# QUAD Framework - AI Agent Architecture

**Created:** January 3, 2026
**Purpose:** Document how QUAD's agentic AI works across multiple providers (like Cursor) with 80% cost savings

---

## 🎯 Core Design Principle: AI-Agnostic Architecture

**QUAD is fundamentally AI-agnostic.** This means:

- **No vendor lock-in**: Switch between Claude, Gemini, OpenAI, DeepSeek without code changes
- **Same-session switching**: One conversation can use multiple providers (Haiku for simple, Gemini for medium, Opus for complex)
- **Unified interface**: All providers implement the same `AIProvider` interface
- **Provider-transparent responses**: UI doesn't know which provider generated the response
- **Intelligent routing**: System automatically picks the best provider for each task

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Request Flow (Step by Step)](#3-request-flow-step-by-step)
4. [Context Optimization (80% Savings)](#4-context-optimization-80-savings)
5. [Model Routing Algorithm](#5-model-routing-algorithm)
6. [Same-Session Provider Switching](#6-same-session-provider-switching)
7. [Provider Integration](#7-provider-integration)
8. [Code Diff Generation & Application](#8-code-diff-generation--application)
9. [Code Diff Sufficiency Analysis](#9-code-diff-sufficiency-analysis)
10. [Multi-File Refactoring](#10-multi-file-refactoring)
11. [Confidence Assessment: Browser-Based IDE](#11-confidence-assessment-browser-based-ide)
12. [Database Tables Used](#12-database-tables-used)
13. [API Contracts](#13-api-contracts)
14. [Comparison with Cursor](#14-comparison-with-cursor)

---

## 1. Executive Summary

QUAD Framework implements an **AI-agnostic agentic system** that:
- Works across **4+ AI providers** (Claude, Gemini, OpenAI, DeepSeek, and extensible)
- **Dynamically routes** each request to the optimal model - even within the same session
- Uses **codebase indexing** to reduce context by 80-90%
- Produces **provider-independent structured code diffs** that work regardless of which AI generated them
- Creates **pull requests** automatically with proper commits

**AI-Agnostic by Design:**
```
Session Example:
  Message 1: "What files handle orders?" → Gemini Flash (fast, cheap) ✓
  Message 2: "Add preferredDeliveryTime" → Claude Sonnet (code gen) ✓
  Message 3: "Refactor order architecture" → Claude Opus (complex) ✓

Same conversation, 3 different providers/models, seamless experience.
```

**Key Differentiator from Cursor:**
- Cursor = IDE extension (runs locally)
- QUAD = Browser-based platform (runs in cloud)
- QUAD = **AI-agnostic** multi-model routing (automatic provider switching per message)
- QUAD = Ticket-integrated (linked to project management)

---

## 1.1 Complete End-to-End Example: Ticket to Closure

This section provides a **detailed walkthrough** of a single ticket from creation to closure, showing **exact context sent at each AI call** with token counts.

### The Ticket

```
Organization: A2Vibe Creators (from seed data)
Project: NutriNine
Domain: nutrinine-services (Backend)
User: suman@a2vibecreators.com

TICKET: "Add preferredDeliveryTime to Order entity with default logic"
```

### Step-by-Step with Exact Context

---

#### STEP 1: Ticket Created (No AI Call Yet)

**User Action:** Creates ticket in QUAD UI

**Database Insert:**
```sql
INSERT INTO QUAD_tickets (
    id, ticket_number, title, description, ticket_type,
    priority, status, org_id, domain_id, created_by
) VALUES (
    'uuid-ticket-001',
    'NN-42',
    'Add preferredDeliveryTime to Order entity',
    'Add a new attribute preferredDeliveryTime (LocalTime) to the Order entity.
     Default to 09:00 for EXPRESS, 14:00 for STANDARD.
     Update DTO, Service, and REST endpoint.',
    'story',
    'high',
    'backlog',
    'uuid-a2vibe-org',        -- A2Vibe Creators
    'uuid-nutrinine-services', -- nutrinine-services domain
    'uuid-suman-user'
);
```

**AI Tokens Used:** 0 (no AI call)

---

#### STEP 2: User Clicks "Analyze with AI"

**API Call:**
```
POST /api/ai/dev-agent/analyze
Authorization: Bearer <jwt>
Content-Type: application/json

{
    "ticket_id": "uuid-ticket-001",
    "action": "analyze_and_expand"
}
```

**Backend Processing - Context Building:**

```java
// 1. Load ticket from database
Ticket ticket = ticketRepo.findById(ticketId);

// 2. Load codebase index (cached) - ~4,500 tokens
CodebaseIndex index = indexService.getByDomain(ticket.getDomainId());

// 3. Load agent rules - ~800 tokens
String agentRules = configService.getAgentRules(ticket.getOrgId());

// 4. Build system prompt - ~300 tokens
String systemPrompt = """
    You are a QUAD Developer Agent for the nutrinine-services codebase.
    Analyze the ticket and break it into implementable subtasks.
    Return JSON with subtasks array.
    """;
```

**EXACT CONTEXT SENT TO AI PROVIDER:**

```json
{
    "model": "gemini-1.5-pro",
    "messages": [
        {
            "role": "system",
            "content": "You are a QUAD Developer Agent for the nutrinine-services codebase.\n\nCODEBASE CONTEXT:\n================\n\n## Database Tables (24 tables)\n- orders: Customer orders (id, user_id, status, delivery_type, created_at)\n- order_items: Line items (id, order_id, product_id, quantity, price)\n- users: User accounts (id, email, name, created_at)\n- products: Product catalog (id, name, price, category)\n... [20 more tables summarized]\n\n## API Endpoints (18 endpoints)\n- POST /api/orders: Create new order\n- GET /api/orders/{id}: Get order by ID\n- PUT /api/orders/{id}/status: Update order status\n- GET /api/orders/user/{userId}: List user orders\n... [14 more endpoints]\n\n## Key Files\n- Order.java: JPA entity with @Entity, fields: id, userId, status, deliveryType, items, createdAt\n- OrderDTO.java: Response DTO with same fields as entity\n- OrderService.java: Business logic - createOrder(), updateStatus(), getById()\n- OrderController.java: REST controller, maps to /api/orders\n- OrderRepository.java: JpaRepository interface\n\n## Patterns Used\n- Framework: Spring Boot 3.2, Java 21\n- ORM: Spring Data JPA with PostgreSQL\n- Mapping: ModelMapper for entity<->DTO\n- Validation: Jakarta Bean Validation\n- Testing: JUnit 5, Mockito\n\nAGENT RULES:\n============\n- Always create Flyway migration for DB changes\n- Entity changes require DTO sync\n- Service methods need unit tests\n- Follow existing naming conventions"
        },
        {
            "role": "user",
            "content": "TICKET NN-42:\nTitle: Add preferredDeliveryTime to Order entity\n\nDescription:\nAdd a new attribute preferredDeliveryTime (LocalTime) to the Order entity.\nDefault to 09:00 for EXPRESS, 14:00 for STANDARD.\nUpdate DTO, Service, and REST endpoint.\n\nPriority: high\nType: story\n\n---\n\nAnalyze this ticket and break it into implementable subtasks.\nReturn JSON format:\n{\n  \"analysis\": {\n    \"complexity\": \"simple|medium|complex\",\n    \"estimated_hours\": number,\n    \"affected_layers\": [\"database\", \"entity\", \"dto\", \"service\", \"controller\", \"test\"]\n  },\n  \"subtasks\": [\n    {\n      \"title\": \"subtask title\",\n      \"description\": \"what to do\",\n      \"layer\": \"which layer\",\n      \"suggested_files\": [\"file paths\"],\n      \"order\": 1\n    }\n  ]\n}"
        }
    ],
    "max_tokens": 2000,
    "temperature": 0.2
}
```

**TOKEN COUNT (Step 2):**
| Component | Tokens |
|-----------|--------|
| System prompt + codebase index | ~4,500 |
| Agent rules | ~800 |
| Ticket content | ~150 |
| Output format instructions | ~200 |
| **Total Input** | **~5,650** |
| **Output (response)** | ~800 |
| **Model Used** | Gemini 1.5 Pro |
| **Cost** | ~$0.008 |

**AI RESPONSE:**

```json
{
    "analysis": {
        "complexity": "medium",
        "estimated_hours": 4,
        "affected_layers": ["database", "entity", "dto", "service", "test"]
    },
    "subtasks": [
        {
            "title": "Create Flyway migration V42",
            "description": "Add preferred_delivery_time column to orders table",
            "layer": "database",
            "suggested_files": ["src/main/resources/db/migration/V42__add_preferred_delivery_time.sql"],
            "order": 1
        },
        {
            "title": "Update Order.java entity",
            "description": "Add preferredDeliveryTime field with @Column annotation",
            "layer": "entity",
            "suggested_files": ["src/main/java/com/nutrinine/entity/Order.java"],
            "order": 2
        },
        {
            "title": "Update OrderDTO.java",
            "description": "Add preferredDeliveryTime field to DTO",
            "layer": "dto",
            "suggested_files": ["src/main/java/com/nutrinine/dto/OrderDTO.java"],
            "order": 3
        },
        {
            "title": "Update OrderService.java",
            "description": "Add default time logic in createOrder method",
            "layer": "service",
            "suggested_files": ["src/main/java/com/nutrinine/service/OrderService.java"],
            "order": 4
        },
        {
            "title": "Add unit tests",
            "description": "Test default time logic for EXPRESS and STANDARD",
            "layer": "test",
            "suggested_files": ["src/test/java/com/nutrinine/service/OrderServiceTest.java"],
            "order": 5
        }
    ]
}
```

**Database Updates:**
```sql
-- Create 5 subtasks
INSERT INTO QUAD_tickets (id, ticket_number, parent_id, title, ...) VALUES
    ('uuid-subtask-1', 'NN-42-1', 'uuid-ticket-001', 'Create Flyway migration V42', ...),
    ('uuid-subtask-2', 'NN-42-2', 'uuid-ticket-001', 'Update Order.java entity', ...),
    ('uuid-subtask-3', 'NN-42-3', 'uuid-ticket-001', 'Update OrderDTO.java', ...),
    ('uuid-subtask-4', 'NN-42-4', 'uuid-ticket-001', 'Update OrderService.java', ...),
    ('uuid-subtask-5', 'NN-42-5', 'uuid-ticket-001', 'Add unit tests', ...);

-- Log AI operation
INSERT INTO QUAD_ai_operations (
    id, org_id, ticket_id, operation_type, model_used, provider,
    input_tokens, output_tokens, cost_usd, duration_ms
) VALUES (
    'uuid-op-1', 'uuid-a2vibe-org', 'uuid-ticket-001', 'analyze',
    'gemini-1.5-pro', 'gemini', 5650, 800, 0.008, 2340
);
```

---

#### STEP 3: User Clicks "Implement" on Subtask 1 (Migration)

**API Call:**
```
POST /api/ai/dev-agent/implement
{
    "ticket_id": "uuid-subtask-1",
    "action": "generate_code"
}
```

**CONTEXT SENT (Subtask 1 - Migration):**

```json
{
    "model": "claude-3-5-sonnet-20241022",
    "messages": [
        {
            "role": "system",
            "content": "You are a QUAD Developer Agent generating code for nutrinine-services.\n\nCODEBASE CONTEXT:\n[Same ~4,500 token index as before]\n\nCURRENT TASK:\nSubtask: Create Flyway migration V42\nParent Ticket: Add preferredDeliveryTime to Order entity\n\nEXISTING MIGRATIONS:\n- V41__add_order_status_history.sql (latest)\n\nRULES:\n- Use Flyway naming: V{number}__{description}.sql\n- Include rollback comment\n- Use PostgreSQL syntax"
        },
        {
            "role": "user",
            "content": "Generate the Flyway migration file to add preferred_delivery_time column.\n\nRequirements:\n- Column: preferred_delivery_time (TIME type)\n- Nullable (for existing orders)\n- Set default for existing orders based on delivery_type\n\nReturn JSON:\n{\n  \"files\": [{\n    \"path\": \"relative/path\",\n    \"action\": \"CREATE\",\n    \"content\": \"file content\",\n    \"language\": \"sql\"\n  }],\n  \"explanation\": \"what this does\",\n  \"validation_steps\": [\"how to verify\"]\n}"
        }
    ],
    "max_tokens": 1500,
    "temperature": 0.1
}
```

**TOKEN COUNT (Step 3):**
| Component | Tokens |
|-----------|--------|
| Codebase index | ~4,500 |
| Task context | ~200 |
| Parent ticket context | ~100 |
| Output format | ~150 |
| **Total Input** | **~4,950** |
| **Output** | ~400 |
| **Model Used** | Claude 3.5 Sonnet |
| **Cost** | ~$0.017 |

**Why Claude Sonnet?** Code generation task = MEDIUM complexity = Sonnet (not Haiku, not Opus)

**AI RESPONSE:**

```json
{
    "files": [
        {
            "path": "src/main/resources/db/migration/V42__add_preferred_delivery_time.sql",
            "action": "CREATE",
            "content": "-- V42: Add preferred_delivery_time to orders table\n-- Rollback: ALTER TABLE orders DROP COLUMN preferred_delivery_time;\n\nALTER TABLE orders ADD COLUMN preferred_delivery_time TIME;\n\n-- Set defaults for existing orders based on delivery_type\nUPDATE orders SET preferred_delivery_time = CASE\n    WHEN delivery_type = 'EXPRESS' THEN '09:00:00'::TIME\n    WHEN delivery_type = 'STANDARD' THEN '14:00:00'::TIME\n    ELSE '12:00:00'::TIME\nEND\nWHERE preferred_delivery_time IS NULL;",
            "language": "sql"
        }
    ],
    "explanation": "Created Flyway migration to add preferred_delivery_time column with intelligent defaults based on existing delivery_type values.",
    "validation_steps": [
        "Run: mvn flyway:migrate",
        "Verify: SELECT preferred_delivery_time FROM orders LIMIT 5;",
        "Check EXPRESS orders have 09:00, STANDARD have 14:00"
    ]
}
```

**Database Updates:**
```sql
-- Save suggestion
INSERT INTO QUAD_ai_messages (
    id, conversation_id, role, content,
    suggestion_type, suggestion_data, suggestion_status
) VALUES (
    'uuid-msg-1', 'uuid-conv-1', 'assistant', 'Generated migration...',
    'code_diff', '{"files":[...]}', 'pending'
);

-- Log operation
INSERT INTO QUAD_ai_operations (...) VALUES (...);
```

---

#### STEP 4: User Approves Subtask 1 → Git Operations

**API Call:**
```
POST /api/ai/dev-agent/approve
{
    "message_id": "uuid-msg-1",
    "create_branch": true,
    "create_pr": false
}
```

**Backend Processing (No AI Call - Pure Git):**

```java
// 1. Parse diff from QUAD_ai_messages
CodeDiff diff = parseFromMessage(messageId);

// 2. Create branch via GitHub API
POST https://api.github.com/repos/a2vibecreators/nutrinine-services/git/refs
{
    "ref": "refs/heads/feature/NN-42-1-add-delivery-time-migration",
    "sha": "abc123..."  // main branch HEAD
}

// 3. Create file via GitHub API
PUT https://api.github.com/repos/a2vibecreators/nutrinine-services/contents/src/main/resources/db/migration/V42__add_preferred_delivery_time.sql
{
    "message": "NN-42-1: Add preferred_delivery_time migration\n\n🤖 Generated by QUAD AI Agent",
    "content": "base64-encoded-file-content",
    "branch": "feature/NN-42-1-add-delivery-time-migration"
}

// 4. Update ticket status
UPDATE QUAD_tickets SET status = 'in_progress' WHERE id = 'uuid-subtask-1';
```

**AI Tokens Used:** 0 (Git operations only)

---

#### STEP 5: Implement Subtask 2 (Entity Update)

**Context Difference:** Now we need the EXISTING file content

**API Call:**
```
POST /api/ai/dev-agent/implement
{
    "ticket_id": "uuid-subtask-2"
}
```

**Backend - Fetch Current File:**
```java
// Fetch current Order.java from GitHub (or cache)
String currentContent = githubService.getFileContent(
    "a2vibecreators/nutrinine-services",
    "src/main/java/com/nutrinine/entity/Order.java",
    "main"
);
// Result: 145 lines, ~2,800 tokens
```

**CONTEXT SENT (Subtask 2 - Entity):**

```json
{
    "model": "claude-3-5-sonnet-20241022",
    "messages": [
        {
            "role": "system",
            "content": "You are a QUAD Developer Agent.\n\nCODEBASE CONTEXT:\n[~4,500 tokens - same index]\n\nCURRENT FILE (Order.java):\n```java\npackage com.nutrinine.entity;\n\nimport jakarta.persistence.*;\nimport lombok.*;\nimport java.time.LocalDateTime;\nimport java.util.List;\nimport java.util.UUID;\n\n@Entity\n@Table(name = \"orders\")\n@Data\n@NoArgsConstructor\n@AllArgsConstructor\n@Builder\npublic class Order {\n\n    @Id\n    @GeneratedValue(strategy = GenerationType.UUID)\n    private UUID id;\n\n    @Column(name = \"user_id\", nullable = false)\n    private UUID userId;\n\n    @Enumerated(EnumType.STRING)\n    @Column(name = \"delivery_type\")\n    private DeliveryType deliveryType;\n\n    @Enumerated(EnumType.STRING)\n    private OrderStatus status;\n\n    @OneToMany(mappedBy = \"order\", cascade = CascadeType.ALL)\n    private List<OrderItem> items;\n\n    @Column(name = \"created_at\")\n    private LocalDateTime createdAt;\n\n    @Column(name = \"updated_at\")\n    private LocalDateTime updatedAt;\n\n    @PrePersist\n    protected void onCreate() {\n        createdAt = LocalDateTime.now();\n    }\n\n    @PreUpdate\n    protected void onUpdate() {\n        updatedAt = LocalDateTime.now();\n    }\n}\n```\n\nTASK: Add preferredDeliveryTime field"
        },
        {
            "role": "user",
            "content": "Modify Order.java to add:\n- preferredDeliveryTime field (LocalTime)\n- @Column annotation mapping to preferred_delivery_time\n\nReturn MODIFY action with hunks showing exact line changes."
        }
    ]
}
```

**TOKEN COUNT (Step 5):**
| Component | Tokens |
|-----------|--------|
| Codebase index | ~4,500 |
| Current file content | ~800 |
| Task instructions | ~150 |
| **Total Input** | **~5,450** |
| **Output** | ~350 |
| **Model Used** | Claude 3.5 Sonnet |
| **Cost** | ~$0.019 |

**AI RESPONSE:**

```json
{
    "files": [
        {
            "path": "src/main/java/com/nutrinine/entity/Order.java",
            "action": "MODIFY",
            "hunks": [
                {
                    "startLine": 4,
                    "endLine": 4,
                    "oldContent": "import java.time.LocalDateTime;",
                    "newContent": "import java.time.LocalDateTime;\nimport java.time.LocalTime;"
                },
                {
                    "startLine": 27,
                    "endLine": 27,
                    "oldContent": "    private DeliveryType deliveryType;",
                    "newContent": "    private DeliveryType deliveryType;\n\n    @Column(name = \"preferred_delivery_time\")\n    private LocalTime preferredDeliveryTime;"
                }
            ],
            "language": "java"
        }
    ],
    "explanation": "Added LocalTime import and preferredDeliveryTime field with JPA column mapping.",
    "validation_steps": ["Compile: mvn compile", "Verify field appears in entity"]
}
```

---

#### STEP 6-8: Implement Remaining Subtasks

Each follows the same pattern. Token counts:

| Subtask | File(s) Modified | Input Tokens | Output Tokens | Model | Cost |
|---------|------------------|--------------|---------------|-------|------|
| NN-42-3 (DTO) | OrderDTO.java | ~5,100 | ~250 | Sonnet | $0.017 |
| NN-42-4 (Service) | OrderService.java | ~5,800 | ~450 | Sonnet | $0.020 |
| NN-42-5 (Tests) | OrderServiceTest.java | ~6,200 | ~600 | Sonnet | $0.023 |

---

#### STEP 9: Create PR (All Subtasks Complete)

**API Call:**
```
POST /api/ai/dev-agent/create-pr
{
    "ticket_id": "uuid-ticket-001",
    "include_subtasks": true
}
```

**Backend Processing:**

```java
// 1. Collect all branches from subtasks
List<String> branches = List.of(
    "feature/NN-42-1-add-delivery-time-migration",
    "feature/NN-42-2-order-entity-update",
    "feature/NN-42-3-order-dto-update",
    "feature/NN-42-4-order-service-logic",
    "feature/NN-42-5-unit-tests"
);

// 2. Merge into single feature branch
String targetBranch = "feature/NN-42-preferred-delivery-time";
// Git operations to merge all...

// 3. Generate PR description with AI (SIMPLE task = Gemini Flash)
```

**CONTEXT SENT (PR Generation):**

```json
{
    "model": "gemini-1.5-flash",
    "messages": [
        {
            "role": "user",
            "content": "Generate a PR description for:\n\nTicket: NN-42 - Add preferredDeliveryTime to Order entity\n\nChanges:\n- V42__add_preferred_delivery_time.sql (CREATE)\n- Order.java (MODIFY - added field)\n- OrderDTO.java (MODIFY - added field)\n- OrderService.java (MODIFY - default logic)\n- OrderServiceTest.java (MODIFY - new tests)\n\nFormat:\n## Summary\n## Changes\n## Testing\n## Checklist"
        }
    ]
}
```

**TOKEN COUNT (Step 9):**
| Component | Tokens |
|-----------|--------|
| PR context | ~400 |
| **Total Input** | **~400** |
| **Output** | ~300 |
| **Model Used** | Gemini Flash (cheap, simple task) |
| **Cost** | ~$0.0003 |

**Create PR via GitHub API:**
```
POST https://api.github.com/repos/a2vibecreators/nutrinine-services/pulls
{
    "title": "NN-42: Add preferredDeliveryTime to Order entity",
    "body": "## Summary\nAdds preferred delivery time...\n\n## Changes\n- Migration V42...\n\n🤖 Generated by QUAD AI Agent",
    "head": "feature/NN-42-preferred-delivery-time",
    "base": "main"
}
```

---

#### STEP 10: Ticket Closed

**Database Updates:**
```sql
-- Update ticket status
UPDATE QUAD_tickets SET status = 'done', completed_at = NOW()
WHERE id = 'uuid-ticket-001';

-- Update all subtasks
UPDATE QUAD_tickets SET status = 'done', completed_at = NOW()
WHERE parent_id = 'uuid-ticket-001';

-- Link PR to ticket
INSERT INTO QUAD_pull_requests (id, ticket_id, pr_number, pr_url, status)
VALUES ('uuid-pr-1', 'uuid-ticket-001', 42, 'https://github.com/.../pull/42', 'open');
```

---

### Total AI Cost Summary for NN-42

| Step | Action | Model | Provider | Input Tokens | Output Tokens | Cost |
|------|--------|-------|----------|--------------|---------------|------|
| 2 | Analyze ticket | gemini-1.5-pro | Gemini | 5,650 | 800 | $0.008 |
| 3 | Implement migration | claude-3-5-sonnet | Claude | 4,950 | 400 | $0.017 |
| 5 | Implement entity | claude-3-5-sonnet | Claude | 5,450 | 350 | $0.019 |
| 6 | Implement DTO | claude-3-5-sonnet | Claude | 5,100 | 250 | $0.017 |
| 7 | Implement service | claude-3-5-sonnet | Claude | 5,800 | 450 | $0.020 |
| 8 | Implement tests | claude-3-5-sonnet | Claude | 6,200 | 600 | $0.023 |
| 9 | Generate PR desc | gemini-1.5-flash | Gemini | 400 | 300 | $0.0003 |
| **TOTAL** | | | | **33,550** | **3,150** | **$0.104** |

### Comparison: With vs Without Optimization

| Metric | Without Index | With QUAD Index | Savings |
|--------|---------------|-----------------|---------|
| Tokens per call | ~45,000 (full files) | ~5,500 (index) | 88% |
| 7 calls total | 315,000 tokens | 38,500 tokens | 88% |
| Cost (all Sonnet) | ~$1.05 | ~$0.13 | 88% |
| Cost (smart routing) | ~$1.05 | **$0.10** | **90%** |

### Key Takeaways

1. **Codebase index = 88% token savings** (5K vs 45K per call)
2. **Smart routing = additional 20% savings** (Gemini for simple, Sonnet for code)
3. **7 AI calls** to complete a medium-complexity ticket
4. **Total cost: $0.10** (vs $1.05 without optimization)
5. **Same session used 3 different models** from 2 providers

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QUAD AI AGENT SYSTEM                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         USER INTERFACE                               │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │   │
│  │  │ Ticket  │  │ Chat    │  │ Code    │  │ PR      │  │ Editor  │  │   │
│  │  │ Board   │  │ Panel   │  │ Review  │  │ View    │  │ (Monaco)│  │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      API GATEWAY (/api/ai/*)                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │   │
│  │  │ /analyze    │  │ /implement  │  │ /review     │                 │   │
│  │  │ (Story)     │  │ (Code Gen)  │  │ (PR Review) │                 │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        AI SERVICE LAYER                              │   │
│  │                                                                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │   │
│  │  │ Context     │  │ Model       │  │ Response    │                 │   │
│  │  │ Builder     │  │ Router      │  │ Parser      │                 │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                 │   │
│  │         │                │                │                          │   │
│  │         ▼                ▼                ▼                          │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    PROVIDER ABSTRACTION                      │   │   │
│  │  │                                                               │   │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │   │   │
│  │  │  │ Claude   │  │ Gemini   │  │ OpenAI   │  │ DeepSeek │    │   │   │
│  │  │  │ Provider │  │ Provider │  │ Provider │  │ Provider │    │   │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │   │   │
│  │  │       │             │             │             │           │   │   │
│  │  │       └─────────────┴─────────────┴─────────────┘           │   │   │
│  │  │                           │                                  │   │   │
│  │  └───────────────────────────┼──────────────────────────────────┘   │   │
│  └──────────────────────────────┼──────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      EXTERNAL AI PROVIDERS                           │   │
│  │                                                                       │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │ api.anthropic│  │ api.google   │  │ api.openai   │              │   │
│  │  │   .com       │  │   .com       │  │   .com       │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Request Flow (Step by Step)

### Complete Flow: Ticket → Code → PR

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 1: USER CREATES TICKET                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User: "Add preferredDeliveryTime to Order page"                            │
│                                                                              │
│  POST /api/tickets                                                          │
│  {                                                                          │
│    "title": "Add preferredDeliveryTime to Order page",                      │
│    "description": "Add new attribute with business logic...",               │
│    "ticket_type": "story",                                                  │
│    "priority": "high"                                                       │
│  }                                                                          │
│                                                                              │
│  → Saved to QUAD_tickets                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 2: USER CLICKS "DEVELOPER AGENT"                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  POST /api/ai/dev-agent/analyze                                             │
│  {                                                                          │
│    "ticket_id": "PROJ-456",                                                 │
│    "action": "analyze_and_expand"                                           │
│  }                                                                          │
│                                                                              │
│  Backend Processing:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 1. Load ticket from QUAD_tickets                                     │   │
│  │ 2. Load codebase index from QUAD_codebase_indexes                    │   │
│  │ 3. Load agent rules from QUAD_ai_configs                             │   │
│  │ 4. Classify task complexity → SELECT MODEL                           │   │
│  │ 5. Build context (index + ticket + rules) → ~7K tokens               │   │
│  │ 6. Call AI provider (Claude/Gemini/OpenAI)                           │   │
│  │ 7. Parse structured response                                         │   │
│  │ 8. Create subtasks in QUAD_tickets                                   │   │
│  │ 9. Log operation in QUAD_ai_operations                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 3: AI RETURNS SUBTASKS                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  AI Response (Structured JSON):                                              │
│  {                                                                          │
│    "analysis": {                                                            │
│      "complexity": "medium",                                                │
│      "estimated_hours": 6,                                                  │
│      "affected_layers": ["database", "entity", "service", "ui"]            │
│    },                                                                       │
│    "subtasks": [                                                            │
│      {                                                                      │
│        "title": "Add migration V42__add_preferred_delivery_time.sql",       │
│        "layer": "database",                                                 │
│        "suggested_files": ["src/main/resources/db/migration/V42__..."]     │
│      },                                                                     │
│      {                                                                      │
│        "title": "Update Order.java entity",                                 │
│        "layer": "backend",                                                  │
│        "suggested_files": ["src/main/java/.../Order.java"]                 │
│      },                                                                     │
│      // ... 4 more subtasks                                                 │
│    ]                                                                        │
│  }                                                                          │
│                                                                              │
│  → 6 subtasks created in QUAD_tickets                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 4: USER CLICKS "IMPLEMENT" ON SUBTASK                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  POST /api/ai/dev-agent/implement                                           │
│  {                                                                          │
│    "ticket_id": "PROJ-456-1",                                               │
│    "action": "generate_code"                                                │
│  }                                                                          │
│                                                                              │
│  Backend Processing:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 1. Load subtask + parent ticket context                              │   │
│  │ 2. Load codebase index (cached)                                      │   │
│  │ 3. Fetch file content if modifying existing files                    │   │
│  │ 4. Build full context → ~10K tokens                                  │   │
│  │ 5. Call AI provider (Sonnet for code gen)                            │   │
│  │ 6. Parse structured code diff response                               │   │
│  │ 7. Save to QUAD_ai_messages.suggestion_data                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 5: AI RETURNS CODE DIFF                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  AI Response (Structured Diff):                                              │
│  {                                                                          │
│    "files": [                                                               │
│      {                                                                      │
│        "path": "src/.../V42__add_preferred_delivery_time.sql",             │
│        "action": "CREATE",                                                  │
│        "content": "-- Migration V42\nALTER TABLE orders ADD COLUMN...",    │
│        "language": "sql"                                                    │
│      }                                                                      │
│    ],                                                                       │
│    "explanation": "Created Flyway migration...",                            │
│    "validation_steps": ["Run mvn flyway:migrate", ...]                     │
│  }                                                                          │
│                                                                              │
│  → Saved to QUAD_ai_messages with suggestion_status = 'pending'             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 6: USER REVIEWS IN BROWSER IDE                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Browser renders Monaco Editor with diff view:                               │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  V42__add_preferred_delivery_time.sql [NEW]                          │   │
│  │  ─────────────────────────────────────────────────────────────────── │   │
│  │  + 1  │ -- Migration V42                                             │   │
│  │  + 2  │ ALTER TABLE orders ADD COLUMN preferred_delivery_time TIME;  │   │
│  │  + 3  │                                                              │   │
│  │  + 4  │ UPDATE orders SET preferred_delivery_time = CASE            │   │
│  │  + 5  │     WHEN delivery_type = 'EXPRESS' THEN '09:00:00'::TIME    │   │
│  │  ...                                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  [✅ Approve & Create Branch]  [✏️ Edit]  [❌ Reject]                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 7: USER APPROVES → GIT OPERATIONS                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  POST /api/ai/dev-agent/approve                                             │
│  {                                                                          │
│    "message_id": "msg_001",                                                 │
│    "create_branch": true,                                                   │
│    "create_pr": true                                                        │
│  }                                                                          │
│                                                                              │
│  Backend Processing:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 1. Update QUAD_ai_messages.suggestion_status = 'approved'            │   │
│  │ 2. Create branch via GitHub API                                      │   │
│  │ 3. Create/modify files via GitHub API                                │   │
│  │ 4. Commit with AI-generated message                                  │   │
│  │ 5. Push to branch                                                    │   │
│  │ 6. Create PR via GitHub API                                          │   │
│  │ 7. Save PR to QUAD_pull_requests                                     │   │
│  │ 8. Link PR to ticket                                                 │   │
│  │ 9. Update ticket status = 'in_review'                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Result:                                                                     │
│  - Branch: feature/PROJ-456-1-add-preferred-delivery-time                   │
│  - PR: https://github.com/org/repo/pull/42                                  │
│  - Ticket status: In Review                                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Context Optimization (80% Savings)

### The Problem: Token Cost

Without optimization, each AI request would need:
```
Full codebase (100 files × 500 lines): ~80,000 tokens
System prompt:                          ~2,000 tokens
User query:                               ~500 tokens
───────────────────────────────────────────────────────
Total per request:                      ~82,500 tokens

Cost per request (Claude Sonnet):
  Input: 82,500 × $3/MTok = $0.2475
  Output: ~1,000 × $15/MTok = $0.015
  Total: ~$0.26 per request

10 requests/day × 30 days = $78/month per user
```

### The Solution: Codebase Index

With optimization:
```
Codebase index (pre-computed summary):  ~5,000 tokens (CACHED)
Ticket context:                          ~1,000 tokens
Agent rules:                             ~1,000 tokens (CACHED)
User query:                                ~500 tokens
───────────────────────────────────────────────────────
Total per request:                       ~7,500 tokens

Cost per request (Claude Sonnet):
  Input: 7,500 × $3/MTok = $0.0225
  Output: ~1,000 × $15/MTok = $0.015
  Total: ~$0.04 per request

10 requests/day × 30 days = $12/month per user
───────────────────────────────────────────────────────
SAVINGS: 85% ($78 → $12 per user/month)
```

### Codebase Index Structure

```java
// Stored in QUAD_codebase_indexes table
public class CodebaseIndex {
    UUID id;
    UUID orgId;
    String repoName;
    String branch;
    String commitHash;

    // Compressed summaries (~1K tokens each)
    Map<String, String> tablesSummary;      // {"orders": "Customer orders with..."}
    Map<String, String> apisSummary;        // {"GET /orders": "List all orders..."}
    Map<String, String> filesSummary;       // {"Order.java": "JPA entity for..."}
    Map<String, String> componentsSummary;  // {"OrderForm.tsx": "React form..."}
    Map<String, String> patternsSummary;    // {"framework": "Spring Boot 3.2"}

    String architectureSummary;             // High-level description

    int totalTokens;           // ~5,000
    int tokenSavingsPercent;   // ~92%

    LocalDateTime lastSyncedAt;
    String syncStatus;         // synced, syncing, failed
}
```

### Index Generation Process

```
1. TRIGGER: On Git push, schedule, or manual

2. FETCH: Clone/pull repository

3. ANALYZE each file type:

   *.java, *.kt, *.py → Extract classes, methods, annotations
   *.sql              → Extract table definitions, columns
   *.ts, *.tsx        → Extract components, hooks, API calls
   *.md               → Extract documentation structure

4. SUMMARIZE with AI (one-time cost):

   "Summarize this file in 1-2 sentences focusing on:
    - What entity/table it represents
    - Key methods/endpoints
    - Dependencies"

5. COMPRESS into JSON structure

6. STORE in QUAD_codebase_indexes

7. CACHE for all future requests
```

---

## 5. Model Routing Algorithm

### Task Classification

```java
public enum TaskComplexity {
    SIMPLE,    // Haiku ($0.25/MTok) - Status, explanation, simple questions
    MEDIUM,    // Sonnet ($3/MTok)   - Code generation, bug analysis
    COMPLEX    // Opus ($15/MTok)    - Architecture, complex refactoring
}

public class TaskClassifier {

    // Keywords that indicate simple tasks
    private static final Set<String> SIMPLE_KEYWORDS = Set.of(
        "what is", "explain", "status", "list", "show", "describe",
        "where is", "find", "search", "when", "who"
    );

    // Keywords that indicate complex tasks
    private static final Set<String> COMPLEX_KEYWORDS = Set.of(
        "architecture", "design pattern", "refactor entire",
        "security audit", "performance optimize", "migrate",
        "rewrite", "restructure", "overhaul"
    );

    public TaskComplexity classify(String query, TaskType type) {
        String lowerQuery = query.toLowerCase();

        // Rule 1: Simple keywords → SIMPLE
        if (SIMPLE_KEYWORDS.stream().anyMatch(lowerQuery::contains)) {
            return TaskComplexity.SIMPLE;
        }

        // Rule 2: Complex keywords → COMPLEX
        if (COMPLEX_KEYWORDS.stream().anyMatch(lowerQuery::contains)) {
            return TaskComplexity.COMPLEX;
        }

        // Rule 3: Task type hints
        switch (type) {
            case CHAT:
            case STATUS_UPDATE:
                return TaskComplexity.SIMPLE;

            case CODE_GENERATION:
            case BUG_FIX:
            case STORY_EXPANSION:
                return TaskComplexity.MEDIUM;

            case ARCHITECTURE_DESIGN:
            case SECURITY_AUDIT:
            case COMPLEX_REFACTOR:
                return TaskComplexity.COMPLEX;
        }

        // Rule 4: Default to MEDIUM
        return TaskComplexity.MEDIUM;
    }
}
```

### Model Selection

```java
public class ModelRouter {

    public ModelSelection route(AIRequest request) {
        // 1. Get org's AI configuration
        AiConfig config = aiConfigService.getByOrgId(request.getOrgId());

        // 2. Classify task complexity
        TaskComplexity complexity = classifier.classify(
            request.getQuery(),
            request.getTaskType()
        );

        // 3. Check budget
        if (creditService.isOverBudget(request.getOrgId())) {
            return useFreeModel();  // Gemini free tier
        }

        // 4. Select model based on complexity + org preference
        switch (complexity) {
            case SIMPLE:
                return selectSimpleModel(config);
            case MEDIUM:
                return selectMediumModel(config);
            case COMPLEX:
                return selectComplexModel(config);
        }
    }

    private ModelSelection selectMediumModel(AiConfig config) {
        // Priority order based on QUAD_ai_provider_config
        // 1. Claude Sonnet (best for code)
        // 2. Gemini Pro (good, free during dev)
        // 3. GPT-4 Turbo (fallback)

        if (config.mediumModel != null) {
            return config.mediumModel;
        }

        // Default priority
        List<String> priority = List.of(
            "claude-3-5-sonnet-20241022",
            "gemini-1.5-pro",
            "gpt-4-turbo"
        );

        for (String model : priority) {
            if (isAvailable(model, config)) {
                return new ModelSelection(model, getProvider(model));
            }
        }

        throw new NoAvailableModelException();
    }
}
```

### Provider Fallback

```java
public class ProviderFallbackHandler {

    public AIResponse callWithFallback(AIRequest request) {
        List<ProviderConfig> providers = getOrderedProviders(request.getOrgId());

        for (ProviderConfig provider : providers) {
            try {
                return callProvider(provider, request);
            } catch (RateLimitException e) {
                log.warn("Rate limited by {}, trying next", provider.getName());
                continue;
            } catch (ProviderException e) {
                log.warn("Provider {} failed: {}", provider.getName(), e.getMessage());
                continue;
            }
        }

        throw new AllProvidersFailed("All AI providers failed for this request");
    }

    private List<ProviderConfig> getOrderedProviders(UUID orgId) {
        // From QUAD_ai_provider_config, ordered by priority
        // Priority: 10=Claude, 20=Gemini, 30=OpenAI, 40=DeepSeek
        return providerConfigRepo.findByOrgIdOrderByPriority(orgId);
    }
}
```

---

## 6. Same-Session Provider Switching

### The AI-Agnostic Advantage

Unlike Cursor (locked to Claude/OpenAI), QUAD can **switch providers within the same conversation session**. This enables:

1. **Cost optimization**: Use cheap models (Gemini Flash, Haiku) for simple queries
2. **Quality optimization**: Use premium models (Claude Opus) for complex tasks
3. **Availability**: Automatic fallback when one provider is rate-limited
4. **Specialization**: Different providers excel at different tasks

### Same-Session Example

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    CONVERSATION: "Add preferredDeliveryTime"                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ USER MESSAGE 1: "What files handle order creation?"                     │ │
│  │                                                                          │ │
│  │ ➤ Classified as: SIMPLE (search/explanation)                            │ │
│  │ ➤ Routed to: Gemini 1.5 Flash ($0.075/MTok)                            │ │
│  │ ➤ Response: Lists OrderController.java, OrderService.java, Order.java   │ │
│  │ ➤ Tokens: 450 input, 200 output                                         │ │
│  │ ➤ Cost: $0.0004                                                         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                          │
│                                    ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ USER MESSAGE 2: "Generate code to add preferredDeliveryTime field"     │ │
│  │                                                                          │ │
│  │ ➤ Classified as: MEDIUM (code generation)                               │ │
│  │ ➤ Routed to: Claude 3.5 Sonnet ($3/MTok)                               │ │
│  │ ➤ Response: Structured diff for 4 files                                 │ │
│  │ ➤ Tokens: 3200 input, 1800 output                                       │ │
│  │ ➤ Cost: $0.037                                                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                          │
│                                    ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ USER MESSAGE 3: "Review the architecture - is this the right approach?"│ │
│  │                                                                          │ │
│  │ ➤ Classified as: COMPLEX (architecture review)                          │ │
│  │ ➤ Routed to: Claude Opus ($15/MTok)                                     │ │
│  │ ➤ Response: Architecture analysis with trade-offs                       │ │
│  │ ➤ Tokens: 4500 input, 2000 output                                       │ │
│  │ ➤ Cost: $0.098                                                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  SESSION TOTAL:                                                               │
│  - 3 messages, 3 different models, 2 different providers                     │
│  - Total cost: $0.135                                                         │
│  - If all used Opus: $0.45 (70% savings!)                                    │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Implementation: Session Context Manager

```java
/**
 * Manages conversation context across provider switches.
 * Key insight: We store conversation in our DB, not provider's.
 * This enables seamless provider switching.
 */
@Service
public class SessionContextManager {

    /**
     * Build context for next message, regardless of which provider will handle it.
     * The context is provider-agnostic - same format for Claude, Gemini, or OpenAI.
     */
    public AIContext buildContext(UUID conversationId, String newMessage) {

        // 1. Load conversation history from QUAD_ai_messages
        List<AIMessage> history = messageRepo.findByConversationId(conversationId);

        // 2. History is stored in neutral format (not provider-specific)
        // Each message has: role, content, provider_used, model_used, tokens
        // The provider_used varies per message - that's the magic!

        // 3. Convert to provider-agnostic format
        List<Message> messages = history.stream()
            .map(m -> new Message(m.getRole(), m.getContent()))
            .collect(toList());

        // 4. Add new user message
        messages.add(new Message("user", newMessage));

        // 5. Load codebase context (cached, same for all providers)
        CodebaseIndex index = indexService.getLatest(conversationId);

        return new AIContext(messages, index, getSystemPrompt());
    }

    /**
     * Each provider translates AIContext to their specific format.
     * Claude: messages array with "user"/"assistant" roles
     * Gemini: contents array with "user"/"model" parts
     * OpenAI: messages array with "user"/"assistant" roles
     */
    public ProviderRequest toProviderFormat(AIContext context, String providerName) {
        return switch (providerName) {
            case "claude" -> new ClaudeRequest(context);
            case "gemini" -> new GeminiRequest(context);
            case "openai" -> new OpenAIRequest(context);
            case "deepseek" -> new DeepSeekRequest(context);
            default -> throw new UnknownProviderException(providerName);
        };
    }
}
```

### Response Normalization

All providers return different response formats. We normalize to a standard format:

```java
/**
 * Normalized response format - same structure regardless of provider.
 * UI never knows which provider generated the response.
 */
public class NormalizedAIResponse {
    String content;           // The text response
    CodeDiff codeDiff;        // Parsed structured diff (if code generation)
    int inputTokens;          // For cost tracking
    int outputTokens;         // For cost tracking
    String model;             // Which model was used (for logging)
    String provider;          // Which provider was used (for logging)
    long latencyMs;           // Response time

    // Note: 'model' and 'provider' are for internal logging only.
    // The UI displays the response identically regardless of source.
}

@Service
public class ResponseNormalizer {

    public NormalizedAIResponse normalize(String rawResponse, String provider) {
        return switch (provider) {
            case "claude" -> parseClaudeResponse(rawResponse);
            case "gemini" -> parseGeminiResponse(rawResponse);
            case "openai" -> parseOpenAIResponse(rawResponse);
            case "deepseek" -> parseDeepSeekResponse(rawResponse);
            default -> throw new UnknownProviderException(provider);
        };
    }

    private NormalizedAIResponse parseClaudeResponse(String raw) {
        // Claude format: {"content":[{"type":"text","text":"..."}], "usage":{...}}
        JsonObject json = JsonParser.parseString(raw).getAsJsonObject();
        String text = json.getAsJsonArray("content")
            .get(0).getAsJsonObject()
            .get("text").getAsString();

        return NormalizedAIResponse.builder()
            .content(text)
            .codeDiff(extractCodeDiff(text))  // Parse structured diff from content
            .inputTokens(json.get("usage").getAsJsonObject().get("input_tokens").getAsInt())
            .outputTokens(json.get("usage").getAsJsonObject().get("output_tokens").getAsInt())
            .build();
    }

    private NormalizedAIResponse parseGeminiResponse(String raw) {
        // Gemini format: {"candidates":[{"content":{"parts":[{"text":"..."}]}}]}
        // ... similar parsing logic
    }
}
```

### Why This Matters

| Approach | Cursor | QUAD |
|----------|--------|------|
| Provider per session | Fixed (Claude or GPT) | Dynamic per message |
| Context storage | Provider's API | Our database |
| Model selection | Manual dropdown | Automatic by task |
| Cost optimization | None | 50-70% savings |
| Rate limit handling | Error shown | Automatic fallback |

---

## 7. Provider Integration

### Provider Interface

```java
public interface AIProvider {

    String getName();  // "claude", "gemini", "openai"

    AIResponse chat(AIRequest request);

    AIResponse generateCode(CodeGenRequest request);

    boolean isAvailable();

    int getRateLimitRemaining();
}
```

### Claude Provider

```java
@Component
public class ClaudeProvider implements AIProvider {

    private static final String API_URL = "https://api.anthropic.com/v1/messages";

    @Override
    public AIResponse chat(AIRequest request) {
        HttpRequest httpRequest = HttpRequest.newBuilder()
            .uri(URI.create(API_URL))
            .header("x-api-key", getApiKey())
            .header("anthropic-version", "2023-06-01")
            .header("content-type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(buildRequestBody(request)))
            .build();

        HttpResponse<String> response = httpClient.send(httpRequest, BodyHandlers.ofString());

        return parseResponse(response.body());
    }

    private String buildRequestBody(AIRequest request) {
        return """
        {
            "model": "%s",
            "max_tokens": %d,
            "temperature": %.2f,
            "system": "%s",
            "messages": [
                {"role": "user", "content": "%s"}
            ]
        }
        """.formatted(
            request.getModel(),
            request.getMaxTokens(),
            request.getTemperature(),
            escapeJson(request.getSystemPrompt()),
            escapeJson(request.getUserMessage())
        );
    }
}
```

### Gemini Provider

```java
@Component
public class GeminiProvider implements AIProvider {

    private static final String API_URL =
        "https://generativelanguage.googleapis.com/v1/models/%s:generateContent";

    @Override
    public AIResponse chat(AIRequest request) {
        String url = API_URL.formatted(request.getModel()) + "?key=" + getApiKey();

        HttpRequest httpRequest = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .header("content-type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(buildRequestBody(request)))
            .build();

        HttpResponse<String> response = httpClient.send(httpRequest, BodyHandlers.ofString());

        return parseGeminiResponse(response.body());
    }
}
```

---

## 7. Code Diff Generation & Application

### Structured Diff Format

```java
public class CodeDiff {
    String path;                    // "src/main/java/.../Order.java"
    DiffAction action;              // CREATE, MODIFY, DELETE, RENAME
    String content;                 // Full content for CREATE
    List<Hunk> hunks;              // For MODIFY
    String language;                // "java", "sql", "typescript"
}

public class Hunk {
    int startLine;                 // 45
    int endLine;                   // 48
    String oldContent;             // Lines to replace
    String newContent;             // New lines
}
```

### AI Prompt for Code Generation

```
You are a QUAD Developer Agent.

## CODEBASE CONTEXT
{codebaseIndex}

## TASK
{ticketDescription}

## AGENT RULES
{agentRules}

## OUTPUT FORMAT (CRITICAL)
Return ONLY valid JSON with this structure:
{
  "files": [
    {
      "path": "relative/path/to/file.java",
      "action": "CREATE" | "MODIFY" | "DELETE",
      "content": "full content for CREATE",
      "hunks": [
        {
          "startLine": 45,
          "endLine": 48,
          "oldContent": "exact lines to replace",
          "newContent": "new lines"
        }
      ],
      "language": "java"
    }
  ],
  "explanation": "Brief explanation of changes",
  "validation_steps": ["How to verify this works"]
}

Rules:
- For MODIFY, provide exact oldContent that matches the file
- For CREATE, provide complete file content
- Use proper indentation matching the codebase
- Follow the patterns in the codebase index
```

### Applying Diffs

```java
public class DiffApplier {

    public String applyDiff(String original, CodeDiff diff) {
        if (diff.getAction() == DiffAction.CREATE) {
            return diff.getContent();
        }

        if (diff.getAction() == DiffAction.DELETE) {
            return null;
        }

        // MODIFY: Apply hunks in reverse order
        String[] lines = original.split("\n");
        List<String> result = new ArrayList<>(Arrays.asList(lines));

        // Sort hunks by startLine descending
        List<Hunk> sortedHunks = diff.getHunks().stream()
            .sorted((a, b) -> b.getStartLine() - a.getStartLine())
            .toList();

        for (Hunk hunk : sortedHunks) {
            // Verify old content matches
            String actual = getLines(result, hunk.getStartLine(), hunk.getEndLine());
            if (!actual.equals(hunk.getOldContent())) {
                throw new DiffMismatchException(
                    "Content at line " + hunk.getStartLine() + " doesn't match"
                );
            }

            // Replace old with new
            int linesToRemove = hunk.getEndLine() - hunk.getStartLine() + 1;
            String[] newLines = hunk.getNewContent().split("\n");

            for (int i = 0; i < linesToRemove; i++) {
                result.remove(hunk.getStartLine() - 1);
            }
            for (int i = newLines.length - 1; i >= 0; i--) {
                result.add(hunk.getStartLine() - 1, newLines[i]);
            }
        }

        return String.join("\n", result);
    }
}
```

---

## 9. Code Diff Sufficiency Analysis

### The Question: Does This Approach Work for All Code Changes?

**Short answer: YES.** The structured diff format handles all code modification scenarios.

### Scenario Analysis

| Scenario | Action | Approach | Sufficiency |
|----------|--------|----------|-------------|
| **New file** | CREATE | Full content provided | ✅ Complete |
| **Modify existing** | MODIFY + hunks | Line-by-line replacement | ✅ Complete |
| **Delete file** | DELETE | File path only | ✅ Complete |
| **Rename file** | RENAME | Old path + new path | ✅ Complete |
| **Move file** | RENAME | Different directories | ✅ Complete |
| **Add new method** | MODIFY | Hunk with insertion point | ✅ Complete |
| **Remove method** | MODIFY | Hunk with empty newContent | ✅ Complete |
| **Update imports** | MODIFY | Multiple hunks | ✅ Complete |
| **Multi-file change** | Multiple diffs | Array of file changes | ✅ Complete |
| **Binary files** | Not supported | ❌ | Out of scope |

### Detailed Scenario Walkthrough

#### Scenario 1: Add New Attribute (User's Original Use Case)

```
Task: "Add preferredDeliveryTime to Order page"

Required changes:
1. Database migration (CREATE new file)
2. JPA Entity (MODIFY - add field + getter/setter)
3. DTO (MODIFY - add field)
4. Service (MODIFY - add business logic)
5. Repository (no change needed - JPA auto)
6. UI Component (MODIFY - add form field)
```

**Structured Diff Output:**

```json
{
  "files": [
    {
      "path": "src/main/resources/db/migration/V42__add_preferred_delivery_time.sql",
      "action": "CREATE",
      "content": "-- V42: Add preferred delivery time\nALTER TABLE orders ADD COLUMN preferred_delivery_time TIME;\n\nUPDATE orders SET preferred_delivery_time = CASE\n    WHEN delivery_type = 'EXPRESS' THEN '09:00:00'::TIME\n    ELSE '14:00:00'::TIME\nEND;",
      "language": "sql"
    },
    {
      "path": "src/main/java/com/quad/entity/Order.java",
      "action": "MODIFY",
      "hunks": [
        {
          "startLine": 45,
          "endLine": 45,
          "oldContent": "    private DeliveryType deliveryType;",
          "newContent": "    private DeliveryType deliveryType;\n\n    @Column(name = \"preferred_delivery_time\")\n    private LocalTime preferredDeliveryTime;"
        },
        {
          "startLine": 120,
          "endLine": 120,
          "oldContent": "    // end of getters/setters",
          "newContent": "    public LocalTime getPreferredDeliveryTime() {\n        return preferredDeliveryTime;\n    }\n\n    public void setPreferredDeliveryTime(LocalTime time) {\n        this.preferredDeliveryTime = time;\n    }\n\n    // end of getters/setters"
        }
      ],
      "language": "java"
    },
    {
      "path": "src/main/java/com/quad/dto/OrderDTO.java",
      "action": "MODIFY",
      "hunks": [
        {
          "startLine": 28,
          "endLine": 28,
          "oldContent": "    private String deliveryType;",
          "newContent": "    private String deliveryType;\n    private String preferredDeliveryTime;  // Format: HH:mm"
        }
      ],
      "language": "java"
    },
    {
      "path": "src/main/java/com/quad/service/OrderService.java",
      "action": "MODIFY",
      "hunks": [
        {
          "startLine": 85,
          "endLine": 90,
          "oldContent": "    public OrderDTO createOrder(OrderCreateRequest request) {\n        Order order = new Order();\n        order.setDeliveryType(request.getDeliveryType());\n        order.setStatus(OrderStatus.PENDING);\n        return mapper.toDTO(orderRepo.save(order));\n    }",
          "newContent": "    public OrderDTO createOrder(OrderCreateRequest request) {\n        Order order = new Order();\n        order.setDeliveryType(request.getDeliveryType());\n        order.setStatus(OrderStatus.PENDING);\n\n        // Business logic: Default delivery time based on type\n        LocalTime deliveryTime = request.getPreferredDeliveryTime();\n        if (deliveryTime == null) {\n            deliveryTime = request.getDeliveryType() == DeliveryType.EXPRESS\n                ? LocalTime.of(9, 0)\n                : LocalTime.of(14, 0);\n        }\n        order.setPreferredDeliveryTime(deliveryTime);\n\n        return mapper.toDTO(orderRepo.save(order));\n    }"
        }
      ],
      "language": "java"
    },
    {
      "path": "quad-web/src/components/OrderForm.tsx",
      "action": "MODIFY",
      "hunks": [
        {
          "startLine": 42,
          "endLine": 42,
          "oldContent": "  const [deliveryType, setDeliveryType] = useState<string>('STANDARD');",
          "newContent": "  const [deliveryType, setDeliveryType] = useState<string>('STANDARD');\n  const [preferredTime, setPreferredTime] = useState<string>('14:00');"
        },
        {
          "startLine": 78,
          "endLine": 80,
          "oldContent": "        <Select value={deliveryType} onValueChange={setDeliveryType}>\n          {/* delivery type options */}\n        </Select>",
          "newContent": "        <Select value={deliveryType} onValueChange={setDeliveryType}>\n          {/* delivery type options */}\n        </Select>\n\n        <TimePicker\n          label=\"Preferred Delivery Time\"\n          value={preferredTime}\n          onChange={setPreferredTime}\n        />"
        }
      ],
      "language": "typescript"
    }
  ],
  "explanation": "Added preferredDeliveryTime field across all layers with business logic for default time based on delivery type.",
  "validation_steps": [
    "Run: mvn flyway:migrate",
    "Run: mvn test -Dtest=OrderServiceTest",
    "Start app and create new order with delivery time",
    "Verify time is saved and returned in API response"
  ]
}
```

**Result:** ✅ All 5 files modified correctly. PR can be created.

#### Scenario 2: Complex Refactoring

```
Task: "Extract payment logic from OrderService into PaymentService"

Required changes:
1. CREATE PaymentService.java (new file)
2. MODIFY OrderService.java (remove payment methods)
3. MODIFY OrderController.java (update DI)
4. CREATE PaymentServiceTest.java (new test)
```

**Approach:** Same structured diff format handles this:
- CREATE for new files (complete content)
- MODIFY with hunks that show removed code (newContent is empty or reduced)
- Multiple hunks for scattered changes

**Result:** ✅ Refactoring handled correctly.

#### Scenario 3: File Rename/Move

```
Task: "Rename UserDTO to UserResponse for API consistency"
```

**Structured Diff:**
```json
{
  "files": [
    {
      "path": "src/main/java/com/quad/dto/UserDTO.java",
      "action": "RENAME",
      "newPath": "src/main/java/com/quad/dto/UserResponse.java",
      "hunks": [
        {
          "startLine": 8,
          "endLine": 8,
          "oldContent": "public class UserDTO {",
          "newContent": "public class UserResponse {"
        }
      ]
    },
    {
      "path": "src/main/java/com/quad/service/UserService.java",
      "action": "MODIFY",
      "hunks": [
        {
          "startLine": 12,
          "endLine": 12,
          "oldContent": "    public UserDTO getUser(UUID id) {",
          "newContent": "    public UserResponse getUser(UUID id) {"
        }
      ]
    }
  ]
}
```

**Result:** ✅ File renamed and all references updated.

### Edge Cases and Mitigations

| Edge Case | Risk | Mitigation |
|-----------|------|------------|
| **Merge conflicts** | Hunk doesn't match current file | Pre-check oldContent against latest Git version |
| **Whitespace mismatch** | Indentation differs | Normalize whitespace before comparison |
| **File moved by another PR** | Path not found | Check Git history, suggest manual resolution |
| **Circular dependencies** | New code creates cycle | Run static analysis after applying diffs |
| **Breaking changes** | Deleted method still used | Run tests in PR pipeline |

### Provider-Agnostic Validation

The same diff format works across ALL providers because:

1. **Structured prompt**: All providers receive identical JSON schema in prompt
2. **Response parsing**: We extract JSON from any provider's text response
3. **Validation**: Same DiffValidator runs regardless of source
4. **Application**: Same DiffApplier applies changes

```java
/**
 * This validator works the same whether diff came from
 * Claude, Gemini, OpenAI, or DeepSeek.
 */
public class DiffValidator {

    public ValidationResult validate(CodeDiff diff, String currentFileContent) {
        // 1. Check file exists (for MODIFY/DELETE)
        // 2. Check oldContent matches current file
        // 3. Check newContent is syntactically valid
        // 4. Check no obvious security issues

        // Provider doesn't matter - same validation logic
        return new ValidationResult(isValid, errors);
    }
}
```

### Conclusion: Sufficiency Confirmed

✅ **CREATE** - Full file content = complete coverage
✅ **MODIFY** - Hunk-based changes = surgical precision
✅ **DELETE** - Simple removal = complete coverage
✅ **RENAME** - Path change + content change = complete coverage
✅ **Multi-file** - Array of diffs = complex changes supported
✅ **Provider-agnostic** - Same format works with any AI provider

The only unsupported case is **binary files** (images, compiled assets), which is intentional - code generation should not modify binaries.

---

## 10. Multi-File Refactoring

### The Challenge

Multi-file refactoring (renaming a class across 20+ files, extracting a service, etc.) is often cited as a limitation of AI-based tools. However, QUAD handles this elegantly with a **two-pass approach**.

### Two-Pass Solution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     MULTI-FILE REFACTORING FLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PASS 1: DISCOVERY (No AI needed)                                            │
│  ─────────────────────────────────                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ User Request: "Rename UserDTO to UserResponse across the codebase"   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ GitHub Code Search API                                               │    │
│  │ GET /search/code?q=UserDTO+repo:org/repo                            │    │
│  │                                                                       │    │
│  │ Returns: 18 files containing "UserDTO"                               │    │
│  │ - UserDTO.java (definition)                                          │    │
│  │ - UserService.java (usage)                                           │    │
│  │ - UserController.java (usage)                                        │    │
│  │ - UserMapper.java (usage)                                            │    │
│  │ - ... 14 more files                                                  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Parallel Fetch: Get content of all 18 files                          │    │
│  │ (GitHub API or cached in QUAD_code_cache)                            │    │
│  │                                                                       │    │
│  │ Total content: ~15,000 tokens                                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  PASS 2: AI GENERATION (Single call)                                         │
│  ────────────────────────────────────                                        │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Single AI Call to Claude Sonnet                                      │    │
│  │                                                                       │    │
│  │ Context (~25K tokens):                                               │    │
│  │ - Codebase index: 5K                                                 │    │
│  │ - 18 affected files: 15K                                             │    │
│  │ - Task instructions: 500                                             │    │
│  │ - Agent rules: 1K                                                    │    │
│  │                                                                       │    │
│  │ Output: Structured diff for ALL 18 files                             │    │
│  │ - RENAME UserDTO.java → UserResponse.java                            │    │
│  │ - MODIFY all 17 files with import/usage changes                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  PASS 3: ATOMIC COMMIT (GitHub Trees API)                                    │
│  ─────────────────────────────────────────                                   │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ GitHub Trees API - Atomic Multi-File Commit                          │    │
│  │                                                                       │    │
│  │ 1. Create tree with all 18 file changes:                             │    │
│  │    POST /repos/org/repo/git/trees                                    │    │
│  │    {                                                                 │    │
│  │      "base_tree": "sha-of-main",                                     │    │
│  │      "tree": [                                                       │    │
│  │        {"path": "UserDTO.java", "mode": "100644", "sha": null},      │    │
│  │        {"path": "UserResponse.java", "content": "..."},              │    │
│  │        {"path": "UserService.java", "content": "..."},               │    │
│  │        // ... 16 more files                                          │    │
│  │      ]                                                               │    │
│  │    }                                                                 │    │
│  │                                                                       │    │
│  │ 2. Create commit pointing to new tree                                │    │
│  │ 3. Update branch ref                                                 │    │
│  │                                                                       │    │
│  │ Result: Single atomic commit with ALL changes                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation Details

```java
/**
 * Multi-file refactoring service.
 * Uses GitHub Code Search → AI → Trees API flow.
 */
@Service
public class MultiFileRefactorService {

    /**
     * PASS 1: Find all affected files using GitHub Code Search
     * NO AI NEEDED - just REST API call
     */
    public List<AffectedFile> discoverAffectedFiles(
        String repoFullName,    // "a2vibecreators/nutrinine-services"
        String searchTerm,       // "UserDTO"
        String branch            // "main"
    ) {
        // GitHub Code Search API
        String url = "https://api.github.com/search/code?q=" +
            URLEncoder.encode(searchTerm + " repo:" + repoFullName, UTF_8);

        SearchResult result = githubClient.get(url, SearchResult.class);

        // Parallel fetch file contents
        return result.getItems().parallelStream()
            .map(item -> new AffectedFile(
                item.getPath(),
                githubClient.getFileContent(repoFullName, item.getPath(), branch)
            ))
            .collect(toList());
    }

    /**
     * PASS 2: Generate diffs for all files in single AI call
     */
    public List<CodeDiff> generateRefactorDiffs(
        List<AffectedFile> files,
        String refactorTask,      // "Rename UserDTO to UserResponse"
        CodebaseIndex index
    ) {
        // Build context with all affected files
        StringBuilder context = new StringBuilder();
        context.append("CODEBASE INDEX:\n").append(index.toCompact()).append("\n\n");
        context.append("AFFECTED FILES (").append(files.size()).append(" files):\n\n");

        for (AffectedFile file : files) {
            context.append("=== ").append(file.getPath()).append(" ===\n");
            context.append(file.getContent()).append("\n\n");
        }

        // Single AI call for ALL diffs
        AIRequest request = AIRequest.builder()
            .model("claude-3-5-sonnet-20241022")  // Good at multi-file
            .systemPrompt(REFACTOR_SYSTEM_PROMPT)
            .userMessage(context + "\n\nTASK: " + refactorTask)
            .maxTokens(8000)  // Enough for 18 file diffs
            .build();

        AIResponse response = aiRouter.call(request);
        return parseDiffs(response.getContent());
    }

    /**
     * PASS 3: Atomic commit using GitHub Trees API
     */
    public CommitResult atomicCommit(
        String repoFullName,
        String branch,
        List<CodeDiff> diffs,
        String commitMessage
    ) {
        // 1. Get current branch HEAD
        String baseTreeSha = githubClient.getRef(repoFullName, "heads/" + branch);

        // 2. Build tree with all file changes
        List<TreeEntry> treeEntries = diffs.stream()
            .map(diff -> switch (diff.getAction()) {
                case CREATE, MODIFY -> new TreeEntry(
                    diff.getPath(),
                    "100644",  // file mode
                    "blob",
                    null,      // sha (null = use content)
                    applyDiff(diff)  // content
                );
                case DELETE -> new TreeEntry(
                    diff.getPath(),
                    "100644",
                    "blob",
                    null,      // sha = null for delete
                    null       // content = null for delete
                );
                case RENAME -> // Two entries: delete old + create new
                    List.of(
                        new TreeEntry(diff.getOldPath(), null, null, null, null),
                        new TreeEntry(diff.getNewPath(), "100644", "blob", null, applyDiff(diff))
                    );
            })
            .flatMap(e -> e instanceof List ? ((List<TreeEntry>) e).stream() : Stream.of((TreeEntry) e))
            .collect(toList());

        // 3. Create tree
        CreateTreeResponse tree = githubClient.createTree(repoFullName, baseTreeSha, treeEntries);

        // 4. Create commit
        CreateCommitResponse commit = githubClient.createCommit(
            repoFullName,
            commitMessage + "\n\n🤖 Generated by QUAD AI Agent",
            tree.getSha(),
            baseTreeSha
        );

        // 5. Update branch ref
        githubClient.updateRef(repoFullName, "heads/" + branch, commit.getSha());

        return new CommitResult(commit.getSha(), branch, diffs.size());
    }
}
```

### Token Analysis for Multi-File Refactor

| Component | Tokens | Notes |
|-----------|--------|-------|
| Codebase index | ~5,000 | Cached, reused |
| 18 affected files (avg 800 lines each) | ~15,000 | Fetched in parallel |
| Task instructions | ~500 | Fixed |
| Agent rules | ~1,000 | Cached |
| **Total Input** | **~21,500** | Fits easily in 200K context |
| **Output (18 file diffs)** | ~6,000 | Structured JSON |
| **Model** | Claude 3.5 Sonnet | |
| **Cost** | ~$0.15 | Single AI call |

### Comparison: Traditional vs QUAD

| Approach | # of AI Calls | Tokens Used | Cost | Time |
|----------|---------------|-------------|------|------|
| **Traditional** (one file at a time) | 18 | 90,000 | ~$0.30 | ~45s |
| **QUAD Two-Pass** | 1 | 27,500 | ~$0.10 | ~15s |
| **Savings** | 94% fewer calls | 69% fewer tokens | 67% cost | 67% time |

### Supported Refactoring Types

| Refactoring | Complexity | Max Files | Confidence |
|-------------|------------|-----------|------------|
| Rename class/interface | Low | 50+ | 95% |
| Rename method | Low | 30+ | 95% |
| Extract interface | Medium | 20+ | 90% |
| Extract service | Medium | 15+ | 85% |
| Move package | Medium | 50+ | 85% |
| Change method signature | Medium | 30+ | 85% |
| Inline class | High | 20+ | 80% |
| Complex restructure | High | 10+ | 70% |

### Edge Cases Handled

1. **Import conflicts**: AI generates proper import statements
2. **Type parameters**: Generic type changes propagated correctly
3. **Test files**: Both source and test files updated
4. **Configuration files**: XML/YAML/JSON configs updated if needed
5. **Comments/Javadoc**: References in documentation updated

---

## 11. Confidence Assessment: Browser-Based IDE

### Overall Confidence: 78%

This section provides a realistic assessment of building a Cursor-like browser IDE for QUAD Framework.

### Feature-by-Feature Breakdown

| Feature | Confidence | Difficulty | Notes |
|---------|------------|------------|-------|
| **Monaco Editor** | 98% | Low | VS Code's editor, battle-tested |
| **File Tree** | 95% | Low | Standard component, GitHub API |
| **AI Chat Panel** | 95% | Low | Already designed in architecture |
| **Diff View** | 95% | Medium | Monaco has built-in diff editor |
| **Syntax Highlighting** | 98% | Low | Monaco handles this |
| **Git Operations** | 90% | Medium | GitHub API, well-documented |
| **Branch Management** | 90% | Medium | GitHub API |
| **PR Creation** | 90% | Medium | GitHub API |
| **Multi-File Refactoring** | 85% | High | Two-pass solution works |
| **Real-time Autocomplete** | 35% | Very High | Needs LSP server per language |
| **Tab-triggered Completion** | 85% | Medium | AI generates on request |
| **Build Trigger** | 80% | Medium | GitHub Actions API |
| **Deploy to DEV** | 75% | Medium | GCP Cloud Run API |
| **Terminal Emulator** | 60% | High | WebSocket + SSH, security concerns |

### What We're Building vs Cursor

| Capability | Cursor | QUAD Browser IDE | Status |
|------------|--------|------------------|--------|
| Code editing | Full IDE | Monaco (sufficient) | ✅ Achievable |
| AI chat | Claude/GPT | Multi-provider | ✅ Better |
| Diff view | Built-in | Monaco diffEditor | ✅ Same |
| Git integration | Built-in | GitHub API | ✅ Same |
| Real-time autocomplete | LSP-based | ❌ Not needed | Skipped |
| Tab completion | AI-powered | On-request | ✅ Sufficient |
| Multi-file refactor | Limited | Two-pass solution | ✅ Better |
| Ticket integration | None | Native | ✅ Better |
| Codebase context | Full load | Indexed (80% savings) | ✅ Better |
| Build/Deploy | Manual | Integrated | ✅ Better |

### Decision: Skip Real-Time Autocomplete

**Reasoning:**
1. Users can ask AI to write code - different workflow, same result
2. LSP servers are complex (one per language: Java, TypeScript, Python, etc.)
3. Browser environment limits LSP performance
4. Focus on AI-assisted writing over keystroke prediction

**Alternative:** Tab-triggered AI completion
- User types partial code → presses Tab → AI completes
- Works across all languages without LSP
- 85% confidence vs 35% for real-time

### Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Monaco performance on large files | Medium | Low | File chunking, virtual scrolling |
| GitHub API rate limits | High | Medium | Caching, user's own token |
| AI response latency | Medium | Medium | Streaming responses |
| Multi-file diffs too large | Medium | Low | Chunking into multiple commits |
| Browser memory limits | Medium | Low | Lazy loading, cleanup |

### Development Complexity Estimate

| Component | Effort | Dependencies |
|-----------|--------|--------------|
| Monaco integration | 3 days | None |
| File tree component | 2 days | GitHub API |
| AI chat panel | 3 days | AI service (exists) |
| Diff view | 2 days | Monaco |
| Git operations UI | 3 days | GitHub API |
| Multi-file refactor UI | 4 days | Refactor service |
| Build/Deploy triggers | 3 days | GitHub Actions, GCP APIs |
| Polish & testing | 5 days | All above |
| **Total** | **~25 days** | |

### Success Criteria

**MVP Success (Week 4):**
- [ ] Open file from GitHub in Monaco
- [ ] Edit and save (creates branch + commit)
- [ ] AI chat generates code diffs
- [ ] Apply diffs to file
- [ ] Create PR with one click

**Full Success (Week 6):**
- [ ] Multi-file refactoring works
- [ ] Build triggers on PR
- [ ] Deploy to DEV from UI
- [ ] Used to develop NutriNine features
- [ ] Used to fix QUAD issues

---

## 12. Database Tables Used

### Core AI Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `QUAD_ai_configs` | Per-org AI settings | primary_provider, enable_*, require_approval_* |
| `QUAD_ai_provider_config` | Provider configs | provider, api_key_vault_path, priority |
| `QUAD_ai_operations` | Operation log | operation_type, model_used, tokens, cost |
| `QUAD_ai_conversations` | Chat threads | scope_type, scope_id, total_tokens |
| `QUAD_ai_messages` | Individual messages | role, content, suggestion_type, suggestion_data |
| `QUAD_ai_activity_routing` | Task→Model mapping | activity_type, provider, model_id |
| `QUAD_ai_analysis_cache` | Cached analyses | entity_type, input_hash, result |
| `QUAD_ai_credit_balances` | Credit tracking | credits_remaining, is_byok |
| `QUAD_ai_credit_transactions` | Credit log | transaction_type, amount_cents, ticket_id |

### Context Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `QUAD_codebase_indexes` | Compressed codebase | tables_summary, apis_summary, files_summary |
| `QUAD_codebase_files` | File-level details | file_path, functions, summary |
| `QUAD_code_cache` | Full file content cache | content, github_sha, expires_at |
| `QUAD_memory_chunks` | Long-term memory | scope, keywords, content |

---

## 11. API Contracts

### POST /api/ai/dev-agent/analyze

**Request:**
```json
{
  "ticket_id": "uuid",
  "action": "analyze_and_expand",
  "options": {
    "create_subtasks": true,
    "estimate": true
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "analysis": {
      "complexity": "medium",
      "estimated_hours": 6,
      "affected_layers": ["database", "backend", "frontend"]
    },
    "subtasks_created": 6,
    "operation_id": "uuid",
    "tokens_used": {
      "input": 1847,
      "output": 892
    },
    "cost_usd": 0.0082
  }
}
```

### POST /api/ai/dev-agent/implement

**Request:**
```json
{
  "ticket_id": "uuid",
  "action": "generate_code"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message_id": "uuid",
    "suggestion": {
      "files": [
        {
          "path": "src/.../V42__migration.sql",
          "action": "CREATE",
          "content": "-- Migration...",
          "language": "sql"
        }
      ],
      "explanation": "Created migration...",
      "validation_steps": ["Run mvn flyway:migrate"]
    },
    "tokens_used": {
      "input": 1523,
      "output": 567
    }
  }
}
```

### POST /api/ai/dev-agent/approve

**Request:**
```json
{
  "message_id": "uuid",
  "options": {
    "create_branch": true,
    "branch_name": "feature/PROJ-456-1-description",
    "create_pr": true
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "action": "approved_and_committed",
    "branch": "feature/PROJ-456-1-description",
    "commit_sha": "abc123...",
    "pull_request": {
      "number": 42,
      "url": "https://github.com/org/repo/pull/42"
    },
    "ticket_status": "in_review"
  }
}
```

---

## 12. Comparison with Cursor

| Feature | Cursor | QUAD Framework |
|---------|--------|----------------|
| **Platform** | Desktop IDE (VS Code) | Browser-based |
| **AI Provider** | Claude/GPT (single session) | **AI-agnostic** (4+ providers) |
| **Model Routing** | Manual dropdown | **Automatic per message** |
| **Same-Session Switching** | ❌ Not supported | ✅ Switch provider mid-conversation |
| **Context** | Full file load | Codebase index (80% savings) |
| **Integration** | None | Tickets, PRs, Git |
| **Cost Control** | Pay-per-use | Budget limits, BYOK |
| **Multi-user** | Individual | Team/Org |
| **Audit Trail** | None | Full operation log |
| **PR Creation** | Manual | Automatic |

### What QUAD Does Better

1. **AI-Agnostic Architecture**
   - **Same conversation can use multiple providers** (e.g., Gemini for Q&A, Claude for code)
   - No vendor lock-in - easily add new providers
   - Intelligent routing based on task complexity
   - Automatic fallback on rate limits

2. **Cost Optimization**
   - Codebase indexing saves 80-90% on tokens
   - Automatic model routing (use cheap model for simple tasks)
   - Budget limits prevent overruns
   - 50-70% savings from intelligent routing

3. **Team Integration**
   - Tickets linked to AI conversations
   - Shared codebase index across team
   - Role-based AI permissions

4. **Workflow Automation**
   - Story → Subtasks (automatic)
   - Code → PR (one click)
   - Ticket status updates

---

## Summary

QUAD's AI Agent Architecture is fundamentally **AI-agnostic**, enabling:

1. **Same-session multi-provider AI** - Claude, Gemini, OpenAI, DeepSeek work interchangeably **within the same conversation**
2. **80% cost savings** - Through codebase indexing and intelligent routing
3. **Automatic model selection** - Right model for each message, not just each session
4. **Provider independence** - No vendor lock-in, easy to add new providers
5. **Cursor-like experience** - In a browser, with ticket integration
6. **Full traceability** - Every AI operation logged with provider, model, tokens, cost

The architecture ensures that **whether an AI suggestion comes from Claude, Gemini, OpenAI, or DeepSeek**, the output format, validation, and application process is identical. Users never need to know which provider generated their code.

---

**Document Version:** 1.2
**Author:** QUAD Development Team
**Last Updated:** January 3, 2026

### Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 3, 2026 | Initial AI-agnostic architecture documentation |
| 1.1 | Jan 3, 2026 | Added end-to-end example with token counts |
| 1.2 | Jan 3, 2026 | Added Multi-File Refactoring section, Confidence Assessment, 1-month Browser IDE plan |
