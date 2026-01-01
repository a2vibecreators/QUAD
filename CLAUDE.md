# CLAUDE.md - QUAD Framework Website

This file provides guidance to Claude Code when working with the QUAD Framework website.

## Project Overview

**QUAD Framework** (quadframe.work) is the official documentation and learning site for the QUAD methodology - Quick Unified Agentic Development.

**Tech Stack:**
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Deployed on Vercel

## QUAD Development Model - Revolutionary Paradigm Shift

**CRITICAL:** QUAD Platform enables a fundamentally different development approach compared to traditional Agile.

**Traditional Agile (Waterfall in Disguise):**
```
Week 1-2: BA writes 40-page detailed spec
Week 3-6: Developers build based on spec
Week 7-9: Business sees working software
Week 10: "This isn't what we wanted" → Start over
```

**QUAD Model (AI-Accelerated Spiral):**
```
Prerequisites: Company provides UI blueprint + optional Git repo reference
Hour 1: BA writes minimal POC spec (1-2 paragraphs)
Hour 2-8: QUAD AI agents develop and deploy to DEV
Same Day: Business sees working prototype
Same Day: Business provides feedback via email/Slack/Jira
Hours later: QUAD agents iterate based on feedback
Same Day: Deploy to production
```

**Prerequisites Before Development:**
1. **UI Blueprint (Required for UI projects)** - Figma/Sketch design, wireframes, or competitor reference
   - If not available: Blueprint Agent AI interviews company and generates mockup
2. **Sample Git Repo (Optional)** - Existing codebase for style/pattern matching

### Blueprint Agent System (Production Feature)

**Overview:** Blueprint Agent is a real, production-ready feature that helps companies create UI blueprints before QUAD Platform development begins.

**Core Principle:** Keep it simple - UI projects REQUIRE blueprints (hard block), API projects don't.

**Q1 Decisions - Tech Stack & Domain Selection (COMPLETED):**

1. **Multi-step Wizard Flow:**
   - First domain creation: Full multi-step wizard walkthrough
   - Subdomain creation: Inherit parent domain settings (shorter flow)
   - Admin can edit anytime (settings changeable after creation)
   - Subdomain requests changes: Email domain admin to modify parent settings

2. **Tech Stack Usage:** ✅ YES - Generate framework-specific code
   - **Why:** 30-40% faster development (no HTML → React conversion)
   - **Example:** React + Tailwind → generates `<div className="...">` not generic HTML

3. **Domain-Specific Sample Data:** ✅ YES - Pre-populate realistic data
   - **Initial 8 Domains:** Healthcare, Finance/Insurance, E-commerce, SaaS Dashboard, Real Estate, Education, Logistics, CRM
   - **Benefits:** Realistic mockups (not "User 1, User 2"), industry-specific terminology

4. **Domain + Project Type Support Check:** ✅ YES
   - Check database before allowing domain creation
   - If unsupported combination: "⚠️ Not common. Contact us for custom setup."

**Q2 Decisions - Prerequisites Upload Flow (COMPLETED):**

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Blueprint requirement | UI projects = REQUIRED<br>API projects = OPTIONAL | Simple: If it has UI, you need a blueprint |
| When upload happens | During project setup (hard block for UI) | No flexibility = no complexity |
| Multiple blueprints per domain | ✅ YES (per project_subtype) | One domain can have web-internal + web-external |
| Subdomain inherits parent blueprint | ✅ YES (can override) | Saves work, but flexible |
| File storage | URLs ONLY (no file upload yet) | Phase 1: Just URLs, Phase 2: File upload |
| Verify URL accessibility | ✅ YES | Basic validation - ping URL to check it works |
| Auto-screenshot competitor URLs | ✅ YES | Helpful reference - store screenshot for later |
| Allow multiple URLs per blueprint | ✅ YES | Homepage + dashboard = different pages |
| Show preview after pasting URL | ✅ YES | Better UX - show iframe/screenshot |
| Auto-approve uploaded blueprint | ✅ AUTO-APPROVE | Keep simple - user uploaded = approved |

**Database Tables:**
- `QUAD_domain_project_support` - Track which domain + project type combinations are supported
- `QUAD_domain_blueprints` - Store blueprint URLs and Git repo references (URLs only in Phase 1)
- `QUAD_blueprint_agent_sessions` - Track Blueprint Agent conversations and Q&A

**Complete Documentation:** See `/documentation/BLUEPRINT_AGENT_IMPLEMENTATION_PLAN.md` (detailed schemas, user flows, sample data)

**Key Metrics:**
- **Time to first prototype:** 2-8 hours (vs 6-9 weeks traditional)
- **Iteration speed:** 3-5 per day (vs 1 per 2-4 weeks)
- **Cost per feature:** $2K-$10K (vs $50K-$200K)
- **Rework rate:** 5-10% (vs 30-40%)
- **Business satisfaction:** 90-95% (vs 60-70%)

**Communication Channels for Continuous Development:**
1. **Email Agent:** BA sends email to quad-agents@ → Auto-creates Jira ticket → Agents implement
2. **Slack Agent:** "@quad add price filter to products page" → Auto-implements in hours
3. **Jira Agent:** BA updates ticket with new requirement → Auto-implements

**Complete Documentation:** See `/documentation/QUAD_DEVELOPMENT_MODEL.md` (18 pages, real-world examples)

**Website Showcase:** Homepage has prominent "QUAD Revolution" section comparing Traditional Agile vs QUAD Model

---

## Key Features

### 1. Flow-Based Navigation
Pages are organized into 3 flows:
- **EXPLORE** (blue) - Learn about QUAD concepts
- **TRY** (green) - Interactive demos and tools
- **RESOURCES** (purple) - Reference materials

### 2. Methodology Lens
Users can select their background methodology (Agile, Waterfall, Kanban, etc.) and content is shown through that lens - comparing QUAD terms to familiar equivalents.

### 3. Interactive Features
- `/quiz` - Interactive knowledge quiz
- `/cheatsheet` - Searchable terminology reference
- `/demo` - Role-based dashboard demo
- `/configure` - QUAD configuration generator

---

## Future Methodologies (Document Here, Not in UI)

This section documents additional methodologies that could be added to the Methodology Lens feature in the future. These are NOT currently in the UI but are documented for future implementation.

### Planned Additions

| Methodology | Status | Notes |
|-------------|--------|-------|
| **Lean** | Future | Toyota Production System, eliminate waste |
| **XP (Extreme Programming)** | Future | Pair programming, TDD, continuous integration |
| **Crystal** | Future | Family of methodologies based on team size |
| **DSDM** | Future | Dynamic Systems Development Method |
| **FDD** | Future | Feature-Driven Development |
| **RAD** | Future | Rapid Application Development |
| **RUP** | Future | Rational Unified Process |
| **Prince2** | Future | Project management methodology (UK government) |
| **PMI/PMP** | Future | Project Management Institute standards |
| **ITIL** | Future | IT Service Management framework |

### Methodology Comparison Data (For Future Implementation)

#### Lean
```typescript
{
  id: "lean",
  name: "Lean",
  icon: "🏭",
  description: "I know Toyota Production System, value stream mapping, eliminate waste",
  color: "slate",
  mappings: {
    cycle: "Value stream cycle",
    pulse: "Kaizen event",
    checkpoint: "Gemba walk",
    trajectory: "Hoshin Kanri",
    circle1: "Value stream manager",
    circle2: "Production team",
    circle3: "Quality circles",
    circle4: "Maintenance team",
    flowDocument: "A3 report",
    humanGate: "Andon signal",
    docsFirst: "Standard work first",
    aiAgents: "Automation (jidoka)",
  }
}
```

#### XP (Extreme Programming)
```typescript
{
  id: "xp",
  name: "XP",
  icon: "⚡",
  description: "I know pair programming, TDD, continuous integration, refactoring",
  color: "lime",
  mappings: {
    cycle: "Release cycle (1-3 months)",
    pulse: "Iteration (1-2 weeks)",
    checkpoint: "Daily standup",
    trajectory: "Release planning",
    circle1: "Customer + Coach",
    circle2: "Development pairs",
    circle3: "QA (same team)",
    circle4: "Technical practices",
    flowDocument: "Story card + Tests",
    humanGate: "Acceptance test",
    docsFirst: "Tests-first (TDD)",
    aiAgents: "Pair programming AI",
  }
}
```

#### DSDM (Dynamic Systems Development Method)
```typescript
{
  id: "dsdm",
  name: "DSDM",
  icon: "🎯",
  description: "I know MoSCoW prioritization, timeboxing, active user involvement",
  color: "rose",
  mappings: {
    cycle: "Timebox (2-6 weeks)",
    pulse: "Weekly review",
    checkpoint: "Daily coordination",
    trajectory: "Increment",
    circle1: "Business Ambassador + Solution Developer",
    circle2: "Solution Development Team",
    circle3: "Solution Tester",
    circle4: "Technical Coordinator",
    flowDocument: "Prioritized Requirements List (PRL)",
    humanGate: "Facilitated workshop",
    docsFirst: "Active user involvement",
    aiAgents: "MoSCoW AI prioritization",
  }
}
```

#### Prince2
```typescript
{
  id: "prince2",
  name: "Prince2",
  icon: "👑",
  description: "I know project boards, stage gates, exception reports",
  color: "violet",
  mappings: {
    cycle: "Management Stage",
    pulse: "Work Package",
    checkpoint: "Checkpoint Report",
    trajectory: "Project",
    circle1: "Project Board + PM",
    circle2: "Team Manager + Team",
    circle3: "Project Assurance",
    circle4: "Project Support",
    flowDocument: "Product Description",
    humanGate: "Stage Gate / Exception",
    docsFirst: "Product-based planning",
    aiAgents: "Automated reporting",
  }
}
```

### How to Add a New Methodology

1. **Add to MethodologyContext.tsx:**
   - Add new type to `MethodologyType` union
   - Add new entry to `METHODOLOGIES` array

2. **Add to MethodologyLens.tsx:**
   - Add new property to `TermMapping` interface
   - Add mapping values for each term in `METHODOLOGY_MAPPINGS`
   - Add case to `getComparisonValue` switch
   - Add color class to `colorClasses`
   - Add summary text in the lens indicator

3. **Test:**
   - Verify dropdown shows new option
   - Verify comparison table shows correct mappings
   - Verify colors and styling work

---

## URL Versioning System

The QUAD Framework website supports versioning to allow comparing different versions of the methodology.

### Current Implementation

- **Version Badge** in header shows current version (v1.0)
- **Version Context** (`src/context/VersionContext.tsx`) manages version state
- **Version History** dropdown shows changelog

### How to Add a New Version

1. **Update VersionContext.tsx:**
```typescript
export const VERSIONS: VersionInfo[] = [
  {
    version: "2.0",
    displayVersion: "2.0",
    releaseDate: "March 2026",
    isLatest: true,  // Mark this as latest
    changelog: [
      "New feature 1",
      "New feature 2",
    ],
  },
  {
    version: "1.0",
    displayVersion: "1.0",
    releaseDate: "December 2025",
    isLatest: false,  // No longer latest
    changelog: [...],
  },
];
```

2. **Create versioned route (optional):**
If you want to serve archived versions at `/1.0/`, create:
```
src/app/(v1.0)/
├── layout.tsx  # Wrapper with VersionProvider version="1.0"
├── concept/page.tsx
└── ... (copy of old pages)
```

3. **Future Plans:**
- `/1.0/concept` → Version 1.0 of concept page
- `/latest/concept` → Redirects to current version
- `/concept` → Always serves latest

---

## Project Structure

```
quadframework/
├── src/
│   ├── app/                 # Next.js pages
│   │   ├── page.tsx         # Homepage
│   │   ├── concept/         # Main concept page
│   │   ├── details/         # Technical details
│   │   ├── jargons/         # Terminology
│   │   ├── demo/            # Dashboard demo
│   │   ├── quiz/            # Interactive quiz
│   │   ├── cheatsheet/      # Searchable reference
│   │   └── ...
│   ├── components/          # Reusable components
│   │   ├── PageNavigation.tsx
│   │   ├── MethodologySelector.tsx
│   │   ├── MethodologyLens.tsx
│   │   ├── Tooltip.tsx
│   │   └── ...
│   └── context/             # React contexts
│       └── MethodologyContext.tsx
├── public/                  # Static assets
└── CLAUDE.md               # This file
```

---

## Development Commands

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

---

## Key Design Decisions

1. **Methodology Lens in Nav** - Global dropdown so users set their background once and see it across all pages

2. **Context for Persistence** - `MethodologyContext` uses localStorage to persist selection

3. **Flow-Based Navigation** - Pages grouped by purpose (learn → try → resources) with clear progression

4. **No External Dependencies** - Pure CSS animations, no heavy libraries

5. **Mobile First** - All components designed for mobile with desktop enhancements

---

## Related Documentation

- QUAD Methodology docs: `/nutrinine-docs/documentation/methodology/QUAD.md`
- A2Vibe Creators website: `/a2vibecreators-web/`

---

**Author:** Suman Addanki
**Last Updated:** December 31, 2025
