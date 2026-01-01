# QUAD Platform Agent MD File Format Specification

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** Downloadable markdown configuration files for role-based QUAD agents

---

## Overview

Agent MD files are **downloadable markdown configurations** that users run with Claude Code to set up personalized QUAD agents. Each role (Developer, QA Engineer, Infrastructure Engineer, etc.) gets a customized agent configuration with role-specific integrations, permissions, and workflows.

---

## File Naming Convention

```
agent-{role}-{circle}.md
```

**Examples:**
- `agent-developer-dev.md` - Developer in Development Circle
- `agent-qa-lead-qa.md` - QA Lead in QA Circle
- `agent-tech-lead-dev.md` - Tech Lead in Development Circle
- `agent-solution-architect-enabling.md` - Solution Architect in Enabling Teams
- `agent-devops-infra.md` - DevOps Engineer in Infrastructure Circle

---

## File Structure

### Section 1: Agent Identity
```markdown
# {Role Name} QUAD Agent

**Circle:** {Circle Name}
**Role:** {Role Title}
**Organization:** {Company Name}
**Generated:** {ISO Date}
**Config Version:** {quad.config.yaml version}

---

## Agent Personality

You are a {role} working within the QUAD (Quick Unified Agentic Development) methodology. Your responsibilities focus on {circle-specific duties}.

**Core Responsibilities:**
- {Responsibility 1}
- {Responsibility 2}
- {Responsibility 3}

**Collaboration Style:**
- You work closely with {related roles}
- You receive requirements from {upstream sources}
- You deliver {outputs} to {downstream consumers}
```

### Section 2: Active Integrations
```markdown
---

## Active Integrations

Your agent is configured to monitor these requirement sources:

### 1. {Integration Name} {Emoji}

**Status:** ✅ Enabled
**Trigger:** {Trigger description}
**Example:** {Real-world example}

**Configuration:**
```yaml
{integration}:
  enabled: true
  endpoint: {webhook_url}
  api_key: ${ENV_VAR_NAME}
  filters:
    - {filter 1}
    - {filter 2}
```

**What This Means:**
When {trigger event happens}, your agent will:
1. {Action 1}
2. {Action 2}
3. {Action 3}

**Expected Response Time:** {X minutes/hours}

---

### 2. {Next Integration}
...
```

### Section 3: Permissions & Boundaries
```markdown
---

## Permissions & Boundaries

**What You CAN Do:**
- ✅ {Permission 1}
- ✅ {Permission 2}
- ✅ {Permission 3}

**What You CANNOT Do:**
- ❌ {Restriction 1} (requires {role} approval)
- ❌ {Restriction 2} (handled by {circle})
- ❌ {Restriction 3} (QUAD Admin only)

**Escalation Path:**
- For {issue type} → Contact {role}
- For {issue type} → Contact {role}
- For urgent issues → Contact QUAD Admin
```

### Section 4: Workflow Examples
```markdown
---

## Workflow Examples

### Example 1: {Common Scenario}

**Trigger:** {What initiates this}
**Your Actions:**

1. **Read Requirement**
   ```bash
   # Agent reads from {source}
   {command or API call}
   ```

2. **Analyze & Validate**
   - Check for {validation 1}
   - Verify {validation 2}
   - Confirm {validation 3}

3. **Execute Work**
   ```bash
   {example commands}
   ```

4. **Notify Completion**
   - Update {system} with status
   - Tag {role} for review
   - Log to audit trail

**Expected Outcome:** {What success looks like}

---

### Example 2: {Another Scenario}
...
```

### Section 5: Setup Instructions
```markdown
---

## Setup Instructions

Follow these steps to activate your QUAD agent:

### Step 1: Install Claude Code
```bash
# If not already installed
npm install -g @anthropic/claude-code
```

### Step 2: Set Environment Variables

Add these to your `.env` file or shell profile:

```bash
# Required for all agents
export QUAD_ORG_ID="{org_id}"
export QUAD_API_KEY="{api_key}"

# Integration-specific (if enabled)
export JIRA_API_TOKEN="{from_admin}"
export SLACK_WEBHOOK_URL="{from_admin}"
export GITHUB_TOKEN="{from_admin}"
export FIGMA_ACCESS_TOKEN="{from_admin}"
```

**Where to Get These:**
- QUAD credentials: Contact QUAD Admin or download from /configure
- Integration tokens: See [Integration Setup Guide](INTEGRATION_SETUP.md)

### Step 3: Run This Agent File

```bash
# Navigate to your project directory
cd /path/to/your/project

# Start Claude Code with this agent configuration
claude-code --agent-config agent-{role}-{circle}.md
```

### Step 4: Verify Integrations

The agent will run an onboarding check:

```
✅ QUAD API connection successful
✅ Jira webhook configured (listening on PROJECT-*)
✅ Slack channel connected (#engineering)
❌ GitHub token invalid (please update GITHUB_TOKEN)
```

Fix any ❌ errors before proceeding.

### Step 5: Test Your First Workflow

Try this test to confirm everything works:

1. {Test action 1}
2. {Expected agent response}
3. {Verification step}

If successful, you should see: {success message}

---

## Customization Options

You can customize this agent by editing the YAML sections above:

**Change Filters:**
```yaml
filters:
  - "jira:project=MYPROJ"  # Only watch specific project
  - "slack:channel=#my-team"  # Only specific channel
```

**Adjust Permissions:**
```yaml
permissions:
  can_commit: true  # Allow direct commits
  can_merge: false  # Require PR review
```

**Add Custom Commands:**
```yaml
custom_commands:
  - name: "deploy-staging"
    description: "Deploy to staging environment"
    command: "./deploy.sh staging"
```

---

## Troubleshooting

### Agent Not Responding to Triggers

**Check:**
1. Environment variables are set correctly (`echo $JIRA_API_TOKEN`)
2. Webhook URLs are reachable (`curl -I {webhook_url}`)
3. Firewall/network allows incoming webhooks
4. Integration filters aren't too restrictive

### Permission Errors

**Error:** "Agent does not have permission to {action}"

**Solution:** Your role ({role}) does not have {permission}. Options:
1. Request permission upgrade from QUAD Admin
2. Escalate task to {role with permission}
3. Use hybrid mode (agent suggests, you approve manually)

### Integration Authentication Failures

**Error:** "401 Unauthorized" or "403 Forbidden"

**Solution:**
1. Verify token is still valid (tokens may expire)
2. Regenerate token from integration provider
3. Update environment variable with new token
4. Restart agent

---

## Support & Resources

**QUAD Platform Documentation:** https://quadframe.work/docs
**Integration Setup Guide:** [INTEGRATION_SETUP.md](INTEGRATION_SETUP.md)
**API Reference:** [API_REFERENCE.md](API_REFERENCE.md)
**Community Support:** Slack #quad-platform-help
**QUAD Admin Contact:** {admin_email}

---

**Generated by QUAD Platform Configure Tool**
**Organization:** {company_name}
**Config Hash:** {md5_hash}
**Regenerate:** Visit https://quadframe.work/configure/agents
```

---

## Template Variables

When generating agent MD files, replace these variables:

| Variable | Example Value | Source |
|----------|---------------|--------|
| `{role}` | "Developer" | User selection |
| `{circle}` | "Development" | User selection |
| `{company_name}` | "Acme Corp" | quad.config.yaml |
| `{org_id}` | "org_abc123" | Generated on first config |
| `{api_key}` | "sk_live_..." | Generated per agent |
| `{webhook_url}` | "https://api.quad.../webhook" | Generated per integration |
| `{admin_email}` | "admin@acme.com" | quad.config.yaml |
| `{iso_date}` | "2025-12-31T10:30:00Z" | Generation timestamp |
| `{md5_hash}` | "a3b4c5d6..." | Hash of config for versioning |

---

## Integration-Specific Sections

### Jira Integration
```markdown
### Jira Integration 🎫

**Status:** ✅ Enabled
**Trigger:** Issue created, updated, or transitioned
**Watched Projects:** {PROJECT_KEYS}

**Configuration:**
```yaml
jira:
  enabled: true
  base_url: https://your-domain.atlassian.net
  api_token: ${JIRA_API_TOKEN}
  webhook_secret: ${JIRA_WEBHOOK_SECRET}
  filters:
    - project: {PROJECT_KEY}
    - issue_type: Story, Bug, Task
    - status_changed_to: In Progress, Code Review
```

**Workflow:**
1. **Issue Created** → Agent analyzes description, suggests implementation approach
2. **Status → In Progress** → Agent checks if branch exists, creates if missing
3. **Status → Code Review** → Agent validates PR checklist completion

**Example:**
```
Jira Webhook: PROJECT-123 status changed to "In Progress"
↓
Agent checks: Does branch feature/PROJECT-123 exist?
  → NO: Creates branch, scaffolds files, comments on ticket
  → YES: Checks if commits exist, reminds dev to push progress
```
```

### Slack Integration
```markdown
### Slack Integration 💬

**Status:** ✅ Enabled
**Trigger:** @story-agent mention or emoji reaction 📝
**Watched Channels:** {CHANNEL_LIST}

**Configuration:**
```yaml
slack:
  enabled: true
  webhook_url: ${SLACK_WEBHOOK_URL}
  app_token: ${SLACK_APP_TOKEN}
  filters:
    - channels: ["#engineering", "#product"]
    - mention: "@story-agent"
    - emoji_reaction: ":story:", ":requirement:"
```

**Workflow:**
1. **@mention** → Agent reads thread, extracts requirements, creates ticket draft
2. **📝 Emoji Reaction** → Agent flags message as requirement for review
3. **Thread Reply** → Agent updates ticket draft based on clarifications

**Example:**
```
Slack Message:
"@story-agent We need to add 2FA to the login flow. Users should get
a code via email. cc @sarah @mike"

Agent Response (threaded):
"✅ Requirement captured!

📋 Draft Story:
Title: Implement 2FA for Login Flow
Description: Add email-based two-factor authentication...
Acceptance Criteria:
  - User receives 6-digit code via email
  - Code expires after 10 minutes
  - ...

Tags: @sarah @mike
Should I create this in Jira PROJECT-*? React with ✅ to confirm."
```
```

### Figma Integration
```markdown
### Figma Integration 🎨

**Status:** ✅ Enabled
**Trigger:** Design file comment with specific tags
**Watched Files:** {FILE_IDS}

**Configuration:**
```yaml
figma:
  enabled: true
  access_token: ${FIGMA_ACCESS_TOKEN}
  team_id: ${FIGMA_TEAM_ID}
  webhook_url: ${FIGMA_WEBHOOK_URL}
  filters:
    - file_ids: ["{FILE_ID_1}", "{FILE_ID_2}"]
    - comment_tags: ["@dev-ready", "@backend-api"]
```

**Workflow:**
1. **Designer adds @dev-ready comment** → Agent analyzes design specs
2. **Agent suggests project structure** → Component tree, API endpoints
3. **Generates scaffolding ticket** → Creates Jira issue with implementation plan

**Example:**
```
Figma Comment:
"@dev-ready This checkout flow needs these APIs:
- POST /cart/apply-coupon
- GET /cart/totals
- POST /orders/create"

Agent Response (Figma comment):
"✅ Analysis complete!

Detected Components:
  - CheckoutForm (React)
  - CouponInput (React)
  - OrderSummary (React)

Suggested API Endpoints:
  POST /api/v1/cart/apply-coupon
    Request: { coupon_code: string }
    Response: { discount: number, new_total: number }

  [Full API spec in Jira ticket PROJECT-456]

Created Jira Story: PROJECT-456 'Implement Checkout Flow APIs'
Assigned to: @backend-team"
```
```

### GitHub Integration
```markdown
### GitHub Integration 🐙

**Status:** ✅ Enabled
**Trigger:** Issue created, PR opened, commit pushed
**Watched Repos:** {REPO_LIST}

**Configuration:**
```yaml
github:
  enabled: true
  token: ${GITHUB_TOKEN}
  webhook_secret: ${GITHUB_WEBHOOK_SECRET}
  filters:
    - repos: ["{ORG}/{REPO}"]
    - events: ["issues", "pull_request", "push"]
    - branches: ["main", "develop", "feature/*"]
```

**Workflow:**
1. **Issue Created** → Agent links to Jira, suggests implementation files
2. **PR Opened** → Agent reviews code, checks tests, validates against ticket
3. **Commit Pushed** → Agent verifies commit message format, updates ticket status

**Example:**
```
GitHub Event: PR #42 opened by @developer
Title: "Fix login validation bug"
Files: src/auth/LoginForm.tsx, tests/auth/login.test.ts

Agent Actions:
1. ✅ Linked to Jira ticket PROJECT-789
2. ✅ Code review: LGTM, follows style guide
3. ✅ Tests added and passing
4. ❌ Missing: Update CHANGELOG.md
5. 💬 Comment on PR: "Great work! Please add changelog entry before merge."
6. 🏷️ Add label: "needs-changelog"
```
```

---

## Role-Specific Templates

### Developer Agent
```markdown
**Responsibilities:**
- Implement features from approved stories
- Write unit/integration tests
- Create pull requests for code review
- Update technical documentation

**Integrations Priority:**
1. Jira (primary requirement source)
2. Slack (team communication)
3. GitHub (code delivery)
4. Figma (design reference)

**Permissions:**
- ✅ Create feature branches
- ✅ Commit code
- ✅ Open pull requests
- ❌ Merge to main (requires review)
- ❌ Deploy to production
```

### QA Engineer Agent
```markdown
**Responsibilities:**
- Create test plans from acceptance criteria
- Execute manual/automated tests
- Report bugs with reproduction steps
- Validate bug fixes

**Integrations Priority:**
1. Jira (test case source, bug reporting)
2. GitHub (test automation code)
3. Slack (blockers, urgent bugs)

**Permissions:**
- ✅ Create test branches
- ✅ Write automated tests
- ✅ Create bug tickets
- ✅ Transition tickets (To QA, Done, Blocked)
- ❌ Merge code (QA automation only)
```

### Solution Architect Agent (Enabling Team)
```markdown
**Responsibilities:**
- Analyze design mockups for technical feasibility
- Suggest system architecture and component structure
- Create technical specifications from designs
- Provide guidance to development teams

**Integrations Priority:**
1. Figma (primary requirement source)
2. Jira (architecture stories)
3. Slack (architecture reviews)

**Permissions:**
- ✅ Read all designs (Figma)
- ✅ Create architecture documents
- ✅ Suggest component structure
- ❌ Write production code (advisory role)
- ❌ Create implementation tickets (guides, doesn't execute)
```

### Infrastructure Engineer Agent
```markdown
**Responsibilities:**
- Manage CI/CD pipelines
- Monitor deployments and infrastructure
- Handle production incidents
- Optimize cloud resources

**Integrations Priority:**
1. GitHub (pipeline triggers)
2. Slack (incident alerts)
3. Jira (infrastructure tasks)

**Permissions:**
- ✅ Deploy to staging/production
- ✅ Modify CI/CD configs
- ✅ Access production logs
- ✅ Rollback deployments
- ❌ Delete production databases
```

---

## Version History

**1.0.0** (Dec 31, 2025)
- Initial specification
- Support for 6 integrations (Jira, Slack, Email, GitHub, Figma, Scheduled)
- 4 base roles (Developer, QA, Infra, Architect)
- Hybrid agent mode (AI suggests, human approves)

---

## Future Enhancements

**Planned for v1.1:**
- MS Teams integration
- Azure DevOps integration
- Linear integration
- Custom role templates
- Agent learning from reassignments (feedback loop)

---

**Specification Maintained By:** QUAD Platform Team
**Last Review:** December 31, 2025
