# QUAD Full Demo Script - Pitch Presentation

**Duration:** 15-20 minutes
**Audience:** Investors / Partners / Customers

---

## Demo Story

> "Watch me build a banking app from ZERO to DEPLOYED in 15 minutes using QUAD"

---

## Pre-Demo Setup

```bash
# Clean demo folder
rm -rf ~/demo-banking-app

# Ensure quad is installed
quad --version
# → quad, version 0.1.0
```

---

## STEP 1: Login (30 seconds)

**Narration:** "First, I authenticate with my organization"

```bash
$ quad login

✓ Opening browser for Google Sign-In...
✓ Welcome, Pradeep Kumar!
✓ Organization: MassMutual
✓ Saved to ~/.quad/config.json

# Show the config
$ cat ~/.quad/config.json
{
  "user_email": "pradeep@massmutual.com",
  "user_name": "Pradeep Kumar",
  "org_code": "MASM",
  "org_name": "MassMutual",
  "token": "eyJ..."
}
```

**Key Point:** "My org context is now available for all QUAD commands"

---

## STEP 2: Initialize Project (1 minute)

**Narration:** "Now I create a new project with ONE command"

```bash
$ cd ~/projects
$ quad init banking-portal

  QUAD Project Initialization
  ───────────────────────────

  → Creating project: banking-portal
  → Project type? [1] Web App  [2] API  [3] Mobile  [4] Full Stack
  Select: 4

  → Frontend? [1] Next.js  [2] React  [3] Vue
  Select: 1

  → Backend? [1] Spring Boot  [2] Node.js  [3] Python
  Select: 1

  → Database? [1] PostgreSQL  [2] MySQL  [3] MongoDB
  Select: 1

  ✓ Created: banking-portal/
  ✓ Created: banking-portal/.quad/config.json
  ✓ Created: banking-portal/README.md
  ✓ Created: banking-portal/CLAUDE.md
  ✓ Created: banking-portal/documentation/architecture/README.md
  ✓ Created: banking-portal/documentation/database/README.md
  ✓ Created: banking-portal/documentation/api/README.md
  ✓ Created: banking-portal/documentation/web/README.md
  ✓ Created: banking-portal/documentation/mobile/README.md
  ✓ Created: banking-portal/documentation/deployment/README.md
  ✓ Created: banking-portal/documentation/security/README.md
  ✓ Created: banking-portal/documentation/testing/README.md
  ✓ Created: banking-portal/documentation/misc/README.md
  ✓ Saved to database: quad_domains

  Project initialized! Next: quad story
```

**Show folder structure:**
```bash
$ tree banking-portal/
banking-portal/
├── README.md
├── CLAUDE.md
├── .quad/
│   └── config.json
└── documentation/
    ├── architecture/README.md
    ├── database/README.md
    ├── api/README.md
    └── ... (9 folders)
```

**Key Point:** "Standard structure, ready for any team member"

---

## STEP 3: Create User Stories (2 minutes)

**Narration:** "Now I tell QUAD what features I need - in plain English"

```bash
$ cd banking-portal
$ quad story create

  QUAD Story Generator
  ─────────────────────

  Describe what you want to build:
  > I need a banking portal where users can:
  > - Login with their bank credentials
  > - View account balances
  > - Transfer money between accounts
  > - View transaction history
  > - Download statements as PDF

  Generating user stories using PGCE algorithm...

  ✓ Analyzing requirements...
  ✓ Calculating dependencies...
  ✓ Prioritizing by PGCE formula: P = (D × 0.5) + (I × 0.3) + (C' × 0.2)

  Generated 12 stories in priority order:

  ┌────┬─────────────────────────────────┬──────────┬───────┐
  │ #  │ Story                           │ Priority │ Phase │
  ├────┼─────────────────────────────────┼──────────┼───────┤
  │ 1  │ Database schema setup           │ 0.95     │ 1     │
  │ 2  │ User authentication API         │ 0.90     │ 1     │
  │ 3  │ JWT token management            │ 0.85     │ 1     │
  │ 4  │ Account balance API             │ 0.75     │ 2     │
  │ 5  │ Transaction history API         │ 0.70     │ 2     │
  │ 6  │ Money transfer API              │ 0.65     │ 2     │
  │ 7  │ Login page UI                   │ 0.60     │ 3     │
  │ 8  │ Dashboard UI                    │ 0.55     │ 3     │
  │ 9  │ Transfer form UI                │ 0.50     │ 3     │
  │ 10 │ Transaction list UI             │ 0.45     │ 3     │
  │ 11 │ PDF statement generation        │ 0.40     │ 4     │
  │ 12 │ Email notifications             │ 0.35     │ 4     │
  └────┴─────────────────────────────────┴──────────┴───────┘

  ✓ Saved 12 stories to database
  ✓ Created: .quad/stories.json

  Ready to generate code? Run: quad code
```

**Key Point:** "PGCE algorithm ensures we build in the RIGHT ORDER - database first, then API, then UI. No more dependency hell!"

---

## STEP 4: Generate Code (3 minutes)

**Narration:** "Now the magic - QUAD generates production-ready code"

```bash
$ quad code generate

  QUAD Code Generator (PGCE Engine)
  ──────────────────────────────────

  Phase 1: Foundation (Stories 1-3)
  ─────────────────────────────────

  [1/3] Database schema setup...

  → Reading industry patterns for "banking"...
  → Generating PostgreSQL schema...

  ✓ Created: banking-portal-database/
  ✓ Created: sql/tables/users.sql
  ✓ Created: sql/tables/accounts.sql
  ✓ Created: sql/tables/transactions.sql
  ✓ Created: migrations/V1__initial_schema.sql

  [2/3] User authentication API...

  → Using pattern: Spring Boot + JWT
  → Generating controllers, services, repositories...

  ✓ Created: banking-portal-api/
  ✓ Created: src/main/java/.../AuthController.java
  ✓ Created: src/main/java/.../AuthService.java
  ✓ Created: src/main/java/.../UserRepository.java
  ✓ Created: src/main/java/.../JwtUtil.java

  [3/3] JWT token management...

  ✓ Created: src/main/java/.../JwtFilter.java
  ✓ Created: src/main/java/.../SecurityConfig.java

  Phase 1 Complete! ████████████░░░░░░░░ 25%

  Continue to Phase 2? [Y/n]: y

  Phase 2: Core Features (Stories 4-6)
  ────────────────────────────────────

  [4/6] Account balance API...
  ✓ Created: AccountController.java
  ✓ Created: AccountService.java
  ✓ Created: AccountRepository.java

  [5/6] Transaction history API...
  ✓ Created: TransactionController.java
  ✓ Created: TransactionService.java

  [6/6] Money transfer API...
  ✓ Created: TransferController.java
  ✓ Created: TransferService.java
  ✓ Created: TransferValidator.java

  Phase 2 Complete! ████████████████░░░░ 50%

  Continue to Phase 3? [Y/n]: y

  Phase 3: User Interface (Stories 7-10)
  ──────────────────────────────────────

  [7/10] Login page UI...
  ✓ Created: banking-portal-web/
  ✓ Created: app/login/page.tsx
  ✓ Created: components/LoginForm.tsx

  [8/10] Dashboard UI...
  ✓ Created: app/dashboard/page.tsx
  ✓ Created: components/AccountCard.tsx
  ✓ Created: components/BalanceDisplay.tsx

  [9/10] Transfer form UI...
  ✓ Created: app/transfer/page.tsx
  ✓ Created: components/TransferForm.tsx

  [10/10] Transaction list UI...
  ✓ Created: components/TransactionList.tsx
  ✓ Created: components/TransactionRow.tsx

  Phase 3 Complete! █████████████████░░░ 75%

  Continue to Phase 4? [Y/n]: y

  Phase 4: Enhancements (Stories 11-12)
  ─────────────────────────────────────

  [11/12] PDF statement generation...
  ✓ Created: StatementService.java
  ✓ Created: PdfGenerator.java

  [12/12] Email notifications...
  ✓ Created: EmailService.java
  ✓ Created: NotificationConfig.java

  ════════════════════════════════════════
  Code Generation Complete! ████████████████████ 100%
  ════════════════════════════════════════

  Summary:
  ├── banking-portal-database/  (5 files)
  ├── banking-portal-api/       (23 files)
  └── banking-portal-web/       (18 files)

  Total: 46 files generated

  Next: quad test
```

**Key Point:** "46 production-ready files in 3 minutes. No hallucination - uses YOUR org's coding patterns!"

---

## STEP 5: Run Tests (1 minute)

**Narration:** "Let's verify the generated code works"

```bash
$ quad test

  QUAD Test Runner
  ────────────────

  [Database] Running schema validation...
  ✓ All tables valid
  ✓ Foreign keys correct
  ✓ Indexes optimized

  [API] Running unit tests...
  ✓ AuthControllerTest - 5/5 passed
  ✓ AccountControllerTest - 4/4 passed
  ✓ TransferControllerTest - 6/6 passed
  ✓ All 15 tests passed

  [Web] Running component tests...
  ✓ LoginForm.test.tsx - passed
  ✓ TransferForm.test.tsx - passed
  ✓ All 8 tests passed

  ════════════════════════════════
  Total: 23 tests, 23 passed, 0 failed
  Coverage: 85%
  ════════════════════════════════
```

**Key Point:** "Tests generated alongside code - not an afterthought"

---

## STEP 6: Deploy (2 minutes)

**Narration:** "Now let's deploy to the cloud"

```bash
$ quad deploy dev

  QUAD Deployment
  ───────────────

  Environment: dev
  Target: GCP Cloud Run

  [1/4] Building database container...
  ✓ PostgreSQL image ready

  [2/4] Building API container...
  ✓ Spring Boot JAR built
  ✓ Docker image: banking-portal-api:v1.0.0

  [3/4] Building Web container...
  ✓ Next.js build complete
  ✓ Docker image: banking-portal-web:v1.0.0

  [4/4] Deploying to Cloud Run...
  ✓ Database deployed: postgres-banking-dev
  ✓ API deployed: https://banking-api-dev.quadframe.work
  ✓ Web deployed: https://banking-dev.quadframe.work

  ════════════════════════════════════════
  Deployment Complete!
  ════════════════════════════════════════

  URLs:
  ├── Web:  https://banking-dev.quadframe.work
  ├── API:  https://banking-api-dev.quadframe.work
  └── Docs: https://banking-dev.quadframe.work/docs

  Open in browser? [Y/n]: y
```

**Key Point:** "From zero to deployed in 15 minutes!"

---

## STEP 7: Show Running App (1 minute)

**Narration:** "Let's see it running"

```bash
# Browser opens automatically
# Show:
# 1. Login page
# 2. Dashboard with account balances
# 3. Transfer money form
# 4. Transaction history
```

---

## Bonus: Team Analytics

**Narration:** "QUAD also tracks team health"

```bash
$ quad burnout

  Team Burnout Analysis
  ─────────────────────

  ┌─────────────────┬───────────┬────────────┐
  │ Team Member     │ Workload  │ Status     │
  ├─────────────────┼───────────┼────────────┤
  │ Pradeep Kumar   │ ████████░░│ 80% - High │
  │ Manju Singh     │ ██████░░░░│ 60% - OK   │
  │ Suman Addanki   │ █████░░░░░│ 50% - OK   │
  └─────────────────┴───────────┴────────────┘

  ⚠️  Alert: Pradeep is at risk of burnout
  → Suggestion: Reassign 2 tickets to Manju

$ quad chart velocity

  Sprint Velocity (Last 4 Sprints)
  ────────────────────────────────

  Sprint 1: ████████████████████ 42 pts
  Sprint 2: ██████████████████░░ 38 pts
  Sprint 3: ████████████████░░░░ 35 pts
  Sprint 4: ██████████████████████ 45 pts

  Average: 40 pts/sprint
  Trend: ↑ Improving
```

---

## Summary Slide

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   QUAD: Zero to Deployed in 15 Minutes              │
│                                                      │
│   ✓ quad login    - SSO authentication              │
│   ✓ quad init     - Project + docs structure        │
│   ✓ quad story    - AI generates user stories       │
│   ✓ quad code     - PGCE generates 46 files         │
│   ✓ quad test     - Automated testing               │
│   ✓ quad deploy   - One-click deployment            │
│   ✓ quad burnout  - Team health analytics           │
│                                                      │
│   Patents Pending:                                   │
│   • PGCE Algorithm (63/957,663)                     │
│   • QUAD Platform (63/956,810)                      │
│   • Dynamic Agent Generation (63/957,071)           │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## Commands to Build for Demo

| Priority | Command | Status |
|----------|---------|--------|
| 1 | `quad login` | 🔨 Build |
| 2 | `quad init` | 🔧 Fix |
| 3 | `quad story create` | 🔨 Build |
| 4 | `quad code generate` | 🔨 Build |
| 5 | `quad test` | 🔨 Build |
| 6 | `quad deploy` | ✅ Done |
| 7 | `quad burnout` | 🔨 Build |
| 8 | `quad chart` | 🔨 Build |

---

**Copyright © 2026 Gopi Suman Addanke. All Rights Reserved.**
