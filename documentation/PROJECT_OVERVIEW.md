# QUAD Platform - Project Overview

**Date:** January 1, 2026
**Version:** 2.0
**Status:** Active Development (60% Backend Complete)

---

## Table of Contents

1. [What is QUAD Platform?](#what-is-quad-platform)
2. [Core Concepts](#core-concepts)
3. [Blueprint Agent](#blueprint-agent)
4. [Technical Architecture](#technical-architecture)
5. [User Roles & Permissions](#user-roles--permissions)
6. [Key Features](#key-features)
7. [Use Cases](#use-cases)
8. [Development Workflow](#development-workflow)
9. [Deployment Environments](#deployment-environments)
10. [Implementation Status](#implementation-status)
11. [Project Roadmap](#project-roadmap)
12. [Success Metrics](#success-metrics)
13. [Deployment Modes](#deployment-modes)
14. [Competitive Landscape](#competitive-landscape)
15. [Getting Started](#getting-started)
16. [Contact & Support](#contact--support)

---

## What is QUAD Platform?

**QUAD** (Quick Agile Unified Development) is an AI-powered platform that helps software development teams streamline their development workflow from concept to deployment.

### The Problem We Solve

Software development teams face these challenges:
- ❌ Scattered tools (Jira, Figma, GitHub, Jenkins)
- ❌ Manual context switching between design, development, and deployment
- ❌ No single source of truth for project status
- ❌ Difficult to track multiple projects across teams
- ❌ Blueprint/design handoff friction between designers and developers

### The QUAD Solution

✅ **Unified Platform** - One place for design, development, deployment, and monitoring
✅ **Blueprint Agent** - AI converts requirements → mockups → code
✅ **Git Integration** - Analyze existing codebases for style matching
✅ **Multi-Domain Management** - Organize projects by business domain (Healthcare, Finance, etc.)
✅ **Resource/Attribute Model** - Flexible configuration without database changes
✅ **Integration Hub** - Connect Jira, GitHub, Jenkins, cloud providers

---

## Core Concepts

### 1. Domains

**Domains** are organizational units (companies, divisions, projects).

```
MassMutual (Root Domain)
├── Insurance Division (Sub-Domain)
│   ├── Life Insurance (Sub-Sub-Domain)
│   └── Claims Processing (Sub-Sub-Domain)
└── Wealth Management (Sub-Domain)
```

**Key Features:**
- Unlimited hierarchy depth (domain → subdomain → sub-subdomain)
- Each domain has members with roles (QUAD_ADMIN, DOMAIN_ADMIN, DEVELOPER, QA)
- Domains contain resources (projects, integrations, blueprints)

### 2. Resources

**Resources** are things you develop or manage within a domain.

**Types:**
- `web_app_project` - Web applications (internal dashboards, external sites)
- `mobile_app_project` - iOS/Android apps
- `api_project` - Backend APIs
- `landing_page_project` - Marketing/landing pages
- `git_repository` - Linked codebases
- `itsm_integration` - Jira, ServiceNow connections
- `blueprint` - Design files (Figma, Sketch, XD)

### 3. Attributes (EAV Pattern)

Each resource has **attributes** stored as key-value pairs (rows, not columns).

**Example: Web App Project Attributes**
```sql
-- Stored as rows in QUAD_resource_attributes table
resource_id | attribute_name          | attribute_value
550e8400... | project_type            | web_internal
550e8400... | frontend_framework      | nextjs
550e8400... | css_framework           | tailwind
550e8400... | blueprint_url           | https://figma.com/...
550e8400... | git_repo_url            | https://github.com/...
550e8400... | backend_framework       | java_spring_boot
```

**Benefits:**
- ✅ Add new attributes without schema changes
- ✅ Different resource types have different attributes
- ✅ No NULL columns for unused attributes

---

## Blueprint Agent

**Blueprint Agent** is the AI-powered design-to-code assistant.

### Workflow

```
Step 1: User provides blueprint
   ├─ Option A: Upload Figma/Sketch URL
   ├─ Option B: Paste competitor website URL
   └─ Option C: AI Interview (10 questions)

Step 2: Optionally link Git repo
   └─ Analyzes tech stack, code patterns, styling

Step 3: AI generates mockups/code
   ├─ Uses Claude 3.5 Sonnet or Gemini
   ├─ Matches existing codebase style (if repo linked)
   └─ Generates reusable components

Step 4: Export to development
   ├─ Figma file (for designers)
   ├─ React/Next.js code (for developers)
   └─ Component library
```

### Blueprint Agent Interview (10 Questions)

1. What type of application? (Web app, mobile, landing page)
2. What is the primary purpose?
3. Who are the target users?
4. What are the key features/screens?
5. Color scheme preference?
6. Existing brand assets?
7. Preferred design style? (Modern, corporate, playful)
8. How many screens? (1-5, 6-15, 16+)
9. Examples of designs you like?
10. Specific requirements/constraints?

**AI Output:**
- Design mockups (Figma-compatible or images)
- Color palette recommendations
- Component library suggestions
- Tech stack recommendations

---

## Technical Architecture

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Next.js 15 (React 19, TypeScript, Tailwind CSS) |
| **Backend** | Next.js API Routes (TypeScript) |
| **Database** | PostgreSQL 15 (15 QUAD_ prefixed tables) |
| **ORM** | Prisma 7 (type-safe queries, migrations) |
| **AI** | Google Gemini (dev), AWS Bedrock (prod) |
| **Deployment** | Docker + Caddy (Mac Studio), GCP Cloud Run (prod) |
| **Git Analysis** | Node.js exec (git clone + file parsing) |
| **Screenshots** | Puppeteer (headless Chrome) |

### Why Next.js Full-Stack?

✅ **Unified Codebase** - Frontend + backend in one project
✅ **API Routes** - No separate backend server needed
✅ **Server-Side Rendering** - Fast initial page loads
✅ **File-Based Routing** - Automatic route generation
✅ **TypeScript** - Type safety across full stack

**vs. Spring Boot (used in NutriNine):**
- QUAD has 15 tables → Next.js + Prisma is ideal
- NutriNine has 346 tables → Needs JPA/Hibernate
- Prisma provides type-safe queries and easy migrations

### Database Schema (15 Tables)

```
QUAD_organizations (root)
├── QUAD_users (organization users)
│   ├── QUAD_user_sessions (JWT sessions)
│   ├── QUAD_adoption_matrix (AI adoption level)
│   ├── QUAD_work_sessions (time tracking)
│   └── QUAD_workload_metrics (productivity)
├── QUAD_roles (with Q-U-A-D stage participation)
└── QUAD_domains (organizational units)
    ├── QUAD_domain_members (user-domain roles)
    ├── QUAD_domain_resources (projects, repos)
    │   └── QUAD_resource_attributes (EAV pattern)
    ├── QUAD_circles (4 team circles)
    │   └── QUAD_circle_members
    └── QUAD_flows (work items)
        └── QUAD_flow_stage_history
```

**Core Tables (8):**
- `QUAD_organizations` - Customer organizations
- `QUAD_users` - User accounts with role_id foreign key (company_id column maps to org_id in Prisma)
- `QUAD_roles` - Roles with Q-U-A-D stage participation (PRIMARY/SUPPORT/REVIEW/INFORM)
- `QUAD_user_sessions` - JWT token sessions
- `QUAD_domains` - Hierarchical workspaces
- `QUAD_domain_members` - User-domain role assignments
- `QUAD_domain_resources` - Resources (projects, repos, blueprints)
- `QUAD_resource_attributes` - Flexible attributes (EAV pattern)

**Feature Tables (7):**
- `QUAD_adoption_matrix` - AI adoption tracking (skill_level, trust_level 1-3)
- `QUAD_flows` - Work items with Q-U-A-D stage tracking
- `QUAD_flow_stage_history` - Stage transition audit log
- `QUAD_circles` - 4 team circles (Management, Development, QA, Infrastructure)
- `QUAD_circle_members` - Circle membership
- `QUAD_work_sessions` - Daily time tracking
- `QUAD_workload_metrics` - Weekly productivity metrics

---

## User Roles & Permissions

### Default Roles (6)

| Role | Code | Hierarchy | Permissions |
|------|------|-----------|-------------|
| **Administrator** | ADMIN | 100 | Full access, manage company, users, billing |
| **Manager** | MANAGER | 80 | Manage users, domains, flows, view metrics |
| **Tech Lead** | TECH_LEAD | 60 | Manage domains, flows, circles, resources |
| **Developer** | DEVELOPER | 40 | Create flows, manage resources |
| **QA Engineer** | QA | 30 | Manage flows, view metrics |
| **Observer** | OBSERVER | 10 | View-only access |

### Q-U-A-D Stage Participation Matrix

Each role has participation levels for each stage of the QUAD workflow:

| Role | Q (Question) | U (Understand) | A (Allocate) | D (Deliver) |
|------|--------------|----------------|--------------|-------------|
| **Administrator** | PRIMARY | REVIEW | PRIMARY | REVIEW |
| **Manager** | PRIMARY | PRIMARY | PRIMARY | REVIEW |
| **Tech Lead** | SUPPORT | PRIMARY | SUPPORT | REVIEW |
| **Developer** | INFORM | SUPPORT | INFORM | PRIMARY |
| **QA** | INFORM | INFORM | INFORM | SUPPORT |
| **Observer** | INFORM | INFORM | INFORM | INFORM |

**Participation Values:**
- **PRIMARY** - Owns and drives the stage
- **SUPPORT** - Actively assists the primary owner
- **REVIEW** - Approves/rejects stage output
- **INFORM** - Receives status updates only

### Multi-Domain Users

- One user can have different roles in different domains
- Example: Alice is ADMIN in MassMutual root, DEVELOPER in Insurance sub-domain
- Roles are auto-created when a new company is registered

---

## Key Features

### 1. Multi-Domain Hierarchy

```
Company: A2Vibe Creators
├── Internal Tools (Domain)
│   ├── QUAD Platform (Resource)
│   └── NutriNine (Resource)
└── Client Projects (Domain)
    ├── MassMutual (Sub-Domain)
    │   ├── Claims Dashboard (Resource)
    │   └── Agent Portal (Resource)
    └── Healthcare Co (Sub-Domain)
```

### 2. Resource/Attribute Model

**Traditional Approach (BAD):**
```sql
ALTER TABLE projects ADD COLUMN new_field VARCHAR(255);
-- Every new feature = database migration
```

**QUAD Approach (GOOD):**
```sql
INSERT INTO QUAD_resource_attributes
  (resource_id, attribute_name, attribute_value)
VALUES
  ('550e8400...', 'new_field', 'value');
-- No schema changes needed!
```

### 3. Blueprint Agent Features

✅ **Auto-Detect Blueprint Type** - Figma, Sketch, XD from URL
✅ **URL Verification** - Checks if design files are accessible
✅ **Competitor Screenshots** - Auto-capture website screenshots
✅ **Git Repo Analysis** - Extract tech stack, components, patterns
✅ **AI Interview** - 10-question flow to gather requirements
✅ **Private Repo Support** - Tokens stored in Vaultwarden

### 4. Integration Hub

**Planned Integrations:**
- **ITSM:** Jira, ServiceNow, Linear
- **Git:** GitHub, GitLab, Bitbucket, Azure DevOps
- **CI/CD:** Jenkins, GitHub Actions, CircleCI
- **Cloud:** AWS, GCP, Azure
- **Design:** Figma, Sketch, Adobe XD

---

## Use Cases

### Use Case 1: Enterprise Dashboard Development

**Company:** MassMutual
**Project:** Claims Processing Dashboard

1. **DOMAIN_ADMIN** creates "Claims Processing" domain
2. Uploads Figma blueprint URL
3. Links existing GitHub repo for style matching
4. QUAD analyzes repo → detects Next.js + Tailwind + Spring Boot
5. Blueprint Agent generates matching components
6. **DEVELOPER** exports code and starts building

### Use Case 2: Startup MVP Development

**Company:** HealthTech Startup
**Project:** Patient Portal MVP

1. **QUAD_ADMIN** creates domain
2. No blueprint yet → starts Blueprint Agent interview
3. Answers 10 questions about requirements
4. AI generates mockups + recommended tech stack
5. Chooses "Next.js + PostgreSQL + Tailwind"
6. Exports code scaffold to start building

### Use Case 3: Multi-Project Portfolio

**Agency:** A2Vibe Creators
**Clients:** 10 different companies

```
A2Vibe Creators (Root)
├── Client: MassMutual
│   ├── Claims Dashboard
│   └── Agent Portal
├── Client: Healthcare Co
│   └── Patient Portal
├── Client: FinTech Startup
│   └── Trading Platform
└── Internal
    ├── QUAD Platform
    └── NutriNine
```

- Each client is a separate domain
- Track all projects in one place
- Role-based access (clients can't see each other)

---

## Development Workflow

```
Developer Flow:

1. Login → Select Domain
2. View Dashboard
   ├─ Active Resources (projects)
   ├─ Recent Activity
   └─ Team Members
3. Create New Resource
   ├─ Choose Type (Web App, Mobile, API)
   ├─ Upload Blueprint (or start AI interview)
   ├─ Link Git Repo (optional)
   └─ Configure Attributes
4. QUAD Platform
   ├─ Analyzes Git repo
   ├─ Verifies blueprint URLs
   ├─ Generates recommendations
   └─ Stores everything as attributes
5. Developer Exports
   ├─ Code scaffold
   ├─ Component library
   └─ Integration configs
```

---

## Deployment Environments

| Environment | URL | Purpose |
|-------------|-----|---------|
| **DEV** | dev.quadframe.work | Development testing |
| **QA** | qa.quadframe.work | Pre-production testing |
| **PROD** | quadframe.work | Production (future) |

**Infrastructure:**
- **Mac Studio M4 Max** (DEV/QA hosting)
- **GCP Cloud Run** (Production - future)
- **Caddy** (Reverse proxy)
- **Docker** (Containerization)

---

## Implementation Status

### Backend API (60% Complete)

| Category | Endpoints | Status |
|----------|-----------|--------|
| **Auth** | register, login, logout | ✅ Complete |
| **Companies** | CRUD | ✅ Complete |
| **Users** | CRUD + password update | ✅ Complete |
| **Roles** | CRUD + Q-U-A-D participation | ✅ Complete |
| **Domains** | CRUD + hierarchy | ✅ Complete |
| **Domain Members** | CRUD | ✅ Complete |
| **Resources** | CRUD + attributes | ✅ Complete |
| **Flows** | CRUD + stage transitions | ✅ Complete |
| **Circles** | CRUD + members | ✅ Complete |
| **Adoption Matrix** | GET/PUT per user | ✅ Complete |
| **Work Sessions** | GET/POST per user | ✅ Complete |
| **Workload Metrics** | GET/POST per user | ✅ Complete |
| **Blueprint Agent** | AI interview | 🔜 Pending |
| **Git Analysis** | Repo parsing | 🔜 Pending |

**Total: 24 API endpoints implemented**

### Database (100% Complete)

- ✅ 15 tables with QUAD_ prefix
- ✅ 4 auto-init functions (roles, adoption matrix, circles, updated_at)
- ✅ Prisma schema synced with all tables
- ✅ Role-stage participation fields (q/u/a/d_participation)

### Frontend (40% Complete)

- ✅ Landing page with concept explanation
- ✅ Domain creation wizard (AI interview style)
- ✅ Login/Register pages
- ✅ Dashboard with domain hierarchy
- ✅ Adoption Matrix page
- 🔜 Blueprint upload UI
- 🔜 Flow board (Kanban style)
- 🔜 Circle management UI

---

## Project Roadmap

### Phase 1 (Current - Jan 2026)
✅ Multi-domain management
✅ Role-stage participation model
✅ Auto-init triggers (company→roles, user→matrix, domain→circles)
✅ Resource/Attribute model (EAV)
✅ Full API for all 15 tables
🔜 Blueprint Agent (AI interview + upload)
🔜 Git repo analysis

### Phase 2 (Q1 2026)
🔜 AI mockup generation
🔜 Integration hub (Jira, GitHub)
🔜 Deployment automation
🔜 Reports system

### Phase 3 (Q2 2026)
🔜 Multi-tenant SaaS (O(1)/O(n)/O(n²) modes)
🔜 Marketplace (templates, components)
🔜 Collaboration features (real-time editing)

---

## Success Metrics

**Target Users:** Software development teams (5-50 developers)

**Key Metrics:**
- Time to create new project: < 10 minutes (vs 2-3 days manual)
- Blueprint → Code: 80% reusable components
- Developer satisfaction: 4.5+/5 stars
- Active projects per company: 10-50

---

## Deployment Modes

QUAD offers three deployment modes using mathematical complexity notation:

| Mode | Name | Target | Who Pays AI |
|------|------|--------|-------------|
| **O(1)** | Seed | Startups (1-10 users) | A2Vibe |
| **O(n)** | Growth | Small Business (10-100 users) | Client (BYOK) |
| **O(n²)** | Scale | Enterprise (100+ users) | Client (On-Premise) |

**See:** [DEPLOYMENT_MODES.md](DEPLOYMENT_MODES.md) for pricing and details.

---

## Competitive Landscape

| Competitor | Focus | QUAD Advantage |
|------------|-------|----------------|
| **Figma** | Design only | We do design → code |
| **GitHub** | Code hosting | We add blueprints + AI |
| **Jira** | Project management | We integrate dev tools |
| **v0.dev** | AI code generation | We add project management |
| **Retool** | Internal tools | We handle all app types |
| **Monday.com** | Workflow | No AI adoption tracking |

**QUAD's Unique Value:**
- AI Adoption Matrix (skill + trust levels)
- Q-U-A-D stage workflow with role participation
- 4 Circles team organization
- Blueprint-to-code pipeline

**No direct competitor offers this combination.**

---

## Getting Started

**For Developers:**
1. Read [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) for table structure
2. Review [TECH_STACK.md](TECH_STACK.md) for technology decisions
3. Check [API_REFERENCE.md](API_REFERENCE.md) for endpoint documentation
4. See [DEPLOYMENT_MODES.md](DEPLOYMENT_MODES.md) for hosting options

**For Business:**
1. Browse [case-studies/](case-studies/) for industry examples
2. Review deployment modes for pricing
3. Schedule demo at calendly.com/a2vibecreators/quad-demo

---

## Contact & Support

**Company:** A2Vibe Creators LLC
**Website:** https://a2vibecreators.com
**Email:** contact@a2vibecreators.com
**GitHub:** https://github.com/a2vibecreators/quadframework

---

**Last Updated:** January 1, 2026
