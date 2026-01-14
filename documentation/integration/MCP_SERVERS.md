# QUAD Platform - MCP Servers Integration

**Purpose:** Document all MCP (Model Context Protocol) servers that QUAD Platform can integrate with.
**Last Updated:** January 8, 2026

---

## What is MCP?

MCP (Model Context Protocol) is Anthropic's standard for connecting AI assistants to external tools and data sources.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Claude Code    │────▶│   MCP Server    │────▶│  External API   │
│  (AI Assistant) │◀────│   (Bridge)      │◀────│  (Zoom, Jira)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**Benefits:**
- Standardized tool interface
- Secure credential management
- Real-time data access
- Bidirectional communication

---

## MCP Servers for QUAD Platform

### Priority Legend
- 🔴 **P0** - Critical for MVP (Meeting Agent)
- 🟡 **P1** - Important for launch
- 🟢 **P2** - Nice to have
- ⚪ **P3** - Future consideration

---

## 1. Zoom MCP Server 🔴 P0

### Overview
Connect QUAD agents to Zoom for meeting management and transcript processing.

### Capabilities

| Feature | Zoom Basic | Zoom Pro | Zoom Business |
|---------|------------|----------|---------------|
| List meetings | ✅ | ✅ | ✅ |
| Schedule meetings | ✅ | ✅ | ✅ |
| Get meeting details | ✅ | ✅ | ✅ |
| Cloud recordings | ❌ | ✅ | ✅ |
| Transcripts | ❌ | ✅ | ✅ |
| Real-time events | ❌ | ✅ | ✅ |
| Webhooks | Limited | ✅ | ✅ |

### Setup Requirements

1. **Zoom Developer Account**
   - URL: https://marketplace.zoom.us/
   - Create Server-to-Server OAuth app

2. **Credentials Needed**
   ```
   ZOOM_ACCOUNT_ID=<account_id>
   ZOOM_CLIENT_ID=<client_id>
   ZOOM_CLIENT_SECRET=<client_secret>
   ```

3. **Scopes Required**
   ```
   meeting:read
   meeting:write
   recording:read
   user:read
   ```

### MCP Server Implementation

**Location:** `/Users/semostudio/mcp-servers/zoom-mcp/`

```javascript
// zoom-mcp/index.js
const { Server } = require('@modelcontextprotocol/sdk/server');
const { ZoomAPI } = require('./zoom-api');

const server = new Server({
  name: 'zoom-mcp',
  version: '1.0.0',
});

// Tool: List Meetings
server.tool('zoom_list_meetings', {
  description: 'List upcoming Zoom meetings',
  parameters: {
    type: { type: 'string', enum: ['scheduled', 'live', 'upcoming'] },
    page_size: { type: 'number', default: 30 }
  },
  handler: async ({ type, page_size }) => {
    const zoom = new ZoomAPI();
    return await zoom.listMeetings(type, page_size);
  }
});

// Tool: Get Meeting Transcript
server.tool('zoom_get_transcript', {
  description: 'Get transcript from a recorded meeting',
  parameters: {
    meeting_id: { type: 'string', required: true }
  },
  handler: async ({ meeting_id }) => {
    const zoom = new ZoomAPI();
    return await zoom.getTranscript(meeting_id);
  }
});

// Tool: Schedule Meeting
server.tool('zoom_schedule_meeting', {
  description: 'Schedule a new Zoom meeting',
  parameters: {
    topic: { type: 'string', required: true },
    start_time: { type: 'string', required: true },
    duration: { type: 'number', default: 60 },
    agenda: { type: 'string' }
  },
  handler: async (params) => {
    const zoom = new ZoomAPI();
    return await zoom.scheduleMeeting(params);
  }
});

module.exports = server;
```

### Claude Code Configuration

**Add to:** `~/.claude/settings.json`
```json
{
  "mcpServers": {
    "zoom": {
      "command": "node",
      "args": ["/Users/semostudio/mcp-servers/zoom-mcp/index.js"],
      "env": {
        "ZOOM_ACCOUNT_ID": "${ZOOM_ACCOUNT_ID}",
        "ZOOM_CLIENT_ID": "${ZOOM_CLIENT_ID}",
        "ZOOM_CLIENT_SECRET": "${ZOOM_CLIENT_SECRET}"
      }
    }
  }
}
```

### Use Cases for QUAD

1. **Meeting Agent - Auto MOM Generation**
   ```
   Meeting ends → Webhook triggers → Get transcript → Generate MOM → Send to BA
   ```

2. **Meeting Agent - Action Item Extraction**
   ```
   Transcript → AI extracts action items → Create Jira tickets → Assign to team
   ```

3. **Meeting Scheduler**
   ```
   "Schedule standup for Circle 1 tomorrow 9 AM" → Creates Zoom meeting → Sends invites
   ```

### Alternative: Fireflies.ai Integration

If using Zoom Basic (no transcripts), integrate with Fireflies.ai:

| Feature | Fireflies.ai |
|---------|--------------|
| Works with Zoom Basic | ✅ |
| Auto-join meetings | ✅ |
| Real-time transcription | ✅ |
| API access | ✅ |
| Pricing | Free tier available |

---

## 2. Jira MCP Server 🔴 P0

### Overview
Connect QUAD agents to Jira for ticket management.

### Capabilities

| Feature | Description |
|---------|-------------|
| Create issues | Create tickets from meeting action items |
| Update issues | Move tickets through workflow |
| Search issues | JQL queries for reporting |
| Get comments | Read ticket discussions |
| Add comments | Post AI-generated updates |

### Setup Requirements

1. **Atlassian API Token**
   - URL: https://id.atlassian.com/manage-profile/security/api-tokens

2. **Credentials Needed**
   ```
   JIRA_HOST=https://yourcompany.atlassian.net
   JIRA_EMAIL=your-email@company.com
   JIRA_API_TOKEN=<api_token>
   ```

### MCP Server Implementation

**Location:** `/Users/semostudio/mcp-servers/jira-mcp/`

```javascript
// jira-mcp/index.js
const { Server } = require('@modelcontextprotocol/sdk/server');

const server = new Server({
  name: 'jira-mcp',
  version: '1.0.0',
});

// Tool: Create Issue
server.tool('jira_create_issue', {
  description: 'Create a Jira issue',
  parameters: {
    project: { type: 'string', required: true },
    summary: { type: 'string', required: true },
    description: { type: 'string' },
    issue_type: { type: 'string', default: 'Task' },
    assignee: { type: 'string' },
    priority: { type: 'string', default: 'Medium' }
  },
  handler: async (params) => {
    // Implementation
  }
});

// Tool: Search Issues
server.tool('jira_search', {
  description: 'Search Jira issues using JQL',
  parameters: {
    jql: { type: 'string', required: true },
    max_results: { type: 'number', default: 50 }
  },
  handler: async ({ jql, max_results }) => {
    // Implementation
  }
});

// Tool: Transition Issue
server.tool('jira_transition', {
  description: 'Move issue to different status',
  parameters: {
    issue_key: { type: 'string', required: true },
    transition: { type: 'string', required: true }
  },
  handler: async ({ issue_key, transition }) => {
    // Implementation
  }
});

module.exports = server;
```

### Use Cases for QUAD

1. **Auto-create tickets from meetings**
2. **Update ticket status from code commits**
3. **Generate sprint reports**
4. **Link PRs to tickets**

---

## 3. GitHub MCP Server 🔴 P0

### Overview
Connect QUAD agents to GitHub for code and PR management.

### Capabilities

| Feature | Description |
|---------|-------------|
| List PRs | Get open pull requests |
| Create PR | Auto-create PRs from branches |
| Review PR | AI-assisted code review |
| Get commits | Track changes |
| Manage issues | GitHub Issues integration |

### Setup Requirements

```
GITHUB_TOKEN=<personal_access_token>
GITHUB_ORG=a2Vibes
```

### Use Cases for QUAD

1. **Auto-create PR when code is ready**
2. **AI code review comments**
3. **Link commits to Jira tickets**
4. **Generate changelog from PRs**

---

## 4. Slack MCP Server 🟡 P1

### Overview
Connect QUAD agents to Slack for team communication.

### Capabilities

| Feature | Description |
|---------|-------------|
| Send messages | Post to channels |
| Read messages | Monitor for commands |
| Create channels | Auto-create project channels |
| Manage threads | Threaded conversations |

### Setup Requirements

```
SLACK_BOT_TOKEN=xoxb-<token>
SLACK_APP_TOKEN=xapp-<token>
```

### Use Cases for QUAD

1. **"@quad add login button to header"** → Creates ticket → Implements
2. **Post MOM to project channel**
3. **Daily standup summaries**
4. **Alert on blockers**

---

## 5. Google Calendar MCP Server 🟡 P1

### Overview
Connect QUAD agents to Google Calendar for scheduling.

### Capabilities

| Feature | Description |
|---------|-------------|
| List events | Get upcoming meetings |
| Create events | Schedule meetings |
| Update events | Reschedule |
| Check availability | Find free slots |

### Use Cases for QUAD

1. **Auto-schedule sprint ceremonies**
2. **Find best meeting times**
3. **Sync with Zoom meetings**

---

## 6. Confluence MCP Server 🟢 P2

### Overview
Connect QUAD agents to Confluence for documentation.

### Capabilities

| Feature | Description |
|---------|-------------|
| Create pages | Auto-generate docs |
| Update pages | Keep docs current |
| Search | Find existing docs |
| Get page content | Read for context |

### Use Cases for QUAD

1. **Auto-generate technical specs from code**
2. **Keep architecture docs updated**
3. **Create release notes**

---

## 7. Azure DevOps MCP Server 🟢 P2

### Overview
Alternative to GitHub/Jira for Microsoft-centric enterprises.

### Capabilities

| Feature | Description |
|---------|-------------|
| Work items | Create/update tasks |
| Repos | Git operations |
| Pipelines | CI/CD management |
| Boards | Sprint management |

---

## 8. Figma MCP Server 🟢 P2

### Overview
Connect QUAD agents to Figma for design handoff.

### Capabilities

| Feature | Description |
|---------|-------------|
| Get designs | Fetch UI specs |
| Export assets | Download images/icons |
| Get comments | Design feedback |
| Dev mode | CSS/code extraction |

### Use Cases for QUAD

1. **Blueprint Agent reads Figma designs**
2. **Auto-generate component code from designs**
3. **Track design-to-code coverage**

---

## 9. Database MCP Server 🟢 P2

### Overview
Direct database access for QUAD agents.

### Capabilities

| Feature | Description |
|---------|-------------|
| Query | Read-only SQL queries |
| Schema | Get table structures |
| Explain | Query optimization |

### Use Cases for QUAD

1. **Generate reports from data**
2. **Validate data migrations**
3. **Debug data issues**

---

## 10. Email MCP Server 🟢 P2

### Overview
Connect QUAD agents to email for communication.

### Capabilities

| Feature | Description |
|---------|-------------|
| Send email | Send MOMs, reports |
| Read email | Parse requirements from email |
| Search | Find related emails |

### Use Cases for QUAD

1. **Send MOM after meetings**
2. **Email Agent: "quad@company.com" receives requirements**
3. **Weekly status reports**

---

## Implementation Roadmap

### Phase 1 (MVP) - Meeting Agent
| Server | Status | Target |
|--------|--------|--------|
| Zoom MCP | 🔴 Not Started | Week 1 |
| Jira MCP | 🔴 Not Started | Week 1 |
| GitHub MCP | 🔴 Not Started | Week 2 |

### Phase 2 - Communication
| Server | Status | Target |
|--------|--------|--------|
| Slack MCP | 🔴 Not Started | Week 3 |
| Google Calendar MCP | 🔴 Not Started | Week 3 |
| Email MCP | 🔴 Not Started | Week 4 |

### Phase 3 - Extended
| Server | Status | Target |
|--------|--------|--------|
| Confluence MCP | 🔴 Not Started | Week 5 |
| Figma MCP | 🔴 Not Started | Week 5 |
| Database MCP | 🔴 Not Started | Week 6 |

---

## Directory Structure

```
/Users/semostudio/mcp-servers/
├── zoom-mcp/
│   ├── index.js
│   ├── zoom-api.js
│   ├── package.json
│   └── README.md
├── jira-mcp/
│   ├── index.js
│   ├── jira-api.js
│   ├── package.json
│   └── README.md
├── github-mcp/
│   ├── index.js
│   ├── github-api.js
│   ├── package.json
│   └── README.md
├── slack-mcp/
│   └── ...
└── shared/
    ├── auth.js
    ├── logger.js
    └── utils.js
```

---

## Credentials Storage

All MCP server credentials stored in Vaultwarden:

**Location:** QUAD Organization → dev/qa/prod collections

| Secret Name | Used By |
|-------------|---------|
| Zoom OAuth | zoom-mcp |
| Jira API Token | jira-mcp |
| GitHub Token | github-mcp |
| Slack Bot Token | slack-mcp |
| Google OAuth | calendar-mcp |

---

## Next Steps

1. **Create Zoom Developer Account** - Get OAuth credentials
2. **Build zoom-mcp server** - Start with list meetings
3. **Test with Claude Code** - Verify MCP connection
4. **Build Meeting Agent flow** - Transcript → MOM → Jira

---

**Document Version:** 1.0
**Author:** QUAD Platform Team
