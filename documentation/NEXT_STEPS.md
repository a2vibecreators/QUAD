# QUAD Framework - Next Steps & Development Plan

**Created:** January 3, 2026
**Last Updated:** January 3, 2026
**Status:** Active Development

---

## Overview

This document outlines the complete development plan for QUAD Framework, organized into phases with clear conventions, testing strategies, and milestones.

**Core Philosophy:**
1. **Services First** - Complete and test all services before exposing via controllers
2. **Convention Over Configuration** - Follow consistent patterns across all entities
3. **Test-Driven** - Every service tested with JUnit before integration
4. **Journey-Based Testing** - Test real user workflows, not just CRUD operations

**Primary Goal:** Build a browser-based IDE (like Cursor) to develop NutriNine and fix QUAD issues.

---

## Table of Contents

1. [Pre-IDE Checklist: Services & Database First](#pre-ide-checklist-services--database-first)
2. [One-Month Sprint Plan: Browser IDE](#one-month-sprint-plan-browser-ide)
3. [Phase 1: Backend Services](#phase-1-backend-services)
4. [Phase 2: UI Development](#phase-2-ui-development)
5. [Phase 3: AI Integration & Model Routing](#phase-3-ai-integration--model-routing)
6. [Phase 4: End-to-End Testing](#phase-4-end-to-end-testing)
7. [Phase 5: Production Deployment](#phase-5-production-deployment)
8. [Conventions & Standards](#conventions--standards)
9. [Test Data Strategy](#test-data-strategy)
10. [References](#references)

---

## Pre-IDE Checklist: Services & Database First

**CRITICAL:** Before building the IDE, all backend services and database must be solid.

### Database Verification

| Task | Status | Notes |
|------|--------|-------|
| Schema deployed to H2 (dev) | ❌ | Run Flyway migrations |
| Schema deployed to PostgreSQL (qa) | ❌ | Run Flyway migrations |
| All 127 tables created | ❌ | Verify with `\dt QUAD_*` |
| Foreign keys verified | ❌ | CASCADE deletes work |
| Indexes created | ❌ | Performance optimization |
| Seed data loaded | ❌ | Organizations, tiers, providers |

### Core Services Testing (Priority Order)

**Level 1: Foundation (Must pass before anything else)**

| Service | Tests | Status | Blocking |
|---------|-------|--------|----------|
| OrganizationService | 10 | ❌ | Everything |
| UserService | 12 | ❌ | Auth, domains |
| OrgMemberService | 8 | ❌ | Permissions |
| OrgSettingsService | 6 | ❌ | Config |

**Level 2: Domain Layer**

| Service | Tests | Status | Blocking |
|---------|-------|--------|----------|
| DomainService | 10 | ❌ | Tickets, Git |
| DomainMemberService | 8 | ❌ | Assignments |
| RoleService | 8 | ❌ | Permissions |
| CircleService | 8 | ❌ | Team structure |

**Level 3: Work Items**

| Service | Tests | Status | Blocking |
|---------|-------|--------|----------|
| TicketService | 15 | ❌ | AI Agent |
| CycleService | 10 | ❌ | Sprint planning |
| FlowService | 10 | ❌ | Workflow |
| TicketCommentService | 6 | ❌ | Collaboration |

**Level 4: AI Layer**

| Service | Tests | Status | Blocking |
|---------|-------|--------|----------|
| AiConfigService | 8 | ❌ | AI features |
| AiProviderConfigService | 6 | ❌ | Multi-provider |
| AiConversationService | 10 | ❌ | Chat |
| AiMessageService | 10 | ❌ | History |
| AiOperationService | 8 | ❌ | Billing |

**Level 5: Git Integration**

| Service | Tests | Status | Blocking |
|---------|-------|--------|----------|
| GitRepositoryService | 8 | ❌ | Code access |
| GitOperationService | 6 | ❌ | Commits |
| PullRequestService | 10 | ❌ | PRs |
| CodebaseIndexService | 8 | ❌ | AI context |

### API Endpoints Verification

| Category | Endpoints | Status | Notes |
|----------|-----------|--------|-------|
| Auth | 5 | ❌ | Login, register, SSO |
| Organizations | 8 | ❌ | CRUD + members |
| Domains | 10 | ❌ | CRUD + resources |
| Tickets | 15 | ❌ | Full workflow |
| AI | 10 | ❌ | Chat, suggestions |
| Git | 8 | ❌ | Branches, PRs |

### Journey Tests

| Journey | Description | Status |
|---------|-------------|--------|
| Organization Lifecycle | Create org → users → domains → delete | ❌ |
| Ticket Workflow | Create → assign → status → close | ❌ |
| Cascade Delete | Delete org → verify all children gone | ❌ |
| AI Conversation | Start chat → messages → history | ❌ |
| Multi-Provider | Switch Claude → Gemini in session | ❌ |

### Exit Criteria (Before IDE Work)

- [ ] All Level 1-5 services pass tests (175+ tests)
- [ ] All journey tests pass
- [ ] Seed data loads without errors
- [ ] Cascade deletes work correctly
- [ ] API endpoints return correct responses
- [ ] No blocking database issues

---

## One-Month Sprint Plan: Browser IDE

**Goal:** Build a functional browser-based IDE that can be used to:
1. Develop NutriNine application features
2. Fix QUAD Framework issues
3. Complete ticket-to-deployment workflow

**Confidence Level:** 78% (see AI_AGENT_ARCHITECTURE.md Section 11)

**Architecture Research:** See [BROWSER_IDE_RESEARCH.md](architecture/BROWSER_IDE_RESEARCH.md) for analysis of Bolt.new, Replit, v0.dev, Lovable, Cursor, and GitHub Copilot Workspace implementations.

**Key Architecture Decision:** Hybrid approach - WebContainers for frontend preview + Cloud sandboxes for backend execution.

### Week-by-Week Breakdown

---

### WEEK 1: Foundation + Core Services Testing (Jan 6-10)

**Focus:** Monaco Editor + File Tree + Critical Service Tests

#### Day 1-2: Monaco Editor Integration

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Set up Monaco Editor in Next.js | P0 | 4h | Working editor component |
| Configure syntax highlighting | P0 | 2h | Java, TypeScript, SQL, YAML support |
| Add keyboard shortcuts | P1 | 2h | Ctrl+S save, Ctrl+P file search |
| Create editor toolbar | P1 | 2h | Line numbers, minimap, find/replace |

**Deliverable:** `/ide/editor` page with Monaco editor working

#### Day 3-4: File Tree Component + GitHub Integration

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Build file tree component | P0 | 4h | Collapsible tree with icons |
| GitHub API - list repo contents | P0 | 3h | Fetch file structure from GitHub |
| File click → load in editor | P0 | 2h | Content loaded via GitHub API |
| Caching layer for files | P1 | 3h | QUAD_code_cache table integration |

**Deliverable:** `/ide` page with file tree + editor working together

#### Day 5: Core Service Tests (Level 1)

| Service | Test Cases | Priority |
|---------|------------|----------|
| OrganizationService | 10 tests (CRUD + cascade) | P0 |
| UserService | 12 tests (auth, roles) | P0 |
| OrgMemberService | 8 tests | P1 |
| OrgSettingsService | 6 tests | P1 |

**Deliverable:** 36 passing unit tests for Level 1 services

---

### WEEK 2: AI Chat + Domain Services Testing (Jan 13-17)

**Focus:** AI Chat Panel + Diff View + Domain Layer Tests

#### Day 1-2: AI Chat Panel

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Chat UI component (slide-out panel) | P0 | 4h | Chat interface with messages |
| Message history from QUAD_ai_messages | P0 | 3h | Load/save conversation |
| Connect to AI router (multi-provider) | P0 | 4h | Claude/Gemini/OpenAI integration |
| Streaming responses | P1 | 3h | Real-time text streaming |

**Deliverable:** AI chat working in IDE with multi-provider support

#### Day 3-4: Diff View + Code Suggestions

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Monaco diff editor integration | P0 | 3h | Side-by-side diff view |
| Parse AI code suggestions | P0 | 3h | Extract structured diffs from AI response |
| Apply diff button | P0 | 2h | One-click apply changes |
| Reject/Edit diff | P1 | 2h | User can modify before applying |

**Deliverable:** AI suggests code → user sees diff → applies changes

#### Day 5: Domain Layer Tests (Level 2)

| Service | Test Cases | Priority |
|---------|------------|----------|
| DomainService | 10 tests (CRUD, hierarchy) | P0 |
| DomainMemberService | 8 tests | P0 |
| DomainResourceService | 8 tests | P1 |
| CircleService | 8 tests | P1 |
| RoleService | 8 tests | P1 |

**Deliverable:** 42 passing unit tests for Level 2 services

---

### WEEK 3: Git Operations + Ticket Services Testing (Jan 20-24)

**Focus:** Branch/Commit/PR + Work Item Tests + API Endpoints

#### Day 1-2: Git Operations

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Create branch from UI | P0 | 3h | GitHub API integration |
| Commit changes (single file) | P0 | 3h | Save file → commit to branch |
| Multi-file commit (atomic) | P0 | 4h | GitHub Trees API |
| Branch selector dropdown | P1 | 2h | Switch between branches |

**Deliverable:** Full Git workflow: edit → commit → branch

#### Day 3: Pull Request Creation

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Create PR from UI | P0 | 3h | GitHub API integration |
| AI-generated PR description | P0 | 2h | Summarize changes with AI |
| Link PR to ticket | P0 | 2h | Update QUAD_pull_requests table |
| PR status display | P1 | 2h | Show checks, reviews |

**Deliverable:** One-click PR creation with AI description

#### Day 4-5: Work Item Services Tests (Level 3)

| Service | Test Cases | Priority |
|---------|------------|----------|
| CycleService | 10 tests | P0 |
| TicketService | 15 tests (CRUD, status, hierarchy) | P0 |
| TicketCommentService | 6 tests | P1 |
| TicketTimeLogService | 6 tests | P1 |
| FlowService | 10 tests | P1 |

**Deliverable:** 47 passing unit tests for Level 3 services

#### API Endpoints (Parallel with Testing)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/ide/files` | GET | List repository files |
| `/api/ide/files/{path}` | GET | Get file content |
| `/api/ide/files/{path}` | PUT | Save file (creates commit) |
| `/api/ide/branches` | GET/POST | List/create branches |
| `/api/ide/prs` | POST | Create pull request |
| `/api/ai/chat` | POST | Send message to AI |
| `/api/ai/chat/stream` | GET (SSE) | Stream AI response |

---

### WEEK 4: Multi-File Refactor + AI Services Testing (Jan 27-31)

**Focus:** Two-Pass Refactoring + Build Triggers + AI Layer Tests

#### Day 1-2: Multi-File Refactoring

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| GitHub Code Search integration | P0 | 3h | Find all occurrences |
| Multi-file context builder | P0 | 3h | Aggregate files for AI |
| Single AI call for all diffs | P0 | 3h | Generate all changes at once |
| Atomic commit via Trees API | P0 | 3h | All changes in one commit |

**Deliverable:** Rename class across 20+ files in one operation

#### Day 3: Build & Deploy Triggers

| Task | Priority | Effort | Deliverable |
|------|----------|--------|-------------|
| Trigger GitHub Actions build | P0 | 3h | POST to workflow dispatch |
| Show build status in UI | P0 | 2h | Poll/webhook for status |
| Deploy to DEV button | P1 | 3h | GCP Cloud Run deployment |
| Build logs viewer | P2 | 2h | Stream build output |

**Deliverable:** Complete CI/CD from IDE

#### Day 4-5: AI Services Tests (Level 4)

| Service | Test Cases | Priority |
|---------|------------|----------|
| AiConfigService | 8 tests | P0 |
| AiProviderConfigService | 6 tests | P0 |
| AiConversationService | 10 tests | P0 |
| AiMessageService | 10 tests | P0 |
| AiOperationService | 8 tests | P1 |
| AiCreditBalanceService | 8 tests | P1 |

**Deliverable:** 50 passing unit tests for Level 4 services

---

### Week 5-6: Polish, Integration Tests, Documentation (Feb 3-14)

**Focus:** Journey Tests + UI Polish + Documentation

#### Journey Tests

| Journey | Test Cases | Priority |
|---------|------------|----------|
| Organization Lifecycle | Create → Add users → Add domains → Delete (cascade) | P0 |
| Ticket to Deployment | Create ticket → AI expand → Implement → PR → Deploy | P0 |
| Multi-Provider AI | Same session switches Claude → Gemini → OpenAI | P0 |
| Cascade Delete | Org delete removes all children | P0 |
| Codebase Index Refresh | Push → Webhook → Re-index → Verify | P1 |

#### UI Polish

| Task | Priority | Effort |
|------|----------|--------|
| Loading states & skeletons | P0 | 4h |
| Error handling & toasts | P0 | 3h |
| Keyboard shortcuts help modal | P1 | 2h |
| Dark/Light theme toggle | P2 | 3h |
| Mobile responsive (basic) | P2 | 4h |

#### Documentation

| Document | Purpose |
|----------|---------|
| IDE User Guide | How to use the browser IDE |
| API Reference (OpenAPI) | All endpoints documented |
| Architecture Decisions | ADRs for key choices |

---

### Milestone Summary

| Week | Main Deliverables | Tests Added | Cumulative Tests |
|------|-------------------|-------------|------------------|
| Week 1 | Monaco + File Tree | 36 | 36 |
| Week 2 | AI Chat + Diff View | 42 | 78 |
| Week 3 | Git Operations + PR | 47 | 125 |
| Week 4 | Multi-file Refactor + Build | 50 | 175 |
| Week 5-6 | Journey Tests + Polish | 25 | 200 |

### Success Metrics

**Week 4 Checkpoint (Minimum Viable IDE):**
- [ ] Open NutriNine codebase in browser
- [ ] Ask AI to implement a feature
- [ ] Review and apply code diff
- [ ] Commit and create PR
- [ ] Build triggered automatically

**Week 6 Checkpoint (Production-Ready):**
- [ ] 200+ passing tests
- [ ] Multi-file refactoring works
- [ ] Deploy to DEV from UI
- [ ] First NutriNine feature developed using QUAD IDE
- [ ] First QUAD bug fixed using QUAD IDE

### Dependencies & Blockers

| Dependency | Status | Mitigation |
|------------|--------|------------|
| GitHub API token | ✅ Available | User provides their token |
| Claude/Gemini API keys | ✅ Available | Stored in QUAD_ai_provider_config |
| Monaco Editor package | ✅ Available | @monaco-editor/react |
| GCP Cloud Run API | ⚠️ Need setup | Week 4 task |

### Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Monaco performance issues | Low | Medium | Lazy load, virtual scrolling |
| GitHub rate limits | Medium | High | Aggressive caching, user's token |
| AI latency too slow | Medium | Medium | Streaming responses, caching |
| Multi-file diffs fail | Low | High | Fallback to single-file mode |

---

---

## Phase 1: Backend Services

### 1.1 Current Status

| Category | Tables | Services | Tested |
|----------|--------|----------|--------|
| Core (Org, User, Domain) | 15 | 15 | ❌ |
| Tickets & Flows | 12 | 12 | ❌ |
| AI & Context | 18 | 18 | ❌ |
| Git & PR | 10 | 10 | ❌ |
| Meetings | 6 | 6 | ❌ |
| Memory | 8 | 8 | ❌ |
| Infrastructure | 12 | 12 | ❌ |
| Notifications | 4 | 4 | ❌ |
| Skills & Adoption | 10 | 10 | ❌ |
| Sandbox & Caching | 8 | 8 | ❌ |
| Other | 24 | 24 | ❌ |
| **Total** | **127** | **127** | **0/127** |

### 1.2 Testing Strategy

#### Step 1: Create Test Data (Two Sample Organizations)

**Organization A: "TechStartup Inc" (Small Team)**
```
TechStartup Inc (Org)
├── Admin User: alice@techstartup.com (Owner)
├── Developer: bob@techstartup.com
├── Domain: "Backend API"
│   ├── Circle: Development
│   ├── Cycle: Sprint 1 (2 weeks)
│   └── Tickets: 5 tickets (mix of story, task, bug)
└── AI Config: Gemini (free tier)
```

**Organization B: "Enterprise Corp" (Large Team)**
```
Enterprise Corp (Org)
├── Admin User: admin@enterprise.com (Owner)
├── Multiple Departments:
│   ├── Engineering (10 users)
│   ├── QA (5 users)
│   └── DevOps (3 users)
├── Multiple Domains:
│   ├── "Frontend App" (React)
│   ├── "Backend Services" (Spring Boot)
│   └── "Infrastructure" (Terraform)
├── Multiple Cycles across domains
├── 50+ Tickets with hierarchy (epics → stories → tasks)
└── AI Config: Claude (paid tier, BYOK)
```

#### Step 2: Service Testing Order

Test services in dependency order (parent → child):

```
Level 1: Core (No Dependencies)
├── OrganizationService
├── UserService (depends on Org)
└── OrgSettingsService

Level 2: Domain Layer
├── DomainService (depends on Org)
├── DomainMemberService
├── DomainResourceService
└── CircleService (depends on Domain)

Level 3: Work Items
├── CycleService (depends on Domain)
├── TicketService (depends on Domain, Cycle)
├── TicketCommentService
├── TicketTimeLogService
└── FlowService

Level 4: AI & Context
├── AiConfigService
├── AiConversationService
├── AiMessageService
├── MemoryChunkService
└── CodebaseIndexService

Level 5: Git Integration
├── GitRepositoryService
├── PullRequestService
├── GitOperationService
└── AiCodeReviewService

Level 6: Other Services
├── NotificationService
├── MeetingService
├── SkillService
└── ... (remaining services)
```

#### Step 3: JUnit Test Structure

Each service test follows this convention:

```
src/test/java/com/quad/services/
├── base/
│   ├── BaseServiceTest.java          # Common test setup
│   └── TestDataFactory.java          # Creates test entities
├── service/
│   ├── OrganizationServiceTest.java
│   ├── UserServiceTest.java
│   ├── DomainServiceTest.java
│   ├── TicketServiceTest.java
│   └── ... (one per service)
└── journey/
    ├── OrganizationJourneyTest.java  # Full org lifecycle
    ├── TicketLifecycleTest.java      # Ticket workflow
    ├── DevAgentJourneyTest.java      # AI agent flow
    └── CascadeDeleteTest.java        # Cascade delete verification
```

### 1.3 Test Conventions

#### Naming Convention
```java
@Test
void methodName_scenario_expectedResult() {
    // Example:
    // create_validOrganization_returnsCreatedOrg()
    // delete_orgWithDomains_cascadesDelete()
    // findById_nonExistentId_throwsNotFoundException()
}
```

#### Test Categories

| Category | Annotation | Purpose |
|----------|------------|---------|
| Unit | `@Tag("unit")` | Service logic only, mocked repos |
| Integration | `@Tag("integration")` | Real database, full stack |
| Journey | `@Tag("journey")` | Multi-step user workflows |
| Performance | `@Tag("performance")` | Load testing, benchmarks |

#### Required Tests Per Service

```java
// Every service MUST have these tests:

// 1. CREATE Tests
@Test void create_validEntity_success();
@Test void create_duplicateKey_throwsException();
@Test void create_missingRequired_throwsValidation();

// 2. READ Tests
@Test void findById_existingId_returnsEntity();
@Test void findById_nonExistentId_throwsNotFound();
@Test void findAll_multipleEntities_returnsList();
@Test void findByParent_validParentId_returnsChildren();

// 3. UPDATE Tests
@Test void update_existingEntity_success();
@Test void update_nonExistentId_throwsNotFound();
@Test void update_invalidData_throwsValidation();

// 4. DELETE Tests
@Test void delete_existingEntity_success();
@Test void delete_nonExistentId_throwsNotFound();
@Test void delete_withChildren_cascadesOrFails(); // Based on schema

// 5. BUSINESS LOGIC Tests (service-specific)
@Test void specificMethod_scenario_expectedResult();
```

### 1.4 Milestone Checklist

#### Milestone 1.1: Core Services (Week 1)
- [ ] OrganizationServiceTest - 10 tests
- [ ] UserServiceTest - 12 tests
- [ ] OrgMemberServiceTest - 8 tests
- [ ] OrgSettingsServiceTest - 6 tests
- [ ] OrgTierServiceTest - 5 tests
- [ ] SsoConfigServiceTest - 6 tests
- [ ] EmailVerificationCodeServiceTest - 5 tests
- [ ] UserSessionServiceTest - 6 tests

#### Milestone 1.2: Domain Layer (Week 2)
- [ ] DomainServiceTest - 10 tests
- [ ] DomainMemberServiceTest - 8 tests
- [ ] DomainResourceServiceTest - 8 tests
- [ ] CircleServiceTest - 8 tests
- [ ] CircleMemberServiceTest - 6 tests
- [ ] RoleServiceTest - 8 tests
- [ ] CoreRoleServiceTest - 5 tests

#### Milestone 1.3: Work Items (Week 3)
- [ ] CycleServiceTest - 10 tests
- [ ] TicketServiceTest - 15 tests
- [ ] TicketCommentServiceTest - 6 tests
- [ ] TicketTimeLogServiceTest - 6 tests
- [ ] TicketSkillServiceTest - 5 tests
- [ ] FlowServiceTest - 10 tests
- [ ] FlowStageHistoryServiceTest - 6 tests
- [ ] FlowBranchServiceTest - 5 tests

#### Milestone 1.4: AI & Context (Week 4)
- [ ] AiConfigServiceTest - 8 tests
- [ ] AiProviderConfigServiceTest - 6 tests
- [ ] AiConversationServiceTest - 10 tests
- [ ] AiMessageServiceTest - 10 tests
- [ ] AiOperationServiceTest - 8 tests
- [ ] AiContextServiceTest - 8 tests
- [ ] AiCreditBalanceServiceTest - 8 tests
- [ ] AiCreditTransactionServiceTest - 6 tests
- [ ] AiActivityRoutingServiceTest - 6 tests
- [ ] AiAnalysisCacheServiceTest - 6 tests
- [ ] AiCodeReviewServiceTest - 8 tests
- [ ] AiUserMemoryServiceTest - 6 tests

#### Milestone 1.5: Git & Memory (Week 5)
- [ ] GitIntegrationServiceTest - 6 tests
- [ ] GitRepositoryServiceTest - 8 tests
- [ ] GitOperationServiceTest - 6 tests
- [ ] PullRequestServiceTest - 10 tests
- [ ] PrReviewerServiceTest - 5 tests
- [ ] PrApprovalServiceTest - 5 tests
- [ ] MemoryChunkServiceTest - 8 tests
- [ ] MemoryKeywordServiceTest - 5 tests
- [ ] MemoryTemplateServiceTest - 5 tests
- [ ] ContextSessionServiceTest - 6 tests
- [ ] ContextRequestServiceTest - 5 tests

#### Milestone 1.6: Remaining Services (Week 6)
- [ ] All remaining services tested
- [ ] Journey tests passing
- [ ] Cascade delete verified
- [ ] Performance benchmarks run

---

## Phase 2: UI Development

### 2.1 Pages & Components

| Page | Priority | Status | Dependencies |
|------|----------|--------|--------------|
| Login/SSO | P0 | ❌ | Auth services |
| Dashboard | P0 | ❌ | Org, Domain, Ticket services |
| Organization Settings | P1 | ❌ | OrgSettings, SsoConfig |
| User Settings | P1 | ❌ | User, Notification services |
| Domain Management | P1 | ❌ | Domain, Circle, Role services |
| Ticket Board (Kanban) | P1 | ❌ | Ticket, Flow services |
| Ticket Detail | P1 | ❌ | Ticket, Comment, AI services |
| AI Chat Panel | P1 | ❌ | AiConversation, AiMessage |
| Code Review IDE | P2 | ❌ | Git, PR, AiCodeReview services |
| Codebase Explorer | P2 | ❌ | CodebaseIndex, CodeCache |
| Cycle Planning | P2 | ❌ | Cycle, Ticket services |
| Analytics Dashboard | P3 | ❌ | DoraMetrics, WorkloadMetrics |
| Admin Portal | P3 | ❌ | All admin services |

### 2.2 UI Components Hierarchy

```
App Shell
├── Navigation Sidebar
│   ├── Org Selector (dropdown)
│   ├── Domain Selector (dropdown)
│   ├── Quick Actions (+ New Ticket, etc.)
│   └── Menu Items (Dashboard, Tickets, Cycles, etc.)
│
├── Main Content Area
│   ├── Page Header (breadcrumb, actions)
│   ├── Page Content (varies by page)
│   └── AI Assistant Panel (slide-out)
│
└── Modals & Overlays
    ├── Settings Modal
    ├── Create Ticket Modal
    ├── AI Chat Modal
    └── Code Review Modal
```

### 2.3 Roles & Permissions

#### Role Hierarchy

```
Platform Level:
├── PLATFORM_ADMIN (A2Vibe staff)
└── PLATFORM_SUPPORT

Organization Level:
├── ORG_OWNER (billing, delete org)
├── ORG_ADMIN (manage users, settings)
└── ORG_MEMBER (basic access)

Domain Level:
├── DOMAIN_ADMIN (manage domain)
├── DOMAIN_LEAD (manage cycles, assign)
├── DOMAIN_MEMBER (work on tickets)
└── DOMAIN_VIEWER (read-only)
```

#### Permission Matrix

| Permission | Owner | Admin | Lead | Member | Viewer |
|------------|-------|-------|------|--------|--------|
| View Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ |
| Create Ticket | ✅ | ✅ | ✅ | ✅ | ❌ |
| Assign Ticket | ✅ | ✅ | ✅ | ❌ | ❌ |
| Manage Cycles | ✅ | ✅ | ✅ | ❌ | ❌ |
| Manage Users | ✅ | ✅ | ❌ | ❌ | ❌ |
| Manage Billing | ✅ | ❌ | ❌ | ❌ | ❌ |
| Delete Org | ✅ | ❌ | ❌ | ❌ | ❌ |
| Use AI Agent | ✅ | ✅ | ✅ | ✅ | ❌ |
| Approve AI Code | ✅ | ✅ | ✅ | ❌ | ❌ |

### 2.4 Settings Hierarchy

```
Organization Settings
├── General (name, slug, logo, timezone)
├── Billing (plan, payment, invoices)
├── SSO (OAuth providers, SAML)
├── AI Configuration
│   ├── Provider (Gemini/Claude/OpenAI)
│   ├── BYOK (Bring Your Own Key)
│   ├── Budget Limits
│   └── Model Preferences
├── Integrations (GitHub, Slack, Jira)
└── Security (2FA, session timeout)

User Settings (Personal)
├── Profile (name, avatar, timezone)
├── Notifications (email, push, slack)
├── AI Preferences (model, temperature)
├── Editor Preferences (theme, font size)
└── Connected Accounts (GitHub, Google)

Domain Settings (Per Domain)
├── General (name, description, methodology)
├── Git Repository (URL, branch, permissions)
├── Circle Configuration
├── Role Definitions
├── AI Rules (agent.md content)
└── Codebase Index Settings
```

---

## Phase 3: AI Integration & Model Routing

### 3.1 Multi-Provider Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AI ROUTER                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   User Request                                                               │
│        │                                                                     │
│        ▼                                                                     │
│   ┌─────────────┐                                                           │
│   │ Task Classifier │◄── Keywords + Gemini (if hybrid mode)                │
│   └─────────────┘                                                           │
│        │                                                                     │
│        ▼                                                                     │
│   ┌─────────────┐         ┌─────────────┐         ┌─────────────┐          │
│   │   SIMPLE    │         │   MEDIUM    │         │   COMPLEX   │          │
│   │  (Haiku)    │         │  (Sonnet)   │         │   (Opus)    │          │
│   └─────────────┘         └─────────────┘         └─────────────┘          │
│        │                       │                       │                    │
│        ▼                       ▼                       ▼                    │
│   ┌──────────────────────────────────────────────────────────────────────┐ │
│   │                     CONTEXT BUILDER                                   │ │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │ │
│   │  │ Codebase    │  │ Ticket      │  │ Agent Rules │                  │ │
│   │  │ Index       │  │ Context     │  │ (agent.md)  │                  │ │
│   │  │ (~5K tokens)│  │ (~1K tokens)│  │ (~1K tokens)│                  │ │
│   │  └─────────────┘  └─────────────┘  └─────────────┘                  │ │
│   └──────────────────────────────────────────────────────────────────────┘ │
│        │                                                                     │
│        ▼                                                                     │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│   │   Claude    │    │   Gemini    │    │   OpenAI    │                    │
│   │   (Primary) │    │   (Dev/Free)│    │   (Fallback)│                    │
│   └─────────────┘    └─────────────┘    └─────────────┘                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Task Classification

| Task Type | Complexity | Model | Cost/1K tokens |
|-----------|------------|-------|----------------|
| Simple question | Low | Haiku | $0.25 input / $1.25 output |
| Code explanation | Low | Haiku | $0.25 / $1.25 |
| Status update | Low | Haiku | $0.25 / $1.25 |
| Bug analysis | Medium | Sonnet | $3 / $15 |
| Code generation | Medium | Sonnet | $3 / $15 |
| Story expansion | Medium | Sonnet | $3 / $15 |
| Architecture design | High | Opus | $15 / $75 |
| Complex refactor | High | Opus | $15 / $75 |
| Security audit | High | Opus | $15 / $75 |

### 3.3 Context Optimization (80% Savings)

#### Before Optimization
```
Full codebase read: 80,000 tokens
+ System prompt: 2,000 tokens
+ User query: 500 tokens
= 82,500 tokens per request
= ~$0.25 per request (Sonnet)
```

#### After Optimization
```
Codebase index: 5,000 tokens (cached)
+ Ticket context: 1,000 tokens
+ Agent rules: 1,000 tokens (cached)
+ User query: 500 tokens
= 7,500 tokens per request
= ~$0.02 per request (Sonnet)
= 92% savings!
```

### 3.4 Codebase Index Structure

```json
{
  "repo": "order-service",
  "branch": "main",
  "indexed_at": "2026-01-03T10:00:00Z",
  "token_count": 4850,

  "tables": {
    "orders": "Customer orders (id, customer_id, status, total, delivery_type, created_at)",
    "order_items": "Order line items (id, order_id, product_id, quantity, price)",
    "customers": "Customer profiles (id, name, email, phone, address)"
  },

  "apis": {
    "GET /api/orders": "List orders with filters",
    "GET /api/orders/:id": "Get order by ID",
    "POST /api/orders": "Create new order",
    "PUT /api/orders/:id": "Update order",
    "DELETE /api/orders/:id": "Delete order"
  },

  "files": {
    "Order.java": "JPA entity for orders table",
    "OrderService.java": "Order business logic",
    "OrderController.java": "REST endpoints for orders",
    "OrderDTO.java": "Data transfer object for orders"
  },

  "patterns": {
    "framework": "Spring Boot 3.2",
    "orm": "JPA/Hibernate",
    "migrations": "Flyway (V*__*.sql)",
    "testing": "JUnit 5",
    "api_style": "REST JSON"
  },

  "architecture": "Standard Spring Boot layered architecture with Controller → Service → Repository. Database migrations via Flyway. UUID primary keys."
}
```

### 3.5 Model Switching Logic

```java
public class AIRouter {

    public ModelSelection selectModel(TaskContext context) {
        // 1. Check org's AI configuration
        AiConfig config = aiConfigService.getByOrgId(context.orgId);

        // 2. Classify task complexity
        TaskComplexity complexity = classifyTask(context);

        // 3. Check budget limits
        if (isOverBudget(context.orgId)) {
            return fallbackToFreeModel();
        }

        // 4. Select model based on complexity
        switch (complexity) {
            case SIMPLE:
                return config.simpleModel != null
                    ? config.simpleModel
                    : DEFAULT_SIMPLE; // haiku

            case MEDIUM:
                return config.mediumModel != null
                    ? config.mediumModel
                    : DEFAULT_MEDIUM; // sonnet

            case COMPLEX:
                return config.complexModel != null
                    ? config.complexModel
                    : DEFAULT_COMPLEX; // opus
        }
    }

    private TaskComplexity classifyTask(TaskContext context) {
        // Hybrid mode: Keywords first, then AI if uncertain

        // Simple keywords
        if (containsAny(context.query,
            "what is", "explain", "status", "list", "show")) {
            return SIMPLE;
        }

        // Complex keywords
        if (containsAny(context.query,
            "architecture", "refactor entire", "security audit",
            "design pattern", "optimize system")) {
            return COMPLEX;
        }

        // Medium by default, or ask Gemini (fast classifier)
        if (config.classificationMode == HYBRID) {
            return classifyWithAI(context.query);
        }

        return MEDIUM;
    }
}
```

---

## Phase 4: End-to-End Testing

### 4.1 Test Scenarios

#### Scenario 1: New User Onboarding
```
1. User signs up with email
2. Email verification
3. Create organization
4. Invite team members
5. Connect GitHub repository
6. Create first domain
7. Create first cycle
8. Create first ticket
9. Use AI agent to expand ticket
10. Verify all data in database
```

#### Scenario 2: Developer Agent Flow
```
1. Create story ticket: "Add preferredDeliveryTime to Order"
2. Click "Developer Agent" button
3. AI analyzes and creates 6 subtasks
4. Select subtask: "Add migration"
5. Click "Implement"
6. AI generates SQL migration code
7. Review diff in browser IDE
8. Click "Approve & Create Branch"
9. Verify branch created in GitHub
10. Verify PR created
11. Verify ticket status updated
```

#### Scenario 3: Multi-Org User
```
1. User belongs to 2 organizations
2. Switch between orgs
3. Verify correct data isolation
4. Verify AI credits tracked per org
5. Verify permissions per org
```

#### Scenario 4: Cascade Delete
```
1. Create org with full data (domains, tickets, AI convos)
2. Delete organization
3. Verify ALL child entities deleted
4. Verify no orphan records
```

### 4.2 UI Test Pages

| Page | Test Cases |
|------|------------|
| Login | SSO flow, email login, 2FA, session persistence |
| Dashboard | Data loads, metrics correct, quick actions work |
| Ticket Board | Drag-drop, filters, create ticket, status change |
| Ticket Detail | View, edit, comment, AI chat, time log |
| Code Review | Diff view, approve, reject, line comments |
| Settings | Save, validate, SSO config, AI config |

### 4.3 Deployment Test

1. **Deploy small project to GCP**
   - Single Cloud Run service
   - Cloud SQL (PostgreSQL)
   - Minimal configuration

2. **Create test organization**

3. **Complete full journey:**
   - Create domain
   - Connect GitHub
   - Create cycle
   - Create 3 tickets
   - Use Developer Agent
   - Create PR
   - Verify in GitHub

---

## Phase 5: Production Deployment

### 5.1 GCP Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GCP PROJECT                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│   │ Cloud Run   │    │ Cloud Run   │    │ Cloud Run   │                    │
│   │ quad-web    │    │ quad-api    │    │ quad-worker │                    │
│   │ (Next.js)   │    │ (Spring)    │    │ (Jobs)      │                    │
│   └─────────────┘    └─────────────┘    └─────────────┘                    │
│         │                  │                  │                             │
│         └──────────────────┼──────────────────┘                             │
│                            │                                                 │
│                     ┌─────────────┐                                         │
│                     │  Cloud SQL  │                                         │
│                     │ PostgreSQL  │                                         │
│                     └─────────────┘                                         │
│                                                                              │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│   │ Secret Mgr  │    │ Cloud Pub/  │    │ Cloud       │                    │
│   │ (API keys)  │    │ Sub (events)│    │ Storage     │                    │
│   └─────────────┘    └─────────────┘    └─────────────┘                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Deployment Checklist

- [ ] GCP project created
- [ ] Cloud SQL instance created
- [ ] Cloud Run services deployed
- [ ] Custom domain configured
- [ ] SSL certificates installed
- [ ] Secret Manager configured
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Monitoring & alerting
- [ ] Backup strategy

---

## Conventions & Standards

### 6.1 Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Entity | PascalCase | `Organization`, `TicketComment` |
| Table | QUAD_ prefix + snake_case | `QUAD_organizations`, `QUAD_ticket_comments` |
| Service | EntityNameService | `OrganizationService`, `TicketService` |
| Repository | EntityNameRepository | `OrganizationRepository` |
| Controller | EntityNameController | `OrganizationController` |
| DTO | EntityNameDTO | `OrganizationDTO` |
| Test | EntityNameServiceTest | `OrganizationServiceTest` |

### 6.2 API Conventions

```
REST Endpoints:
GET    /api/organizations          # List all
GET    /api/organizations/:id      # Get by ID
POST   /api/organizations          # Create
PUT    /api/organizations/:id      # Update
DELETE /api/organizations/:id      # Delete

Nested Resources:
GET    /api/organizations/:orgId/domains         # Domains in org
POST   /api/organizations/:orgId/domains         # Create domain in org
GET    /api/domains/:domainId/tickets            # Tickets in domain

Query Parameters:
GET    /api/tickets?status=open&page=1&size=20   # Filtering + pagination
```

### 6.3 Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "ENTITY_NOT_FOUND",
    "message": "Organization with ID 'xxx' not found",
    "details": {
      "entityType": "Organization",
      "entityId": "xxx"
    }
  },
  "timestamp": "2026-01-03T10:00:00Z"
}
```

### 6.4 Success Response Format

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Organization Name",
    ...
  },
  "meta": {
    "page": 1,
    "size": 20,
    "total": 100
  }
}
```

---

## Test Data Strategy

### 7.1 Test Data Initialization

```java
@Component
public class TestDataFactory {

    public Organization createTechStartup() {
        Organization org = Organization.builder()
            .name("TechStartup Inc")
            .slug("techstartup-inc")
            .industry("Technology")
            .teamSize("1-10")
            .aiTier("FREE")
            .build();

        // Add admin user
        User admin = createUser("alice@techstartup.com", org, true);

        // Add domain
        Domain domain = createDomain("Backend API", org, admin);

        // Add circle
        Circle circle = createCircle("Development", domain);

        // Add cycle
        Cycle cycle = createCycle("Sprint 1", domain);

        // Add tickets
        createTickets(5, domain, cycle, admin);

        return org;
    }

    public Organization createEnterpriseCorp() {
        // Similar but with 50+ tickets, multiple domains, etc.
    }
}
```

### 7.2 Test Data Cleanup

```java
@AfterEach
void cleanup() {
    // Delete in reverse order of creation
    ticketRepository.deleteAll();
    cycleRepository.deleteAll();
    circleRepository.deleteAll();
    domainRepository.deleteAll();
    userRepository.deleteAll();
    organizationRepository.deleteAll();
}
```

### 7.3 Test Profiles

```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop

# Use H2 for fast tests, real PostgreSQL for integration
```

---

## Progress Tracking

### Weekly Status Template

```markdown
## Week X Status (Date)

### Completed
- [ ] Service tests: X/127
- [ ] Journey tests: X/10
- [ ] UI pages: X/15

### In Progress
- Current focus: ...

### Blockers
- Issue: ...

### Next Week
- Goal: ...
```

---

## References

- [QUAD Framework CLAUDE.md](../CLAUDE.md)
- [Database Schema](../quad-database/schema.prisma)
- [API Documentation](./api/API_DOCUMENTATION.md)
- [Architecture Documentation](./architecture/SMART_AGENT_ARCHITECTURE.md)

---

**Document Version:** 1.1
**Author:** QUAD Development Team
**Review Cycle:** Weekly

### Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 3, 2026 | Initial development plan with phases |
| 1.1 | Jan 3, 2026 | Added comprehensive 1-month Browser IDE sprint plan with week-by-week breakdown |
