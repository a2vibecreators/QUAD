# QUAD Framework - Database Architecture

## Table of Contents
1. [Overview](#overview)
2. [Table Count Summary](#table-count-summary)
3. [Domain Categories](#domain-categories)
4. [Entity Relationship Model](#entity-relationship-model)
5. [Naming Conventions](#naming-conventions)
6. [Backend Entity Coverage](#backend-entity-coverage)
7. [Service Layer Mapping](#service-layer-mapping)
8. [Graph Theory Concepts](#graph-theory-concepts)

---

## Overview

QUAD Framework uses a modular PostgreSQL database architecture with **132 tables** organized into **16 domain categories**. Each table follows strict naming conventions with the `QUAD_` prefix for easy identification.

**Key Design Principles:**
- UUID primary keys for distributed system compatibility
- `created_at` and `updated_at` timestamps with triggers
- Soft deletes via `deleted_at` where applicable
- Multi-tenant support via `company_id` foreign keys
- JSONB columns for flexible metadata storage

---

## Table Count Summary

| Domain | Table Count | Description |
|--------|-------------|-------------|
| **ai** | 19 | AI providers, conversations, credits, RAG, ticket tracking |
| **analytics** | 9 | Metrics, rankings, predictions |
| **core** | 14 | Organizations, users, roles, sessions, rules |
| **domains** | 10 | Project domains, resources, attributes |
| **flows** | 9 | CI/CD flows, deployments, releases |
| **git** | 6 | Git integration, PRs, approvals |
| **infrastructure** | 9 | Sandboxes, codebase indexing, cache |
| **meetings** | 4 | Meeting integrations, action items |
| **memory** | 8 | AI memory, context, document chunks |
| **onboarding** | 8 | Developer onboarding, training |
| **other** | 16 | Notifications, approvals, misc |
| **portal** | 2 | External portal access |
| **security** | 4 | Secret scans, runbooks |
| **skills** | 3 | Developer skills tracking |
| **messenger** | 3 | Messenger channels (Slack, Teams, Discord, WhatsApp) |
| **tickets** | 8 | Tickets, cycles, circles |
| **TOTAL** | **132** | |

---

## Domain Categories

### 1. Core (14 tables)
Foundation tables for multi-tenant organization management.

| Table | Purpose |
|-------|---------|
| `QUAD_organizations` | Company/organization master |
| `QUAD_org_tiers` | Subscription tiers (FREE/BASIC/PRO/ENTERPRISE) |
| `QUAD_org_settings` | Organization-specific configurations |
| `QUAD_org_setup_status` | Onboarding completion tracking |
| `QUAD_org_members` | Organization membership |
| `QUAD_org_invitations` | Pending invitations |
| `QUAD_org_rules` | Org/domain/user rules with hierarchical resolution |
| `QUAD_users` | User accounts |
| `QUAD_user_sessions` | Active login sessions |
| `QUAD_roles` | Custom role definitions |
| `QUAD_core_roles` | System default roles |
| `QUAD_sso_configs` | SSO provider configurations |
| `QUAD_config_settings` | Global platform settings |
| `QUAD_email_verification_codes` | Email OTP verification |

### 2. Domains (10 tables)
Project domain hierarchy and resource management.

| Table | Purpose |
|-------|---------|
| `QUAD_domains` | Project domains (like Jira projects) |
| `QUAD_domain_members` | Domain team membership |
| `QUAD_domain_operations` | Domain activity log |
| `QUAD_domain_resources` | Compute resources (CPU/Memory quotas) |
| `QUAD_resource_attributes` | Custom resource properties |
| `QUAD_resource_attribute_requirements` | Required attribute definitions |
| `QUAD_workload_metrics` | Domain workload analytics |
| `QUAD_adoption_matrix` | Feature adoption tracking |
| `QUAD_requirements` | Domain requirements/epics |
| `QUAD_milestones` | Domain milestones |

### 3. Tickets (8 tables)
Work item management with graph-based dependencies.

| Table | Purpose |
|-------|---------|
| `QUAD_tickets` | Main ticket/work item table |
| `QUAD_ticket_comments` | Ticket discussion threads |
| `QUAD_ticket_time_logs` | Time tracking entries |
| `QUAD_ticket_skills` | Skills required for ticket |
| `QUAD_assignment_scores` | AI-calculated assignment fit scores |
| `QUAD_cycles` | Sprints/iterations |
| `QUAD_circles` | Teams within domains |
| `QUAD_circle_members` | Team membership |

### 4. AI (19 tables)
Multi-provider AI integration with credit management and ticket-level consumption tracking.

| Table | Purpose |
|-------|---------|
| `QUAD_ai_provider_config` | AI provider settings (Claude, Gemini, OpenAI) |
| `QUAD_ai_configs` | Domain-specific AI configuration |
| `QUAD_ai_operations` | AI operation audit log |
| `QUAD_ai_contexts` | Saved AI context windows |
| `QUAD_ai_context_relationships` | Context linkages |
| `QUAD_ai_conversations` | AI conversation sessions |
| `QUAD_ai_messages` | Individual messages in conversations |
| `QUAD_ai_code_reviews` | AI-powered code review results |
| `QUAD_ai_user_memories` | Per-user AI memory |
| `QUAD_ai_activity_routing` | AI activity routing rules |
| `QUAD_ai_analysis_cache` | Cached AI analysis results |
| `QUAD_ai_credit_balances` | Per-org AI credit balance |
| `QUAD_ai_credit_transactions` | Credit usage transactions |
| `QUAD_platform_credit_pool` | Platform-wide credit pool |
| `QUAD_platform_pool_transactions` | Pool allocation transactions |
| `QUAD_rag_indexes` | RAG vector index metadata |
| `QUAD_ticket_ai_sessions` | Per-ticket AI session tracking |
| `QUAD_ticket_ai_requests` | Individual AI requests with debug payloads |
| `QUAD_ticket_ai_summary` | Compacted AI usage totals per ticket |

### 5. Flows (9 tables)
CI/CD pipeline and deployment management.

| Table | Purpose |
|-------|---------|
| `QUAD_flows` | CI/CD flow definitions |
| `QUAD_flow_branches` | Branch-specific flow configs |
| `QUAD_flow_stage_history` | Flow execution history |
| `QUAD_environments` | Deployment environments (dev/qa/prod) |
| `QUAD_deployment_recipes` | Deployment templates |
| `QUAD_deployments` | Actual deployment records |
| `QUAD_release_notes` | Release documentation |
| `QUAD_release_contributors` | Release credits |
| `QUAD_rollback_operations` | Rollback tracking |

### 6. Git (6 tables)
Git provider integration (GitHub, GitLab, Bitbucket).

| Table | Purpose |
|-------|---------|
| `QUAD_git_integrations` | Git provider OAuth configs |
| `QUAD_git_repositories` | Connected repositories |
| `QUAD_git_operations` | Git operation audit log |
| `QUAD_pull_requests` | PR tracking |
| `QUAD_pr_reviewers` | PR reviewer assignments |
| `QUAD_pr_approvals` | PR approval records |

### 7. Infrastructure (9 tables)
Cloud sandbox and codebase management.

| Table | Purpose |
|-------|---------|
| `QUAD_infrastructure_config` | Infrastructure provider settings |
| `QUAD_sandbox_instances` | Ephemeral sandbox containers |
| `QUAD_sandbox_usage` | Sandbox compute usage tracking |
| `QUAD_ticket_sandbox_groups` | Ticket-to-sandbox associations |
| `QUAD_codebase_files` | Indexed codebase files |
| `QUAD_codebase_indexes` | Search indexes |
| `QUAD_code_cache` | Cached code analysis |
| `QUAD_cache_usage` | Cache hit/miss metrics |
| `QUAD_indexing_usage` | Indexing operation metrics |

### 8. Memory (8 tables)
AI long-term memory and context management.

| Table | Purpose |
|-------|---------|
| `QUAD_memory_documents` | Stored documents for RAG |
| `QUAD_memory_chunks` | Document chunks with embeddings |
| `QUAD_memory_keywords` | Keyword extraction |
| `QUAD_memory_templates` | Memory prompt templates |
| `QUAD_memory_update_queue` | Async memory updates |
| `QUAD_context_sessions` | Context window sessions |
| `QUAD_context_requests` | Context retrieval requests |
| `QUAD_context_rules` | Context assembly rules |

### 9. Meetings (4 tables)
Calendar and meeting integration.

| Table | Purpose |
|-------|---------|
| `QUAD_meeting_integrations` | Calendar provider configs |
| `QUAD_meetings` | Meeting records |
| `QUAD_meeting_action_items` | Action items from meetings |
| `QUAD_meeting_follow_ups` | Follow-up reminders |

### 10. Onboarding (8 tables)
Developer onboarding workflows.

| Table | Purpose |
|-------|---------|
| `QUAD_developer_onboarding_templates` | Onboarding templates |
| `QUAD_developer_onboarding_progress` | Per-user progress |
| `QUAD_training_content` | Training materials |
| `QUAD_training_completions` | Training completion records |
| `QUAD_resource_setup_templates` | Environment setup templates |
| `QUAD_user_resource_setups` | Per-user resource configs |
| `QUAD_setup_bundles` | Bundled setup packages |
| `QUAD_user_setup_journeys` | Setup journey tracking |

### 11. Analytics (9 tables)
Metrics, predictions, and gamification.

| Table | Purpose |
|-------|---------|
| `QUAD_dora_metrics` | DORA metrics tracking |
| `QUAD_cycle_risk_predictions` | Sprint risk predictions |
| `QUAD_risk_factors` | Risk factor definitions |
| `QUAD_cost_estimates` | Ticket cost estimates |
| `QUAD_story_point_suggestions` | AI story point suggestions |
| `QUAD_technical_debt_scores` | Tech debt tracking |
| `QUAD_ranking_configs` | Gamification ranking rules |
| `QUAD_user_rankings` | User leaderboards |
| `QUAD_kudos` | Peer recognition |

### 12. Other (16 tables)
Miscellaneous supporting tables.

| Table | Purpose |
|-------|---------|
| `QUAD_notifications` | User notifications |
| `QUAD_notification_preferences` | Notification settings |
| `QUAD_work_sessions` | Developer work sessions |
| `QUAD_user_activity_summaries` | Activity analytics |
| `QUAD_approvals` | Generic approval workflows |
| `QUAD_database_connections` | External DB connections |
| `QUAD_database_operations` | DB operation log |
| `QUAD_database_approvals` | DB change approvals |
| `QUAD_file_imports` | File import tracking |
| `QUAD_api_access_config` | API key management |
| `QUAD_api_request_logs` | API request audit |
| `QUAD_user_role_allocations` | Role assignment tracking |
| `QUAD_validated_credentials` | Credential validation |
| `QUAD_verification_requests` | Account verification |
| `QUAD_anonymization_rules` | Data anonymization config |
| `QUAD_integration_health_checks` | Integration monitoring |

### 13. Portal (2 tables)
External partner portal access.

| Table | Purpose |
|-------|---------|
| `QUAD_portal_access` | External portal configurations |
| `QUAD_portal_audit_log` | Portal access audit |

### 14. Security (4 tables)
Security scanning and incident response.

| Table | Purpose |
|-------|---------|
| `QUAD_secret_scans` | Secret detection scans |
| `QUAD_secret_rotations` | Secret rotation tracking |
| `QUAD_incident_runbooks` | Incident response playbooks |
| `QUAD_runbook_executions` | Runbook execution history |

### 15. Skills (3 tables)
Developer skill management.

| Table | Purpose |
|-------|---------|
| `QUAD_skills` | Skill definitions |
| `QUAD_user_skills` | User skill levels |
| `QUAD_skill_feedback` | Skill assessment feedback |

### 16. Messenger (3 tables)
Channel-agnostic messenger integration supporting Slack, Teams, Discord, WhatsApp, Email, SMS.

| Table | Purpose |
|-------|---------|
| `QUAD_messenger_channels` | Connected channels per org (Slack, Teams, Discord, etc.) |
| `QUAD_messenger_commands` | Commands/triggers received (NOT chat content) |
| `QUAD_messenger_outbound` | Messages sent BY QUAD (notifications, responses) |

**Design Philosophy:**
- **Channel-agnostic**: Same commands work on all platforms
- **No message storage**: Only commands and bot responses (chat stays in platform)
- **Multi-channel**: One org can have Slack, Teams, and Discord simultaneously

---

## Entity Relationship Model

### Core Entity Hierarchy

```
Organization (company_id)
    │
    ├── OrgMember (user_id + company_id)
    │       └── User (id)
    │
    ├── Domain (company_id)
    │       ├── DomainMember (domain_id + user_id)
    │       ├── Circle (domain_id)
    │       │       └── CircleMember (circle_id + user_id)
    │       ├── Cycle (domain_id)
    │       │       └── Ticket (cycle_id)
    │       └── AiConfig (domain_id)
    │               └── AiConversation (domain_id)
    │
    └── SsoConfig (company_id)
```

### Ticket Dependency Graph (DAG)

```
           ┌─────────┐
           │ Epic-1  │ (IN-DEGREE: 0, OUT-DEGREE: 2)
           └────┬────┘
                │
       ┌────────┴────────┐
       ▼                 ▼
  ┌─────────┐       ┌─────────┐
  │Story-1.1│       │Story-1.2│ (IN-DEGREE: 1)
  └────┬────┘       └────┬────┘
       │                 │
       ▼                 ▼
  ┌─────────┐       ┌─────────┐
  │ Task-A  │       │ Task-B  │ (IN-DEGREE: 1, OUT-DEGREE: 0)
  └─────────┘       └─────────┘
```

---

## Naming Conventions

### Database Objects

| Object Type | Convention | Example |
|-------------|------------|---------|
| Tables | `QUAD_{domain}_{name}.tbl.sql` | `QUAD_tickets.tbl.sql` |
| Functions | `QUAD_{action}_{subject}.fnc.sql` | `QUAD_init_company_roles.fnc.sql` |
| Triggers | `trg_{table}_{event}` | `trg_tickets_updated_at` |
| Indexes | `idx_{table}_{columns}` | `idx_tickets_domain_id` |
| Foreign Keys | `fk_{table}_{ref_table}` | `fk_tickets_cycles` |

### Column Naming

| Column Type | Convention | Example |
|-------------|------------|---------|
| Primary Key | `id` (UUID) | `id` |
| Foreign Key | `{table}_id` | `domain_id`, `cycle_id` |
| Timestamps | `{action}_at` | `created_at`, `updated_at`, `deleted_at` |
| Status | `status` | `status` (enum) |
| Boolean | `is_{state}` or `has_{feature}` | `is_active`, `has_children` |
| Counts | `{noun}_count` | `ticket_count`, `member_count` |

---

## Backend Entity Coverage

### Level 1 - Core Services (7 entities)

| Entity | JPA Entity | Service | Repository | Status |
|--------|------------|---------|------------|--------|
| Organization | `Organization.java` | `OrganizationService` | `OrganizationRepository` | ✅ Tested |
| User | `User.java` | `UserService` | `UserRepository` | ✅ Tested |
| OrgMember | `OrgMember.java` | `OrgMemberService` | `OrgMemberRepository` | ✅ Tested |
| Domain | `Domain.java` | `DomainService` | `DomainRepository` | ✅ Tested |
| Cycle | `Cycle.java` | `CycleService` | `CycleRepository` | ✅ Ready |
| Circle | `Circle.java` | `CircleService` | `CircleRepository` | ✅ Ready |
| Ticket | `Ticket.java` | `TicketService` | `TicketRepository` | ✅ Tested |

### Level 2 - AI Services (4 entities)

| Entity | JPA Entity | Service | Repository | Status |
|--------|------------|---------|------------|--------|
| AiConfig | `AiConfig.java` | `AiConfigService` | `AiConfigRepository` | ✅ Ready |
| AiConversation | `AiConversation.java` | `AiConversationService` | `AiConversationRepository` | ✅ Ready |
| AiMessage | TBD | TBD | TBD | 🔜 Pending |
| AiOperation | TBD | TBD | TBD | 🔜 Pending |

### Level 3-5 - Future Phases

| Level | Domain | Tables | Status |
|-------|--------|--------|--------|
| Level 3 | Git Integration | 6 | 🔜 Pending |
| Level 4 | CI/CD Flows | 9 | 🔜 Pending |
| Level 5 | Infrastructure | 9 | 🔜 Pending |

---

## Service Layer Mapping

### Service Levels

```
Level 5: Infrastructure
    └── SandboxService, CodebaseService

Level 4: Flows
    └── FlowService, DeploymentService

Level 3: Git
    └── GitIntegrationService, PullRequestService

Level 2: AI
    └── AiConfigService, AiConversationService

Level 1: Core (Foundation)
    └── OrganizationService
        └── UserService
            └── OrgMemberService
                └── DomainService
                    └── CycleService
                        └── CircleService
                            └── TicketService
```

---

## Graph Theory Concepts

### Ticket Dependencies as DAG (Directed Acyclic Graph)

QUAD models ticket dependencies using graph theory terminology:

| Term | Graph Theory | QUAD Meaning |
|------|--------------|--------------|
| **Node** | Vertex | A ticket |
| **Edge** | Directed Edge | Dependency relationship |
| **IN-DEGREE** | # incoming edges | # of PRECONDITIONS (blockers) |
| **OUT-DEGREE** | # outgoing edges | # of DEPENDENTS (tickets blocked by this) |
| **Source** | Node with IN-DEGREE=0 | Epic or root ticket |
| **Sink** | Node with OUT-DEGREE=0 | Leaf task |
| **Topological Sort** | Linear ordering | Valid execution sequence |

### Ticket State Machine

```
BACKLOG ──→ READY ──→ IN_PROGRESS ──→ IN_REVIEW ──→ DONE
   │          │           │              │           │
   │          │           │              │           │
   └──────────┴───────────┴──────────────┴───────────┘
                         BLOCKED
```

### Preconditions (GATES)

A ticket cannot transition from READY to IN_PROGRESS unless:

1. **DEPENDENCY_GATE**: All tickets with `depends_on` relationship are DONE
2. **CYCLE_GATE**: Ticket's cycle has started (`cycle.start_date <= today`)
3. **ASSIGNMENT_GATE**: Ticket is assigned to a user
4. **CAPACITY_GATE**: User has available capacity (optional)

```sql
-- Check if ticket can start (all gates pass)
SELECT t.id,
       (SELECT COUNT(*) FROM ticket_dependencies td
        JOIN tickets dep ON td.depends_on_id = dep.id
        WHERE td.ticket_id = t.id AND dep.status != 'done') as blocking_count,
       CASE WHEN c.start_date <= CURRENT_DATE THEN true ELSE false END as cycle_started,
       t.assignee_id IS NOT NULL as is_assigned
FROM tickets t
JOIN cycles c ON t.cycle_id = c.id
WHERE t.id = :ticket_id;
```

---

## Related Documentation

- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - Prisma schema overview
- [ENTITY_IMPLEMENTATION_ORDER.md](ENTITY_IMPLEMENTATION_ORDER.md) - Implementation sequence
- [quad-services/documentation/TESTING_GUIDE.md](../../quad-services/documentation/TESTING_GUIDE.md) - How to run tests

---

**Last Updated:** January 4, 2026
**Version:** 1.2 (Renamed slack → messenger: channel-agnostic design with 3 tables supporting Slack, Teams, Discord, WhatsApp, Email, SMS)
