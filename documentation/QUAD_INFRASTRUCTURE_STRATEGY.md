# QUAD Framework - Infrastructure Strategy

## Overview

QUAD provides a flexible infrastructure model where organizations choose their preferred strategies for sandboxes, codebase indexing, and code caching. All options are available with different cost/performance tradeoffs.

---

## Architecture Principles

### Separation of Concerns

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QUAD MULTI-TENANT ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────┐     ┌─────────────────────────────────────┐
│      QUAD DATABASE              │     │       CLIENT DATABASE               │
│      (QUAD's GCP)               │     │       (Client's GCP/AWS - BYOK)     │
├─────────────────────────────────┤     ├─────────────────────────────────────┤
│                                 │     │                                     │
│  Platform Data:                 │     │  Business Data:                     │
│  • QUAD_organizations           │     │  • users, orders, products          │
│  • QUAD_users                   │     │  • payments, subscriptions          │
│  • QUAD_user_skills             │     │  • ... (client's 200+ tables)       │
│  • QUAD_learning_paths          │     │                                     │
│  • QUAD_tickets                 │     │  This is THEIR data,                │
│  • QUAD_codebase_index          │     │  in THEIR cloud account.            │
│  • ... (150 QUAD tables)        │     │                                     │
│                                 │     │                                     │
└─────────────────────────────────┘     └─────────────────────────────────────┘
           │                                           │
           └───────────────────┬───────────────────────┘
                               │
                               ▼
                  ┌─────────────────────────┐
                  │   QUAD Orchestration    │
                  │   Layer                 │
                  └─────────────────────────┘
```

### BYOK (Bring Your Own Key) Model

| Component | Provider | Who Pays |
|-----------|----------|----------|
| QUAD Platform | QUAD's GCP | Included in subscription |
| Client Database | Client's GCP/AWS | Client pays directly |
| Sandbox Pods | Client's GCP/AWS | Client pays directly |
| AI API Keys | Client's keys (or QUAD pooled) | Client or QUAD markup |
| Code Storage Cache | QUAD's storage | Tiered pricing |

---

## Section 1: Sandbox Strategies

### Three Strategies (Org-Level Configuration)

Organizations choose ONE strategy that applies to all their projects:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SANDBOX STRATEGY SELECTION                                │
│                                                                              │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────────┐   │
│  │   🎯 DEDICATED    │  │   👥 SHARED       │  │   ⚡ ON-DEMAND        │   │
│  │                   │  │   (DEFAULT)       │  │                       │   │
│  ├───────────────────┤  ├───────────────────┤  ├───────────────────────┤   │
│  │ One sandbox per   │  │ Pool of sandboxes │  │ Spin up on request    │   │
│  │ ticket            │  │ shared by team    │  │ Auto-terminate idle   │   │
│  │                   │  │                   │  │                       │   │
│  │ Always available  │  │ Check-out model   │  │ 30-60s cold start     │   │
│  │                   │  │                   │  │                       │   │
│  │ ~$0.50-2/ticket   │  │ ~$50/mo for team  │  │ ~$0.01-0.05/hour      │   │
│  │ /day              │  │ of 10             │  │                       │   │
│  └───────────────────┘  └───────────────────┘  └───────────────────────┘   │
│                                                                              │
│  Configuration: QUAD_infrastructure_config.sandbox_strategy                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Strategy A: DEDICATED (Per-Ticket Sandbox)

**Best for:** Enterprise teams, critical projects, compliance requirements

```
Ticket Created (QUAD-123)
         │
         ▼
┌─────────────────────────────────────────┐
│  1. QUAD detects new ticket             │
│  2. Spins up dedicated pods:            │
│     - quad-123-api (Cloud Run/Fargate)  │
│     - quad-123-ui (Cloud Run/Fargate)   │
│  3. Connects to client's DEV database   │
│  4. Developer gets unique URL           │
│     https://quad-123.sandbox.client.com │
└─────────────────────────────────────────┘
         │
         ▼
PR Merged / Ticket Closed
         │
         ▼
┌─────────────────────────────────────────┐
│  5. QUAD detects ticket resolved        │
│  6. Terminates sandbox pods             │
│  7. Releases resources                  │
└─────────────────────────────────────────┘
```

**Ticket Grouping Optimization:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TICKET GROUPING FOR DEDICATED SANDBOXES                   │
│                                                                              │
│  Related tickets can share a sandbox to reduce costs:                        │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Epic: "Payment System Overhaul"                                    │    │
│  │  ├── QUAD-123: Add retry logic                                      │    │
│  │  ├── QUAD-124: Add webhook handling                                 │    │
│  │  ├── QUAD-125: Add refund support                                   │    │
│  │  └── QUAD-126: Add payment analytics                                │    │
│  │                                                                     │    │
│  │  SUGGESTED: Group into 1 sandbox (all touch payment code)           │    │
│  │  Cost: $2/day instead of $8/day (4 separate sandboxes)              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Grouping Rules:                                                             │
│  • Same epic/feature                                                         │
│  • Same developer                                                            │
│  • Same domain (overlapping file paths)                                      │
│  • User-defined grouping                                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Cost Estimate:**
| Team Size | Avg Active Tickets | Daily Cost | Monthly Cost |
|-----------|-------------------|------------|--------------|
| 5 devs | 5 tickets | $2.50-10 | $50-200 |
| 10 devs | 10 tickets | $5-20 | $100-400 |
| 25 devs | 20 tickets | $10-40 | $200-800 |

---

### Strategy B: SHARED (Pool-Based) - DEFAULT

**Best for:** Most teams, good balance of cost and availability

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SHARED SANDBOX POOL                                    │
│                                                                              │
│  Pool Size: ceil(team_size / 3)  (e.g., 10 devs = 4 sandboxes)              │
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Sandbox-1   │  │ Sandbox-2   │  │ Sandbox-3   │  │ Sandbox-4   │        │
│  │ ──────────  │  │ ──────────  │  │ ──────────  │  │ ──────────  │        │
│  │ QUAD-123    │  │ QUAD-456    │  │ (Available) │  │ QUAD-789    │        │
│  │ Dev: John   │  │ Dev: Jane   │  │             │  │ Dev: Bob    │        │
│  │ Since: 2h   │  │ Since: 30m  │  │             │  │ Since: 4h   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│         │                │                │                │                │
│         └────────────────┴────────────────┴────────────────┘                │
│                                   │                                          │
│                                   ▼                                          │
│                    ┌─────────────────────────────┐                          │
│                    │   Client's DEV Database     │                          │
│                    └─────────────────────────────┘                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Allocation Rules:**

| Event | Action |
|-------|--------|
| Developer starts work on ticket | Check out available sandbox |
| 2 hours of inactivity | Auto-release sandbox |
| All sandboxes busy | Queue (notify when available) |
| Work hours end (configurable) | Scale pool down to 1 |
| Work hours start | Scale pool up to full size |

**Cost Estimate:**
| Team Size | Pool Size | Monthly Cost |
|-----------|-----------|--------------|
| 5 devs | 2 sandboxes | $30-50 |
| 10 devs | 4 sandboxes | $50-80 |
| 25 devs | 9 sandboxes | $100-180 |

---

### Strategy C: ON-DEMAND (Serverless)

**Best for:** Cost-conscious teams, async work, remote teams across timezones

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ON-DEMAND SANDBOX LIFECYCLE                              │
│                                                                              │
│  Developer clicks "Start Sandbox"                                            │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────────────────────────────┐                                │
│  │  "Spinning up your sandbox..."          │                                │
│  │  ████████████░░░░░░░░  45 seconds       │                                │
│  └─────────────────────────────────────────┘                                │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────────────────────────────┐                                │
│  │  ✅ Sandbox Ready!                       │                                │
│  │  https://temp-abc123.sandbox.client.com │                                │
│  │                                         │                                │
│  │  Auto-terminates in: 30 min idle        │                                │
│  └─────────────────────────────────────────┘                                │
│           │                                                                  │
│           ├── Activity detected ──► Reset idle timer                        │
│           │                                                                  │
│           ▼ (30 min no activity)                                            │
│  ┌─────────────────────────────────────────┐                                │
│  │  💤 Sandbox terminated (cost stops)      │                                │
│  │                                         │                                │
│  │  [Restart Sandbox]                      │                                │
│  └─────────────────────────────────────────┘                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Technology:** Cloud Run (GCP) or Fargate Spot (AWS) - true serverless

**Cost Estimate:**
| Usage Pattern | Hours/Dev/Day | Monthly Cost (10 devs) |
|---------------|---------------|------------------------|
| Light (2h/day) | 2h | $8-15 |
| Medium (4h/day) | 4h | $15-30 |
| Heavy (8h/day) | 8h | $30-60 |

---

## Section 2: Codebase Indexing Strategies

### Three Depth Levels (Org-Level Configuration)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CODEBASE INDEXING DEPTH                                   │
│                                                                              │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────────┐   │
│  │   📄 MINIMAL      │  │   📊 BALANCED     │  │   🔬 DEEP             │   │
│  │                   │  │   (DEFAULT)       │  │                       │   │
│  ├───────────────────┤  ├───────────────────┤  ├───────────────────────┤   │
│  │ File names only   │  │ + Function sigs   │  │ + Full AST parsing    │   │
│  │ + Basic keywords  │  │ + AI summaries    │  │ + Dependency graph    │   │
│  │                   │  │ + Schema refs     │  │ + Call hierarchy      │   │
│  │                   │  │                   │  │ + Type analysis       │   │
│  │ Storage: ~1KB/    │  │ Storage: ~5KB/    │  │ Storage: ~20KB/       │   │
│  │ file              │  │ file              │  │ file                  │   │
│  │                   │  │                   │  │                       │   │
│  │ Free with plan    │  │ +$5/mo per        │  │ +$15/mo per           │   │
│  │                   │  │ 10K files         │  │ 10K files             │   │
│  └───────────────────┘  └───────────────────┘  └───────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Level 1: MINIMAL (File Names + Keywords)

**What's Indexed:**
```json
{
  "file_path": "src/services/PaymentService.java",
  "keywords": ["payment", "stripe", "charge", "refund"],
  "file_type": "java",
  "last_modified": "2026-01-03T10:00:00Z",
  "line_count": 450
}
```

**Use Case:** Basic file discovery, simple keyword search
**Storage:** ~1KB per file
**Cost:** Included in subscription

---

### Level 2: BALANCED (+ Signatures + Summaries) - DEFAULT

**What's Indexed:**
```json
{
  "file_path": "src/services/PaymentService.java",
  "keywords": ["payment", "stripe", "charge", "refund", "webhook"],
  "file_type": "java",
  "last_modified": "2026-01-03T10:00:00Z",
  "line_count": 450,

  "functions": [
    { "name": "chargeCard", "params": ["amount", "customerId"], "returns": "PaymentResult" },
    { "name": "processRefund", "params": ["paymentId", "reason"], "returns": "RefundResult" },
    { "name": "handleWebhook", "params": ["event"], "returns": "void" }
  ],

  "schema_refs": ["payments", "refunds", "payment_logs"],

  "summary": "Handles Stripe payment processing including charges, refunds, and webhook events. Uses idempotency keys for retry safety. Integrates with PaymentRepository for persistence.",

  "imports": ["com.stripe.Stripe", "com.company.repository.PaymentRepository"],

  "token_estimate": 1200
}
```

**Use Case:** Intelligent context retrieval, AI-assisted search
**Storage:** ~5KB per file
**Cost:** +$5/month per 10K files

---

### Level 3: DEEP (+ AST + Dependencies + Call Graph)

**What's Indexed:**
```json
{
  "file_path": "src/services/PaymentService.java",
  "...": "...all from BALANCED...",

  "ast": {
    "class": "PaymentService",
    "extends": "BaseService",
    "implements": ["PaymentProcessor", "WebhookHandler"],
    "fields": [
      { "name": "stripeClient", "type": "StripeClient", "visibility": "private" },
      { "name": "repository", "type": "PaymentRepository", "visibility": "private" }
    ],
    "methods": [
      {
        "name": "chargeCard",
        "visibility": "public",
        "params": [
          { "name": "amount", "type": "BigDecimal" },
          { "name": "customerId", "type": "String" }
        ],
        "returns": "PaymentResult",
        "throws": ["PaymentException", "CustomerNotFoundException"],
        "annotations": ["@Transactional", "@Retryable"]
      }
    ]
  },

  "dependencies": {
    "calls": ["PaymentRepository.save", "StripeClient.charge", "EventPublisher.publish"],
    "called_by": ["CheckoutController.processPayment", "SubscriptionService.renewSubscription"]
  },

  "complexity": {
    "cyclomatic": 12,
    "lines_of_code": 450,
    "test_coverage": 85
  }
}
```

**Use Case:** Architecture analysis, refactoring, security audits
**Storage:** ~20KB per file
**Cost:** +$15/month per 10K files

---

### GitHub Integration (NOT Full Checkout)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     GITHUB INDEXING WORKFLOW                                 │
│                                                                              │
│  Single Source of Truth: GitHub                                              │
│  QUAD stores: INDEX ONLY (not full code)                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

Initial Setup:
──────────────
1. Client connects GitHub repo (OAuth)
2. QUAD requests read-only access
3. Background job starts indexing:

   For each file:
   ┌─────────────────────────────────────────────────────────────────┐
   │  a. Fetch file content via GitHub API                          │
   │  b. Extract: keywords, functions, schema refs                  │
   │  c. Generate AI summary (if BALANCED or DEEP)                  │
   │  d. Store INDEX in QUAD_codebase_index                         │
   │  e. DISCARD full file content                                  │
   └─────────────────────────────────────────────────────────────────┘

Incremental Updates:
────────────────────
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  GitHub Webhook │────►│  QUAD Indexer   │────►│  Update Index   │
│  (push event)   │     │  (changed only) │     │  (incremental)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## Section 3: Code Cache / Storage Tiers

### Storage Pricing Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CODE CACHE STORAGE TIERS                                  │
│                                                                              │
│  When AI needs actual code, we fetch from GitHub.                            │
│  To avoid repeated fetches, we cache recently accessed files.                │
│                                                                              │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────────┐   │
│  │   💾 BASIC        │  │   📦 STANDARD     │  │   🚀 PREMIUM          │   │
│  │   (DEFAULT)       │  │                   │  │                       │   │
│  ├───────────────────┤  ├───────────────────┤  ├───────────────────────┤   │
│  │ 256 MB cache      │  │ 1 GB cache        │  │ 5 GB cache            │   │
│  │                   │  │                   │  │                       │   │
│  │ LRU eviction      │  │ LRU eviction      │  │ Smart eviction        │   │
│  │                   │  │                   │  │ (keep hot files)      │   │
│  │ 1 hour TTL        │  │ 24 hour TTL       │  │ 7 day TTL             │   │
│  │                   │  │                   │  │                       │   │
│  │ Included          │  │ +$2/mo            │  │ +$8/mo                │   │
│  └───────────────────┘  └───────────────────┘  └───────────────────────┘   │
│                                                                              │
│  Custom Storage: $1/GB/month (any size you want)                            │
│                                                                              │
│  Compare: Apple iCloud 2TB = $10/mo                                          │
│           QUAD 1GB cache = $2/mo (you probably need <<1GB)                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Cache Behavior

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CODE CACHE WORKFLOW                                   │
│                                                                              │
│  AI needs PaymentService.java                                                │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────────────────────────────┐                                │
│  │  Check QUAD_code_cache                  │                                │
│  └─────────────────────────────────────────┘                                │
│           │                                                                  │
│     ┌─────┴─────┐                                                           │
│     │           │                                                           │
│     ▼           ▼                                                           │
│  CACHE HIT   CACHE MISS                                                     │
│     │           │                                                           │
│     │           ▼                                                           │
│     │  ┌─────────────────────────────────────────┐                          │
│     │  │  1. Fetch from GitHub API               │                          │
│     │  │  2. Store in cache (with TTL)           │                          │
│     │  │  3. Update access_count for analytics   │                          │
│     │  └─────────────────────────────────────────┘                          │
│     │           │                                                           │
│     └───────────┴───────────────────┐                                       │
│                                     │                                       │
│                                     ▼                                       │
│                        Return file content to AI                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

Cache Eviction (when storage full):
───────────────────────────────────
BASIC:    Simple LRU (least recently used)
STANDARD: LRU with frequency weighting
PREMIUM:  Smart eviction - keeps:
          • Frequently accessed files
          • Files in active tickets
          • Core architecture files (manually pinned)
```

---

## Section 4: Configuration Schema

### Database Tables

```sql
-- Organization-level infrastructure configuration
CREATE TABLE QUAD_infrastructure_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  -- Sandbox Strategy
  sandbox_strategy VARCHAR(20) DEFAULT 'shared',  -- 'dedicated', 'shared', 'on_demand'
  sandbox_pool_size INT DEFAULT 0,                 -- 0 = auto-calculate
  sandbox_idle_timeout_minutes INT DEFAULT 120,    -- For shared/on_demand
  sandbox_work_hours_start TIME DEFAULT '09:00',
  sandbox_work_hours_end TIME DEFAULT '18:00',
  sandbox_work_hours_timezone VARCHAR(50) DEFAULT 'America/New_York',

  -- Indexing Strategy
  indexing_depth VARCHAR(20) DEFAULT 'balanced',  -- 'minimal', 'balanced', 'deep'
  indexing_auto_update BOOLEAN DEFAULT true,       -- Update on webhook
  indexing_schedule VARCHAR(20) DEFAULT 'realtime', -- 'realtime', 'hourly', 'daily'

  -- Cache Strategy
  cache_tier VARCHAR(20) DEFAULT 'basic',         -- 'basic', 'standard', 'premium', 'custom'
  cache_size_mb INT DEFAULT 256,                   -- For custom tier
  cache_ttl_hours INT DEFAULT 1,                   -- Default TTL

  -- Cloud Provider (BYOK)
  cloud_provider VARCHAR(20) DEFAULT 'gcp',       -- 'gcp', 'aws', 'azure'
  cloud_project_id VARCHAR(255),                   -- GCP project or AWS account
  cloud_region VARCHAR(50),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sandbox instances tracking
CREATE TABLE QUAD_sandbox_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  instance_name VARCHAR(100) NOT NULL,
  strategy VARCHAR(20) NOT NULL,                   -- 'dedicated', 'shared', 'on_demand'
  status VARCHAR(20) DEFAULT 'provisioning',       -- 'provisioning', 'running', 'idle', 'terminated'

  -- Assignment
  assigned_user_id UUID REFERENCES QUAD_users(id),
  assigned_ticket_ids UUID[],                       -- Can serve multiple tickets (grouping)

  -- URLs
  api_url VARCHAR(500),
  ui_url VARCHAR(500),

  -- Lifecycle
  started_at TIMESTAMPTZ DEFAULT NOW(),
  last_activity_at TIMESTAMPTZ DEFAULT NOW(),
  terminated_at TIMESTAMPTZ,

  -- Cost tracking
  compute_seconds INT DEFAULT 0,
  estimated_cost_usd DECIMAL(10,4) DEFAULT 0,

  -- Cloud resources
  cloud_resource_ids JSONB                          -- {"api_service": "...", "ui_service": "..."}
);

-- Ticket to sandbox grouping
CREATE TABLE QUAD_ticket_sandbox_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  group_name VARCHAR(200),
  ticket_ids UUID[] NOT NULL,
  sandbox_instance_id UUID REFERENCES QUAD_sandbox_instances(id),

  -- Auto-grouping metadata
  grouping_reason VARCHAR(50),                      -- 'same_epic', 'same_developer', 'same_domain', 'manual'
  suggested_by_ai BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Codebase index (stores INDEX only, not full code)
CREATE TABLE QUAD_codebase_index (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES QUAD_projects(id),

  file_path VARCHAR(1000) NOT NULL,
  file_type VARCHAR(20),

  -- MINIMAL level
  keywords TEXT[],
  line_count INT,
  last_modified TIMESTAMPTZ,
  github_sha VARCHAR(40),

  -- BALANCED level (nullable for MINIMAL)
  functions JSONB,                                  -- [{name, params, returns}]
  schema_refs TEXT[],
  summary TEXT,
  imports TEXT[],
  token_estimate INT,

  -- DEEP level (nullable for MINIMAL/BALANCED)
  ast JSONB,
  dependencies JSONB,
  complexity JSONB,

  -- Metadata
  indexing_depth VARCHAR(20) NOT NULL,
  indexed_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(project_id, file_path)
);

-- Code cache (stores actual file content temporarily)
CREATE TABLE QUAD_code_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),
  project_id UUID NOT NULL REFERENCES QUAD_projects(id),

  file_path VARCHAR(1000) NOT NULL,
  content TEXT NOT NULL,
  content_size_bytes INT NOT NULL,
  github_sha VARCHAR(40),

  -- Cache metadata
  cached_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  access_count INT DEFAULT 1,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),

  -- Pinning (for PREMIUM tier)
  is_pinned BOOLEAN DEFAULT false,
  pinned_by UUID REFERENCES QUAD_users(id),
  pin_reason VARCHAR(200),

  UNIQUE(project_id, file_path)
);

-- Cache storage usage tracking
CREATE TABLE QUAD_cache_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES QUAD_organizations(id),

  date DATE NOT NULL,
  tier VARCHAR(20) NOT NULL,

  storage_used_mb DECIMAL(10,2),
  storage_limit_mb DECIMAL(10,2),

  cache_hits INT DEFAULT 0,
  cache_misses INT DEFAULT 0,
  github_api_calls INT DEFAULT 0,

  cost_usd DECIMAL(10,4) DEFAULT 0,

  UNIQUE(org_id, date)
);
```

---

## Section 5: Cost Comparison

### Monthly Cost Examples (10 Developer Team)

| Configuration | Sandbox | Indexing | Cache | Total/Month |
|---------------|---------|----------|-------|-------------|
| **Budget** | On-Demand | Minimal | Basic (256MB) | ~$25 |
| **Balanced** | Shared Pool | Balanced | Standard (1GB) | ~$90 |
| **Premium** | Dedicated | Deep | Premium (5GB) | ~$250 |

### vs. Traditional Approaches

| Approach | Monthly Cost | QUAD Savings |
|----------|--------------|--------------|
| Always-on staging per dev | $500+ | 80-95% |
| Full codebase in every prompt | $200+ AI tokens | 95%+ |
| Manual context gathering | 10+ hours/dev/month | 90%+ |

---

## Section 6: Implementation Roadmap

### Phase 1: Core Infrastructure (This Sprint)
- [ ] Add configuration tables to schema
- [ ] Implement SandboxService with 3 strategies
- [ ] Implement CodebaseIndexer with 3 depths
- [ ] Implement CodeCacheService with 3 tiers
- [ ] Create configuration API endpoints

### Phase 2: Cloud Integration
- [ ] GCP Cloud Run integration for sandboxes
- [ ] AWS Fargate integration for sandboxes
- [ ] GitHub App for webhook integration
- [ ] OAuth flow for GitHub repository access

### Phase 3: Intelligence
- [ ] AI-suggested ticket grouping
- [ ] Smart cache eviction (usage patterns)
- [ ] Auto-scaling sandbox pools
- [ ] Cost optimization recommendations

---

*Last Updated: January 3, 2026*
*QUAD Framework - A2Vibe Creators LLC*
