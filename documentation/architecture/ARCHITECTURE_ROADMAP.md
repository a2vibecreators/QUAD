# QUAD Framework - Architecture & Roadmap

## Document Purpose

This document captures all architectural decisions, gap analysis, and roadmap for QUAD Framework. It ensures continuity across development sessions and serves as the source of truth for what's built, what's planned, and what's missing.

**Last Updated:** January 2, 2026
**Author:** Claude Code + Development Team

---

## Table of Contents

1. [Current State Summary](#current-state-summary)
2. [What We Built (Session Jan 2, 2026)](#what-we-built-session-jan-2-2026)
3. [Architecture Decisions](#architecture-decisions)
4. [Gap Analysis](#gap-analysis)
5. [Enterprise Features](#enterprise-features)
6. [AI System Design](#ai-system-design)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Sandbox/Preview Environments](#sandboxpreview-environments)
9. [BYOC (Bring Your Own Cloud)](#byoc-bring-your-own-cloud)
10. [Cost Analysis](#cost-analysis)
11. [Priority Roadmap](#priority-roadmap)
12. [Competitive Analysis](#competitive-analysis)

---

## Current State Summary

### Codebase Metrics

| Category | Count | Status |
|----------|-------|--------|
| **Database Tables** | 97 models | Solid foundation |
| **API Routes** | 98 endpoints | Good coverage |
| **Components** | ~18 core | Needs expansion |
| **Lib/Services** | 31 files | Well-structured |

### Technology Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Next.js 14, React, TypeScript, Tailwind CSS |
| **Backend** | Next.js API Routes, Prisma ORM |
| **Database** | PostgreSQL (Cloud SQL) |
| **Auth** | NextAuth.js with JWT |
| **Deployment** | GCP Cloud Run, Docker |
| **CI/CD** | GitHub Actions |

---

## What We Built (Session Jan 2, 2026)

### 1. Codebase Indexer System

**Purpose:** Reduce AI context tokens by 95% (from ~50,000 to ~5,000 tokens)

**Files Created:**
- `scripts/generate-codebase-index.ts` - CLI script to generate index
- `src/lib/ai/codebase-indexer.ts` - Index retrieval and formatting
- `documentation/CODEBASE_INDEX_SYSTEM.md` - Full documentation

**How It Works:**
```
Full Codebase (58,262 LOC) → Indexer → Compact Summary (5,593 tokens)
                                          ↓
                               Tables, APIs, Components, Patterns
                                          ↓
                               AI receives summary, not full code
```

**Usage:**
```bash
DATABASE_URL="postgresql://..." npx tsx scripts/generate-codebase-index.ts \
  "<org_id>" "/path/to/repo" "repo_name"
```

**Results:**
- 202 files indexed
- 93 tables found
- 170 API routes documented
- 95% token savings

### 2. AI Conversation System

**Purpose:** Per-ticket AI chat with persistence, activity-based routing, cross-project RAG

**Schema Added:**
```prisma
model QUAD_ai_conversations {
  id              String   @id @default(uuid())
  org_id          String
  user_id         String
  scope_type      String   // ticket, domain, general, code_review
  scope_id        String?  // ticket ID if scoped
  title           String?
  status          String   @default("active")
  total_messages  Int      @default(0)
  total_tokens_used Int    @default(0)
  primary_provider String?
}

model QUAD_ai_messages {
  id              String   @id @default(uuid())
  conversation_id String
  role            String   // user, assistant, system
  content         String
  tokens_used     Int
  provider        String?
  model_id        String?
  latency_ms      Int?
  needs_more_info Boolean  @default(false)
  requested_context String?
  embedding       Json?    // For RAG search
  suggestion_type String?
  suggestion_data Json?
  suggestion_status String?
}

model QUAD_ai_user_memories {
  id              String   @id @default(uuid())
  user_id         String
  org_id          String
  memory_type     String   // decision, preference, context
  summary         String
  keywords        String[]
  source_conversation_id String?
  source_ticket_id String?
  source_domain_id String?
  embedding       Json?
  discussed_at    DateTime
}

model QUAD_ai_activity_routing {
  id              String   @id @default(uuid())
  org_id          String
  activity_type   String   // ticket_question, code_review, story_split
  provider        String   // claude, openai, gemini
  model_id        String   // claude-3-sonnet, gpt-4, etc.
  max_tokens_input Int
  temperature     Decimal
  use_codebase_index Boolean
  require_approval Boolean
  is_active       Boolean
}
```

**Files Created:**
- `src/app/api/ai/ticket-chat/route.ts` - Ticket-scoped chat API
- `src/components/ai/TicketAIChat.tsx` - React chat component

**Key Design Decisions:**
- **Ticket chat = Saved** (per-ticket history in database)
- **General chat = Not saved** (ephemeral, privacy)
- **Activity routing** = Different AI providers for different tasks
- **RAG** = Cross-project memory for user preferences

### 3. CI/CD Pipeline

**Files Created:**
- `.github/workflows/ci.yml` - PR validation
- `.github/workflows/deploy-dev.yml` - Deploy to Cloud Run
- `.github/workflows/preview.yml` - Sandbox per PR

**CI Pipeline (ci.yml):**
```yaml
Steps:
1. Checkout code
2. Setup Node.js 20
3. Install dependencies (npm ci)
4. Generate Prisma client
5. Validate Prisma schema
6. TypeScript check
7. ESLint
8. Build
```

**Deploy Pipeline (deploy-dev.yml):**
```yaml
Trigger: Push to dev branch
Steps:
1. Build Docker image
2. Push to GCR
3. Deploy to Cloud Run
4. Run database migrations
5. Smoke test
```

### 4. Enterprise Sandbox System

**Purpose:** Per-PR preview environments with layered architecture

**Key Insight:** UI developers don't need their own database - they point to shared DEV.

**Sandbox Types:**
| Type | What Spins Up | Database | Use Case |
|------|---------------|----------|----------|
| `ui-only` | Next.js container | → Shared DEV DB | UI developer work |
| `api-only` | API container | → Shared DEV DB | Backend work |
| `full-stack` | UI + API | → Shared DEV DB | Integration testing |
| `isolated` | UI + API + DB | Own database | Breaking changes (rare) |

**Workflow:**
```
Schema PR (DBA reviews) → Merged first → DEV DB updated
         ↓
API PR → Sandbox points to DEV DB
         ↓
UI PR → Sandbox points to DEV API + DB
```

**Auto-Detection:**
- PR changes `src/components/*` → ui-only
- PR changes `src/app/api/*` → api-only
- PR changes both → full-stack
- PR has label `sandbox:isolated` → isolated

### 5. Local Development Setup

**Files Created:**
- `scripts/setup-local.sh` - One-command local setup
- `scripts/validate-build.sh` - Pre-PR validation

**setup-local.sh does:**
1. Check prerequisites (Node, Docker, Git)
2. Create PostgreSQL container
3. Run Prisma migrations
4. Seed database
5. Create .env.local

**validate-build.sh does:**
1. Prisma validate
2. TypeScript check
3. ESLint
4. Build

---

## Architecture Decisions

### ADR-001: Token Optimization via Codebase Index

**Context:** AI calls with full codebase context cost ~$0.25/question (85K tokens)

**Decision:** Pre-index codebase into compact summary (~5K tokens)

**Consequences:**
- 95% cost reduction
- Faster responses
- Need to regenerate index when code changes
- May miss context not in index

### ADR-002: Per-Ticket vs General AI Chat Storage

**Context:** Should we save all AI conversations?

**Decision:**
- Ticket-scoped chat → Saved to database (audit, continuity)
- General search/chat → Not saved (privacy, ephemeral)

**Consequences:**
- Clear data retention policy
- Ticket history available for handoffs
- General queries don't pollute storage

### ADR-003: Activity-Based AI Routing

**Context:** Different tasks need different AI models (cost vs quality)

**Decision:** Route by activity type:
| Activity | Provider | Model | Why |
|----------|----------|-------|-----|
| ticket_question | claude | sonnet | Fast, cheap |
| code_review | claude | opus | Quality matters |
| story_split | openai | gpt-4 | Good at structure |
| simple_lookup | openai | gpt-3.5 | Cheapest |

**Consequences:**
- Cost optimization
- Quality where it matters
- Complexity in routing logic

### ADR-004: Layered Sandbox Architecture

**Context:** Enterprise customers have huge databases - can't spin up per PR

**Decision:** Sandboxes point to shared DEV database by default

**Consequences:**
- Near-zero sandbox cost
- Database changes must merge first
- UI/API work is independent
- Isolated mode available for breaking changes

### ADR-005: BYOC (Bring Your Own Cloud)

**Context:** Enterprise customers want to deploy to their own cloud

**Decision:** Support customer-provided GCP service account keys

**Consequences:**
- Customer pays cloud bill directly
- We deploy to their project
- Need secure key storage (vault)
- More complex onboarding

---

## Gap Analysis

### By Category

#### 1. AI Integration - 40% Complete

| Component | Status | Gap |
|-----------|--------|-----|
| Token optimization | ✅ Done | - |
| Conversation storage | ✅ Schema | Mock responses only |
| Activity routing | ✅ Schema | No routing logic |
| BYOK keys | ✅ Schema | No encryption |
| **Real AI calls** | ❌ Missing | No Claude/OpenAI SDK |
| **Streaming** | ❌ Missing | No SSE |

#### 2. Authentication - 60% Complete

| Component | Status | Gap |
|-----------|--------|-----|
| NextAuth | ✅ Done | Basic only |
| JWT tokens | ✅ Done | - |
| **Google OAuth** | ⚠️ Config ready | No credentials |
| **SSO/SAML** | ❌ Missing | Enterprise need |
| **MFA** | ❌ Missing | Security need |
| **API keys** | ❌ Missing | CI/CD integration |

#### 3. Real-time - 10% Complete

| Component | Status | Gap |
|-----------|--------|-----|
| **WebSockets** | ❌ Missing | No live updates |
| **Notifications** | ❌ Missing | No push/email |
| **Webhooks** | ❌ Missing | No GitHub events |

#### 4. Integrations - 20% Complete

| Integration | Status | Gap |
|-------------|--------|-----|
| **GitHub** | ⚠️ Planned | No webhooks |
| **Slack** | ❌ Missing | No notifications |
| **Jira** | ❌ Missing | No migration tool |
| **VS Code** | ❌ Missing | No extension |

#### 5. UI/UX - 30% Complete

| Component | Status | Gap |
|-----------|--------|-----|
| Dashboard | ✅ Done | Basic |
| CRUD pages | ✅ Done | - |
| **Kanban board** | ❌ Missing | Core feature |
| **Gantt chart** | ❌ Missing | Cycle planning |
| **Charts** | ❌ Missing | Burndown, velocity |

#### 6. Billing - 5% Complete

| Component | Status | Gap |
|-----------|--------|-----|
| Org model | ✅ Done | - |
| **Stripe** | ❌ Missing | No payments |
| **Usage metering** | ❌ Missing | AI tokens |
| **Quotas** | ❌ Missing | Rate limiting |

---

## Enterprise Features

### BYOC (Bring Your Own Cloud) Architecture

```
Customer Flow:
1. Sign up on QUAD website
2. Choose "Managed" plan
3. Create GCP project (or use existing)
4. Create service account with roles:
   - roles/run.admin
   - roles/cloudsql.client
   - roles/storage.admin
   - roles/secretmanager.admin
5. Download JSON key
6. Upload to QUAD settings
7. We deploy QUAD to their GCP
8. They get: quad.their-domain.com
```

**Schema for BYOC:**
```prisma
model QUAD_org_cloud_configs {
  id                String   @id @default(uuid())
  org_id            String   @unique
  cloud_provider    String   // gcp, aws, azure
  gcp_project_id    String?
  gcp_sa_key_ref    String?  // Vault reference
  gcp_region        String?
  cloud_run_url     String?
  cloud_sql_instance String?
  setup_status      String   @default("pending")
  last_deployed_at  DateTime?
}
```

### Multi-Tenancy Isolation Levels

| Level | Isolation | Cost | Use Case |
|-------|-----------|------|----------|
| **Shared** | Same DB, schema separation | Lowest | Startups |
| **Schema** | Same DB, separate schemas | Low | SMB |
| **Database** | Separate DB per tenant | Medium | Enterprise |
| **Project** | Separate GCP project | Highest | Regulated |

---

## AI System Design

### Token Flow

```
User Question
     ↓
Keyword Matching → Find relevant categories
     ↓
Load Codebase Index (~5K tokens)
     ↓
Load Matched Schema (~500 tokens)
     ↓
Compact Conversation History (~1K tokens)
     ↓
Total Context: ~6.5K tokens (vs 85K without optimization)
     ↓
Call AI Provider (routed by activity type)
     ↓
Save Response (if ticket-scoped)
```

### Activity Routing Table

| Activity Type | Default Provider | Default Model | Max Tokens | Temperature |
|---------------|------------------|---------------|------------|-------------|
| ticket_question | claude | claude-3-sonnet | 4000 | 0.7 |
| code_review | claude | claude-3-opus | 8000 | 0.3 |
| story_split | openai | gpt-4 | 4000 | 0.5 |
| bug_analysis | claude | claude-3-sonnet | 4000 | 0.3 |
| documentation | openai | gpt-4 | 4000 | 0.7 |
| simple_lookup | openai | gpt-3.5-turbo | 1000 | 0.0 |

### RAG (Retrieval Augmented Generation)

**User Memory System:**
```
User asks about tickets → Check QUAD_ai_user_memories
     ↓
Find relevant past discussions (embedding similarity)
     ↓
Include summary in AI context
     ↓
"Last time we discussed login feature, you preferred OAuth..."
```

**Cross-Project but Not Cross-Org:**
- User memories span all projects they work on
- Never leak to other organizations
- Enables: "What did we decide about X?"

---

## CI/CD Pipeline

### Workflow Overview

```
Developer pushes code
         ↓
    ┌────┴────┐
    │  ci.yml │ ← Runs on every PR
    └────┬────┘
         ↓
    Validate → TypeCheck → Lint → Build
         ↓
    ┌─────────────────┐
    │   preview.yml   │ ← Creates sandbox
    └────────┬────────┘
             ↓
    Deploy preview environment
    Comment on PR with URL
         ↓
    PR Merged to dev
         ↓
    ┌─────────────────┐
    │  deploy-dev.yml │ ← Deploy to DEV
    └────────┬────────┘
             ↓
    Build → Push to GCR → Deploy Cloud Run
         ↓
    PR Merged to main
         ↓
    ┌─────────────────┐
    │ deploy-prod.yml │ ← Deploy to PROD (TODO)
    └─────────────────┘
```

### GitHub Secrets Required

| Secret | Purpose |
|--------|---------|
| `GCP_SA_KEY` | Service account JSON for deployment |
| `GCP_PROJECT_ID` | GCP project ID |
| `DB_PASSWORD` | Database password |
| `DB_HOST` | Database host IP |
| `DEV_DATABASE_URL` | Full dev database connection string |
| `NEXTAUTH_SECRET` | NextAuth encryption key |

---

## Sandbox/Preview Environments

### Cost Analysis

| Resource | Regular DEV | Sandbox (10 PRs) |
|----------|-------------|------------------|
| Cloud Run | $55/month | $2-6/month |
| Database | Shared | Shared (no extra) |
| **Total Extra** | - | +$2-6/month |

### Why Sandboxes Are Cheap

1. **Scale to zero** - No traffic = no charge
2. **Shared DEV database** - No Cloud SQL per PR
3. **Auto-cleanup** - Resources deleted on PR close

### PR Comment Example

```markdown
## 🚀 Preview Environment

| Property | Value |
|----------|-------|
| **Preview URL** | https://quad-preview-pr-123.run.app |
| **Sandbox Type** | 🎨 `ui-only` |
| **Database** | 🔗 Shared DEV database |
| **PR** | #123 |
| **Commit** | `abc1234` |
```

---

## Cost Analysis

### Cloud Run Pricing

| Component | Price | Monthly (always on) | Monthly (scale to zero) |
|-----------|-------|---------------------|-------------------------|
| CPU | $0.00002400/vCPU-sec | ~$52 | ~$2 |
| Memory | $0.00000250/GB-sec | ~$3 | ~$0.10 |
| Requests | $0.40/million | ~$0.40 | ~$0.04 |

### AI Token Costs

| Provider | Model | Input | Output |
|----------|-------|-------|--------|
| Claude | Sonnet | $3/M tokens | $15/M tokens |
| Claude | Opus | $15/M tokens | $75/M tokens |
| OpenAI | GPT-4 | $30/M tokens | $60/M tokens |
| OpenAI | GPT-3.5 | $0.50/M tokens | $1.50/M tokens |

### Token Optimization Savings

| Without Index | With Index | Savings |
|---------------|------------|---------|
| 85,000 tokens/question | 6,500 tokens/question | 92% |
| ~$0.25/question | ~$0.02/question | 92% |
| $250/1000 questions | $20/1000 questions | $230 saved |

---

## Priority Roadmap

### P0 - Critical (This Week)

| Task | Impact | Effort |
|------|--------|--------|
| Connect real Claude API | Core value prop | 4 hours |
| Add Kanban board UI | Basic usability | 8 hours |

### P1 - High (This Month)

| Task | Impact | Effort |
|------|--------|--------|
| GitHub webhook integration | Dev workflow | 8 hours |
| Email notifications | User engagement | 4 hours |
| Stripe billing | Monetization | 16 hours |
| SSO/SAML | Enterprise sales | 8 hours |

### P2 - Medium (This Quarter)

| Task | Impact | Effort |
|------|--------|--------|
| VS Code extension | Developer UX | 24 hours |
| Slack integration | Team adoption | 8 hours |
| Burndown/Velocity charts | Scrum compliance | 16 hours |
| Multi-region deployment | Enterprise scale | 16 hours |

### P3 - Nice to Have

| Task | Impact | Effort |
|------|--------|--------|
| Mobile app | User reach | 40+ hours |
| CLI tool (`quad`) | Power users | 16 hours |
| Jira migration tool | Customer acquisition | 24 hours |

---

## Competitive Analysis

### Feature Comparison

| Feature | QUAD | Jira | Linear | Notion |
|---------|------|------|--------|--------|
| AI-native | ✅ Core | ⚠️ Add-on | ⚠️ Basic | ✅ Good |
| Developer UX | ⚠️ Building | ❌ Poor | ✅ Great | ⚠️ OK |
| Kanban | ❌ Missing | ✅ Yes | ✅ Yes | ✅ Yes |
| Sprint planning | ⚠️ Basic | ✅ Full | ✅ Cycles | ⚠️ Manual |
| GitHub integration | ⚠️ Planned | ✅ Yes | ✅ Yes | ⚠️ Basic |
| Self-host option | ✅ Yes | ❌ No | ❌ No | ❌ No |
| BYOK AI | ✅ Yes | ❌ No | ❌ No | ❌ No |

### QUAD Differentiators

1. **BYOK AI** - Customers use their own API keys (unique in market)
2. **Self-hosted enterprise** - Deploy to customer's cloud
3. **AI-first design** - Not bolted on like competitors
4. **Codebase awareness** - Token-optimized context
5. **Activity routing** - Right AI for each task

---

## Files Reference

### Created This Session

| File | Purpose |
|------|---------|
| `scripts/generate-codebase-index.ts` | CLI to generate index |
| `scripts/setup-local.sh` | Local dev setup |
| `scripts/validate-build.sh` | Pre-PR validation |
| `src/lib/ai/codebase-indexer.ts` | Index retrieval |
| `src/app/api/ai/ticket-chat/route.ts` | Ticket chat API |
| `src/components/ai/TicketAIChat.tsx` | Chat component |
| `.github/workflows/ci.yml` | CI pipeline |
| `.github/workflows/deploy-dev.yml` | Deploy pipeline |
| `.github/workflows/preview.yml` | Sandbox pipeline |
| `documentation/CODEBASE_INDEX_SYSTEM.md` | Index docs |
| `documentation/DEV_AGENT_WORKFLOW.md` | Agent workflow docs |
| `documentation/QUAD_ARCHITECTURE_ROADMAP.md` | This file |

### Key Existing Files

| File | Purpose |
|------|---------|
| `prisma/schema.prisma` | All 97 database models |
| `src/lib/authOptions.ts` | NextAuth configuration |
| `src/lib/ai/context-categories.ts` | Keyword routing |
| `src/app/api/ai/chat/route.ts` | General AI chat |

---

## Commits This Session

```
f169895 feat: Add codebase indexer for AI context optimization
bf04812 feat: Add AI conversation system with per-ticket chat and RAG
9534826 feat: Add CI/CD workflows and Dev Agent infrastructure
7404a4d feat: Enterprise-ready sandbox with layered architecture
```

---

## Next Session Checklist

When resuming development:

1. [ ] Read this document for context
2. [ ] Check `prisma/schema.prisma` for latest models
3. [ ] Check `.github/workflows/` for CI/CD status
4. [ ] Review gap analysis above
5. [ ] Pick from priority roadmap

---

**Document Version:** 1.0
**Created:** January 2, 2026
**Next Review:** After implementing P0 items
