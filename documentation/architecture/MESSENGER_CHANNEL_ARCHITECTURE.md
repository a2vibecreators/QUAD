# QUAD Messenger Channel Architecture

**Version:** 1.0
**Created:** January 4, 2026
**Status:** Phase 2 Design (Documented for future implementation)

---

## Executive Summary

QUAD's messenger integration is designed to be **channel-agnostic** - supporting Slack, Microsoft Teams, Discord, WhatsApp Business, Email, and SMS through a unified abstraction layer. This document explains the architectural decisions and why we **don't store message content**.

---

## Key Architectural Decisions

### Decision 1: No Message Content Storage

**Why we DON'T store chat messages:**

| Concern | Explanation |
|---------|-------------|
| **Privacy** | User conversations may contain sensitive info (salaries, personal issues, complaints) |
| **Storage Cost** | Millions of messages × attachments = expensive blob storage |
| **Not Needed** | QUAD only needs to REACT to triggers, not archive conversations |
| **Compliance** | GDPR/CCPA right-to-deletion is complex with stored messages |
| **Already Exists** | Slack/Teams/Discord already store messages - don't duplicate |

**What we DO store:**
- **Commands/Triggers** - When user types `/quad create-ticket` → store the command
- **Bot Responses** - What QUAD replied (for debugging/audit)
- **Operation Results** - Success/failure status of the action

### Decision 2: Channel-Agnostic Design

**Why NOT "Slack" in table names:**

```
❌ QUAD_slack_messages      → Tightly coupled to one vendor
❌ QUAD_slack_bot_commands  → What about Teams? Discord?

✅ QUAD_messenger_channels   → Supports any channel
✅ QUAD_messenger_commands   → Same commands work everywhere
✅ QUAD_messenger_outbound   → Bot can reply to any channel
```

**Supported Channels (Phase 2):**

| Channel | Use Case | API |
|---------|----------|-----|
| **Slack** | Enterprise teams | Slack Bolt SDK |
| **Microsoft Teams** | Corporate environments | Bot Framework |
| **Discord** | Developer communities, gaming | Discord.js |
| **WhatsApp Business** | Mobile-first teams, India | Twilio/Meta API |
| **Email** | Async notifications, digests | SendGrid/SES |
| **SMS** | Critical alerts only | Twilio/MSG91 |

---

## Proposed Schema (Channel-Agnostic)

### Table 1: QUAD_messenger_channels

Stores which channels an org has connected.

```sql
CREATE TABLE QUAD_messenger_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES QUAD_organizations(id) ON DELETE CASCADE,

    -- Channel identification
    channel_type VARCHAR(20) NOT NULL,  -- 'slack', 'teams', 'discord', 'whatsapp', 'email', 'sms'
    channel_name VARCHAR(100),          -- "#dev-team" or "Engineering Chat"
    channel_id VARCHAR(100) NOT NULL,   -- External ID (Slack channel ID, Teams channel ID, etc.)

    -- Connection details
    workspace_id VARCHAR(100),          -- Slack workspace, Teams tenant, Discord server
    webhook_url TEXT,                   -- For sending messages
    bot_token_path VARCHAR(255),        -- Vault path to bot token (not stored here!)

    -- Configuration
    is_active BOOLEAN DEFAULT true,
    notification_types TEXT[],          -- What to send here: ['ticket_created', 'pr_merged', 'deploy_complete']

    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES QUAD_users(id),

    CONSTRAINT valid_channel_type CHECK (channel_type IN ('slack', 'teams', 'discord', 'whatsapp', 'email', 'sms'))
);

CREATE INDEX idx_messenger_channels_org ON QUAD_messenger_channels(org_id);
CREATE INDEX idx_messenger_channels_type ON QUAD_messenger_channels(channel_type);
```

### Table 2: QUAD_messenger_commands

Stores commands/triggers received (NOT full message content).

```sql
CREATE TABLE QUAD_messenger_commands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES QUAD_organizations(id) ON DELETE SET NULL,
    channel_id UUID REFERENCES QUAD_messenger_channels(id) ON DELETE SET NULL,

    -- Who triggered
    user_id UUID REFERENCES QUAD_users(id) ON DELETE SET NULL,
    external_user_id VARCHAR(100),      -- Slack user ID, Teams user ID, etc.
    external_user_name VARCHAR(100),    -- Display name (for audit)

    -- The command
    command VARCHAR(100) NOT NULL,      -- 'create-ticket', 'status', 'assign', 'deploy'
    args JSONB,                         -- Parsed arguments {"title": "...", "priority": "high"}
    raw_text TEXT,                      -- Original command text (for debugging)

    -- Thread context (if reply)
    thread_id VARCHAR(100),             -- Thread/conversation ID
    is_thread_reply BOOLEAN DEFAULT false,

    -- Result
    status VARCHAR(20) DEFAULT 'received',  -- received, processing, completed, failed
    response_summary TEXT,              -- Brief summary of what QUAD did
    error_message TEXT,

    -- Timing
    received_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT valid_command_status CHECK (status IN ('received', 'processing', 'completed', 'failed'))
);

CREATE INDEX idx_messenger_commands_org ON QUAD_messenger_commands(org_id);
CREATE INDEX idx_messenger_commands_user ON QUAD_messenger_commands(user_id);
CREATE INDEX idx_messenger_commands_status ON QUAD_messenger_commands(status);
```

### Table 3: QUAD_messenger_outbound

Stores messages QUAD sends out (not incoming messages).

```sql
CREATE TABLE QUAD_messenger_outbound (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES QUAD_organizations(id) ON DELETE SET NULL,
    channel_id UUID REFERENCES QUAD_messenger_channels(id) ON DELETE SET NULL,

    -- What triggered this message
    trigger_type VARCHAR(50) NOT NULL,  -- 'ticket_created', 'pr_review', 'deploy_complete', 'reminder', 'command_response'
    trigger_id UUID,                    -- Related entity ID (ticket_id, pr_id, etc.)
    command_id UUID REFERENCES QUAD_messenger_commands(id), -- If responding to a command

    -- Message content
    message_type VARCHAR(20) NOT NULL,  -- 'text', 'card', 'button', 'file'
    message_template VARCHAR(100),      -- Template used (for consistency tracking)
    message_content JSONB NOT NULL,     -- Structured content (not raw text)

    -- Targeting
    target_thread_id VARCHAR(100),      -- Reply to specific thread
    target_user_id VARCHAR(100),        -- DM to specific user

    -- Delivery status
    status VARCHAR(20) DEFAULT 'pending',  -- pending, sent, delivered, failed
    external_message_id VARCHAR(100),   -- Message ID from the platform
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,

    -- Timing
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT valid_outbound_status CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'cancelled'))
);

CREATE INDEX idx_messenger_outbound_org ON QUAD_messenger_outbound(org_id);
CREATE INDEX idx_messenger_outbound_status ON QUAD_messenger_outbound(status);
CREATE INDEX idx_messenger_outbound_trigger ON QUAD_messenger_outbound(trigger_type, trigger_id);
```

---

## Message Flow Architecture

### Inbound Flow (User → QUAD)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        INBOUND MESSAGE FLOW                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────┐  ┌─────────┐  │
│  │  Slack  │  │  Teams  │  │ Discord │  │ WhatsApp │  │  Email  │  │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬─────┘  └────┬────┘  │
│       │            │            │            │             │        │
│       └────────────┴─────┬──────┴────────────┴─────────────┘        │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │  WEBHOOK RECEIVER     │  ← Different webhook per      │
│              │  (Channel-Specific)   │    channel type               │
│              └───────────┬───────────┘                               │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │  COMMAND PARSER       │  ← Extract command & args     │
│              │  /quad <cmd> <args>   │                               │
│              └───────────┬───────────┘                               │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │  QUAD_messenger_      │  ← Store COMMAND only         │
│              │  commands             │    (not full chat)            │
│              └───────────┬───────────┘                               │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │  COMMAND HANDLER      │  ← Execute the action         │
│              │  (Ticket, PR, Deploy) │                               │
│              └───────────────────────┘                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

WHAT WE STORE:
✅ Command text: "/quad create-ticket Fix login bug"
✅ Parsed args: {"command": "create-ticket", "title": "Fix login bug"}
✅ Result: "Ticket DEV-123 created"

WHAT WE DON'T STORE:
❌ Previous chat messages
❌ User's casual conversations
❌ Attachments/files from chat
❌ Reactions/emojis
```

### Outbound Flow (QUAD → Channels)

```
┌─────────────────────────────────────────────────────────────────────┐
│                       OUTBOUND MESSAGE FLOW                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                     QUAD EVENTS                                │  │
│  │  • Ticket Created    • PR Approved    • Deploy Complete       │  │
│  │  • Ticket Assigned   • PR Merged      • Test Failed           │  │
│  │  • Comment Added     • Build Failed   • Reminder Due          │  │
│  └───────────────────────────┬───────────────────────────────────┘  │
│                              │                                       │
│                              ▼                                       │
│              ┌───────────────────────┐                               │
│              │  NOTIFICATION ROUTER  │  ← Determine which channels   │
│              │                       │    based on config            │
│              └───────────┬───────────┘                               │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │  MESSAGE FORMATTER    │  ← Channel-specific format    │
│              │  (Slack blocks, Teams │    (Slack blocks vs Teams     │
│              │   Adaptive Cards)     │    Adaptive Cards)            │
│              └───────────┬───────────┘                               │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │  QUAD_messenger_      │  ← Log outbound message       │
│              │  outbound             │    (for audit/retry)          │
│              └───────────┬───────────┘                               │
│                          │                                           │
│       ┌──────────────────┼──────────────────┐                        │
│       │                  │                  │                        │
│       ▼                  ▼                  ▼                        │
│  ┌─────────┐       ┌─────────┐       ┌──────────┐                   │
│  │  Slack  │       │  Teams  │       │  Discord │                   │
│  │   API   │       │Bot Frame│       │   API    │                   │
│  └─────────┘       └─────────┘       └──────────┘                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Supported Commands (Phase 2)

All commands work the same across all channels:

| Command | Description | Example |
|---------|-------------|---------|
| `/quad ticket <title>` | Create new ticket | `/quad ticket Fix login bug` |
| `/quad status` | Show your assigned tickets | `/quad status` |
| `/quad assign <ticket> <user>` | Assign ticket | `/quad assign DEV-123 @john` |
| `/quad comment <ticket> <text>` | Add comment | `/quad comment DEV-123 Working on it` |
| `/quad deploy <env>` | Trigger deployment | `/quad deploy staging` |
| `/quad help` | Show available commands | `/quad help` |

---

## Channel-Specific Formatting

Same notification, different format per channel:

### Example: "Ticket Created" Notification

**Slack (Blocks):**
```json
{
  "blocks": [
    {
      "type": "header",
      "text": {"type": "plain_text", "text": "🎫 New Ticket Created"}
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Ticket:* <https://quad.app/DEV-123|DEV-123>"},
        {"type": "mrkdwn", "text": "*Priority:* 🔴 High"},
        {"type": "mrkdwn", "text": "*Assignee:* @john"},
        {"type": "mrkdwn", "text": "*Circle:* Development"}
      ]
    }
  ]
}
```

**Teams (Adaptive Card):**
```json
{
  "type": "AdaptiveCard",
  "body": [
    {"type": "TextBlock", "text": "🎫 New Ticket Created", "weight": "bolder"},
    {"type": "FactSet", "facts": [
      {"title": "Ticket", "value": "DEV-123"},
      {"title": "Priority", "value": "🔴 High"},
      {"title": "Assignee", "value": "John Smith"}
    ]}
  ],
  "actions": [
    {"type": "Action.OpenUrl", "title": "View Ticket", "url": "https://quad.app/DEV-123"}
  ]
}
```

**Discord (Embed):**
```json
{
  "embeds": [{
    "title": "🎫 New Ticket Created",
    "color": 5814783,
    "fields": [
      {"name": "Ticket", "value": "[DEV-123](https://quad.app/DEV-123)", "inline": true},
      {"name": "Priority", "value": "🔴 High", "inline": true}
    ]
  }]
}
```

**Email (HTML):**
```html
<h2>🎫 New Ticket Created</h2>
<table>
  <tr><td><strong>Ticket:</strong></td><td><a href="https://quad.app/DEV-123">DEV-123</a></td></tr>
  <tr><td><strong>Priority:</strong></td><td>🔴 High</td></tr>
</table>
```

**SMS (Plain text):**
```
QUAD: New ticket DEV-123 assigned to you. Priority: High. https://quad.app/DEV-123
```

---

## Migration Plan: Slack → Generic

### Current Tables (to be renamed)

```sql
-- Current (Phase 1 - Slack-specific)
QUAD_slack_bot_commands  → QUAD_messenger_commands
QUAD_slack_messages      → QUAD_messenger_outbound (repurposed)
```

### Migration Steps

1. **Create new generic tables** (QUAD_messenger_*)
2. **Migrate data** from slack_* to messenger_*
3. **Add channel_type column** (default 'slack' for existing)
4. **Drop old tables** after verification
5. **Update application code** to use new tables

---

## Why NOT Store Full Messages

### Scenario: User Discussion

```
[#dev-team channel]
Alice: Hey, did anyone see the bug in production?
Bob: Yeah, the login is broken
Charlie: @alice can you create a ticket?
Alice: /quad ticket Login button not working in production
QUAD Bot: ✅ Created ticket DEV-456 - "Login button not working in production"
```

**What we store:**
```sql
-- QUAD_messenger_commands
{
  command: "ticket",
  args: {"title": "Login button not working in production"},
  user: "alice",
  result: "Created DEV-456"
}
```

**What we DON'T store:**
- Alice's question "Hey, did anyone see the bug..."
- Bob's response "Yeah, the login is broken"
- Charlie's mention "@alice can you create a ticket?"

**Why?** This conversation is already in Slack. We don't need a copy. We only need to know that Alice created a ticket.

---

## Phase 2 Implementation Priority

| Priority | Channel | Reason |
|----------|---------|--------|
| **P1** | Slack | Most enterprise teams already use it |
| **P1** | Email | Async notifications, works everywhere |
| **P2** | Microsoft Teams | Corporate environments |
| **P2** | Discord | Developer communities |
| **P3** | WhatsApp Business | India market, mobile-first |
| **P3** | SMS | Critical alerts only (expensive) |

---

## Summary

1. **Don't store messages** - Just commands/triggers and our responses
2. **Channel-agnostic design** - Same commands work on Slack, Teams, Discord
3. **Rename tables** - `QUAD_slack_*` → `QUAD_messenger_*`
4. **Format per channel** - Slack blocks, Teams cards, Discord embeds
5. **Phase 2** - But architecture documented now so we don't forget

---

**Related Documents:**
- [DATABASE_ARCHITECTURE.md](../database/DATABASE_ARCHITECTURE.md)
- [DISCUSSIONS_LOG.md](../internal/DISCUSSIONS_LOG.md) - Decision #23

