# QUAD Framework - Codebase Index System

## Overview

The Codebase Index System provides **token-optimized AI context** by pre-indexing your codebase into a compact summary. Instead of sending 50,000+ tokens of raw code to AI, we send ~5,000 tokens of structured summaries.

---

## Problem & Solution

### The Problem

```
Traditional AI Code Assistance:

User asks: "How do I add a button that shows time in a modal?"

AI needs to:
1. Read all component files         (~20,000 tokens)
2. Read all API routes              (~15,000 tokens)
3. Read database schema             (~40,000 tokens)
4. Understand patterns              (~10,000 tokens)
─────────────────────────────────────────────────────
Total per question:                  ~85,000 tokens
Cost: ~$0.25 per question
```

### The Solution

```
With Codebase Index:

User asks: "How do I add a button that shows time in a modal?"

AI receives:
1. Pre-built index summary          (~5,000 tokens)
   - Tables: QUAD_tickets, QUAD_users, etc.
   - APIs: POST /api/tickets, GET /api/domains, etc.
   - Components: Modal.tsx, Button.tsx, etc.
   - Patterns: Next.js, Prisma, Tailwind
─────────────────────────────────────────────────────
Total per question:                  ~5,000 tokens
Cost: ~$0.015 per question (94% cheaper!)
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CODEBASE INDEX PIPELINE                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Git Repository │────▶│  Indexer Script  │────▶│   PostgreSQL     │
│   (58,262 LOC)   │     │  (Scans & Maps)  │     │  QUAD_codebase_  │
│                  │     │                  │     │  indexes table   │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                                           │
                                                           ▼
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   User Question  │────▶│  /api/ai/chat    │────▶│   AI Response    │
│  "Add modal..."  │     │  (Loads Index)   │     │  with context    │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

---

## What Gets Indexed

| Category | What's Stored | Example |
|----------|---------------|---------|
| **Tables** | Model name + description | `QUAD_tickets: "Work items with status, priority"` |
| **APIs** | Method + path + description | `POST /api/tickets: "Create new ticket"` |
| **Files** | Path + purpose | `src/lib/auth.ts: "JWT authentication"` |
| **Components** | Name + description | `Modal.tsx: "Reusable dialog component"` |
| **Patterns** | Tech stack detected | `framework: "Next.js App Router"` |
| **Architecture** | High-level summary | `"93 tables, 170 APIs, 22 components"` |

---

## Database Schema

```sql
CREATE TABLE "QUAD_codebase_indexes" (
  id                    UUID PRIMARY KEY,
  org_id                UUID NOT NULL,

  -- Repository identification
  repo_name             VARCHAR(255),    -- "quadframework"
  repo_url              VARCHAR(500),    -- GitHub URL
  branch                VARCHAR(100),    -- "main"
  commit_hash           VARCHAR(40),     -- Last indexed commit

  -- Summarized content (JSONB)
  tables_summary        JSONB,           -- {"QUAD_tickets": "description", ...}
  apis_summary          JSONB,           -- {"POST /api/x": "description", ...}
  files_summary         JSONB,           -- {"path/file.ts": "description", ...}
  components_summary    JSONB,           -- {"Modal": "description", ...}
  patterns_summary      JSONB,           -- {"auth": "NextAuth", ...}
  architecture_summary  TEXT,            -- High-level overview

  -- Token tracking
  total_tokens          INTEGER,         -- Tokens when index is used
  token_savings_percent INTEGER,         -- Savings vs full code

  -- Metadata
  file_count            INTEGER,
  table_count           INTEGER,
  api_count             INTEGER,
  loc_count             INTEGER,         -- Lines of code

  -- Sync status
  last_synced_at        TIMESTAMP,
  sync_status           VARCHAR(50),     -- pending, syncing, synced, failed

  UNIQUE(org_id, repo_name, branch)
);
```

---

## API Endpoints

### GET /api/codebase-index

Fetch the codebase index for AI context.

**Query Parameters:**
- `repo` - Repository name (default: "quadframework")
- `format` - Response format: "json" or "text"

**Response (JSON):**
```json
{
  "success": true,
  "data": {
    "index": {
      "tables": {"QUAD_tickets": "Work items..."},
      "apis": {"POST /api/tickets": "Create ticket"},
      "files": {"src/lib/auth.ts": "JWT auth"},
      "components": {"Modal": "Dialog component"},
      "patterns": {"framework": "Next.js"},
      "architecture": "93 tables, 170 APIs..."
    },
    "formatted": "## Architecture\n...",
    "metadata": {
      "totalTokens": 5593,
      "tokenSavingsPercent": 95,
      "fileCount": 202,
      "lastSyncedAt": "2026-01-03T02:40:00Z"
    }
  }
}
```

### POST /api/codebase-index

Regenerate the codebase index.

**Request Body:**
```json
{
  "repoName": "quadframework",
  "repoPath": "/path/to/repo",
  "repoUrl": "https://github.com/org/repo"
}
```

---

## CLI Usage

### Generate Index

```bash
# Using npx tsx
DATABASE_URL="postgresql://..." npx tsx scripts/generate-codebase-index.ts \
  "<org_id>" \
  "/path/to/repo" \
  "repo_name"

# Example for QUAD
DATABASE_URL="postgresql://quad_user:quad_dev_pass@localhost:16201/quad_dev_db" \
npx tsx scripts/generate-codebase-index.ts \
  "00000000-0000-0000-0000-000000000001" \
  "/Users/dev/quadframework" \
  "quadframework"
```

### Output

```
╔════════════════════════════════════════════════════════════════╗
║                    ✅ INDEX GENERATED                          ║
╠════════════════════════════════════════════════════════════════╣
║  Files indexed:    202                                         ║
║  Tables found:     93                                          ║
║  API routes:       170                                         ║
║  Components:       22                                          ║
║  Lines of code:    58262                                       ║
║  Index tokens:     5593                                        ║
║  Token savings:    95%                                         ║
╚════════════════════════════════════════════════════════════════╝
```

---

## Integration with AI Chat

The `/api/ai/chat` endpoint automatically uses the codebase index:

```typescript
// In /api/ai/chat/route.ts

// Step 4: Fetch codebase index for broader context
let codebaseContext: string | undefined;
try {
  const codebaseIndex = await getCodebaseIndex(user.companyId, 'quadframework');
  if (codebaseIndex) {
    codebaseContext = formatIndexForAI(codebaseIndex);
    console.log(`Using codebase index (~${indexTokens} tokens)`);
  }
} catch {
  console.log('No codebase index available');
}

// Step 5: Build system prompt with index context
const contextString = buildContextString(
  context.tables,
  context.categories,
  codebaseContext  // ← Index injected here
);
```

---

## Cross-Context Questions

When a user asks about multiple topics (e.g., "tickets AND modals"):

```
User: "I want to show ticket details in a modal"

┌─────────────────────────────────────────────────────────────────┐
│  KEYWORD MATCHING                                                │
│                                                                  │
│  "ticket" → matches 'tickets' category                           │
│  "modal" → no specific category (component question)             │
│                                                                  │
│  Result: categories = ['tickets']                                │
│          tables = ['QUAD_tickets', 'QUAD_ticket_comments']       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  CODEBASE INDEX (fills the gap!)                                 │
│                                                                  │
│  Index contains:                                                 │
│  - components: {"Modal.tsx": "Reusable dialog component"}        │
│  - files: {"src/components/Modal.tsx": "Dialog with overlay"}    │
│  - patterns: {"ui": "Tailwind + shadcn/ui"}                      │
│                                                                  │
│  AI now knows: Modal component exists at src/components/Modal    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  AI RESPONSE                                                     │
│                                                                  │
│  "To show ticket details in a modal:                             │
│   1. Import Modal from src/components/Modal.tsx                  │
│   2. Fetch ticket via GET /api/tickets/:id                       │
│   3. Pass ticket data to Modal component                         │
│   4. Use QUAD_tickets fields: title, description, status..."     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Token Savings Analysis

### Before (Without Index)

| Component | Tokens |
|-----------|--------|
| Full Prisma schema | ~40,000 |
| All API routes | ~15,000 |
| Component files | ~20,000 |
| Conversation | ~5,000 |
| **Total** | **~80,000** |

### After (With Index)

| Component | Tokens |
|-----------|--------|
| Codebase index | ~5,000 |
| Matched schema (subset) | ~500 |
| Conversation | ~5,000 |
| **Total** | **~10,500** |

### Savings

- **Per question**: 87% reduction
- **Per 100 questions**: ~7M tokens saved
- **Monthly cost reduction**: ~$20-50

---

## When to Regenerate Index

| Trigger | Action |
|---------|--------|
| New tables added | Run indexer |
| New API routes | Run indexer |
| Major refactoring | Run indexer |
| Weekly scheduled | Cron job (recommended) |
| Git push webhook | Auto-regenerate |

---

## Files Reference

| File | Purpose |
|------|---------|
| `prisma/schema.prisma` | QUAD_codebase_indexes model |
| `src/lib/ai/codebase-indexer.ts` | Core indexing logic |
| `src/app/api/codebase-index/route.ts` | API endpoint |
| `scripts/generate-codebase-index.ts` | CLI script |
| `src/app/api/ai/chat/route.ts` | Chat endpoint (uses index) |

---

## Future Enhancements

1. **Git Webhook Integration**: Auto-regenerate on push
2. **Incremental Updates**: Only re-index changed files
3. **Cross-Project Search**: Query indexes from multiple repos
4. **Embedding Fallback**: Semantic search when keywords fail
5. **Chat UI Component**: User-facing chat interface

---

## Related Documentation

- [AI_CONTEXT_MANAGEMENT.md](AI_CONTEXT_MANAGEMENT.md) - Keyword routing & compaction
- [AI_PIPELINE_TIERS.md](AI_PIPELINE_TIERS.md) - Multi-provider strategy

---

**Last Updated**: January 2, 2026
**Author**: Claude Code
