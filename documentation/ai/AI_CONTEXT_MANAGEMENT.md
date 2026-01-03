# QUAD Framework - AI Context Management

## Overview

QUAD uses a **smart context routing system** to minimize token usage while maintaining response quality. Instead of sending all schema definitions to the AI for every request, we route questions to only the relevant context.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AI CONTEXT MANAGEMENT PIPELINE                            │
└─────────────────────────────────────────────────────────────────────────────┘

User Question: "How do I create a ticket?"
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: KEYWORD MATCHING                                                   │
│                                                                              │
│  Match keywords in question to categories:                                   │
│  "ticket" → tickets category                                                 │
│  "create" → context includes ticket schema + creation docs                   │
│                                                                              │
│  Result: Load ONLY ticket-related schema (~200 tokens)                       │
│          NOT all 15 tables (~3000 tokens)                                    │
└─────────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  CONVERSATION COMPACTION                                                     │
│                                                                              │
│  If conversation is long (>5 messages):                                      │
│  • Keep last 5 messages verbatim (recent context)                            │
│  • Summarize older messages into 1 paragraph                                 │
│                                                                              │
│  Token savings: ~89% reduction on long conversations                         │
└─────────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  BUILD CONTEXT STRING                                                        │
│                                                                              │
│  System Prompt = QUAD methodology + matched schema + summary                 │
│                                                                              │
│  ~850 tokens instead of ~8000 tokens per request                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Context Categories

QUAD defines 12 context categories, each with:
- **Keywords**: Words that trigger this category
- **Tables**: Database schema to include
- **Docs**: Documentation references
- **Description**: Human-readable description

### Category Definitions

| Category | Keywords | Tables |
|----------|----------|--------|
| **auth** | oauth, login, logout, signup, password, token, session, jwt | QUAD_users, QUAD_sessions, QUAD_email_verification_codes |
| **organizations** | organization, org, company, team, workspace, tenant | QUAD_organizations, QUAD_users, QUAD_org_members |
| **domains** | domain, project, product, initiative | QUAD_domains, QUAD_domain_members |
| **flows** | flow, workflow, process, pipeline, stage | QUAD_flows, QUAD_flow_stages |
| **circles** | circle, squad, team, group, pod | QUAD_circles, QUAD_circle_members |
| **tickets** | ticket, task, issue, bug, feature, story, epic, backlog | QUAD_tickets, QUAD_ticket_comments, QUAD_ticket_attachments |
| **cycles** | cycle, sprint, iteration, release, milestone, roadmap | QUAD_cycles, QUAD_cycle_tickets |
| **ai** | ai, llm, gpt, claude, gemini, openai, anthropic, byok, api key | QUAD_ai_configs, QUAD_byok_keys |
| **git** | git, github, gitlab, repository, pull request, pr, merge, branch | QUAD_git_integrations, QUAD_pull_requests |
| **meetings** | meeting, calendar, schedule, standup, sync, google meet, zoom | QUAD_meetings, QUAD_meeting_integrations |
| **roles** | role, permission, access, admin, owner, developer, manager | QUAD_roles, QUAD_core_roles, QUAD_users |
| **setup** | setup, onboarding, getting started, configure, install | QUAD_org_setup_status |

---

## Implementation Files

### Core Files

| File | Purpose |
|------|---------|
| `src/lib/ai/context-categories.ts` | Category definitions, keyword matching, compaction |
| `src/app/api/ai/chat/route.ts` | AI chat endpoint with context routing |

### Key Functions

```typescript
// Match question to categories
matchCategories("How do I create a ticket?")
// Returns: ['tickets']

// Get context for categories
getCategoryContext(['tickets'])
// Returns: { tables: ['QUAD_tickets', ...], docs: ['QUAD_METHODOLOGY.md#tickets'], ... }

// Full routing
routeToContext("How do I assign a ticket to a circle?")
// Returns: {
//   categories: ['tickets', 'circles'],
//   tables: ['QUAD_tickets', 'QUAD_circles', 'QUAD_circle_members'],
//   docs: [...],
//   shouldUseFallback: false
// }

// Compact conversation
compactConversation(messages, 5)
// Returns: {
//   summary: "Previous conversation about...",
//   recentMessages: [...last 5 messages...],
//   messagesSummarized: 10,
//   estimatedTokensSaved: 1500
// }
```

---

## API Endpoint

### POST /api/ai/chat

**Request:**
```json
{
  "message": "How do I create a ticket?",
  "conversationHistory": [
    { "role": "user", "content": "previous message" },
    { "role": "assistant", "content": "previous response" }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "To create a ticket, use POST /api/tickets...",
    "context": {
      "categories": ["tickets"],
      "tables": ["QUAD_tickets"],
      "tokensSaved": 1500,
      "usedFallback": false
    },
    "usage": {
      "promptTokens": 850,
      "completionTokens": 100,
      "totalTokens": 950
    }
  }
}
```

---

## Token Savings Analysis

### Before (No Context Routing)

| Component | Tokens |
|-----------|--------|
| Full schema (15 tables) | ~3000 |
| Full conversation (20 messages) | ~4000 |
| System prompt | ~500 |
| User message | ~50 |
| **Total per request** | **~7550** |

### After (With Context Routing)

| Component | Tokens |
|-----------|--------|
| Matched schema (1-3 tables) | ~200-600 |
| Compacted conversation | ~400 |
| System prompt | ~200 |
| User message | ~50 |
| **Total per request** | **~850-1250** |

### Savings
- **Per request**: ~89% reduction (7550 → 850)
- **At scale (1000 requests/day)**: 6.7M tokens saved/day
- **Cost savings**: ~$20/day at Claude Sonnet pricing

---

## Phase 2: Embeddings Fallback (Planned)

When keyword matching returns no results, the system will fall back to semantic search:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: EMBEDDINGS FALLBACK (Future)                                       │
│                                                                              │
│  If matchCategories() returns empty:                                         │
│  1. Generate embedding for question using OpenAI/Anthropic API               │
│  2. Query QUAD_document_chunks with vector similarity (pgvector)             │
│  3. Return top-K most similar document chunks                                │
│  4. Use those chunks as context for AI response                              │
│                                                                              │
│  Requires:                                                                   │
│  • pgvector extension in PostgreSQL                                          │
│  • QUAD_document_chunks table with embedding column                          │
│  • Embedding API (OpenAI text-embedding-3-small or similar)                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## BYOK (Bring Your Own Key) Support

Organizations can configure their own AI API keys:

| Field | Description |
|-------|-------------|
| `anthropic_key_ref` | Vault reference to Anthropic API key |
| `openai_key_ref` | Vault reference to OpenAI API key |
| `gemini_key_ref` | Vault reference to Google Gemini API key |

The chat endpoint checks for custom keys and uses them if available:

```typescript
const aiConfig = await prisma.qUAD_ai_configs.findUnique({
  where: { org_id: user.companyId },
});

const hasCustomKeys = !!(aiConfig?.anthropic_key_ref || aiConfig?.openai_key_ref);
```

---

## Testing

### Test Context Routing

```bash
curl -X POST http://localhost:3000/api/ai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "message": "How do I create a ticket with high priority?",
    "conversationHistory": []
  }'
```

Expected: Response includes `context.categories: ["tickets"]`

### Test Compaction

```bash
curl -X POST http://localhost:3000/api/ai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "message": "What about the due date?",
    "conversationHistory": [
      {"role": "user", "content": "I want to create a ticket"},
      {"role": "assistant", "content": "Here is how..."},
      {"role": "user", "content": "What fields are required?"},
      {"role": "assistant", "content": "Title and description..."},
      {"role": "user", "content": "How about priority?"},
      {"role": "assistant", "content": "Priority can be low, medium, high..."}
    ]
  }'
```

Expected: Response includes `context.tokensSaved > 0`

---

## Related Documentation

- [AI_PIPELINE_TIERS.md](AI_PIPELINE_TIERS.md) - Multi-provider AI strategy
- [AI_PRICING_TIERS.md](AI_PRICING_TIERS.md) - Pricing and cost analysis
- [MULTI_PROVIDER_AI_STRATEGY.md](MULTI_PROVIDER_AI_STRATEGY.md) - Provider selection

---

## Last Updated

- **Date**: January 2, 2026
- **Author**: Claude Code
- **Changes**: Initial documentation for AI context management system
