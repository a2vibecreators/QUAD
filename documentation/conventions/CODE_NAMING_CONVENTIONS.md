# QUAD Framework - Code Naming Conventions

## Table of Contents
1. [Overview](#overview)
2. [Database Naming](#database-naming)
3. [Java Backend Naming](#java-backend-naming)
4. [TypeScript/JavaScript Naming](#typescriptjavascript-naming)
5. [API Naming](#api-naming)
6. [File Naming](#file-naming)
7. [Git Conventions](#git-conventions)
8. [Terminology Glossary](#terminology-glossary)

---

## Overview

Consistent naming across the QUAD codebase ensures:
- **Readability** - Code is self-documenting
- **Discoverability** - Easy to find related code
- **Maintainability** - Reduced cognitive load
- **AI-Friendliness** - AI tools understand patterns better

**Golden Rule:** Names should be **predictable**. Given an entity name, you should be able to guess the table, service, controller, and endpoint names.

---

## Database Naming

### Tables

| Convention | Example |
|------------|---------|
| Prefix all tables with `QUAD_` | `QUAD_tickets` |
| Use lowercase snake_case | `QUAD_ticket_comments` |
| Use plural nouns for entity tables | `QUAD_organizations` |
| Use singular for junction tables | `QUAD_ticket_skill` (ticket has skill) |

```sql
-- GOOD
CREATE TABLE QUAD_tickets (...);
CREATE TABLE QUAD_ticket_comments (...);
CREATE TABLE QUAD_user_skills (...);

-- BAD
CREATE TABLE Tickets (...);         -- Missing prefix, wrong case
CREATE TABLE QUAD_TicketComments;   -- Wrong case
CREATE TABLE quad_ticket;           -- Singular
```

### Columns

| Column Type | Convention | Example |
|-------------|------------|---------|
| Primary Key | `id` (always UUID) | `id` |
| Foreign Key | `{referenced_table}_id` | `domain_id`, `cycle_id` |
| Timestamps | `{action}_at` | `created_at`, `updated_at`, `deleted_at` |
| Boolean | `is_{state}` or `has_{feature}` | `is_active`, `has_children` |
| Status | `status` (enum) | `status` |
| Count | `{noun}_count` | `ticket_count` |
| Name | `name` | `name` |
| Title | `title` | `title` |
| Description | `description` | `description` |
| Code | `{noun}_code` | `ticket_code`, `org_code` |
| Type | `{noun}_type` | `ticket_type` |

```sql
-- GOOD
CREATE TABLE QUAD_tickets (
    id UUID PRIMARY KEY,
    domain_id UUID REFERENCES QUAD_domains(id),
    cycle_id UUID REFERENCES QUAD_cycles(id),
    title VARCHAR(255) NOT NULL,
    ticket_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'backlog',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- BAD
CREATE TABLE QUAD_tickets (
    ticket_id UUID,           -- Should be just 'id'
    domainId UUID,            -- Should be domain_id
    type VARCHAR(20),         -- Should be ticket_type
    active BOOLEAN,           -- Should be is_active
    creation_date TIMESTAMP   -- Should be created_at
);
```

### Functions

| Convention | Example |
|------------|---------|
| Prefix with `QUAD_` | `QUAD_init_company_roles()` |
| Use snake_case | `QUAD_calculate_sprint_velocity()` |
| Start with verb | `QUAD_create_`, `QUAD_update_`, `QUAD_get_` |
| File extension `.fnc.sql` | `QUAD_init_company_roles.fnc.sql` |

### Triggers

| Convention | Example |
|------------|---------|
| Prefix with `trg_QUAD_` | `trg_QUAD_tickets_updated_at` |
| Include table and event | `trg_QUAD_users_before_insert` |
| File extension `.trg.sql` | `trg_QUAD_tickets_updated_at.trg.sql` |

### Indexes

| Convention | Example |
|------------|---------|
| Prefix with `idx_` | `idx_QUAD_tickets_domain_id` |
| Include table and columns | `idx_QUAD_tickets_status_priority` |
| Unique indexes: `udx_` | `udx_QUAD_users_email` |

---

## Java Backend Naming

### Packages

```
com.quad.services
├── controller    # REST controllers
├── service       # Business logic interfaces
│   └── impl      # Service implementations
├── repository    # Spring Data repositories
├── entity        # JPA entities
├── dto           # Data Transfer Objects
├── exception     # Custom exceptions
├── config        # Configuration classes
└── util          # Utility classes
```

### Classes

| Type | Convention | Example |
|------|------------|---------|
| Entity | Singular PascalCase | `Ticket`, `Domain`, `User` |
| Repository | `{Entity}Repository` | `TicketRepository` |
| Service Interface | `{Entity}Service` | `TicketService` |
| Service Impl | `{Entity}ServiceImpl` | `TicketServiceImpl` |
| Controller | `{Entity}Controller` | `TicketController` |
| DTO | `{Entity}DTO` or `{Entity}Request/Response` | `TicketDTO`, `CreateTicketRequest` |
| Exception | `{Description}Exception` | `TicketNotFoundException` |
| Config | `{Feature}Config` | `SecurityConfig`, `SwaggerConfig` |

### Methods

| Operation | Convention | Example |
|-----------|------------|---------|
| Get all | `findAll()` | `List<Ticket> findAll()` |
| Get by ID | `findById(UUID id)` | `Optional<Ticket> findById(UUID id)` |
| Get by field | `findBy{Field}(value)` | `List<Ticket> findByDomainId(UUID domainId)` |
| Create/Update | `save(Entity)` | `Ticket save(Ticket ticket)` |
| Update existing | `update(UUID id, Entity)` | `Ticket update(UUID id, Ticket ticket)` |
| Delete | `deleteById(UUID id)` | `void deleteById(UUID id)` |
| Check exists | `existsById(UUID id)` | `boolean existsById(UUID id)` |
| Count | `count()` or `countBy{Field}()` | `long countByStatus(String status)` |
| Custom action | `{verb}{Noun}()` | `startSandbox()`, `closeTicket()` |

### Variables

| Type | Convention | Example |
|------|------------|---------|
| Instance variables | camelCase | `ticketRepository` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Boolean | `is{State}` or `has{Feature}` | `isActive`, `hasChildren` |
| Collections | plural | `tickets`, `domains` |

```java
// GOOD
private final TicketRepository ticketRepository;
private static final int MAX_RETRY_COUNT = 3;
private boolean isActive;
private List<Ticket> tickets;

// BAD
private final TicketRepository repo;        // Abbreviated
private static final int maxRetries = 3;    // Wrong case
private boolean active;                      // Missing 'is' prefix
private List<Ticket> ticketList;            // Redundant 'List'
```

### Entity Fields to Column Mapping

```java
// Entity field (camelCase) → Database column (snake_case)
@Entity
@Table(name = "QUAD_tickets")
public class Ticket {

    @Id
    @Column(name = "id")
    private UUID id;                    // id

    @Column(name = "domain_id")
    private UUID domainId;              // domain_id

    @Column(name = "ticket_type")
    private String ticketType;          // ticket_type

    @Column(name = "is_active")
    private Boolean isActive;           // is_active

    @Column(name = "created_at")
    private LocalDateTime createdAt;    // created_at
}
```

---

## TypeScript/JavaScript Naming

### Files

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `TicketList.tsx`, `DomainCard.tsx` |
| Hooks | camelCase with `use` prefix | `useTickets.ts`, `useDomains.ts` |
| Utilities | camelCase | `formatDate.ts`, `apiClient.ts` |
| Types | PascalCase | `Ticket.ts`, `Domain.ts` |
| Constants | SCREAMING_SNAKE_CASE file | `API_ENDPOINTS.ts` |

### Variables and Functions

```typescript
// Variables: camelCase
const ticketCount = 10;
const isLoading = true;
const selectedDomainId = 'uuid';

// Functions: camelCase, verb prefix
function fetchTickets() { ... }
function updateTicketStatus() { ... }
function handleSubmit() { ... }

// Components: PascalCase
function TicketCard({ ticket }: Props) { ... }

// Types/Interfaces: PascalCase
interface Ticket {
  id: string;
  title: string;
  domainId: string;
  ticketType: TicketType;
  isActive: boolean;
  createdAt: Date;
}

// Enums: PascalCase for name, SCREAMING_SNAKE_CASE for values
enum TicketType {
  USER_STORY = 'USER_STORY',
  BUG = 'BUG',
  TASK = 'TASK',
}

// Constants: SCREAMING_SNAKE_CASE
const MAX_TICKETS_PER_PAGE = 50;
const API_BASE_URL = '/api';
```

### React Component Props

```typescript
// Props interface: {Component}Props
interface TicketCardProps {
  ticket: Ticket;
  onSelect: (id: string) => void;
  isSelected?: boolean;
}

// Event handlers: on{Event}
interface ButtonProps {
  onClick: () => void;
  onHover?: () => void;
}

// Render functions: render{Thing}
function renderTicketList() { ... }
function renderEmptyState() { ... }
```

---

## API Naming

### REST Endpoints

| Operation | Method | Path Pattern | Example |
|-----------|--------|--------------|---------|
| List all | GET | `/api/{resources}` | `GET /api/tickets` |
| Get one | GET | `/api/{resources}/{id}` | `GET /api/tickets/uuid` |
| Create | POST | `/api/{resources}` | `POST /api/tickets` |
| Update | PUT | `/api/{resources}/{id}` | `PUT /api/tickets/uuid` |
| Partial update | PATCH | `/api/{resources}/{id}` | `PATCH /api/tickets/uuid` |
| Delete | DELETE | `/api/{resources}/{id}` | `DELETE /api/tickets/uuid` |
| Action | POST | `/api/{resources}/{id}/{action}` | `POST /api/tickets/uuid/start` |
| Nested | GET | `/api/{parent}/{id}/{child}` | `GET /api/domains/uuid/tickets` |

```
# GOOD
GET    /api/tickets
GET    /api/tickets/{id}
POST   /api/tickets
PUT    /api/tickets/{id}
DELETE /api/tickets/{id}
POST   /api/tickets/{id}/start
GET    /api/domains/{id}/tickets

# BAD
GET    /api/getTickets           # Verb in URL
GET    /api/ticket/{id}          # Singular
POST   /api/tickets/create       # Redundant 'create'
PUT    /api/updateTicket/{id}    # Verb in URL
```

### Query Parameters

| Purpose | Convention | Example |
|---------|------------|---------|
| Filtering | `{field}={value}` | `?status=open` |
| Sorting | `sort={field}:{direction}` | `?sort=createdAt:desc` |
| Pagination | `page={n}&size={n}` | `?page=0&size=20` |
| Search | `q={query}` | `?q=login bug` |
| Include relations | `include={relations}` | `?include=comments,assignee` |

### Response Structure

```json
// Single resource
{
  "id": "uuid",
  "title": "Implement login",
  "ticketType": "USER_STORY",
  "status": "open",
  "createdAt": "2026-01-04T10:00:00Z"
}

// Collection
{
  "content": [...],
  "page": 0,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5
}

// Error
{
  "error": "NOT_FOUND",
  "message": "Ticket not found with id: uuid",
  "timestamp": "2026-01-04T10:00:00Z",
  "path": "/api/tickets/uuid"
}
```

---

## File Naming

### Directory Structure

```
quad-services/
├── src/
│   ├── main/
│   │   ├── java/com/quad/services/
│   │   │   ├── controller/
│   │   │   │   └── TicketController.java
│   │   │   ├── service/
│   │   │   │   ├── TicketService.java
│   │   │   │   └── impl/
│   │   │   │       └── TicketServiceImpl.java
│   │   │   ├── repository/
│   │   │   │   └── TicketRepository.java
│   │   │   └── entity/
│   │   │       └── Ticket.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/com/quad/services/
│           ├── base/
│           │   ├── BaseServiceTest.java
│           │   └── TestDataFactory.java
│           └── service/
│               └── TicketServiceTest.java
└── documentation/
    └── TESTING_GUIDE.md

quad-database/
└── sql/
    ├── core/
    │   └── QUAD_organizations.tbl.sql
    ├── tickets/
    │   └── QUAD_tickets.tbl.sql
    ├── functions/
    │   └── QUAD_init_company_roles.fnc.sql
    └── migrations/
        └── 001_create_tickets.sql
```

### SQL File Extensions

| Type | Extension | Example |
|------|-----------|---------|
| Table | `.tbl.sql` | `QUAD_tickets.tbl.sql` |
| Function | `.fnc.sql` | `QUAD_init_roles.fnc.sql` |
| Trigger | `.trg.sql` | `trg_tickets_updated_at.trg.sql` |
| View | `.vw.sql` | `QUAD_ticket_summary.vw.sql` |
| Migration | `.sql` (numbered) | `001_create_tickets.sql` |
| Seed | `.sql` | `seed_test_data.sql` |

### Documentation Files

| Type | Convention | Example |
|------|------------|---------|
| Main guide | SCREAMING_SNAKE_CASE.md | `TESTING_GUIDE.md` |
| ADR | `ADR-{number}_{title}.md` | `ADR-001_UUID_Primary_Keys.md` |
| Changelog | `CHANGELOG.md` | `CHANGELOG.md` |
| README | `README.md` | `README.md` |

---

## Git Conventions

### Branch Names

```
{type}/{ticket-id}-{short-description}

feature/QUAD-123-add-sandbox-api
bugfix/QUAD-456-fix-null-pointer
chore/QUAD-789-update-dependencies
hotfix/QUAD-999-security-patch
release/v1.2.0
```

| Type | Use Case |
|------|----------|
| `feature/` | New functionality |
| `bugfix/` | Bug fixes |
| `chore/` | Maintenance, dependencies |
| `hotfix/` | Urgent production fixes |
| `release/` | Release preparation |

### Commit Messages

```
[QUAD-123] {imperative verb} {what changed}

[QUAD-123] Add sandbox creation API
[QUAD-456] Fix null pointer in TicketService
[QUAD-789] Update Spring Boot to 3.2.1
```

**Format:**
1. Ticket reference in brackets
2. Imperative verb (Add, Fix, Update, Remove, Refactor)
3. Brief description (50 chars max)

### Tag Names

```
v{major}.{minor}.{patch}

v1.0.0
v1.2.3
v2.0.0-beta.1
```

---

## Terminology Glossary

### Ticket Terms (Graph Theory)

| Term | Definition |
|------|------------|
| **IN-DEGREE** | Number of tickets that block this ticket (PRECONDITIONS count) |
| **OUT-DEGREE** | Number of tickets blocked by this ticket |
| **SOURCE** | Ticket with IN-DEGREE = 0 (no blockers) |
| **SINK** | Ticket with OUT-DEGREE = 0 (blocks nothing) |
| **PRECONDITIONS** | Tickets that must complete before this one can start |
| **GATES** | Boolean conditions that must be true to transition states |
| **DAG** | Directed Acyclic Graph (ticket dependency structure) |
| **TOPOLOGICAL SORT** | Valid execution order respecting dependencies |

### Entity Terms

| Term | Definition |
|------|------------|
| **Organization** | Top-level tenant (company) |
| **Domain** | Project within an organization |
| **Cycle** | Sprint/iteration within a domain |
| **Circle** | Team within a domain |
| **Ticket** | Work item (USER_STORY, BUG, TASK) |
| **Sandbox** | Ephemeral development environment |

### Status Terms

| Entity | Statuses |
|--------|----------|
| Ticket | `backlog`, `ready`, `in_progress`, `in_review`, `done`, `blocked` |
| Cycle | `planning`, `active`, `completed` |
| Sandbox | `requested`, `provisioning`, `ready`, `active`, `idle`, `terminated` |
| User | `pending`, `active`, `suspended` |
| OrgMember | `pending`, `active`, `inactive` |

---

## Anti-Patterns to Avoid

### Database

```sql
-- BAD: Inconsistent naming
CREATE TABLE Tickets (...);              -- Missing QUAD_ prefix
CREATE TABLE QUAD_TicketComments (...);  -- Mixed case
CREATE TABLE QUAD_ticket (...);          -- Singular

-- BAD: Ambiguous columns
domainId UUID;      -- Should be domain_id
type VARCHAR;       -- Should be ticket_type
active BOOLEAN;     -- Should be is_active
```

### Java

```java
// BAD: Abbreviated names
private TicketRepository repo;           // Should be ticketRepository
private String desc;                      // Should be description

// BAD: Hungarian notation
private String strTitle;                  // Should be title
private int intCount;                     // Should be count

// BAD: Inconsistent prefixes
private boolean isOpen;
private boolean hasAccess;
private boolean completed;               // Should be isCompleted
```

### API

```
# BAD: Verbs in URLs
GET /api/getTickets
POST /api/createTicket
PUT /api/updateTicket/{id}

# BAD: Inconsistent pluralization
GET /api/ticket/{id}
GET /api/domains

# BAD: Deeply nested
GET /api/orgs/{id}/domains/{id}/cycles/{id}/tickets/{id}/comments/{id}
```

---

**Last Updated:** January 4, 2026
**Version:** 1.0
