# QUAD Platform - Top 5 Tools by Agent Type

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** Quick reference of industry-standard tools for each QUAD agent

---

## 1. Backend Developer Agent

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Source Control** | GitHub | GitLab | Bitbucket | Azure Repos | Gerrit |
| **Project Management** | Jira | Linear | Azure DevOps | Asana | Monday.com |
| **API Testing** | Postman | Insomnia | Swagger UI | Thunder Client | REST Client |
| **Containerization** | Docker | Kubernetes | Podman | containerd | LXC |
| **Cloud Providers** | AWS | GCP | Azure | DigitalOcean | Heroku |

**QUAD Platform Support:**
- ✅ **Implemented:** GitHub, GitLab, Bitbucket, Jira, Linear, Azure DevOps
- 🔜 **Future:** Postman, Docker, Kubernetes, AWS, GCP, Azure

---

## 2. UI Developer Agent (Base)

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Design** | Figma | Sketch | Adobe XD | Zeplin | InVision |
| **Source Control** | GitHub | GitLab | Bitbucket | Azure Repos | SVN |
| **Project Management** | Jira | Linear | Asana | Trello | ClickUp |
| **Communication** | Slack | Microsoft Teams | Discord | Zoom | Google Chat |
| **Browser DevTools** | Chrome DevTools | Firefox DevTools | Safari DevTools | Edge DevTools | Brave DevTools |

**QUAD Platform Support:**
- ✅ **Implemented:** Figma, GitHub, GitLab, Bitbucket, Jira, Linear, Slack, Teams, Discord
- 🔜 **Future:** Sketch, Adobe XD (if requested)
- ❌ **Not Supported:** Browser DevTools (local tools, no API)

---

## 3. iOS Developer Agent (Extends UI)

### Top 5 Tools by Category (Beyond UI Agent)

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **IDE** | Xcode | AppCode | VS Code | Vim | Sublime Text |
| **Distribution** | TestFlight | App Store Connect | Diawi | InstallOnAir | HockeyApp |
| **Analytics** | Firebase Crashlytics | Sentry | Mixpanel | Amplitude | New Relic |
| **CI/CD** | Fastlane | Xcode Cloud | Bitrise | CircleCI | GitHub Actions |
| **Dependency Mgmt** | Swift Package Manager | CocoaPods | Carthage | Tuist | - |

**Inherits from UI Agent:**
- ✅ Figma, GitHub, Jira, Slack (all implemented)

**iOS-Specific Support:**
- ✅ **Implemented:** None yet (Phase 1 focus on static site)
- 🔜 **Future:** TestFlight, Firebase, Fastlane, Xcode Cloud
- ❌ **Not Supported:** Xcode, VS Code (local IDE, no API)

---

## 4. Android Developer Agent (Extends UI)

### Top 5 Tools by Category (Beyond UI Agent)

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **IDE** | Android Studio | IntelliJ IDEA | VS Code | Eclipse | NetBeans |
| **Distribution** | Google Play Console | Firebase App Distribution | AppCenter | TestFairy | HockeyApp |
| **Analytics** | Firebase Crashlytics | Sentry | Mixpanel | Amplitude | Bugsnag |
| **Build System** | Gradle | Maven | Bazel | Buck | - |
| **CI/CD** | Fastlane | Bitrise | CircleCI | GitHub Actions | GitLab CI |

**Inherits from UI Agent:**
- ✅ Figma, GitHub, Jira, Slack (all implemented)

**Android-Specific Support:**
- ✅ **Implemented:** None yet (Phase 1 focus on static site)
- 🔜 **Future:** Google Play Console, Firebase, Fastlane
- ❌ **Not Supported:** Android Studio, Gradle (local tools)

---

## 5. Web Developer Agent (Extends UI)

### Top 5 Tools by Category (Beyond UI Agent)

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **IDE** | VS Code | WebStorm | Sublime Text | Atom | Brackets |
| **Hosting** | Vercel | Netlify | AWS Amplify | GitHub Pages | Cloudflare Pages |
| **Package Managers** | npm | yarn | pnpm | Bun | - |
| **Testing** | Cypress | Playwright | Selenium | Jest | Vitest |
| **Build Tools** | Vite | Webpack | Rollup | esbuild | Parcel |

**Inherits from UI Agent:**
- ✅ Figma, GitHub, Jira, Slack (all implemented)

**Web-Specific Support:**
- ✅ **Implemented:** None yet (Phase 1 focus on static site)
- 🔜 **Future:** Vercel, Netlify, Cypress, Playwright
- ❌ **Not Supported:** VS Code, npm, yarn (local tools)

---

## 6. Next.js Developer Agent (Extends Web)

### Top 5 Next.js-Specific Tools/Concepts

| Category | Tool/Concept 1 | Tool/Concept 2 | Tool/Concept 3 | Tool/Concept 4 | Tool/Concept 5 |
|----------|----------------|----------------|----------------|----------------|----------------|
| **Hosting** | Vercel | Netlify | Cloudflare Pages | AWS Amplify | Render |
| **Database ORMs** | Prisma | Drizzle | TypeORM | Sequelize | Mongoose |
| **State Management** | Zustand | Redux Toolkit | Jotai | Recoil | Context API |
| **UI Libraries** | shadcn/ui | Tailwind CSS | Material-UI | Chakra UI | Ant Design |
| **Testing** | Playwright | Cypress | Jest | Vitest | Testing Library |

**Inherits from Web → UI:**
- ✅ Figma, GitHub, Jira, Slack, Vercel (implemented/planned)

**Next.js Do's & Don'ts:**
- ✅ Use App Router (not Pages Router)
- ✅ Server Components by default
- ✅ Cache with `revalidate` or `cache: 'force-cache'`
- ❌ Don't use `getServerSideProps` (use Server Components)
- ❌ Don't overuse `'use client'` (only when needed)

---

## 7. React.js Developer Agent (Extends Web)

### Top 5 React.js-Specific Tools/Concepts

| Category | Tool/Concept 1 | Tool/Concept 2 | Tool/Concept 3 | Tool/Concept 4 | Tool/Concept 5 |
|----------|----------------|----------------|----------------|----------------|----------------|
| **State Management** | Redux Toolkit | Zustand | Jotai | Recoil | MobX |
| **Routing** | React Router | TanStack Router | Wouter | Reach Router | - |
| **UI Libraries** | Material-UI | Chakra UI | Ant Design | shadcn/ui | Mantine |
| **Data Fetching** | TanStack Query | SWR | RTK Query | Apollo Client | Axios |
| **Testing** | Jest | Vitest | Testing Library | Cypress | Playwright |

**Inherits from Web → UI:**
- ✅ Figma, GitHub, Jira, Slack (implemented)

**React.js Best Practices:**
- ✅ Use functional components + hooks
- ✅ Use `useState`, `useEffect`, `useContext` correctly
- ✅ Memoize with `useMemo`, `useCallback` when needed
- ❌ Don't use class components (legacy)
- ❌ Don't mutate state directly

---

## 8. QA Engineer Agent

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Bug Tracking** | Jira | Linear | Azure DevOps | GitHub Issues | Bugzilla |
| **Test Automation** | Selenium | Cypress | Playwright | Appium | TestCafe |
| **API Testing** | Postman | Insomnia | REST Assured | SoapUI | Katalon |
| **Cross-Browser** | BrowserStack | Sauce Labs | LambdaTest | CrossBrowserTesting | Selenium Grid |
| **Performance** | JMeter | Gatling | k6 | Locust | Artillery |

**QUAD Platform Support:**
- ✅ **Implemented:** Jira, Linear, Azure DevOps
- 🔜 **Future:** Selenium, Cypress, Playwright, Postman, BrowserStack

---

## 9. Infrastructure Engineer Agent

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Cloud Providers** | AWS | GCP | Azure | DigitalOcean | Linode |
| **IaC** | Terraform | Ansible | CloudFormation | Pulumi | Chef |
| **Orchestration** | Kubernetes | Docker Swarm | Nomad | ECS | Mesos |
| **Monitoring** | PagerDuty | Datadog | New Relic | Grafana | Prometheus |
| **CI/CD** | Jenkins | GitHub Actions | GitLab CI | CircleCI | Travis CI |

**QUAD Platform Support:**
- ✅ **Implemented:** PagerDuty, Datadog, New Relic, Grafana
- 🔜 **Future:** AWS, GCP, Azure, Terraform, Kubernetes, Jenkins, GitHub Actions

---

## 10. Database Engineer Agent (Base)

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **SQL Databases** | PostgreSQL | MySQL | SQL Server | Oracle | MariaDB |
| **NoSQL Databases** | MongoDB | Redis | Cassandra | DynamoDB | CouchDB |
| **Migration Tools** | Flyway | Liquibase | Prisma Migrate | Alembic | TypeORM Migrations |
| **GUI Clients** | DBeaver | pgAdmin | MySQL Workbench | SQL Server Mgmt Studio | DataGrip |
| **Monitoring** | Datadog | New Relic | Grafana | pgBadger | SQL Profiler |

**QUAD Platform Support:**
- ✅ **Implemented:** None yet (drivers auto-installed per project)
- 🔜 **Future:** PostgreSQL agent, MSSQL agent, MySQL agent, MongoDB agent
- ❌ **Not Supported:** GUI clients (local tools, manual installation)

---

## 11. PostgreSQL Agent (Extends Database)

### Top 5 PostgreSQL-Specific Tools

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Extensions** | PostGIS | pg_trgm | uuid-ossp | hstore | pgcrypto |
| **Connection Pooler** | PgBouncer | pgpool-II | Odyssey | - | - |
| **Replication** | Streaming Replication | Logical Replication | Patroni | Slony | Bucardo |
| **Monitoring** | pg_stat_statements | pgBadger | pganalyze | Datadog | Grafana |
| **Backup** | pg_dump | pg_basebackup | WAL-E | pgBackRest | Barman |

**Inherits from Database Agent:**
- ✅ Driver installation, migrations, backups

**PostgreSQL-Specific:**
- 🔜 **Future:** Auto-enable extensions, PgBouncer setup, replication config

---

## 12. SQL Server (MSSQL) Agent (Extends Database)

### Top 5 SQL Server-Specific Tools

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Management** | SSMS | Azure Data Studio | mssql-cli | DBeaver | DataGrip |
| **High Availability** | Always On AG | Failover Clustering | Log Shipping | Database Mirroring | - |
| **Performance** | Query Store | Extended Events | SQL Profiler | Database Tuning Advisor | DMVs |
| **Backup** | SQL Server Backup | Azure Backup | Veeam | Commvault | - |
| **Monitoring** | Datadog | New Relic | SolarWinds | Redgate Monitor | SQL Monitor |

**Inherits from Database Agent:**
- ✅ Driver installation, migrations, backups

**MSSQL-Specific:**
- 🔜 **Future:** Always On setup, Query Store config, Extended Events

---

## 13. Product/Tech Lead Agent (PM + BA + TL Combined)

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Project Management** | Jira | Linear | Azure DevOps | Asana | Monday.com |
| **Documentation** | Confluence | Notion | Google Docs | Coda | Slite |
| **Wireframing** | Figma | Miro | Balsamiq | Lucidchart | Whimsical |
| **Analytics** | Mixpanel | Amplitude | Google Analytics | Heap | Pendo |
| **Communication** | Slack | Microsoft Teams | Zoom | Google Meet | Discord |

**QUAD Platform Support:**
- ✅ **Implemented:** Jira, Linear, Azure DevOps, Figma, Slack, Teams
- 🔜 **Future:** Confluence, Notion, Mixpanel, Amplitude

---

## 14. Solution Architect Agent

### Top 5 Tools by Category

| Category | Tool 1 | Tool 2 | Tool 3 | Tool 4 | Tool 5 |
|----------|--------|--------|--------|--------|--------|
| **Diagramming** | Lucidchart | draw.io | Miro | PlantUML | Excalidraw |
| **Architecture** | C4 Model | ArchiMate | UML | AWS Architecture | Azure Architecture |
| **Documentation** | Confluence | Notion | GitBook | Docusaurus | MkDocs |
| **Design Review** | GitHub | GitLab | Gerrit | Crucible | Upsource |
| **Cloud Platforms** | AWS | GCP | Azure | DigitalOcean | Linode |

**QUAD Platform Support:**
- ✅ **Implemented:** GitHub, GitLab
- 🔜 **Future:** Lucidchart, draw.io, Confluence, AWS, GCP, Azure

---

## Summary: Currently Implemented Tools (Phase 1)

### ✅ Active Integrations (Live in QUAD Platform)

**Source Control:**
- GitHub, GitLab, Bitbucket

**Project Management:**
- Jira, Linear, Azure DevOps

**Communication:**
- Slack, Microsoft Teams, Discord

**Design:**
- Figma

**Monitoring:**
- PagerDuty, Datadog, New Relic, Grafana

**Total:** 14 integrations implemented

---

## Phase 2 Roadmap (Next 3-6 Months)

**CI/CD:**
- GitHub Actions, GitLab CI

**Mobile Distribution:**
- TestFlight, Google Play Console

**Analytics:**
- Firebase (Crashlytics, Analytics)

**Deployment:**
- Vercel, Netlify

**Total:** +6 integrations

---

## Phase 3 Roadmap (6-12 Months)

**Cloud Providers:**
- AWS, GCP, Azure

**Testing:**
- Selenium, Cypress, Playwright, BrowserStack

**Infrastructure:**
- Terraform, Kubernetes, Jenkins

**Documentation:**
- Confluence, Notion

**Total:** +12 integrations

---

## Notes for QUAD_ADMIN

**When configuring agents:**
1. Start with **top 3 tools** in each category (most common)
2. Add tools 4-5 only if your team uses them
3. Fewer tools = simpler onboarding, faster agents
4. More tools = more flexibility, but more configuration

**Example (Recommended Minimal Setup for Startup):**
- Source Control: GitHub only
- Project Management: Jira only
- Communication: Slack only
- Design: Figma only
- Total: 4 integrations (easiest to manage)

**Example (Enterprise Setup):**
- Source Control: GitHub, GitLab, Bitbucket (teams use different tools)
- Project Management: Jira, Linear (different teams prefer different tools)
- Communication: Slack, Teams (Slack for eng, Teams for org)
- Design: Figma
- Monitoring: PagerDuty, Datadog
- Total: 9 integrations (more complex, but covers all teams)

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
