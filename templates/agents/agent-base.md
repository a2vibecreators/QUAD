# QUAD Agent - Base Template

**Version:** 1.0.0
**Type:** Base Template (Extended by all QUAD agents)
**Created:** December 31, 2025

---

## Introduction

This is the **base template** for all QUAD agents. It contains common functionality that all agents inherit, including:

- Session management and context preservation
- Integration verification
- Environment setup
- Troubleshooting procedures
- Standard agent personality traits

**Do not use this template directly.** Instead, use a specific agent that extends this base:
- `agent-developer.md` - Development agent
- `agent-qa.md` - QA engineer agent
- `agent-infrastructure.md` - Infrastructure engineer agent
- `agent-product-tech-lead.md` - Product/Tech Lead agent
- `agent-solution-architect.md` - Solution Architect agent

---

## Session Management (Context Preservation)

**Tagline:** *"Lost context? Just run `{{AGENT_NAME}}-init` to restore your session."*

### How It Works

This agent maintains **intelligent session management** to preserve context across conversations:

**7-Day Active Context Window:**
- Agent remembers your last 7 days of work in detail
- After 7 days, old context is compressed and archived
- Only "Problem → Solution" summary is kept

**What Gets Stored:**
```
.quad/
├── session.json              # Current session state
├── context.md                # Last 7 days of detailed work
└── archive/
    └── compressed/           # Older sessions (compressed)
```

**Session State (session.json):**
```json
{
  "companyName": "{{COMPANY_NAME}}",
  "lastActive": "2025-12-31T10:30:00Z",
  "integrations": {
    "jira": {"enabled": true, "verified": true},
    "github": {"enabled": true, "verified": true},
    "slack": {"enabled": true, "verified": false}
  },
  "contextWindow": {
    "startDate": "2025-12-24",
    "endDate": "2025-12-31",
    "compressionScheduled": "2026-01-07"
  },
  "workCompleted": [
    "Setup Jira polling (Dec 24)",
    "Configured GitHub webhooks (Dec 26)",
    "Built dashboard UI (Dec 30)"
  ]
}
```

### First-Time Session Initialization

When you run this agent for the **FIRST time**, it will:

1. **Check for existing session**
   ```bash
   ls .quad/session.json
   ```

2. **Interactive setup** (if no session found):
   ```
   Welcome to {{AGENT_NAME}} QUAD Agent!

   I need to verify your integrations before we start.

   {{INTEGRATION_CHECKS}}

   Session initialized! You're ready to go.
   ```

3. **Create session state**:
   - Write `.quad/session.json`
   - Write `.quad/context.md` (empty initially)
   - Create `.quad/archive/` folder

### Context Restoration After Conversation Reset

**Problem:** Claude Code conversation gets compacted or you start a new conversation.

**Solution:** Run `{{AGENT_NAME}}-init` to restore your session context.

**What `{{AGENT_NAME}}-init` Does:**

1. **Reads `.quad/session.json`**:
   - Restores company name, integrations, work history
   - Loads last 7 days of detailed context from `context.md`

2. **Displays Session Summary**:
   ```
   📋 Session Restored!

   Company: {{COMPANY_NAME}}
   Last Active: December 30, 2025 (1 day ago)

   Integrations:
   ✅ Jira: Connected ({{JIRA_PROJECT_KEY}})
   ✅ GitHub: Connected ({{GITHUB_ORG}}/{{GITHUB_REPO}})
   ⚠️  Slack: Not verified (run test notification)

   Recent Work (Last 7 Days):
   - Dec 24: Setup Jira polling
   - Dec 26: Configured GitHub webhooks
   - Dec 30: Built dashboard UI

   Context preserved. Continue where you left off!
   ```

3. **Ready to Continue**:
   - Agent now remembers all your integrations
   - Agent knows what you've been working on
   - No need to re-explain the project

### Context Compression (After 7 Days)

**When does compression happen?**
- Automatically after 7 days of inactivity
- Manually via `{{AGENT_NAME}}-archive` command

**Before Compression (Detailed):**
```markdown
## December 24, 2025 - Setup Jira Polling

User: "We need to add Jira polling to track sprint progress"
Agent: "I suggest polling Jira API every 30 seconds. Here's the approach..."
User: "What about rate limits?"
Agent: "Jira Cloud allows 10 requests/second. We're well within limits."
[20 more back-and-forth messages about implementation details]
Agent: "Polling implemented in src/lib/jira-poller.ts"
User: "Test it"
Agent: "Running test... ✅ Successfully fetched 15 issues from QUAD-SPRINT-1"
```

**After Compression (Problem → Solution):**
```markdown
## December 24, 2025 - Setup Jira Polling

**Problem:** Need to track Jira sprint progress in real-time
**Solution:** Implemented 30-second polling of Jira API
**Code:** `src/lib/jira-poller.ts`, `src/app/api/jira/poll/route.ts`
**Result:** ✅ Successfully polling 15 issues from QUAD-SPRINT-1
**Next:** Add error handling for API failures
```

**What Gets Deleted:**
- ❌ Back-and-forth discussion about implementation approaches
- ❌ Questions and clarifications during development
- ❌ Intermediate code iterations

**What Gets Kept:**
- ✅ What problem was solved
- ✅ What solution was built
- ✅ What files were created/modified
- ✅ What the outcome was
- ✅ What needs to happen next

### Benefits of Session Management

| Without Session Management | With Session Management |
|----------------------------|-------------------------|
| ❌ Lost context after conversation reset | ✅ Run `{{AGENT_NAME}}-init` to restore |
| ❌ Must re-verify integrations every time | ✅ Integration state persisted |
| ❌ Repeat project explanation | ✅ Agent remembers project details |
| ❌ No memory of what was built | ✅ Work history tracked |
| ❌ Bloated conversation context (100K+ tokens) | ✅ Compressed to key outcomes |

### Session Management Commands

**`{{AGENT_NAME}}-init`** - Restore session context (run this after conversation reset)
```bash
# Loads .quad/session.json and context.md
# Displays integration status and recent work
```

**`{{AGENT_NAME}}-status`** - Show current session state
```bash
# Shows company name, integrations, context window dates
```

**`{{AGENT_NAME}}-archive`** - Manually compress old context
```bash
# Compresses context.md to Problem→Solution format
# Moves compressed context to archive/
```

**`{{AGENT_NAME}}-reset`** - Clear session and start fresh
```bash
# ⚠️  WARNING: Deletes .quad/session.json and context.md
# Use only if you want to completely start over
```

---

## Integration Verification

Before starting work, this agent verifies that all required integrations are properly configured.

### Required Environment Variables

```bash
# Company Configuration
COMPANY_NAME={{COMPANY_NAME}}

# Integration-Specific Variables (set by specific agent)
{{INTEGRATION_VARS}}
```

### Verification Checklist

**On first run or after `{{AGENT_NAME}}-init`, the agent checks:**

{{VERIFICATION_CHECKLIST}}

**Example Verification Output:**
```
🔍 Verifying Integrations...

{{VERIFICATION_OUTPUT}}

✅ All integrations verified! Ready to start.
```

---

## Agent Personality & Behavior

All QUAD agents share these personality traits:

### Communication Style
- **Professional but approachable** - Not robotic, not overly casual
- **Proactive** - Suggests improvements without being asked
- **Transparent** - Explains what's happening and why
- **Patient** - Never rushes, always explains complex topics clearly

### Working Style
1. **Plan before acting** - Explain approach before implementing
2. **Show, don't just tell** - Provide code examples, not just descriptions
3. **Verify everything** - Test integrations, run commands, check results
4. **Track progress** - Update session state after completing tasks

### Error Handling
- Never say "I can't do that" - Instead: "Here's the best approach given our constraints"
- If API fails, provide fallback options
- If credentials missing, guide user to get them (don't guess)
- If configuration wrong, show exactly what to fix

### Code Quality Standards
- **Type-safe** - Use TypeScript, define proper types
- **Error handling** - Always use try/catch for external API calls
- **Logging** - Log important events (API calls, errors, state changes)
- **Comments** - Explain WHY, not WHAT (code should be self-documenting)

---

## Tool Configuration & Access Control

All QUAD agents have access to specific tools based on their role. Tool access is configured by the **QUAD_ADMIN** during company setup.

### Tool Configuration Strategy

**Two Deployment Models:**

1. **Static Site (quadframe.work)** - We define default tools
   - Predefined tool list based on industry standards
   - User downloads agent MD with recommended tools
   - No customization (demo/getting started only)

2. **Self-Hosted (QUAD Platform)** - QUAD_ADMIN configures tools
   - Admin enables/disables tools per agent type
   - Admin provides API tokens/credentials
   - Stored in QUAD_company_integrations table

### Industry-Standard Tools by Agent Type

**Backend Developer Agent:**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| Source Control | GitHub, GitLab, Bitbucket, Azure Repos, Gerrit | ✅ GitHub, GitLab, Bitbucket |
| Project Management | Jira, Linear, Azure DevOps, Asana, Monday | ✅ Jira, Linear, Azure DevOps |
| API Testing | Postman, Insomnia, Swagger, Thunder Client, REST Client | 🔜 Future |
| Containerization | Docker, Kubernetes, Podman, containerd, LXC | 🔜 Future |
| Cloud Providers | AWS, GCP, Azure, DigitalOcean, Heroku | 🔜 Future |

**UI Developer Agent (Base):**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| Design | Figma, Sketch, Adobe XD, Zeplin, InVision | ✅ Figma |
| Source Control | GitHub, GitLab, Bitbucket | ✅ GitHub, GitLab, Bitbucket |
| Project Management | Jira, Linear, Asana | ✅ Jira, Linear |
| Communication | Slack, Microsoft Teams, Discord, Zoom, Google Chat | ✅ Slack, Teams, Discord |
| Browser Tools | Chrome DevTools, Safari DevTools, Firefox DevTools | N/A (local tools) |

**iOS Developer Agent (Extends UI):**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| IDE | Xcode, AppCode, VS Code | N/A (local tools) |
| Distribution | App Store Connect, TestFlight | 🔜 Future |
| Analytics | Firebase, Crashlytics, Mixpanel, Amplitude, Sentry | 🔜 Future |
| Design | Figma, Sketch (inherited from UI) | ✅ Figma |
| CI/CD | Fastlane, Xcode Cloud, Bitrise, CircleCI, GitHub Actions | 🔜 Future |

**Android Developer Agent (Extends UI):**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| IDE | Android Studio, IntelliJ IDEA, VS Code | N/A (local tools) |
| Distribution | Google Play Console, Firebase App Distribution | 🔜 Future |
| Analytics | Firebase, Crashlytics, Mixpanel, Amplitude, Sentry | 🔜 Future |
| Design | Figma, Sketch (inherited from UI) | ✅ Figma |
| Build System | Gradle, Maven, Bazel | N/A (local tools) |

**Web Developer Agent (Extends UI):**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| IDE | VS Code, WebStorm, Sublime Text, Atom, Brackets | N/A (local tools) |
| Hosting | Vercel, Netlify, AWS Amplify, GitHub Pages, Cloudflare | 🔜 Future |
| Package Managers | npm, yarn, pnpm, Bun | N/A (local tools) |
| Design | Figma, Sketch (inherited from UI) | ✅ Figma |
| Testing | Cypress, Playwright, Selenium, Jest, Vitest | 🔜 Future |

**QA Engineer Agent:**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| Bug Tracking | Jira, Linear, Azure DevOps, GitHub Issues, Bugzilla | ✅ Jira, Linear, Azure DevOps |
| Test Automation | Selenium, Cypress, Playwright, Appium, TestCafe | 🔜 Future |
| API Testing | Postman, Insomnia, REST Assured, SoapUI, Katalon | 🔜 Future |
| Cross-Browser | BrowserStack, Sauce Labs, LambdaTest, CrossBrowserTesting | 🔜 Future |
| Performance | JMeter, Gatling, k6, Locust, Artillery | 🔜 Future |

**Infrastructure Engineer Agent:**
| Tool Category | Top 5 Tools | QUAD Platform Support |
|---------------|-------------|----------------------|
| Cloud Providers | AWS, GCP, Azure, DigitalOcean, Linode | 🔜 Future |
| IaC (Infrastructure as Code) | Terraform, Ansible, CloudFormation, Pulumi, Chef | 🔜 Future |
| Orchestration | Kubernetes, Docker Swarm, Nomad, ECS, Mesos | 🔜 Future |
| Monitoring | PagerDuty, Datadog, New Relic, Grafana, Prometheus | ✅ PagerDuty, Datadog, New Relic, Grafana |
| CI/CD | Jenkins, GitHub Actions, GitLab CI, CircleCI, Travis CI | 🔜 Future |

### How Tool Access Works

**Static Site (Demo):**
```markdown
# Agent Template (agent-developer.md)

## Tools You'll Use:
- ✅ GitHub (source control)
- ✅ Jira (project management)
- ✅ Slack (communication)

[Agent instructions assume these tools are available]
```

**Self-Hosted (QUAD Platform):**
```sql
-- QUAD_ADMIN enables tools for company
INSERT INTO QUAD_company_integrations (company_id, integration_id, config)
VALUES
  ('company-uuid', 'github', '{"org": "acmecorp", "default_branch": "main"}'),
  ('company-uuid', 'jira', '{"instance": "acmecorp.atlassian.net", "project_key": "DEV"}'),
  ('company-uuid', 'slack', '{"workspace": "acmecorp", "channels": {"alerts": "#dev-alerts"}}');

-- When user downloads agent, QUAD Platform generates agent MD with only enabled tools
```

**Generated Agent MD (Customized):**
```markdown
# Developer QUAD Agent for Acme Corp

## Your Tools:
- ✅ GitHub (acmecorp organization)
- ✅ Jira (DEV project)
- ✅ Slack (#dev-alerts channel)

[Agent instructions use ONLY these 3 tools, not all 5 possible tools]
```

### Tool Inheritance (Agent Hierarchy)

**Example: UI → iOS/Android/Web**

```
agent-ui.md (base UI agent)
  Tools:
  - Figma (design)
  - GitHub (source control)
  - Jira (project management)
  - Slack (communication)
  ↓
  ├── agent-ios.md (extends agent-ui)
  │   Inherits: Figma, GitHub, Jira, Slack
  │   Adds: TestFlight, Firebase, Xcode Cloud
  │
  ├── agent-android.md (extends agent-ui)
  │   Inherits: Figma, GitHub, Jira, Slack
  │   Adds: Google Play Console, Firebase, Gradle
  │
  └── agent-web.md (extends agent-ui)
      Inherits: Figma, GitHub, Jira, Slack
      Adds: Vercel, Cypress, npm
```

**In Practice:**
- iOS developer gets: Figma + GitHub + Jira + Slack + TestFlight + Firebase
- Android developer gets: Figma + GitHub + Jira + Slack + Google Play + Firebase
- Web developer gets: Figma + GitHub + Jira + Slack + Vercel + Cypress

### Configuration in QUAD Platform

**QUAD_ADMIN Dashboard:**
```
Company Settings → Integrations

Backend Developer:
  [x] GitHub
  [x] Jira
  [x] Slack
  [ ] Postman (future)
  [ ] Docker (future)

UI Developer (Base):
  [x] Figma
  [x] GitHub
  [x] Jira
  [x] Slack

iOS Developer (extends UI):
  Inherited: Figma, GitHub, Jira, Slack ✅
  [ ] TestFlight (future)
  [ ] Firebase (future)

QA Engineer:
  [x] Jira
  [x] GitHub
  [ ] Selenium (future)
  [ ] BrowserStack (future)

Infrastructure:
  [x] PagerDuty
  [x] Datadog
  [ ] AWS (future)
  [ ] Terraform (future)
```

**When QUAD_ADMIN saves configuration:**
1. Inserts/updates QUAD_company_integrations table
2. Agent templates dynamically include only enabled tools
3. User downloads customized agent MD

---

## Troubleshooting

### Common Issues

#### Issue 1: Session Not Found
**Error:** `.quad/session.json` does not exist

**Solution:**
```bash
# Run initialization
{{AGENT_NAME}}-init

# Agent will create session file
```

#### Issue 2: Integration Verification Failed
**Error:** `JIRA_API_TOKEN is not set` (or similar)

**Solution:**
1. Check `.env` file in project root
2. Verify variable name matches exactly
3. Restart terminal/IDE to reload environment
4. Run `{{AGENT_NAME}}-init` again

#### Issue 3: Context Corruption
**Error:** `session.json` is malformed or unreadable

**Solution:**
```bash
# Backup corrupted file
mv .quad/session.json .quad/session.json.backup

# Reset session
{{AGENT_NAME}}-reset

# Re-initialize
{{AGENT_NAME}}-init
```

#### Issue 4: Old Context Taking Up Too Much Space
**Error:** `.quad/context.md` is 10MB+ (too large)

**Solution:**
```bash
# Manually trigger compression
{{AGENT_NAME}}-archive

# This will compress to Problem→Solution format
# Moves old context to .quad/archive/compressed/
```

---

## File Structure

All QUAD agents use this standard file structure:

```
your-project/
├── .quad/                     # QUAD agent session data
│   ├── session.json           # Current session state
│   ├── context.md             # Last 7 days of work
│   └── archive/
│       └── compressed/        # Compressed old sessions
│           ├── 2025-12-01.md
│           └── 2025-12-15.md
│
├── .env                       # Environment variables
├── .gitignore                 # Exclude .quad/ from git
│
├── src/
│   ├── app/                   # Next.js pages
│   ├── components/            # React components
│   ├── lib/                   # Utility functions
│   └── ...
│
└── documentation/
    ├── integration/           # Integration setup guides
    └── architecture/          # Architecture docs
```

---

## Security Best Practices

### 1. Never Commit Secrets
```bash
# .gitignore should include:
.env
.quad/session.json
*.log
```

### 2. Use Environment Variables
```bash
# ✅ GOOD
const apiToken = process.env.JIRA_API_TOKEN;

# ❌ BAD
const apiToken = "abc123..."; // Never hardcode!
```

### 3. Rotate Credentials Regularly
- Change API tokens every 90 days
- Use secret management tools (Vaultwarden, AWS Secrets Manager)
- Audit who has access to integration credentials

### 4. Validate All Inputs
```typescript
// ✅ GOOD - Validate before using
if (!process.env.JIRA_PROJECT_KEY?.match(/^[A-Z]+-[A-Z]+$/)) {
  throw new Error('Invalid JIRA_PROJECT_KEY format');
}

// ❌ BAD - Use without validation
const project = process.env.JIRA_PROJECT_KEY;
```

---

## Customization for Specific Agents

This base template is extended by specific agents using template variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{AGENT_NAME}}` | Name of specific agent | `developer`, `qa`, `infrastructure` |
| `{{COMPANY_NAME}}` | Company name from setup | `Mass Mutual`, `Acme Corp` |
| `{{INTEGRATION_CHECKS}}` | Agent-specific integration checks | Jira, GitHub, Slack for developer |
| `{{INTEGRATION_VARS}}` | Required environment variables | JIRA_API_TOKEN, GITHUB_TOKEN, etc. |
| `{{VERIFICATION_CHECKLIST}}` | Steps to verify integrations | Different per agent type |
| `{{VERIFICATION_OUTPUT}}` | Example verification output | Sample output for that agent |

**How Specific Agents Extend This Base:**

```markdown
# Developer QUAD Agent

{{> agent-base}}  <!-- Include all base template content -->

## Developer-Specific Configuration

[developer-only sections here]
```

---

## Support

**Questions or Issues?**
- Documentation: https://quadframe.work/docs
- GitHub Issues: https://github.com/a2vibecreators/quadframework/issues
- Email: support@quadframe.work

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
