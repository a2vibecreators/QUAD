# QUAD Platform - Master Jargons & Terminology

**Purpose:** Single source of truth for all QUAD terminology to prevent naming conflicts and ensure consistent usage.
**Last Updated:** January 8, 2026

---

## Table of Contents

1. [Core QUAD Terms](#core-quad-terms)
2. [12 Proprietary Technologies™](#12-proprietary-technologies)
3. [AI Agents](#ai-agents)
4. [4 Circles](#4-circles)
5. [Cycle Events & Meetings](#cycle-events--meetings)
6. [QUAD Stages (Q-U-A-D)](#quad-stages-q-u-a-d)
7. [Work Items & Tracking](#work-items--tracking)
8. [Metrics & Measurements](#metrics--measurements)
9. [Gamification](#gamification)
10. [Organization Structure](#organization-structure)
11. [⚠️ NAMING CONFLICTS TO RESOLVE](#-naming-conflicts-to-resolve)

---

## Core QUAD Terms

| Term | Meaning | Context | Example |
|------|---------|---------|---------|
| **Cycle** | 4-week period of continuous work | Work rhythm | "Q1 2026 Sprint 1 = Jan 6-31" |
| **Flow** | Work item (replaces Story/Ticket/Task) | Work tracking | "Add authentication Flow" |
| **Stream** | Large initiative (replaces Epic) | Work grouping | "Platform Modernization Stream" |
| **Domain** | Project or product area (replaces Project) | Organization | "QUAD Platform Domain" |
| **Circle** | Functional team (replaces Team) | Organization | "Development Circle (5 people)" |
| **Canvas** | Board for Flow visualization (replaces Board) | Tracking | "Q-U-A-D Canvas for Q1" |
| **Complexity Points** | Estimation unit (replaces Story Points) | Estimation | "8 Complexity Points" |
| **Horizon** | Prioritized backlog (work ahead) | Planning | "Q2 2026 Horizon has 50 Flows" |
| **Refinement** | Breaking down & clarifying work | Process | "Refinement meeting on Fridays" |

---

## 12 Proprietary Technologies™

| Technology | Icon | Tagline | Description | What It Does |
|------------|------|---------|-------------|--------------|
| **QUAD FLOW™** | 🔄 | Core Workflow | Q → U → A → D methodology | Powers the entire QUAD development process |
| **QUAD FLUX™** | ⚡ | AI Routing & Distribution | Smart multi-provider routing + batch/realtime modes | Routes tasks to Anthropic/Google/other AI models intelligently, switches between real-time (<5s) and batch (5m-hours) modes for cost optimization |
| **QUAD ORBIT™** | 🌐 | Cloud Deploy | Multi-cloud, zero lock-in | Deploys to AWS/GCP/Azure without vendor lock-in |
| **QUAD GATE™** | 🚦 | Human Gates | AI suggests, humans decide | Human approval gates at each QUAD stage |
| **QUAD SYNC™** | 🔗 | Integrations | Jira, GitHub, Messenger sync | Syncs work across tools (not yet live) |
| **QUAD MONITOR™** | 📡 | Real-time Monitoring | System health & performance tracking | Monitors API response times, database queries, error rates, deployments in real-time with anomaly detection |
| **QUAD FORGE™** | 🔥 | Data Generation | Test data on the fly | Generates realistic test data for testing |
| **QUAD SPARK™** | ✨ | Code Generation | AI-powered code from specs | Generates production code from specifications |
| **QUAD MIRROR™** | 🪞 | Environment Clone | Prod to dev with masked PII | Clones production environment to dev with data masking |
| **QUAD LENS™** | 🔍 | Right-Sized Solutions | Simplest effective architecture | Recommends simplest effective solution (no over-engineering) |
| **QUAD ATLAS™** | 🗺️ | Knowledge Platform | Unified docs, code, and context | Complete knowledge system: document search, code repository search, customer support chatbot, context injection for AI prompts |
| **QUAD BEACON™** | 🔔 | Alert Broadcasting | Call people when things happen | Broadcasts alerts to team members via calls, SMS, and notifications for deployments, errors, incidents, and critical events |

---

## AI Agents

### QUAD Server Agents (Service-Account, Org-Level)

| Agent | Icon | Type | Description | Variations |
|-------|------|------|-------------|-----------|
| **Email Agent** | 📧 | Server | Creates tickets from emails | Server only |
| **Messenger Agent** | 💬 | Server | Responds to @quad mentions | Server only |
| **Code Agent** | 💻 | Both | Generates production code | Server (org-wide) + Local (dev machine) |
| **Review Agent** | 🔍 | Both | Reviews PRs for issues | Server (all PRs) + Local (before commit) |
| **Test Agent** | 🧪 | Both | Writes unit & E2E tests | Server (CI/CD) + Local (dev machine via MCP) |
| **Deploy Agent** | 🚀 | Both | Handles CI/CD pipelines | Server (prod) + Local (staging) |
| **Cost Agent** | 💰 | Server | Optimizes cloud spend | Server only |
| **Training Agent** | 📚 | Server | Matches skills to courses | Server only |
| **Priority Agent** | 🎯 | Server | Learns PM patterns | Server only |
| **Analytics Agent** | 📊 | Server | Tracks performance | Server only |
| **Document Agent** | 📄 | Server | Generates & updates docs | Server only |
| **Meeting Agent** | 📅 | Server | Schedules & takes notes | Server only |
| **Infrastructure Agent** | 🔧 | Server | Monitors performance & health | Server only |
| **Production Agent** | 🌍 | Server | Manages releases & rollouts | Server only |

### QUAD Local Agent (User-Authenticated, Client-Side)

| Agent | Icon | Type | Description | Auth Method |
|-------|------|------|-------------|-------------|
| **Developer Agent** | 👨‍💻 | Local | Runs on dev machine | SSH, OAuth Token, or MCP |

---

## 4 Circles

| Circle | Icon | Members | Focus | Responsibilities |
|--------|------|---------|-------|------------------|
| **Circle 1** | 👔 | 1-2 | Management | Planning, prioritization, stakeholder comms |
| **Circle 2** | 💻 | 3-5 | Development | Code generation, architecture, reviews |
| **Circle 3** | 🧪 | 1-2 | QA | Testing, quality, bug tracking |
| **Circle 4** | 🔧 | 1-2 | Infrastructure | Deployments, monitoring, databases |

---

## Cycle Events & Meetings

| Event | Icon | Frequency | Duration | Purpose | Participants | When |
|-------|------|-----------|----------|---------|--------------|------|
| **Trajectory** | 📍 | Monthly | 1-2 hours | Set priorities for next cycle | Circle 1 (+ team input) | Start of cycle |
| **Pulse** | 📡 | Weekly (optional) | 5-15 min | Quick sync, blockers, dashboard review | Whole team | During cycle |
| **Checkpoint** | 🎯 | Monthly | 1 hour | Demo to stakeholders, release decision | All circles + stakeholders | Mid/End cycle |
| **Calibration** | 🔄 | Monthly | 30-60 min | Retrospective, agent learning review | All circles | End of cycle |

---

## QUAD Stages (Q-U-A-D)

| Stage | Letter | Name | Meaning | Description | Questions |
|-------|--------|------|---------|-------------|-----------|
| **Q Stage** | Q | Question | Define the problem | What needs to be done? | "Is this worth doing?" |
| **U Stage** | U | Understand | Analyze & plan | How should we do it? | "Do we understand the work?" |
| **A Stage** | A | Allocate | Assign & schedule | Who will do it? When? | "Are we ready to build?" |
| **D Stage** | D | Deliver | Execute & deploy | Ship it | "Is it done and live?" |

---

## Work Items & Tracking

| Legacy Term | QUAD Term | Plural | Example | Context |
|-------------|-----------|--------|---------|---------|
| Story | Flow | Flows | "Add OAuth login" | Individual work item |
| Ticket | Flow | Flows | "Fix login bug" | Individual work item |
| Task | Flow | Flows | "Review PR #234" | Individual work item |
| Epic | Stream | Streams | "Platform Modernization" | Large initiative |
| Sprint | Cycle | Cycles | "Q1 2026 Cycle 1" | 4-week work period |
| Board | Canvas | Canvases | "Q-U-A-D Canvas" | Visual workflow |
| Backlog | Horizon | Horizons | "Q2 Horizon" | Prioritized work queue |

---

## Metrics & Measurements

| Metric | QUAD Name | What It Measures | Unit |
|--------|-----------|------------------|------|
| Story Points | Complexity Points | Work size & complexity | Points |
| Velocity | Velocity Vector | Speed of delivery | Points/Cycle |
| Burndown | Trajectory Chart | Work remaining | Points over time |
| DORA Metrics | Velocity Vectors | Deployment speed/frequency | Deployments/frequency |
| Technical Debt | Code Topology | Health of codebase | Score |

---

## Gamification

| Element | QUAD Name | Plural | Purpose |
|---------|-----------|--------|---------|
| Leaderboard | Mastery Board | Mastery Boards | Track skill growth |
| Points | Mastery Points | Mastery Points | Reward contributions |
| Badge | Mastery Badge | Mastery Badges | Recognize achievements |
| Ranking | Mastery Ranking | Mastery Rankings | Show skill levels |

---

## Organization Structure

| Level | Entity | Description | Example |
|-------|--------|-------------|---------|
| **Level 1** | Organization | Company | "QUAD Platform Inc" |
| **Level 2** | Domain | Product/Project | "QUAD Framework (Website)" |
| **Level 3** | Circle | Functional Team | "Development Circle (5 devs)" |
| **Level 4** | Operator | Individual Contributor | "Alice (Full-Stack Developer)" |

---

## ✅ NAMING CONFLICTS (RESOLVED)

### **CONFLICT 1: "PULSE" (RESOLVED Jan 8, 2026)**

**Problem:** Two different meanings causing confusion

```
Definition 1 (Cycle Events):
  PULSE = Weekly standup/sync meeting (5-15 min)
  Purpose: Quick sync, blockers, dashboard review
  Location: /jargons/page.tsx line 27, 45

Definition 2 (Proprietary Technology - RESOLVED):
  QUAD PULSE™ → QUAD MONITOR™ (renamed)
  Purpose: Real-time monitoring system
  Purpose: Monitor API health, error rates, metrics, deployments
  Location: Pitch page (Slide 7)
```

**Resolution (Applied):**

| Use Case | Before | After | Status |
|----------|--------|-------|--------|
| Weekly meeting | "Pulse" | "Pulse" | ✅ Unchanged (clear context) |
| Monitoring tech | "QUAD PULSE™" | **"QUAD MONITOR™"** | ✅ **Resolved** |

**Why MONITOR™ works:**
- Clear naming (monitoring = real-time health checks, performance tracking, anomaly detection)
- No conflict with standup meeting "Pulse"
- Aligns with use case (Infrastructure Agent monitors, Production Agent orchestrates)
- Matches Cycle Events terminology (Trajectory, Pulse, Checkpoint, Calibration remain unchanged)

---

### **CONFLICT 2: "CHECKPOINT" (Low Priority)**

| Entity | Current | Issue |
|--------|---------|-------|
| Cycle Event | Checkpoint (monthly demo) | Clear usage |
| Not conflicting yet | N/A | No tech with this name |

**Status:** ✅ No conflict

---

### **CONFLICT 3: "FLOW" (Low Priority)**

| Entity | Current | Issue |
|--------|---------|-------|
| Work Item | Flow (story/ticket) | Clear usage |
| Tech Name | QUAD FLOW™ | Clear usage (process, not item) |

**Status:** ✅ No conflict (context makes it clear)

---

## Recommendations

### ✅ Completed Actions:

1. **✅ Resolved PULSE Naming Conflict**
   - ✅ QUAD PULSE™ renamed to **QUAD MONITOR™** (Jan 8, 2026)
   - ✅ Weekly standup remains "Pulse" (clear context, no conflict)
   - ✅ No impact on Cycle Events (Trajectory, Pulse, Checkpoint, Calibration)

2. **✅ Added QUAD ATLAS™ & QUAD BEACON™**
   - ✅ QUAD ATLAS™ = Complete knowledge platform (docs, code search, chatbot, context injection)
   - ✅ QUAD BEACON™ = Alert broadcasting system (calls, SMS, notifications)
   - ✅ Total: 12 proprietary technologies (expanded from 10)

3. **✅ Expanded QUAD FLUX™**
   - ✅ Now handles batch vs realtime distribution (not just routing)
   - ✅ Switches between real-time (<5s) and batch (5m-hours) modes
   - ✅ Optimizes costs by using off-peak resources for batch processing

### Next Actions (Implement):

1. **Update `quad-terminology.ts`**
   - Add all 12 tech names (currently has FLOW_ACCELERATORS)
   - Export QUAD MONITOR™ instead of old PULSE references
   - Add ATLAS™ and SAGE™ definitions

2. **Update Pitch Page**
   - Confirm grid layout reflects all 12 technologies
   - Verify QUAD MONITOR™ (not PULSE™) displays
   - Update agent count display if needed

3. **Communication:**
   - Brief team on 12 proprietary technologies
   - Define which are "available now" vs "coming soon" (Q2 2026)
   - Emphasize ATLAS™ as knowledge backbone for all systems

### For User/Creator Reference:

When creating new terminology, check:
- Is it unique? (No overlap with existing terms)
- Is it memorable? (QUAD FLOW™ is catchy)
- Is it clear? (From name alone, what does it do?)
- Does it fit QUAD's AI/tech vibe?

---

## Quick Lookup Table (By Category)

### Events (When Things Happen) ✅
- Trajectory (monthly planning)
- Pulse (weekly sync) ✅ No conflict
- Checkpoint (monthly demo)
- Calibration (monthly retro)

### Processes (How We Work)
- QUAD FLOW™ (Q→U→A→D core workflow)
- Refinement (break down work)
- Release (deployment via QUAD GATE™)

### Teams (Who Does Work)
- Circle 1 (Management)
- Circle 2 (Development)
- Circle 3 (QA)
- Circle 4 (Infrastructure)

### 12 Proprietary Technologies™ (All Systems)
| Category | Technology | What It Does |
|----------|-----------|--------------|
| **Core** | QUAD FLOW™ | Q→U→A→D methodology |
| **Routing** | QUAD FLUX™ | AI routing + batch/realtime modes |
| **Deployment** | QUAD ORBIT™ | Multi-cloud deployment |
| **Governance** | QUAD GATE™ | Human approval gates |
| **Integration** | QUAD SYNC™ | Tool sync (Jira, GitHub, Slack) |
| **Monitoring** | QUAD MONITOR™ | Real-time health & metrics ✅ (resolved) |
| **Testing** | QUAD FORGE™ | Test data generation |
| **Development** | QUAD SPARK™ | AI code generation |
| **Infrastructure** | QUAD MIRROR™ | Prod-to-dev environment cloning |
| **Architecture** | QUAD LENS™ | Simplest effective solutions |
| **Knowledge** | QUAD ATLAS™ | Documentation, code search, chatbot, context injection |
| **Alerting** | QUAD BEACON™ | Broadcasting alerts to team members |

### Metrics (How We Measure)
- Complexity Points (work size)
- Velocity Vector (delivery speed)
- Trajectory Chart (remaining work)
- Mastery Points (team contribution)

---

## Document History

| Date | Change | Author |
|------|--------|--------|
| Jan 8, 2026 | Created master jargons doc with 10 proprietary technologies | Claude Code |
| Jan 8, 2026 | ✅ **Resolved PULSE conflict** - Renamed QUAD PULSE™ → QUAD MONITOR™ | Claude Code |
| Jan 8, 2026 | ✅ **Consolidated ATLAS & removed SAGE** - Removed redundant tech, single knowledge platform | Claude Code |
| Jan 8, 2026 | ✅ **Added QUAD BEACON™** - Alert broadcasting for calls/SMS/notifications | Claude Code |
| Jan 8, 2026 | ✅ **Expanded QUAD FLUX™** - Now handles batch/realtime mode distribution | Claude Code |
| Jan 8, 2026 | ✅ **FINAL: 12 proprietary technologies locked** - All naming finalized, ready for deployment | Claude Code |

---

**Status:** ✅ **COMPLETE - All terminology finalized**

**12 Final Proprietary Technologies:**
1. QUAD FLOW™ - Core Workflow (Q→U→A→D)
2. QUAD FLUX™ - AI Routing & Batch/Realtime Distribution
3. QUAD ORBIT™ - Multi-cloud Deployment
4. QUAD GATE™ - Human Approval Gates
5. QUAD SYNC™ - Tool Integration (Jira, GitHub, Slack)
6. QUAD MONITOR™ - Real-time Performance Monitoring
7. QUAD FORGE™ - Test Data Generation
8. QUAD SPARK™ - AI Code Generation
9. QUAD MIRROR™ - Prod-to-Dev Environment Cloning
10. QUAD LENS™ - Right-Sized Architecture Solutions
11. QUAD ATLAS™ - Knowledge Platform (docs, code, chatbot, context)
12. QUAD BEACON™ - Alert Broadcasting (calls, SMS, notifications)

**Ready to Deploy:**
✅ JARGONS_MASTER.md - Complete
✅ Pitch page - Updated with 12 technologies
⏳ Build and test on DEV
⏳ Commit all changes

