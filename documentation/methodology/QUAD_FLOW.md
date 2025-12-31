# QUAD Source of Truth Flow

## Overview

The Source of Truth Flow shows how requirements travel through the QUAD system - from initial idea to deployed feature. This animated visualization demonstrates the path data takes and how AI agents assist at each stage.

---

## Flow Visualization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QUAD SOURCE OF TRUTH FLOW                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────┐                                                               │
│  │  IDEA    │  ← Business need, user feedback, market requirement           │
│  └────┬─────┘                                                               │
│       │                                                                      │
│       ▼                                                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    CIRCLE 1: MANAGEMENT                               │  │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐               │  │
│  │  │     BA      │ →  │  Story      │ →  │    PM       │               │  │
│  │  │  Creates    │    │  Agent      │    │  Schedules  │               │  │
│  │  │  Story      │    │  Expands    │    │  Cycle      │               │  │
│  │  └─────────────┘    └─────────────┘    └─────────────┘               │  │
│  │                            ↓                                          │  │
│  │                    [Flow Document]                                    │  │
│  │                    Created in JIRA                                    │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                              │                                              │
│                              ▼                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    CIRCLE 2: DEVELOPMENT                              │  │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐               │  │
│  │  │   Dev UI    │    │   Dev API   │    │   Review    │               │  │
│  │  │   Agent     │    │   Agent     │    │   Agent     │               │  │
│  │  │  Parallel   │    │  Parallel   │    │  Reviews    │               │  │
│  │  └─────────────┘    └─────────────┘    └─────────────┘               │  │
│  │         │                 │                   │                       │  │
│  │         └────────┬────────┘                   │                       │  │
│  │                  ▼                            ▼                        │  │
│  │            [Pull Request]              [Approved PR]                  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                              │                                              │
│                              ▼                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    CIRCLE 3: QA                                       │  │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐               │  │
│  │  │  Test UI    │    │  Test API   │    │    QA       │               │  │
│  │  │   Agent     │    │   Agent     │    │  Engineer   │               │  │
│  │  │  Auto-gen   │    │  Auto-gen   │    │  Validates  │               │  │
│  │  └─────────────┘    └─────────────┘    └─────────────┘               │  │
│  │         │                 │                   │                       │  │
│  │         └────────┬────────┘                   │                       │  │
│  │                  ▼                            ▼                        │  │
│  │            [Test Results]              [QA Sign-off]                  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                              │                                              │
│                              ▼                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    CIRCLE 4: INFRASTRUCTURE                           │  │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐               │  │
│  │  │   Deploy    │ →  │  Monitor    │ →  │  Incident   │               │  │
│  │  │   Agent     │    │   Agent     │    │   Agent     │               │  │
│  │  │  Auto-ship  │    │  Watches    │    │  Responds   │               │  │
│  │  └─────────────┘    └─────────────┘    └─────────────┘               │  │
│  │         │                 │                   │                       │  │
│  │         ▼                 ▼                   ▼                        │  │
│  │    [Deployed]       [Metrics]          [Alerts]                       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                              │                                              │
│                              ▼                                              │
│  ┌──────────┐                                                               │
│  │ DEPLOYED │  ← Feature live in production                                │
│  └──────────┘                                                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Flow Stages Explained

### Stage 1: Idea Capture

**Input:** Business need, user feedback, market requirement

**Process:**
1. Stakeholder identifies a need
2. BA captures the idea in JIRA as Epic/Story
3. Initial requirements documented

**Output:** Draft story in backlog

---

### Stage 2: Story Expansion (Circle 1)

**Actors:** BA, Story Agent, PM

**Process:**
1. BA writes initial story with basic description
2. **Story Agent** (AI) auto-expands:
   - Acceptance criteria
   - Edge cases
   - Technical considerations
   - Related stories
3. PM schedules into upcoming Cycle
4. Tech Lead reviews technical feasibility

**Output:** Complete Flow Document in JIRA

**Human Gate:** BA approves expanded story before development

---

### Stage 3: Development (Circle 2)

**Actors:** Dev Agent (UI), Dev Agent (API), Review Agent, Developers

**Process:**
1. Story moves to "In Development"
2. **Dev Agent UI** generates frontend code (parallel)
3. **Dev Agent API** generates backend code (parallel)
4. Developer reviews and refines AI output
5. Pull Request created
6. **Review Agent** performs automated code review
7. Human developer approves PR

**Output:** Approved Pull Request merged to development branch

**Human Gate:** Developer approves AI-generated code

---

### Stage 4: Testing (Circle 3)

**Actors:** Test Agent (UI), Test Agent (API), QA Engineer

**Process:**
1. Story moves to "In QA"
2. **Test Agent UI** generates UI test cases
3. **Test Agent API** generates API test cases
4. Automated tests run in CI/CD
5. QA Engineer performs manual testing
6. Bugs logged back to development if found

**Output:** QA Sign-off

**Human Gate:** QA Engineer certifies feature is ready

---

### Stage 5: Deployment (Circle 4)

**Actors:** Deploy Agent, Monitor Agent, Incident Agent, DevOps

**Process:**
1. Story moves to "Ready for Deploy"
2. **Deploy Agent** packages and deploys to staging
3. Smoke tests run automatically
4. **Deploy Agent** promotes to production
5. **Monitor Agent** watches metrics and logs
6. **Incident Agent** triggers alerts if issues detected

**Output:** Feature live in production

**Human Gate:** DevOps approves production deployment (at adoption levels 0D-2D)

---

## Flow Document Structure

Every story that flows through QUAD has a **Flow Document** - the source of truth.

```markdown
# STORY-123: User Login with SSO

## Business Context
[Why this feature matters]

## Acceptance Criteria
- [ ] User can login with Google SSO
- [ ] User can login with Microsoft SSO
- [ ] Session expires after 24 hours
- [ ] Failed login shows error message

## Technical Design
- Frontend: OAuth2 flow in React
- Backend: Spring Security OAuth2 client
- Database: Update users table with provider

## AI Agent Outputs
### Story Agent
- Added 3 edge cases
- Suggested security review

### Dev Agent
- Generated OAuth2 boilerplate
- Created API endpoints

### Test Agent
- Generated 15 test cases
- 12 passed, 3 pending

## Human Approvals
- [ ] BA approved story expansion
- [ ] Dev approved generated code
- [ ] QA approved test results
- [ ] DevOps approved deployment
```

---

## Animation on Website

The `/flow` page shows this flow as an animated visualization:

1. **Pulsing nodes** showing data flowing through system
2. **Agent icons** lighting up when active
3. **Document icons** appearing at each stage
4. **Human gate checkpoints** highlighted

---

## Integration Points

| Stage | Integration | Data Flow |
|-------|-------------|-----------|
| Story Creation | JIRA | Story created via API |
| Code Generation | GitHub/GitLab | Branch + commits |
| Code Review | GitHub Actions | PR comments |
| Testing | CI/CD Pipeline | Test results posted |
| Deployment | Cloud Run/K8s | Deployment triggered |
| Monitoring | Prometheus/Grafana | Metrics collected |
| Incidents | PagerDuty/Slack | Alerts sent |

---

## Key Principles

### 1. Single Source of Truth
- JIRA is the authoritative source
- All artifacts link back to JIRA story
- Wikis sync FROM Git, not the other way

### 2. Documentation-First
- Specs written before code
- AI agents read specs to generate code
- Tests generated from acceptance criteria

### 3. Human-in-the-Loop
- AI suggests, humans approve
- Critical gates require human sign-off
- Full audit trail of decisions

### 4. Parallel Processing
- UI and API work can proceed simultaneously
- Multiple agents work in parallel
- Reduces cycle time significantly

---

## Related Documentation

- [QUAD Methodology](./QUAD.md) - Complete QUAD specification
- [QUAD Agent Architecture](./QUAD_AGENT_ARCHITECTURE.md) - Agent communication
- [QUAD Project Lifecycle](./quad-workflow/QUAD_PROJECT_LIFECYCLE.md) - Full project flow
- [QUAD Integration Architecture](./quad-workflow/QUAD_INTEGRATION_ARCHITECTURE.md) - Tool integrations

---

**Last Updated:** December 31, 2025
**Author:** A2Vibe Creators
