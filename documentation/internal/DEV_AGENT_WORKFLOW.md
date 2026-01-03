# QUAD Dev Agent Workflow

## Overview

The Dev Agent provides an AI-assisted development experience within QUAD, similar to Claude Code but with **approval gates** and **team workflows**.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEV AGENT ARCHITECTURE                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│    User       │────▶│   Dev Agent   │────▶│   Codebase    │
│  (QUAD UI)    │     │   (AI Layer)  │     │   (Git Repo)  │
└───────────────┘     └───────────────┘     └───────────────┘
        │                     │                     │
        │                     ▼                     │
        │           ┌───────────────┐               │
        │           │  Code Review  │◀──────────────┘
        │           │   (PR Check)  │
        │           └───────────────┘
        │                     │
        │                     ▼
        │           ┌───────────────┐     ┌───────────────┐
        └──────────▶│   Approval    │────▶│    Deploy     │
                    │    Gate       │     │   (Cloud Dev) │
                    └───────────────┘     └───────────────┘
```

---

## User Journey

### Step 1: User Requests Change

```
User: "Add a button to show current time in a modal"

Dev Agent:
├── Searches codebase index
├── Finds: Modal.tsx, Button.tsx, existing patterns
├── Generates code changes
└── Shows diff to user
```

### Step 2: User Reviews Changes

```
┌─────────────────────────────────────────────────────────────────────┐
│  📝 Proposed Changes                                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  New File: src/components/TimeButton.tsx                             │
│  ─────────────────────────────────────────                           │
│  + 1  │ import { useState } from 'react';                            │
│  + 2  │ import { Button } from './Button';                           │
│  + 3  │ import { Modal } from './Modal';                             │
│  + 4  │ import { format } from 'date-fns';                           │
│  + 5  │                                                              │
│  + 6  │ export function TimeButton() {                               │
│  + 7  │   const [open, setOpen] = useState(false);                   │
│  + 8  │   return (                                                   │
│  + 9  │     <>                                                       │
│  + 10 │       <Button onClick={() => setOpen(true)}>                 │
│  + 11 │         Show Time                                            │
│  + 12 │       </Button>                                              │
│  + 13 │       <Modal open={open} onClose={() => setOpen(false)}>     │
│  + 14 │         {format(new Date(), 'HH:mm:ss')}                     │
│  + 15 │       </Modal>                                               │
│  + 16 │     </>                                                      │
│  + 17 │   );                                                         │
│  + 18 │ }                                                            │
│                                                                      │
│  [✓ Approve]  [✗ Reject]  [✏️ Request Changes]                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 3: User Approves → Create PR

```
User clicks [✓ Approve]

Dev Agent:
├── Creates branch: feature/time-button-QUAD-456
├── Commits changes
├── Pushes to remote
├── Creates Pull Request #123
└── Links PR to ticket QUAD-456
```

### Step 4: CI Validation

```
GitHub Actions runs automatically:

┌─────────────────────────────────────────────────────────────────────┐
│  PR #123: Add time button modal                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Checks:                                                             │
│  ✓ TypeScript check          passed                                  │
│  ✓ ESLint                    passed                                  │
│  ✓ Prisma schema valid       passed                                  │
│  ✓ Build successful          passed                                  │
│                                                                      │
│  Status: Ready for Review                                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 5: Human Review & Merge

```
Scenario A: Single Developer
─────────────────────────────
1. Tech lead reviews PR #123
2. Approves and merges to 'dev' branch
3. Auto-deploy triggered

Scenario B: Multiple Developers
─────────────────────────────
1. Alice's PR #123: Add time button
2. Bob's PR #124: Fix login bug
3. Both reviewed & approved
4. Merge #123 → CI runs
5. Merge #124 → CI runs
6. If conflict → Bob rebases on latest dev
```

### Step 6: Auto-Deploy to Cloud Dev

```
On merge to 'dev' branch:

GitHub Actions:
├── Build Docker image
├── Push to Container Registry
├── Deploy to Cloud Run
├── Run database migrations
├── Smoke test endpoints
└── Notify team on success

Result: https://dev.quadframe.work updated
```

---

## Local Development Flow

For developers who want to test locally before creating PR:

### Setup (One-time)

```bash
# Clone repository
git clone https://github.com/a2vibecreators/quadframework.git
cd quadframework

# Run setup wizard
./scripts/setup-local.sh
```

The setup script:
1. Checks prerequisites (Node, Docker, Git)
2. Shows installation instructions if missing
3. Creates PostgreSQL container
4. Runs database migrations
5. Seeds test data
6. Creates .env.local

### Development Cycle

```bash
# Start dev server
npm run dev

# Make changes...

# Validate before PR
./scripts/validate-build.sh

# If all checks pass, create PR
git checkout -b feature/your-feature
git add . && git commit -m "feat: Your feature"
git push origin feature/your-feature
```

---

## Multiple Developer Workflow

When two developers are working on different features:

```
Timeline:
─────────

Day 1:
  Alice: Creates branch feature/time-button
  Bob: Creates branch feature/login-fix

Day 2:
  Alice: Completes work, creates PR #123
  Bob: Completes work, creates PR #124

  CI runs on both PRs:
  PR #123: ✓ All checks passed
  PR #124: ✓ All checks passed

Day 3:
  Tech Lead reviews both PRs

  Merge Order:
  1. PR #123 merged to 'dev'
     → Auto-deploy to dev.quadframe.work
     → CI runs on dev branch

  2. PR #124: Needs rebase (dev changed)
     Bob: git rebase origin/dev
     Bob: git push --force-with-lease
     → CI runs again on updated PR

  3. PR #124 merged to 'dev'
     → Auto-deploy again
     → Both features now live
```

---

## AI Activity Routing

Different tasks use different AI providers:

| Task Type | Provider | Model | Cost |
|-----------|----------|-------|------|
| Simple ticket questions | GPT-3.5 | gpt-3.5-turbo | $0.0005/1K |
| Code generation | Claude | claude-3-sonnet | $0.003/1K |
| Complex analysis | Claude | claude-3-opus | $0.015/1K |
| Translation | DeepL | - | Fixed rate |
| Summarization | Ollama | llama3.2 | FREE |

Configured in `QUAD_ai_activity_routing` table per org.

---

## Approval Gates

### Level 1: AI Review (Automatic)
- Syntax check
- Type check
- Linting
- Security scan

### Level 2: User Approval (Required)
- User reviews AI-generated code
- Can modify, reject, or approve
- Approval creates PR

### Level 3: Team Review (Required for merge)
- Another team member reviews PR
- CI must pass
- Required approvals met

### Level 4: Deploy Approval (Optional)
- For production deploys
- Requires manager approval
- Audit logged

---

## Database Tables

| Table | Purpose |
|-------|---------|
| QUAD_ai_conversations | Per-ticket chat threads |
| QUAD_ai_messages | Individual messages with suggestions |
| QUAD_ai_activity_routing | AI provider selection by task |
| QUAD_ai_user_memories | Cross-project RAG summaries |
| QUAD_codebase_indexes | Token-optimized code summaries |

---

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `./scripts/setup-local.sh` | One-time local setup |
| `./scripts/validate-build.sh` | Pre-PR validation |
| `./scripts/generate-codebase-index.ts` | Update codebase index |

---

## CI/CD Workflows

| Workflow | Trigger | Action |
|----------|---------|--------|
| `ci.yml` | PR, push to main/dev | Validate & build |
| `deploy-dev.yml` | Push to dev | Deploy to Cloud Run |

---

## Security Considerations

1. **Secrets in GitHub**
   - `GCP_PROJECT_ID`
   - `GCP_SA_KEY`
   - `DEV_DATABASE_URL`
   - `NEXTAUTH_SECRET`

2. **Branch Protection**
   - Require PR reviews
   - Require CI to pass
   - No direct pushes to main/dev

3. **Audit Logging**
   - All AI actions logged
   - All deployments logged
   - User actions tracked

---

## Future Enhancements

1. **GitHub App Integration**
   - Auto-create PRs from QUAD UI
   - Link PRs to tickets automatically
   - Show PR status in ticket view

2. **Slack Notifications**
   - PR created
   - CI passed/failed
   - Deploy completed

3. **Rollback Support**
   - One-click rollback to previous version
   - Auto-rollback on smoke test failure

4. **Environment Promotion**
   - dev → staging → production
   - Approval gates at each stage

---

**Last Updated**: January 2, 2026
**Author**: Claude Code
