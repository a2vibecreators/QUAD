# QUAD Platform - Phase 1 Workflow Documentation

## Overview

This document describes the complete workflow for QUAD Platform Phase 1, including agent architecture, approval flows, and realistic scenarios.

---

## 1. Agent Architecture: Narrow-Purpose Agents

### Philosophy: One Agent = One Purpose

To minimize hallucinations and improve accuracy, QUAD uses **narrow-purpose agents** instead of one general-purpose agent.

| Agent ID | Name | Purpose | Confidence Target |
|----------|------|---------|-------------------|
| `BA_ANALYZER` | BA Analyzer | Parse requirements → milestones → tickets | 85%+ |
| `PLAN_GENERATOR` | Plan Generator | Create implementation plan from ticket | 90%+ |
| `CODE_IMPLEMENTER` | Code Implementer | Write code based on plan | 85%+ |
| `CODE_REVIEWER` | Code Reviewer | Review PR for issues | 90%+ |
| `DOC_GENERATOR` | Doc Generator | Generate documentation | 95%+ |
| `TEST_GENERATOR` | Test Generator | Write test cases | 85%+ |
| `DEPLOY_EXECUTOR` | Deploy Executor | Execute deployment recipe | 95%+ |
| `TRANSCRIPT_PROCESSOR` | Transcript Processor | Extract action items from meeting | 80%+ |
| `DB_OPERATOR` | Database Operator | Execute database operations | 95%+ |
| `RAG_RESPONDER` | RAG Responder | Answer questions from codebase | 80%+ |

### Human Review Rules (Phase 1)

**Phase 1 Rule: ALWAYS HUMAN REVIEW before any execution**

```
┌─────────────────────────────────────────────────────────────┐
│                    PHASE 1 APPROVAL MATRIX                  │
├─────────────────────────────────────────────────────────────┤
│  Confidence ≥ 90%  → Show "Recommended" + User Review       │
│  Confidence 70-89% → Show "Review Carefully" + User Review  │
│  Confidence < 70%  → Show "Low Confidence" + User Review    │
│                                                             │
│  ALL require explicit user approval before execution        │
└─────────────────────────────────────────────────────────────┘
```

**Phase 2 (Future):**
- Confidence ≥ 95% → Auto-execute with notification
- Confidence 90-94% → User review
- Confidence < 90% → Mandatory detailed review

---

## 2. Meeting Transcript → Task Flow

### Scenario

Meeting transcript contains: *"Please create a new ticket to follow up with Chandra and get back to me by Friday"*

### Complete Flow

```
┌─────────────────────────────────────────────────────────────┐
│  MEETING TRANSCRIPT PROCESSING FLOW                         │
└─────────────────────────────────────────────────────────────┘

Step 1: Meeting Recording
├── Otter.ai/Fireflies transcribes meeting
├── User uploads transcript OR auto-sync via API
└── Status: transcript_uploaded

Step 2: AI Processing (TRANSCRIPT_PROCESSOR Agent)
├── AI extracts action items:
│   └── "Follow up with Chandra, due: Friday, assignee: [speaker]"
├── AI confidence: 85%
├── Creates QUAD_meeting_action_items records
└── Status: ai_processed

Step 3: User Review (ALWAYS in Phase 1)
├── Action items shown on Home Screen:
│   ┌─────────────────────────────────────────────────┐
│   │  📋 TODAY'S TASKS                               │
│   │  ─────────────────────────────────────────────  │
│   │  □ Follow up with Chandra          Due: Fri    │
│   │    AI Confidence: 85%                          │
│   │    [✓ Approve] [✎ Edit] [✗ Reject]            │
│   │                                                 │
│   │  📅 THIS WEEK                                   │
│   │  □ Review PR #45                   Due: Wed    │
│   │  □ Update API documentation        Due: Thu    │
│   └─────────────────────────────────────────────────┘
└── User clicks [✓ Approve] or [✎ Edit] to modify

Step 4: Task Execution Options
├── Option A: API-Executable Task
│   └── "Execute" button calls API (e.g., send email, create ticket)
│
├── Option B: Manual Task (Phone call, Meeting)
│   └── User does task manually → clicks "Mark Complete"
│   └── User adds notes: "Chandra confirmed delivery by Monday"
│
└── Option C: Convert to Ticket
    └── "Create Ticket" button → Opens ticket form pre-filled
    └── Ticket goes into backlog or sprint

Step 5: Follow-up Actions
├── If task updates ticket → User can invoke DEV_AGENT
├── If task is standalone → Mark complete, move to next
└── All actions logged in QUAD_meeting_action_items
```

### Home Screen Task Display

```
┌─────────────────────────────────────────────────────────────┐
│  🏠 HOME - [Project Name]                                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📋 MY TASKS TODAY (3)                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ □ Follow up with Chandra                    Due: Fri│   │
│  │   From: Sprint Planning Meeting                     │   │
│  │   [Execute] [Mark Done] [Convert to Ticket]         │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ □ PROJ-45: Fix login timeout bug           In Prog  │   │
│  │   Sprint 3 | Story Points: 3                        │   │
│  │   [Open Ticket] [Start Dev Agent]                   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ □ Review PR #123                           Pending  │   │
│  │   Branch: feature/user-auth                         │   │
│  │   [Review in GitHub] [AI Review]                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📅 UPCOMING THIS WEEK (5)                                  │
│  • Wed: API documentation update                           │
│  • Thu: Demo preparation                                   │
│  • Fri: Sprint retrospective                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Ticket → Development Agent Flow

### When User Picks a Ticket

```
┌─────────────────────────────────────────────────────────────┐
│  TICKET TO CODE FLOW                                        │
└─────────────────────────────────────────────────────────────┘

Step 1: User Opens Ticket
├── Sees ticket details, acceptance criteria
├── Clicks "Start Development" or "Invoke Dev Agent"
└── Status: in_progress

Step 2: PLAN_GENERATOR Agent
├── Analyzes ticket + codebase context
├── Generates implementation plan:
│   ┌─────────────────────────────────────────────────┐
│   │  IMPLEMENTATION PLAN                            │
│   │  ─────────────────────────────────────────────  │
│   │  1. Modify src/auth/login.ts (lines 45-67)     │
│   │  2. Add new function validateSession()          │
│   │  3. Update src/middleware/auth.ts               │
│   │  4. Add test in tests/auth.test.ts              │
│   │                                                 │
│   │  AI Confidence: 88%                            │
│   │  Estimated: 2.5 hours                          │
│   │                                                 │
│   │  [✓ Approve Plan] [✎ Modify] [✗ Reject]       │
│   └─────────────────────────────────────────────────┘
└── User reviews and approves plan

Step 3: CODE_IMPLEMENTER Agent
├── Generates code based on approved plan
├── Shows diff preview:
│   ┌─────────────────────────────────────────────────┐
│   │  CHANGES PREVIEW                                │
│   │  ─────────────────────────────────────────────  │
│   │  📁 src/auth/login.ts                          │
│   │  - const timeout = 3600;                       │
│   │  + const timeout = getConfiguredTimeout();     │
│   │  + function getConfiguredTimeout() { ... }     │
│   │                                                 │
│   │  📁 src/middleware/auth.ts                     │
│   │  + import { validateSession } from './login';  │
│   │                                                 │
│   │  AI Confidence: 85%                            │
│   │  [✓ Create PR] [✎ Modify] [✗ Reject]          │
│   └─────────────────────────────────────────────────┘
└── User reviews code changes

Step 4: Create Pull Request
├── AI creates branch: feature/PROJ-45-fix-login-timeout
├── AI commits code changes
├── AI creates PR with description
├── PR linked to ticket
└── Status: in_review

Step 5: CODE_REVIEWER Agent (Optional)
├── AI reviews the PR
├── Flags potential issues
├── Adds review comments
└── Human reviewer makes final decision

Step 6: Merge & Deploy
├── After approval, PR merged
├── If auto-deploy enabled → DEPLOY_EXECUTOR triggers
├── If manual → User triggers deployment
└── Ticket status: done
```

---

## 4. Database Copy Approval Flow

### The Problem

Dev needs QA database refreshed with PROD-like data, but:
- QA Lead is actively testing
- Another dev has tickets in QA testing phase
- Copy would destroy their test data

### Complete Approval Flow

```
┌─────────────────────────────────────────────────────────────┐
│  DATABASE COPY APPROVAL FLOW                                │
└─────────────────────────────────────────────────────────────┘

Step 1: Request Initiation
├── Dev clicks "Request Data Copy"
├── Selects: Source=PROD, Target=QA
├── Options:
│   ├── □ All tables
│   ├── □ Selected tables (choose...)
│   └── ☑ Anonymize PII data
└── System creates QUAD_database_operations record

Step 2: Automatic Stakeholder Detection
├── System checks:
│   ├── Who is Database Lead for this project? → John (DB_LEAD)
│   ├── Who has active tickets in QA testing?
│   │   └── Sarah (PROJ-78), Mike (PROJ-92)
│   └── Who is assigned as QA Lead? → Lisa (QA_LEAD)
└── Creates approval requests for all stakeholders

Step 3: Notification Distribution
┌────────────────────────────────────────────────────────────┐
│  📧 EMAIL TO: John (DB Lead)                               │
│  ────────────────────────────────────────────────────────  │
│  Subject: [QUAD] Database Copy Request - Approval Needed   │
│                                                            │
│  Dev (Alex) has requested a database copy:                 │
│  • Source: PROD → Target: QA                               │
│  • Tables: All                                             │
│  • Anonymize PII: Yes                                      │
│                                                            │
│  ⚠️ WARNING: Active tickets in QA:                         │
│  • PROJ-78 (Sarah) - In Testing                           │
│  • PROJ-92 (Mike) - In Testing                            │
│                                                            │
│  [Approve] [Reject] [View Details]                         │
│                                                            │
│  Link: https://quad.company.com/approvals/abc123           │
└────────────────────────────────────────────────────────────┘

Step 4: In-App Approval Queue
├── All stakeholders see in their notification center:
│   ┌─────────────────────────────────────────────────┐
│   │  🔔 PENDING APPROVALS (1)                       │
│   │  ─────────────────────────────────────────────  │
│   │  Database Copy: PROD → QA                       │
│   │  Requested by: Alex                             │
│   │  Your role: DB Lead                             │
│   │                                                 │
│   │  Other approvers:                               │
│   │  ✓ Sarah (affected) - Approved                 │
│   │  ⏳ Mike (affected) - Pending                   │
│   │  ⏳ Lisa (QA Lead) - Pending                    │
│   │                                                 │
│   │  [✓ Approve] [✗ Reject with reason]            │
│   └─────────────────────────────────────────────────┘
└── Click email link → Opens app → Approval page

Step 5: Approval Collection
├── Order of approval:
│   1. DB Lead approves first (required)
│   2. Affected users (Sarah, Mike) approve
│   3. QA Lead approves last
├── Any rejection → Request cancelled with reason
└── All approved → Status: approved

Step 6: Execution by Requester
├── Alex (original requester) gets notification:
│   "All approvals received. Ready to execute."
├── Alex clicks "Execute Data Copy"
├── DB_OPERATOR Agent:
│   ├── Knows source (PROD) and target (QA)
│   ├── Knows which tables
│   ├── Executes anonymization rules
│   └── Copies data
└── Status: completed

Step 7: Post-Copy Notification
├── All stakeholders notified: "QA database refreshed"
├── Copy log available for audit
└── Sarah/Mike can resume testing (might need re-setup)
```

### Approval Status Matrix

| Stakeholder | Role | Required | Can Block |
|-------------|------|----------|-----------|
| DB Lead | Database owner | ✅ Yes | ✅ Yes |
| Affected Users | Has active tickets | ✅ Yes | ✅ Yes |
| QA Lead | Environment owner | ✅ Yes | ✅ Yes |
| Project Lead | Oversight | ❌ Optional | ✅ Yes |

---

## 5. Documentation Templates (Startup vs Enterprise)

### Startup Tier: Pre-built Templates

Startups get **6 predefined documentation templates**:

| Template | File | Auto-Generated |
|----------|------|----------------|
| README | `README.md` | ✅ Yes |
| Architecture | `docs/ARCHITECTURE.md` | ✅ Yes |
| API Reference | `docs/API.md` | ✅ Yes |
| Setup Guide | `docs/SETUP.md` | ✅ Yes |
| Testing Guide | `docs/TESTING.md` | ✅ Yes |
| Deployment | `docs/DEPLOYMENT.md` | ✅ Yes |

**How it works:**
```
1. AI analyzes codebase structure
2. AI generates documentation from code + comments
3. User reviews and approves
4. Docs committed to repo in /docs folder
5. Updated on each release (with user approval)
```

### Enterprise Tier: Custom Templates (Phase 2+)

Enterprises can:
- Define custom documentation templates
- Add compliance-specific sections
- Integrate with Confluence/SharePoint
- Custom approval workflows

---

## 6. Scenarios: Worst to Realistic

### Scenario Matrix

| Scenario | Type | Outcome | Mitigation |
|----------|------|---------|------------|
| AI misinterprets requirement | Worst | Wrong feature built | Human review at every step |
| AI confidence 60% | Bad | Low quality code | Mandatory detailed review |
| DB copy during active testing | Bad | Data loss | Multi-stakeholder approval |
| Meeting transcript unclear | Common | Wrong action items | User can edit/reject |
| AI suggests wrong files | Common | Wasted time | User reviews plan first |
| Deploy fails | Common | Rollback needed | Recipe includes rollback |
| AI confidence 95% | Best | Fast delivery | Still human review (Phase 1) |

### Detailed Scenarios

#### WORST CASE: AI Completely Misunderstands

```
Scenario: BA uploads requirement "Add dark mode to settings page"
AI interprets: "Delete mode settings from page"

Flow:
1. BA_ANALYZER creates milestone: "Remove settings mode"
   - Confidence: 72% (flagged as low)
   - UI shows: ⚠️ "Low Confidence - Review Carefully"

2. BA reviews and catches error
   - Clicks "Reject" with reason
   - Manually creates correct milestone

3. AI learns nothing (Phase 1 - no feedback loop)
   - Phase 2: AI feedback improves model

Impact: 5 minutes of BA's time
Prevented: Wrong feature entirely
```

#### BAD CASE: Database Copy Conflict

```
Scenario: Alex requests PROD→QA copy
Sarah has been testing for 3 hours, test data not saved
Mike has 2 tickets in QA testing phase

Flow:
1. System detects Sarah and Mike have active work
2. Both receive urgent notification
3. Sarah: "Reject - I need 2 more hours to complete testing"
4. Alex sees rejection with reason
5. Alex waits 2 hours, re-requests
6. All approve, copy executes

Impact: 2 hour delay (vs data loss)
Prevented: Sarah loses 3 hours of work
```

#### COMMON CASE: Unclear Meeting Transcript

```
Scenario: Transcript says "John will handle the thing we discussed"

Flow:
1. TRANSCRIPT_PROCESSOR extracts:
   - Action: "Handle discussed item"
   - Assignee: John
   - Due: Not specified
   - Confidence: 45%

2. Display shows:
   ┌─────────────────────────────────────────────────┐
   │  ⚠️ LOW CONFIDENCE ACTION ITEM                  │
   │  ─────────────────────────────────────────────  │
   │  Task: "Handle discussed item"                  │
   │  Assignee: John                                 │
   │  Due: Not specified                             │
   │  Confidence: 45%                                │
   │                                                 │
   │  [✎ Edit] [✗ Reject] [? What was discussed?]  │
   └─────────────────────────────────────────────────┘

3. John clicks [✎ Edit], updates:
   - Task: "Set up AWS S3 bucket for file uploads"
   - Due: Thursday

Impact: 30 seconds to edit
Prevented: Vague task sitting forever
```

#### REALISTIC CASE: Normal Development Flow

```
Scenario: Ticket PROJ-123 "Add email validation to signup form"

Flow:
1. Dev picks ticket, clicks "Start Dev Agent"

2. PLAN_GENERATOR output (Confidence: 91%):
   - Modify src/components/SignupForm.tsx
   - Add email regex validation
   - Show error message if invalid
   - Add test case

3. Dev reviews plan: "Looks good" → Approves

4. CODE_IMPLEMENTER output (Confidence: 88%):
   - Shows diff: 15 lines added
   - Clean implementation

5. Dev reviews code: Minor tweak needed
   - Edits error message text
   - Approves

6. PR created, linked to ticket
7. CODE_REVIEWER flags: "Consider debouncing validation"
8. Dev adds debounce, updates PR
9. PR approved by team lead
10. Merged to dev, auto-deployed to DEV environment

Total time: 25 minutes (vs 2 hours manual)
Quality: Same or better (AI + human review)
```

#### BEST CASE: High Confidence Fast Track

```
Scenario: Ticket "Update copyright year in footer from 2024 to 2025"

Flow:
1. Dev picks ticket, clicks "Start Dev Agent"

2. PLAN_GENERATOR output (Confidence: 99%):
   - Modify src/components/Footer.tsx line 42
   - Change "2024" to "2025"

3. CODE_IMPLEMENTER output (Confidence: 99%):
   - Single line change
   - Diff clearly shows year change

4. Dev reviews: "Perfect" → Approves in 10 seconds

5. PR created, auto-approved (simple change policy)
6. Merged and deployed

Total time: 2 minutes
```

---

## 7. Notification Channels

### Channel Configuration

| Channel | Startup | Enterprise | User Override |
|---------|---------|------------|---------------|
| In-App | ✅ Always | ✅ Always | Cannot disable |
| Email | ✅ Default On | ✅ Default On | Can disable |
| Slack | ❌ Not included | ✅ Optional | Can disable |
| Mobile Push | ✅ Default On | ✅ Default On | Can disable |
| SMS | ❌ Not included | ✅ Optional | Can disable |

### Notification Types

| Type | Urgency | Default Channels |
|------|---------|------------------|
| Approval Needed | High | In-App + Email + Push |
| Ticket Assigned | Medium | In-App + Email |
| PR Review | Medium | In-App + Email |
| Deployment Complete | Low | In-App |
| Daily Digest | Low | Email only |

### User Preference Example

```typescript
// QUAD_notification_preferences
{
  user_id: "uuid",
  email_enabled: true,
  in_app_enabled: true,      // Cannot be false
  slack_enabled: false,
  mobile_push_enabled: true,
  type_preferences: {
    "approval_needed": true,  // Always true for approvals
    "ticket_assigned": true,
    "pr_review": true,
    "deployment": false,      // User disabled
    "mention": true
  },
  quiet_hours_enabled: true,
  quiet_start_time: "22:00",
  quiet_end_time: "08:00",
  timezone: "America/New_York"
}
```

---

## 8. Environment Configuration (Phase 1)

### Default Environments

| Environment | Auto-Deploy | Requires Approval | Purpose |
|-------------|-------------|-------------------|---------|
| DEV | ✅ Yes (on PR merge) | ❌ No | Developer testing |
| QA | ❌ No | ✅ Yes (BA/PM) | QA testing |
| PROD | ❌ No (provide steps only) | N/A | Production |

### Phase 1 Limitation

**PROD deployment in Phase 1:**
- QUAD does NOT auto-deploy to PROD
- QUAD provides deployment steps/recipe
- User executes manually or via their own CI/CD
- This reduces risk and liability

**Phase 2 (Future):**
- Optional PROD deployment with multi-approval
- Requires: Tech Lead + QA Lead + Product Owner approval
- Full audit trail

---

## 9. Integration Summary

### Phase 1 Integrations

| Integration | Purpose | Cost to User | Cost to QUAD |
|-------------|---------|--------------|--------------|
| GitHub | Git operations | Free (user's account) | Free |
| Google Meet | Video calls | Free (user's Workspace) | Free |
| Google Calendar | Scheduling | Free (user's Workspace) | Free |
| Otter.ai | Transcription | Free tier (user's account) | Free |
| Cal.com | Scheduling alt | Free tier available | Free |
| Claude API | AI operations | Included in subscription | $3k-8k/mo |

### User-Owned vs QUAD-Owned

```
USER PROVIDES (connects via OAuth):
├── GitHub account
├── Google Workspace (Calendar, Meet)
├── Otter.ai account (optional)
├── Cloud platform credentials (GCP/AWS)
└── Slack workspace (Enterprise only)

QUAD PROVIDES:
├── Claude/AI API access
├── Database for QUAD platform
├── In-app notifications
├── Email notifications (via our SendGrid/SES)
└── Mobile push notifications
```

---

## 10. Data Model Summary (21 New Tables)

### Phase 1 Tables Added

| Category | Tables | Purpose |
|----------|--------|---------|
| Requirements | QUAD_requirements, QUAD_milestones | BA workflow |
| Sprints/Tickets | QUAD_sprints, QUAD_tickets, QUAD_ticket_comments, QUAD_ticket_time_logs | Ticket management |
| Git | QUAD_git_repositories, QUAD_pull_requests, QUAD_git_operations | Git integration |
| Deployment | QUAD_environments, QUAD_deployment_recipes, QUAD_deployments | Deploy workflow |
| AI | QUAD_ai_operations | Track AI usage/cost |
| Notifications | QUAD_notifications, QUAD_notification_preferences | Notification system |
| Multi-Role | QUAD_user_role_allocations | 70% Dev / 30% QA |
| Approvals | QUAD_approvals | Multi-stakeholder approval |
| File Imports | QUAD_file_imports | Wireframes, docs |
| Meetings | QUAD_meetings, QUAD_meeting_action_items | Meeting integration |
| RAG | QUAD_rag_indexes | Codebase chatbot |
| Database | QUAD_database_operations | DB agent operations |

---

## Next Steps

1. **API Endpoints** - Define REST API for all operations
2. **UI Wireframes** - Design screens for each workflow
3. **Implementation Tickets** - Break into sprint-sized work items
4. **Competitor Research** - Validate pricing against Linear, Emergent, Shortcut

---

*Document Version: 1.0*
*Last Updated: January 2026*
*Author: QUAD Platform Team*
