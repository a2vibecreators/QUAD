# QUAD Discovery Framework

## Overview

The QUAD Discovery Framework is a structured diagnostic process for organizations that aren't sure if QUAD is right for them, or don't know where to start. It helps confused clients move from "I have problems but don't know what to do" to "Here's my personalized QUAD adoption path."

## When to Use Discovery

| Client Type | Use Discovery? | Reason |
|-------------|---------------|--------|
| **Clear Client** | No | Knows what they want, go straight to `/configure` |
| **Confused Client** | Yes | Needs diagnosis before prescription |
| **Exploratory Client** | Yes | Evaluating QUAD vs other methodologies |
| **Pilot Client** | Yes | Wants to validate fit before commitment |

---

## The 4-Step Discovery Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       QUAD DISCOVERY PROCESS                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Step 1: SYMPTOMS          Step 2: READINESS                            │
│  ┌─────────────────┐       ┌─────────────────┐                          │
│  │  What hurts?    │  ──►  │  Are you ready? │                          │
│  │  Select all     │       │  Prerequisites  │                          │
│  │  pain points    │       │  check          │                          │
│  └─────────────────┘       └─────────────────┘                          │
│           │                         │                                    │
│           └────────────┬────────────┘                                   │
│                        ▼                                                 │
│               Step 3: DIAGNOSIS                                          │
│               ┌─────────────────┐                                       │
│               │  Root cause     │                                       │
│               │  analysis       │                                       │
│               │  + QUAD mapping │                                       │
│               └─────────────────┘                                       │
│                        │                                                 │
│                        ▼                                                 │
│          Step 4: RECOMMENDATION                                          │
│          ┌─────────────────┐                                            │
│          │  Adoption level │                                            │
│          │  0D → 4D        │                                            │
│          │  + Next steps   │                                            │
│          └─────────────────┘                                            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Symptom Collection

### Pain Point Categories

QUAD Discovery categorizes organizational pain into 6 areas:

#### 1. Delivery & Timeline Issues (🚀)

| Symptom | Weight | Root Cause |
|---------|--------|------------|
| Projects are always late | High (3) | No standardized estimation |
| Estimates are wildly inaccurate | Medium (2) | Hidden complexity discovered late |
| Scope creep is constant | Medium (2) | Requirements change mid-sprint |
| Sprint commitments never met | High (3) | Dependencies not tracked |

**QUAD Solution:** Documentation-First ensures requirements are clear BEFORE development. AI agents assist with accurate estimation using historical data.

#### 2. Quality & Rework Problems (🐛)

| Symptom | Weight | Root Cause |
|---------|--------|------------|
| Too many production bugs | High (3) | Inadequate test coverage |
| Lots of time spent on rework | High (3) | QA involved too late |
| QA finds issues late in cycle | Medium (2) | No code review standards |
| Technical debt keeps growing | Medium (2) | Documentation not maintained |

**QUAD Solution:** Circle 3 (QA) is involved from Day 1. Test Agent writes tests as specs are created. Review Agent catches issues before QA.

#### 3. Communication & Alignment (💬)

| Symptom | Weight | Root Cause |
|---------|--------|------------|
| Business and dev don't understand each other | High (3) | No single source of truth |
| Same questions asked repeatedly | Medium (2) | Documentation scattered/outdated |
| Knowledge lost when people leave | High (3) | No standardized terminology |
| Status updates take too long | Low (1) | Information silos between teams |

**QUAD Solution:** Source of Truth flow ensures all knowledge lives in JIRA. Auto-generated documentation. AI agents provide instant status.

#### 4. Scaling & Growth Challenges (📈)

| Symptom | Weight | Root Cause |
|---------|--------|------------|
| Hard to onboard new developers | Medium (2) | Tribal knowledge not documented |
| Processes don't scale | High (3) | No automation of repetitive work |
| Senior devs on repetitive tasks | Medium (2) | Heavy dependence on key people |
| Can't add projects without people | High (3) | Manual processes everywhere |

**QUAD Solution:** AI Agents handle 60-80% of repetitive work. Circle 4 automates deployments. Documentation becomes onboarding material.

#### 5. Visibility & Metrics (👀)

| Symptom | Weight | Root Cause |
|---------|--------|------------|
| Don't know project health until late | High (3) | Manual status reporting |
| No reliable velocity metrics | Medium (2) | Data spread across tools |
| Can't compare team performance | Medium (2) | No standardized metrics |
| Surprises in status meetings | Medium (2) | Reactive not proactive tracking |

**QUAD Solution:** QUAD Dashboard shows real-time health with statistical metrics (μ velocity, σ deviation). Directors see variance instantly.

#### 6. AI/Automation Adoption (🤖)

| Symptom | Weight | Root Cause |
|---------|--------|------------|
| Tried AI tools but didn't stick | Medium (2) | No structured AI integration |
| Don't know where AI can help | Medium (2) | AI used randomly, not systematically |
| Worried about AI quality | Medium (2) | No human-in-the-loop safeguards |
| Team resistant to AI | Low (1) | Unclear AI permissions/boundaries |

**QUAD Solution:** QUAD defines exactly what AI can/cannot do. Human approval at critical gates. Gradual adoption levels (0D→4D).

---

## Step 2: Readiness Assessment

### Critical Requirements (Must Have)

These are non-negotiable for QUAD adoption:

| Requirement | Why Critical |
|-------------|--------------|
| JIRA or similar project management tool | QUAD's Source of Truth depends on structured ticketing |
| Git for source control | AI agents need version control integration |
| Leadership commitment to change | QUAD requires organizational buy-in |

### Nice-to-Have Requirements

| Requirement | Impact if Missing |
|-------------|-------------------|
| Defined sprints/iterations | Can start with Kanban, transition later |
| Dedicated BA or Product Owner | Can share role initially |
| Openness to AI | Can start at lower adoption level |

### Readiness Scoring

| Score | Readiness Level | Recommendation |
|-------|-----------------|----------------|
| 0-3 | Not Ready | Address prerequisites first |
| 4-6 | Basic Ready | Start at 0D (Origin) |
| 7-9 | Ready | Start at 1D (Vector) |
| 10-12 | Very Ready | Start at 2D (Plane) |
| 13+ | Highly Ready | Consider 3D (Space) |

---

## Step 3: Diagnosis

### Pain Score Calculation

```
Pain Score = Σ (symptom_weight × selected)

Interpretation:
- 0-5:    Low pain - QUAD optional, may be overkill
- 6-12:   Medium pain - QUAD recommended
- 13-20:  High pain - QUAD strongly recommended
- 21+:    Critical pain - QUAD urgent
```

### Root Cause Mapping

Each symptom maps to specific QUAD solutions:

| Pain Area | Primary QUAD Solution | Secondary Solutions |
|-----------|----------------------|---------------------|
| Delivery | Docs-First + Estimation Agent | Story Agent, Planning Agent |
| Quality | Circle 3 QA + Test Agent | Review Agent, Code Agent |
| Communication | Source of Truth + Jargons | JIRA Integration, Auto-docs |
| Scaling | AI Agents (60-80% automation) | Circle 4, Platform |
| Visibility | QUAD Dashboard | Metrics, Analytics Agent |
| AI Adoption | Adoption Levels (0D-4D) | Gradual rollout, permissions |

---

## Step 4: Recommendation

### Adoption Level Selection

Based on combined Pain Score and Readiness Score:

```
Recommended Level = min(Pain Level Needed, Readiness Allows)
```

| Level | Name | When Recommended |
|-------|------|------------------|
| **0D** | Origin | Low pain OR not ready for AI |
| **1D** | Vector | Medium pain + basic readiness |
| **2D** | Plane | High pain + good readiness |
| **3D** | Space | Critical pain + very ready |
| **4D** | Hyperspace | Maximum automation desired |

### Next Steps by Level

#### If Recommended: 0D (Origin)
1. Implement Documentation-First principles
2. Establish 4 Circles structure
3. Define terminology/jargons
4. No AI agents yet

#### If Recommended: 1D (Vector)
1. All of 0D
2. Add manual AI tools (ChatGPT, Copilot)
3. Human-in-the-loop for all AI output
4. Basic JIRA integration

#### If Recommended: 2D (Plane)
1. All of 1D
2. Story Agent (auto-expand stories)
3. Estimation Agent (suggest estimates)
4. Human approval required

#### If Recommended: 3D (Space)
1. All of 2D
2. Dev Agent (code generation)
3. Test Agent (auto-write tests)
4. Review Agent (code review)
5. Some auto-approval allowed

#### If Recommended: 4D (Hyperspace)
1. All of 3D
2. Deploy Agent (auto-deploy to DEV)
3. Monitor Agent (self-healing)
4. Full autonomous pipeline
5. Human only for exceptions

---

## Discovery Output

After completing discovery, the client receives:

### 1. Diagnosis Report
- Pain score with breakdown
- Affected areas with root causes
- QUAD solutions for each issue

### 2. Readiness Assessment
- Prerequisites met/not met
- Readiness score
- Gaps to address

### 3. Personalized Recommendation
- Recommended adoption level
- Why this level
- Next steps with links

### 4. Configuration Starting Point
- Pre-filled `/configure` page
- Based on diagnosis
- Ready to generate YAML

---

## Flow Integration

```
Website User Journey:

                    ┌─────────────┐
                    │   Landing   │
                    │      /      │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
    │  I'm Clear  │ │  I'm Confused│ │  Just Look │
    │  /configure │ │  /discovery  │ │  /explore  │
    └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
           │               │               │
           │        ┌──────▼──────┐        │
           │        │  Diagnosis  │        │
           │        │  + Recommend│        │
           │        └──────┬──────┘        │
           │               │               │
           └───────────────┼───────────────┘
                           │
                    ┌──────▼──────┐
                    │  /configure │
                    │  Export YAML│
                    └─────────────┘
```

---

## FAQ

### Q: Can I skip Discovery and go straight to Configure?
**A:** Yes! If you know what you want, go to `/configure`. Discovery is for clients who need guidance.

### Q: What if I fail the readiness check?
**A:** We'll show you exactly what's missing (JIRA, Git, leadership). Address those first, then return.

### Q: Can I change my adoption level later?
**A:** Absolutely! QUAD is designed for gradual adoption. Start at 1D, prove value, then move to 2D.

### Q: How long does Discovery take?
**A:** About 5-10 minutes for the questionnaire. You get instant recommendations.

### Q: Is my data saved?
**A:** Currently, Discovery runs client-side only. No data is sent to servers.

---

## Related Documentation

- [QUAD Adoption Levels](./quad-workflow/QUAD_ADOPTION_LEVELS.md) - Detailed 0D-4D progression
- [QUAD Platform](./QUAD_PLATFORM.md) - Platform subscription tiers
- [QUAD Details](./QUAD_DETAILS.md) - Technical implementation details
- [QUAD Jargons](./QUAD_JARGONS.md) - Terminology glossary

---

**Last Updated:** December 31, 2025
**Author:** A2Vibe Creators
