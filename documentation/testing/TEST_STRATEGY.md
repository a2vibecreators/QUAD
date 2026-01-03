# QUAD Framework - Test Strategy

**Version:** 1.0
**Last Updated:** January 2, 2026

---

## Table of Contents

1. [Testing Objectives](#1-testing-objectives)
2. [Testing Types](#2-testing-types)
3. [Test Environments](#3-test-environments)
4. [Journey Testing Approach](#4-journey-testing-approach)
5. [Test Data](#5-test-data)
6. [Bug Severity Levels](#6-bug-severity-levels)
7. [AI Testing Special Considerations](#7-ai-testing-special-considerations)
8. [Success Criteria](#8-success-criteria)
9. [Scope](#9-scope)
10. [Phase 1 Implementation Status](#10-phase-1-implementation-status)

---

## 1. Testing Objectives

| Objective | Description |
|-----------|-------------|
| **Functional Correctness** | All Q-U-A-D workflow stages work as specified |
| **User Experience** | Smooth navigation through Circle → Domain → Flow workflows |
| **API Integration** | Next.js app communicates correctly with Prisma backend |
| **Data Integrity** | Flows, Cycles, and Circles data saved and displayed correctly |
| **AI Quality** | Flow Accelerators produce accurate, useful outputs |
| **Human Override** | All AI operations have proper approval gates |

---

## 2. Testing Types

### 2.1 Manual Journey Testing (Primary - Current Phase)

| Aspect | Details |
|--------|---------|
| **What** | End-to-end Q-U-A-D workflow testing |
| **When** | After each feature implementation |
| **Who** | Developer/QA |
| **Documentation** | `journeys/JOURNEY_*.md` files |

### 2.2 Unit Testing (Implemented)

| Aspect | Details |
|--------|---------|
| **What** | Test API routes, services, utilities |
| **Framework** | Jest |
| **Location** | `__tests__/` or `*.test.ts` |
| **Coverage Goal** | 70%+ for business logic |

### 2.3 Integration Testing (Planned)

| Aspect | Details |
|--------|---------|
| **What** | Test API endpoint chains |
| **Framework** | Playwright or Cypress |
| **Focus** | Critical user flows |

---

## 3. Test Environments

| Environment | Database | URL | Use Case |
|-------------|----------|-----|----------|
| **Local DEV** | postgres-dev:16201 | localhost:3000 | Development |
| **DEV Studio** | postgres-dev:16201 | https://dev.quadframe.work | Integration |
| **QA Studio** | postgres-qa:17201 | https://qa.quadframe.work | Pre-release |

---

## 4. Journey Testing Approach

### What is a Journey?
A **journey** is a complete user workflow from start to finish, tested as a single unit following the **Q-U-A-D** methodology.

### Journey List (Phase 1)

| # | Journey | Q-U-A-D Stage | Description | Priority |
|---|---------|---------------|-------------|----------|
| J01 | Onboarding & Circle Setup | ALL | New user → Organization → Circle | HIGH |
| J02 | Q-Stage: Requirements | Q (Question) | Document upload → AI analysis → Flows | HIGH |
| J03 | U-Stage: Development | U (Understand) | Cycles → Flows → Code → PR | HIGH |
| J04 | D-Stage: Deployment | D (Deliver) | Recipes → Deploy → Rollback | HIGH |
| J05 | A-Stage: Database Ops | A (Allocate) | DB Copy → Anonymize → Approve | MEDIUM |
| J06 | Meetings & Integration | ALL | Otter.ai → Flows → Slack | MEDIUM |
| J07 | Analytics & Mastery | ALL | Velocity → DORA → Gamification | LOW |

---

## 5. Test Data

### Test User Creation
Each journey starts with a fresh user:
- Email: `testuser@quadframe.work`
- Password: `Test123!`
- Organization: Auto-created on signup

### Sample Data Required
Database must have sample data loaded via seed:
- Core roles (18 master roles)
- Sample domains
- Sample flows
- AI tier configurations

### Seed Command
```bash
DATABASE_URL="postgresql://quad_user:quad_dev_pass@localhost:16201/quad_dev_db" npx prisma db seed
```

---

## 6. Bug Severity Levels

| Severity | Description | Example |
|----------|-------------|---------|
| **P0 Critical** | App crashes, data loss, security breach | Crash on login, AI reveals PII |
| **P1 High** | Feature not working | Cannot create Flow from requirement |
| **P2 Medium** | Works with issues | Wrong AI confidence displayed |
| **P3 Low** | Minor UI issues | Text alignment off |

---

## 7. AI Testing Special Considerations

### Confidence Scoring
| Score Range | Action | Test Verification |
|-------------|--------|-------------------|
| 90%+ | Recommended | Show "Recommended" badge |
| 70-89% | Review Carefully | Show warning indicator |
| <70% | Manual Review Required | Block auto-approval |

### Human-in-the-Loop
Every AI action MUST have:
- [ ] Approval gate before execution
- [ ] Ability to reject/modify
- [ ] Full audit trail logged

---

## 8. Success Criteria

A journey is **test-complete** when:
- [ ] All steps pass
- [ ] No P0/P1 bugs
- [ ] Data persists correctly
- [ ] Error cases handled
- [ ] AI operations have human override
- [ ] Results logged in TEST_RESULTS.md

---

## 9. Scope

### In Scope
- All Next.js pages (src/app/)
- All API routes (src/app/api/)
- Prisma database operations
- AI Flow Accelerator interactions
- Circle permissions and roles

### Out of Scope
- Third-party API testing (GitHub, Slack, Otter.ai)
- Performance/load testing
- Security penetration testing

---

## 10. Phase 1 Implementation Status

Based on gap analysis (January 2, 2026):

| Stage | Tables | API | UI | Overall |
|-------|--------|-----|----|---------|
| Q-Stage | 85% | 50% | 65% | **50%** |
| U-Stage | 67% | 45% | 55% | **37%** |
| D-Stage | 100% | 75% | 0% | **25%** |
| A-Stage | 100% | 100% | 0% | **33%** |
| Git Integration | 50% | 0% | 0% | **0%** |
| Meeting→Flows | 100% | 0% | 0% | **0%** |
| Slack (Nexus) | 60% | 0% | 0% | **0%** |
| Gamification | 100% | 67% | 67% | **66%** |

**Overall Phase 1: ~35% Complete**

---

**See Also:**
- [TEST_EXECUTION.md](TEST_EXECUTION.md) - How to run tests
- [TEST_RESULTS.md](TEST_RESULTS.md) - Test status tracking
- [journeys/](journeys/) - Journey test scenarios
- [PHASE1_GAP_ANALYSIS.md](../PHASE1_GAP_ANALYSIS.md) - Implementation gaps
