# CLAUDE.md - QUAD Framework Website

This file provides guidance to Claude Code when working with the QUAD Framework website.

## Project Overview

**QUAD Framework** (quadframe.work) is the official documentation and learning site for the QUAD methodology - Quick Unified Agentic Development.

**Tech Stack:**
- Next.js 15.5 (App Router)
- TypeScript
- Tailwind CSS
- **Database:** PostgreSQL with SQL + JPA (NOT Prisma - migrated Jan 2026)
- **Backend:** Java Spring Boot 3.2.1 (quad-services)
- NextAuth.js for OAuth authentication
- Deployed on Mac Studio (Docker) + GCP Cloud Run

**Live URLs:**
- DEV Web: https://dev.quadframe.work (port 14001)
- DEV API: https://dev-api.quadframe.work (port 14101)
- QA Web: https://qa.quadframe.work (port 15001)
- QA API: https://qa-api.quadframe.work (port 15101)
- DEV Database: localhost:14201 (quad_dev_db)
- QA Database: localhost:15201 (quad_qa_db)

---

## Cloudflare DNS Configuration

**Mac Studio IP:** 96.240.97.243

**DNS Architecture:**
```
User → Cloudflare DNS → Mac Studio (96.240.97.243) → Caddy (SSL) → Docker Container
```

**QUAD Framework DNS Records:**

| Subdomain | IP Address | Proxy | Port (via Caddy) | Container | Purpose |
|-----------|------------|-------|------------------|-----------|---------|
| dev.quadframe.work | 96.240.97.243 | ❌ Off | 14001 | quad-web-dev | Web UI |
| qa.quadframe.work | 96.240.97.243 | ❌ Off | 15001 | quad-web-qa | Web UI |
| dev-api.quadframe.work | 96.240.97.243 | ❌ Off | 14301 | quad-api-dev | API Gateway (external clients) |
| qa-api.quadframe.work | 96.240.97.243 | ❌ Off | 15301 | quad-api-qa | API Gateway (external clients) |
| api.quadframe.work | GCP Cloud Run | ✅ On | - | quad-api-prod | API Gateway (PROD) |

**API Architecture:**
```
VS Code Extension / External Clients
           ↓
    dev-api.quadframe.work (Caddy SSL)
           ↓
    quad-api-dev:3100 (API Gateway)
           ↓
    [Rate Limiting + API Key Auth + Whitelist]
           ↓
    quad-services-dev:8080 (Java Backend)
           ↓
    postgres-quad-dev:5432
```

**Key Points:**
- Cloudflare proxy is **OFF** (DNS only)
- Caddy handles SSL/HTTPS termination automatically
- All HTTPS traffic goes through Caddy on ports 80/443
- Caddy routes to containers based on subdomain

**DNS Management:**
- Automated script: `/Users/semostudio/scripts/cloudflare-dns-sync.sh`
- Cloudflare API token stored in Vaultwarden (QUAD org → dev collection)
- Documentation: `/Users/semostudio/scripts/CLOUDFLARE_DNS_MANAGEMENT.md`

---

## Git Workflow & Repository Structure

### Organizations
| Organization | Purpose | Visibility |
|-------------|---------|------------|
| **a2Vibes** | Active development | Private (members only) |
| **a2vibecreators** | Backup/Production | Private |

### Branch Strategy
```
main ─────────────── protected (backup to a2vibecreators after testing)
  ├── sumanMain ──── Suman's working branch
  └── SharuMain ──── Sharath's working branch
```

### Development Workflow
1. **All coding happens in a2Vibes org** on your personal branch (sumanMain/SharuMain)
2. **After testing**, push to a2vibecreators as backup
3. **Never push directly to main** - merge via pull request

### Sync to Backup (a2vibecreators)
```bash
# One-time setup: Add upstream remote
git remote add upstream git@github.com:a2vibecreators/QUAD.git

# After testing, push to backup
git push upstream sumanMain:main
```

### Related Repos (all in a2Vibes)
- QUAD (parent - this repo)
- QUAD-web, QUAD-database, QUAD-services
- QUAD-vscode, QUAD-android, QUAD-ios

### Team Members
- **sumanaddanki** - Admin, works on `sumanMain`
- **sharuuu** - Member, works on `SharuMain`

---

## QUAD Development Model - Revolutionary Paradigm Shift

**CRITICAL:** QUAD Platform enables a fundamentally different development approach compared to traditional Agile.

**Traditional Agile (Waterfall in Disguise):**
```
Week 1-2: BA writes 40-page detailed spec
Week 3-6: Developers build based on spec
Week 7-9: Business sees working software
Week 10: "This isn't what we wanted" → Start over
```

**QUAD Model (AI-Accelerated Spiral):**
```
Prerequisites: Company provides UI blueprint + optional Git repo reference
Hour 1: BA writes minimal POC spec (1-2 paragraphs)
Hour 2-8: QUAD AI agents develop and deploy to DEV
Same Day: Business sees working prototype
Same Day: Business provides feedback via email/Slack/Jira
Hours later: QUAD agents iterate based on feedback
Same Day: Deploy to production
```

**Prerequisites Before Development:**
1. **UI Blueprint (Required for UI projects)** - Figma/Sketch design, wireframes, or competitor reference
   - If not available: Blueprint Agent AI interviews company and generates mockup
2. **Sample Git Repo (Optional)** - Existing codebase for style/pattern matching

### Blueprint Agent System (Production Feature)

**Overview:** Blueprint Agent is a real, production-ready feature that helps companies create UI blueprints before QUAD Platform development begins.

**Core Principle:** Keep it simple - UI projects REQUIRE blueprints (hard block), API projects don't.

**Q1 Decisions - Tech Stack & Domain Selection (COMPLETED):**

1. **Multi-step Wizard Flow:**
   - First domain creation: Full multi-step wizard walkthrough
   - Subdomain creation: Inherit parent domain settings (shorter flow)
   - Admin can edit anytime (settings changeable after creation)
   - Subdomain requests changes: Email domain admin to modify parent settings

2. **Tech Stack Usage:** ✅ YES - Generate framework-specific code
   - **Why:** 30-40% faster development (no HTML → React conversion)
   - **Example:** React + Tailwind → generates `<div className="...">` not generic HTML

3. **Domain-Specific Sample Data:** ✅ YES - Pre-populate realistic data
   - **Initial 8 Domains:** Healthcare, Finance/Insurance, E-commerce, SaaS Dashboard, Real Estate, Education, Logistics, CRM
   - **Benefits:** Realistic mockups (not "User 1, User 2"), industry-specific terminology

4. **Domain + Project Type Support Check:** ✅ YES
   - Check database before allowing domain creation
   - If unsupported combination: "⚠️ Not common. Contact us for custom setup."

**Q2 Decisions - Prerequisites Upload Flow (COMPLETED):**

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Blueprint requirement | UI projects = REQUIRED<br>API projects = OPTIONAL | Simple: If it has UI, you need a blueprint |
| When upload happens | During project setup (hard block for UI) | No flexibility = no complexity |
| Multiple blueprints per domain | ✅ YES (per project_subtype) | One domain can have web-internal + web-external |
| Subdomain inherits parent blueprint | ✅ YES (can override) | Saves work, but flexible |
| File storage | URLs ONLY (no file upload yet) | Phase 1: Just URLs, Phase 2: File upload |
| Verify URL accessibility | ✅ YES | Basic validation - ping URL to check it works |
| Auto-screenshot competitor URLs | ✅ YES | Helpful reference - store screenshot for later |
| Allow multiple URLs per blueprint | ✅ YES | Homepage + dashboard = different pages |
| Show preview after pasting URL | ✅ YES | Better UX - show iframe/screenshot |
| Auto-approve uploaded blueprint | ✅ AUTO-APPROVE | Keep simple - user uploaded = approved |

**Database Tables:**
- `QUAD_domain_project_support` - Track which domain + project type combinations are supported
- `QUAD_domain_blueprints` - Store blueprint URLs and Git repo references (URLs only in Phase 1)
- `QUAD_blueprint_agent_sessions` - Track Blueprint Agent conversations and Q&A

**Complete Documentation:** See `/documentation/BLUEPRINT_AGENT_IMPLEMENTATION_PLAN.md` (detailed schemas, user flows, sample data)

**Key Metrics:**
- **Time to first prototype:** 2-8 hours (vs 6-9 weeks traditional)
- **Iteration speed:** 3-5 per day (vs 1 per 2-4 weeks)
- **Cost per feature:** $2K-$10K (vs $50K-$200K)
- **Rework rate:** 5-10% (vs 30-40%)
- **Business satisfaction:** 90-95% (vs 60-70%)

**Communication Channels for Continuous Development:**
1. **Email Agent:** BA sends email to quad-agents@ → Auto-creates Jira ticket → Agents implement
2. **Slack Agent:** "@quad add price filter to products page" → Auto-implements in hours
3. **Jira Agent:** BA updates ticket with new requirement → Auto-implements

**Complete Documentation:** See `/documentation/QUAD_DEVELOPMENT_MODEL.md` (18 pages, real-world examples)

**Website Showcase:** Homepage has prominent "QUAD Revolution" section comparing Traditional Agile vs QUAD Model

---

## Key Features

### 1. Flow-Based Navigation
Pages are organized into 3 flows:
- **EXPLORE** (blue) - Learn about QUAD concepts
- **TRY** (green) - Interactive demos and tools
- **RESOURCES** (purple) - Reference materials

### 2. Methodology Lens
Users can select their background methodology (Agile, Waterfall, Kanban, etc.) and content is shown through that lens - comparing QUAD terms to familiar equivalents.

### 3. Interactive Features
- `/quiz` - Interactive knowledge quiz
- `/cheatsheet` - Searchable terminology reference
- `/demo` - Role-based dashboard demo
- `/configure` - QUAD configuration generator

---

## Future Methodologies (Document Here, Not in UI)

This section documents additional methodologies that could be added to the Methodology Lens feature in the future. These are NOT currently in the UI but are documented for future implementation.

### Planned Additions

| Methodology | Status | Notes |
|-------------|--------|-------|
| **Lean** | Future | Toyota Production System, eliminate waste |
| **XP (Extreme Programming)** | Future | Pair programming, TDD, continuous integration |
| **Crystal** | Future | Family of methodologies based on team size |
| **DSDM** | Future | Dynamic Systems Development Method |
| **FDD** | Future | Feature-Driven Development |
| **RAD** | Future | Rapid Application Development |
| **RUP** | Future | Rational Unified Process |
| **Prince2** | Future | Project management methodology (UK government) |
| **PMI/PMP** | Future | Project Management Institute standards |
| **ITIL** | Future | IT Service Management framework |

### Methodology Comparison Data (For Future Implementation)

#### Lean
```typescript
{
  id: "lean",
  name: "Lean",
  icon: "🏭",
  description: "I know Toyota Production System, value stream mapping, eliminate waste",
  color: "slate",
  mappings: {
    cycle: "Value stream cycle",
    pulse: "Kaizen event",
    checkpoint: "Gemba walk",
    trajectory: "Hoshin Kanri",
    circle1: "Value stream manager",
    circle2: "Production team",
    circle3: "Quality circles",
    circle4: "Maintenance team",
    flowDocument: "A3 report",
    humanGate: "Andon signal",
    docsFirst: "Standard work first",
    aiAgents: "Automation (jidoka)",
  }
}
```

#### XP (Extreme Programming)
```typescript
{
  id: "xp",
  name: "XP",
  icon: "⚡",
  description: "I know pair programming, TDD, continuous integration, refactoring",
  color: "lime",
  mappings: {
    cycle: "Release cycle (1-3 months)",
    pulse: "Iteration (1-2 weeks)",
    checkpoint: "Daily standup",
    trajectory: "Release planning",
    circle1: "Customer + Coach",
    circle2: "Development pairs",
    circle3: "QA (same team)",
    circle4: "Technical practices",
    flowDocument: "Story card + Tests",
    humanGate: "Acceptance test",
    docsFirst: "Tests-first (TDD)",
    aiAgents: "Pair programming AI",
  }
}
```

#### DSDM (Dynamic Systems Development Method)
```typescript
{
  id: "dsdm",
  name: "DSDM",
  icon: "🎯",
  description: "I know MoSCoW prioritization, timeboxing, active user involvement",
  color: "rose",
  mappings: {
    cycle: "Timebox (2-6 weeks)",
    pulse: "Weekly review",
    checkpoint: "Daily coordination",
    trajectory: "Increment",
    circle1: "Business Ambassador + Solution Developer",
    circle2: "Solution Development Team",
    circle3: "Solution Tester",
    circle4: "Technical Coordinator",
    flowDocument: "Prioritized Requirements List (PRL)",
    humanGate: "Facilitated workshop",
    docsFirst: "Active user involvement",
    aiAgents: "MoSCoW AI prioritization",
  }
}
```

#### Prince2
```typescript
{
  id: "prince2",
  name: "Prince2",
  icon: "👑",
  description: "I know project boards, stage gates, exception reports",
  color: "violet",
  mappings: {
    cycle: "Management Stage",
    pulse: "Work Package",
    checkpoint: "Checkpoint Report",
    trajectory: "Project",
    circle1: "Project Board + PM",
    circle2: "Team Manager + Team",
    circle3: "Project Assurance",
    circle4: "Project Support",
    flowDocument: "Product Description",
    humanGate: "Stage Gate / Exception",
    docsFirst: "Product-based planning",
    aiAgents: "Automated reporting",
  }
}
```

### How to Add a New Methodology

1. **Add to MethodologyContext.tsx:**
   - Add new type to `MethodologyType` union
   - Add new entry to `METHODOLOGIES` array

2. **Add to MethodologyLens.tsx:**
   - Add new property to `TermMapping` interface
   - Add mapping values for each term in `METHODOLOGY_MAPPINGS`
   - Add case to `getComparisonValue` switch
   - Add color class to `colorClasses`
   - Add summary text in the lens indicator

3. **Test:**
   - Verify dropdown shows new option
   - Verify comparison table shows correct mappings
   - Verify colors and styling work

---

## URL Versioning System

The QUAD Framework website supports versioning to allow comparing different versions of the methodology.

### Current Implementation

- **Version Badge** in header shows current version (v1.0)
- **Version Context** (`src/context/VersionContext.tsx`) manages version state
- **Version History** dropdown shows changelog

### How to Add a New Version

1. **Update VersionContext.tsx:**
```typescript
export const VERSIONS: VersionInfo[] = [
  {
    version: "2.0",
    displayVersion: "2.0",
    releaseDate: "March 2026",
    isLatest: true,  // Mark this as latest
    changelog: [
      "New feature 1",
      "New feature 2",
    ],
  },
  {
    version: "1.0",
    displayVersion: "1.0",
    releaseDate: "December 2025",
    isLatest: false,  // No longer latest
    changelog: [...],
  },
];
```

2. **Create versioned route (optional):**
If you want to serve archived versions at `/1.0/`, create:
```
src/app/(v1.0)/
├── layout.tsx  # Wrapper with VersionProvider version="1.0"
├── concept/page.tsx
└── ... (copy of old pages)
```

3. **Future Plans:**
- `/1.0/concept` → Version 1.0 of concept page
- `/latest/concept` → Redirects to current version
- `/concept` → Always serves latest

---

## Project Structure

```
quadframework/
├── src/                         # Next.js web app
│   ├── app/                     # App Router pages
│   │   ├── page.tsx             # Homepage
│   │   ├── api/                 # API routes (thin layer, delegates to Java)
│   │   ├── concept/             # QUAD methodology pages
│   │   ├── demo/                # Dashboard demo
│   │   └── ...
│   ├── components/              # Reusable components
│   └── lib/                     # Utilities, API clients
├── quad-services/          # Java Spring Boot backend (PRIMARY)
│   ├── src/main/java/com/quad/services/
│   │   ├── controller/          # REST endpoints (Auth, User)
│   │   ├── service/             # Business logic (AuthService, UserService)
│   │   ├── repository/          # JPA repositories (UserRepository, OrganizationRepository)
│   │   ├── entity/              # JPA entities (User, Organization)
│   │   ├── dto/                 # Request/Response DTOs (SignupRequest, AuthResponse)
│   │   ├── config/              # Spring config (SecurityConfig)
│   │   └── security/            # JWT utilities
│   ├── pom.xml                  # Maven config (Java 17, Spring Boot 3.2.1, Lombok 1.18.36)
│   └── Dockerfile               # Multi-stage build (Maven + JRE 17)
├── quad-api/                    # API Gateway for external clients (submodule)
│   ├── src/
│   │   ├── index.js             # Express server
│   │   └── middleware/          # Auth, rate limiting, whitelist
│   ├── Dockerfile               # API gateway container
│   └── README.md                # API gateway docs
├── quad-vscode/                 # VS Code extension (submodule)
├── quad-database/               # Database migrations (submodule)
├── quad-ios/                    # iOS app (submodule - future)
├── quad-android/                # Android app (submodule - future)
├── documentation/               # Markdown docs
└── CLAUDE.md                    # This file
```

**Note:** Java `quad-services` is the primary backend.

---

## Java Backend (quad-services)

**Stack:** Spring Boot 3.2.1, PostgreSQL 15, JWT auth, BCrypt

**Build Requirements:**
- Java 17 (compilation): `brew install openjdk@17`
- Maven 3.9+
- Lombok 1.18.36 (Java 21 compatibility)

**Endpoints:**

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| `/auth/signup` | POST | Create organization + user | No |
| `/auth/login` | POST | Email/password authentication | No |
| `/users/email/{email}` | GET | User lookup (OAuth account linking) | No |
| `/users/email/{email}/exists` | GET | Check user existence | No |
| `/auth/health` | GET | Service health check | No |

**Docker Build & Deploy:**
```bash
cd quad-services
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
mvn clean package -DskipTests
docker build -t quad-services:dev .
docker run -d \
  --name quad-services-dev \
  --network dev-network \
  -p 14101:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:postgresql://postgres-quad-dev:5432/quad_dev_db" \
  -e SPRING_DATASOURCE_USERNAME="quad_user" \
  -e SPRING_DATASOURCE_PASSWORD="quad_dev_pass" \
  -e JWT_SECRET="your-secret" \
  quad-services:dev
```

**Network Requirements:**
All containers must be on `dev-network`:
```bash
docker network connect dev-network postgres-quad-dev
docker network connect dev-network quad-services-dev
docker network connect dev-network quad-web-dev
```

**See:** [OAuth Implementation Guide](documentation/OAUTH_IMPLEMENTATION.md)

---

## Secrets Management (Vaultwarden)

### Vault Structure

All secrets are stored in Vaultwarden at **vault.nutrinine.app**

```
╔══════════════════════════════════════════════════════════════════╗
║                    VAULTWARDEN VAULT STRUCTURE                   ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│ 📁 QUAD Organization (id: 579c22f3-4f13-447c-a861-9a4aa0ab7fbc) │
├─────────────────────────────────────────────────────────────────┤
│   📂 dev/                                                       │
│      🔐 Anthropic API Key                                       │
│      🔐 Database                                                │
│      🔐 GitHub OAuth                                            │
│      🔐 Google OAuth                                            │
│      🔐 NextAuth Secret                                         │
│   📂 qa/                                                        │
│      🔐 (same items as dev)                                     │
│   📂 prod/                                                      │
│      🔐 (same items as dev)                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📁 NutriNine Organization (id: a2608572-3e25-4b3a-996b-cd5be95b12c0) │
├─────────────────────────────────────────────────────────────────┤
│   📂 dev/                                                       │
│      🔐 AWS Credentials                                         │
│      🔐 Database                                                │
│      🔐 Email HMAC Secret                                       │
│      🔐 GitHub Backup Sync                                      │
│      🔐 Gmail SMTP                                              │
│      🔐 Google Gemini API Key                                   │
│      🔐 JWT Secret                                              │
│      🔐 MSG91 (India OTP)                                       │
│      🔐 Sarvam AI                                               │
│      🔐 Twilio                                                  │
│      🔐 Zoho SMTP                                               │
│   📂 qa/                                                        │
│      🔐 (same items as dev)                                     │
│   📂 prod/                                                      │
│      🔐 (same items as dev)                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Environment Variables Mapping

| Secret in Vault | Environment Variable | Used In |
|-----------------|---------------------|---------|
| NextAuth Secret | `NEXTAUTH_SECRET` | .env.local |
| Google OAuth | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` | .env.local |
| GitHub OAuth | `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET` | .env.local |
| Anthropic API Key | `ANTHROPIC_API_KEY` | .env.local |
| Database | `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL` | .env.local |

### Local Development Setup

1. **Get Vaultwarden Access**: Request access from admin (sumanaddanki)
2. **Login to Vault**: https://vault.nutrinine.app
3. **Navigate to**: QUAD org → dev collection
4. **Create `.env.local`** from template:
   ```bash
   cp .env.example .env.local
   ```
5. **Fill in secrets** from vault

### Using bw CLI

```bash
# Login to Vaultwarden
export BW_SESSION=$(bw unlock --raw)

# List all organizations
bw list organizations

# List QUAD secrets (dev collection)
bw list items --organizationid 579c22f3-4f13-447c-a861-9a4aa0ab7fbc --collectionid e4f03d1a-b8ac-4186-a384-0fb62d431ddd

# List NutriNine secrets (dev collection)
bw list items --organizationid a2608572-3e25-4b3a-996b-cd5be95b12c0 --collectionid c792c297-8ccd-46a1-b691-7955ede25eb5

# Get specific secret from QUAD
bw get item "NextAuth Secret" --organizationid 579c22f3-4f13-447c-a861-9a4aa0ab7fbc

# Get Database credentials
bw get item "Database" --organizationid 579c22f3-4f13-447c-a861-9a4aa0ab7fbc --collectionid e4f03d1a-b8ac-4186-a384-0fb62d431ddd
```

### OAuth Configuration (Google Sign-In)

**Status:** ✅ **Google OAuth configured and enabled** (Jan 4, 2026)

**Google Cloud Setup:**
- **Project:** "QUAD Platform" (ID: quad-platform)
- **OAuth Client:** "QUAD Platform Dev"
- **Client ID:** `805817782076-b6975p184nj0kqcs9l0hurjj2bv6gkev.apps.googleusercontent.com`
- **Authorized Origins:** dev.quadframe.work, qa.quadframe.work, quadframe.work
- **Redirect URIs:**
  - `https://dev.quadframe.work/api/auth/callback/google`
  - `https://qa.quadframe.work/api/auth/callback/google`
  - `https://quadframe.work/api/auth/callback/google`

**Storage:**
- Client ID & Secret stored in `.env.local`
- Also documented in Vaultwarden (QUAD org → dev → Google OAuth)

**GitHub OAuth:** Not configured yet (GitHub sign-in disabled)

**Testing Google Sign-In:**
```bash
# Go to login page
https://dev.quadframe.work/auth/login

# You should now see "Sign in with Google" button
# Click it to test OAuth flow
```

### Organization IDs

| Organization | ID |
|--------------|-----|
| QUAD | `579c22f3-4f13-447c-a861-9a4aa0ab7fbc` |
| NutriNine | `a2608572-3e25-4b3a-996b-cd5be95b12c0` |

### Collection IDs (QUAD)

| Collection | ID |
|------------|-----|
| dev | `e4f03d1a-b8ac-4186-a384-0fb62d431ddd` |
| qa | `75fb3b57-9e84-4e2d-8b4f-447518e0a315` |
| prod | `cc4a16a2-9acc-459a-ad37-a8ef99592366` |

### Collection IDs (NutriNine)

| Collection | ID |
|------------|-----|
| dev | `c792c297-8ccd-46a1-b691-7955ede25eb5` |
| qa | `532a3e70-d93b-42d8-8ebb-87ab0706786c` |
| prod | `97a77f38-24f3-4782-90c7-bc37e078e029` |

### Team Member Access

| Member | QUAD Org | NutriNine Org | Access Level |
|--------|----------|---------------|--------------|
| sumanaddanki | ✅ Owner | ✅ Owner | All collections (dev/qa/prod) |
| sharuuu | ✅ Member | ✅ Member | dev/qa only (no prod access) |

---

## Database Setup

**QUAD has its own PostgreSQL database, separate from NutriNine:**

| Database | Purpose | Port | Container |
|----------|---------|------|-----------|
| `quad_dev_db` | QUAD DEV | 14201 | postgres-quad-dev |
| `quad_qa_db` | QUAD QA | 15201 | postgres-quad-qa |
| `nutrinine_dev_db` | NutriNine DEV | 16201 | postgres-dev |
| `nutrinine_qa_db` | NutriNine QA | 17201 | postgres-qa |

**Connection String (.env):**
```bash
# DEV (Java backend uses JPA, not Prisma)
DATABASE_URL="postgresql://quad_user:quad_dev_pass@localhost:14201/quad_dev_db?schema=public"

# QA
DATABASE_URL="postgresql://quad_user:quad_qa_pass@localhost:15201/quad_qa_db?schema=public"
```

**Architecture (Migrated Jan 2026):**
- **Schema:** Raw SQL files in `quad-database/sql/` (source of truth)
- **Backend:** Java Spring Boot + JPA (quad-services/)
- **Frontend:** Next.js calls Java backend via HTTP (java-backend.ts)
- **Migration Complete:** All auth logic migrated to Java backend (Jan 2026)

**Database Commands:**
```bash
# View schema SQL files
ls quad-database/sql/tables/

# Deploy schema to database
cd quad-database && ./deployment/dev/dev-deploy.sh

# Check sync status
cd quad-database && ./sync/sync-db.sh dev
```

**Schema Tables (15 tables with QUAD_ prefix):**
- `QUAD_companies` - Company/organization accounts
- `QUAD_roles` - Role definitions with QUAD participation levels
- `QUAD_users` - User accounts with role assignments
- `QUAD_adoption_matrix` - Skill/Trust levels per user
- `QUAD_domains` - Product/project domains
- `QUAD_domain_members` - User assignments to domains
- `QUAD_circles` - 4 Circles within each domain
- `QUAD_circle_members` - User assignments to circles
- `QUAD_flows` - Work items progressing through Q-U-A-D stages
- `QUAD_flow_stage_history` - Stage transition audit trail
- `QUAD_domain_resources` - Git repos, databases, cloud projects
- `QUAD_resource_attributes` - Key-value attributes for resources
- `QUAD_work_sessions` - Time tracking sessions
- `QUAD_domain_blueprints` - UI blueprints for projects
- `QUAD_blueprint_agent_sessions` - AI interview sessions

---

## Test Data (Seed Files)

**Journey 1: HealthTrack Startup** (`quad-database/sql/seeds/journey1_healthtrack.sql`)

A complete test scenario for a 4-person startup building a mobile health app.

| Entity | Count | Description |
|--------|-------|-------------|
| Company | 1 | HealthTrack Startup |
| Roles | 7 | 6 default + 1 custom (MOBILE_LEAD) |
| Users | 4 | Founder, iOS dev, Android dev, Full-stack |
| Circles | 4 | Management, Development, QA, Infrastructure |
| Resources | 5 | 3 git repos, 1 database, 1 cloud project |
| Flows | 5 | At different Q-U-A-D stages |

**Test Credentials:**
```
founder@healthtrack.io / Test123!@#  (ADMIN)
ios@healthtrack.io / Test123!@#      (DEVELOPER)
android@healthtrack.io / Test123!@#  (DEVELOPER)
fullstack@healthtrack.io / Test123!@# (SENIOR_DEVELOPER)
```

**Run Seed:**
```bash
docker cp quad-database/sql/seeds/journey1_healthtrack.sql postgres-quad-dev:/tmp/
docker exec postgres-quad-dev psql -U quad_user -d quad_dev_db -f /tmp/journey1_healthtrack.sql
```

**More test journeys:** See `documentation/TEST_JOURNEYS.md` for 6 complete scenarios (Startup, Small Business, Enterprise).

---

## Authentication (NextAuth)

**Providers:**
- Credentials (email/password with bcrypt)
- OAuth 2.0 (Google, GitHub, Azure AD, Okta, Auth0)

**Session Strategy:** JWT tokens stored in cookies

**OAuth Flow:** See [OAuth Implementation Guide](documentation/OAUTH_IMPLEMENTATION.md)

**Key Files:**
- `src/lib/authOptions.ts` - NextAuth config, OAuth providers, callbacks
- `src/app/api/auth/[...nextauth]/route.ts` - NextAuth endpoints
- `src/app/api/auth/complete-oauth-signup/route.ts` - Complete OAuth signup
- `src/lib/java-backend.ts` - getUserByEmail() for account linking
- `src/types/next-auth.d.ts` - TypeScript session extensions

**Session includes:**
- `user.id` - User UUID
- `user.email` - User email
- `user.role` - Role code (ADMIN, DEVELOPER, etc.)
- `user.companyId` - Company UUID
- `user.domainId` - Current domain UUID (if selected)
- `accessToken` - JWT for API calls

**Protected API Routes:**
```typescript
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/authOptions";

export async function GET() {
  const session = await getServerSession(authOptions);
  if (!session) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  // ... use session.user.companyId, etc.
}
```

---

## Deployment

**Deploy Script:** `./deploy-studio.sh`

```bash
# Deploy to DEV
./deploy-studio.sh dev

# Deploy to QA
./deploy-studio.sh qa

# Deploy to both
./deploy-studio.sh all
```

**QUAD Framework Ports (Mac Studio DEV/QA):**

| Environment | Service | Container Name | Port | URL |
|-------------|---------|----------------|------|-----|
| DEV | Web | quad-web-dev | 14001 | https://dev.quadframe.work |
| DEV | Java API (internal) | quad-services-dev | 14101 (8080) | http://quad-services-dev:8080 (Docker network only) |
| DEV | Database | postgres-quad-dev | 14201 | localhost:14201 |
| DEV | **API Gateway (external)** | quad-api-dev | 14301 | https://dev-api.quadframe.work |
| QA | Web | quad-web-qa | 15001 | https://qa.quadframe.work |
| QA | Java API (internal) | quad-services-qa | 15101 (8080) | http://quad-services-qa:8080 (Docker network only) |
| QA | Database | postgres-quad-qa | 15201 | localhost:15201 |
| QA | **API Gateway (external)** | quad-api-qa | 15301 | https://qa-api.quadframe.work |

**Port Allocation:**
- QUAD DEV: 14xxx range (14001 web, 14101 java, 14201 db, **14301 api-gateway**)
- QUAD QA: 15xxx range (15001 web, 15101 java, 15201 db, **15301 api-gateway**)

**Shared Services (used by QUAD):**
- Vaultwarden: Port 10000 (shared by all projects)
- Caddy Reverse Proxy: Ports 80/443 (shared by all projects)

**Docker Networks:** `dev-network` and `qa-network`

**Infrastructure Verification Scripts:**
- **Caddy Network Fixer:** `/Users/semostudio/scripts/ensure-caddy-networks.sh`
  - Automatically runs after every deployment (dev/qa/all)
  - Ensures Caddy is connected to dev-network and qa-network
  - Creates networks if they don't exist
  - Prevents 502 errors due to network misconfiguration

- **Comprehensive Verifier:** `/Users/semostudio/scripts/verify-all-dns-and-networks.sh`
  - Checks all DNS records (QUAD, A2Vibe, NutriNine for dev/qa)
  - Verifies container network connectivity
  - Tests HTTPS accessibility for all domains
  - Auto-fixes Caddy network issues if found
  - Run manually anytime: `/Users/semostudio/scripts/verify-all-dns-and-networks.sh`

**Related Documentation:**
- Master Infrastructure Port Scheme: `/Users/semostudio/scripts/INFRASTRUCTURE_PORTS.md`
- NutriNine Ports: `/Users/semostudio/git/a2vibecreators/nutrinine/CLAUDE.md`
- A2Vibe Ports: `/Users/semostudio/git/a2vibecreators/a2vibecreators-web/CLAUDE.md`

**Caddy Configuration:** `/Users/semostudio/docker/caddy/Caddyfile`
```
# QUAD Web
dev.quadframe.work {
    reverse_proxy quad-web-dev:3000
}
qa.quadframe.work {
    reverse_proxy quad-web-qa:3000
}

# QUAD API Gateway (External)
dev-api.quadframe.work {
    reverse_proxy quad-api-dev:3100
}
qa-api.quadframe.work {
    reverse_proxy quad-api-qa:3100
}
```

---

## GCP Cloud Infrastructure

**Project:** `nutrinine-prod` (Display Name: "A2Vibe Creators")
**Account:** madhuri.recherla@gmail.com
**Region:** us-east1
**Budget:** $300 free tier credits (valid ~2 months)

### Current Production Services (Jan 4, 2026)

**Cloud Run Services (4 active):**
```
├── a2vibecreators-web      → https://a2vibecreators-web-605414080358.us-east1.run.app
├── nutrinine-api           → https://nutrinine-api-605414080358.us-east1.run.app
├── nutrinine-web           → https://nutrinine-web-605414080358.us-east1.run.app
└── quadframework-prod      → https://quadframework-prod-605414080358.us-east1.run.app
```

**Cloud SQL (1 instance):**
```
└── nutrinine-db (PostgreSQL 15, f1-micro) → 34.148.105.158
```

**Cloud Storage:**
```
└── nutrinine-health-reports (us-east1)
```

### Recent Cleanup (Jan 4, 2026)

**Deleted Services:**
- ❌ `nutrinine-voice` - Not deployed to PROD (using Sarvam AI instead)
- ❌ `a2vibecreators-web-dev` - Runs on Mac Studio only
- ❌ `a2vibecreators-web-qa` - Runs on Mac Studio only

**Rationale:** DEV/QA run on Mac Studio Docker, only PROD deploys to GCP Cloud Run.

### Future: PROD Deployment Plan (On Hold)

**After DEV/QA are stable, deploy to PROD:**

1. **Create separate QUAD database:**
   ```bash
   gcloud sql instances create quad-prod-db \
     --database-version=POSTGRES_15 \
     --tier=db-f1-micro \
     --region=us-east1
   ```

2. **Split QUAD into microservices (3 services):**
   ```
   Current:
   └── quadframework-prod (Next.js monolith)

   Future:
   ├── quadframework-web      (Next.js frontend)
   ├── quadframework-api      (Next.js API routes)
   └── quadframework-services (Java Spring Boot backend)
   ```

3. **Update deployment scripts** in `/deployment/prod/`

**Status:** Documented for future implementation. Focus on DEV/QA first.

---

## Development Commands

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Build Java backend
cd quad-services && mvn clean package

# Run Java backend (applies JPA schema)
java -jar target/quad-services-*.jar

# View database (use any PostgreSQL client)
psql -h localhost -p 14201 -U quad_user -d quad_dev_db
```

---

## Key Design Decisions

1. **Methodology Lens in Nav** - Global dropdown so users set their background once and see it across all pages

2. **Context for Persistence** - `MethodologyContext` uses localStorage to persist selection

3. **Flow-Based Navigation** - Pages grouped by purpose (learn → try → resources) with clear progression

4. **No External Dependencies** - Pure CSS animations, no heavy libraries

5. **Mobile First** - All components designed for mobile with desktop enhancements

---

## Multi-Provider AI Integration

**QUAD uses two AI providers for cost optimization and reliability:**

| Provider | Use Case | Status | Location |
|----------|----------|--------|----------|
| **Anthropic Claude** | Primary (coding, complex reasoning) | ⏳ Configured in vault | Vaultwarden (QUAD org → dev) |
| **Google Gemini** | Secondary (simple tasks, cost optimization) | ✅ Configured | Shared with NutriNine |

### Provider Configuration

**1. Anthropic Claude (Primary)**
- **API Key:** Stored in Vaultwarden (QUAD org → dev → "Anthropic API Key")
- **Console:** https://console.anthropic.com/settings/usage
- **Account:** madhuri.recherla@gmail.com
- **Environment Variable:** `ANTHROPIC_API_KEY`
- **Status:** Configured in vault, needs to be added to .env.local

**2. Google Gemini (Secondary - Cost Optimization)**
- **API Key:** `AIzaSyBA27fTF2AyRISvz0LAJTX9mCL8B2PJxBY`
- **Google Cloud Project:** "NutriNine" (gen-lang-client-0961567683)
- **Environment Variable:** `GEMINI_API_KEY`
- **Status:** ✅ Configured in .env.local and deployed
- **Note:** Shared with NutriNine project for cost efficiency

**Why Multi-Provider?**
- **Cost:** Gemini is 10x cheaper for simple tasks
- **Reliability:** Fallback if one provider is down
- **Smart Routing:** Route tasks to the best model for the job

### Token Optimization Strategy

QUAD uses 4 optimization strategies to minimize Claude API costs:

| Strategy | Savings | Implementation |
|----------|---------|----------------|
| **Prompt Caching** | 90% on input | Cache system prompts, org context, codebase summaries |
| **Model Routing** | 30-50% | Haiku for simple, Sonnet for coding, Opus for complex |
| **Batch API** | 50% | "Come Back in 5 Minutes" async processing |
| **Context Compression** | 20-40% | Summarize conversations, compress code context |

**BYOK (Bring Your Own Key) Modes:**
- **Conservative** - Max optimization, ~$15/mo per dev
- **Flexible** - Full power, ~$45/mo per dev

### Client Library Files

| File | Purpose |
|------|---------|
| `src/lib/claude/client.ts` | Main Claude client with caching |
| `src/lib/claude/types.ts` | TypeScript types and interfaces |
| `src/lib/claude/cache.ts` | Cache management utilities |
| `src/lib/claude/router.ts` | Task → Model routing logic |
| `src/lib/claude/usage.ts` | Token usage tracking |
| `src/lib/claude/batch.ts` | Batch API processor ("Come Back in 5 Minutes") |
| `src/lib/claude/index.ts` | Exports all modules |

**Usage Example:**
```typescript
import { getClaudeClient, createBYOKClient } from '@/lib/claude';

// Using QUAD's API key
const client = getClaudeClient();
const response = await client.chat('Hello!');

// Code review (batch-eligible)
const review = await client.codeReview(code, 'Check for security issues');

// Using user's own API key (BYOK)
const byokClient = createBYOKClient({
  apiKey: 'user-api-key',
  mode: 'conservative',
  userId: 'user-123',
  organizationId: 'org-456',
});
```

### AI Documentation (Complete)

| Document | Purpose |
|----------|---------|
| `documentation/TOKEN_OPTIMIZATION_STRATEGY.md` | Core optimization strategies |
| `documentation/MULTI_PROVIDER_AI_STRATEGY.md` | Multi-provider cost comparison |
| `documentation/AI_PRICING_TIERS.md` | User-facing tier options |
| `documentation/AI_PIPELINE_TIERS.md` | NutriNine-style pipeline approach |
| `documentation/QUAD_AI_ACTIVITIES.md` | Complete list of 62 AI activities |

### User AI Tiers

| Tier | Cost/Dev/Mo | Description |
|------|-------------|-------------|
| 🚀 **Turbo** | ~$5 | Cheapest - Groq FREE + DeepSeek |
| ⚡ **Balanced** | ~$15 | Best value - Smart mix of providers |
| 💎 **Quality** | ~$35 | Best results - Claude-first |
| 🔑 **BYOK** | Direct | Bring Your Own Key |

---

## Testing Protocol (IMPORTANT)

**When testing each page, Claude must explain the complete flow step by step:**

1. **Before Testing:**
   - Explain what the page/feature does
   - List all components involved
   - Describe the data flow (frontend → API → database)

2. **During Testing:**
   - Walk through each user interaction
   - Explain what happens at each step
   - Show expected API calls and responses

3. **After Testing:**
   - Summarize what worked/didn't work
   - Document any issues found
   - Suggest improvements if any

**Example Flow Documentation:**
```
Page: /domains (Domain Management)

1. User loads page
   → GET /api/domains (fetch user's domains)
   → Response: [{ id, name, description, ...}]

2. User clicks "Create Domain"
   → Modal opens
   → Form validation client-side

3. User submits form
   → POST /api/domains { name, description, project_type }
   → Server validates, creates in QUAD_domains table
   → Response: { id, name, ... }
   → UI updates list, shows success toast
```

This protocol ensures thorough understanding of each feature before and after testing.

---

## Phase 2 Features (Planned)

Features documented for future implementation:

| Feature | Description | Priority |
|---------|-------------|----------|
| **Discovery Results Persistence** | Save discovery wizard responses to database for logged-in users. Currently client-side only (React useState) - data lost on refresh. Would require: `QUAD_discovery_results` table, API endpoint, frontend integration. | Low |
| **File Upload for Blueprints** | Phase 1 uses URLs only. Phase 2 adds actual file upload to cloud storage. | Medium |
| **Slack/Email Agents** | Auto-implement features from Slack messages or emails. | High |
| **Multi-version Documentation** | Serve archived versions at `/1.0/`, `/2.0/` etc. | Low |

---

## Related Projects

| Project | Path | Description |
|---------|------|-------------|
| **NutriNine** | `/Users/semostudio/git/a2vibecreators/nutrinine` | Family health app (uses same postgres-dev) |
| **A2Vibe Creators** | `/Users/semostudio/git/a2vibecreators/a2vibecreators-web` | Company website |
| **Nanna** | `/Users/semostudio/git/sumanaddanki/nanna` | AI teaching agent (Telugu) |

## Related Documentation

- QUAD Methodology docs: `/nutrinine-docs/documentation/methodology/QUAD.md`
- A2Vibe Creators website: `/a2vibecreators-web/`
- Test Journeys: `documentation/TEST_JOURNEYS.md`
- Blueprint Agent Implementation: `documentation/BLUEPRINT_AGENT_IMPLEMENTATION_PLAN.md`

---

**Author:** Suman Addanki
**Last Updated:** January 2, 2026
