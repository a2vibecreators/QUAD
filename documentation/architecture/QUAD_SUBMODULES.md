# QUAD Framework - Submodules Architecture

**Last Updated:** January 3, 2026
**Status:** Planning

---

## Table of Contents

1. [Current State](#1-current-state)
2. [Proposed Structure](#2-proposed-structure)
3. [Submodule Breakdown](#3-submodule-breakdown)
4. [Migration Plan](#4-migration-plan)
5. [Services Project](#5-services-project)
6. [Benefits](#6-benefits)

---

## 1. Current State

### Current Monorepo Structure

```
quadframework/                    # Single Next.js repo
├── prisma/                       # Database schema
│   ├── schema.prisma
│   └── sql/                      # Modular SQL files
├── src/
│   ├── app/                      # Next.js pages + API routes
│   │   ├── api/                  # REST API endpoints
│   │   └── (pages)/              # Web app pages
│   ├── components/               # React components
│   └── lib/                      # Shared libraries
│       ├── services/             # Business logic
│       └── db.ts                 # Database connection
├── documentation/                # All documentation
└── quad-vscode-plugin/           # VS Code extension (excluded from build)
```

### Problems with Current Structure

| Problem | Impact |
|---------|--------|
| Everything coupled | Can't deploy API without web app |
| Large builds | Changes to docs trigger full rebuild |
| VS Code plugin in wrong place | Needs separate repo |
| No reusable services | API and VS Code duplicate logic |
| Hard to scale team | Everyone works in same repo |

---

## 2. Proposed Structure

### New Multi-Repo with Submodules

```
a2vibecreators/                   # GitHub Organization
│
├── quadframework/                # Parent repo (orchestrator)
│   ├── .gitmodules               # Submodule definitions
│   ├── quadframework-database/   # ← Submodule
│   ├── quadframework-services/   # ← Submodule (NEW)
│   ├── quadframework-web/        # ← Submodule
│   ├── quadframework-vscode/     # ← Submodule
│   ├── documentation/            # Keep in parent (shared)
│   └── scripts/                  # Deploy scripts
│
├── quadframework-database/       # Standalone repo
│   ├── prisma/
│   │   ├── schema.prisma
│   │   ├── migrations/
│   │   └── sql/
│   └── package.json
│
├── quadframework-services/       # Standalone repo (NEW)
│   ├── src/
│   │   ├── services/             # Core business logic
│   │   ├── ai/                   # AI routing, providers
│   │   ├── memory/               # Memory system
│   │   └── index.ts              # Exports
│   └── package.json
│
├── quadframework-web/            # Standalone repo
│   ├── src/
│   │   ├── app/                  # Next.js pages + API
│   │   └── components/
│   └── package.json              # Depends on services
│
└── quadframework-vscode/         # Standalone repo
    ├── src/
    │   └── extension.ts
    └── package.json              # Depends on services
```

---

## 3. Submodule Breakdown

### quadframework-database

**Purpose:** Database schema and migrations only

```
quadframework-database/
├── prisma/
│   ├── schema.prisma             # Full schema
│   ├── migrations/               # Migration history
│   └── sql/
│       ├── tables/               # Modular table definitions
│       ├── functions/            # PostgreSQL functions
│       ├── triggers/             # Triggers
│       └── views/                # Database views
├── scripts/
│   ├── db-push.sh                # Push schema to database
│   ├── db-seed.sh                # Seed data
│   └── db-reset.sh               # Reset database
├── package.json
└── README.md
```

**Dependencies:** None (standalone)

**Consumers:**
- quadframework-web (imports Prisma client)
- quadframework-services (imports Prisma client)

---

### quadframework-services (NEW)

**Purpose:** Reusable business logic for web app AND VS Code extension

```
quadframework-services/
├── src/
│   ├── index.ts                  # Main exports
│   │
│   ├── ai/                       # AI Provider Layer
│   │   ├── router.ts             # Intelligent routing
│   │   ├── providers/
│   │   │   ├── claude.ts
│   │   │   ├── gemini.ts
│   │   │   ├── groq.ts
│   │   │   └── deepseek.ts
│   │   ├── classifier.ts         # Hybrid classification
│   │   └── types.ts
│   │
│   ├── memory/                   # Memory System
│   │   ├── memory-service.ts     # Hierarchical memory
│   │   ├── chunk-service.ts      # Document chunking
│   │   ├── keyword-service.ts    # Keyword extraction
│   │   └── types.ts
│   │
│   ├── codebase/                 # Codebase Indexing
│   │   ├── indexer.ts            # Code indexer
│   │   ├── parser.ts             # tree-sitter parsing
│   │   └── types.ts
│   │
│   ├── documentation/            # Doc Generation
│   │   ├── generator.ts          # AI doc generation
│   │   ├── templates/            # Doc templates
│   │   └── types.ts
│   │
│   ├── tickets/                  # Ticket Operations
│   │   ├── ticket-service.ts
│   │   ├── sprint-service.ts
│   │   └── types.ts
│   │
│   ├── agents/                   # Agent System
│   │   ├── base-agent.ts
│   │   ├── dev-agent.ts
│   │   ├── review-agent.ts
│   │   ├── ba-agent.ts
│   │   └── types.ts
│   │
│   └── utils/                    # Shared utilities
│       ├── token-counter.ts
│       └── cost-calculator.ts
│
├── package.json
├── tsconfig.json
└── README.md
```

**Dependencies:**
- `@prisma/client` (from quadframework-database)
- `@anthropic-ai/sdk`
- `@google/generative-ai`
- `groq-sdk`

**Consumers:**
- quadframework-web (API routes use services)
- quadframework-vscode (Extension uses services)

**Key Insight:** This is the "glue" that both web and VS Code share!

---

### quadframework-web

**Purpose:** Next.js web application (pages + API)

```
quadframework-web/
├── src/
│   ├── app/
│   │   ├── api/                  # REST API (thin layer)
│   │   │   ├── ai/               # AI endpoints
│   │   │   ├── memory/           # Memory endpoints
│   │   │   ├── tickets/          # Ticket endpoints
│   │   │   └── ...
│   │   ├── (pages)/              # Web pages
│   │   │   ├── dashboard/
│   │   │   ├── configure/
│   │   │   └── ...
│   │   └── layout.tsx
│   │
│   ├── components/               # React components
│   │   ├── ui/
│   │   └── ...
│   │
│   └── lib/
│       ├── auth.ts               # NextAuth
│       └── db.ts                 # Prisma client
│
├── package.json                  # Depends on services
├── next.config.ts
└── README.md
```

**Dependencies:**
- `quadframework-services` (npm link or workspace)
- `quadframework-database` (Prisma client)
- `next`, `react`, etc.

**API Routes Pattern:**
```typescript
// src/app/api/ai/route.ts
import { AIRouter } from 'quadframework-services';

export async function POST(request: NextRequest) {
  const { prompt, task_type } = await request.json();

  // Use shared service
  const response = await AIRouter.route({
    prompt,
    taskType: task_type,
    orgId: session.orgId,
  });

  return NextResponse.json(response);
}
```

---

### quadframework-vscode

**Purpose:** VS Code extension

```
quadframework-vscode/
├── src/
│   ├── extension.ts              # Entry point
│   │
│   ├── commands/                 # VS Code commands
│   │   ├── generate-docs.ts
│   │   ├── explain-code.ts
│   │   └── chat.ts
│   │
│   ├── providers/                # VS Code providers
│   │   ├── completion.ts
│   │   └── hover.ts
│   │
│   ├── views/                    # Webview panels
│   │   ├── chat-panel.ts
│   │   └── ticket-panel.ts
│   │
│   └── services/                 # Service wrappers
│       └── quad-client.ts        # Wraps quadframework-services
│
├── package.json
├── tsconfig.json
└── README.md
```

**Dependencies:**
- `quadframework-services` (bundled)
- `vscode` (VS Code API)

**Service Usage:**
```typescript
// src/services/quad-client.ts
import { DocumentationService, AIRouter } from 'quadframework-services';

export class QuadClient {
  async generateDocs(code: string, language: string) {
    return DocumentationService.generate({
      code,
      language,
      // Uses user's Gemini key (BYOK)
      apiKey: this.config.geminiKey,
    });
  }
}
```

---

## 4. Migration Plan

### Phase 1: Extract Database (1 day)

```bash
# 1. Create new repo
gh repo create a2vibecreators/quadframework-database --public

# 2. Copy prisma folder
cp -r quadframework/prisma quadframework-database/

# 3. Add as submodule to parent
cd quadframework
git submodule add git@github.com:a2vibecreators/quadframework-database.git
```

### Phase 2: Create Services Package (2 days)

```bash
# 1. Create new repo
gh repo create a2vibecreators/quadframework-services --public

# 2. Move service files from lib/services/
# 3. Set up npm package
# 4. Add as submodule
```

### Phase 3: Update Web App (1 day)

```bash
# 1. Create new repo
gh repo create a2vibecreators/quadframework-web --public

# 2. Move remaining Next.js code
# 3. Update imports to use services package
# 4. Add as submodule
```

### Phase 4: Move VS Code Plugin (1 day)

```bash
# 1. Create new repo
gh repo create a2vibecreators/quadframework-vscode --public

# 2. Move quad-vscode-plugin contents
# 3. Update to use services package
# 4. Add as submodule
```

---

## 5. Services Project - Key Design

### Why a Separate Services Package?

```
WITHOUT services package:
  ┌─────────────────┐     ┌─────────────────┐
  │   Web App       │     │   VS Code       │
  │                 │     │                 │
  │  ┌───────────┐  │     │  ┌───────────┐  │
  │  │ AI Logic  │  │     │  │ AI Logic  │  │  ← DUPLICATE!
  │  │ Memory    │  │     │  │ Memory    │  │  ← DUPLICATE!
  │  │ Indexing  │  │     │  │ Indexing  │  │  ← DUPLICATE!
  │  └───────────┘  │     │  └───────────┘  │
  └─────────────────┘     └─────────────────┘

WITH services package:
  ┌─────────────────┐     ┌─────────────────┐
  │   Web App       │     │   VS Code       │
  │                 │     │                 │
  │  Uses services  │     │  Uses services  │
  └────────┬────────┘     └────────┬────────┘
           │                       │
           └───────────┬───────────┘
                       │
              ┌────────▼────────┐
              │ QUAD Services   │
              │                 │
              │  • AI Router    │
              │  • Memory       │
              │  • Indexing     │
              │  • Agents       │
              └─────────────────┘
```

### Services Package API

```typescript
// quadframework-services/src/index.ts

// AI
export { AIRouter } from './ai/router';
export { ClaudeProvider, GeminiProvider, GroqProvider } from './ai/providers';
export { HybridClassifier } from './ai/classifier';

// Memory
export { MemoryService } from './memory/memory-service';
export { ChunkService } from './memory/chunk-service';

// Codebase
export { CodebaseIndexer } from './codebase/indexer';
export { TreeSitterParser } from './codebase/parser';

// Documentation
export { DocumentationService } from './documentation/generator';

// Tickets
export { TicketService } from './tickets/ticket-service';
export { SprintService } from './tickets/sprint-service';

// Agents
export { DevAgent, ReviewAgent, BAAgent, QAAgent } from './agents';

// Types
export * from './types';
```

### Usage in Web App

```typescript
// quadframework-web/src/app/api/memory/route.ts
import { MemoryService } from 'quadframework-services';
import { prisma } from '@/lib/db';

export async function POST(request: NextRequest) {
  const memoryService = new MemoryService(prisma);
  const result = await memoryService.retrieve({
    orgId: session.orgId,
    level: 'project',
    keywords: ['authentication'],
  });
  return NextResponse.json(result);
}
```

### Usage in VS Code Extension

```typescript
// quadframework-vscode/src/commands/generate-docs.ts
import { DocumentationService } from 'quadframework-services';
import * as vscode from 'vscode';

export async function generateDocs() {
  const editor = vscode.window.activeTextEditor;
  const code = editor?.document.getText(editor.selection);

  const docs = await DocumentationService.generate({
    code,
    language: editor?.document.languageId,
    apiKey: getConfig('geminiKey'), // User's BYOK key
  });

  // Insert docs above selection
  editor?.edit(builder => {
    builder.insert(editor.selection.start, docs + '\n');
  });
}
```

---

## 6. Benefits

### For Development

| Benefit | Description |
|---------|-------------|
| **Faster builds** | Only rebuild what changed |
| **Clear ownership** | Database team, services team, UI team |
| **Parallel work** | Teams work on different repos |
| **Smaller PRs** | Changes scoped to one area |
| **Reusable logic** | Write once, use in web + VS Code |

### For Deployment

| Benefit | Description |
|---------|-------------|
| **Independent deploys** | Update API without touching web |
| **Version control** | Pin submodule versions |
| **Rollback** | Rollback one component |
| **Scaling** | Scale services independently |

### For VS Code Extension

| Benefit | Description |
|---------|-------------|
| **Shared logic** | Same AI router as web app |
| **Consistent behavior** | Memory works same everywhere |
| **Smaller bundle** | Only import what's needed |
| **BYOK works** | Services support user API keys |

---

## Next Steps

1. ✅ Document structure (this file)
2. [ ] Create quadframework-database repo
3. [ ] Create quadframework-services repo
4. [ ] Migrate existing services
5. [ ] Update quadframework-web to use services
6. [ ] Move VS Code plugin to separate repo

---

*This architecture enables QUAD to scale from 1 developer to 100+ while keeping code reusable and maintainable.*
