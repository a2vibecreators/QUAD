# QUAD Framework - Documentation Integration Architecture

> **Last Updated:** January 3, 2026
> **Purpose:** Design for DeepWiki, Confluence, GitBook, and Notion integration
> **Status:** Design Phase
> **Related:** [FEATURES.md](../FEATURES.md), [DISCUSSIONS_LOG.md](../internal/DISCUSSIONS_LOG.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Integration Philosophy](#integration-philosophy)
3. [Supported Platforms](#supported-platforms)
4. [Architecture](#architecture)
5. [DeepWiki Integration](#deepwiki-integration)
6. [Confluence Integration](#confluence-integration)
7. [GitBook Integration](#gitbook-integration)
8. [Notion Integration](#notion-integration)
9. [Database Schema](#database-schema)
10. [API Specification](#api-specification)
11. [Phase Plan](#phase-plan)

---

## Overview

### The Problem

Organizations use multiple documentation platforms:
- **Confluence** - Enterprise wiki, JIRA integration
- **Notion** - Modern, flexible workspace
- **GitBook** - Developer documentation
- **DeepWiki** - AI-powered codebase documentation
- **SharePoint** - Microsoft enterprise docs

**Pain Points:**
1. Documentation scattered across platforms
2. No single source of truth
3. Manual sync between platforms
4. AI can't query across all docs
5. Context switching kills productivity

### QUAD's Solution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD DOCUMENTATION HUB                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   SINGLE SOURCE OF TRUTH: Git + Markdown                                │
│   ─────────────────────────────────────────────────────────────────────  │
│                                                                          │
│   /docs/                                                                 │
│   ├── /api/           → API reference                                   │
│   ├── /architecture/  → System design, ADRs                             │
│   ├── /guides/        → How-to guides                                   │
│   └── /runbooks/      → Operations                                      │
│                                                                          │
│   AUTO-EXPORT TO:                                                        │
│   ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐           │
│   │ DeepWiki  │  │Confluence │  │  GitBook  │  │  Notion   │           │
│   │ (AI Chat) │  │(Enterprise)│  │(Dev Docs) │  │(Team Wiki)│           │
│   └───────────┘  └───────────┘  └───────────┘  └───────────┘           │
│                                                                          │
│   IMPORT FROM:                                                           │
│   ┌───────────┐  ┌───────────┐  ┌───────────┐                           │
│   │Confluence │  │  Notion   │  │ SharePoint│                           │
│   │  Import   │  │  Import   │  │  Import   │                           │
│   └───────────┘  └───────────┘  └───────────┘                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Integration Philosophy

### "Convention Over Configuration"

QUAD uses a **folder-based convention** for documentation:

| Folder | Purpose | Export Target |
|--------|---------|---------------|
| `/docs/api/` | API reference | GitBook, DeepWiki |
| `/docs/architecture/` | System design | Confluence, DeepWiki |
| `/docs/guides/` | How-to guides | Notion, GitBook |
| `/docs/runbooks/` | Operations | Confluence |
| `/docs/onboarding/` | New hire docs | Notion |
| `/business/` | Business docs | Confluence (restricted) |

### Three Integration Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **Sync** | Bi-directional real-time | Use QUAD + external tool together |
| **Export** | QUAD → External (one-way) | Publish from QUAD to external |
| **Import** | External → QUAD (one-time) | Migrate TO QUAD |

---

## Supported Platforms

### Platform Comparison

| Platform | Sync | Export | Import | AI Query | Phase |
|----------|------|--------|--------|----------|-------|
| **DeepWiki** | ✅ | ✅ | ✅ | ✅ Native | Phase 2 |
| **Confluence** | ✅ | ✅ | ✅ | Via QUAD | Phase 2 |
| **GitBook** | ✅ | ✅ | ✅ | Via QUAD | Phase 2 |
| **Notion** | ✅ | ✅ | ✅ | Via QUAD | Phase 2 |
| **SharePoint** | ❌ | ✅ | ✅ | Via QUAD | Phase 3 |
| **HTML/Static** | ❌ | ✅ | ❌ | N/A | Phase 2 |

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DOCUMENTATION INTEGRATION LAYER                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌───────────────────────────────────────────────────────────────────┐ │
│   │                      QUAD DOC SERVICE                              │ │
│   │                                                                    │ │
│   │   DocService                                                       │ │
│   │   ├── parseMarkdown(file) → DocNode                               │ │
│   │   ├── exportTo(platform, docs) → ExportResult                     │ │
│   │   ├── importFrom(platform, options) → ImportResult                │ │
│   │   ├── syncWith(platform, options) → SyncResult                    │ │
│   │   └── queryDocs(question) → AIResponse                            │ │
│   └───────────────────────────────────────────────────────────────────┘ │
│                              │                                           │
│         ┌────────────────────┼────────────────────┐                     │
│         ↓                    ↓                    ↓                     │
│   ┌───────────┐        ┌───────────┐        ┌───────────┐              │
│   │ DeepWiki  │        │Confluence │        │  GitBook  │              │
│   │  Adapter  │        │  Adapter  │        │  Adapter  │              │
│   └───────────┘        └───────────┘        └───────────┘              │
│   ┌───────────┐        ┌───────────┐        ┌───────────┐              │
│   │  Notion   │        │ SharePoint│        │  Static   │              │
│   │  Adapter  │        │  Adapter  │        │  Adapter  │              │
│   └───────────┘        └───────────┘        └───────────┘              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Adapter Interface

```typescript
interface DocPlatformAdapter {
  // Connection
  connect(credentials: PlatformCredentials): Promise<Connection>;
  disconnect(): Promise<void>;
  testConnection(): Promise<boolean>;

  // Export (QUAD → Platform)
  exportDocs(docs: DocNode[], options: ExportOptions): Promise<ExportResult>;
  exportSingle(doc: DocNode): Promise<ExportResult>;

  // Import (Platform → QUAD)
  importDocs(options: ImportOptions): Promise<ImportResult>;
  listRemoteDocs(): Promise<RemoteDoc[]>;

  // Sync (Bi-directional)
  sync(options: SyncOptions): Promise<SyncResult>;
  getChanges(since: Date): Promise<DocChange[]>;

  // AI Integration
  indexForAI(docs: DocNode[]): Promise<void>;
  queryAI(question: string): Promise<AIResponse>;
}
```

---

## DeepWiki Integration

### What is DeepWiki?

DeepWiki is an **AI-powered documentation platform** that:
- Indexes your codebase automatically
- Answers questions about your code in natural language
- Generates documentation from code
- Provides chat interface for developers

### Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD + DEEPWIKI INTEGRATION                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   QUAD DOCS (Markdown)                                                   │
│   ┌──────────────────┐                                                  │
│   │ /docs/api/       │                                                  │
│   │ /docs/guides/    │ ──── Push on commit ────►  DeepWiki Index       │
│   │ /docs/arch/      │                            ┌─────────────────┐   │
│   └──────────────────┘                            │ AI-Queryable    │   │
│                                                   │ Documentation   │   │
│   QUAD CODEBASE                                   └────────┬────────┘   │
│   ┌──────────────────┐                                     │            │
│   │ /src/            │                                     ↓            │
│   │ /prisma/         │ ──── GitHub Webhook ────►  ┌─────────────────┐   │
│   │ /tests/          │                            │ DeepWiki Chat   │   │
│   └──────────────────┘                            │ "How does auth  │   │
│                                                   │  work?"         │   │
│   QUAD MEMORY                                     └─────────────────┘   │
│   ┌──────────────────┐                                     ↑            │
│   │ Project context  │                                     │            │
│   │ Patterns         │ ──── Memory Sync ─────────────────────          │
│   │ Decisions        │                                                  │
│   └──────────────────┘                                                  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### DeepWiki Adapter

```typescript
class DeepWikiAdapter implements DocPlatformAdapter {
  private apiKey: string;
  private projectId: string;
  private baseUrl = 'https://api.deepwiki.com/v1';

  async connect(credentials: PlatformCredentials): Promise<Connection> {
    this.apiKey = credentials.apiKey;
    this.projectId = credentials.projectId;
    // Verify connection
    const response = await fetch(`${this.baseUrl}/projects/${this.projectId}`, {
      headers: { 'Authorization': `Bearer ${this.apiKey}` }
    });
    return { connected: response.ok };
  }

  async exportDocs(docs: DocNode[]): Promise<ExportResult> {
    // Convert Markdown to DeepWiki format
    const deepWikiDocs = docs.map(doc => ({
      path: doc.path,
      content: doc.content,
      metadata: {
        title: doc.title,
        tags: doc.tags,
        lastUpdated: doc.updatedAt
      }
    }));

    // Push to DeepWiki
    const response = await fetch(`${this.baseUrl}/projects/${this.projectId}/docs`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ documents: deepWikiDocs })
    });

    return { success: response.ok, docsExported: docs.length };
  }

  async queryAI(question: string): Promise<AIResponse> {
    const response = await fetch(`${this.baseUrl}/projects/${this.projectId}/chat`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ question })
    });

    const data = await response.json();
    return {
      answer: data.answer,
      sources: data.sources,
      confidence: data.confidence
    };
  }
}
```

### DeepWiki Sync Flow

```
On Git Push:
  1. GitHub Webhook triggers QUAD
  2. QUAD detects changed docs in /docs/
  3. QUAD parses Markdown → DocNode[]
  4. QUAD calls DeepWiki API to update
  5. DeepWiki re-indexes for AI queries

On User Query (via QUAD Chat):
  1. User asks: "How does authentication work?"
  2. QUAD routes to DeepWiki API
  3. DeepWiki searches indexed docs + code
  4. Returns answer with source references
  5. QUAD displays in chat with links
```

---

## Confluence Integration

### Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD + CONFLUENCE INTEGRATION                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   QUAD DOCS (Markdown)              Confluence Space                    │
│   ┌──────────────────┐              ┌──────────────────┐                │
│   │ /docs/           │              │ QUAD Docs Space  │                │
│   │ ├── architecture/│ ◄── Sync ──► │ ├── Architecture │                │
│   │ ├── api/         │              │ ├── API Docs     │                │
│   │ └── guides/      │              │ └── Guides       │                │
│   └──────────────────┘              └──────────────────┘                │
│                                                                          │
│   MAPPING:                                                               │
│   ┌────────────────────────────────────────────────────────────────┐    │
│   │ QUAD Folder         →    Confluence Location                    │    │
│   │ ─────────────────────────────────────────────────────────────── │    │
│   │ /docs/              →    Space: QUAD-DOCS                       │    │
│   │ /docs/api/          →    Parent Page: "API Documentation"       │    │
│   │ /docs/api/auth.md   →    Child Page: "Authentication API"       │    │
│   │ /business/          →    Space: QUAD-BUSINESS (restricted)      │    │
│   └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Confluence Adapter

```typescript
class ConfluenceAdapter implements DocPlatformAdapter {
  private client: ConfluenceClient;
  private spaceKey: string;

  async connect(credentials: PlatformCredentials): Promise<Connection> {
    this.client = new ConfluenceClient({
      host: credentials.host,
      authentication: {
        basic: {
          email: credentials.email,
          apiToken: credentials.apiToken
        }
      }
    });
    this.spaceKey = credentials.spaceKey;
    return { connected: true };
  }

  async exportDocs(docs: DocNode[]): Promise<ExportResult> {
    const results = [];

    for (const doc of docs) {
      // Convert Markdown to Confluence Storage Format
      const confluenceContent = this.markdownToConfluence(doc.content);

      // Check if page exists
      const existingPage = await this.findPage(doc.title);

      if (existingPage) {
        // Update existing page
        await this.client.content.updateContent({
          id: existingPage.id,
          body: {
            version: { number: existingPage.version.number + 1 },
            title: doc.title,
            type: 'page',
            body: {
              storage: {
                value: confluenceContent,
                representation: 'storage'
              }
            }
          }
        });
      } else {
        // Create new page
        await this.client.content.createContent({
          space: { key: this.spaceKey },
          title: doc.title,
          type: 'page',
          body: {
            storage: {
              value: confluenceContent,
              representation: 'storage'
            }
          }
        });
      }

      results.push({ path: doc.path, success: true });
    }

    return { success: true, docsExported: results.length };
  }

  async importDocs(options: ImportOptions): Promise<ImportResult> {
    // Get all pages from Confluence space
    const pages = await this.client.content.getContent({
      spaceKey: this.spaceKey,
      expand: ['body.storage', 'version', 'ancestors']
    });

    const docs: DocNode[] = [];

    for (const page of pages.results) {
      // Convert Confluence Storage Format to Markdown
      const markdown = this.confluenceToMarkdown(page.body.storage.value);

      docs.push({
        title: page.title,
        content: markdown,
        path: this.buildPath(page),
        updatedAt: new Date(page.version.when)
      });
    }

    return { success: true, docs, docsImported: docs.length };
  }

  private markdownToConfluence(markdown: string): string {
    // Convert Markdown to Confluence Storage Format
    // Handle: headers, code blocks, tables, links, images
    // ... implementation
  }

  private confluenceToMarkdown(storage: string): string {
    // Convert Confluence Storage Format to Markdown
    // ... implementation
  }
}
```

### Confluence Sync Scenarios

| Scenario | Action |
|----------|--------|
| **New doc in QUAD** | Create page in Confluence |
| **Edit doc in QUAD** | Update page, increment version |
| **Delete doc in QUAD** | Option: Archive or delete in Confluence |
| **New page in Confluence** | Create doc in QUAD (if sync enabled) |
| **Edit in Confluence** | Update doc in QUAD (if sync enabled) |
| **Conflict** | Show diff, let user choose |

---

## GitBook Integration

### Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD + GITBOOK INTEGRATION                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   QUAD creates GitBook-compatible structure:                            │
│                                                                          │
│   /docs/                                                                 │
│   ├── SUMMARY.md          ← GitBook TOC (auto-generated)                │
│   ├── README.md           ← Landing page                                │
│   ├── api/                                                               │
│   │   ├── README.md       ← Section intro                               │
│   │   ├── authentication.md                                             │
│   │   └── endpoints.md                                                  │
│   └── guides/                                                            │
│       ├── README.md                                                      │
│       └── getting-started.md                                            │
│                                                                          │
│   SYNC OPTIONS:                                                          │
│   ┌────────────────────────────────────────────────────────────────┐    │
│   │ Option 1: Git Sync (Recommended)                                │    │
│   │   - GitBook connects to your GitHub repo                        │    │
│   │   - Auto-updates on push                                        │    │
│   │   - No QUAD integration needed (native GitBook feature)         │    │
│   │                                                                  │    │
│   │ Option 2: API Sync                                               │    │
│   │   - QUAD pushes via GitBook API                                  │    │
│   │   - More control over what's published                           │    │
│   │   - Can filter/transform docs                                    │    │
│   └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### SUMMARY.md Auto-Generation

QUAD auto-generates GitBook's SUMMARY.md from folder structure:

```markdown
# Summary

## Getting Started
* [Introduction](README.md)
* [Quick Start](guides/getting-started.md)

## API Reference
* [Overview](api/README.md)
* [Authentication](api/authentication.md)
* [Endpoints](api/endpoints.md)

## Architecture
* [Overview](architecture/README.md)
* [Database Design](architecture/database.md)
* [AI Integration](architecture/ai.md)
```

---

## Notion Integration

### Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD + NOTION INTEGRATION                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   QUAD DOCS                         NOTION WORKSPACE                    │
│   ┌──────────────────┐              ┌──────────────────┐                │
│   │ /docs/guides/    │              │ QUAD Docs        │                │
│   │ ├── onboarding/  │ ◄── Sync ──► │ ├── Onboarding   │                │
│   │ ├── workflows/   │              │ ├── Workflows    │                │
│   │ └── faq.md       │              │ └── FAQ          │                │
│   └──────────────────┘              └──────────────────┘                │
│                                                                          │
│   NOTION FEATURES SUPPORTED:                                            │
│   ┌────────────────────────────────────────────────────────────────┐    │
│   │ ✅ Pages and sub-pages                                          │    │
│   │ ✅ Headers (H1, H2, H3)                                         │    │
│   │ ✅ Code blocks with syntax highlighting                         │    │
│   │ ✅ Tables                                                        │    │
│   │ ✅ Bullet and numbered lists                                     │    │
│   │ ✅ Callout blocks (info, warning, error)                        │    │
│   │ ⚠️ Databases (limited - export as tables)                       │    │
│   │ ❌ Embeds (not synced)                                          │    │
│   └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Notion Adapter

```typescript
class NotionAdapter implements DocPlatformAdapter {
  private client: Client;
  private rootPageId: string;

  async connect(credentials: PlatformCredentials): Promise<Connection> {
    this.client = new Client({ auth: credentials.apiToken });
    this.rootPageId = credentials.rootPageId;
    return { connected: true };
  }

  async exportDocs(docs: DocNode[]): Promise<ExportResult> {
    for (const doc of docs) {
      // Convert Markdown to Notion blocks
      const blocks = this.markdownToNotionBlocks(doc.content);

      // Find or create page
      const pageId = await this.findOrCreatePage(doc.title, doc.parentPath);

      // Update page content
      await this.client.blocks.children.append({
        block_id: pageId,
        children: blocks
      });
    }

    return { success: true, docsExported: docs.length };
  }

  private markdownToNotionBlocks(markdown: string): BlockObjectRequest[] {
    // Convert Markdown to Notion block format
    // ... implementation
  }
}
```

---

## Database Schema

### Documentation Integration Tables

```sql
-- Platform connections
CREATE TABLE QUAD_doc_integrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  -- Platform info
  platform VARCHAR(50) NOT NULL,  -- deepwiki, confluence, gitbook, notion
  platform_name VARCHAR(100),     -- Display name

  -- Connection
  connection_status VARCHAR(20) DEFAULT 'disconnected',
  credentials_vault_path TEXT,    -- Path in Vaultwarden

  -- Configuration
  root_path TEXT,                 -- /docs, /business, etc.
  sync_mode VARCHAR(20),          -- sync, export, import
  sync_frequency VARCHAR(20),     -- realtime, hourly, daily, manual

  -- Platform-specific
  space_key VARCHAR(100),         -- Confluence space key
  workspace_id VARCHAR(100),      -- Notion workspace ID
  project_id VARCHAR(100),        -- DeepWiki project ID

  -- Mapping
  folder_mapping JSONB,           -- {"/docs/api": "API Docs", ...}

  -- Status
  last_sync_at TIMESTAMPTZ,
  last_sync_status VARCHAR(20),
  last_sync_error TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(org_id, platform)
);

-- Sync history
CREATE TABLE QUAD_doc_sync_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  integration_id UUID REFERENCES QUAD_doc_integrations(id),

  -- Sync details
  sync_type VARCHAR(20),          -- full, incremental, single
  direction VARCHAR(10),          -- export, import, both

  -- Results
  docs_processed INTEGER DEFAULT 0,
  docs_created INTEGER DEFAULT 0,
  docs_updated INTEGER DEFAULT 0,
  docs_deleted INTEGER DEFAULT 0,
  docs_failed INTEGER DEFAULT 0,

  -- Errors
  errors JSONB,

  -- Timing
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,

  triggered_by UUID REFERENCES QUAD_users(id)
);

-- Document ID mapping (QUAD ↔ Platform)
CREATE TABLE QUAD_doc_id_map (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  integration_id UUID REFERENCES QUAD_doc_integrations(id),

  -- QUAD side
  quad_doc_path TEXT NOT NULL,    -- /docs/api/auth.md
  quad_doc_hash VARCHAR(64),      -- Content hash for change detection

  -- Platform side
  platform_id VARCHAR(255),       -- Platform's document ID
  platform_url TEXT,              -- Direct URL to doc

  -- Versioning
  quad_version INTEGER DEFAULT 1,
  platform_version INTEGER DEFAULT 1,

  -- Status
  sync_status VARCHAR(20),        -- synced, pending, conflict
  last_synced_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(integration_id, quad_doc_path)
);

-- AI query cache (for DeepWiki responses)
CREATE TABLE QUAD_doc_ai_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  integration_id UUID REFERENCES QUAD_doc_integrations(id),

  -- Query
  question_hash VARCHAR(64),      -- Hash of question for lookup
  question TEXT NOT NULL,

  -- Response
  answer TEXT,
  sources JSONB,                  -- [{path: "", title: "", snippet: ""}]
  confidence DECIMAL(3,2),

  -- Cache control
  expires_at TIMESTAMPTZ,
  hit_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_doc_integrations_org ON QUAD_doc_integrations(org_id);
CREATE INDEX idx_doc_sync_log_integration ON QUAD_doc_sync_log(integration_id);
CREATE INDEX idx_doc_id_map_path ON QUAD_doc_id_map(quad_doc_path);
CREATE INDEX idx_doc_ai_cache_hash ON QUAD_doc_ai_cache(question_hash);
```

---

## API Specification

### Endpoints

```
# Integration Management
GET    /api/docs/integrations              # List all integrations
POST   /api/docs/integrations              # Create new integration
GET    /api/docs/integrations/:id          # Get integration details
PUT    /api/docs/integrations/:id          # Update integration
DELETE /api/docs/integrations/:id          # Remove integration
POST   /api/docs/integrations/:id/test     # Test connection

# Sync Operations
POST   /api/docs/integrations/:id/sync     # Trigger sync
GET    /api/docs/integrations/:id/sync/status  # Get sync status
GET    /api/docs/integrations/:id/sync/history # Get sync history

# Document Operations
GET    /api/docs/integrations/:id/docs     # List synced docs
POST   /api/docs/integrations/:id/export   # Export specific docs
POST   /api/docs/integrations/:id/import   # Import from platform

# AI Query (DeepWiki)
POST   /api/docs/query                     # Query docs via AI
GET    /api/docs/query/history             # Query history
```

### Request/Response Examples

**Create Integration:**
```http
POST /api/docs/integrations
Content-Type: application/json

{
  "platform": "confluence",
  "platformName": "Atlassian Confluence",
  "credentials": {
    "host": "https://company.atlassian.net",
    "email": "user@company.com",
    "apiToken": "xxx"
  },
  "spaceKey": "QUADDOCS",
  "syncMode": "sync",
  "syncFrequency": "realtime",
  "folderMapping": {
    "/docs/api": "API Documentation",
    "/docs/architecture": "Architecture",
    "/business": "Business (Restricted)"
  }
}
```

**Trigger Sync:**
```http
POST /api/docs/integrations/123/sync
Content-Type: application/json

{
  "syncType": "incremental",
  "direction": "export",
  "paths": ["/docs/api/"]
}
```

**AI Query:**
```http
POST /api/docs/query
Content-Type: application/json

{
  "question": "How does the authentication system work?",
  "integrationId": "deepwiki-123",
  "includeCode": true
}

Response:
{
  "answer": "The authentication system uses JWT tokens with OAuth2...",
  "sources": [
    {
      "path": "/docs/api/authentication.md",
      "title": "Authentication API",
      "snippet": "JWT tokens are issued upon successful login...",
      "url": "https://deepwiki.com/project/123/docs/api/authentication"
    },
    {
      "path": "/src/services/auth.service.ts",
      "title": "AuthService",
      "snippet": "export class AuthService { ... }",
      "lineNumbers": "45-78"
    }
  ],
  "confidence": 0.92
}
```

---

## Phase Plan

### Phase 2 (Q2-Q3 2026)

| Feature | Priority | Effort |
|---------|----------|--------|
| DeepWiki export | High | 2 weeks |
| DeepWiki AI query | High | 1 week |
| Confluence export | High | 2 weeks |
| Confluence import | Medium | 1 week |
| GitBook SUMMARY.md generation | Medium | 3 days |
| Notion export | Medium | 2 weeks |
| Sync status UI | High | 1 week |

### Phase 3 (Q4 2026+)

| Feature | Priority | Effort |
|---------|----------|--------|
| Bi-directional sync (all platforms) | Medium | 4 weeks |
| Conflict resolution UI | Medium | 2 weeks |
| SharePoint integration | Low | 3 weeks |
| Static site generation | Low | 1 week |
| Custom templates | Low | 2 weeks |

---

## Value Proposition

### Before QUAD

```
Developer wants to find auth docs:
  1. Check Confluence → Not found
  2. Check Notion → Outdated
  3. Check GitHub wiki → Different version
  4. Ask colleague → "It's somewhere..."
  5. Read the code → Finally understand

Time wasted: 30-60 minutes
```

### With QUAD

```
Developer asks QUAD:
  "How does authentication work?"

QUAD (via DeepWiki):
  "Authentication uses JWT with OAuth2.
   Here's the flow: [diagram]
   See: auth.service.ts:45-78
   Docs: /docs/api/authentication.md"

Time: 30 seconds
```

### Cost Savings

| Scenario | Before QUAD | With QUAD | Savings |
|----------|-------------|-----------|---------|
| Find documentation | 30 min/day | 5 min/day | 83% |
| Sync docs across platforms | 2 hr/week | 0 (automated) | 100% |
| Onboard new developer | 1 week | 2 days | 60% |
| Answer "how does X work?" | 15 min | 30 sec | 96% |

---

## Sources

- [DeepWiki API Documentation](https://docs.deepwiki.com)
- [Confluence REST API](https://developer.atlassian.com/cloud/confluence/rest/v1/intro/)
- [GitBook API](https://developer.gitbook.com/)
- [Notion API](https://developers.notion.com/)

---

*Document generated: January 3, 2026*
*Next review: February 2026*
