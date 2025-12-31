# QUAD Onboarding Requirements

## Overview

This document outlines everything you need before adopting QUAD methodology - tools, subscriptions, team structure, and a step-by-step onboarding checklist for Senior Directors.

---

## Understanding Agentic AI

### What is Agentic AI?

**Traditional AI (ChatGPT, Copilot):**
- You ask → AI answers
- One question at a time
- You do the work based on answers
- Manual copy/paste of outputs

**Agentic AI (Claude Code, QUAD Agents):**
- You give a goal → AI executes
- Autonomous multi-step tasks
- AI does the work, you approve
- Direct integration with your tools

### Example Comparison

| Task | Traditional AI | Agentic AI |
|------|----------------|------------|
| "Create a login page" | Gives you code to copy | Creates files, writes tests, opens PR |
| "Fix this bug" | Explains the solution | Reads code, finds issue, applies fix |
| "Expand this user story" | Suggests acceptance criteria | Updates JIRA, notifies team |

### Why QUAD Needs Agentic AI

QUAD's AI Agents are **agentic** - they don't just answer questions, they:
- Read your JIRA stories
- Generate code in your repository
- Create pull requests
- Run tests
- Deploy to environments

This requires tools that support autonomous execution with human oversight.

---

## Required Tools

### Critical (Must Have)

| Tool | Purpose | Cost | Why Required |
|------|---------|------|--------------|
| **Claude Business** | Agentic AI for code generation, story expansion | $30/user/month | Core agent runtime |
| **JIRA** | Project management, source of truth | $8/user/month | Story management, workflow |
| **GitHub/GitLab** | Source control, CI/CD | $4/user/month | Code repository, automation |

**Minimum Monthly Cost per Developer:** ~$42/month

### Recommended (Nice to Have)

| Tool | Purpose | Cost | Benefit |
|------|---------|------|---------|
| **Slack** | Team communication, notifications | $8/user/month | Agent notifications |
| **Linear** | Alternative to JIRA (faster UI) | $10/user/month | Modern project management |
| **Notion** | Documentation wiki | $10/user/month | Auto-generated docs |

---

## Tool Setup Details

### 1. Claude Business Setup

**Why Claude Business (not Claude Pro)?**
- Business has **Claude Code** - the agentic IDE integration
- Extended context window (200K tokens)
- Admin controls for team management
- SSO integration

**Setup Steps:**
1. Go to [claude.ai/business](https://claude.ai/business)
2. Sign up with company email
3. Add team members
4. Install Claude Code VS Code extension
5. Authenticate with your account

### 2. JIRA Setup

**Why JIRA?**
- QUAD's Source of Truth is JIRA
- Story Agent reads/writes to JIRA
- Workflow automation built-in

**Setup Steps:**
1. Create Atlassian account at [atlassian.com](https://atlassian.com)
2. Create JIRA project (Scrum or Kanban)
3. Configure workflow states:
   - Backlog → In Analysis → Ready for Dev → In Development → In QA → Ready for Deploy → Done
4. Install JIRA API access for agents
5. Generate API token for automation

### 3. GitHub Setup

**Why GitHub?**
- Dev Agent creates branches and PRs
- Review Agent comments on PRs
- Deploy Agent triggers workflows

**Setup Steps:**
1. Create organization at [github.com](https://github.com)
2. Create repository for project
3. Set up branch protection rules
4. Configure GitHub Actions for CI/CD
5. Generate personal access token or GitHub App

---

## Team Structure Prerequisites

### Minimum Team Size

QUAD is designed for teams with **10+ developers**. Smaller teams can adopt but may not see full ROI.

| Team Size | QUAD Recommendation |
|-----------|---------------------|
| 2-5 devs | Not recommended (too much overhead) |
| 5-10 devs | Possible, start at 0D or 1D |
| 10-50 devs | Ideal, full QUAD adoption |
| 50+ devs | Enterprise QUAD with multiple Directors |

### Required Roles

At minimum, you need people to fill these Circle responsibilities:

| Circle | Required Roles | Can Be Same Person |
|--------|----------------|-------------------|
| Circle 1 (Management) | BA or Product Owner | Yes, one person can cover |
| Circle 2 (Development) | At least 2 developers | No, need team |
| Circle 3 (QA) | QA Engineer | Can be shared with dev |
| Circle 4 (Infrastructure) | DevOps/Cloud Engineer | Can be shared |

---

## Senior Director Onboarding Checklist

### Phase 1: Prerequisites (Week 1)

- [ ] **Subscribe to Claude Business** ($30/user/month)
  - Create account at claude.ai/business
  - Add initial pilot team members (5-10 people)
  - Install Claude Code in VS Code/Cursor

- [ ] **Set up JIRA project** ($8/user/month)
  - Create new Scrum/Kanban project
  - Configure QUAD workflow states
  - Generate API token for agent access

- [ ] **Configure GitHub/GitLab** ($4/user/month)
  - Create repository for pilot project
  - Set up branch protection
  - Configure CI/CD pipeline

### Phase 2: Team Structure (Week 2)

- [ ] **Assign Circle leads**
  - Circle 1 Lead (BA/PM)
  - Circle 2 Lead (Tech Lead)
  - Circle 3 Lead (QA Lead)
  - Circle 4 Lead (DevOps Lead)

- [ ] **Define team allocation**
  - Dedicated vs shared per project
  - Cross-project assignments

- [ ] **Establish communication channels**
  - Slack/Teams channels per project
  - Agent notification channels

### Phase 3: Configuration (Week 3)

- [ ] **Use /configure wizard**
  - Select adoption level (recommend 2D Plane)
  - Choose estimation scheme
  - Configure story labels
  - Generate quad.config.yaml

- [ ] **Deploy configuration**
  - Add quad.config.yaml to repository
  - Configure agent permissions
  - Test agent connectivity

- [ ] **Run pilot project**
  - Select low-risk feature
  - Have Story Agent expand story
  - Have Dev Agent generate code
  - Human review and approve

### Phase 4: Rollout (Week 4+)

- [ ] **Train team on QUAD terminology**
  - Cycles, Pulses, Checkpoints
  - Flow Documents, Human Gates
  - Adoption Levels (0D-4D)

- [ ] **Establish metrics baseline**
  - Current velocity
  - Current cycle time
  - Current defect rate

- [ ] **Gradual agent enablement**
  - Start with Story Agent only
  - Add Dev Agent after 1 week
  - Add Test Agent after 2 weeks
  - Add Deploy Agent after successful QA

---

## Adoption Levels Summary

| Level | AI Involvement | Human Gates | Best For |
|-------|----------------|-------------|----------|
| **0D Origin** | None | All manual | Learning QUAD methodology |
| **1D Vector** | Sequential agents | Between each step | Cautious teams |
| **2D Plane** | Parallel agents | Per phase | Most organizations (recommended) |
| **3D Space** | Full pipelines | Start and end only | Mature teams |
| **4D Hyperspace** | Self-improving | Exceptions only | AI-native organizations |

**Recommendation:** Start at **2D Plane** for balance of AI assistance and human oversight.

---

## Cost Calculator

### For 10-Person Team

| Item | Monthly Cost |
|------|--------------|
| Claude Business (10 users) | $300 |
| JIRA (10 users) | $80 |
| GitHub Team (10 users) | $40 |
| Slack Pro (10 users) | $80 |
| **Total** | **$500/month** |

### ROI Estimate

With QUAD saving ~61% of development costs (see [/pitch](/pitch)):
- 10 devs × $130K salary = $1.3M/year dev cost
- 61% savings = ~$793K/year saved
- Tool cost = $6K/year
- **Net ROI: $787K/year**

---

## Common Obstacles & Solutions

| Obstacle | Solution |
|----------|----------|
| "We already use Scrum" | QUAD complements Scrum, replaces ceremonies not structure |
| "Developers don't trust AI" | Start at 0D, show AI suggestions only, build trust |
| "No budget for new tools" | Show ROI calculation, tools pay for themselves |
| "Too much process overhead" | Documentation overhead reduced by AI generating 80% |
| "We're too small" | Wait until 10+ developers, or adopt 0D/1D only |

---

## Next Steps

1. **Assess fit**: Complete [/discovery](/discovery) assessment
2. **Calculate ROI**: Use [/pitch](/pitch) calculator for your company size
3. **Configure QUAD**: Use [/configure](/configure) to generate setup
4. **Review platform**: Check [/platform](/platform) for enterprise options
5. **Read documentation**: Browse [/docs](/docs) for deep dives

---

## Related Documentation

- [QUAD Discovery](./QUAD_DISCOVERY.md) - Diagnostic assessment
- [QUAD Value Proposition](./QUAD_PITCH.md) - ROI and benefits
- [QUAD Platform](./QUAD_PLATFORM.md) - Enterprise deployment
- [QUAD Adoption Levels](./quad-workflow/QUAD_ADOPTION_LEVELS.md) - 0D to 4D progression
- [QUAD Adoption Journey](./quad-workflow/QUAD_ADOPTION_JOURNEY.md) - 8-step journey

---

**Last Updated:** December 31, 2025
**Author:** A2Vibe Creators
