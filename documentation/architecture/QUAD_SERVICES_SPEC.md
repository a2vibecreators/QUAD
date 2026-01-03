# QUAD Services Package Specification

**Last Updated:** January 3, 2026
**Status:** Planning
**Package Name:** `@quad/services`

---

## Table of Contents

1. [Overview](#1-overview)
2. [Package Structure](#2-package-structure)
3. [AI Module](#3-ai-module)
4. [Memory Module](#4-memory-module)
5. [Codebase Module](#5-codebase-module)
6. [Agent Module](#6-agent-module)
7. [Ticket Module](#7-ticket-module)
8. [Documentation Module](#8-documentation-module)
9. [Types & Interfaces](#9-types--interfaces)
10. [Configuration](#10-configuration)
11. [Usage Examples](#11-usage-examples)
12. [Build & Distribution](#12-build--distribution)

---

## 1. Overview

### Purpose

The `@quad/services` package provides reusable business logic that powers both:
- **QUAD Web App** (Next.js API routes)
- **QUAD VS Code Extension** (Extension commands)

### Design Principles

| Principle | Description |
|-----------|-------------|
| **Framework Agnostic** | No Next.js or VS Code dependencies in core |
| **Dependency Injection** | Prisma client injected, not imported |
| **BYOK Support** | All AI calls accept user-provided API keys |
| **Streaming First** | AI responses stream by default |
| **Type Safe** | Full TypeScript with strict mode |
| **Tree Shakeable** | ES modules for optimal bundling |

### Why This Package Exists

```
WITHOUT @quad/services:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌───────────────────────┐    ┌───────────────────────┐        │
│  │     QUAD Web App      │    │   QUAD VS Code Ext    │        │
│  │                       │    │                       │        │
│  │  ┌─────────────────┐  │    │  ┌─────────────────┐  │        │
│  │  │  AI Router      │  │    │  │  AI Router      │  │ DUPLICATE!
│  │  │  Memory Service │  │    │  │  Memory Service │  │ DUPLICATE!
│  │  │  Agent Logic    │  │    │  │  Agent Logic    │  │ DUPLICATE!
│  │  └─────────────────┘  │    │  └─────────────────┘  │        │
│  └───────────────────────┘    └───────────────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

WITH @quad/services:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌───────────────────────┐    ┌───────────────────────┐        │
│  │     QUAD Web App      │    │   QUAD VS Code Ext    │        │
│  │                       │    │                       │        │
│  │  import { AIRouter }  │    │  import { AIRouter }  │        │
│  │  from '@quad/services'│    │  from '@quad/services'│        │
│  └───────────┬───────────┘    └───────────┬───────────┘        │
│              │                            │                     │
│              └────────────┬───────────────┘                     │
│                           │                                     │
│              ┌────────────▼────────────┐                        │
│              │     @quad/services      │  SINGLE SOURCE!        │
│              │                         │                        │
│              │  • AIRouter             │                        │
│              │  • MemoryService        │                        │
│              │  • CodebaseIndexer      │                        │
│              │  • AgentOrchestrator    │                        │
│              └─────────────────────────┘                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Package Structure

```
quadframework-services/
├── src/
│   ├── index.ts                    # Main exports
│   │
│   ├── ai/                         # AI Provider Layer
│   │   ├── index.ts                # AI exports
│   │   ├── router.ts               # Intelligent routing
│   │   ├── classifier.ts           # Task classification
│   │   ├── cost-calculator.ts      # Token & cost tracking
│   │   ├── providers/
│   │   │   ├── base.ts             # Base provider interface
│   │   │   ├── claude.ts           # Anthropic Claude
│   │   │   ├── gemini.ts           # Google Gemini
│   │   │   ├── groq.ts             # Groq (Llama, Mixtral)
│   │   │   ├── deepseek.ts         # DeepSeek R1
│   │   │   └── openai.ts           # OpenAI GPT-4o
│   │   └── types.ts                # AI types
│   │
│   ├── memory/                     # Memory System
│   │   ├── index.ts                # Memory exports
│   │   ├── memory-service.ts       # Hierarchical memory
│   │   ├── chunk-service.ts        # Document chunking
│   │   ├── keyword-service.ts      # Keyword extraction
│   │   ├── embeddings.ts           # Vector embeddings
│   │   └── types.ts                # Memory types
│   │
│   ├── codebase/                   # Codebase Indexing
│   │   ├── index.ts                # Codebase exports
│   │   ├── indexer.ts              # Full repo indexer
│   │   ├── parser.ts               # Tree-sitter wrapper
│   │   ├── symbols.ts              # Symbol extraction
│   │   ├── references.ts           # Reference finder
│   │   └── types.ts                # Codebase types
│   │
│   ├── agents/                     # Agent System
│   │   ├── index.ts                # Agent exports
│   │   ├── orchestrator.ts         # Agent orchestration
│   │   ├── base-agent.ts           # Base agent class
│   │   ├── dev-agent.ts            # Developer agent
│   │   ├── review-agent.ts         # Code reviewer
│   │   ├── ba-agent.ts             # Business analyst
│   │   ├── qa-agent.ts             # QA engineer
│   │   ├── doc-agent.ts            # Documentation agent
│   │   └── types.ts                # Agent types
│   │
│   ├── tickets/                    # Ticket Operations
│   │   ├── index.ts                # Ticket exports
│   │   ├── ticket-service.ts       # CRUD + AI enrichment
│   │   ├── sprint-service.ts       # Sprint management
│   │   ├── story-splitter.ts       # Epic → Stories
│   │   ├── acceptance-generator.ts # Generate ACs
│   │   └── types.ts                # Ticket types
│   │
│   ├── docs/                       # Documentation Gen
│   │   ├── index.ts                # Docs exports
│   │   ├── generator.ts            # AI doc generation
│   │   ├── templates/              # Doc templates
│   │   │   ├── api-doc.ts
│   │   │   ├── readme.ts
│   │   │   └── jsdoc.ts
│   │   └── types.ts                # Doc types
│   │
│   ├── git/                        # Git Operations
│   │   ├── index.ts                # Git exports
│   │   ├── commit-analyzer.ts      # Commit analysis
│   │   ├── pr-generator.ts         # PR description gen
│   │   ├── diff-parser.ts          # Diff parsing
│   │   └── types.ts                # Git types
│   │
│   ├── utils/                      # Shared Utilities
│   │   ├── token-counter.ts        # Token counting
│   │   ├── rate-limiter.ts         # Rate limiting
│   │   ├── retry.ts                # Retry logic
│   │   ├── logger.ts               # Structured logging
│   │   └── cache.ts                # In-memory cache
│   │
│   └── types/                      # Shared Types
│       ├── index.ts                # Type exports
│       ├── common.ts               # Common types
│       ├── database.ts             # DB types
│       └── config.ts               # Config types
│
├── package.json
├── tsconfig.json
├── tsup.config.ts                  # Build config
└── README.md
```

---

## 3. AI Module

### AIRouter

The intelligent routing engine that selects the best AI provider for each task.

```typescript
// src/ai/router.ts

export interface AIRouterConfig {
  defaultProvider: 'claude' | 'gemini' | 'groq' | 'deepseek' | 'openai';
  fallbackProvider?: string;
  maxRetries: number;
  timeout: number;
  costOptimization: boolean;
}

export interface AIRequest {
  prompt: string;
  systemPrompt?: string;
  taskType: TaskType;
  context?: {
    ticketId?: string;
    codeContext?: string;
    memoryContext?: MemoryEntry[];
  };
  options?: {
    temperature?: number;
    maxTokens?: number;
    stream?: boolean;
  };
  // BYOK support
  apiKey?: string;
  provider?: string;
}

export interface AIResponse {
  content: string;
  provider: string;
  model: string;
  usage: {
    inputTokens: number;
    outputTokens: number;
    cost: number;
  };
  metadata: {
    latency: number;
    cached: boolean;
  };
}

export class AIRouter {
  constructor(config: AIRouterConfig);

  // Main routing method
  async route(request: AIRequest): Promise<AIResponse>;

  // Streaming version
  async *streamRoute(request: AIRequest): AsyncGenerator<string>;

  // Get best provider for task
  selectProvider(taskType: TaskType): ProviderConfig;

  // Cost estimation
  estimateCost(request: AIRequest): CostEstimate;
}
```

### Task Types & Provider Mapping

```typescript
// src/ai/types.ts

export enum TaskType {
  // Coding Tasks
  CODE_GENERATION = 'code_generation',
  CODE_REVIEW = 'code_review',
  CODE_EXPLANATION = 'code_explanation',
  BUG_FIX = 'bug_fix',
  REFACTORING = 'refactoring',

  // Documentation
  DOC_GENERATION = 'doc_generation',
  COMMENT_GENERATION = 'comment_generation',

  // Planning
  STORY_SPLITTING = 'story_splitting',
  ACCEPTANCE_CRITERIA = 'acceptance_criteria',
  SPRINT_PLANNING = 'sprint_planning',

  // Analysis
  CODEBASE_ANALYSIS = 'codebase_analysis',
  DEEP_REASONING = 'deep_reasoning',
  ARCHITECTURE_REVIEW = 'architecture_review',

  // Quick Tasks
  QUICK_ANSWER = 'quick_answer',
  CLASSIFICATION = 'classification',
  SUMMARIZATION = 'summarization',
}

// Default provider mapping
export const TASK_PROVIDER_MAP: Record<TaskType, string[]> = {
  [TaskType.CODE_GENERATION]: ['claude', 'gemini'],
  [TaskType.CODE_REVIEW]: ['claude', 'gemini'],
  [TaskType.DEEP_REASONING]: ['deepseek', 'claude'],
  [TaskType.QUICK_ANSWER]: ['groq', 'gemini'],
  [TaskType.CLASSIFICATION]: ['groq', 'gemini'],
  [TaskType.DOC_GENERATION]: ['gemini', 'claude'],
  // ... etc
};
```

### Provider Implementations

```typescript
// src/ai/providers/claude.ts

import Anthropic from '@anthropic-ai/sdk';

export class ClaudeProvider implements AIProvider {
  private client: Anthropic;

  constructor(apiKey: string) {
    this.client = new Anthropic({ apiKey });
  }

  async complete(request: ProviderRequest): Promise<ProviderResponse> {
    const response = await this.client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: request.maxTokens || 4096,
      messages: [{ role: 'user', content: request.prompt }],
      system: request.systemPrompt,
    });

    return {
      content: response.content[0].text,
      inputTokens: response.usage.input_tokens,
      outputTokens: response.usage.output_tokens,
    };
  }

  async *stream(request: ProviderRequest): AsyncGenerator<string> {
    const stream = await this.client.messages.stream({
      model: 'claude-sonnet-4-20250514',
      max_tokens: request.maxTokens || 4096,
      messages: [{ role: 'user', content: request.prompt }],
    });

    for await (const event of stream) {
      if (event.type === 'content_block_delta') {
        yield event.delta.text;
      }
    }
  }
}
```

---

## 4. Memory Module

### MemoryService

Hierarchical memory system for context management.

```typescript
// src/memory/memory-service.ts

export interface MemoryEntry {
  id: string;
  level: 'org' | 'domain' | 'project' | 'ticket';
  levelId: string;
  content: string;
  keywords: string[];
  embedding?: number[];
  metadata: {
    source: string;
    timestamp: Date;
    relevanceScore?: number;
  };
}

export interface MemoryQuery {
  orgId: string;
  level?: MemoryEntry['level'];
  levelId?: string;
  keywords?: string[];
  semanticQuery?: string;
  limit?: number;
}

export class MemoryService {
  constructor(
    private prisma: PrismaClient,
    private embeddingService?: EmbeddingService
  ) {}

  // Store memory
  async store(entry: Omit<MemoryEntry, 'id'>): Promise<MemoryEntry>;

  // Retrieve relevant memories
  async retrieve(query: MemoryQuery): Promise<MemoryEntry[]>;

  // Semantic search (if embeddings available)
  async semanticSearch(query: string, limit: number): Promise<MemoryEntry[]>;

  // Build context for AI prompt
  async buildContext(ticketId: string): Promise<string>;

  // Prune old/irrelevant memories
  async prune(orgId: string, olderThan: Date): Promise<number>;
}
```

### ChunkService

Document chunking for large content.

```typescript
// src/memory/chunk-service.ts

export interface ChunkOptions {
  maxTokens: number;
  overlap: number;
  preserveCodeBlocks: boolean;
  preserveMarkdown: boolean;
}

export class ChunkService {
  // Split content into chunks
  chunk(content: string, options: ChunkOptions): Chunk[];

  // Chunk code files intelligently
  chunkCode(code: string, language: string): Chunk[];

  // Chunk markdown preserving structure
  chunkMarkdown(markdown: string): Chunk[];

  // Merge chunks back
  merge(chunks: Chunk[]): string;
}
```

---

## 5. Codebase Module

### CodebaseIndexer

Full codebase indexing for context retrieval.

```typescript
// src/codebase/indexer.ts

export interface IndexOptions {
  rootPath: string;
  include: string[];      // Glob patterns
  exclude: string[];      // Ignore patterns
  parseComments: boolean;
  extractTypes: boolean;
  followImports: boolean;
}

export interface CodeSymbol {
  name: string;
  kind: 'function' | 'class' | 'method' | 'variable' | 'type' | 'interface';
  filePath: string;
  startLine: number;
  endLine: number;
  signature?: string;
  docstring?: string;
  references?: CodeReference[];
}

export interface CodebaseIndex {
  symbols: CodeSymbol[];
  files: FileEntry[];
  dependencies: DependencyGraph;
  lastUpdated: Date;
}

export class CodebaseIndexer {
  constructor(private parser: TreeSitterParser) {}

  // Full index
  async indexCodebase(options: IndexOptions): Promise<CodebaseIndex>;

  // Incremental update
  async updateIndex(index: CodebaseIndex, changedFiles: string[]): Promise<CodebaseIndex>;

  // Find symbol
  async findSymbol(name: string, kind?: string): Promise<CodeSymbol[]>;

  // Find references
  async findReferences(symbol: CodeSymbol): Promise<CodeReference[]>;

  // Get context for file
  async getFileContext(filePath: string): Promise<FileContext>;
}
```

---

## 6. Agent Module

### AgentOrchestrator

Coordinates multiple AI agents working together.

```typescript
// src/agents/orchestrator.ts

export interface AgentTask {
  id: string;
  type: 'implement' | 'review' | 'analyze' | 'document' | 'test';
  input: {
    ticketId?: string;
    code?: string;
    files?: string[];
    instructions?: string;
  };
  config: {
    maxIterations: number;
    autoApprove: boolean;
    notifyOnComplete: boolean;
  };
}

export interface AgentResult {
  taskId: string;
  status: 'success' | 'failed' | 'needs_review';
  outputs: {
    files?: FileChange[];
    review?: ReviewComment[];
    analysis?: AnalysisReport;
    documentation?: string;
  };
  metrics: {
    tokensUsed: number;
    cost: number;
    duration: number;
    iterations: number;
  };
}

export class AgentOrchestrator {
  constructor(
    private aiRouter: AIRouter,
    private memoryService: MemoryService,
    private codebaseIndexer: CodebaseIndexer
  ) {}

  // Execute agent task
  async execute(task: AgentTask): Promise<AgentResult>;

  // Execute with streaming updates
  async *executeWithUpdates(task: AgentTask): AsyncGenerator<AgentUpdate>;

  // Cancel running task
  async cancel(taskId: string): Promise<void>;

  // Get task status
  async getStatus(taskId: string): Promise<TaskStatus>;
}
```

### DevAgent

Developer agent for code implementation.

```typescript
// src/agents/dev-agent.ts

export class DevAgent extends BaseAgent {
  name = 'dev';

  async execute(context: AgentContext): Promise<AgentOutput> {
    // 1. Understand ticket requirements
    const requirements = await this.analyzeTicket(context.ticketId);

    // 2. Gather codebase context
    const codeContext = await this.gatherContext(requirements);

    // 3. Plan implementation
    const plan = await this.planImplementation(requirements, codeContext);

    // 4. Generate code
    const code = await this.generateCode(plan);

    // 5. Self-review
    const review = await this.selfReview(code);

    // 6. Return result
    return {
      files: code.files,
      review: review,
      plan: plan,
    };
  }
}
```

---

## 7. Ticket Module

### TicketService

Ticket operations with AI enrichment.

```typescript
// src/tickets/ticket-service.ts

export interface TicketInput {
  title: string;
  description?: string;
  type: 'epic' | 'story' | 'task' | 'bug';
  priority?: 'low' | 'medium' | 'high' | 'critical';
  domainId: string;
  projectId?: string;
}

export interface EnrichedTicket extends TicketInput {
  id: string;
  acceptanceCriteria?: string[];
  technicalNotes?: string;
  estimatedPoints?: number;
  suggestedAssignee?: string;
  relatedTickets?: string[];
  aiEnriched: boolean;
}

export class TicketService {
  constructor(
    private prisma: PrismaClient,
    private aiRouter: AIRouter
  ) {}

  // Create with AI enrichment
  async create(input: TicketInput, enrich?: boolean): Promise<EnrichedTicket>;

  // Split epic into stories
  async splitEpic(epicId: string): Promise<EnrichedTicket[]>;

  // Generate acceptance criteria
  async generateAcceptanceCriteria(ticketId: string): Promise<string[]>;

  // Estimate story points
  async estimatePoints(ticketId: string): Promise<number>;

  // Find related tickets
  async findRelated(ticketId: string): Promise<EnrichedTicket[]>;
}
```

---

## 8. Documentation Module

### DocumentationService

AI-powered documentation generation.

```typescript
// src/docs/generator.ts

export interface DocRequest {
  type: 'api' | 'readme' | 'jsdoc' | 'changelog' | 'guide';
  input: {
    code?: string;
    files?: string[];
    projectPath?: string;
  };
  options?: {
    style?: 'formal' | 'casual' | 'technical';
    includeExamples?: boolean;
    format?: 'markdown' | 'html' | 'rst';
  };
}

export class DocumentationService {
  constructor(private aiRouter: AIRouter) {}

  // Generate documentation
  async generate(request: DocRequest): Promise<string>;

  // Generate JSDoc for function
  async generateJSDoc(code: string, language: string): Promise<string>;

  // Generate README from codebase
  async generateReadme(projectPath: string): Promise<string>;

  // Generate API docs
  async generateApiDocs(openApiSpec: object): Promise<string>;

  // Generate changelog from commits
  async generateChangelog(commits: Commit[]): Promise<string>;
}
```

---

## 9. Types & Interfaces

### Main Exports

```typescript
// src/index.ts

// AI
export { AIRouter } from './ai/router';
export { ClaudeProvider, GeminiProvider, GroqProvider, DeepSeekProvider } from './ai/providers';
export { TaskType, TASK_PROVIDER_MAP } from './ai/types';
export type { AIRequest, AIResponse, AIRouterConfig } from './ai/types';

// Memory
export { MemoryService } from './memory/memory-service';
export { ChunkService } from './memory/chunk-service';
export { KeywordService } from './memory/keyword-service';
export type { MemoryEntry, MemoryQuery } from './memory/types';

// Codebase
export { CodebaseIndexer } from './codebase/indexer';
export { TreeSitterParser } from './codebase/parser';
export type { CodeSymbol, CodebaseIndex, IndexOptions } from './codebase/types';

// Agents
export { AgentOrchestrator } from './agents/orchestrator';
export { DevAgent, ReviewAgent, BAAgent, QAAgent, DocAgent } from './agents';
export type { AgentTask, AgentResult } from './agents/types';

// Tickets
export { TicketService } from './tickets/ticket-service';
export { SprintService } from './tickets/sprint-service';
export { StorySplitter } from './tickets/story-splitter';
export type { TicketInput, EnrichedTicket } from './tickets/types';

// Docs
export { DocumentationService } from './docs/generator';
export type { DocRequest } from './docs/types';

// Git
export { CommitAnalyzer } from './git/commit-analyzer';
export { PRGenerator } from './git/pr-generator';

// Utils
export { TokenCounter } from './utils/token-counter';
export { CostCalculator } from './utils/cost-calculator';
export { RateLimiter } from './utils/rate-limiter';

// Types
export * from './types';
```

---

## 10. Configuration

### QuadServicesConfig

```typescript
// src/types/config.ts

export interface QuadServicesConfig {
  // AI Configuration
  ai: {
    defaultProvider: 'claude' | 'gemini' | 'groq' | 'deepseek' | 'openai';
    providers: {
      claude?: { apiKey: string; model?: string };
      gemini?: { apiKey: string; model?: string };
      groq?: { apiKey: string; model?: string };
      deepseek?: { apiKey: string; model?: string };
      openai?: { apiKey: string; model?: string };
    };
    routing: {
      costOptimization: boolean;
      fallbackEnabled: boolean;
      maxRetries: number;
    };
  };

  // Memory Configuration
  memory: {
    maxEntriesPerLevel: number;
    embeddingsEnabled: boolean;
    embeddingsProvider?: 'openai' | 'local';
  };

  // Codebase Configuration
  codebase: {
    maxFileSize: number;
    excludePatterns: string[];
    parseLanguages: string[];
  };

  // Agent Configuration
  agents: {
    maxIterations: number;
    autoApprove: boolean;
    notifyOnComplete: boolean;
  };

  // Logging
  logging: {
    level: 'debug' | 'info' | 'warn' | 'error';
    structured: boolean;
  };
}

// Create service instance with config
export function createQuadServices(
  prisma: PrismaClient,
  config: QuadServicesConfig
): QuadServices;
```

---

## 11. Usage Examples

### In QUAD Web App

```typescript
// quadframework-web/src/app/api/ai/route.ts

import { AIRouter, TaskType } from '@quad/services';
import { prisma } from '@/lib/db';

const aiRouter = new AIRouter({
  defaultProvider: 'claude',
  costOptimization: true,
  maxRetries: 3,
});

export async function POST(request: NextRequest) {
  const session = await getSession();
  const { prompt, taskType } = await request.json();

  // Get org's API key (BYOK)
  const orgConfig = await prisma.qUAD_ai_configs.findUnique({
    where: { org_id: session.orgId }
  });

  const response = await aiRouter.route({
    prompt,
    taskType: taskType as TaskType,
    apiKey: orgConfig?.byok_key || process.env.DEFAULT_CLAUDE_KEY,
  });

  return NextResponse.json(response);
}
```

### In QUAD VS Code Extension

```typescript
// quadframework-vscode/src/commands/generate-docs.ts

import { DocumentationService, AIRouter } from '@quad/services';
import * as vscode from 'vscode';

export async function generateDocs() {
  const editor = vscode.window.activeTextEditor;
  if (!editor) return;

  const code = editor.document.getText(editor.selection);
  const language = editor.document.languageId;

  // Get user's API key from extension settings
  const config = vscode.workspace.getConfiguration('quad');
  const apiKey = config.get<string>('geminiApiKey');

  const aiRouter = new AIRouter({
    defaultProvider: 'gemini',
    providers: { gemini: { apiKey } }
  });

  const docService = new DocumentationService(aiRouter);

  const docs = await docService.generateJSDoc(code, language);

  // Insert above selection
  editor.edit(builder => {
    builder.insert(editor.selection.start, docs + '\n');
  });

  vscode.window.showInformationMessage('Documentation generated!');
}
```

### With Memory Context

```typescript
// Building context-aware AI responses

import { AIRouter, MemoryService, TaskType } from '@quad/services';

async function respondWithContext(
  prisma: PrismaClient,
  ticketId: string,
  userMessage: string
) {
  const memoryService = new MemoryService(prisma);
  const aiRouter = new AIRouter({ defaultProvider: 'claude' });

  // Retrieve relevant memories
  const context = await memoryService.buildContext(ticketId);

  // Make AI call with context
  const response = await aiRouter.route({
    prompt: userMessage,
    systemPrompt: `You are a helpful coding assistant. Use this context:\n${context}`,
    taskType: TaskType.CODE_GENERATION,
  });

  // Store response in memory
  await memoryService.store({
    level: 'ticket',
    levelId: ticketId,
    content: response.content,
    keywords: ['ai-response'],
    metadata: { source: 'ai-assistant' }
  });

  return response;
}
```

---

## 12. Build & Distribution

### package.json

```json
{
  "name": "@quad/services",
  "version": "1.0.0",
  "description": "Reusable business logic for QUAD Framework",
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    },
    "./ai": {
      "import": "./dist/ai/index.mjs",
      "require": "./dist/ai/index.js",
      "types": "./dist/ai/index.d.ts"
    },
    "./memory": {
      "import": "./dist/memory/index.mjs",
      "require": "./dist/memory/index.js",
      "types": "./dist/memory/index.d.ts"
    },
    "./agents": {
      "import": "./dist/agents/index.mjs",
      "require": "./dist/agents/index.js",
      "types": "./dist/agents/index.d.ts"
    }
  },
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "test": "vitest",
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit"
  },
  "peerDependencies": {
    "@prisma/client": "^5.0.0"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.20.0",
    "@google/generative-ai": "^0.5.0",
    "groq-sdk": "^0.3.0",
    "openai": "^4.0.0",
    "tiktoken": "^1.0.0",
    "tree-sitter": "^0.21.0"
  },
  "devDependencies": {
    "tsup": "^8.0.0",
    "typescript": "^5.3.0",
    "vitest": "^1.0.0"
  }
}
```

### Build Configuration

```typescript
// tsup.config.ts

import { defineConfig } from 'tsup';

export default defineConfig({
  entry: {
    index: 'src/index.ts',
    'ai/index': 'src/ai/index.ts',
    'memory/index': 'src/memory/index.ts',
    'agents/index': 'src/agents/index.ts',
    'tickets/index': 'src/tickets/index.ts',
    'codebase/index': 'src/codebase/index.ts',
  },
  format: ['cjs', 'esm'],
  dts: true,
  splitting: true,
  clean: true,
  treeshake: true,
  external: ['@prisma/client'],
});
```

### Distribution Options

| Method | Use Case |
|--------|----------|
| **npm link** | Development - link local package |
| **npm workspace** | Monorepo - single node_modules |
| **npm publish** | Public - `@quad/services` on npm |
| **Private npm** | Enterprise - private registry |
| **Bundled** | VS Code - bundle in extension |

---

## Next Steps

1. ✅ Document structure (this file)
2. [ ] Create GitHub repo `quadframework-services`
3. [ ] Scaffold package with tsup
4. [ ] Migrate existing lib/services/ code
5. [ ] Add AI provider implementations
6. [ ] Add memory service
7. [ ] Add tests
8. [ ] Publish to npm

---

*This services package is the foundation for QUAD's multi-platform strategy.*
