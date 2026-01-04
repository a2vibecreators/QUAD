# QUAD Framework - Top 1 Tool Strategy

**Created:** January 4, 2026
**Philosophy:** Focus on ONE tool per category. Get the vision working. Adding more tools later is just configuration.

---

## The Strategy

```
"If we can get the TOP 1 tool in each category working,
 the whole vision is proven. Adding more tools is just explicit integration work."
```

**Why this works:**
- 80% of users use the #1 tool anyway
- Proves the architecture works end-to-end
- Adding tool #2, #3 is just API adapter work
- AI interaction is the hard part - tools are plumbing

---

## Integration Categories: Top 1 Pick

| Category | Top 1 Tool | Why | Phase |
|----------|------------|-----|-------|
| **Git/Source** | GitHub | 90%+ market share, best API | P1 |
| **CI/CD** | GitHub Actions | Free with GitHub, integrated | P1 |
| **IDE** | VS Code | 70%+ developers, free | P1 |
| **Messenger** | Slack | Enterprise standard | P2 |
| **AI Provider** | Claude (Sonnet) | Best for coding | P1 |
| **AI (Cheap)** | Gemini Flash | Cheap for Q&A | P1 |
| **Meeting** | Google Meet | Free, best transcription | P2 |
| **Cloud/Sandbox** | Docker + Cloud Run | Simple, scalable | P1 |
| **Documentation** | Markdown in Git | No extra tool needed | P1 |
| **Secrets** | Vault/1Password | Standard | P2 |

---

## Current QUAD Status vs Strategy

### What We Have (Database/Architecture)

| Component | Tables | Status | Notes |
|-----------|--------|--------|-------|
| Core (Orgs, Users) | 14 | ✅ Schema done | Ready for services |
| Tickets/Circles | 8 | ✅ Schema done | Need services |
| AI System | 19 | ✅ Schema done | Memory, credits, tracking |
| Git Integration | 6 | ✅ Schema done | GitHub focus |
| Messenger | 3 | ✅ Schema done | Slack first |
| Meetings | 4 | ✅ Schema done | P2 |
| Memory System | 8 | ✅ Schema done | RAG ready |
| Infrastructure | 9 | ✅ Schema done | Sandbox config |

**Total: 132 tables designed** - Architecture is solid.

### What We DON'T Have Yet

| Component | What's Missing | Priority |
|-----------|---------------|----------|
| **Backend Services** | Java Spring Boot APIs | P0 - CRITICAL |
| **VS Code Plugin** | The actual IDE integration | P1 |
| **GitHub Webhook** | Receive PR/commit events | P1 |
| **Sandbox Runner** | Execute code in containers | P1 |
| **Web Dashboard** | React/Next.js admin UI | P1 |

---

## Trigger Types (How QUAD Gets Activated)

QUAD can be triggered from ANYWHERE:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUAD TRIGGER SOURCES                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. WEB UI (Primary)                                                 │
│     └── User clicks "Create Ticket", "Start Work", etc.            │
│                                                                      │
│  2. MENTIONS (@QUAD)                                                 │
│     ├── Slack: "@QUAD create ticket for this bug"                   │
│     ├── Teams: "@QUAD what's the status?"                           │
│     ├── Email: "To: quad@company.com - Please review PR #123"       │
│     └── SMS: "@QUAD urgent - server down"                           │
│                                                                      │
│  3. MONITORING (Proactive)                                           │
│     ├── "Watch this email inbox, alert me if error detected"        │
│     ├── "Monitor this Slack channel for keywords"                   │
│     ├── "Watch GitHub for failed workflows"                         │
│     └── QUAD already knows context → can act autonomously           │
│                                                                      │
│  4. SCHEDULED                                                        │
│     ├── Daily standup summary                                        │
│     ├── Weekly sprint reports                                        │
│     └── Reminder: "Ticket stale for 3 days"                         │
│                                                                      │
│  5. WEBHOOKS                                                         │
│     ├── GitHub: PR created, merged, failed                          │
│     ├── CI/CD: Build failed                                          │
│     └── Third-party: Any webhook we configure                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Insight:** The trigger source doesn't matter. QUAD has the CONTEXT (ticket, domain, rules). It knows what to do.

---

## Recommended Next Steps (Phase 1 Focus)

### Priority: WEB FIRST (Not IDE)

**Why Web First:**
- Works on any device (phone, tablet, desktop)
- No installation required
- Easier to iterate
- IDE plugin can come later (just API calls)

### Step 1: Backend Services (Java Spring Boot)

**Priority: P0 - Without this, nothing works**

Create core services in `quad-services/`:

```
quad-services/
├── src/main/java/com/quad/
│   ├── core/           # Org, User, Auth services
│   ├── tickets/        # Ticket CRUD, assignment
│   ├── ai/             # AI orchestration, credits
│   ├── git/            # GitHub webhook handler
│   └── memory/         # Context retrieval
```

**Start with:**
1. `OrganizationService` - Create/manage orgs
2. `UserService` - Auth, sessions
3. `TicketService` - CRUD tickets
4. `AIOrchestrationService` - Route tasks to Claude/Gemini

### Step 2: GitHub Integration (Top 1 Git Tool)

**One webhook, one API:**

```
GitHub Webhook → QUAD Backend
    ↓
┌─────────────────────────────────┐
│ Events we care about:           │
│ • push → Index changed files    │
│ • pull_request → Create ticket? │
│ • issue → Sync with QUAD ticket │
│ • workflow_run → Track CI/CD    │
└─────────────────────────────────┘
```

**Don't worry about GitLab, Bitbucket yet** - just make GitHub work perfectly.

### Step 3: Web Dashboard (Primary Interface)

**Web-first approach - works everywhere:**

```
Next.js Web App (quad-web)
    ↓
┌─────────────────────────────────────────┐
│ Phase 1 Features:                        │
│ • Organization dashboard                 │
│ • Ticket list with filters               │
│ • "Start Work" → sandbox creation        │
│ • AI chat panel (context-aware)          │
│ • Create/edit tickets                    │
│ • View AI usage and credits              │
│                                          │
│ Phase 2 Features:                        │
│ • @QUAD mention handling UI              │
│ • Monitoring configuration               │
│ • Analytics dashboards                   │
│ • Integration settings                   │
└─────────────────────────────────────────┘
```

**Why Web First:** Works on any device, no installation, easier to iterate.

### Step 4: AI Integration (Claude + Gemini)

**Two providers, clear routing:**

```
┌─────────────────────────────────────────┐
│ Task Type → Provider                     │
├─────────────────────────────────────────┤
│ Ticket work (code gen)    → Claude       │
│ Code review               → Claude       │
│ Questions/chat            → Gemini Flash │
│ Meeting summary           → Gemini Flash │
│ Simple lookups            → Gemini Flash │
└─────────────────────────────────────────┘
```

**Don't worry about OpenAI, AWS Bedrock yet** - just make Claude + Gemini work.

### Step 5: Sandbox (Docker + Cloud Run)

**One sandbox approach:**

```
Developer clicks "Start Work"
    ↓
QUAD creates sandbox:
    - Docker container
    - Repo cloned
    - Branch created
    - IDE connected (via VS Code Remote)
    ↓
Developer works in isolated environment
    ↓
QUAD tracks time, AI usage, files changed
```

---

## Phase 2: Enhanced Features

### VS Code Plugin (Phase 2)

**Key Architecture: VS Code calls QUAD, NOT Claude directly**

```
┌──────────────────────────────────────────────────────────────┐
│                    VS CODE PLUGIN                             │
│                                                               │
│  ❌ WRONG: VS Code → Claude API directly                     │
│  ✅ RIGHT: VS Code → QUAD Backend → Claude/Gemini            │
│                                                               │
│  Why?                                                         │
│  • QUAD has the context (ticket, rules, memory)              │
│  • QUAD tracks AI credits                                     │
│  • QUAD can route to different providers                      │
│  • VS Code is just a thin client                              │
└──────────────────────────────────────────────────────────────┘
```

**VS Code Menu Commands (One-Click Actions):**

```
┌──────────────────────────────────────────────────────────────┐
│  QUAD Menu (VS Code Command Palette / Right-click)           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  📋 My Tickets                                                │
│     └── Shows list of assigned tickets                       │
│                                                               │
│  ▶️  QUAD-123: Start                                          │
│     └── One click → QUAD executes required steps             │
│         (Steps are defined in QUAD rules/templates)          │
│         User just sees: "Ready to work on QUAD-123"          │
│                                                               │
│  📝 QUAD-123: Show Changes                                    │
│     └── "Here's what QUAD has done:"                         │
│         • Files modified: 3                                   │
│         • Tests added: 2                                      │
│         • Last suggestion: "Added error handling..."         │
│                                                               │
│  💬 QUAD-123: Ask                                             │
│     └── Opens AI chat (context of this ticket)               │
│                                                               │
│  ✅ QUAD-123: Submit                                          │
│     └── One click → QUAD executes submit steps               │
│         (PR creation, reviewers - all from templates)        │
│                                                               │
│  🔄 Sync                                                      │
│     └── Pull latest from QUAD                                │
│                                                               │
└──────────────────────────────────────────────────────────────┘

Note: User just sees ticket number and action.
      QUAD knows the required steps (documented in templates).
      No need to show "checkout", "branch", etc.
```

**Sidebar Panel:**

```
┌─────────────────────────────────┐
│  QUAD                      [⚙️] │
├─────────────────────────────────┤
│  Current Ticket: QUAD-123       │
│  Status: In Progress            │
│  Branch: feature/QUAD-123       │
├─────────────────────────────────┤
│  📁 Files Changed (3)           │
│  ├── src/auth/login.ts          │
│  ├── src/auth/login.test.ts     │
│  └── src/utils/validate.ts      │
├─────────────────────────────────┤
│  🤖 QUAD Activity               │
│  • Added input validation       │
│  • Created unit tests           │
│  • Suggested error handling     │
├─────────────────────────────────┤
│  [ Start Work ] [ Submit PR ]   │
└─────────────────────────────────┘
```

**Implementation Phases:**

| Phase | Features |
|-------|----------|
| P2.1 | My Tickets list, Basic sidebar, Beautify docs |
| P2.2 | Start Work, Show Changes, Sync |
| P2.3 | Ask QUAD (AI chat), Submit PR |
| P2.4 | Full sandbox integration |

### Monitoring & Proactive Triggers (Phase 2)

```
┌──────────────────────────────────────────────────────────────┐
│                 QUAD MONITORING SYSTEM                        │
│                                                               │
│  User configures:                                             │
│  "Watch this email inbox for error keywords"                  │
│  "Monitor Slack #alerts channel"                              │
│  "Call me if GitHub workflow fails"                           │
│                                                               │
│  QUAD already has:                                            │
│  • Context of what "error" means for this project             │
│  • Rules for how to respond                                   │
│  • Knowledge of who to notify                                 │
│                                                               │
│  Flow:                                                        │
│  1. QUAD polls/receives events                                │
│  2. AI analyzes: "Is this an issue?"                          │
│  3. If yes → take configured action                           │
│     • Create ticket automatically                             │
│     • Notify team via Slack/Email/SMS                         │
│     • Call user (voice) for urgent issues                     │
└──────────────────────────────────────────────────────────────┘
```

---

## What We're NOT Doing in Phase 1

| Feature | Why Defer |
|---------|-----------|
| Teams/Discord/WhatsApp | Slack is #1, others can wait |
| GitLab/Bitbucket | GitHub is #1, others can wait |
| JetBrains/Vim | VS Code plugin uses QUAD API, same code works |
| OpenAI/AWS Bedrock | Claude + Gemini covers it |
| Zoom/Teams meetings | Google Meet is simplest |
| Complex analytics | Get core working first |
| Voice assistant | Cool but not essential for P1 |
| Mobile app | Web works on mobile |
| Monitoring/Proactive | P2 feature |

---

## Implementation Order

```
PHASE 1: Core Platform (8 weeks)
═══════════════════════════════

Week 1-2: Backend Core
├── Setup Spring Boot project (quad-services)
├── OrganizationService + tests
├── UserService + auth (JWT)
└── TicketService + basic CRUD

Week 3-4: Web Dashboard
├── Next.js setup (quad-web)
├── Auth pages (login, register)
├── Organization dashboard
├── Ticket list + create/edit
└── Connect to backend APIs

Week 5-6: AI Integration
├── AIOrchestrationService
├── Claude integration (coding tasks)
├── Gemini Flash integration (Q&A)
├── AI chat component in web
└── Credit tracking

Week 7-8: GitHub + Polish
├── GitHub webhook endpoint
├── PR/commit event handling
├── End-to-end flow testing
└── Deploy to production

═══════════════════════════════
PHASE 2: Extended Features (4+ weeks)
═══════════════════════════════

Week 9-10: VS Code Plugin
├── Extension scaffold
├── Call QUAD HTTP APIs
├── Beautify markdown docs
└── Ticket sidebar

Week 11-12: Sandbox + Monitoring
├── Docker sandbox creation
├── @QUAD mention handling
├── Basic monitoring setup
└── Proactive notifications
```

---

## Success Criteria (Phase 1 Complete)

A developer can:
1. ✅ Log into QUAD (web or VS Code)
2. ✅ See their assigned tickets
3. ✅ Click "Start Work" → sandbox spins up
4. ✅ Ask AI questions in context of ticket
5. ✅ AI generates code suggestions
6. ✅ Submit PR when done
7. ✅ GitHub Actions runs, QUAD tracks

**That's the vision, proven.** Everything else is adding more tools.

---

## Key Insight

```
The hard parts:
├── AI orchestration (structured, minimal tokens) ← WE DESIGNED THIS
├── Context management (memory system) ← WE DESIGNED THIS
├── Ticket→Branch→PR flow ← NEEDS IMPLEMENTATION
└── IDE integration (VS Code) ← NEEDS IMPLEMENTATION

The easy parts (just configuration):
├── Add GitLab support ← Same webhooks, different API
├── Add Teams support ← Same commands, different format
├── Add JetBrains ← Same APIs, different UI
└── Add more AI providers ← Same interface, different SDK
```

---

## Files to Create Next

| File | Purpose |
|------|---------|
| `quad-services/pom.xml` | Maven project setup |
| `quad-services/src/.../OrganizationService.java` | First service |
| `quad-vscode-plugin/package.json` | VS Code extension |
| `quad-vscode-plugin/src/extension.ts` | Entry point |

---

**Summary:** We have 132 tables designed. Architecture is solid. Now we need to BUILD the services that use them, starting with Backend → GitHub → VS Code → Sandbox.
