# QUAD Platform - Session Management System

**Tagline:** *"Lost context? Just run `quadframework-init` to restore your session."*

**Version:** 1.0.0
**Last Updated:** December 31, 2025

---

## Overview

QUAD Platform uses an intelligent session management system that preserves context across Claude Code conversations.

**Problem We Solve:**
- ❌ Claude Code conversations get compacted (context window limit)
- ❌ User switches to different project, loses QUAD Platform context
- ❌ Conversation reset means Claude "forgets" what we're working on

**Our Solution:**
- ✅ `.claudeagent/` folder stores session state
- ✅ `quadframework-init` command restores full context
- ✅ Session persists across conversation resets

---

## Session State Storage

### Directory Structure

```
/Users/semostudio/git/a2vibecreators/quadframework/
├── .claudeagent/
│   ├── SESSION_HISTORY.md         # Compacted conversation summaries
│   ├── AGENT_RULES.md             # Project-specific rules for Claude
│   ├── AGENT_CONTEXT_FILES.md     # Important files Claude should read
│   ├── DATABASE_CHANGELOG.md      # Why database changes were made
│   └── archive/
│       ├── session-2025-12-30.md  # Archived sessions
│       └── session-2025-12-31.md
```

### What Gets Stored

**SESSION_HISTORY.md:**
```markdown
# QUAD Platform Session History

## December 31, 2025 - OAuth SSO Implementation

**What was done:**
- Created 6 QUAD_ database tables (companies, users, integrations, etc.)
- Implemented NextAuth.js with 6 SSO providers (Okta, Azure AD, Google, GitHub, Auth0, OIDC)
- Built authentication flow with free tier enforcement (5 users)
- Created documentation structure (similar to NutriNine)

**Key decisions:**
- Self-hosted deployment model (not SaaS in our cloud)
- Polling agents (30s interval) instead of webhooks
- Shared PostgreSQL database with NutriNine (QUAD_ prefix)
- OAuth SSO only (no passwords)

**Next steps:**
- Build auth pages (signup/login UI)
- Create dashboard pages
- Implement polling agents (Jira, GitHub, Slack)
```

**AGENT_RULES.md:**
```markdown
# QUAD Platform - Rules for Claude Agent

1. Always check SESSION_HISTORY.md before starting work
2. Update SESSION_HISTORY.md after completing major features
3. Use TodoWrite tool to track multi-step tasks
4. Ask user before deploying to production
5. Follow architecture decisions (self-hosted, polling, OAuth)
6. Database tables use QUAD_ prefix (shared with NutriNine)
7. Documentation follows NutriNine structure
```

---

## The `quadframework-init` Command

### What It Does

When you run `quadframework-init`, Claude Code:

1. **Reads session files:**
   ```
   .claudeagent/SESSION_HISTORY.md
   .claudeagent/AGENT_RULES.md
   .claudeagent/AGENT_CONTEXT_FILES.md
   ```

2. **Restores context:**
   - What features have been built
   - What architectural decisions were made
   - What's currently in progress
   - What files are important

3. **Resumes work:**
   - Picks up where we left off
   - No need to re-explain project
   - Knows the codebase structure

### How to Use

**Scenario 1: After Conversation Compacting**

```bash
# Claude says: "Conversation compacted, some context may be lost"

# You type:
/quadframework-init

# Claude reads:
- SESSION_HISTORY.md (what we've built)
- AGENT_RULES.md (how to work on this project)
- AGENT_CONTEXT_FILES.md (important files)

# Claude responds:
"✅ Session restored! I see we're working on QUAD Platform.
Last session: Implemented OAuth SSO with 6 providers.
Current task: Building auth pages (signup/login UI).
Ready to continue?"
```

**Scenario 2: Switching Between Projects**

```bash
# User was working on NutriNine, now wants to work on QUAD Platform

# You type:
/quadframework-init

# Claude reads session files and understands:
"I'm now working on QUAD Platform (not NutriNine).
Architecture: Self-hosted, OAuth SSO, polling agents.
Database: QUAD_ tables in shared PostgreSQL.
Ready to continue work on auth pages."
```

**Scenario 3: New Developer Onboarding**

```bash
# New developer clones repo, runs:
/quadframework-init

# Claude introduces the project:
"Welcome to QUAD Platform!

Overview:
- Self-hosted enterprise SaaS for AI-powered software workflows
- Uses OAuth SSO (Okta, Azure AD, Google, GitHub)
- Real-time polling agents (Jira, GitHub, Slack)
- Free tier: 5 users

Current status:
- ✅ Database schema complete (6 tables)
- ✅ OAuth SSO complete
- 🔄 Auth pages in progress

What would you like to work on?"
```

---

## Implementation

### slash command: `/quadframework-init`

**Location:** `.claude/commands/quadframework-init.md`

```markdown
# QUAD Platform - Restore Session Context

You are working on **QUAD Platform**, a self-hosted enterprise SaaS for AI-powered software development workflows.

## Read These Files First

Before responding, read these files to restore session context:

1. `.claudeagent/SESSION_HISTORY.md` - What we've built so far
2. `.claudeagent/AGENT_RULES.md` - Project rules and conventions
3. `.claudeagent/AGENT_CONTEXT_FILES.md` - Important files to review
4. `documentation/QUAD_PLATFORM.md` - Technical overview

## Project Summary

**Technology Stack:**
- Next.js 15 (App Router) - Web app
- PostgreSQL 15 - Database (QUAD_ tables)
- NextAuth.js - OAuth SSO
- Docker Compose - Deployment

**Key Decisions:**
- Self-hosted (customer's cloud, not our SaaS)
- Polling agents (30s interval, not webhooks)
- OAuth SSO only (Okta, Azure AD, Google, GitHub, Auth0, OIDC)
- Free tier: 5 users, Pro: unlimited users ($99/month)

**Database Location:**
- Shared with NutriNine: `/Users/semostudio/git/a2vibecreators/nutrinine/nutrinine-database/`
- Tables: `QUAD_companies`, `QUAD_users`, `QUAD_company_integrations`, etc.

## After Restoring Context

1. Summarize what was done in last session
2. Identify current task (check TodoWrite list)
3. Ask: "Ready to continue? What should I work on next?"
```

**Location:** `.claude/commands/quadframework-init.md` *(to be created)*

---

## Session History Best Practices

### When to Update SESSION_HISTORY.md

**Update after:**
- ✅ Completing a major feature (OAuth SSO, dashboard, etc.)
- ✅ Making architectural decision (self-hosted, polling, etc.)
- ✅ Finishing a sprint/milestone
- ✅ Before ending work session

**Don't update for:**
- ❌ Minor bug fixes
- ❌ Small documentation changes
- ❌ Mid-feature work

### What to Include

```markdown
## [Date] - [Feature Name]

**What was done:**
- Bullet points of completed work

**Key decisions:**
- Why we chose X over Y

**Code locations:**
- Important files created/modified

**Next steps:**
- What needs to be done next

**Blockers:**
- Any issues or dependencies
```

---

## Integration with TodoWrite

**TodoWrite** tracks current tasks, **SESSION_HISTORY** tracks completed work.

**Example workflow:**

```bash
# Start of session
/quadframework-init  # Restore context

# Claude reads TodoWrite:
[1. ✅ Build OAuth SSO - completed]
[2. 🔄 Create auth pages - in progress]
[3. ⏳ Build dashboard - pending]

# Work on task
[builds auth pages]

# End of session - Update SESSION_HISTORY.md
## December 31, 2025 - Auth Pages UI

**What was done:**
- Created /login page with SSO buttons
- Created /signup page for QUAD_ADMIN
- Added free tier enforcement (5 users)

**Key decisions:**
- Use shadcn/ui components for consistency
- Show only enabled SSO providers (based on env vars)

**Next steps:**
- Build dashboard pages
- Implement polling agents
```

---

## Benefits

| Benefit | Without Session Mgmt | With Session Mgmt |
|---------|---------------------|-------------------|
| **Context Loss** | ❌ Conversation compacts → forget everything | ✅ Run /quadframework-init → restore |
| **Project Switch** | ❌ Explain project again | ✅ Auto-loads context |
| **New Developer** | ❌ Read all docs manually | ✅ One command onboarding |
| **Consistency** | ❌ Different agents work differently | ✅ Rules enforced |
| **History** | ❌ Lost in conversation | ✅ Persisted in files |

---

## Future Enhancements

### Phase 2: Multi-Project Context

```bash
# User works on both NutriNine and QUAD Platform

/nutrinine-init       # Switches context to NutriNine
/quadframework-init   # Switches context to QUAD Platform

# Claude knows which project is active
# Loads correct session history
# Follows project-specific rules
```

### Phase 3: Team Collaboration

```bash
# SESSION_HISTORY.md includes author
## December 31, 2025 - OAuth SSO (by Suman)
[work details]

## January 2, 2026 - Dashboard (by John)
[work details]

# Team members can see what others did
# No duplicate work
# Smooth handoffs
```

---

## Related Documentation

- [Agent Rules](.claudeagent/AGENT_RULES.md)
- [Session History](.claudeagent/SESSION_HISTORY.md)
- [Context Files](.claudeagent/AGENT_CONTEXT_FILES.md)
- [QUAD Platform Overview](QUAD_PLATFORM.md)

---

**Tagline:** *"Lost context? Just run `quadframework-init` to restore your session."*

**Author:** A2Vibe Creators LLC
**Last Updated:** December 31, 2025
