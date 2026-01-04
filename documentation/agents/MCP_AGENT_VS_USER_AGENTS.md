# MCP Agents vs User Agents (Slash Commands)

## Table of Contents
1. [Overview](#overview)
2. [What is a User Agent (Slash Command)?](#what-is-a-user-agent-slash-command)
3. [What is an MCP Agent?](#what-is-an-mcp-agent)
4. [Side-by-Side Comparison](#side-by-side-comparison)
5. [Architecture Diagrams](#architecture-diagrams)
6. [When to Use Which](#when-to-use-which)
7. [QUAD Framework Integration](#quad-framework-integration)
8. [Implementation Examples](#implementation-examples)

---

## Overview

There are two paradigms for extending AI assistant capabilities:

| Paradigm | Examples | Use Case |
|----------|----------|----------|
| **User Agent** | `/nutrinine-init`, `/devstudio`, `/qastudio` | Project-specific workflows, context loading |
| **MCP Agent** | MCP Server for Slack, GitHub, Database | Tool providers for AI clients |

**Key Insight**: User Agents are **prompt injection patterns** (markdown instructions). MCP Agents are **tool servers** (JSON-RPC services).

---

## What is a User Agent (Slash Command)?

### Definition

A User Agent (slash command) is a **markdown-based prompt template** that injects context and instructions into an AI conversation. It runs within Claude Code as a text expansion.

### Location

```
project-root/
└── .claude/
    └── commands/
        ├── nutrinine-init.md       # /nutrinine-init
        ├── devstudio.md            # /devstudio
        ├── qastudio.md             # /qastudio
        └── custom-command.md       # /custom-command
```

### Anatomy of a User Agent

```markdown
# Command Name

You are the [Role] Agent. Initialize by following these steps:

## STEP 1: Load Context
Read these files in order:
1. `.claudeagent/AGENT_RULES.md` - Learn rules
2. `CLAUDE.md` - Understand architecture
3. `SESSION_HISTORY.md` - Know recent work

## STEP 2: Perform Actions
- Follow rules from AGENT_RULES.md
- Use tools available in Claude Code (Bash, Read, Write, etc.)

## STEP 3: Output Format
Respond with:
- Status summary
- Ready to work message

## Rules
- NEVER do X
- ALWAYS do Y
```

### Characteristics

| Aspect | User Agent Behavior |
|--------|---------------------|
| **Execution** | Claude Code expands markdown into conversation |
| **State** | Stateless - must reload context each invocation |
| **Memory** | Via markdown files (SESSION_HISTORY.md) |
| **Tools** | Uses Claude Code's built-in tools (Bash, Read, Write, etc.) |
| **AI Provider** | Claude only (runs in Claude Code) |
| **Setup** | Zero config - just create .md file |
| **Scope** | Project-specific (per repo) |

### Example: nutrinine-init Agent

The `/nutrinine-init` command demonstrates a sophisticated User Agent:

```
Invocation: /nutrinine-init

What Happens:
1. Claude Code reads .claude/commands/nutrinine-init.md
2. Markdown content is injected into conversation context
3. Claude follows the instructions:
   - Saves previous session to SESSION_HISTORY.md
   - Loads secrets from Vaultwarden
   - Reads 9 context files in order
   - Greets user with context summary
4. Agent is now "initialized" with full project context
```

**Key Features of nutrinine-init**:
- 7-step initialization workflow
- Two-tier memory system (Active Tasks vs Completed)
- Vault secret management
- Session history compaction rules
- Deployment quick reference

---

## What is an MCP Agent?

### Definition

An MCP (Model Context Protocol) Agent is an **external server** that provides tools via JSON-RPC. Any MCP-compatible AI client can connect to it.

### Architecture

```
┌──────────────────┐     JSON-RPC      ┌──────────────────┐
│   AI Client      │ ◄──────────────► │   MCP Server     │
│  (Claude Code,   │                   │  (Node.js,       │
│   Claude.ai,     │                   │   Python,        │
│   Cursor, etc.)  │                   │   Go, etc.)      │
└──────────────────┘                   └──────────────────┘
                                              │
                                              ▼
                                       ┌──────────────────┐
                                       │ External Systems │
                                       │ - GitHub API     │
                                       │ - Slack API      │
                                       │ - Database       │
                                       │ - File System    │
                                       └──────────────────┘
```

### MCP Server Structure

```typescript
// Example MCP Server (TypeScript)
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "quad-tickets",
  version: "1.0.0",
});

// Define tools the server provides
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "create_ticket",
      description: "Create a new ticket in QUAD",
      inputSchema: {
        type: "object",
        properties: {
          title: { type: "string" },
          domain_id: { type: "string" },
          ticket_type: { type: "string", enum: ["USER_STORY", "BUG", "TASK"] },
        },
        required: ["title", "domain_id"],
      },
    },
    {
      name: "get_ticket",
      description: "Get ticket details by ID",
      inputSchema: {
        type: "object",
        properties: {
          ticket_id: { type: "string" },
        },
        required: ["ticket_id"],
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "create_ticket") {
    // Call QUAD API to create ticket
    const ticket = await quadApi.createTicket(args);
    return { content: [{ type: "text", text: JSON.stringify(ticket) }] };
  }

  if (name === "get_ticket") {
    const ticket = await quadApi.getTicket(args.ticket_id);
    return { content: [{ type: "text", text: JSON.stringify(ticket) }] };
  }
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Characteristics

| Aspect | MCP Agent Behavior |
|--------|-------------------|
| **Execution** | Standalone server process |
| **State** | Can maintain persistent state |
| **Memory** | Server-side storage (DB, files, Redis) |
| **Tools** | Custom tools defined via JSON-RPC |
| **AI Provider** | Any MCP-compatible client |
| **Setup** | Requires server deployment |
| **Scope** | Cross-project, reusable |

---

## Side-by-Side Comparison

| Aspect | User Agent (Slash Command) | MCP Agent (Server) |
|--------|---------------------------|-------------------|
| **Definition** | Markdown prompt template | JSON-RPC tool server |
| **Location** | `.claude/commands/*.md` | Standalone process |
| **Execution** | Text expansion in Claude Code | External server |
| **State** | Stateless (reload each time) | Can be stateful |
| **Memory** | Markdown files | Database, Redis, files |
| **Tools** | Claude Code built-in | Custom-defined |
| **AI Providers** | Claude only | Any MCP client |
| **Setup Complexity** | Zero (create .md file) | Medium (deploy server) |
| **Multi-Project** | Per-project | Cross-project |
| **Example** | `/nutrinine-init` | GitHub MCP Server |
| **Best For** | Project workflows | Reusable integrations |

### When User Agent Wins

- **Zero-setup** - Just create a markdown file
- **Project-specific** - Tailored to one codebase
- **Context loading** - Reading project files
- **Workflow orchestration** - Multi-step instructions
- **Rules enforcement** - NEVER/ALWAYS rules

### When MCP Agent Wins

- **Cross-project** - Same tools across repos
- **External APIs** - Slack, GitHub, Jira
- **Custom logic** - Complex business rules
- **State management** - Persistent data
- **Multi-provider** - Works with Claude, GPT, etc.

---

## Architecture Diagrams

### User Agent Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Claude Code                              │
│                                                                  │
│  User types: /nutrinine-init                                     │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────────┐                                             │
│  │ Read .claude/   │                                             │
│  │ commands/       │                                             │
│  │ nutrinine-init  │                                             │
│  │ .md             │                                             │
│  └────────┬────────┘                                             │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────┐     ┌─────────────────┐                     │
│  │ Inject markdown │────►│ Claude follows  │                     │
│  │ into context    │     │ instructions    │                     │
│  └─────────────────┘     └────────┬────────┘                     │
│                                   │                              │
│                                   ▼                              │
│                          ┌─────────────────┐                     │
│                          │ Use built-in    │                     │
│                          │ tools: Bash,    │                     │
│                          │ Read, Write     │                     │
│                          └─────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

### MCP Agent Flow

```
┌─────────────────────┐
│   AI Client         │
│  (Claude Code,      │
│   Claude.ai, etc.)  │
└──────────┬──────────┘
           │
           │ JSON-RPC over stdio/HTTP
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                         MCP Server                               │
│                                                                  │
│  ┌─────────────────┐     ┌─────────────────┐                     │
│  │ tools/list      │     │ tools/call      │                     │
│  │ - create_ticket │     │ - Validate args │                     │
│  │ - get_ticket    │     │ - Execute logic │                     │
│  │ - list_domains  │     │ - Return result │                     │
│  └─────────────────┘     └────────┬────────┘                     │
│                                   │                              │
│                                   ▼                              │
│                          ┌─────────────────┐                     │
│                          │ External APIs   │                     │
│                          │ - QUAD API      │                     │
│                          │ - GitHub API    │                     │
│                          │ - Database      │                     │
│                          └─────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## When to Use Which

### Use User Agent (Slash Command) When:

| Scenario | Example |
|----------|---------|
| Project initialization | `/nutrinine-init` - Load all context files |
| Deployment workflows | `/devstudio` - Deploy to dev environment |
| Code review | `/review-pr` - Review current PR |
| Documentation | `/update-docs` - Update all docs |
| Rules enforcement | `/check-rules` - Verify rule compliance |
| Context refresh | `/refresh` - Reload session history |

### Use MCP Agent When:

| Scenario | Example |
|----------|---------|
| Cross-project tools | QUAD ticket management across all projects |
| External integrations | Slack notifications, GitHub PRs |
| Data operations | Database queries, file storage |
| Custom APIs | Proprietary business logic |
| Shared resources | Credential management, secrets |
| Real-time features | Webhooks, notifications |

---

## QUAD Framework Integration

QUAD can benefit from BOTH paradigms:

### User Agents for QUAD

```
.claude/commands/
├── quad-init.md           # Initialize QUAD context
├── quad-ticket.md         # Create ticket workflow
├── quad-deploy.md         # Deploy to environment
├── quad-review.md         # Code review workflow
└── quad-standup.md        # Daily standup report
```

Example `/quad-ticket.md`:
```markdown
# Create QUAD Ticket

## Context
Read current domain and cycle from project state.

## Steps
1. Ask for ticket type (USER_STORY, BUG, TASK)
2. Ask for title and description
3. Call QUAD API via MCP to create ticket
4. Output ticket URL
```

### MCP Agent for QUAD

**quad-mcp-server** (Reusable tool server):

| Tool | Description |
|------|-------------|
| `quad_create_ticket` | Create ticket via QUAD API |
| `quad_get_ticket` | Get ticket details |
| `quad_list_tickets` | List tickets in cycle |
| `quad_update_status` | Change ticket status |
| `quad_start_sandbox` | Spin up ephemeral sandbox |
| `quad_deploy` | Deploy to environment |

Configuration in Claude Code:
```json
{
  "mcpServers": {
    "quad": {
      "command": "node",
      "args": ["/path/to/quad-mcp-server/index.js"],
      "env": {
        "QUAD_API_URL": "https://api.quadframe.work",
        "QUAD_API_KEY": "${QUAD_API_KEY}"
      }
    }
  }
}
```

### Hybrid Approach (Recommended)

```
User types: /quad-init

  ┌──────────────────────────────────────────────────────────┐
  │ User Agent: quad-init.md                                  │
  │                                                           │
  │ 1. Load project context (markdown files)                  │
  │ 2. Verify MCP connection to quad-server                   │
  │ 3. Call MCP tool: quad_get_current_sprint()              │
  │ 4. Display sprint summary                                 │
  │ 5. Ready for commands                                     │
  └──────────────────────────────────────────────────────────┘
                              │
                              │ Uses MCP for data
                              ▼
  ┌──────────────────────────────────────────────────────────┐
  │ MCP Agent: quad-mcp-server                                │
  │                                                           │
  │ Provides tools:                                           │
  │ - quad_get_current_sprint()                               │
  │ - quad_create_ticket()                                    │
  │ - quad_update_ticket()                                    │
  │ - quad_start_sandbox()                                    │
  └──────────────────────────────────────────────────────────┘
```

---

## Implementation Examples

### Example 1: User Agent - Project Init

**File**: `.claude/commands/quad-init.md`

```markdown
# QUAD Framework Agent Initialization

You are the QUAD Framework AI Agent. Initialize by following these steps:

## STEP 1: Read Context Files

Read these files in order:
1. `CLAUDE.md` - Project architecture
2. `.claudeagent/AGENT_RULES.md` - Non-negotiable rules
3. `documentation/database/DATABASE_ARCHITECTURE.md` - 127 tables

## STEP 2: Verify MCP Connection

Check if quad-mcp-server is available:
```bash
# This will be handled by Claude Code's MCP integration
```

## STEP 3: Greet User

```
QUAD Framework Agent Initialized

Domains: [list from API]
Current Sprint: [from API]
My Tickets: [from API]

Ready to work. What would you like to do?
```

## Rules
- NEVER modify schema without approval
- ALWAYS use graph terminology for dependencies
- ALWAYS update SESSION_HISTORY.md on session end
```

### Example 2: MCP Agent - QUAD Tools

**File**: `quad-mcp-server/index.ts`

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";

const server = new Server({ name: "quad", version: "1.0.0" });

// Tool: Create Ticket
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "quad_create_ticket",
      description: "Create a new ticket in QUAD Framework",
      inputSchema: {
        type: "object",
        properties: {
          title: { type: "string", description: "Ticket title" },
          domain_id: { type: "string", description: "Domain UUID" },
          cycle_id: { type: "string", description: "Sprint/Cycle UUID" },
          ticket_type: {
            type: "string",
            enum: ["USER_STORY", "BUG", "TASK"],
            description: "Type of ticket"
          },
          depends_on: {
            type: "array",
            items: { type: "string" },
            description: "UUIDs of blocking tickets (PRECONDITIONS)"
          },
          story_points: { type: "number", description: "Estimated points" }
        },
        required: ["title", "domain_id", "ticket_type"],
      },
    },
    {
      name: "quad_get_dependency_graph",
      description: "Get ticket dependency graph for a cycle",
      inputSchema: {
        type: "object",
        properties: {
          cycle_id: { type: "string" },
          format: { type: "string", enum: ["json", "mermaid", "dot"] }
        },
        required: ["cycle_id"],
      },
    },
    {
      name: "quad_start_sandbox",
      description: "Start ephemeral sandbox for ticket development",
      inputSchema: {
        type: "object",
        properties: {
          ticket_id: { type: "string" },
          base_branch: { type: "string", default: "main" }
        },
        required: ["ticket_id"],
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "quad_create_ticket":
      return await handleCreateTicket(args);
    case "quad_get_dependency_graph":
      return await handleGetDependencyGraph(args);
    case "quad_start_sandbox":
      return await handleStartSandbox(args);
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function handleCreateTicket(args: any) {
  const response = await fetch(`${QUAD_API_URL}/api/tickets`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${QUAD_API_KEY}`,
    },
    body: JSON.stringify({
      title: args.title,
      domainId: args.domain_id,
      cycleId: args.cycle_id,
      ticketType: args.ticket_type,
      dependsOn: args.depends_on || [],
      storyPoints: args.story_points,
    }),
  });

  const ticket = await response.json();
  return {
    content: [{
      type: "text",
      text: `Ticket created: ${ticket.id}\nTitle: ${ticket.title}\nStatus: ${ticket.status}\nIN-DEGREE: ${args.depends_on?.length || 0} (PRECONDITIONS)`,
    }],
  };
}

async function handleGetDependencyGraph(args: any) {
  const response = await fetch(`${QUAD_API_URL}/api/cycles/${args.cycle_id}/dependency-graph`);
  const graph = await response.json();

  if (args.format === "mermaid") {
    // Convert to Mermaid diagram
    let mermaid = "graph TD\n";
    for (const edge of graph.edges) {
      mermaid += `  ${edge.from}["${graph.nodes[edge.from].title}"] --> ${edge.to}["${graph.nodes[edge.to].title}"]\n`;
    }
    return { content: [{ type: "text", text: mermaid }] };
  }

  return { content: [{ type: "text", text: JSON.stringify(graph, null, 2) }] };
}

async function handleStartSandbox(args: any) {
  const response = await fetch(`${QUAD_API_URL}/api/sandboxes`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${QUAD_API_KEY}`,
    },
    body: JSON.stringify({
      ticketId: args.ticket_id,
      baseBranch: args.base_branch || "main",
    }),
  });

  const sandbox = await response.json();
  return {
    content: [{
      type: "text",
      text: `Sandbox started:\nID: ${sandbox.id}\nURL: ${sandbox.url}\nSSH: ${sandbox.ssh_command}\nExpires: ${sandbox.expires_at}`,
    }],
  };
}
```

---

## Summary

| Need | Use |
|------|-----|
| Project-specific workflow | **User Agent** (`.claude/commands/*.md`) |
| Cross-project tool | **MCP Agent** (server with tools) |
| Context loading | **User Agent** |
| External API integration | **MCP Agent** |
| Stateless instructions | **User Agent** |
| Stateful operations | **MCP Agent** |
| Zero setup | **User Agent** |
| Reusable across clients | **MCP Agent** |

**Recommendation for QUAD**: Use **Hybrid Approach**
- User Agents for project initialization and workflows
- MCP Agent for QUAD API integration and sandbox management
- MCP Agent for cross-cutting tools (Slack, GitHub, etc.)

---

## Related Documentation

- [AGENT_RULES.md](../agents/AGENT_RULES.md) - Generic agent creation rules
- [Claude MCP Documentation](https://docs.anthropic.com/en/docs/agents-and-tools/mcp)
- [NutriNine Agent Example](../../../nutrinine/.claude/commands/nutrinine-init.md)

---

**Last Updated:** January 4, 2026
**Version:** 1.0
