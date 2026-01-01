# QUAD Agent Integration Mapping

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** Define which integrations each role uses and their priority

---

## Integration Priority Matrix

This matrix shows which integrations are available for each role and their priority level.

**Priority Levels:**
- 🔴 **PRIMARY** - Core integration, role can't function without it
- 🟡 **SECONDARY** - Important but optional, enhances workflow
- 🟢 **TERTIARY** - Nice-to-have, provides additional context
- ⚪ **NOT APPLICABLE** - Role doesn't use this integration

---

## Developer Role (Circle 1: Development)

| Integration | Priority | Purpose | Configuration Required |
|------------|----------|---------|----------------------|
| **Jira** | 🔴 PRIMARY | Receive user stories and tasks | API token, Project key |
| **GitHub** | 🔴 PRIMARY | Code delivery via PRs, CI/CD status | Personal access token, Webhook |
| **Bitbucket** | 🔴 PRIMARY (alt) | Alternative to GitHub | App password |
| **GitLab** | 🔴 PRIMARY (alt) | Alternative to GitHub | Personal access token |
| **Slack** | 🟡 SECONDARY | Team communication, blockers | App token, Webhook URL |
| **MS Teams** | 🟡 SECONDARY (alt) | Alternative to Slack | Webhook URL |
| **Figma** | 🟢 TERTIARY | Reference designs during implementation | Access token (read-only) |
| **Email** | 🟢 TERTIARY | Urgent requirement notifications | IMAP credentials |
| **Linear** | 🔴 PRIMARY (alt) | Alternative to Jira | API key |
| **Azure DevOps** | 🔴 PRIMARY (alt) | Alternative to GitHub + Jira combined | PAT (Personal Access Token) |

**Recommended Minimal Setup:**
- Jira (or Linear) + GitHub (or Bitbucket) = Developer can work
- Add Slack for team collaboration

**Typical Configuration:**
- Jira + GitHub + Slack
- Linear + GitHub + Slack (startup)
- Azure DevOps (enterprise, all-in-one)

---

## QA Engineer Role (Circle 2: QA)

| Integration | Priority | Purpose | Configuration Required |
|------------|----------|---------|----------------------|
| **Jira** | 🔴 PRIMARY | Test planning, bug reporting | API token, Project key |
| **GitHub** | 🟡 SECONDARY | Test automation code, PR validation | Personal access token |
| **Slack** | 🔴 PRIMARY | Bug reports, QA status updates | App token, Webhook URL |
| **Azure Test Plans** | 🟡 SECONDARY | Enterprise test management | Azure DevOps PAT |
| **TestRail** | 🟡 SECONDARY | Dedicated test management | API key |
| **Figma** | 🟢 TERTIARY | Validate UI matches designs | Access token (read-only) |
| **Linear** | 🔴 PRIMARY (alt) | Alternative to Jira | API key |

**Recommended Minimal Setup:**
- Jira + Slack = QA can report bugs and track testing
- Add GitHub if QA writes automated tests

**Typical Configuration:**
- Jira + Slack + GitHub
- Linear + Slack (startup)
- Azure DevOps + MS Teams (enterprise)

---

## Solution Architect Role (Enabling Team: Architecture)

| Integration | Priority | Purpose | Configuration Required |
|------------|----------|---------|----------------------|
| **Figma** | 🔴 PRIMARY | Analyze designs, suggest architecture | Access token (read-only) |
| **Jira** | 🟡 SECONDARY | Create architecture epics/tasks | API token |
| **Slack** | 🟡 SECONDARY | Architecture discussions | App token |
| **GitHub** | 🟢 TERTIARY | Review architecture-impacting PRs | Personal access token (read-only) |
| **Confluence** | 🟢 TERTIARY | Write architecture docs | API token |

**Recommended Minimal Setup:**
- Figma only = Architect can analyze designs
- Add Jira to create implementation tasks

**Typical Configuration:**
- Figma + Jira + Slack
- Figma + Confluence + Jira (docs-heavy teams)

**⚠️ Important:** Solution Architect is **read-only** for most integrations. They analyze and guide, they don't implement.

---

## Infrastructure Engineer Role (Circle 3: Infrastructure)

| Integration | Priority | Purpose | Configuration Required |
|------------|----------|---------|----------------------|
| **GitHub** | 🔴 PRIMARY | CI/CD triggers, deployment automation | Personal access token, Webhook |
| **GitLab** | 🔴 PRIMARY (alt) | Alternative to GitHub | Personal access token |
| **Slack** | 🔴 PRIMARY | Incident alerts, deployment notifications | App token, Webhook URL |
| **PagerDuty** | 🔴 PRIMARY | On-call alerting for incidents | API key, Service ID |
| **Datadog** | 🟡 SECONDARY | Monitoring, metrics, anomaly detection | API key, App key |
| **New Relic** | 🟡 SECONDARY (alt) | Alternative to Datadog | API key |
| **AWS CloudWatch** | 🟡 SECONDARY | AWS-native monitoring | AWS credentials |
| **Jira** | 🟢 TERTIARY | Infrastructure task tracking | API token |
| **MS Teams** | 🔴 PRIMARY (alt) | Alternative to Slack | Webhook URL |
| **Grafana** | 🟡 SECONDARY | Custom dashboards | API key |

**Recommended Minimal Setup:**
- GitHub + Slack + PagerDuty = Infra can deploy and respond to incidents
- Add Datadog for proactive monitoring

**Typical Configuration:**
- GitHub + Slack + PagerDuty + Datadog
- GitLab + MS Teams + PagerDuty + New Relic (enterprise)

---

## Tech Lead Role (Circle 1: Development - Leadership)

| Integration | Priority | Purpose | Configuration Required |
|------------|----------|---------|----------------------|
| **Jira** | 🔴 PRIMARY | Sprint planning, team task assignment | API token, Admin access |
| **GitHub** | 🔴 PRIMARY | Code review, merge approvals | Personal access token |
| **Slack** | 🔴 PRIMARY | Team coordination, blockers | App token, Admin permissions |
| **Figma** | 🟡 SECONDARY | Review designs with team | Access token (read-only) |
| **Linear** | 🔴 PRIMARY (alt) | Alternative to Jira | API key, Admin |

**Recommended Minimal Setup:**
- Jira + GitHub + Slack = Tech Lead can manage team

**Typical Configuration:**
- Jira + GitHub + Slack + Figma
- Linear + GitHub + Slack (startup)

---

## Product Manager Role (Circle 0: Management)

| Integration | Priority | Purpose | Configuration Required |
|------------|----------|---------|----------------------|
| **Jira** | 🔴 PRIMARY | Create epics, prioritize backlog | API token, Admin access |
| **Figma** | 🟡 SECONDARY | Collaborate with designers | Access token |
| **Slack** | 🔴 PRIMARY | Stakeholder communication | App token |
| **Email** | 🟡 SECONDARY | External stakeholder requirements | IMAP credentials |
| **Linear** | 🔴 PRIMARY (alt) | Alternative to Jira | API key, Admin |

**Recommended Minimal Setup:**
- Jira + Slack = PM can manage product

---

## Integration Category Breakdown

### Project Management (Pick ONE)

| Tool | Best For | Agent Support |
|------|----------|---------------|
| **Jira** | Enterprise, complex workflows | ✅ Full support (all roles) |
| **Linear** | Startups, fast-moving teams | ✅ Full support (all roles) |
| **Azure DevOps** | Microsoft shops, all-in-one | ✅ Full support (Dev, QA, Infra) |

### Source Control (Pick ONE)

| Tool | Best For | Agent Support |
|------|----------|---------------|
| **GitHub** | Most popular, best ecosystem | ✅ Full support (all roles) |
| **GitLab** | Self-hosted, built-in CI/CD | ✅ Full support (all roles) |
| **Bitbucket** | Atlassian stack (Jira integration) | ✅ Full support (Dev, QA) |

### Communication (Pick ONE)

| Tool | Best For | Agent Support |
|------|----------|---------------|
| **Slack** | Most integrations, best UX | ✅ Full support (all roles) |
| **MS Teams** | Microsoft 365 orgs | ✅ Full support (all roles) |
| **Discord** | Startups, gaming companies | 🔜 Planned |

### Design (Optional)

| Tool | Best For | Agent Support |
|------|----------|---------------|
| **Figma** | Web/mobile app design | ✅ Full support (Architect, Dev) |
| **Adobe XD** | Adobe Creative Cloud users | 🔜 Planned |

### Monitoring (Infrastructure - Pick ONE)

| Tool | Best For | Agent Support |
|------|----------|---------------|
| **Datadog** | Comprehensive, multi-cloud | ✅ Full support |
| **New Relic** | Application performance | ✅ Full support |
| **AWS CloudWatch** | AWS-native | ✅ Full support |
| **Grafana** | Self-hosted, customizable | ✅ Full support |

### Incident Management (Infrastructure - Pick ONE)

| Tool | Best For | Agent Support |
|------|----------|---------------|
| **PagerDuty** | Enterprise on-call management | ✅ Full support |
| **Opsgenie** | Atlassian stack | 🔜 Planned |
| **VictorOps** | Splunk users | 🔜 Planned |

---

## Integration Configuration by Team Size

### Startup (1-10 people)

**Minimal Stack:**
- Linear (Project Management)
- GitHub (Source Control)
- Slack (Communication)

**Agent Setup:**
- All roles share same Linear workspace
- GitHub org with 1 repo
- Single Slack workspace (#engineering channel)

**Cost:** ~$50/month ($10 Linear + $20 GitHub + $0 Slack Free + $20 agent hosting)

---

### Small Team (10-50 people)

**Recommended Stack:**
- Jira (Project Management) - $7/user/month
- GitHub (Source Control) - $4/user/month
- Slack (Communication) - $8/user/month
- Figma (Design) - $12/user/month (designers only)

**Agent Setup:**
- Separate Jira projects per team/product
- GitHub org with multiple repos
- Slack workspace with team channels

**Cost:** ~$900/month (30 people × $30/user avg)

---

### Medium Company (50-200 people)

**Recommended Stack:**
- Jira (with Advanced Roadmaps)
- GitHub Enterprise
- Slack Enterprise Grid
- Figma Professional
- PagerDuty (for Infra team)
- Datadog (monitoring)

**Agent Setup:**
- Multiple Jira projects
- GitHub organizations per department
- Slack Enterprise with workspaces
- Role-based agent configurations

**Cost:** ~$10,000/month (100 people × $100/user avg)

---

### Enterprise (200+ people)

**Recommended Stack:**
- Jira Data Center (self-hosted)
- GitHub Enterprise Server (self-hosted)
- MS Teams (included with Microsoft 365)
- Azure DevOps (build pipelines)
- Figma Enterprise
- PagerDuty + Datadog

**Agent Setup:**
- Federated Jira instances
- GitHub Enterprise across regions
- Azure AD integration
- Custom agent templates per division

**Cost:** Custom pricing (self-hosted reduces per-user costs)

---

## Integration Setup Priority for New Teams

**Week 1: Core Setup**
1. Project Management (Jira or Linear)
2. Source Control (GitHub)
3. Communication (Slack)

**Week 2: CI/CD & Quality**
4. Set up CI/CD pipelines (GitHub Actions or GitLab CI)
5. Configure agent webhooks

**Week 3: Monitoring & Design**
6. Add monitoring (Datadog for production)
7. Connect Figma (if design team exists)

**Week 4: Advanced Features**
8. Add PagerDuty for on-call
9. Configure advanced agent triggers
10. Set up custom agent templates

---

## Multi-Integration Scenarios

### Scenario 1: Developer Working on Feature

**Workflow:**
1. **Jira** → Story assigned to developer
2. **Agent** → Analyzes story, creates branch
3. **Figma** (if design attached) → Agent extracts design tokens
4. **GitHub** → Developer commits code, opens PR
5. **Slack** → Agent notifies team of PR
6. **GitHub** → CI/CD runs tests
7. **Slack** → Agent posts PR ready for review
8. **Jira** → Agent updates story status

**Integrations Used:** Jira, GitHub, Figma, Slack

---

### Scenario 2: QA Testing Feature

**Workflow:**
1. **Jira** → Story moves to "Ready for QA"
2. **Agent** → Creates test plan from acceptance criteria
3. **GitHub** → Checks if automated tests exist
4. **Slack** → Agent asks QA engineer to verify
5. **Jira** → QA transitions to "In QA"
6. (QA finds bug)
7. **Slack** → QA reports bug in #bugs channel
8. **Agent** → Creates Jira bug ticket
9. **Jira** → Bug assigned to original developer

**Integrations Used:** Jira, GitHub, Slack

---

### Scenario 3: Solution Architect Reviews Design

**Workflow:**
1. **Figma** → Designer posts comment "@arch-review"
2. **Agent** → Analyzes design components
3. **Agent** → Suggests component tree + API endpoints
4. **Jira** → Agent creates architecture epic
5. **Figma** → Agent replies with recommendations
6. **Slack** → Agent notifies #architecture channel
7. **Confluence** (optional) → Agent creates ADR document

**Integrations Used:** Figma, Jira, Slack, Confluence (optional)

---

### Scenario 4: Infrastructure Incident Response

**Workflow:**
1. **Datadog** → CPU spike detected (> 90%)
2. **Agent** → Analyzes metrics, identifies service
3. **PagerDuty** → Pages on-call engineer
4. **Slack** → Posts incident in #incidents
5. **Agent** → Auto-scales instances
6. **Jira** → Creates incident ticket
7. **GitHub** → Agent checks recent deployments
8. **Slack** → Agent posts resolution update
9. **PagerDuty** → Incident resolved

**Integrations Used:** Datadog, PagerDuty, Slack, Jira, GitHub

---

## Integration Authentication Methods

### OAuth 2.0 (Recommended)
- **Supports:** Slack, GitHub, GitLab, Figma
- **Pros:** Secure, user-scoped, easy to revoke
- **Setup:** User clicks "Connect GitHub" → OAuth flow → Agent gets token

### API Tokens/Keys
- **Supports:** Jira, Linear, Datadog, PagerDuty
- **Pros:** Simple to generate, long-lived
- **Setup:** User generates token in tool settings → Pastes into QUAD config

### Webhooks
- **Supports:** All tools (for receiving events)
- **Setup:** QUAD provides webhook URL → User adds to tool settings → Tool POSTs events to QUAD

---

## Security Best Practices

### Token Storage
- ✅ **DO:** Store in environment variables or secret managers (AWS Secrets Manager, HashiCorp Vault)
- ❌ **DON'T:** Commit tokens to Git repos or hardcode in agent MD files

### Webhook Security
- ✅ **DO:** Validate webhook signatures (HMAC-SHA256)
- ✅ **DO:** Use HTTPS for all webhook URLs
- ❌ **DON'T:** Accept unsigned webhook requests

### Least Privilege
- ✅ **DO:** Grant minimum required permissions (read-only for Figma, write for GitHub)
- ❌ **DON'T:** Use admin tokens for regular agents

---

## Troubleshooting Integration Issues

### "401 Unauthorized" Errors
**Cause:** Token expired or invalid
**Solution:**
1. Regenerate token in integration settings
2. Update environment variable
3. Restart agent

### "403 Forbidden" Errors
**Cause:** Insufficient permissions
**Solution:**
1. Check token scopes (GitHub: repo, workflow, admin:org)
2. Verify user has required role (Jira: Project Admin)

### "Webhook Not Received" Errors
**Cause:** Firewall blocking, wrong URL, or signature mismatch
**Solution:**
1. Verify webhook URL is publicly accessible
2. Check webhook delivery logs in integration settings
3. Validate signature verification code

---

## Integration Roadmap

**Phase 1 (Current - MVP):**
- ✅ Jira, Linear, Azure DevOps
- ✅ GitHub, GitLab, Bitbucket
- ✅ Slack, MS Teams
- ✅ Figma
- ✅ PagerDuty, Datadog

**Phase 2 (Q2 2026):**
- 🔜 Confluence (documentation)
- 🔜 Notion (alternative to Confluence)
- 🔜 TestRail (QA-specific)
- 🔜 Opsgenie (incident management)

**Phase 3 (Q3 2026):**
- 🔜 Discord (communication)
- 🔜 Adobe XD (design)
- 🔜 Asana (project management)
- 🔜 Trello (simple boards)

---

## Custom Integration Requests

**Don't see your tool?**

QUAD supports custom integrations via webhooks. Contact QUAD Admin to discuss:
- Custom webhook endpoints
- API integration development
- Agent template customization

**Email:** support@quadframe.work
**Slack:** #quad-platform-help

---

**Last Updated:** December 31, 2025
**Maintained By:** QUAD Platform Team
