# QUAD Platform - Session Management System

**Tagline:** *"Lost context? Just run `quadframework-init` to restore your session."*

**Version:** 1.0.0
**Last Updated:** December 31, 2025

---

## Overview

QUAD Platform uses an intelligent session management system that preserves context across Claude Code conversations.

**Problem We Solve:**
- ❌ Claude Code conversations get compacted (context window limit)
- ❌ User switches to different project, loses QUAD Platform context
- ❌ Conversation reset means Claude "forgets" what we're working on

**Our Solution:**
- ✅ `.claudeagent/` folder stores session state
- ✅ `quadframework-init` command restores full context
- ✅ Session persists across conversation resets

---

## Session State Storage

### Directory Structure

```
/Users/semostudio/git/a2vibecreators/quadframework/
├── .claudeagent/
│   ├── SESSION_HISTORY.md         # Compacted conversation summaries
│   ├── AGENT_RULES.md             # Project-specific rules for Claude
│   ├── AGENT_CONTEXT_FILES.md     # Important files Claude should read
│   ├── DATABASE_CHANGELOG.md      # Why database changes were made
│   └── archive/
│       ├── session-2025-12-30.md  # Archived sessions
│       └── session-2025-12-31.md
```

### What Gets Stored

**SESSION_HISTORY.md:**
```markdown
# QUAD Platform Session History

## December 31, 2025 - OAuth SSO Implementation

**What was done:**
- Created 6 QUAD_ database tables (organizations, users, integrations, etc.)
- Implemented NextAuth.js with 6 SSO providers (Okta, Azure AD, Google, GitHub, Auth0, OIDC)
- Built authentication flow with free tier enforcement (5 users)
- Created documentation structure (similar to NutriNine)

**Key decisions:**
- Self-hosted deployment model (not SaaS in our cloud)
- Polling agents (30s interval) instead of webhooks
- Shared PostgreSQL database with NutriNine (QUAD_ prefix)
- OAuth SSO only (no passwords)

**Next steps:**
- Build auth pages (signup/login UI)
- Create dashboard pages
- Implement polling agents (Jira, GitHub, Slack)
```

**AGENT_RULES.md:**
```markdown
# QUAD Platform - Rules for Claude Agent

1. Always check SESSION_HISTORY.md before starting work
2. Update SESSION_HISTORY.md after completing major features
3. Use TodoWrite tool to track multi-step tasks
4. Ask user before deploying to production
5. Follow architecture decisions (self-hosted, polling, OAuth)
6. Database tables use QUAD_ prefix (shared with NutriNine)
7. Documentation follows NutriNine structure
```

---

## The `quadframework-init` Command

### What It Does

When you run `quadframework-init`, Claude Code:

1. **Reads session files:**
   ```
   .claudeagent/SESSION_HISTORY.md
   .claudeagent/AGENT_RULES.md
   .claudeagent/AGENT_CONTEXT_FILES.md
   ```

2. **Restores context:**
   - What features have been built
   - What architectural decisions were made
   - What's currently in progress
   - What files are important

3. **Resumes work:**
   - Picks up where we left off
   - No need to re-explain project
   - Knows the codebase structure

### How to Use

**Scenario 1: After Conversation Compacting**

```bash
# Claude says: "Conversation compacted, some context may be lost"

# You type:
/quadframework-init

# Claude reads:
- SESSION_HISTORY.md (what we've built)
- AGENT_RULES.md (how to work on this project)
- AGENT_CONTEXT_FILES.md (important files)

# Claude responds:
"✅ Session restored! I see we're working on QUAD Platform.
Last session: Implemented OAuth SSO with 6 providers.
Current task: Building auth pages (signup/login UI).
Ready to continue?"
```

**Scenario 2: Switching Between Projects**

```bash
# User was working on NutriNine, now wants to work on QUAD Platform

# You type:
/quadframework-init

# Claude reads session files and understands:
"I'm now working on QUAD Platform (not NutriNine).
Architecture: Self-hosted, OAuth SSO, polling agents.
Database: QUAD_ tables in shared PostgreSQL.
Ready to continue work on auth pages."
```

**Scenario 3: New Developer Onboarding**

```bash
# New developer clones repo, runs:
/quadframework-init

# Claude introduces the project:
"Welcome to QUAD Platform!

Overview:
- Self-hosted enterprise SaaS for AI-powered software workflows
- Uses OAuth SSO (Okta, Azure AD, Google, GitHub)
- Real-time polling agents (Jira, GitHub, Slack)
- Free tier: 5 users

Current status:
- ✅ Database schema complete (6 tables)
- ✅ OAuth SSO complete
- 🔄 Auth pages in progress

What would you like to work on?"
```

---

## Implementation

### slash command: `/quadframework-init`

**Location:** `.claude/commands/quadframework-init.md`

```markdown
# QUAD Platform - Restore Session Context

You are working on **QUAD Platform**, a self-hosted enterprise SaaS for AI-powered software development workflows.

## Read These Files First

Before responding, read these files to restore session context:

1. `.claudeagent/SESSION_HISTORY.md` - What we've built so far
2. `.claudeagent/AGENT_RULES.md` - Project rules and conventions
3. `.claudeagent/AGENT_CONTEXT_FILES.md` - Important files to review
4. `documentation/QUAD_PLATFORM.md` - Technical overview

## Project Summary

**Technology Stack:**
- Next.js 15 (App Router) - Web app
- PostgreSQL 15 - Database (QUAD_ tables)
- NextAuth.js - OAuth SSO
- Docker Compose - Deployment

**Key Decisions:**
- Self-hosted (customer's cloud, not our SaaS)
- Polling agents (30s interval, not webhooks)
- OAuth SSO only (Okta, Azure AD, Google, GitHub, Auth0, OIDC)
- Free tier: 5 users, Pro: unlimited users ($99/month)

**Database Location:**
- Shared with NutriNine: `/Users/semostudio/git/a2vibecreators/nutrinine/nutrinine-database/`
- Tables: `QUAD_organizations`, `QUAD_users`, `QUAD_org_integrations`, etc.
- Note: `company_id` column in tables maps to `org_id` in Prisma for code clarity

## After Restoring Context

1. Summarize what was done in last session
2. Identify current task (check TodoWrite list)
3. Ask: "Ready to continue? What should I work on next?"
```

**Location:** `.claude/commands/quadframework-init.md` *(to be created)*

---

## Session History Best Practices

### When to Update SESSION_HISTORY.md

**Update after:**
- ✅ Completing a major feature (OAuth SSO, dashboard, etc.)
- ✅ Making architectural decision (self-hosted, polling, etc.)
- ✅ Finishing a sprint/milestone
- ✅ Before ending work session

**Don't update for:**
- ❌ Minor bug fixes
- ❌ Small documentation changes
- ❌ Mid-feature work

### What to Include

```markdown
## [Date] - [Feature Name]

**What was done:**
- Bullet points of completed work

**Key decisions:**
- Why we chose X over Y

**Code locations:**
- Important files created/modified

**Next steps:**
- What needs to be done next

**Blockers:**
- Any issues or dependencies
```

---

## Integration with TodoWrite

**TodoWrite** tracks current tasks, **SESSION_HISTORY** tracks completed work.

**Example workflow:**

```bash
# Start of session
/quadframework-init  # Restore context

# Claude reads TodoWrite:
[1. ✅ Build OAuth SSO - completed]
[2. 🔄 Create auth pages - in progress]
[3. ⏳ Build dashboard - pending]

# Work on task
[builds auth pages]

# End of session - Update SESSION_HISTORY.md
## December 31, 2025 - Auth Pages UI

**What was done:**
- Created /login page with SSO buttons
- Created /signup page for QUAD_ADMIN
- Added free tier enforcement (5 users)

**Key decisions:**
- Use shadcn/ui components for consistency
- Show only enabled SSO providers (based on env vars)

**Next steps:**
- Build dashboard pages
- Implement polling agents
```

---

## Benefits

| Benefit | Without Session Mgmt | With Session Mgmt |
|---------|---------------------|-------------------|
| **Context Loss** | ❌ Conversation compacts → forget everything | ✅ Run /quadframework-init → restore |
| **Project Switch** | ❌ Explain project again | ✅ Auto-loads context |
| **New Developer** | ❌ Read all docs manually | ✅ One command onboarding |
| **Consistency** | ❌ Different agents work differently | ✅ Rules enforced |
| **History** | ❌ Lost in conversation | ✅ Persisted in files |

---

## AI API Session Management (Claude is Stateless)

### The Problem

Claude API (and all LLM APIs) are **stateless HTTP calls**:
- Each request is independent
- No memory of previous conversations
- We must send context with EVERY call

```
Without context management:
├── Request 1: "Analyze ticket PROJ-123"
│   └── Claude: Analyzes and responds
├── Request 2: "What did you suggest?"
│   └── Claude: "I don't know what you're referring to"
```

### The Solution: Database-Backed Context

QUAD stores AI context in the database and loads it for each request:

```
With QUAD context management:
├── User asks: "Analyze ticket PROJ-123"
│   ├── Load user's recent context from QUAD_ai_contexts
│   ├── Load ticket details
│   ├── Build system prompt + context + question
│   ├── Call Claude API
│   ├── Save response to QUAD_ai_contexts
│   └── Return response to user
│
├── User asks: "What did you suggest?"
│   ├── Load previous context (from QUAD_ai_contexts)
│   ├── Claude sees: "You previously analyzed PROJ-123 and suggested..."
│   └── Claude responds with relevant history
```

### Database Tables

**QUAD_ai_contexts** - Stores conversation and activity context:
```sql
- user_id: Who this context belongs to
- domain_id: Which project (optional)
- lifecycle: core | long_term | short_term | momentary
- context_type: conversation | activity | decision | preference
- summary: Brief summary
- full_content: Full details
- entity_type: ticket | sprint | requirement | pr
- entity_id: Link to specific entity
- expires_at: Auto-cleanup based on lifecycle
```

**QUAD_ai_context_relationships** - Links related contexts:
```sql
- source_context_id / target_context_id
- relationship_type: follow_up | related_to | caused_by
- relationship_strength: 0.00 to 1.00
```

**QUAD_user_activity_summaries** - Pre-computed activity for fast loading:
```sql
- user_id: Who
- period_type: daily | weekly
- tickets_created/completed, prs_created/reviewed, deployments
- ai_summary: AI-generated summary of the period
- recent_ticket_ids, recent_pr_ids: Quick reference
```

### Context Loading on Login

When a user logs in, QUAD loads their recent context:

```typescript
async function loadUserContext(userId: string) {
  // 1. Load activity summaries (last 7 days)
  const summaries = await prisma.QUAD_user_activity_summaries.findMany({
    where: {
      user_id: userId,
      period_start: { gte: sevenDaysAgo }
    }
  });

  // 2. Load recent conversations (short_term + core)
  const contexts = await prisma.QUAD_ai_contexts.findMany({
    where: {
      user_id: userId,
      lifecycle: { in: ['core', 'short_term'] },
      OR: [
        { expires_at: null },
        { expires_at: { gt: new Date() } }
      ]
    },
    orderBy: { created_at: 'desc' },
    take: 20
  });

  // 3. Load recent tickets
  const recentTickets = await prisma.QUAD_tickets.findMany({
    where: { assigned_to: userId },
    orderBy: { updated_at: 'desc' },
    take: 5
  });

  return { summaries, contexts, recentTickets };
}
```

### Context-Aware AI Calls

When calling Claude, include loaded context:

```typescript
async function callClaudeWithContext(
  userId: string,
  domainId: string,
  userQuestion: string,
  entityContext?: { type: string; id: string }
) {
  // 1. Load user context
  const userContext = await loadUserContext(userId);

  // 2. Build context summary
  const contextSummary = buildContextSummary(userContext);

  // 3. Build prompt
  const systemPrompt = `
    You are the QUAD AI assistant.

    User Context:
    ${contextSummary}

    ${entityContext ? `Currently viewing: ${entityContext.type} ${entityContext.id}` : ''}
  `;

  // 4. Call Claude API
  const response = await anthropic.messages.create({
    model: 'claude-3-5-haiku-latest', // 80% of calls
    max_tokens: 1024,
    system: systemPrompt,
    messages: [{ role: 'user', content: userQuestion }]
  });

  // 5. Save context for future reference
  await prisma.QUAD_ai_contexts.create({
    data: {
      user_id: userId,
      domain_id: domainId,
      lifecycle: 'short_term',
      context_type: 'conversation',
      summary: `Asked about: ${userQuestion.substring(0, 100)}`,
      full_content: JSON.stringify({
        question: userQuestion,
        response: response.content[0].text
      }),
      entity_type: entityContext?.type,
      entity_id: entityContext?.id,
      expires_at: addDays(new Date(), 30) // 30 days for short_term
    }
  });

  return response;
}
```

### Lifecycle Management

| Lifecycle | Duration | Use Case | Example |
|-----------|----------|----------|---------|
| **core** | Forever | Important decisions, preferences | "User prefers verbose code comments" |
| **long_term** | 1 year | Project-level context | "User worked on auth module" |
| **short_term** | 30 days | Recent conversations | "User asked about PROJ-123" |
| **momentary** | 7 days | Temporary context | "User is debugging login" |

### Background Cleanup Job

```typescript
// Run daily to clean expired contexts
async function cleanupExpiredContexts() {
  await prisma.QUAD_ai_contexts.deleteMany({
    where: {
      expires_at: { lt: new Date() }
    }
  });
}
```

### Smart Context Strategy: Load Only When Necessary

**Key Insight:** Don't send context every time. Only load what's needed.

| Request Type | Context Level | What to Load | Tokens Used |
|--------------|---------------|--------------|-------------|
| **Simple query** | NONE | Just query database | 0 |
| **Entity-specific** | MINIMAL | Entity details only | ~200 |
| **Follow-up** | RECENT | Last 1-2 conversations | ~500 |
| **Complex planning** | FULL | Everything relevant | ~2000 |

**Detection Logic:**

```typescript
function determineContextLevel(question: string, hasRecentConversation: boolean): ContextLevel {
  // Follow-up keywords = needs recent context
  if (/what did you|you (said|mentioned|suggested)|earlier|previous|continue/i.test(question)) {
    return 'RECENT';
  }

  // Planning/analysis keywords = needs full context
  if (/plan|prioritize|based on|history|overview|summarize my/i.test(question)) {
    return 'FULL';
  }

  // Entity-specific (ticket, PR, etc.) = minimal context
  if (/PROJ-\d+|PR-\d+|sprint|ticket/i.test(question)) {
    return 'MINIMAL';
  }

  // Simple questions = no AI context needed (just DB query)
  if (/status|what is|list|show me/i.test(question)) {
    return 'NONE';
  }

  // Default: minimal if recent conversation exists, none otherwise
  return hasRecentConversation ? 'MINIMAL' : 'NONE';
}
```

**Examples:**

```typescript
// NONE - No AI call needed, just DB query
"What's the status of PROJ-123?"
  → Query: SELECT status FROM tickets WHERE ticket_number = 'PROJ-123'
  → Response: "PROJ-123 is in_progress"
  → AI tokens: 0

// MINIMAL - Only entity details
"Analyze ticket PROJ-123 and suggest implementation"
  → Load: Ticket title, description, acceptance criteria
  → AI analyzes just this ticket
  → AI tokens: ~300

// RECENT - Include last conversation
"What did you suggest for the implementation?"
  → Load: Last AI response from QUAD_ai_contexts
  → AI has context of previous suggestion
  → AI tokens: ~800

// FULL - Load everything
"Based on my work this week, what should I prioritize?"
  → Load: Activity summary + recent tickets + preferences
  → AI has full picture
  → AI tokens: ~2500
```

**Implementation:**

```typescript
async function callClaudeSmartContext(
  userId: string,
  question: string,
  entityContext?: { type: string; id: string }
) {
  // 1. Check if we even need AI
  const simpleAnswer = await trySimpleDatabaseQuery(question);
  if (simpleAnswer) {
    return { answer: simpleAnswer, ai_used: false, tokens: 0 };
  }

  // 2. Determine context level needed
  const hasRecentConvo = await hasRecentConversation(userId);
  const contextLevel = determineContextLevel(question, hasRecentConvo);

  // 3. Load appropriate context
  let context = '';
  switch (contextLevel) {
    case 'NONE':
      context = ''; // No additional context
      break;
    case 'MINIMAL':
      context = entityContext ? await loadEntityDetails(entityContext) : '';
      break;
    case 'RECENT':
      context = await loadRecentConversation(userId, 2); // Last 2 exchanges
      break;
    case 'FULL':
      context = await loadFullContext(userId);
      break;
  }

  // 4. Call Claude with optimized context
  const response = await callClaude(question, context);

  // 5. Save response for potential follow-ups
  await saveToContext(userId, question, response);

  return { answer: response, ai_used: true, tokens: estimatedTokens };
}
```

**Result:**

| Before (Always Full Context) | After (Smart Loading) |
|------------------------------|----------------------|
| Every request: ~2000 tokens | Simple: 0 tokens |
| Cost: $0.003/request | Minimal: ~300 tokens |
| Latency: 2-3 seconds | Cost: $0.0003-0.002/request |
| | Latency: 0.5-2 seconds |

**Session ID for Follow-ups:**

For follow-up questions, we track a "conversation session":

```typescript
// User's browser stores last_context_id
// When user asks follow-up, include last_context_id

POST /api/ai/chat
{
  "question": "What did you suggest?",
  "last_context_id": "uuid-of-previous-response"  // Optional
}

// Server loads only that specific context, not everything
```

---

## Future Enhancements

### Phase 2: Multi-Project Context

```bash
# User works on both NutriNine and QUAD Platform

/nutrinine-init       # Switches context to NutriNine
/quadframework-init   # Switches context to QUAD Platform

# Claude knows which project is active
# Loads correct session history
# Follows project-specific rules
```

### Phase 3: Team Collaboration

```bash
# SESSION_HISTORY.md includes author
## December 31, 2025 - OAuth SSO (by Suman)
[work details]

## January 2, 2026 - Dashboard (by John)
[work details]

# Team members can see what others did
# No duplicate work
# Smooth handoffs
```

---

## Related Documentation

- [Agent Rules](.claudeagent/AGENT_RULES.md)
- [Session History](.claudeagent/SESSION_HISTORY.md)
- [Context Files](.claudeagent/AGENT_CONTEXT_FILES.md)
- [QUAD Platform Overview](QUAD_PLATFORM.md)

---

**Tagline:** *"Lost context? Just run `quadframework-init` to restore your session."*

**Author:** A2Vibe Creators LLC
**Last Updated:** December 31, 2025
