# QUAD Platform - Project Overview

**Date:** December 31, 2025
**Version:** 1.0
**Status:** Active Development

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
| **Frontend** | Next.js 14 (React, TypeScript, Tailwind CSS) |
| **Backend** | Next.js API Routes (TypeScript) |
| **Database** | PostgreSQL 15 |
| **ORM** | Raw SQL via `pg` library (no ORM) |
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
- QUAD has ~10-15 tables → Next.js direct SQL is fine
- NutriNine has 346 tables → Needs JPA/Hibernate

### Database Schema (Simplified)

```sql
QUAD_companies          -- Top-level organizations
  └─ QUAD_users         -- People with email/password
      └─ QUAD_domain_members  -- User roles per domain

QUAD_domains            -- Organizational units (hierarchical)
  └─ QUAD_domain_resources   -- Projects, integrations, repos
      └─ QUAD_resource_attributes  -- Key-value attributes (EAV)

QUAD_resource_attribute_requirements  -- Validation rules
```

**Key Tables:**
- `QUAD_companies` - Customer organizations
- `QUAD_users` - User accounts
- `QUAD_domains` - Workspaces (can be nested)
- `QUAD_domain_resources` - Resources (projects, repos)
- `QUAD_resource_attributes` - Flexible attributes (EAV pattern)
- `QUAD_resource_attribute_requirements` - Attribute validation rules

---

## User Roles & Permissions

| Role | Permissions |
|------|-------------|
| **QUAD_ADMIN** | Full access to all domains, manage users, billing |
| **DOMAIN_ADMIN** | Manage specific domain, create sub-domains, invite users |
| **SUBDOMAIN_ADMIN** | Manage sub-domain, assign resources |
| **DEVELOPER** | Create/edit resources, run deployments |
| **QA** | View resources, run tests, view reports |
| **VIEWER** | Read-only access |

**Multi-Domain Users:**
- One user can have different roles in different domains
- Example: Alice is QUAD_ADMIN in MassMutual root, DEVELOPER in Insurance sub-domain

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

## Project Goals

### Phase 1 (Current - Dec 2025)
✅ Multi-domain management
✅ Blueprint Agent (upload + AI interview)
✅ Git repo analysis
✅ Resource/Attribute model
🔜 Frontend UI (domain wizard, blueprint upload)

### Phase 2 (Q1 2026)
🔜 AI mockup generation
🔜 Integration hub (Jira, GitHub)
🔜 Deployment automation
🔜 Reports system

### Phase 3 (Q2 2026)
🔜 Multi-tenant SaaS
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

## Competitive Landscape

| Competitor | Focus | QUAD Advantage |
|------------|-------|----------------|
| **Figma** | Design only | We do design → code |
| **GitHub** | Code hosting | We add blueprints + AI |
| **Jira** | Project management | We integrate dev tools |
| **v0.dev** | AI code generation | We add project management |
| **Retool** | Internal tools | We handle all app types |

**QUAD = Design + Development + Deployment in ONE platform**

---

## Getting Started

**For Developers:**
1. Read [GETTING_STARTED.md](GETTING_STARTED.md)
2. Set up local environment
3. Review [ARCHITECTURE.md](ARCHITECTURE.md)
4. Check [API_OVERVIEW.md](API_OVERVIEW.md)

**For Contributors:**
1. Read [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
2. Follow coding standards
3. Submit pull requests

---

## Contact & Support

**Company:** A2Vibe Creators LLC
**Website:** https://a2vibecreators.com
**Email:** contact@a2vibecreators.com
**GitHub:** https://github.com/a2vibecreators/quadframework

---

**Next:** Read [ARCHITECTURE.md](ARCHITECTURE.md) for technical deep dive.
