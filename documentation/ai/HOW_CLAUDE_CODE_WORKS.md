# How Claude Code Works Internally

**Version:** 1.0
**Last Updated:** January 4, 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Core Components](#core-components)
4. [Tool System](#tool-system)
5. [Context Management](#context-management)
6. [Agent SDK](#agent-sdk)
7. [MCP Integration](#mcp-integration)
8. [Comparison with Other AI IDEs](#comparison-with-other-ai-ides)
9. [QUAD Implementation Strategy](#quad-implementation-strategy)

---

## Overview

**Claude Code** is Anthropic's official CLI tool for AI-assisted software development. It's designed to be:

- **Agentic**: Can autonomously execute multi-step tasks
- **Tool-based**: Uses structured tool calls instead of free-form code execution
- **Context-aware**: Maintains project context across interactions
- **Safe**: Sandboxed execution with permission controls

### Key Characteristics

| Aspect | Claude Code Approach |
|--------|---------------------|
| **Execution Model** | Tool-based (not code generation + eval) |
| **Context Window** | ~200K tokens with automatic summarization |
| **Memory** | Conversation-based + file-based (CLAUDE.md) |
| **Tools** | ~15 built-in tools (Read, Write, Bash, etc.) |
| **Extensions** | MCP servers for external integrations |
| **IDE Support** | VS Code, JetBrains, Terminal |

---

## Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Claude Code CLI                                │
│                                                                          │
│  User Input: "Fix the bug in auth.ts"                                    │
│       │                                                                  │
│       ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Context Builder                               │    │
│  │  - Load CLAUDE.md (project instructions)                         │    │
│  │  - Load conversation history                                     │    │
│  │  - Load tool definitions                                         │    │
│  │  - Apply system prompts                                          │    │
│  └────────────────────────────┬────────────────────────────────────┘    │
│                               │                                          │
│                               ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Claude API                                    │    │
│  │  - Model: claude-sonnet-4-20250514 (default)                     │    │
│  │  - Streaming response                                            │    │
│  │  - Tool use enabled                                              │    │
│  └────────────────────────────┬────────────────────────────────────┘    │
│                               │                                          │
│                               ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Response Handler                              │    │
│  │  - Parse tool calls                                              │    │
│  │  - Execute tools (with permissions)                              │    │
│  │  - Feed results back to Claude                                   │    │
│  │  - Repeat until task complete                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Agentic Loop

```
while (not_done):
    1. Send context + history to Claude API
    2. Claude responds with text and/or tool calls
    3. For each tool call:
       a. Check permissions (auto-approve or ask user)
       b. Execute tool (Read, Write, Bash, etc.)
       c. Capture result
    4. Append tool results to conversation
    5. If Claude says "done" or no more tool calls → exit
    6. Else → continue loop
```

---

## Core Components

### 1. System Prompt

Claude Code injects a comprehensive system prompt that defines:

```markdown
You are Claude Code, an AI assistant specialized in software development.

## Available Tools
You have access to these tools:
- Read: Read files from the filesystem
- Write: Write files to the filesystem
- Edit: Make targeted edits to files
- Bash: Execute shell commands
- Glob: Find files by pattern
- Grep: Search file contents
- WebFetch: Fetch web content
- WebSearch: Search the web
- Task: Spawn sub-agents
- TodoWrite: Track tasks
- AskUserQuestion: Get user input

## Working Directory
Current directory: /path/to/project

## Project Context
[Contents of CLAUDE.md loaded here]

## Rules
- Never execute destructive commands without permission
- Read files before editing them
- Use appropriate tools for each task
```

### 2. Tool Definitions

Each tool is defined with a JSON Schema:

```json
{
  "name": "Read",
  "description": "Read a file from the filesystem",
  "parameters": {
    "type": "object",
    "properties": {
      "file_path": {
        "type": "string",
        "description": "Absolute path to the file"
      },
      "offset": {
        "type": "number",
        "description": "Line number to start reading"
      },
      "limit": {
        "type": "number",
        "description": "Number of lines to read"
      }
    },
    "required": ["file_path"]
  }
}
```

### 3. Permission System

```
┌──────────────────────────────────────────────────────────────┐
│                   Permission Levels                           │
│                                                               │
│  AUTO-APPROVE:                                                │
│  - Read any file in project                                   │
│  - Glob/Grep searches                                         │
│  - WebSearch (read-only)                                      │
│                                                               │
│  ASK USER:                                                    │
│  - Write/Edit files                                           │
│  - Bash commands (unless in allow-list)                       │
│  - WebFetch (external URLs)                                   │
│                                                               │
│  CONFIGURABLE (via settings):                                 │
│  - Trust all Bash commands                                    │
│  - Trust specific patterns (e.g., "npm test")                 │
│  - Trust in specific directories                              │
└──────────────────────────────────────────────────────────────┘
```

### 4. CLAUDE.md Files

Claude Code loads project-specific instructions from:

```
project-root/
├── CLAUDE.md              # Project-level instructions
├── .claude/
│   ├── settings.json      # Claude Code settings
│   └── commands/          # Custom slash commands
│       └── my-command.md  # /my-command
└── subdirectory/
    └── CLAUDE.md          # Directory-level instructions
```

**Hierarchy (all combined):**
1. Base system prompt (hardcoded)
2. User-level CLAUDE.md (~/.claude/CLAUDE.md)
3. Project-level CLAUDE.md
4. Directory-level CLAUDE.md (if navigating)
5. Slash command content (if invoked)

---

## Tool System

### Built-in Tools (15 core tools)

| Tool | Purpose | Permissions |
|------|---------|-------------|
| **Read** | Read file contents | Auto-approve (project files) |
| **Write** | Create/overwrite files | Ask user |
| **Edit** | Surgical text replacement | Ask user |
| **Bash** | Execute shell commands | Configurable |
| **Glob** | Find files by pattern | Auto-approve |
| **Grep** | Search file contents | Auto-approve |
| **WebFetch** | Fetch URL content | Ask user |
| **WebSearch** | Search the web | Auto-approve |
| **Task** | Spawn sub-agent | Auto-approve |
| **TaskOutput** | Get sub-agent result | Auto-approve |
| **TodoWrite** | Manage task list | Auto-approve |
| **AskUserQuestion** | Interactive prompt | Auto-approve |
| **NotebookEdit** | Edit Jupyter notebooks | Ask user |
| **EnterPlanMode** | Switch to planning mode | Auto-approve |
| **ExitPlanMode** | Exit planning mode | Auto-approve |

### Tool Execution Flow

```
Claude: "I'll read the file to understand the issue"

<tool_call>
  <name>Read</name>
  <parameters>{"file_path": "/project/src/auth.ts"}</parameters>
</tool_call>

→ Claude Code intercepts tool call
→ Checks permission: Read is auto-approved for project files
→ Executes: fs.readFile("/project/src/auth.ts")
→ Returns result to Claude:

<tool_result>
  <content>
    1→export function authenticate(user: string) {
    2→  // BUG: Missing null check
    3→  return user.toLowerCase();
    4→}
  </content>
</tool_result>

Claude: "I see the bug. Let me fix it."

<tool_call>
  <name>Edit</name>
  <parameters>{
    "file_path": "/project/src/auth.ts",
    "old_string": "return user.toLowerCase();",
    "new_string": "return user?.toLowerCase() ?? '';"
  }</parameters>
</tool_call>

→ Claude Code asks user: "Allow edit to auth.ts?"
→ User approves
→ Executes edit
→ Returns success
```

---

## Context Management

### Token Budget

Claude Code manages a ~200K token context window:

```
┌──────────────────────────────────────────────────────────────┐
│                    Context Budget (~200K)                     │
│                                                               │
│  ┌────────────────────────────────────────────┐              │
│  │ System Prompt + CLAUDE.md       ~10K       │              │
│  ├────────────────────────────────────────────┤              │
│  │ Tool Definitions                ~5K        │              │
│  ├────────────────────────────────────────────┤              │
│  │ Conversation History            ~50K       │              │
│  │ (auto-summarized when full)               │              │
│  ├────────────────────────────────────────────┤              │
│  │ Current Turn                    ~135K      │              │
│  │ (file contents, tool results)             │              │
│  └────────────────────────────────────────────┘              │
│                                                               │
│  When context exceeds limit:                                  │
│  1. Summarize old conversation turns                          │
│  2. Keep recent turns verbatim                                │
│  3. Continue with summarized context                          │
└──────────────────────────────────────────────────────────────┘
```

### Automatic Summarization

When context gets full:

```
OLD APPROACH (before summarization):
Turn 1: Full content
Turn 2: Full content
Turn 3: Full content
...
Turn 50: Full content → Context full!

NEW APPROACH (after summarization):
Summary: "Turns 1-40 covered: fixed auth bug, added tests,
         deployed to staging"
Turn 41: Full content
Turn 42: Full content
...
Turn 50: Full content → Fits!
```

---

## Agent SDK

Claude Code can spawn sub-agents via the **Task** tool:

### Sub-Agent Types

| Type | Purpose | Tools Available |
|------|---------|-----------------|
| `general-purpose` | Complex multi-step tasks | All tools |
| `Explore` | Codebase exploration | Glob, Grep, Read |
| `Plan` | Architecture planning | All tools |
| `claude-code-guide` | Documentation lookup | Read, WebFetch |

### Spawning Sub-Agents

```javascript
// Claude decides to spawn an exploration agent
<tool_call>
  <name>Task</name>
  <parameters>{
    "subagent_type": "Explore",
    "prompt": "Find all files that handle authentication",
    "description": "Explore auth files"
  }</parameters>
</tool_call>
```

### Sub-Agent Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Main Agent                                │
│                                                              │
│  Processing: "Refactor the authentication system"            │
│       │                                                      │
│       │ Spawns                                               │
│       ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Sub-Agent: Explore                                   │    │
│  │ Task: "Find all auth-related files"                  │    │
│  │                                                      │    │
│  │ Tools: Glob, Grep, Read                              │    │
│  │ Returns: List of files with auth logic               │    │
│  └──────────────────────────────────────────────────────┘    │
│       │                                                      │
│       │ Results                                              │
│       ▼                                                      │
│  Main Agent continues with sub-agent results                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## MCP Integration

### What is MCP?

**Model Context Protocol (MCP)** is a standard for connecting AI assistants to external tools via JSON-RPC.

### Claude Code + MCP

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│   MCP Client    │────▶│   MCP Server    │
│                 │     │   (built-in)    │     │   (external)    │
│  - Agentic loop │     │                 │     │                 │
│  - Tool calls   │     │  - stdio        │     │  - GitHub API   │
│  - Context      │     │  - HTTP/SSE     │     │  - Slack API    │
└─────────────────┘     └─────────────────┘     │  - Database     │
                                                 │  - QUAD API     │
                                                 └─────────────────┘
```

### MCP Configuration

In `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
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

### MCP Tool Discovery

```
Claude Code starts
    │
    ├─▶ Start MCP servers from config
    │
    ├─▶ Call tools/list on each server
    │
    ├─▶ Merge MCP tools with built-in tools
    │
    └─▶ Include all tools in system prompt

Tool list now includes:
- Read (built-in)
- Write (built-in)
- github_create_pr (MCP)
- quad_create_ticket (MCP)
- ...
```

---

## Comparison with Other AI IDEs

### Claude Code vs Cursor vs Copilot

| Feature | Claude Code | Cursor | GitHub Copilot |
|---------|-------------|--------|----------------|
| **Architecture** | Tool-based agent | Code generation | Code completion |
| **Execution** | Can run code | Can run code | Read-only |
| **Context** | ~200K tokens | ~32K tokens | ~8K tokens |
| **Memory** | CLAUDE.md + history | .cursorrules | Limited |
| **Extensions** | MCP servers | Plugins | Extensions |
| **Multi-step** | Yes (agentic loop) | Limited | No |
| **IDE** | VS Code, Terminal | Cursor IDE | VS Code, JetBrains |

### Architecture Comparison

**Claude Code (Agentic)**:
```
User Request → Claude → Tool Calls → Execute → Results → Claude → Done
                 ↑                                          │
                 └──────────── Loop until complete ─────────┘
```

**Cursor (Hybrid)**:
```
User Request → Generate Code → User Accepts → Apply
                   ↓
            Run in terminal (optional)
```

**Copilot (Completion)**:
```
User Types → Suggest Completion → User Accepts → Insert
```

---

## QUAD Implementation Strategy

### How QUAD Should Implement Similar Functionality

#### 1. Web-Based Agent Runtime

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         QUAD Browser IDE                                 │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    Agent Controller (JavaScript)                    │ │
│  │                                                                     │ │
│  │  while (!done) {                                                    │ │
│  │    const response = await callQuadAPI(context, history);           │ │
│  │    for (const toolCall of response.toolCalls) {                    │ │
│  │      const result = await executeToolInSandbox(toolCall);          │ │
│  │      history.push({ tool: toolCall.name, result });                │ │
│  │    }                                                                │ │
│  │    if (response.done) break;                                        │ │
│  │  }                                                                  │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                               │                                          │
│                               ▼                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    Tool Execution Layer                             │ │
│  │                                                                     │ │
│  │  - Monaco Editor (Read/Write/Edit)                                  │ │
│  │  - Terminal (xterm.js + WebSocket to sandbox)                       │ │
│  │  - File Explorer (virtual filesystem)                               │ │
│  │  - QUAD API (tickets, sandbox, deployment)                          │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 2. Tool Definitions for QUAD

```typescript
// QUAD Tool Definitions
const QUAD_TOOLS = [
  // File Operations (via sandbox)
  {
    name: "quad_read_file",
    description: "Read a file from the sandbox workspace",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        offset: { type: "number" },
        limit: { type: "number" }
      },
      required: ["path"]
    }
  },

  // Ticket Operations (via QUAD API)
  {
    name: "quad_get_ticket",
    description: "Get ticket details",
    inputSchema: {
      type: "object",
      properties: {
        ticket_id: { type: "string" }
      },
      required: ["ticket_id"]
    }
  },

  // Build Operations (via sandbox)
  {
    name: "quad_run_build",
    description: "Run build command in sandbox",
    inputSchema: {
      type: "object",
      properties: {
        command: { type: "string" },
        timeout_ms: { type: "number" }
      },
      required: ["command"]
    }
  },

  // Deployment (via QUAD infrastructure)
  {
    name: "quad_deploy",
    description: "Deploy to environment",
    inputSchema: {
      type: "object",
      properties: {
        environment: { type: "string", enum: ["dev", "staging", "prod"] },
        sandbox_id: { type: "string" }
      },
      required: ["environment", "sandbox_id"]
    }
  }
];
```

#### 3. Context Management for QUAD

```typescript
interface QuadAgentContext {
  // Project context
  project: {
    domain_id: string;
    repository_url: string;
    branch: string;
    tech_stack: string[];
  };

  // Ticket context
  ticket: {
    id: string;
    title: string;
    type: "USER_STORY" | "BUG" | "TASK";
    preconditions: string[];  // IN-DEGREE tickets
    dependents: string[];     // OUT-DEGREE tickets
    acceptance_criteria: string[];
  };

  // Sandbox context
  sandbox: {
    id: string;
    url: string;
    workspace_path: string;
    build_status: string;
  };

  // Agent rules (from templates)
  rules: {
    mandatory: string[];  // From org level
    optional: string[];   // From domain level
    circle_specific: string[];  // From circle template
  };

  // Conversation history
  history: {
    turns: Turn[];
    summary?: string;  // When context gets large
  };
}
```

#### 4. AI Provider Abstraction

```typescript
// Support multiple AI providers
interface AIProvider {
  name: string;
  chat(context: QuadAgentContext, tools: Tool[]): Promise<AIResponse>;
}

class ClaudeProvider implements AIProvider {
  name = "claude";
  async chat(context, tools) {
    return await anthropic.messages.create({
      model: "claude-sonnet-4-20250514",
      messages: formatMessages(context.history),
      tools: tools,
      system: buildSystemPrompt(context)
    });
  }
}

class GeminiProvider implements AIProvider {
  name = "gemini";
  async chat(context, tools) {
    // Gemini doesn't support MCP natively
    // Use REST tool definitions instead
    return await gemini.generateContent({
      model: "gemini-2.0-flash",
      contents: formatContents(context.history),
      tools: convertToGeminiTools(tools)
    });
  }
}
```

---

## Summary

### Key Takeaways for QUAD

1. **Tool-based architecture** - Define tools with JSON Schema, execute via API
2. **Agentic loop** - Keep calling AI until task is complete
3. **Context management** - Summarize old turns when context gets large
4. **Permission system** - Control what actions require approval
5. **MCP for extensions** - Standard protocol for external integrations
6. **Provider abstraction** - Support Claude, Gemini, OpenAI with same tool interface

### QUAD-Specific Adaptations

| Claude Code Feature | QUAD Equivalent |
|---------------------|-----------------|
| CLAUDE.md | Agent templates in DB |
| Built-in tools | Sandbox tools via WebSocket |
| MCP servers | QUAD MCP + REST API |
| File system | Sandbox filesystem |
| Terminal | xterm.js + sandbox |
| Permission system | Org/Domain rules |

---

## Related Documentation

- [MCP_AGENT_VS_USER_AGENTS.md](MCP_AGENT_VS_USER_AGENTS.md) - MCP vs User Agent comparison
- [AGENT_RULES.md](../agents/AGENT_RULES.md) - QUAD agent creation rules
- [SANDBOX_ARCHITECTURE.md](../architecture/SANDBOX_ARCHITECTURE.md) - Sandbox design
- [Claude Documentation](https://docs.anthropic.com/en/docs/agents-and-tools)

---

**Author:** QUAD Framework Team
**Version:** 1.0
