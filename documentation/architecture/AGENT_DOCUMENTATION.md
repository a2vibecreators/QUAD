# QUAD Framework - Agent Documentation

**Created:** January 3, 2026
**Last Updated:** January 3, 2026
**Status:** Draft
**Version:** 1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Agent Types](#2-agent-types)
3. [Agent Groups](#3-agent-groups)
4. [Agent Permissions](#4-agent-permissions)
5. [Agent Lifecycle](#5-agent-lifecycle)
6. [Agent Configuration](#6-agent-configuration)
7. [Agent Communication](#7-agent-communication)
8. [Agent Context & Memory](#8-agent-context--memory)
9. [Agent Routing & Selection](#9-agent-routing--selection)
10. [Database Tables](#10-database-tables)
11. [API Endpoints](#11-api-endpoints)
12. [Security & Audit](#12-security--audit)
13. [References](#13-references)

---

## 1. Overview

QUAD Framework uses an **agentic AI architecture** where specialized agents handle different aspects of software development. Each agent has specific capabilities, permissions, and context awareness.

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Specialization** | Each agent has a focused purpose (code gen, review, analysis) |
| **AI-Agnostic** | Agents can use any AI provider (Claude, Gemini, OpenAI, DeepSeek) |
| **Context-Aware** | Agents understand codebase structure via indexed context |
| **Auditable** | Every agent action is logged for traceability |
| **Permissioned** | Agent capabilities are controlled by organization settings |

### Agent vs AI Provider

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AGENT ARCHITECTURE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   AGENT (What it does)              AI PROVIDER (How it thinks)             │
│   ─────────────────────             ───────────────────────────             │
│   Developer Agent                   → Claude Sonnet (code gen)              │
│   Code Reviewer Agent               → Claude Opus (complex review)          │
│   Documentation Agent               → Gemini Pro (writing)                  │
│   Test Generator Agent              → Claude Sonnet (code gen)              │
│   Security Auditor Agent            → Claude Opus (analysis)                │
│                                                                              │
│   Same agent can use different providers based on:                          │
│   - Task complexity                                                          │
│   - Organization preference                                                  │
│   - Cost optimization                                                        │
│   - Provider availability                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Agent Types

### 2.1 Primary Agents

| Agent Type | Code | Purpose | Default Provider |
|------------|------|---------|------------------|
| **Developer Agent** | `DEV_AGENT` | Code generation, implementation | Claude Sonnet |
| **Code Reviewer Agent** | `REVIEW_AGENT` | PR review, code quality | Claude Sonnet |
| **Documentation Agent** | `DOC_AGENT` | Generate docs, comments | Gemini Pro |
| **Test Generator Agent** | `TEST_AGENT` | Unit/integration tests | Claude Sonnet |
| **Analyst Agent** | `ANALYST_AGENT` | Story expansion, requirements | Gemini Pro |
| **Architect Agent** | `ARCH_AGENT` | System design, patterns | Claude Opus |
| **Security Agent** | `SEC_AGENT` | Security audit, vulnerabilities | Claude Opus |
| **DevOps Agent** | `DEVOPS_AGENT` | CI/CD, deployment, infra | Claude Sonnet |

### 2.2 Agent Type Details

#### Developer Agent (`DEV_AGENT`)

```yaml
name: Developer Agent
code: DEV_AGENT
description: Implements features and fixes bugs
capabilities:
  - Generate new code files
  - Modify existing files (structured diffs)
  - Create database migrations
  - Implement API endpoints
  - Write business logic
context_required:
  - Codebase index
  - Ticket description
  - Agent rules (from domain)
  - Related file contents
output_format: Structured JSON with file diffs
approval_required: true
default_provider: claude-3-5-sonnet
fallback_providers:
  - gemini-1.5-pro
  - gpt-4-turbo
```

#### Code Reviewer Agent (`REVIEW_AGENT`)

```yaml
name: Code Reviewer Agent
code: REVIEW_AGENT
description: Reviews PRs and suggests improvements
capabilities:
  - Analyze code changes
  - Identify bugs and issues
  - Suggest refactoring
  - Check coding standards
  - Verify test coverage
context_required:
  - PR diff
  - Original file contents
  - Codebase patterns
  - Coding standards (from domain)
output_format: Structured review with line comments
approval_required: false
default_provider: claude-3-5-sonnet
```

#### Architect Agent (`ARCH_AGENT`)

```yaml
name: Architect Agent
code: ARCH_AGENT
description: Designs system architecture
capabilities:
  - Create architecture diagrams
  - Define service boundaries
  - Design database schemas
  - Plan API contracts
  - Evaluate technology choices
context_required:
  - Full codebase index
  - System requirements
  - Non-functional requirements
  - Existing architecture docs
output_format: Markdown documentation with diagrams
approval_required: true
default_provider: claude-opus-4
complexity: high
```

### 2.3 Agent Capability Matrix

| Capability | DEV | REVIEW | DOC | TEST | ANALYST | ARCH | SEC | DEVOPS |
|------------|-----|--------|-----|------|---------|------|-----|--------|
| Create files | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ |
| Modify files | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ |
| Delete files | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| Create branches | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ |
| Create PRs | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ |
| Comment on PRs | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Approve PRs | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Trigger builds | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Deploy | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Create tickets | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Estimate effort | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |

---

## 3. Agent Groups

Agent groups allow bundling multiple agents for specific workflows.

### 3.1 Predefined Groups

| Group Name | Agents Included | Use Case |
|------------|-----------------|----------|
| **Full Development** | DEV + TEST + REVIEW | Complete feature implementation |
| **Code Quality** | REVIEW + SEC + TEST | PR validation |
| **Planning** | ANALYST + ARCH | Sprint planning |
| **Documentation** | DOC + ANALYST | Doc generation |
| **Security Audit** | SEC + REVIEW | Security review |
| **DevOps Pipeline** | DEVOPS + TEST | CI/CD operations |

### 3.2 Group Configuration

```json
{
  "group_name": "Full Development",
  "group_code": "FULL_DEV",
  "description": "Complete feature implementation with tests and review",
  "agents": [
    {
      "agent_type": "DEV_AGENT",
      "order": 1,
      "required": true,
      "config": {
        "create_branch": true,
        "auto_commit": false
      }
    },
    {
      "agent_type": "TEST_AGENT",
      "order": 2,
      "required": true,
      "trigger": "after_dev_complete",
      "config": {
        "test_types": ["unit", "integration"],
        "coverage_threshold": 80
      }
    },
    {
      "agent_type": "REVIEW_AGENT",
      "order": 3,
      "required": false,
      "trigger": "after_tests_pass",
      "config": {
        "auto_approve": false,
        "require_human_review": true
      }
    }
  ],
  "workflow": {
    "type": "sequential",
    "stop_on_failure": true,
    "notify_on_complete": true
  }
}
```

### 3.3 Group Permissions

| Permission | Full Dev | Code Quality | Planning | Docs | Security | DevOps |
|------------|----------|--------------|----------|------|----------|--------|
| Create code | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Create tests | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Review code | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Security scan | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Create docs | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Estimate | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Deploy | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 4. Agent Permissions

### 4.1 Permission Levels

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PERMISSION HIERARCHY                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PLATFORM LEVEL (A2Vibe Creators)                                           │
│  ├── Enable/disable agent types globally                                    │
│  ├── Set default AI providers                                               │
│  └── Configure rate limits                                                  │
│                                                                              │
│  ORGANIZATION LEVEL                                                          │
│  ├── Enable/disable specific agents                                         │
│  ├── Set approval requirements                                              │
│  ├── Configure AI provider preferences                                      │
│  ├── Set budget limits per agent                                            │
│  └── Define custom agent rules                                              │
│                                                                              │
│  DOMAIN LEVEL                                                                │
│  ├── Override org settings for domain                                       │
│  ├── Set domain-specific agent rules (agent.md)                             │
│  ├── Configure allowed file patterns                                        │
│  └── Set deployment permissions                                             │
│                                                                              │
│  USER LEVEL                                                                  │
│  ├── Personal AI preferences (temperature, style)                           │
│  ├── Notification preferences                                               │
│  └── BYOK (Bring Your Own Key) option                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Permission Matrix by Role

| Permission | ORG_OWNER | ORG_ADMIN | DOMAIN_ADMIN | DOMAIN_LEAD | MEMBER | VIEWER |
|------------|-----------|-----------|--------------|-------------|--------|--------|
| Enable agents for org | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Configure agent budget | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Set approval rules | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Use Developer Agent | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Use Architect Agent | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Use DevOps Agent | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve agent changes | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| View agent history | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| BYOK configuration | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

### 4.3 Agent Action Permissions

```java
public enum AgentActionPermission {
    // File Operations
    FILE_CREATE,        // Create new files
    FILE_MODIFY,        // Modify existing files
    FILE_DELETE,        // Delete files
    FILE_RENAME,        // Rename/move files

    // Git Operations
    BRANCH_CREATE,      // Create branches
    BRANCH_DELETE,      // Delete branches
    COMMIT_CREATE,      // Create commits
    PR_CREATE,          // Create pull requests
    PR_APPROVE,         // Approve pull requests
    PR_MERGE,           // Merge pull requests

    // Ticket Operations
    TICKET_CREATE,      // Create tickets/subtasks
    TICKET_UPDATE,      // Update ticket status
    TICKET_ASSIGN,      // Assign tickets
    TICKET_ESTIMATE,    // Add estimates

    // Build/Deploy Operations
    BUILD_TRIGGER,      // Trigger CI builds
    DEPLOY_DEV,         // Deploy to DEV
    DEPLOY_QA,          // Deploy to QA
    DEPLOY_PROD,        // Deploy to PROD (requires extra approval)

    // AI Operations
    AI_CHAT,            // Use AI chat
    AI_CODE_GEN,        // Generate code
    AI_REVIEW,          // AI code review
    AI_HIGH_COST        // Use expensive models (Opus)
}
```

### 4.4 Approval Workflows

| Action | Default | Configurable |
|--------|---------|--------------|
| Create code file | Requires approval | Yes |
| Modify code file | Requires approval | Yes |
| Delete file | Always requires approval | No |
| Create branch | Auto-approved | Yes |
| Create PR | Auto-approved | Yes |
| Merge PR | Requires human review | Yes |
| Deploy to DEV | Auto-approved | Yes |
| Deploy to QA | Requires approval | Yes |
| Deploy to PROD | Always requires approval | No |

---

## 5. Agent Lifecycle

### 5.1 Agent States

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         AGENT LIFECYCLE                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐   │
│   │ IDLE    │───▶│ STARTED │───▶│ WORKING │───▶│ PENDING │───▶│ COMPLETE│   │
│   └─────────┘    └─────────┘    └─────────┘    │ APPROVAL│    └─────────┘   │
│        ▲                             │         └─────────┘         │         │
│        │                             │              │              │         │
│        │                             ▼              ▼              ▼         │
│        │                        ┌─────────┐   ┌─────────┐    ┌─────────┐    │
│        └────────────────────────│ ERROR   │   │REJECTED │    │ APPLIED │    │
│                                 └─────────┘   └─────────┘    └─────────┘    │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

States:
  IDLE          - Agent is available
  STARTED       - Agent has received a task
  WORKING       - Agent is processing (AI call in progress)
  PENDING_APPROVAL - Agent has output waiting for human review
  COMPLETE      - Task finished (may or may not need action)
  ERROR         - Agent encountered an error
  REJECTED      - Human rejected the agent's output
  APPLIED       - Agent's changes were applied (committed, deployed)
```

### 5.2 Lifecycle Events

| Event | Trigger | Action |
|-------|---------|--------|
| `agent.started` | User invokes agent | Log start, reserve credits |
| `agent.working` | AI call begins | Show progress indicator |
| `agent.output_ready` | AI response received | Parse response, validate |
| `agent.approval_requested` | Requires approval | Notify approvers |
| `agent.approved` | User approves | Apply changes |
| `agent.rejected` | User rejects | Log reason, return to idle |
| `agent.applied` | Changes committed | Update ticket, notify |
| `agent.error` | Any error | Log error, refund credits |

---

## 6. Agent Configuration

### 6.1 Organization-Level Config

```json
{
  "org_id": "uuid-org",
  "agent_config": {
    "enabled_agents": ["DEV_AGENT", "REVIEW_AGENT", "TEST_AGENT", "DOC_AGENT"],
    "disabled_agents": ["DEVOPS_AGENT"],
    "default_provider": "claude",
    "fallback_provider": "gemini",
    "require_approval": {
      "file_create": true,
      "file_modify": true,
      "file_delete": true,
      "pr_merge": true
    },
    "budget": {
      "monthly_limit_usd": 500,
      "per_agent_limit": {
        "ARCH_AGENT": 100,
        "DEV_AGENT": 200,
        "REVIEW_AGENT": 100
      },
      "alert_threshold_percent": 80
    },
    "model_preferences": {
      "simple_tasks": "claude-3-haiku",
      "medium_tasks": "claude-3-5-sonnet",
      "complex_tasks": "claude-opus-4"
    }
  }
}
```

### 6.2 Domain-Level Config (agent.md)

Each domain can have an `agent.md` file that provides agent-specific rules:

```markdown
# Agent Rules for NutriNine Backend

## Code Style
- Use Spring Boot 3.2 conventions
- All services must be @Transactional
- Use ModelMapper for DTO conversions
- UUID for all primary keys

## Database
- Use Flyway migrations (V{num}__description.sql)
- Never use ALTER TABLE DROP COLUMN without backup
- Always add indexes on foreign keys

## API Design
- REST endpoints under /api
- Use pagination for list endpoints
- Return 201 for POST, 200 for PUT
- Use problem+json for errors

## Testing
- Minimum 80% code coverage
- Use @SpringBootTest for integration tests
- Mock external services

## Forbidden
- Never expose passwords or secrets
- Never use SELECT * in queries
- Never commit .env files
```

### 6.3 User-Level Preferences

```json
{
  "user_id": "uuid-user",
  "ai_preferences": {
    "preferred_model": "claude-3-5-sonnet",
    "temperature": 0.7,
    "response_style": "detailed",
    "code_style": {
      "indentation": "spaces",
      "indent_size": 4,
      "quotes": "double"
    },
    "notifications": {
      "agent_complete": true,
      "approval_needed": true,
      "error_occurred": true
    },
    "byok": {
      "enabled": false,
      "provider": null,
      "api_key_vault_path": null
    }
  }
}
```

---

## 7. Agent Communication

### 7.1 Agent-to-Agent Communication

Agents can delegate tasks to other agents within a workflow:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    AGENT COMMUNICATION FLOW                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   User: "Add preferredDeliveryTime to Order"                                 │
│                      │                                                        │
│                      ▼                                                        │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    ANALYST_AGENT                                     │   │
│   │  "Break down into subtasks"                                          │   │
│   │  Output: 5 subtasks (migration, entity, DTO, service, test)         │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                      │                                                        │
│          ┌───────────┼───────────┬───────────┬───────────┐                  │
│          ▼           ▼           ▼           ▼           ▼                  │
│   ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐    │
│   │ DEV_AGENT │ │ DEV_AGENT │ │ DEV_AGENT │ │ DEV_AGENT │ │ TEST_AGENT│    │
│   │ Migration │ │ Entity    │ │ DTO       │ │ Service   │ │ Tests     │    │
│   └───────────┘ └───────────┘ └───────────┘ └───────────┘ └───────────┘    │
│          │           │           │           │           │                  │
│          └───────────┴───────────┴───────────┴───────────┘                  │
│                                  │                                           │
│                                  ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    REVIEW_AGENT                                      │   │
│   │  "Review all changes together"                                       │   │
│   │  Output: Approval or feedback                                        │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Communication Protocol

```java
public class AgentMessage {
    UUID messageId;
    UUID sourceAgentId;
    UUID targetAgentId;
    String messageType;      // REQUEST, RESPONSE, DELEGATE, NOTIFY
    String payload;          // JSON content
    Map<String, String> metadata;
    LocalDateTime timestamp;
}

// Message Types
public enum AgentMessageType {
    REQUEST,        // Ask another agent to do something
    RESPONSE,       // Reply to a request
    DELEGATE,       // Hand off task to another agent
    NOTIFY,         // Inform about status change
    ESCALATE,       // Escalate to human
    COMPLETE        // Signal task completion
}
```

---

## 8. Agent Context & Memory

### 8.1 Context Sources

| Source | Description | Token Cost | Cache Duration |
|--------|-------------|------------|----------------|
| Codebase Index | Compressed summary of repo | ~5,000 | Until git push |
| Ticket Context | Current ticket + parent | ~1,000 | Per request |
| Agent Rules | Domain's agent.md | ~1,000 | Until file change |
| Conversation History | Recent messages | ~2,000 | Session |
| Memory Chunks | Long-term learnings | ~500 | Permanent |
| File Contents | Actual code being modified | Variable | 15 min cache |

### 8.2 Memory System

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         AGENT MEMORY ARCHITECTURE                             │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   SHORT-TERM MEMORY (Session)                                                │
│   ├── Current conversation                                                   │
│   ├── Recent file changes                                                    │
│   ├── Pending approvals                                                      │
│   └── Stored in: QUAD_ai_conversations + QUAD_ai_messages                   │
│                                                                               │
│   MEDIUM-TERM MEMORY (Days)                                                  │
│   ├── Recent tickets worked on                                               │
│   ├── User preferences observed                                              │
│   ├── Common patterns detected                                               │
│   └── Stored in: QUAD_ai_analysis_cache                                     │
│                                                                               │
│   LONG-TERM MEMORY (Permanent)                                               │
│   ├── Codebase patterns                                                      │
│   ├── Team coding style                                                      │
│   ├── Business domain knowledge                                              │
│   ├── Past decisions & rationale                                             │
│   └── Stored in: QUAD_memory_chunks + QUAD_memory_keywords                  │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Memory Retrieval

```java
public class AgentContextBuilder {

    public AgentContext buildContext(UUID ticketId, UUID domainId) {
        // 1. Load codebase index (cached)
        CodebaseIndex index = indexService.getByDomain(domainId);

        // 2. Load agent rules
        String agentRules = ruleService.getAgentRules(domainId);

        // 3. Load ticket context
        Ticket ticket = ticketService.getWithParent(ticketId);

        // 4. Search relevant memories
        List<MemoryChunk> memories = memoryService.searchByKeywords(
            extractKeywords(ticket.getTitle() + " " + ticket.getDescription()),
            domainId,
            5  // top 5 relevant memories
        );

        // 5. Load conversation history (if continuing)
        List<AIMessage> history = conversationService.getRecent(ticketId, 10);

        return AgentContext.builder()
            .codebaseIndex(index)
            .agentRules(agentRules)
            .ticket(ticket)
            .memories(memories)
            .conversationHistory(history)
            .build();
    }
}
```

---

## 9. Agent Routing & Selection

### 9.1 Automatic Agent Selection

```java
public class AgentRouter {

    public AgentType selectAgent(TaskContext context) {
        String task = context.getTaskDescription().toLowerCase();

        // Rule-based routing
        if (containsAny(task, "implement", "add feature", "create", "code")) {
            return AgentType.DEV_AGENT;
        }
        if (containsAny(task, "review", "check", "audit code")) {
            return AgentType.REVIEW_AGENT;
        }
        if (containsAny(task, "test", "unit test", "integration test")) {
            return AgentType.TEST_AGENT;
        }
        if (containsAny(task, "document", "readme", "api docs")) {
            return AgentType.DOC_AGENT;
        }
        if (containsAny(task, "architecture", "design", "system")) {
            return AgentType.ARCH_AGENT;
        }
        if (containsAny(task, "security", "vulnerability", "owasp")) {
            return AgentType.SEC_AGENT;
        }
        if (containsAny(task, "deploy", "ci/cd", "pipeline", "build")) {
            return AgentType.DEVOPS_AGENT;
        }
        if (containsAny(task, "analyze", "break down", "estimate", "plan")) {
            return AgentType.ANALYST_AGENT;
        }

        // Default to analyst for ambiguous tasks
        return AgentType.ANALYST_AGENT;
    }
}
```

### 9.2 Model Selection Per Agent

| Agent Type | Simple Task | Medium Task | Complex Task |
|------------|-------------|-------------|--------------|
| DEV_AGENT | Haiku | Sonnet | Opus |
| REVIEW_AGENT | Sonnet | Sonnet | Opus |
| TEST_AGENT | Haiku | Sonnet | Sonnet |
| DOC_AGENT | Haiku | Gemini Pro | Gemini Pro |
| ANALYST_AGENT | Gemini Flash | Gemini Pro | Sonnet |
| ARCH_AGENT | Sonnet | Opus | Opus |
| SEC_AGENT | Sonnet | Opus | Opus |
| DEVOPS_AGENT | Haiku | Sonnet | Sonnet |

---

## 10. Database Tables

### 10.1 Agent-Related Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `QUAD_ai_configs` | Org AI settings | enabled_agents, budget, approval_rules |
| `QUAD_ai_provider_config` | Provider configs | provider, api_key_vault_path, priority |
| `QUAD_ai_activity_routing` | Agent→Model mapping | activity_type, provider, model_id |
| `QUAD_ai_conversations` | Chat sessions | scope_type, agent_type, status |
| `QUAD_ai_messages` | Messages | role, content, suggestion_data |
| `QUAD_ai_operations` | Operation log | agent_type, model_used, tokens, cost |
| `QUAD_ai_code_reviews` | Code reviews | review_type, severity, suggestions |
| `QUAD_memory_chunks` | Long-term memory | scope, content, keywords |
| `QUAD_codebase_indexes` | Codebase context | summaries, token_count |

### 10.2 Table Relationships

```
QUAD_organizations
    │
    ├── QUAD_ai_configs (1:1)
    │       │
    │       └── QUAD_ai_provider_config (1:N)
    │               │
    │               └── QUAD_ai_activity_routing (1:N)
    │
    ├── QUAD_ai_conversations (1:N)
    │       │
    │       └── QUAD_ai_messages (1:N)
    │
    ├── QUAD_ai_operations (1:N)
    │
    └── QUAD_memory_chunks (1:N)
            │
            └── QUAD_memory_keywords (1:N)
```

---

## 11. API Endpoints

### 11.1 Agent Operations

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ai/agents` | GET | List available agents for user |
| `/api/ai/agents/{type}/invoke` | POST | Start agent task |
| `/api/ai/agents/{type}/status/{taskId}` | GET | Check agent status |
| `/api/ai/agents/{type}/cancel/{taskId}` | POST | Cancel running task |
| `/api/ai/suggestions/{id}/approve` | POST | Approve agent output |
| `/api/ai/suggestions/{id}/reject` | POST | Reject agent output |
| `/api/ai/suggestions/{id}/modify` | PUT | Modify before applying |

### 11.2 Agent Configuration

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/admin/ai/agents/config` | GET/PUT | Org agent settings |
| `/api/admin/ai/agents/{type}/enable` | POST | Enable agent |
| `/api/admin/ai/agents/{type}/disable` | POST | Disable agent |
| `/api/admin/ai/budget` | GET/PUT | Budget settings |
| `/api/admin/ai/approval-rules` | GET/PUT | Approval workflows |

### 11.3 Agent History

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ai/history` | GET | User's agent history |
| `/api/ai/history/{operationId}` | GET | Operation details |
| `/api/admin/ai/history` | GET | Org-wide history |
| `/api/admin/ai/usage` | GET | Usage analytics |

---

## 12. Security & Audit

### 12.1 Security Controls

| Control | Description |
|---------|-------------|
| **API Key Encryption** | Keys stored in Vault, never in DB |
| **Action Logging** | Every agent action logged to QUAD_ai_operations |
| **Approval Workflow** | Sensitive actions require human approval |
| **Budget Limits** | Prevents runaway costs |
| **Rate Limiting** | Per-user, per-org limits |
| **Scope Isolation** | Agents only access their domain's code |

### 12.2 Audit Trail

```java
public class AgentAuditLog {
    UUID id;
    UUID orgId;
    UUID userId;
    UUID domainId;
    UUID ticketId;

    String agentType;           // DEV_AGENT, REVIEW_AGENT, etc.
    String action;              // invoke, approve, reject, apply
    String provider;            // claude, gemini, openai
    String model;               // claude-3-5-sonnet, etc.

    int inputTokens;
    int outputTokens;
    BigDecimal costUsd;

    String inputSummary;        // What was asked
    String outputSummary;       // What was produced
    String approvedBy;          // Who approved (if applicable)

    LocalDateTime createdAt;
    long durationMs;
}
```

### 12.3 Compliance

| Requirement | Implementation |
|-------------|----------------|
| GDPR | User can request agent history deletion |
| SOC 2 | Full audit trail, access controls |
| HIPAA | No PHI in agent context (for healthcare orgs) |
| Data Residency | Provider selection respects data location |

---

## 13. References

### 13.1 Related Documents

| Document | Path | Description |
|----------|------|-------------|
| AI Agent Architecture | [AI_AGENT_ARCHITECTURE.md](./AI_AGENT_ARCHITECTURE.md) | Technical implementation details |
| Database Schema | [../quad-database/schema.prisma](../quad-database/schema.prisma) | Full database schema |
| API Documentation | [../api/API_DOCUMENTATION.md](../api/API_DOCUMENTATION.md) | REST API reference |
| Next Steps | [../NEXT_STEPS.md](../NEXT_STEPS.md) | Development roadmap |
| AI Provider Config | [../../quad-database/sql/seeds/003_ai_providers.dta.sql](../../quad-database/sql/seeds/003_ai_providers.dta.sql) | Provider seed data |

### 13.2 External References

| Resource | URL | Purpose |
|----------|-----|---------|
| Claude API | https://docs.anthropic.com | Anthropic Claude |
| Gemini API | https://ai.google.dev/docs | Google Gemini |
| OpenAI API | https://platform.openai.com/docs | OpenAI GPT |
| GitHub API | https://docs.github.com/en/rest | Git operations |

---

**Document Version:** 1.0
**Author:** QUAD Development Team
**Last Updated:** January 3, 2026

### Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 3, 2026 | Initial agent documentation with types, groups, permissions |
