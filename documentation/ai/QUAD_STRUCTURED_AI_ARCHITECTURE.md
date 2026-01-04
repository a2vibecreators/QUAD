# QUAD Structured AI Architecture

**Version:** 1.0
**Last Updated:** January 4, 2026
**Purpose:** Define QUAD's unique AI approach vs general-purpose tools

---

## Table of Contents

1. [Why QUAD is Different](#why-quad-is-different)
2. [Structured vs Conversational Tasks](#structured-vs-conversational-tasks)
3. [Task Type Routing](#task-type-routing)
4. [Structured Pipeline Architecture](#structured-pipeline-architecture)
5. [Context Selection Strategy](#context-selection-strategy)
6. [Output Schema Validation](#output-schema-validation)
7. [Learning Architecture](#learning-architecture)
8. [Database Tables](#database-tables)
9. [Implementation Priority](#implementation-priority)

---

## Why QUAD is Different

### General-Purpose AI Tools (Claude Code, Cursor, Copilot)

```
User: "Fix the bug"
   ↓
AI Tool:
   1. Search entire codebase (50K+ tokens)
   2. Guess what "bug" means
   3. Explore multiple files
   4. Generate free-form response
   5. Hope it's correct

Problems:
- High token usage (expensive)
- Hallucination risk (unknown territory)
- No output validation
- User intent is guessed
```

### QUAD Structured Approach

```
User: Clicks "Start Work" on ticket QUAD-123 (type=BUG)
   ↓
QUAD:
   1. Load BUG template (predefined prompt)
   2. Send ONLY: ticket + linked files + rules (500-1500 tokens)
   3. AI outputs JSON matching bug_fix_schema
   4. QUAD validates output against schema
   5. If invalid → reject, don't execute

Advantages:
- Minimal tokens (10x cheaper)
- Low hallucination (bounded context)
- Schema-validated output
- Intent is KNOWN from ticket_type
```

### Comparison Matrix

| Aspect | General Tools | QUAD |
|--------|---------------|------|
| **Task Scope** | Anything | Defined workflows |
| **Context Needed** | Everything might be relevant | Only ticket + domain |
| **User Intent** | Must guess from prompt | Known from ticket_type |
| **Tools Available** | 15+ general tools | Scoped per workflow |
| **Memory** | Conversation + files | Structured DB memory |
| **Output Format** | Free-form | Schema-validated JSON |
| **Hallucination Risk** | High | Low |
| **Token Usage** | 50K+ per request | 500-1500 per request |

---

## Structured vs Conversational Tasks

QUAD routes AI requests into two categories:

### Category 1: Structured Tasks (Templates + Schema)

**Used for:** All ticket-related work with known workflows.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    STRUCTURED TASKS                                      │
│                                                                          │
│   Ticket Type        → Template          → Output Schema                 │
│   ──────────────────────────────────────────────────────────────────────│
│   USER_STORY         → story_analysis    → {approach, files, risks}     │
│   BUG                → bug_analysis      → {root_cause, fix, test}      │
│   TASK               → task_breakdown    → {subtasks, dependencies}     │
│   CODE_REVIEW        → review_template   → {comments, severity}         │
│   MEETING_NOTES      → meeting_template  → {actions, decisions}         │
│   DEPLOYMENT         → deploy_template   → {steps, rollback}            │
│                                                                          │
│   AI Model: Claude Sonnet / Haiku (quality matters)                      │
│   Context: Minimal, targeted (500-1500 tokens)                           │
│   Output: JSON validated against schema                                  │
│   Learning: Track success rate per template                              │
└─────────────────────────────────────────────────────────────────────────┘
```

### Category 2: Conversational Tasks (Free-form, Cheap)

**Used for:** User questions, exploration, summaries.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CONVERSATIONAL TASKS                                  │
│                                                                          │
│   Request Type       → AI Model         → Output                         │
│   ──────────────────────────────────────────────────────────────────────│
│   "How does X work?" → Gemini Flash     → Free-form explanation         │
│   "Summarize this"   → Gemini Flash     → Bullet points                 │
│   "What is..."       → Haiku / GPT-mini → Short answer                  │
│   "Explain..."       → Gemini Flash     → Markdown text                 │
│                                                                          │
│   AI Model: Gemini Flash / Haiku (cheap is fine)                         │
│   Context: RAG retrieval from docs (variable)                            │
│   Output: Free-form text, no schema                                      │
│   Learning: Not tracked (exploratory)                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Task Type Routing

QUAD automatically routes requests based on context:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD AI ROUTING DECISION                              │
│                                                                          │
│   User Action                           → Route To                       │
│   ──────────────────────────────────────────────────────────────────────│
│                                                                          │
│   STRUCTURED TASKS (Template + Schema)                                   │
│   ────────────────────────────────────                                   │
│   Click "Start Work" on ticket          → Structured (Claude)            │
│   Submit PR for review                  → Structured (Claude)            │
│   Click "Deploy"                        → Structured (Claude)            │
│   Meeting ends (transcript ready)       → Structured (Gemini Flash)      │
│                                                                          │
│   CONVERSATIONAL TASKS (Free-form, Cheap)                                │
│   ────────────────────────────────────                                   │
│   Type question in chat                 → Conversational (Gemini Flash)  │
│   Ask "how does auth work?"             → Conversational (Gemini Flash)  │
│   Ask "summarize this meeting"          → Conversational (Gemini Flash)  │
│   Ask "what is REST API?"               → Conversational (Haiku)         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Model Selection by Task Type

| Task Type | Primary Model | Fallback | Cost per Request |
|-----------|---------------|----------|------------------|
| **USER_STORY analysis** | Claude Sonnet | Claude Haiku | $0.50 - $3.00 |
| **BUG analysis** | Claude Sonnet | Claude Haiku | $0.50 - $3.00 |
| **CODE_REVIEW** | Claude Sonnet | GPT-4o | $1.00 - $5.00 |
| **MEETING_NOTES** | Gemini Flash | Claude Haiku | $0.05 - $0.30 |
| **User question** | Gemini Flash | Haiku | $0.01 - $0.10 |
| **Simple lookup** | GPT-4o-mini | Haiku | $0.005 - $0.05 |

---

## Structured Pipeline Architecture

### 8-Step Pipeline for Ticket Work

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD STRUCTURED AI PIPELINE                           │
│                                                                          │
│   1. TASK ARRIVES                                                        │
│      User clicks "Start Work" on ticket QUAD-123                         │
│        ↓                                                                 │
│   2. DETERMINE TASK TYPE                                                 │
│      ticket.type = BUG → Load BUG pipeline                               │
│        ↓                                                                 │
│   3. LOAD TASK TEMPLATE (from QUAD_memory_templates)                     │
│      {                                                                   │
│        "system_prompt": "You are analyzing a bug...",                    │
│        "required_context": ["ticket", "error_logs", "related_files"],    │
│        "output_schema": {"root_cause": "string", "fix": "string"},       │
│        "tools_allowed": ["read_file", "search_codebase"],                │
│        "tools_denied": ["write_file", "bash"],                           │
│        "max_tokens": 2000                                                │
│      }                                                                   │
│        ↓                                                                 │
│   4. LOAD MINIMAL CONTEXT (NOT everything!)                              │
│      ✓ Ticket: title, description, acceptance_criteria                   │
│      ✓ Related files: from ticket_file_associations ONLY                 │
│      ✓ Org rules: WHERE circle_type = ticket.circle                      │
│      ✗ NO: Full codebase search                                          │
│      ✗ NO: Unrelated domain files                                        │
│        ↓                                                                 │
│   5. EXECUTE WITH CONSTRAINED TOOLS                                      │
│      Tools scoped to task type                                           │
│      File access scoped to domain                                        │
│        ↓                                                                 │
│   6. VALIDATE OUTPUT AGAINST SCHEMA                                      │
│      Did AI follow expected format? ✓                                    │
│      Did AI produce required fields? ✓                                   │
│      If invalid → REJECT, don't execute                                  │
│        ↓                                                                 │
│   7. RECORD OUTCOME                                                      │
│      QUAD_ai_operations: success/failure, tokens, latency                │
│      User feedback: thumbs up/down                                       │
│        ↓                                                                 │
│   8. LEARNING LOOP (Background)                                          │
│      Weekly: Analyze template success rates                              │
│      Auto: Update templates with <80% success                            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Context Selection Strategy

### Why Minimal Context Matters

| Approach | Tokens Sent | Cost | Hallucination Risk |
|----------|-------------|------|-------------------|
| **Send everything** | 50,000+ | $$$$ | High |
| **Smart selection** | 5,000 | $$ | Medium |
| **QUAD minimal** | 500-1,500 | $ | Low |

### Context Selection Rules

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 CONTEXT SELECTION FOR TICKET QUAD-123                    │
│                                                                          │
│   TICKET TYPE: BUG                                                       │
│   CIRCLE: DEVELOPMENT                                                    │
│                                                                          │
│   ✅ REQUIRED CONTEXT (Always Send):                                     │
│   ├── ticket.title                          (50 tokens)                  │
│   ├── ticket.description                    (200 tokens)                 │
│   ├── ticket.acceptance_criteria            (100 tokens)                 │
│   └── org_rules WHERE circle = DEVELOPMENT  (150 tokens)                 │
│                                                                          │
│   ✅ CONDITIONAL CONTEXT (Only If Relevant):                             │
│   ├── IF bug involves "auth"                                             │
│   │   └── Send: AuthService.java, jwt-config.ts (500 tokens)             │
│   ├── IF bug involves "database"                                         │
│   │   └── Send: schema.sql, relevant entity (400 tokens)                 │
│   └── IF has linked files in ticket_file_associations                    │
│       └── Send: those specific files only                                │
│                                                                          │
│   ❌ NEVER SEND (Even If AI Asks):                                       │
│   ├── Full codebase tree                                                 │
│   ├── Unrelated domain files                                             │
│   ├── Other tickets                                                      │
│   └── Historical conversations                                           │
│                                                                          │
│   📊 ESTIMATED CONTEXT: 500-1500 tokens (vs 50K+ for Claude Code)        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Output Schema Validation

### Why Schema Validation Prevents Hallucination

```
Without Schema (General Tools):
  AI can output ANYTHING → Might hallucinate file paths, function names

With Schema (QUAD):
  AI MUST output valid JSON → If invalid, REJECTED before execution
```

### Example: Bug Analysis Schema

```json
{
  "type": "object",
  "required": ["root_cause", "fix_approach", "files_to_modify", "test_needed"],
  "properties": {
    "root_cause": {
      "type": "string",
      "minLength": 50,
      "description": "Explanation of what caused the bug"
    },
    "fix_approach": {
      "type": "string",
      "minLength": 30,
      "description": "How to fix the bug"
    },
    "files_to_modify": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1,
      "description": "List of files that need changes"
    },
    "test_needed": {
      "type": "boolean",
      "description": "Does this fix need a new test?"
    },
    "estimated_effort": {
      "type": "string",
      "enum": ["SMALL", "MEDIUM", "LARGE"],
      "description": "Effort to implement fix"
    }
  }
}
```

### Validation Flow

```
AI Output → JSON Parse → Schema Validate → If Valid: Execute
                                          If Invalid: Reject + Log

Rejection reasons tracked in QUAD_ai_operations.error_message:
- "Missing required field: root_cause"
- "files_to_modify must have at least 1 item"
- "estimated_effort must be SMALL, MEDIUM, or LARGE"
```

---

## Learning Architecture

### How QUAD "Learns" Without Fine-Tuning

| Method | Description | QUAD Implementation |
|--------|-------------|---------------------|
| **Rules** | Human-defined constraints | QUAD_org_rules table |
| **Templates** | Pre-built prompts per task | QUAD_memory_templates table |
| **RAG** | Retrieve similar patterns | QUAD_rag_indexes table |
| **Feedback** | Track success/failure | QUAD_ai_operations.outcome |
| **A/B Testing** | Test prompt variations | QUAD_ai_activity_routing |

### Four-Layer Learning System

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    QUAD LEARNING LAYERS                                  │
│                                                                          │
│   LAYER 1: RULES (Explicit, Human-defined)                               │
│   ─────────────────────────────────────────                              │
│   QUAD_org_rules: "All bugs must have root_cause field"                  │
│   Loaded before EVERY AI request                                         │
│   Updated by humans based on outcomes                                    │
│                                                                          │
│   LAYER 2: TEMPLATES (Pre-built Prompts)                                 │
│   ─────────────────────────────────────────                              │
│   QUAD_memory_templates: System prompt + output schema                   │
│   One template per task type                                             │
│   A/B tested for effectiveness                                           │
│                                                                          │
│   LAYER 3: RAG (Pattern Retrieval)                                       │
│   ─────────────────────────────────────────                              │
│   QUAD_rag_indexes: "Auth bugs usually involve JWT expiry"               │
│   Retrieved based on similarity                                          │
│   Added to context: "Similar issues were solved by..."                   │
│                                                                          │
│   LAYER 4: FEEDBACK LOOP (Auto-adjustment)                               │
│   ─────────────────────────────────────────                              │
│   QUAD_ai_operations: Track success/failure per template                 │
│   Weekly job: Flag templates with <80% success                           │
│   Auto: Adjust context, escalate model tier                              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Feedback Tracking

```sql
-- Track outcome for learning
UPDATE QUAD_ai_operations SET
  outcome = 'SUCCESS',        -- SUCCESS, FAILURE, PARTIAL
  user_feedback = 1,          -- 1 = thumbs up, -1 = thumbs down, 0 = no feedback
  schema_valid = true,        -- Did output match schema?
  deviation_score = 0.1       -- How much output deviated from expected
WHERE id = :operation_id;

-- Weekly analysis job: Find struggling templates
SELECT
  template_code,
  COUNT(*) as total_uses,
  AVG(CASE WHEN outcome = 'SUCCESS' THEN 1 ELSE 0 END) as success_rate,
  AVG(user_feedback) as avg_feedback
FROM QUAD_ai_operations ao
JOIN QUAD_memory_templates mt ON ao.template_id = mt.id
WHERE ao.created_at > NOW() - INTERVAL '7 days'
GROUP BY template_code
HAVING AVG(CASE WHEN outcome = 'SUCCESS' THEN 1 ELSE 0 END) < 0.8;
```

---

## Database Tables

### Tables for Structured AI

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `QUAD_memory_templates` | Task templates | template_code, system_prompt, output_schema |
| `QUAD_org_rules` | Org/domain constraints | rule_key, rule_value, circle_type |
| `QUAD_rag_indexes` | Successful patterns | content, embedding, metadata |
| `QUAD_ai_operations` | Execution log | outcome, user_feedback, tokens |
| `QUAD_ai_activity_routing` | Task → Template mapping | activity_type, template_id |
| `QUAD_ai_analysis_cache` | Cache repeated analyses | cache_key, result, expires_at |

### Template Schema (QUAD_memory_templates.template_content)

```json
{
  "system_prompt": "You are analyzing a user story for QUAD. Output ONLY JSON.",
  "required_context": ["ticket", "acceptance_criteria", "related_files"],
  "output_schema": {
    "type": "object",
    "required": ["approach", "files", "risks"],
    "properties": {
      "approach": { "type": "string" },
      "files": { "type": "array", "items": { "type": "string" } },
      "risks": { "type": "array", "items": { "type": "string" } }
    }
  },
  "tools_allowed": ["read_file", "search_codebase"],
  "tools_denied": ["write_file", "bash", "web_search"],
  "max_tokens": 2000,
  "model_preference": "claude-sonnet"
}
```

---

## Implementation Priority

| Priority | Feature | Table/Code | Effort |
|----------|---------|------------|--------|
| **P0** | Task templates | QUAD_memory_templates | 2 days |
| **P0** | Output schema validation | JSON Schema library | 1 day |
| **P1** | Org rules loading | QUAD_org_rules | 1 day |
| **P1** | Minimal context builder | ContextBuilderService | 3 days |
| **P1** | Task type routing | AIRouterService | 2 days |
| **P2** | Feedback tracking | QUAD_ai_operations.outcome | 1 day |
| **P2** | Weekly analytics job | Cron job | 1 day |
| **P3** | RAG pattern retrieval | QUAD_rag_indexes + embedding | 5 days |
| **P3** | Template A/B testing | QUAD_ai_activity_routing | 3 days |

---

## Related Documentation

- [AI_PIPELINE_TIERS.md](AI_PIPELINE_TIERS.md) - Model selection and cost tiers
- [AI_ACTIVITIES.md](AI_ACTIVITIES.md) - 62 AI activities catalog
- [AI_PRICING_TIERS.md](AI_PRICING_TIERS.md) - Pricing strategy
- [DISCUSSIONS_LOG.md](../internal/DISCUSSIONS_LOG.md) - Section 23

---

**Key Insight:**
```
QUAD doesn't make AI "smarter" -
QUAD constrains AI to only do what's needed.

Less freedom = Less hallucination = Better UX = Lower cost
```

---

**Last Updated:** January 4, 2026
**Version:** 1.0
