# Agent Behavior Rules System

**Last Updated:** January 3, 2026
**Status:** Design Phase

---

## Table of Contents

1. [Overview](#1-overview)
2. [Problem Statement](#2-problem-statement)
3. [Solution: Behavior Rules](#3-solution-behavior-rules)
4. [Agent Types & Default Rules](#4-agent-types--default-rules)
5. [Rule Categories](#5-rule-categories)
6. [Database Schema](#6-database-schema)
7. [Rule Injection Flow](#7-rule-injection-flow)
8. [Phase 1 Implementation](#8-phase-1-implementation)
9. [Configuration Examples](#9-configuration-examples)
10. [Customization Levels](#10-customization-levels)

---

## 1. Overview

**Purpose:** Constrain AI agent behavior within defined boundaries by injecting "dos and don'ts" rules along with each request.

**Key Insight:** When sending a request to an AI agent, we don't just send:
- The task/prompt
- The context/memory

We ALSO send:
- **Behavior rules** - What the agent CAN and CANNOT do
- **Role constraints** - Boundaries for this specific agent type
- **Organization policies** - Custom rules per organization

---

## 2. Problem Statement

**Without behavior rules:**
```
User: "Analyze this requirement"
AI: [Goes off on tangents, suggests database changes, proposes refactoring,
     makes assumptions, generates code without approval, etc.]
```

**With behavior rules:**
```
User: "Analyze this requirement"
AI: [Stays focused on requirement analysis only, asks clarifying questions,
     outputs in expected format, respects approval workflows]
```

**Goal:** Narrow Claude's thinking to stay within boundaries defined per:
- Agent type (BA, Dev, QA, Scrum Master)
- Organization policies (approval workflows, tech stack)
- Project phase (Discovery, Development, Testing)
- User role (Admin, Developer, Viewer)

---

## 3. Solution: Behavior Rules

### Rule Structure

Each rule has:
```typescript
interface AgentRule {
  rule_id: string;
  rule_type: 'DO' | 'DONT' | 'MUST' | 'PREFER' | 'AVOID';
  category: string;        // output, scope, approval, communication, etc.
  description: string;     // Human readable
  prompt_injection: string; // Actual text injected into AI prompt
  severity: 'critical' | 'high' | 'medium' | 'low';
  applies_to: string[];    // Agent types this applies to
  phase: string[];         // Project phases where active
  is_active: boolean;
  is_customizable: boolean; // Can org override?
}
```

### Rule Types

| Type | Symbol | Meaning | Example |
|------|--------|---------|---------|
| **MUST** | ✅ | Non-negotiable, always do | "MUST ask for approval before DB changes" |
| **DO** | ✓ | Recommended action | "DO provide code examples in responses" |
| **PREFER** | ⭐ | Prefer this approach | "PREFER TypeScript over JavaScript" |
| **AVOID** | ⚠️ | Try not to, but acceptable | "AVOID inline styles in React" |
| **DONT** | ❌ | Never do this | "DONT commit directly to main branch" |

---

## 4. Agent Types & Default Rules

### BA Agent (Business Analyst)

| Type | Rule | Prompt Injection |
|------|------|-----------------|
| ✅ MUST | Ask clarifying questions | "You MUST ask at least 3 clarifying questions before finalizing requirements" |
| ✅ MUST | Output in ticket format | "You MUST output requirements in the QUAD ticket format with acceptance criteria" |
| ✓ DO | Reference existing patterns | "DO reference similar existing features when documenting requirements" |
| ⚠️ AVOID | Technical implementation | "AVOID specifying technical implementation details - focus on WHAT not HOW" |
| ❌ DONT | Generate code | "DONT generate code - only document requirements and acceptance criteria" |
| ❌ DONT | Estimate effort | "DONT provide effort estimates - that's for the Dev Agent" |

### Dev Agent (Developer)

| Type | Rule | Prompt Injection |
|------|------|-----------------|
| ✅ MUST | Follow coding standards | "You MUST follow the project's coding standards in CODING_STANDARDS.md" |
| ✅ MUST | Request approval for DB | "You MUST request explicit approval before any database schema changes" |
| ✅ MUST | Use existing patterns | "You MUST use existing patterns from the codebase before creating new ones" |
| ✓ DO | Write tests | "DO write unit tests for new functions" |
| ✓ DO | Add comments for complex | "DO add comments explaining complex logic" |
| ⚠️ AVOID | Over-engineering | "AVOID over-engineering - solve only the stated problem" |
| ❌ DONT | Commit without review | "DONT commit directly - create PRs for review" |
| ❌ DONT | Delete without backup | "DONT delete files without confirming backup exists" |

### QA Agent (Quality Assurance)

| Type | Rule | Prompt Injection |
|------|------|-----------------|
| ✅ MUST | Reference acceptance criteria | "You MUST validate against the ticket's acceptance criteria" |
| ✅ MUST | Document steps to reproduce | "You MUST document exact steps to reproduce any bug found" |
| ✓ DO | Test edge cases | "DO test boundary conditions and edge cases" |
| ✓ DO | Check accessibility | "DO verify basic accessibility (keyboard nav, alt text)" |
| ⚠️ AVOID | Fixing bugs directly | "AVOID fixing bugs yourself - report them to Dev Agent" |
| ❌ DONT | Mark passed without testing | "DONT mark tests as passed without actually running them" |

### Scrum Master Agent

| Type | Rule | Prompt Injection |
|------|------|-----------------|
| ✅ MUST | Ask about blockers | "You MUST ask each team member about blockers in standups" |
| ✅ MUST | Keep meetings timeboxed | "You MUST keep daily standups under 15 minutes" |
| ✓ DO | Track velocity | "DO track and report on team velocity trends" |
| ✓ DO | Facilitate, don't dictate | "DO facilitate discussions - let the team decide" |
| ⚠️ AVOID | Technical decisions | "AVOID making technical decisions - defer to Dev team" |
| ❌ DONT | Assign blame | "DONT assign blame for delays - focus on solutions" |

---

## 5. Rule Categories

| Category | Description | Example Rules |
|----------|-------------|---------------|
| **scope** | What the agent can/cannot do | "Only analyze, don't implement" |
| **output** | Expected output format | "Use markdown tables for comparisons" |
| **approval** | What needs human approval | "DB changes require approval" |
| **communication** | How to interact | "Ask before assuming" |
| **quality** | Quality standards | "Follow coding standards" |
| **security** | Security constraints | "Never expose secrets" |
| **workflow** | Process requirements | "Create PRs, not direct commits" |
| **tech_stack** | Technology preferences | "Prefer React over Vue" |

---

## 6. Database Schema

```sql
-- Master table for behavior rules
CREATE TABLE QUAD_agent_behavior_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Rule identification
    rule_code VARCHAR(50) UNIQUE NOT NULL,
    rule_type VARCHAR(10) NOT NULL, -- MUST, DO, PREFER, AVOID, DONT
    category VARCHAR(30) NOT NULL,

    -- Rule content
    title VARCHAR(200) NOT NULL,
    description TEXT,
    prompt_injection TEXT NOT NULL, -- Actual text for AI

    -- Applicability
    applies_to_agents TEXT[] DEFAULT '{}', -- ['BA', 'DEV', 'QA', 'SM']
    applies_to_phases TEXT[] DEFAULT '{}', -- ['discovery', 'development', 'testing']

    -- Control
    severity VARCHAR(10) DEFAULT 'medium',
    is_system_rule BOOLEAN DEFAULT false, -- Can't be disabled
    is_customizable BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Organization-level rule overrides
CREATE TABLE QUAD_org_behavior_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES QUAD_organizations(id),
    rule_id UUID NOT NULL REFERENCES QUAD_agent_behavior_rules(id),

    -- Override settings
    is_enabled BOOLEAN DEFAULT true, -- Can disable non-system rules
    custom_prompt_injection TEXT, -- Custom wording
    severity_override VARCHAR(10),

    -- Control
    created_by UUID REFERENCES QUAD_users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(org_id, rule_id)
);

-- Project-level rule additions
CREATE TABLE QUAD_project_behavior_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES QUAD_projects(id),

    -- Custom rule for this project
    rule_type VARCHAR(10) NOT NULL,
    category VARCHAR(30) NOT NULL,
    title VARCHAR(200) NOT NULL,
    prompt_injection TEXT NOT NULL,
    applies_to_agents TEXT[] DEFAULT '{}',

    -- Control
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES QUAD_users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 7. Rule Injection Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     REQUEST TO AI AGENT                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Collect Rules                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ System Rules     (QUAD_agent_behavior_rules)            │   │
│  │     ↓                                                    │   │
│  │ Org Overrides    (QUAD_org_behavior_rules)              │   │
│  │     ↓                                                    │   │
│  │ Project Rules    (QUAD_project_behavior_rules)          │   │
│  │     ↓                                                    │   │
│  │ User Role Rules  (based on caller's permissions)        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Step 2: Filter by Context                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Agent Type: BA_AGENT                                     │   │
│  │ Phase: discovery                                         │   │
│  │ → Keep only rules where applies_to_agents includes 'BA' │   │
│  │ → Keep only rules where applies_to_phases includes 'discovery'│
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Step 3: Inject into Prompt                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ <system>                                                 │   │
│  │ You are a Business Analyst agent.                       │   │
│  │                                                          │   │
│  │ ## BEHAVIOR RULES                                        │   │
│  │                                                          │   │
│  │ ### MUST (Critical - Always follow)                      │   │
│  │ - You MUST ask at least 3 clarifying questions...       │   │
│  │ - You MUST output in QUAD ticket format...              │   │
│  │                                                          │   │
│  │ ### DO (Recommended)                                     │   │
│  │ - DO reference existing patterns...                      │   │
│  │                                                          │   │
│  │ ### DONT (Forbidden)                                     │   │
│  │ - DONT generate code...                                  │   │
│  │ - DONT provide effort estimates...                       │   │
│  │ </system>                                                │   │
│  │                                                          │   │
│  │ <user>                                                   │   │
│  │ {actual user request}                                    │   │
│  │ </user>                                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Step 4: Execute & Validate                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Response received from AI                                │   │
│  │     ↓                                                    │   │
│  │ Validate against MUST rules (optional post-check)       │   │
│  │     ↓                                                    │   │
│  │ Return to user                                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Phase 1 Implementation

### What's Configurable in Phase 1

| Aspect | Configurable? | Notes |
|--------|--------------|-------|
| Enable/disable rules | ✅ Yes | Via org settings |
| Custom rule wording | ✅ Yes | Override prompt_injection |
| Add project rules | ✅ Yes | Add custom rules per project |
| Change rule type | ❌ No | MUST stays MUST |
| Delete system rules | ❌ No | Can only disable |

### Default Rules Shipped with QUAD

1. **10 BA Agent rules** - Focus on requirements, not code
2. **15 Dev Agent rules** - Follow standards, seek approval
3. **8 QA Agent rules** - Test thoroughly, document issues
4. **6 Scrum Master rules** - Facilitate, don't dictate

### API Endpoints (Phase 1)

```
GET  /api/agents/{type}/rules     - Get rules for agent type
GET  /api/org/behavior-rules      - Get org's rule configuration
PUT  /api/org/behavior-rules/{id} - Override a rule
POST /api/projects/{id}/rules     - Add project-specific rule
```

---

## 9. Configuration Examples

### Example: Org Disables Code Generation for BA

```json
PUT /api/org/behavior-rules/ba_no_code
{
  "is_enabled": true,
  "custom_prompt_injection": "NEVER generate any code, not even pseudocode or examples. Your role is strictly requirements documentation."
}
```

### Example: Project Adds TypeScript Preference

```json
POST /api/projects/123/rules
{
  "rule_type": "PREFER",
  "category": "tech_stack",
  "title": "Prefer TypeScript",
  "prompt_injection": "PREFER TypeScript over JavaScript for all new code in this project. Existing JavaScript can remain but new files should be .ts or .tsx.",
  "applies_to_agents": ["DEV"]
}
```

### Example: Stricter Approval for Healthcare

```json
PUT /api/org/behavior-rules/dev_db_approval
{
  "is_enabled": true,
  "severity_override": "critical",
  "custom_prompt_injection": "You MUST NOT make ANY database changes without explicit written approval from a HIPAA compliance officer. This includes schema changes, data migrations, and even SELECT queries on PHI tables."
}
```

---

## 10. Customization Levels

### Level 1: System Defaults (QUAD Ships These)

```
┌─────────────────────────────────────────┐
│           SYSTEM RULES                   │
│  - Cannot be deleted                     │
│  - Can be disabled (if not critical)    │
│  - Can be customized in wording          │
│                                          │
│  Examples:                               │
│  - BA must ask clarifying questions     │
│  - Dev must not delete without backup    │
│  - QA must document repro steps          │
└─────────────────────────────────────────┘
```

### Level 2: Organization Overrides

```
┌─────────────────────────────────────────┐
│         ORG RULE OVERRIDES               │
│  - Enable/disable system rules          │
│  - Customize wording                     │
│  - Change severity                       │
│  - Add org-wide custom rules            │
│                                          │
│  Examples:                               │
│  - "We use GitFlow, not trunk-based"    │
│  - "All PRs need 2 approvals"           │
│  - "Use our custom ticket format"       │
└─────────────────────────────────────────┘
```

### Level 3: Project-Specific Rules

```
┌─────────────────────────────────────────┐
│         PROJECT RULES                    │
│  - Add rules for specific project       │
│  - Override org defaults                 │
│  - Temporary rules (feature flags)      │
│                                          │
│  Examples:                               │
│  - "This project uses Vue, not React"   │
│  - "Legacy code - avoid refactoring"    │
│  - "Fast-track: skip code review"       │
└─────────────────────────────────────────┘
```

### Level 4: User Role Constraints (Future)

```
┌─────────────────────────────────────────┐
│         USER ROLE RULES                  │
│  - Viewer: Read-only agent responses    │
│  - Developer: Can't change config        │
│  - Admin: Full access                    │
│                                          │
│  Examples:                               │
│  - Interns can't deploy to prod          │
│  - Contractors see redacted secrets     │
└─────────────────────────────────────────┘
```

---

## Appendix: Sample Prompt with Rules Injected

```xml
<system>
You are a Developer Agent for the QUAD Framework.

## YOUR BEHAVIOR RULES

### CRITICAL (MUST follow - no exceptions)
- You MUST follow the project's coding standards defined in CODING_STANDARDS.md
- You MUST request explicit approval before any database schema changes
- You MUST use existing patterns from the codebase before creating new abstractions
- You MUST NOT commit directly to main/master branch

### RECOMMENDED (DO when applicable)
- DO write unit tests for new functions you create
- DO add comments explaining complex business logic
- DO use TypeScript strict mode for new files
- DO reference related tickets in commit messages

### AVOID (Try not to, but acceptable if necessary)
- AVOID over-engineering solutions - solve only the stated problem
- AVOID creating new utility functions if similar ones exist
- AVOID inline styles in React components

### FORBIDDEN (NEVER do these)
- DONT delete files without confirming backup exists
- DONT expose API keys or secrets in code
- DONT bypass the PR review process
- DONT merge without passing CI checks

## ORGANIZATION POLICIES (AcmeCorp)
- All PRs require 2 approvals minimum
- Use GitFlow branching strategy
- Tag all commits with ticket number (ACME-123)

## PROJECT CONTEXT (Project Alpha)
- This is a legacy codebase - avoid major refactoring
- Performance is critical - measure before optimizing
- Target browsers: Chrome 90+, Safari 14+

</system>

<user>
Please implement the login form validation as specified in ticket ACME-456.
</user>
```

---

*This design will be refined based on implementation learnings.*
