# How IDE AI Tools Work - Competitive Analysis

**Version:** 1.0
**Last Updated:** January 4, 2026
**Purpose:** Understand competitor architecture to inform QUAD's browser IDE implementation

---

## Table of Contents

1. [Overview](#overview)
2. [GitHub Copilot](#github-copilot)
3. [Cursor](#cursor)
4. [Cody (Sourcegraph)](#cody-sourcegraph)
5. [Tabnine](#tabnine)
6. [Amazon Q Developer](#amazon-q-developer)
7. [Architecture Comparison](#architecture-comparison)
8. [QUAD Implementation Strategy](#quad-implementation-strategy)

---

## Overview

Modern IDE AI tools fall into three categories:

| Category | Examples | How It Works |
|----------|----------|--------------|
| **Completion-Based** | Copilot, Tabnine | Suggest code as you type |
| **Chat-Based** | Cursor, Cody | Conversational AI for code |
| **Agentic** | Claude Code, Devin | Autonomous multi-step execution |

---

## GitHub Copilot

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         GitHub Copilot                                   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    VS Code Extension                             │    │
│  │                                                                  │    │
│  │  1. Capture cursor context (current file, imports, comments)     │    │
│  │  2. Send to Copilot API with surrounding code                    │    │
│  │  3. Receive completions                                          │    │
│  │  4. Display ghost text suggestions                               │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Copilot Backend (Azure)                       │    │
│  │                                                                  │    │
│  │  - OpenAI Codex model (fine-tuned GPT)                          │    │
│  │  - Token context: ~4K-8K tokens                                  │    │
│  │  - Response time: 100-500ms                                      │    │
│  │  - No persistent memory across sessions                          │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### How Context is Built

```typescript
// Copilot context construction (simplified)
function buildContext(cursor: Position, document: TextDocument): string {
  // 1. Get current file content (up to cursor)
  const prefix = document.getText(new Range(0, 0, cursor.line, cursor.character));

  // 2. Get suffix (after cursor)
  const suffix = document.getText(new Range(cursor.line, cursor.character, Infinity, 0));

  // 3. Get related files from imports
  const imports = extractImports(document);
  const relatedFiles = imports.slice(0, 3).map(f => readFile(f));

  // 4. Get recent clipboard content (optional)
  const clipboard = getRecentClipboard();

  // 5. Build prompt
  return `
    // File: ${document.fileName}
    ${prefix}
    <cursor>
    ${suffix}

    // Related files:
    ${relatedFiles.join('\n')}
  `;
}
```

### Key Features

| Feature | How It Works |
|---------|--------------|
| **Ghost Text** | AI suggestions appear faded, Tab to accept |
| **Multi-line** | Can suggest entire functions |
| **Language Detection** | Infers language from file extension |
| **Comment-to-Code** | Natural language comments trigger suggestions |
| **Copilot Chat** | Separate chat panel for Q&A |

### Strengths & Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Fast response time | Limited context window |
| Seamless UX (ghost text) | No codebase understanding |
| Works in all major IDEs | Can't execute code |
| Good for boilerplate | Sometimes wrong suggestions |

---

## Cursor

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                             Cursor IDE                                   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Electron-Based IDE                            │    │
│  │                    (Fork of VS Code)                             │    │
│  │                                                                  │    │
│  │  Features:                                                       │    │
│  │  - Composer (multi-file generation)                              │    │
│  │  - Chat panel                                                    │    │
│  │  - Inline editing (Cmd+K)                                        │    │
│  │  - Codebase indexing                                             │    │
│  │  - .cursorrules file                                             │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Cursor Backend                                │    │
│  │                                                                  │    │
│  │  - Claude or GPT-4 (user choice)                                 │    │
│  │  - Embeddings for codebase search                                │    │
│  │  - Long context (32K-128K)                                       │    │
│  │  - Apply model for file changes                                  │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Codebase Index                                │    │
│  │                                                                  │    │
│  │  - File embeddings (semantic search)                             │    │
│  │  - Symbol table (functions, classes)                             │    │
│  │  - Import graph (dependencies)                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### How Codebase Indexing Works

```python
# Cursor indexing (conceptual)

def index_codebase(repo_path):
    index = {}

    for file_path in walk_files(repo_path):
        # 1. Parse AST
        ast = parse(file_path)

        # 2. Extract symbols
        symbols = extract_symbols(ast)  # functions, classes, variables

        # 3. Generate embeddings
        content = read_file(file_path)
        embedding = embed(content)  # Vector for semantic search

        # 4. Store
        index[file_path] = {
            "symbols": symbols,
            "embedding": embedding,
            "imports": extract_imports(ast),
            "exports": extract_exports(ast)
        }

    return index

def search_codebase(query, index):
    # Semantic search using embeddings
    query_embedding = embed(query)

    results = []
    for path, data in index.items():
        similarity = cosine_similarity(query_embedding, data["embedding"])
        if similarity > 0.7:
            results.append((path, similarity))

    return sorted(results, key=lambda x: -x[1])
```

### .cursorrules File

```markdown
# .cursorrules

## Project Context
This is a TypeScript/React project using Next.js 14.

## Code Style
- Use functional components
- Prefer hooks over class components
- Use TypeScript strict mode

## File Structure
- Components in /src/components
- Pages in /src/app (App Router)
- API routes in /src/app/api

## Rules
- Always use async/await, never .then()
- Use Tailwind CSS for styling
- Write tests for all new components
```

### Key Features

| Feature | How It Works |
|---------|--------------|
| **Composer** | Generate/edit multiple files at once |
| **Cmd+K** | Inline code generation at cursor |
| **@codebase** | Reference entire codebase in chat |
| **@docs** | Reference external documentation |
| **Apply** | Apply AI suggestions to files |

---

## Cody (Sourcegraph)

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              Cody                                        │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    VS Code Extension                             │    │
│  │                                                                  │    │
│  │  - Chat sidebar                                                  │    │
│  │  - Autocomplete                                                  │    │
│  │  - Commands (/explain, /test, /doc)                              │    │
│  │  - Context fetching                                              │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Sourcegraph Backend                           │    │
│  │                                                                  │    │
│  │  - Code graph (cross-repo references)                            │    │
│  │  - Precise code intel (SCIP)                                     │    │
│  │  - Multi-repo search                                             │    │
│  │  - Embeddings index                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  Unique: Cross-repository code intelligence                              │
│  - "Find all usages across all repos"                                    │
│  - "What other services call this API?"                                  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Differentiator: Cross-Repo Intelligence

```
Copilot:    "What does this function do?"  → Looks at current file
Cursor:     "What does this function do?"  → Looks at current repo
Cody:       "What does this function do?"  → Looks at ALL repos in org

Example:
  User: "Who calls the createUser API?"

  Cody searches across:
  - api-gateway (calls createUser 5 times)
  - user-service (defines createUser)
  - admin-dashboard (calls createUser 3 times)
  - mobile-app (calls createUser via SDK)
```

---

## Tabnine

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                             Tabnine                                      │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Local AI Model                                │    │
│  │                                                                  │    │
│  │  - Small model runs on-device (1-3B params)                      │    │
│  │  - No code leaves the machine                                    │    │
│  │  - Fast completions (50-100ms)                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                               │                                          │
│                               ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Cloud AI (Optional)                           │    │
│  │                                                                  │    │
│  │  - Larger model for complex tasks                                │    │
│  │  - Enterprise: Fine-tuned on company code                        │    │
│  │  - SOC 2 compliant                                               │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  Key Selling Point: Privacy + Enterprise Security                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Enterprise Fine-Tuning

```
Standard Tabnine:
  - Generic code model
  - Good for common patterns

Enterprise Tabnine:
  - Fine-tuned on YOUR codebase
  - Learns your naming conventions
  - Suggests YOUR patterns
  - Knows YOUR APIs

Example:
  Standard:  user.get_name()
  Enterprise: user.fetchUserDisplayName()  ← Matches your code style
```

---

## Amazon Q Developer

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Amazon Q Developer                                │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    IDE Extensions                                │    │
│  │                    (VS Code, JetBrains)                          │    │
│  │                                                                  │    │
│  │  - Code completions                                              │    │
│  │  - Security scanning                                             │    │
│  │  - AWS integration                                               │    │
│  │  - Feature development (/dev)                                    │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Amazon Bedrock                                │    │
│  │                                                                  │    │
│  │  - Claude for code generation                                    │    │
│  │  - Titan for embeddings                                          │    │
│  │  - AWS service integration                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  Unique Features:                                                        │
│  - /dev: Multi-file feature development                                  │
│  - /transform: Java 8 → Java 17 migration                                │
│  - AWS Console integration                                               │
│  - Security vulnerability scanning                                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Feature Development (/dev)

```
User types: /dev Add user authentication with Cognito

Amazon Q:
1. Analyzes codebase structure
2. Generates plan:
   - Create auth.ts
   - Update app.ts
   - Add Cognito config
   - Create login component
3. Creates files with code
4. User reviews and accepts
```

---

## Architecture Comparison

### Context Strategies

| Tool | Context Window | Context Strategy |
|------|----------------|------------------|
| **Copilot** | 4-8K tokens | Current file + imports |
| **Cursor** | 32-128K tokens | Semantic search + embeddings |
| **Cody** | 32K tokens | Cross-repo search |
| **Tabnine** | 1-2K tokens | Local context only |
| **Amazon Q** | 32K tokens | AWS service context |
| **Claude Code** | 200K tokens | Full project + summarization |

### Feature Matrix

| Feature | Copilot | Cursor | Cody | Tabnine | Amazon Q | Claude Code |
|---------|---------|--------|------|---------|----------|-------------|
| Autocomplete | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Chat | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Multi-file edit | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ |
| Codebase search | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Execute code | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Local/private | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| Custom rules | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Cross-repo | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |

### Execution Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    EXECUTION MODEL SPECTRUM                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  READ-ONLY                                              FULL EXECUTION   │
│  (Suggestions)                                          (Agentic)        │
│                                                                          │
│  Copilot ─────── Cursor ─────── Amazon Q ─────── Claude Code            │
│     │               │               │                   │                │
│     ▼               ▼               ▼                   ▼                │
│  Ghost text    Chat + Apply    Multi-file         Tool calls             │
│  Tab accept    User applies    User reviews       Auto-execute           │
│                                                                          │
│  Risk: Low          Medium          Medium           High                │
│  Power: Low         Medium          Medium-High      High                │
│  Control: User      User            User             Permissions         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## QUAD Implementation Strategy

### What QUAD Should Implement

Based on this analysis, QUAD's browser IDE should combine the best features:

| Feature | Source Inspiration | QUAD Implementation |
|---------|-------------------|---------------------|
| **Codebase Indexing** | Cursor | Index on GitHub push, store in DB |
| **Semantic Search** | Cody | Embeddings for file search |
| **Cross-Repo** | Cody | Search across all org repos |
| **Custom Rules** | Cursor (.cursorrules) | Agent templates in database |
| **Multi-File Edit** | Cursor Composer | Sandbox with diff preview |
| **Execution** | Claude Code | Tool-based, sandbox-isolated |
| **Security Scan** | Amazon Q | Integrate with SAST tools |

### QUAD's Unique Advantages

| Advantage | Description |
|-----------|-------------|
| **Ticket Context** | AI knows the ticket, acceptance criteria, dependencies |
| **Team Memory** | Org/domain/project context hierarchy |
| **CI/CD Integration** | Build, test, deploy from IDE |
| **Meeting Context** | Meeting notes linked to tickets |
| **Sandbox Isolation** | Safe execution environment |

### Architecture Recommendation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD Browser IDE Architecture                         │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Browser (Monaco Editor)                       │    │
│  │                                                                  │    │
│  │  - File explorer (virtual filesystem)                            │    │
│  │  - Code editor (Monaco)                                          │    │
│  │  - Terminal (xterm.js → sandbox)                                 │    │
│  │  - Chat panel (AI assistant)                                     │    │
│  │  - Ticket panel (current work)                                   │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │ WebSocket                                  │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    QUAD API (Cloud Run)                          │    │
│  │                                                                  │    │
│  │  - Context service (memory, tickets)                             │    │
│  │  - AI router (Claude, Gemini, OpenAI)                           │    │
│  │  - Sandbox manager                                               │    │
│  │  - Codebase index                                                │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│              ┌──────────────┴──────────────┐                            │
│              ▼                             ▼                            │
│  ┌─────────────────────┐       ┌─────────────────────┐                  │
│  │   AI Providers      │       │   Sandbox Pool      │                  │
│  │                     │       │                     │                  │
│  │  - Claude (MCP)     │       │  - Git clone        │                  │
│  │  - Gemini (REST)    │       │  - Build/Test       │                  │
│  │  - OpenAI (REST)    │       │  - Terminal access  │                  │
│  └─────────────────────┘       │  - Deploy           │                  │
│                                └─────────────────────┘                  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Implementation Phases

| Phase | Features | Priority |
|-------|----------|----------|
| **Phase 1** | Monaco editor + Terminal + Chat | MVP |
| **Phase 2** | Codebase indexing + Semantic search | High |
| **Phase 3** | Multi-file edit + Apply changes | High |
| **Phase 4** | Cross-repo search | Medium |
| **Phase 5** | Security scanning | Medium |

---

## Related Documentation

- [HOW_CLAUDE_CODE_WORKS.md](HOW_CLAUDE_CODE_WORKS.md) - Claude Code architecture
- [MCP_AGENT_VS_USER_AGENTS.md](../agents/MCP_AGENT_VS_USER_AGENTS.md) - Agent comparison
- [SANDBOX_ARCHITECTURE.md](../architecture/SANDBOX_ARCHITECTURE.md) - Sandbox design

---

**Author:** QUAD Framework Team
**Version:** 1.0
