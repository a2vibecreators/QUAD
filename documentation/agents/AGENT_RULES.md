# QUAD Framework - AI Agent Rules

**Version:** 1.0
**Last Updated:** January 4, 2026

---

## Table of Contents
1. [Project Vision](#project-vision)
2. [Critical Rules (1-10)](#critical-rules-1-10)
3. [Code Conventions (11-20)](#code-conventions-11-20)
4. [Documentation Rules (21-30)](#documentation-rules-21-30)
5. [Ticket Management Rules (31-40)](#ticket-management-rules-31-40)
6. [Agent Must Refuse](#agent-must-refuse)
7. [Session Management](#session-management)

---

## Project Vision

**QUAD Framework** is an AI-native project management platform that brings together:
- **Developers** - AI-assisted ticket work, code reviews, deployments
- **Organizations** - Multi-tenant workspace management
- **AI Providers** - Claude, Gemini, OpenAI, DeepSeek (AI-agnostic)
- **Infrastructure** - Ephemeral sandboxes for cloud builds

**Design Principle:** Every feature should leverage AI capabilities. Ask: "Does this make developers more productive? Does this use AI intelligently?"

---

## Critical Rules (1-10)

### Rule 1: Never Use Hibernate Auto-DDL

```java
// ALWAYS use: spring.jpa.hibernate.ddl-auto=validate
// NEVER use: update, create, create-drop
```

Schema managed manually via `quad-database/sql/` directory with modular SQL files.

### Rule 2: Read Before Changing

Before modifying ANY file:
1. Read the current file completely
2. Read related files (Entity → Repository → Service → Controller)
3. Check DATABASE_ARCHITECTURE.md for design reasoning
4. Check existing tests in quad-services/src/test/

### Rule 3: Get Approval for Architecture Changes

**MUST GET USER APPROVAL for:**
- Primary key type changes (UUID ↔ BIGINT)
- Adding/removing indexes, triggers, functions
- Relationship type changes (1:1 ↔ 1:N)
- Authentication mechanism changes
- Adding new libraries/frameworks
- Renaming tables/columns
- Adding NOT NULL constraints

### Rule 4: Update Documentation Immediately

| Change Type | Files to Update |
|-------------|-----------------|
| Schema change | SQL file, DATABASE_ARCHITECTURE.md |
| Feature implemented | Test file, README.md |
| API endpoint added | Controller Javadoc, test case |
| Architecture decision | ADR document |

### Rule 5: Test-First Mindset

- Write/update tests BEFORE marking work as done
- All new entities need corresponding service tests
- Follow BaseServiceTest pattern for integration tests
- Minimum: findAll, findById, save, update, deleteById, existsById

### Rule 6: Use Graph Theory Terminology for Tickets

| Concept | Term | Description |
|---------|------|-------------|
| Blocking tickets | **IN-DEGREE** | Number of tickets that must complete first |
| Dependent tickets | **OUT-DEGREE** | Number of tickets blocked by this one |
| Ticket with no blockers | **SOURCE** | IN-DEGREE = 0 |
| Ticket with no dependents | **SINK** | OUT-DEGREE = 0 |
| Ticket blockers | **PRECONDITIONS** or **GATES** | What must be done first |
| Valid execution order | **TOPOLOGICAL SORT** | Order respecting dependencies |

### Rule 7: QUAD_ Prefix for All Database Objects

```sql
-- Tables
CREATE TABLE QUAD_tickets (...);

-- Functions
CREATE FUNCTION QUAD_init_company_roles(...);

-- Triggers
CREATE TRIGGER trg_QUAD_tickets_updated_at ...;
```

### Rule 8: No Breaking Changes Without Migration

Before any breaking change:
1. Check for existing data
2. Create migration script in `quad-database/migrations/`
3. Test on data copy
4. Document rollback procedure
5. Get user approval

### Rule 9: UUID Primary Keys Only

All entities use UUID primary keys for distributed system compatibility:

```java
@Id
@GeneratedValue(strategy = GenerationType.UUID)
@Column(name = "id", updatable = false, nullable = false)
private UUID id;
```

### Rule 10: No Wildcard Imports in Java

```java
// WRONG
import org.springframework.http.*;
import java.util.*;

// CORRECT
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import java.util.List;
import java.util.UUID;
```

---

## Code Conventions (11-20)

### Rule 11: Entity Field Naming

| Column Type | Java Field | Database Column |
|-------------|------------|-----------------|
| Primary Key | `id` | `id` |
| Foreign Key | `domainId` | `domain_id` |
| Timestamps | `createdAt` | `created_at` |
| Boolean | `isActive` | `is_active` |
| Status | `status` | `status` |

### Rule 12: Service Method Naming

| Operation | Method Name | Return Type |
|-----------|-------------|-------------|
| Get all | `findAll()` | `List<T>` |
| Get by ID | `findById(UUID id)` | `Optional<T>` |
| Create/Update | `save(T entity)` | `T` |
| Update existing | `update(UUID id, T entity)` | `T` |
| Delete | `deleteById(UUID id)` | `void` |
| Check exists | `existsById(UUID id)` | `boolean` |

### Rule 13: Test Class Structure

```java
@DisplayName("ServiceName Tests")
class ServiceNameTest extends BaseServiceTest {

    @Nested
    @DisplayName("methodName()")
    class MethodNameTests {

        @Test
        @DisplayName("should do X when Y")
        void shouldDoXWhenY() { ... }
    }
}
```

### Rule 14: Controller Endpoint Patterns

| Operation | HTTP Method | Path | Body |
|-----------|-------------|------|------|
| List all | GET | `/api/{resources}` | - |
| Get one | GET | `/api/{resources}/{id}` | - |
| Create | POST | `/api/{resources}` | JSON |
| Update | PUT | `/api/{resources}/{id}` | JSON |
| Delete | DELETE | `/api/{resources}/{id}` | - |

### Rule 15: Use DTOs for API Layer

- Entities for database layer only
- DTOs for controller layer
- ModelMapper for conversions
- Never expose entities directly in REST responses

### Rule 16: @NonNull on Service Parameters

```java
public Ticket findById(@NonNull UUID id) {
    return ticketRepository.findById(id)
        .orElseThrow(() -> new EntityNotFoundException("Ticket not found: " + id));
}
```

### Rule 17: Lombok Annotations Order

```java
@Entity
@Table(name = "QUAD_tickets")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ticket { ... }
```

### Rule 18: Consistent Error Messages

```java
throw new EntityNotFoundException("Ticket not found with id: " + id);
throw new IllegalStateException("Cannot delete ticket in DONE status");
throw new ValidationException("Cycle must have start_date before end_date");
```

### Rule 19: Transaction Boundaries

- `@Transactional` on service methods, not repository
- Read-only operations: `@Transactional(readOnly = true)`
- Complex operations: explicit transaction management

### Rule 20: Dependency Injection Style

```java
// Prefer constructor injection
private final TicketRepository ticketRepository;
private final DomainService domainService;

@Autowired
public TicketServiceImpl(TicketRepository ticketRepository, DomainService domainService) {
    this.ticketRepository = ticketRepository;
    this.domainService = domainService;
}
```

---

## Documentation Rules (21-30)

### Rule 21: Every MD File Needs TOC

Add Table of Contents to all markdown files over 100 lines.

### Rule 22: Document Versioning

Key documents need version header:
```markdown
**Version:** 1.0
**Last Updated:** January 4, 2026
```

### Rule 23: ADR Format for Architecture Decisions

```markdown
# ADR-001: Use UUID Primary Keys

## Status
Accepted

## Context
We need unique identifiers across distributed systems.

## Decision
Use UUID v4 for all primary keys.

## Consequences
- (+) Globally unique without coordination
- (+) Can generate IDs client-side
- (-) Larger than BIGINT (16 bytes vs 8)
```

### Rule 24: README.md at Each Major Directory

- Root: Comprehensive project overview
- quad-services/: Backend setup guide
- quad-web/: Frontend setup guide
- quad-database/: Schema overview

### Rule 25: Keep Documentation DRY

- Single source of truth for each concept
- Cross-reference instead of duplicating
- Use relative links for navigation

### Rule 26: Code Examples in Documentation

Always include runnable examples:
```bash
# Run tests
mvn test -Dtest=TicketServiceTest -DskipTests=false
```

### Rule 27: Update Docs Before PRs

Documentation must be updated in the same commit as code changes.

### Rule 28: Deprecation Documentation

Mark deprecated items clearly:
```java
/**
 * @deprecated Use {@link #newMethod()} instead. Will be removed in v2.0.
 */
@Deprecated(since = "1.5", forRemoval = true)
public void oldMethod() { ... }
```

### Rule 29: API Documentation via Javadoc

```java
/**
 * Creates a new ticket in the specified domain and cycle.
 *
 * @param ticket The ticket to create (must have domainId and cycleId set)
 * @return The created ticket with generated ID
 * @throws EntityNotFoundException if domain or cycle doesn't exist
 * @throws ValidationException if required fields are missing
 */
public Ticket save(Ticket ticket);
```

### Rule 30: Changelog Format

```markdown
## [1.0.0] - 2026-01-04

### Added
- Initial database schema with 127 tables
- Service layer for Level 1-2 entities

### Changed
- Upgraded Lombok to 1.18.38 for Java 21 compatibility

### Fixed
- TestDataFactory entity field mismatches
```

---

## Ticket Management Rules (31-40)

### Rule 31: Ticket Lifecycle States

```
BACKLOG → READY → IN_PROGRESS → IN_REVIEW → DONE
              ↘           ↙
               BLOCKED
```

### Rule 32: Dependency Gates (PRECONDITIONS)

A ticket cannot move from READY to IN_PROGRESS unless:

| Gate | Condition |
|------|-----------|
| **DEPENDENCY_GATE** | All IN-DEGREE tickets are DONE |
| **CYCLE_GATE** | Cycle has started (start_date <= today) |
| **ASSIGNMENT_GATE** | Ticket has assignee |
| **CAPACITY_GATE** | Assignee has available capacity (optional) |

### Rule 33: Story Points as Fibonacci

Use Fibonacci sequence: 1, 2, 3, 5, 8, 13, 21

| Points | Meaning |
|--------|---------|
| 1 | Trivial change (typo fix) |
| 2 | Simple task (add field) |
| 3 | Small feature (CRUD) |
| 5 | Medium feature (with validation) |
| 8 | Complex feature (multi-entity) |
| 13 | Large feature (needs breakdown) |
| 21 | Epic (must be split) |

### Rule 34: Ticket Type Hierarchy

```
EPIC (container)
  └── USER_STORY (feature)
        └── TASK (implementation unit)
              └── BUG (defect)
```

### Rule 35: Branch Naming from Tickets

```
{type}/{ticket-id}-{short-description}

feature/QUAD-123-add-sandbox-api
bugfix/QUAD-456-fix-null-pointer
chore/QUAD-789-update-dependencies
```

### Rule 36: Commit Message Format

```
[QUAD-123] Add sandbox creation API

- Add SandboxService with create/destroy methods
- Add SandboxController with POST/DELETE endpoints
- Add integration tests for sandbox lifecycle
```

### Rule 37: PR Template

```markdown
## What
[Brief description of changes]

## Why
[Link to ticket: QUAD-123]

## How
[Technical approach]

## Testing
- [ ] Unit tests added
- [ ] Integration tests pass
- [ ] Manual testing done

## Screenshots
[If UI changes]
```

### Rule 38: Code Review Checklist

- [ ] Tests cover happy path and edge cases
- [ ] No wildcard imports
- [ ] Documentation updated
- [ ] No TODO comments without ticket reference
- [ ] Error handling is appropriate
- [ ] Logging is sufficient

### Rule 39: Sandbox Association

Every ticket in IN_PROGRESS should have an associated sandbox:
- `ticket_sandbox_groups` links tickets to sandboxes
- Sandboxes auto-expire after 72 hours of inactivity
- Multiple tickets can share a sandbox

### Rule 40: Ticket Time Tracking

```java
// Start work
ticketTimeLogService.startWork(ticketId, userId);

// End work
ticketTimeLogService.endWork(ticketId, userId, "Completed API implementation");
```

---

## Agent Must Refuse

1. Using hibernate.ddl-auto except "validate"
2. Making architecture changes without approval
3. Modifying code without reading first
4. Making changes without updating tests
5. Force pushing to main/master
6. Committing without tests passing
7. Using wildcard imports in Java
8. Creating entities without service tests
9. Changing schema without SQL migration file
10. Deploying to production without user approval

---

## Session Management

### Context Files to Read on Init

1. `CLAUDE.md` - Project overview
2. `documentation/agents/AGENT_RULES.md` - This file
3. `documentation/database/DATABASE_ARCHITECTURE.md` - Schema details
4. `PROJECT_STATUS.md` - Current sprint status

### Session History Format

```markdown
| Date | Topic | Outcome |
|------|-------|---------|
| Jan 4 | Service Tests | 65 tests passing for Level 1-2 services |
| Jan 4 | Database Docs | Created DATABASE_ARCHITECTURE.md (127 tables) |
```

### Before Making Changes

```
1. Read related files first
2. Present proposal to user
3. List ALL changes being made
4. Explain WHY needed
5. Wait for EXPLICIT approval
6. If no approval → STOP and wait
```

### Session End Checklist

- [ ] Update SESSION_HISTORY.md with outcomes
- [ ] Update affected documentation
- [ ] Run tests to verify nothing broke
- [ ] Commit changes with proper message

---

## Quick Reference - All Rules

| # | Category | Name | Key Point |
|---|----------|------|-----------|
| 1 | Critical | No Auto-DDL | Always use `validate` |
| 2 | Critical | Read First | Understand before changing |
| 3 | Critical | Get Approval | Architecture needs approval |
| 4 | Critical | Update Docs | Immediately after changes |
| 5 | Critical | Test First | Tests before marking done |
| 6 | Critical | Graph Terms | IN-DEGREE, OUT-DEGREE, GATES |
| 7 | Critical | QUAD_ Prefix | All DB objects prefixed |
| 8 | Critical | No Breaking | Migration scripts required |
| 9 | Critical | UUID Keys | All entities use UUID |
| 10 | Critical | No Wildcards | Explicit Java imports |
| 11 | Code | Field Naming | camelCase → snake_case |
| 12 | Code | Method Naming | findAll, findById, save, etc. |
| 13 | Code | Test Structure | Nested @DisplayName classes |
| 14 | Code | Endpoints | REST resource patterns |
| 15 | Code | DTOs | Never expose entities |
| 16 | Code | @NonNull | On service parameters |
| 17 | Code | Lombok Order | @Entity, @Table, @Data, etc. |
| 18 | Code | Error Messages | Consistent format |
| 19 | Code | Transactions | On service methods |
| 20 | Code | DI Style | Constructor injection |
| 21 | Docs | TOC Required | Files > 100 lines |
| 22 | Docs | Versioning | Version + date header |
| 23 | Docs | ADR Format | Status, Context, Decision |
| 24 | Docs | README | At major directories |
| 25 | Docs | DRY | No duplication |
| 26 | Docs | Examples | Runnable code samples |
| 27 | Docs | Before PR | Docs in same commit |
| 28 | Docs | Deprecation | Clear marking |
| 29 | Docs | API Docs | Javadoc on public methods |
| 30 | Docs | Changelog | Added/Changed/Fixed |
| 31 | Tickets | States | BACKLOG → DONE lifecycle |
| 32 | Tickets | Gates | DEPENDENCY, CYCLE, ASSIGNMENT |
| 33 | Tickets | Points | Fibonacci sequence |
| 34 | Tickets | Types | EPIC → STORY → TASK → BUG |
| 35 | Tickets | Branches | type/ticket-id-description |
| 36 | Tickets | Commits | [QUAD-123] message |
| 37 | Tickets | PRs | Template with checklist |
| 38 | Tickets | Reviews | Checklist items |
| 39 | Tickets | Sandboxes | Auto-association |
| 40 | Tickets | Time | Start/end tracking |

---

**Author:** QUAD Framework Team
**Version:** 1.0
