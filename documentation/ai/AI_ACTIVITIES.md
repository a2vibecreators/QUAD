# QUAD Framework - Complete AI Activities List

## Overview

Before designing AI pipelines, we must understand every AI activity QUAD performs. This document catalogs all 40+ AI activities organized by category and complexity.

---

## Activity Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QUAD AI ACTIVITY MAP                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │     A       │  │     B       │  │     C       │  │     D       │        │
│  │  INTAKE     │  │  ORGANIZE   │  │   CODE      │  │  ANALYZE    │        │
│  │             │  │             │  │             │  │             │        │
│  │ Meeting     │  │ Classify    │  │ Generate    │  │ Review      │        │
│  │ Email       │  │ Prioritize  │  │ Fix         │  │ Audit       │        │
│  │ Slack       │  │ Route       │  │ Refactor    │  │ Design      │        │
│  │ Documents   │  │ Estimate    │  │ Test        │  │ Secure      │        │
│  │             │  │             │  │             │  │             │        │
│  │ CHEAPEST    │  │   CHEAP     │  │  MEDIUM     │  │  PREMIUM    │        │
│  │ $0.00-0.10  │  │ $0.10-0.30  │  │ $0.25-3.00  │  │ $3.00-15.00 │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Category A: INTAKE (Extract & Parse)

**Purpose:** Convert unstructured input into structured data
**Complexity:** Low - Pattern matching, extraction
**Best Models:** Groq (FREE), Gemini Flash-Lite, DeepSeek

### A1. Meeting Processing

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| A1.1 | **Meeting → Action Items** | Transcript (5K-20K) | List of actions | In: 10K, Out: 1K |
| A1.2 | **Meeting → Decisions** | Transcript | List of decisions made | In: 10K, Out: 500 |
| A1.3 | **Meeting → Attendee Summary** | Transcript | Who said what summary | In: 10K, Out: 1K |
| A1.4 | **Meeting → Follow-ups** | Transcript | Follow-up items with owners | In: 10K, Out: 800 |

### A2. Email Processing

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| A2.1 | **Email → Parse Request** | Email body | Structured request | In: 500, Out: 200 |
| A2.2 | **Email → Extract Entities** | Email body | People, dates, items | In: 500, Out: 150 |
| A2.3 | **Email → Sentiment** | Email body | Sentiment + urgency | In: 500, Out: 50 |
| A2.4 | **Email Thread → Summary** | Thread (multiple) | Conversation summary | In: 2K, Out: 300 |

### A3. Slack/Chat Processing

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| A3.1 | **Slack → Intent Detection** | Message | Intent category | In: 100, Out: 20 |
| A3.2 | **Slack → Extract Request** | Message | Structured task | In: 100, Out: 100 |
| A3.3 | **Slack Thread → Summary** | Thread | Key points | In: 1K, Out: 200 |
| A3.4 | **Slack → @quad Command** | Command message | Parsed command + args | In: 50, Out: 50 |

### A4. Document Processing

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| A4.1 | **Doc → Summary** | Document | Executive summary | In: 5K, Out: 500 |
| A4.2 | **PRD → User Stories** | PRD document | List of user stories | In: 3K, Out: 2K |
| A4.3 | **Spec → Requirements** | Technical spec | Structured requirements | In: 5K, Out: 2K |
| A4.4 | **Confluence → Extract** | Wiki page | Key information | In: 2K, Out: 500 |

### A5. Git/Code Parsing

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| A5.1 | **Git Diff → Summary** | Diff output | Human-readable changes | In: 2K, Out: 300 |
| A5.2 | **Commit History → Changelog** | Commits list | Changelog entries | In: 1K, Out: 500 |
| A5.3 | **PR Description → Parse** | PR text | Structured PR info | In: 500, Out: 200 |

---

## Category B: ORGANIZE (Classify & Route)

**Purpose:** Categorize, prioritize, and route work items
**Complexity:** Low-Medium - Classification, decision logic
**Best Models:** GPT-4o-mini, Groq, DeepSeek

### B1. Ticket Classification

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| B1.1 | **Ticket → Priority** | Ticket text | P0/P1/P2/P3 | In: 300, Out: 10 |
| B1.2 | **Ticket → Category** | Ticket text | Bug/Feature/Task/Spike | In: 300, Out: 10 |
| B1.3 | **Ticket → Effort** | Ticket text | S/M/L/XL or story points | In: 300, Out: 20 |
| B1.4 | **Ticket → Labels** | Ticket text | Relevant labels | In: 300, Out: 50 |
| B1.5 | **Ticket → Component** | Ticket text | Affected component | In: 300, Out: 20 |

### B2. Routing & Assignment

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| B2.1 | **Task → Circle** | Task description | Dev/QA/Ops/Management | In: 200, Out: 10 |
| B2.2 | **Task → Skill Match** | Task + team profiles | Best assignee | In: 500, Out: 50 |
| B2.3 | **Request → Is Code?** | Request text | Yes/No + reasoning | In: 100, Out: 30 |
| B2.4 | **Ticket → Dependencies** | Ticket + context | Related tickets | In: 500, Out: 100 |

### B3. Planning Assistance

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| B3.1 | **Backlog → Sprint Suggest** | Backlog items | Suggested sprint | In: 2K, Out: 500 |
| B3.2 | **Tickets → Group by Theme** | Multiple tickets | Grouped themes | In: 1K, Out: 300 |
| B3.3 | **Velocity → Forecast** | Historical data | Sprint forecast | In: 500, Out: 200 |

---

## Category C: CODE (Generate & Modify)

**Purpose:** Write, fix, and modify code
**Complexity:** Medium-High - Requires coding knowledge
**Best Models:** Claude Haiku, DeepSeek, Mistral Codestral, Claude Sonnet

### C1. Code Generation (Simple)

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| C1.1 | **Generate Boilerplate** | Description + framework | Starter code | In: 200, Out: 500 |
| C1.2 | **Generate Function** | Function spec | Function code | In: 150, Out: 300 |
| C1.3 | **Generate Interface/Type** | Description | TypeScript types | In: 100, Out: 200 |
| C1.4 | **Generate API Route** | Endpoint spec | Route handler | In: 200, Out: 400 |
| C1.5 | **Generate Test Stubs** | Function/class | Test file skeleton | In: 300, Out: 400 |

### C2. Code Modification (Simple)

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| C2.1 | **Add Comments** | Code block | Commented code | In: 500, Out: 700 |
| C2.2 | **Format Code** | Unformatted code | Formatted code | In: 500, Out: 500 |
| C2.3 | **Rename Variables** | Code + rename rules | Refactored code | In: 500, Out: 500 |
| C2.4 | **Convert Syntax** | Code + target style | Converted code | In: 500, Out: 500 |
| C2.5 | **Add Error Handling** | Code block | Code with try/catch | In: 300, Out: 400 |

### C3. Code Generation (Complex)

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| C3.1 | **Implement Feature** | Feature spec + context | Full implementation | In: 1K, Out: 2K |
| C3.2 | **Implement API Endpoint** | API spec + DB schema | Complete endpoint | In: 1K, Out: 1.5K |
| C3.3 | **Generate Unit Tests** | Code + requirements | Complete test suite | In: 1K, Out: 1.5K |
| C3.4 | **Generate Integration Test** | Flow description | Integration tests | In: 800, Out: 1K |
| C3.5 | **Implement UI Component** | Design + spec | React component | In: 800, Out: 1.5K |

### C4. Bug Fixing

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| C4.1 | **Fix Simple Bug** | Code + error | Fixed code | In: 500, Out: 300 |
| C4.2 | **Fix Complex Bug** | Code + error + context | Fixed code + explanation | In: 2K, Out: 1K |
| C4.3 | **Debug Error** | Stack trace + code | Root cause + fix | In: 1K, Out: 500 |
| C4.4 | **Fix Test Failure** | Test + code | Fixed test or code | In: 800, Out: 400 |

### C5. Refactoring

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| C5.1 | **Refactor Function** | Function + goal | Refactored function | In: 500, Out: 500 |
| C5.2 | **Refactor Multi-file** | Multiple files + goal | Refactored files | In: 3K, Out: 3K |
| C5.3 | **Extract Component** | Large file | Extracted components | In: 2K, Out: 2K |
| C5.4 | **Optimize Performance** | Code + perf issue | Optimized code | In: 1K, Out: 1K |

---

## Category D: ANALYZE (Review & Audit)

**Purpose:** Review code, analyze architecture, audit security
**Complexity:** High - Requires deep understanding
**Best Models:** Claude Sonnet, Claude Opus, GPT-4o

### D1. Code Review

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| D1.1 | **Review Code Changes** | Diff/PR | Review comments | In: 2K, Out: 1K |
| D1.2 | **Review for Best Practices** | Code | Improvement suggestions | In: 1K, Out: 800 |
| D1.3 | **Review for Performance** | Code | Performance issues | In: 1K, Out: 500 |
| D1.4 | **Review for Security** | Code | Security issues | In: 1K, Out: 500 |
| D1.5 | **Review PR End-to-End** | Full PR | Complete review | In: 5K, Out: 2K |

### D2. Codebase Analysis

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| D2.1 | **Analyze Codebase Structure** | File tree + samples | Architecture overview | In: 3K, Out: 1K |
| D2.2 | **Find Code Patterns** | Codebase context | Pattern analysis | In: 5K, Out: 1K |
| D2.3 | **Identify Tech Debt** | Codebase context | Tech debt report | In: 5K, Out: 2K |
| D2.4 | **Dependency Analysis** | package.json + code | Dependency report | In: 2K, Out: 1K |

### D3. Architecture & Design

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| D3.1 | **Design System Architecture** | Requirements | Architecture proposal | In: 2K, Out: 3K |
| D3.2 | **Review Architecture** | Current architecture | Review + suggestions | In: 3K, Out: 2K |
| D3.3 | **Design Database Schema** | Requirements | Schema design | In: 1K, Out: 1.5K |
| D3.4 | **Design API** | Requirements | API spec | In: 1K, Out: 2K |
| D3.5 | **Migration Planning** | Current + target | Migration plan | In: 3K, Out: 2K |

### D4. Security & Compliance

| ID | Activity | Input | Output | Tokens (avg) |
|----|----------|-------|--------|--------------|
| D4.1 | **Security Audit** | Code | Security report | In: 5K, Out: 2K |
| D4.2 | **Vulnerability Assessment** | Code + deps | Vulnerability list | In: 3K, Out: 1K |
| D4.3 | **OWASP Check** | Code | OWASP compliance | In: 3K, Out: 1K |
| D4.4 | **Privacy Review** | Code | Privacy issues | In: 2K, Out: 800 |

---

## Summary: 48 AI Activities

| Category | Count | Complexity | Cost Range | Primary Models |
|----------|-------|------------|------------|----------------|
| **A: Intake** | 16 | Low | $0.00-0.30 | Groq FREE, Gemini, DeepSeek |
| **B: Organize** | 12 | Low-Medium | $0.10-0.50 | GPT-4o-mini, DeepSeek |
| **C: Code** | 19 | Medium-High | $0.25-5.00 | Haiku, DeepSeek, Sonnet |
| **D: Analyze** | 15 | High | $3.00-20.00 | Sonnet, Opus |
| **TOTAL** | **62** | | | |

---

## Activity → Pipeline Mapping

### Pipeline 1: FREE TIER (Categories A1-A5, B1-B2)

```
Activities: A1.1-A5.3, B1.1-B2.4 (28 activities)
Models: Groq FREE → Gemini FREE → DeepSeek $0.28
Use Case: All extraction, parsing, classification
Cost: $0.00 - $0.30 per request
```

### Pipeline 2: BUDGET CODING (Categories C1-C2)

```
Activities: C1.1-C2.5 (10 activities)
Models: DeepSeek $0.28 → Codestral $0.20 → Haiku $0.25
Use Case: Simple code generation and modification
Cost: $0.20 - $1.00 per request
```

### Pipeline 3: QUALITY CODING (Categories C3-C5)

```
Activities: C3.1-C5.4 (13 activities)
Models: Haiku $0.25 → Sonnet $3.00 → Opus $15.00
Use Case: Complex code generation, bugs, refactoring
Cost: $1.00 - $10.00 per request
```

### Pipeline 4: PREMIUM ANALYSIS (Category D)

```
Activities: D1.1-D4.4 (15 activities)
Models: Sonnet $3.00 → Opus $15.00 → Multi-model
Use Case: Code review, architecture, security
Cost: $5.00 - $30.00 per request
```

---

## User Tier → Pipeline Access

| User Tier | Pipeline 1 | Pipeline 2 | Pipeline 3 | Pipeline 4 |
|-----------|------------|------------|------------|------------|
| 🚀 Turbo | ✅ Full | ✅ DeepSeek only | ⚠️ Haiku only | ❌ Limited |
| ⚡ Balanced | ✅ Full | ✅ Full | ✅ Haiku→Sonnet | ✅ Sonnet only |
| 💎 Quality | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| 🔑 BYOK | ✅ User config | ✅ User config | ✅ User config | ✅ User config |

---

## Next Steps

1. **Finalize activity list** - Add any missing activities
2. **Create pipeline code** - Implement 4 pipelines
3. **Build router** - Route activities to correct pipeline
4. **Add fallback logic** - Escalation between tiers
5. **Create user settings UI** - Let users choose tier

---

*Last Updated: January 2, 2026*
*QUAD Framework Documentation*
