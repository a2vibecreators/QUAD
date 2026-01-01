# QUAD Platform - Agent Rules

**Purpose:** Guidelines for Claude Code when working on QUAD Platform
**Last Updated:** December 31, 2025

---

## Core Rules

### 1. Session Management

**7-Day Active Context Window:**
- Keep detailed context for last 7 days of work
- After 7 days, compress conversation into "Problem → Solution" format
- Archive compressed sessions in `.claudeagent/archive/`

**Compression Format:**
```markdown
## [Date] - [Feature Name]

**Problem:** What we needed to build
**Solution:** What was built (outcome only, not how)
**Code:** Key files created/modified
**Next:** What comes next
```

**Example (Compressed):**
```markdown
## December 31, 2025 - OAuth SSO

**Problem:** Need enterprise SSO authentication (Okta, Azure AD, Google, etc.)
**Solution:** Implemented NextAuth.js with 6 SSO providers. Free tier enforces 5 user limit.
**Code:** `src/app/api/auth/[...nextauth]/route.ts`, `QUAD_users` table updated with `oauth_provider` column
**Next:** Build auth pages (signup/login UI)
```

**Don't keep:**
- ❌ Back-and-forth discussion ("what if we use X?" "no, Y is better")
- ❌ Debugging steps ("tried A, failed, tried B, worked")
- ❌ Alternative approaches that weren't chosen

**Do keep:**
- ✅ Final architectural decision
- ✅ Why we chose it
- ✅ What was built
- ✅ Where code lives

### 2. Always Check Context First

Before starting work, read:
```
1. .claudeagent/SESSION_HISTORY.md
2. .claudeagent/AGENT_CONTEXT_FILES.md
3. Current TodoWrite list
```

### 3. Update Session History After Major Milestones

**When to update:**
- ✅ Feature complete (OAuth SSO, Dashboard, etc.)
- ✅ Architectural decision made (self-hosted, polling, etc.)
- ✅ Sprint/milestone complete

**Don't update for:**
- ❌ Small bug fixes
- ❌ Minor documentation changes
- ❌ Work in progress

### 4. Use TodoWrite for Multi-Step Tasks

Always use TodoWrite when:
- Task has 3+ steps
- Multiple files affected
- Takes > 30 minutes

**Update status immediately:**
- Mark "in_progress" when starting
- Mark "completed" immediately after finishing (don't batch)

### 5. Database Tables Use QUAD_ Prefix

**Location:** `/Users/semostudio/git/a2vibecreators/nutrinine/nutrinine-database/sql/tables/quad_platform/`

**Tables:**
- `QUAD_companies`
- `QUAD_users`
- `QUAD_company_integrations`
- `QUAD_agent_downloads`
- `QUAD_sessions`
- `QUAD_login_codes`

**Important:** QUAD_ tables share database with NutriNine, but **NO foreign keys** between them.

### 6. Follow Architecture Decisions

**Deployment:** Self-hosted (customer's cloud), not SaaS
**Auth:** OAuth SSO only (Okta, Azure AD, Google, GitHub, Auth0, OIDC)
**Data Sync:** Polling (30s interval), not webhooks
**Pricing:** Free (5 users), Pro ($99/month), Enterprise ($499/month)

### 7. Agent Role Philosophy: Combined by Default, Flexible for Enterprises

**QUAD Platform's Ideology:**

**Default (Recommended for Startups/Small Teams):**
- ✅ Combined PM/BA/TL Agent - One agent handles Product Manager + Business Analyst + Tech Lead responsibilities
- **Why:** Startups often have one person wearing multiple hats (PM/BA/TL combined)
- **Agent:** `agent-product-tech-lead.md`

**Flexible (Available for Enterprise Clients):**
- 🔧 Separate PM, BA, TL Agents - If client explicitly requests separation
- **Why:** Large enterprises may have dedicated roles for each
- **Agents:** `agent-product-manager.md`, `agent-business-analyst.md`, `agent-tech-lead.md`
- **When to offer:** Only when client asks ("Do you have separate PM and TL agents?")

**Default Agent Roles (Static Site - quadframe.work):**
| Agent | Role | Targets |
|-------|------|---------|
| `agent-product-tech-lead` | PM + BA + TL (combined) | Startups, small teams |
| `agent-developer` | Backend developer | Circle 1 backend development |
| `agent-qa` | QA engineer | Circle 2 testing |
| `agent-infrastructure` | DevOps/SRE | Circle 3 infrastructure |
| `agent-solution-architect` | Solution architect | Enabling team |

**Agent Hierarchy (Inheritance):**

```
agent-base.md (session mgmt, tool config)
  ├── agent-ui.md (Figma, GitHub, Jira, Slack)
  │   ├── agent-ios.md (TestFlight, Xcode, SwiftUI)
  │   ├── agent-android.md (Play Console, Android Studio, Jetpack Compose)
  │   └── agent-web.md (Vercel, npm, Browser DevTools)
  │       ├── agent-nextjs.md (App Router, SSR/SSG, Server Components)
  │       ├── agent-reactjs.md (Hooks, Context, State Management)
  │       ├── agent-vuejs.md (Composition API, Pinia, Vite) [Future]
  │       └── agent-angular.md (Modules, Services, RxJS) [Future]
  │
  ├── agent-database.md (Drivers, Migrations, Backups)
  │   ├── agent-postgresql.md (pg_stat_statements, PgBouncer, Replication)
  │   ├── agent-mssql.md (Query Store, Always On, SSMS)
  │   ├── agent-mysql.md (InnoDB, Replication, Partitioning) [Future]
  │   ├── agent-mongodb.md (Sharding, Replica Sets, Aggregation) [Future]
  │   └── agent-redis.md (Cache strategies, Pub/Sub, Persistence) [Future]
  │
  ├── agent-developer.md (Backend, APIs, Microservices)
  ├── agent-qa.md (Selenium, API testing, Bug tracking)
  ├── agent-infrastructure.md (Docker, Kubernetes, CI/CD)
  └── agent-product-tech-lead.md (PM + BA + TL combined)
```

**Framework-Specific Agents (Web):**
- `agent-nextjs.md` - Next.js do's and don'ts (App Router, SSR vs SSG vs ISR, server components, caching)
- `agent-reactjs.md` - React.js best practices (hooks, state management, performance optimization)
- `agent-vuejs.md` - Vue.js patterns (Composition API, Pinia, reactivity) [Future]
- `agent-angular.md` - Angular best practices (modules, dependency injection, RxJS) [Future]

**Enterprise Customization (Self-Hosted - QUAD Platform):**
If enterprise client requests:
- "We need separate PM and TL agents" → Create `agent-product-manager.md` and `agent-tech-lead.md`
- "We need a dedicated BA" → Create `agent-business-analyst.md`
- "We need mobile + backend on same agent" → Create custom `agent-fullstack-mobile.md`

**Rule:** Don't proactively offer separate agents. Default to combined PM/BA/TL. Only discuss separation if client asks.

**Example Conversation:**
```
Client: "Do you have separate agents for Product Manager and Tech Lead?"
You: "Yes! We default to a combined PM/BA/TL agent for startups, but we can provide
separate agents for enterprises. Would you like us to split these into:
- agent-product-manager (roadmap, requirements, stakeholder management)
- agent-business-analyst (requirements gathering, user stories)
- agent-tech-lead (technical decisions, architecture, code reviews)?"
```

### 7. Documentation Structure

Follow NutriNine pattern:
```
documentation/
├── architecture/
├── deployment/
├── integration/
└── testing/
```

### 8. Ask Before Production Deployment

**Never deploy to production without explicit user approval.**

DEV deployment: ✅ Can do freely
QA/Production: ⚠️ Ask first

### 9. Git Commit Messages

Use conventional commits:
```
feat: Add OAuth SSO with 6 providers
fix: Correct free tier user limit check
docs: Add SSO setup guide
chore: Update .env.example with SSO vars
```

### 10. Code Style

- TypeScript strict mode
- ESLint rules from Next.js
- Tailwind CSS for styling
- Components use shadcn/ui when possible

---

## Project-Specific Context

**Two Products:**
1. **quadframe.work** - Static website (free forever)
2. **QUAD Platform** - Self-hosted Docker product (free tier + paid)

**Shared Database:**
- NutriNine tables (no prefix) - Family health app
- QUAD_ tables (QUAD_ prefix) - QUAD Platform
- Same PostgreSQL instance, zero connection between them

**Target Market:**
- Mid-size companies (50-200 developers)
- Enterprises (200+ developers)
- Teams using Jira, GitHub, Slack

---

## When Context is Lost

If conversation compacts or user switches projects:

**User types:** `/quadframework-init`

**You should:**
1. Read `.claudeagent/SESSION_HISTORY.md`
2. Read `.claudeagent/AGENT_RULES.md` (this file)
3. Read `.claudeagent/AGENT_CONTEXT_FILES.md`
4. Summarize current state
5. Ask: "Ready to continue? What should I work on next?"

---

**Last Updated:** December 31, 2025
**Maintained By:** Claude Code + Suman Addanke
