# Blueprint Agent - Implementation Plan & Decisions

**Date:** December 31, 2025
**Session:** Blueprint Agent & Prerequisites System Design
**Status:** In Progress (Q2 of 10)

---

## Overview

Blueprint Agent is a **real, production-ready feature** that helps companies create UI blueprints before QUAD Platform development begins. This document captures all design decisions, database schemas, and implementation details.

---

## Design Decisions Summary

### Q1: Blueprint Agent - Tech Stack & Domain Selection ✅ COMPLETED

**Decisions Made:**

1. **Multi-step Wizard Flow:**
   - **First domain creation:** Full multi-step wizard (walk through all steps)
   - **Subdomain creation:** Inherit parent domain settings (shorter flow)
   - **Admin can edit anytime:** Settings changeable after creation
   - **Subdomain requests changes:** Email domain admin to modify parent settings

2. **Tech Stack Usage:** ✅ YES - Use tech stack to generate framework-specific code
   - **Why:** 30-40% faster development (no HTML → React conversion)
   - **Benefit:** QUAD agents get copy-paste-ready code in target framework
   - **Example:** React + Tailwind → generates `<div className="...">` not generic HTML

3. **Domain-Specific Sample Data:** ✅ YES - Pre-populate realistic data
   - **Initial 8 Domains:**
     1. Healthcare (HIPAA-compliant patterns, patient records)
     2. Finance/Insurance (secure transactions, policies, claims)
     3. E-commerce (products, cart, checkout)
     4. SaaS Dashboard (users, metrics, analytics)
     5. Real Estate (properties, listings, map integration)
     6. Education (students, courses, LMS)
     7. Logistics (shipments, tracking, warehouses)
     8. CRM (contacts, deals, pipeline)
   - **Benefits:**
     - Realistic mockups (not "User 1, User 2")
     - Industry-specific terminology
     - Pre-configured data types

4. **Domain → Project Type → Blueprint Support Check:** ✅ YES
   - **Flow:**
     ```
     User selects: Healthcare + Web App
       ↓
     Check database: Is this combination supported?
       ↓
     If YES: "✅ Fully supported! Do you have a blueprint or need help creating one?"
     If NO: "⚠️ Not common. Contact us for custom setup."
     ```
   - **Database Table:** `domain_project_support`

---

### Q2: Prerequisites Upload Flow - SIMPLIFIED ✅ COMPLETED

**Core Principle:** Keep it simple - no complexity!

**Confirmed Decisions:**

| Question ID | Question | Decision | Rationale |
|-------------|----------|----------|-----------|
| **Q2-CORE** | Blueprint requirement | UI projects = REQUIRED<br>API projects = OPTIONAL | Simple: If it has UI, you need a blueprint |
| **Q2a** | When does upload happen? | During project setup (hard block for UI) | No flexibility = no complexity |
| **Q2b-1** | Multiple blueprints per domain? | ✅ YES (per project_subtype) | One domain can have web-internal + web-external |
| **Q2b-2** | Subdomain inherits parent blueprint? | ✅ YES (can override) | Saves work, but flexible |
| **Q2b-3** | File storage? | URLs ONLY (no file upload yet) | Phase 1: Just URLs, Phase 2: File upload |
| **Q2c-complexity** | Reminders? Policies? Approval flows? | ❌ REMOVED ALL | Too complex, not needed |

**Completed with Sensible Defaults (Keep it Simple):**

| Question ID | Question | Options | Decision | Rationale |
|-------------|----------|---------|----------|-----------|
| **Q2b-3-1** | Verify URL accessibility? | Yes / No | ✅ YES | Basic validation - ping URL to check it works |
| **Q2b-3-3** | Auto-screenshot competitor URLs? | Yes / No | ✅ YES | Helpful reference - store screenshot for later |
| **Q2c-1** | Allow multiple URLs per blueprint? | Yes / No | ✅ YES | Homepage + dashboard = different pages |
| **Q2c-2** | Show preview after pasting URL? | Yes / No | ✅ YES | Better UX - show iframe/screenshot |
| **Q2d** | Auto-approve uploaded blueprint? | Auto-approve / Requires approval | ✅ AUTO-APPROVE | Keep simple - user uploaded = approved |

---

### Q3: Integration Method Flow - Complete User Journey 🔄 IN PROGRESS

**Objective:** Define the complete end-to-end flow from domain creation to development start, showing how blueprint upload integrates with integration method selection.

**Current State Analysis:**

1. **Existing UI Component:** [IntegrationMethodSelector.tsx](../src/components/IntegrationMethodSelector.tsx)
   - Shows 3 integration methods: Webhooks, SSH Polling, MCP Agents
   - Has prerequisites checklist that appears when method selected
   - Saves to `/api/integrations/configure` endpoint
   - Redirects to setup guides: `/configure/integrations/{method}`

2. **Current Flow (as implemented):**
   ```
   User selects integration method (Webhooks/SSH/MCP)
     ↓
   Prerequisites checklist appears:
     - UI Blueprint (Required)
     - Sample Git Repo (Optional)
     ↓
   User clicks "Continue to Setup Guide"
     ↓
   Redirects to method-specific setup page
   ```

**Questions for Complete Flow Design:**

**Q3a: When does domain creation happen relative to integration method selection?**
   - Option A: Domain creation FIRST → Then integration method → Then blueprint upload
   - Option B: Integration method FIRST → Then domain creation → Then blueprint upload
   - Option C: Blueprint upload FIRST → Then domain creation → Then integration method
   - **Recommended:** Option A (logical progression: Create workspace → Configure how to connect → Provide design assets)

**Q3b: Should blueprint upload be a separate page or inline with integration method selector?**
   - Option A: Inline (current IntegrationMethodSelector.tsx shows checklist, clicking opens modal/form)
   - Option B: Separate page (`/configure/integrations/blueprints` before method selection)
   - Option C: Wizard step (multi-step flow: Step 1 = Domain, Step 2 = Blueprint, Step 3 = Method)
   - **Recommended:** Option C (wizard is most intuitive, matches multi-step approach from Q1)

**Q3c: What happens if user skips blueprint upload (for API-only projects)?**
   - Option A: Hard block - cannot proceed until blueprint provided (too strict?)
   - Option B: Show warning banner but allow proceed (recommended for flexibility)
   - Option C: Check project_type: If UI project → block, if API project → allow skip
   - **Recommended:** Option C (smart detection based on project type)

**Q3d: Where should Git repo URL input happen?**
   - Option A: Same page as blueprint upload (single "Prerequisites" page)
   - Option B: Separate page after blueprint upload
   - Option C: Optional field on integration method selector page
   - **Recommended:** Option A (both are prerequisites, group together)

**Q3e: Integration method setup guides - what do they contain?**
   - Option A: Generic instructions (current state)
   - Option B: Auto-populated with domain info (company name, project type, blueprint URL)
   - Option C: Interactive wizard that calls backend APIs to configure
   - **Recommended:** Option C (full automation, least manual work)

**Proposed Complete User Journey (Wizard Approach):**

```
═══════════════════════════════════════════════════════════════════════════
STEP 1: CREATE DOMAIN (Multi-step wizard from Q1)
═══════════════════════════════════════════════════════════════════════════

Page: /configure/domain/create

Sub-step 1a: Domain Type Selection
  ┌─────────────────────────────────────────────────────────────┐
  │ Select Your Domain & Project Type                           │
  ├─────────────────────────────────────────────────────────────┤
  │                                                              │
  │ Domain Type:                                                 │
  │   ◉ Healthcare     ○ Finance      ○ E-commerce              │
  │   ○ SaaS Dashboard ○ Real Estate  ○ Education               │
  │   ○ Logistics      ○ CRM          ○ Other (Custom)          │
  │                                                              │
  │ Project Type:                                                │
  │   ◉ Web App (Internal)  ○ Web App (External)                │
  │   ○ Mobile App (iOS)    ○ Mobile App (Android)              │
  │   ○ API Only            ○ Landing Page                       │
  │                                                              │
  │ ✅ This combination is fully supported!                     │
  │                                                              │
  │                    [Continue to Tech Stack →]                │
  └─────────────────────────────────────────────────────────────┘

Sub-step 1b: Tech Stack Selection
  ┌─────────────────────────────────────────────────────────────┐
  │ Select Your Tech Stack                                       │
  ├─────────────────────────────────────────────────────────────┤
  │                                                              │
  │ Frontend Framework:                                          │
  │   ◉ Next.js 14   ○ React 18   ○ Vue 3   ○ Angular 17       │
  │                                                              │
  │ CSS Framework:                                               │
  │   ◉ Tailwind CSS   ○ Bootstrap   ○ Material-UI   ○ Chakra  │
  │                                                              │
  │ Backend (Optional - for full-stack):                         │
  │   ○ Node.js + Express   ○ Java Spring Boot                  │
  │   ○ Python FastAPI      ○ None (frontend only)              │
  │                                                              │
  │ Database (Optional):                                         │
  │   ○ PostgreSQL   ○ MySQL   ○ MongoDB   ○ None               │
  │                                                              │
  │           [← Back]              [Continue to Prerequisites →]│
  └─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
STEP 2: UPLOAD PREREQUISITES (Blueprint + Git Repo)
═══════════════════════════════════════════════════════════════════════════

Page: /configure/prerequisites

  ┌─────────────────────────────────────────────────────────────┐
  │ 📋 Prerequisites Before Development                         │
  ├─────────────────────────────────────────────────────────────┤
  │                                                              │
  │ 1. UI Blueprint (REQUIRED for Web/Mobile projects)          │
  │                                                              │
  │    Do you have a UI design?                                 │
  │      ◉ Yes, I have a Figma/Sketch design                    │
  │      ○ Yes, I have wireframes/screenshots                   │
  │      ○ Yes, use this competitor website as reference        │
  │      ○ No, I need help creating one (Blueprint Agent)       │
  │                                                              │
  │    [If "Yes, I have..." selected:]                          │
  │    ┌───────────────────────────────────────────────────┐   │
  │    │ Paste URL:                                        │   │
  │    │ https://figma.com/file/abc123...                  │   │
  │    │                                                    │   │
  │    │ [+ Add More URLs] (Homepage, Dashboard, etc.)     │   │
  │    │                                                    │   │
  │    │ ✅ URL verified and accessible                    │   │
  │    │ [Preview →] [Auto-screenshot ✓]                   │   │
  │    └───────────────────────────────────────────────────┘   │
  │                                                              │
  │    [If "No, I need help..." selected:]                      │
  │    ┌───────────────────────────────────────────────────┐   │
  │    │ 🤖 Launch Blueprint Agent                         │   │
  │    │                                                    │   │
  │    │ Our AI will interview you with 5-10 questions    │   │
  │    │ and generate a mockup website based on your      │   │
  │    │ answers. You can review and iterate before       │   │
  │    │ approving the final design.                       │   │
  │    │                                                    │   │
  │    │        [Start Blueprint Agent Interview →]        │   │
  │    └───────────────────────────────────────────────────┘   │
  │                                                              │
  │ 2. Sample Git Repo (Optional - helps match your style)      │
  │                                                              │
  │    ☐ I have an existing codebase to reference               │
  │                                                              │
  │    [If checked:]                                             │
  │    ┌───────────────────────────────────────────────────┐   │
  │    │ Git Repository URL:                               │   │
  │    │ https://github.com/company/existing-project       │   │
  │    │                                                    │   │
  │    │ Repository Type:  ◉ GitHub  ○ GitLab  ○ Bitbucket│   │
  │    │                                                    │   │
  │    │ ☐ Private repo (provide access token below)      │   │
  │    │                                                    │   │
  │    │ [Link to Vaultwarden for token storage →]        │   │
  │    └───────────────────────────────────────────────────┘   │
  │                                                              │
  │           [← Back]         [Continue to Integration Method →]│
  └─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
STEP 3: SELECT INTEGRATION METHOD (Webhooks/SSH/MCP)
═══════════════════════════════════════════════════════════════════════════

Page: /configure/integrations

  [Existing IntegrationMethodSelector.tsx component]

  - Shows 3 methods: Webhooks, SSH Polling, MCP Agents
  - User selects one
  - Prerequisites checklist REMOVED (already done in Step 2)
  - Click "Continue" → Redirects to method-specific setup

═══════════════════════════════════════════════════════════════════════════
STEP 4: METHOD-SPECIFIC SETUP GUIDE (Auto-configured)
═══════════════════════════════════════════════════════════════════════════

Page: /configure/integrations/{method} (webhooks, ssh, or mcp)

Example for Webhooks:
  ┌─────────────────────────────────────────────────────────────┐
  │ 🔗 Webhook Setup for Your Domain                            │
  ├─────────────────────────────────────────────────────────────┤
  │                                                              │
  │ We'll auto-configure webhooks for your repositories.        │
  │                                                              │
  │ ✅ Domain: massmutual / insurance-division                  │
  │ ✅ Project Type: Healthcare Web App                         │
  │ ✅ Tech Stack: Next.js 14 + Tailwind CSS                    │
  │ ✅ Blueprint: https://figma.com/... (verified)              │
  │ ✅ Git Repo: https://github.com/massmutual/claims-portal    │
  │                                                              │
  │ Step 1: Provide GitHub Personal Access Token                │
  │   (We'll use it ONCE to create webhooks, then delete it)    │
  │                                                              │
  │   Token: [●●●●●●●●●●●●●●●●●●●●●●●●●●●●] [Generate Token →]│
  │                                                              │
  │   Required Scopes: repo, admin:repo_hook                     │
  │                                                              │
  │ Step 2: We'll auto-create these webhooks:                   │
  │   ☐ Push events → https://api.quadframe.work/webhooks/push │
  │   ☐ Pull request → https://api.quadframe.work/webhooks/pr  │
  │   ☐ Issue comments → .../webhooks/issue                     │
  │                                                              │
  │ Step 3: Firewall Configuration (if self-hosted)             │
  │   Add these IPs to allowlist: [Copy IPs]                    │
  │                                                              │
  │                [← Back]           [Auto-Configure Webhooks →]│
  │                                                              │
  │ [Auto-Configure] button will:                               │
  │   1. Validate token                                          │
  │   2. Create webhooks via GitHub API                         │
  │   3. Test webhook delivery                                   │
  │   4. Delete token from our system                           │
  │   5. Redirect to dashboard → "✅ Setup Complete!"           │
  └─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
STEP 5: DASHBOARD - READY TO DEVELOP
═══════════════════════════════════════════════════════════════════════════

Page: /dashboard

  ┌─────────────────────────────────────────────────────────────┐
  │ ✅ Domain Setup Complete!                                   │
  ├─────────────────────────────────────────────────────────────┤
  │                                                              │
  │ Your QUAD Platform is ready to start development.           │
  │                                                              │
  │ Domain: massmutual / insurance-division                      │
  │ Project: Healthcare Web App (Next.js + Tailwind)            │
  │ Blueprint: ✅ Approved                                       │
  │ Integration: ✅ Webhooks configured                         │
  │                                                              │
  │ Next steps:                                                  │
  │   1. BA writes minimal POC spec (1-2 paragraphs)            │
  │   2. Create Jira ticket or send email to quad-agents@       │
  │   3. QUAD agents will build and deploy to DEV in 2-8 hours  │
  │                                                              │
  │            [Create First Feature Request →]                  │
  └─────────────────────────────────────────────────────────────┘
```

**Key Decisions for Q3:**

| Decision ID | Question | Recommended Choice | Rationale |
|-------------|----------|-------------------|-----------|
| **Q3a** | Flow order | Domain → Blueprint → Integration Method | Logical progression |
| **Q3b** | Blueprint upload UI | Wizard step (separate page) | Most intuitive, clear steps |
| **Q3c** | Skip blueprint? | Allow skip for API-only projects | Smart detection based on project_type |
| **Q3d** | Git repo input | Same page as blueprint | Group prerequisites together |
| **Q3e** | Setup guides | Interactive auto-configure | Full automation, least manual work |

**Implementation Impact:**

1. **Files to Create:**
   - `/configure/domain/create` - Domain creation wizard (Steps 1a-1b)
   - `/configure/prerequisites` - Blueprint + Git repo upload (Step 2)
   - Keep existing `/configure/integrations` - Integration method selector (Step 3)
   - Enhance `/configure/integrations/{method}` - Auto-configured setup guides (Step 4)

2. **Files to Modify:**
   - `IntegrationMethodSelector.tsx` - Remove prerequisites checklist (moved to Step 2)
   - Create new wizard component with step indicator

3. **Backend APIs to Create:**
   - `POST /api/domain/create` - Create domain with tech stack
   - `POST /api/domain/blueprints/upload` - Store blueprint URLs
   - `GET /api/domain/blueprints/verify-url` - Verify URL accessibility
   - `POST /api/domain/blueprints/screenshot` - Auto-screenshot competitor URLs
   - `POST /api/integrations/webhooks/auto-configure` - Auto-setup webhooks
   - `POST /api/integrations/ssh/generate-key` - Generate SSH keys
   - `POST /api/integrations/mcp/install` - Install MCP agent

**Status:** ⏳ AWAITING USER FEEDBACK on Q3a-Q3e

---

### Q4-Q10: Remaining Questions ⏳ PENDING

| Question | Topic | Status |
|----------|-------|--------|
| Q4 | Blueprint Formats - Support all formats | Pending |
| Q5 | Sample Git Repo - What we accept and process | Pending |
| Q6 | Homepage Integration - Prerequisites on homepage? | Pending |
| Q7 | Additional Prerequisites - Other required items | Pending |
| Q8 | Blueprint Agent Questions - Question set definition | Pending |
| Q9 | Visual Design Review - Current design confirmation | Pending |
| Q10 | Documentation vs Website - Dedicated pages | Pending |

---

## Database Schema

### 1. Domain Project Support Table

**Purpose:** Track which domain + project type combinations are supported

```sql
CREATE TABLE QUAD_domain_project_support (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Domain and project type
  domain VARCHAR(50) NOT NULL, -- 'healthcare', 'finance', 'e_commerce', etc.
  project_type VARCHAR(50) NOT NULL, -- 'web_app', 'mobile_app', 'api', 'landing_page'

  -- Support status
  supported BOOLEAN DEFAULT true,
  template_available BOOLEAN DEFAULT false,
  sample_data_included BOOLEAN DEFAULT false,

  -- Metadata
  description TEXT,
  recommended_tech_stacks TEXT[], -- ['react', 'nextjs', 'tailwind']

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(domain, project_type)
);

-- Indexes
CREATE INDEX idx_domain_support_domain ON QUAD_domain_project_support(domain);
CREATE INDEX idx_domain_support_type ON QUAD_domain_project_support(project_type);
CREATE INDEX idx_domain_support_combo ON QUAD_domain_project_support(domain, project_type);

-- Initial data (8 domains × 4 project types = 32 combinations)
INSERT INTO QUAD_domain_project_support (domain, project_type, supported, template_available, sample_data_included, recommended_tech_stacks) VALUES
  -- Healthcare
  ('healthcare', 'web_app', true, true, true, ARRAY['react', 'nextjs', 'tailwind']),
  ('healthcare', 'mobile_app', true, true, true, ARRAY['react_native', 'flutter']),
  ('healthcare', 'api', true, false, false, ARRAY['nodejs', 'java_spring', 'python_fastapi']),
  ('healthcare', 'landing_page', true, true, false, ARRAY['nextjs', 'astro']),

  -- Finance/Insurance
  ('finance', 'web_app', true, true, true, ARRAY['react', 'nextjs', 'tailwind']),
  ('finance', 'mobile_app', true, true, true, ARRAY['react_native', 'flutter']),
  ('finance', 'api', true, false, false, ARRAY['java_spring', 'nodejs']),
  ('finance', 'landing_page', true, true, false, ARRAY['nextjs']),

  -- E-commerce
  ('e_commerce', 'web_app', true, true, true, ARRAY['nextjs', 'react', 'shopify']),
  ('e_commerce', 'mobile_app', true, true, true, ARRAY['react_native', 'flutter']),
  ('e_commerce', 'api', true, false, false, ARRAY['nodejs', 'python']),
  ('e_commerce', 'landing_page', true, true, false, ARRAY['nextjs', 'webflow']),

  -- Continue for remaining 5 domains...
  ;
```

---

### 2. Domain Blueprints Table (SIMPLIFIED - URLs Only)

**Purpose:** Store blueprint URLs and Git repo references

**Phase 1 Approach:** URLs only - no file upload

```sql
CREATE TABLE QUAD_domain_blueprints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID REFERENCES QUAD_domains(id) ON DELETE CASCADE,

  -- Blueprint info (URL-based only for Phase 1)
  blueprint_type VARCHAR(50) NOT NULL,
  -- 'figma_url', 'sketch_cloud_url', 'adobe_xd_url', 'sharepoint_url',
  -- 'google_drive_url', 'competitor_website_url', 'blueprint_agent_generated'

  blueprint_url TEXT NOT NULL, -- The actual URL (Figma, SharePoint, competitor site, etc.)

  -- Multiple URLs (e.g., homepage wireframe URL + dashboard wireframe URL)
  additional_urls JSONB DEFAULT '[]',
  -- [
  --   {"name": "Dashboard Page", "url": "https://figma.com/...", "screenshot_url": "s3://..."},
  --   {"name": "Login Page", "url": "https://figma.com/...", "screenshot_url": "s3://..."}
  -- ]

  -- Auto-screenshot for competitor URLs (Q2b-3-3: YES)
  screenshot_url TEXT, -- Auto-captured screenshot stored in S3/GCP (for competitor URLs)
  url_verified BOOLEAN DEFAULT false, -- Q2b-3-1: YES - ping URL to check accessibility
  url_verification_date TIMESTAMP,

  -- Project context
  project_type VARCHAR(50), -- 'web_app', 'mobile_app', 'api', 'landing_page'
  project_subtype VARCHAR(50), -- 'web_internal', 'web_external', 'mobile_ios', 'mobile_android'

  -- Inheritance (Q2b-2: YES - subdomain inherits parent blueprint)
  inherited_from_domain_id UUID REFERENCES QUAD_domains(id),
  -- NULL = own blueprint, UUID = inherited from parent

  -- Git repo info (optional)
  git_repo_url TEXT,
  git_repo_type VARCHAR(20), -- 'github', 'gitlab', 'bitbucket'
  git_access_token_vault_path TEXT, -- Path to token in Vaultwarden (if private repo)

  -- Blueprint Agent metadata (if used)
  blueprint_agent_session_id UUID, -- Link to agent conversation
  blueprint_agent_answers JSONB, -- Answers to Blueprint Agent questions
  blueprint_agent_mockup_url TEXT, -- URL to generated mockup

  -- Tech stack context (from Q1)
  tech_stack VARCHAR(50), -- 'react', 'nextjs', 'vue', 'angular'
  css_framework VARCHAR(50), -- 'tailwind', 'bootstrap', 'mui', 'chakra'

  -- Status (Q2d: AUTO-APPROVE)
  blueprint_status VARCHAR(20) DEFAULT 'approved', -- Auto-approve when uploaded

  -- Metadata
  uploaded_by UUID REFERENCES users(id),
  uploaded_at TIMESTAMP DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_domain_blueprints_domain ON QUAD_domain_blueprints(domain_id);
CREATE INDEX idx_domain_blueprints_status ON QUAD_domain_blueprints(blueprint_status);
CREATE INDEX idx_domain_blueprints_type ON QUAD_domain_blueprints(blueprint_type);
CREATE INDEX idx_domain_blueprints_agent_session ON QUAD_domain_blueprints(blueprint_agent_session_id);
CREATE INDEX idx_domain_blueprints_inherited ON QUAD_domain_blueprints(inherited_from_domain_id);

-- Trigger to update updated_at
CREATE TRIGGER update_domain_blueprints_updated_at
  BEFORE UPDATE ON QUAD_domain_blueprints
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### 3. Blueprint Agent Sessions Table

**Purpose:** Track Blueprint Agent conversations and Q&A

```sql
CREATE TABLE QUAD_blueprint_agent_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),

  -- Session info
  status VARCHAR(20) DEFAULT 'in_progress', -- 'in_progress', 'completed', 'abandoned'
  current_step INT DEFAULT 1, -- Which question is the agent on?

  -- Domain and project context
  domain_type VARCHAR(50), -- 'healthcare', 'finance', etc.
  project_type VARCHAR(50), -- 'web_app', 'mobile_app', etc.
  tech_stack VARCHAR(50), -- 'react', 'nextjs', etc.

  -- Questions and answers (JSONB for flexibility)
  questions_answers JSONB DEFAULT '[]',
  /*
  [
    {
      "question_id": "q1_purpose",
      "question_text": "What's the main purpose of this page/feature?",
      "answer": "Insurance claims dashboard for agents",
      "answered_at": "2025-12-31T10:30:00Z"
    },
    {
      "question_id": "q2_users",
      "question_text": "Who will use this?",
      "answer": "Insurance agents who process claims",
      "answered_at": "2025-12-31T10:31:00Z"
    }
  ]
  */

  -- Generated mockup
  mockup_url TEXT, -- https://blueprint.quadframe.work/massmutual-claims-v1
  mockup_deployed_at TIMESTAMP,
  mockup_approved BOOLEAN DEFAULT false,

  -- Iteration history (user requests changes)
  iterations JSONB DEFAULT '[]',
  /*
  [
    {
      "iteration": 1,
      "user_feedback": "Add date range filter at the top",
      "mockup_url": "https://blueprint.quadframe.work/massmutual-claims-v2",
      "completed_at": "2025-12-31T11:00:00Z"
    }
  ]
  */

  -- Timestamps
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  abandoned_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_blueprint_sessions_domain ON QUAD_blueprint_agent_sessions(domain_id);
CREATE INDEX idx_blueprint_sessions_user ON QUAD_blueprint_agent_sessions(user_id);
CREATE INDEX idx_blueprint_sessions_status ON QUAD_blueprint_agent_sessions(status);
```

---

## User Flows

### Flow 1: Domain Creation with Blueprint Agent

```
Step 1: Select Domain Type & Project Type
  User: "I want to build a Healthcare Web App"
    ↓
  System checks: domain_project_support table
    ↓
  Result: ✅ Supported, template available, sample data included

Step 2: Select Tech Stack
  Options: React, Next.js, Vue, Angular
  User selects: Next.js + Tailwind CSS
    ↓
  System notes: tech_stack='nextjs', css_framework='tailwind'

Step 3: Blueprint Options
  [A] I have a Figma/Sketch design
  [B] I have wireframes/screenshots
  [C] I have a competitor website to copy
  [D] I don't have anything - help me create one ← User selects this
    ↓

Step 4: Blueprint Agent Interview
  Creates new record in blueprint_agent_sessions
    ↓
  Agent asks questions (stored in questions_answers JSONB)
    ↓
  Q1: Main purpose? → "Claims dashboard for agents"
  Q2: Who uses it? → "Insurance agents"
  Q3: What data? → "Claim ID, customer name, amount, date, status"
  Q4: Similar page? → "https://massmutual.com/policies"
    ↓

Step 5: Mockup Generation
  Agent generates mockup using:
    - Domain type (Healthcare)
    - Project type (Web App)
    - Tech stack (Next.js + Tailwind)
    - Sample data (Healthcare-specific)
    - User answers
    - Competitor reference
    ↓
  Deploys to: https://blueprint.quadframe.work/massmutual-claims-v1
    ↓
  Updates: mockup_url, mockup_deployed_at

Step 6: User Review & Iteration
  User: "Looks great! Add date range filter"
    ↓
  Agent updates mockup (v2)
    ↓
  Stores iteration in iterations JSONB array
    ↓
  User: "Perfect! Approve"
    ↓
  Updates: mockup_approved=true, completed_at=NOW()

Step 7: Store Final Blueprint
  Creates record in QUAD_domain_blueprints:
    - blueprint_type='blueprint_agent_generated'
    - blueprint_url=mockup_url
    - blueprint_agent_session_id=session.id
    - tech_stack='nextjs'
    - blueprint_status='approved'
    ↓
  QUAD development agents can now use this blueprint
```

---

### Flow 2: Upload Existing Blueprint (Figma/Wireframes)

```
User selects: "I have a Figma design"
  ↓
Paste Figma URL: https://figma.com/file/abc123...
  ↓
[Optional] Verify Figma access (ping Figma API)
  ↓
Store in QUAD_domain_blueprints:
  - blueprint_type='figma'
  - blueprint_url='https://figma.com/file/abc123...'
  - blueprint_status='uploaded'
  ↓
If approval required:
  Notify DOMAIN_ADMIN → Review → Approve/Reject
Else:
  Auto-approve → blueprint_status='approved'
```

---

## Implementation Phases

### Phase 1: Database Setup ✅ DESIGNED (Not yet implemented)
- [ ] Create `QUAD_domain_project_support` table
- [ ] Create `QUAD_domain_blueprints` table
- [ ] Create `QUAD_blueprint_agent_sessions` table
- [ ] Populate initial 8 domains × 4 project types = 32 support records

### Phase 2: Blueprint Upload UI (Q2-Q4) 🔄 IN PROGRESS
- [ ] Decide upload timing (Q2a)
- [ ] Implement file upload component (drag-and-drop or button)
- [ ] Support multiple blueprint types (Figma, wireframes, competitor URL)
- [ ] Implement file storage (S3/GCP/local)
- [ ] Add approval workflow (if needed)

### Phase 3: Blueprint Agent AI (Q8) ⏳ PENDING
- [ ] Define question set (5-10 questions)
- [ ] Build interactive Q&A interface
- [ ] Integrate with mockup generation (v0.dev or custom)
- [ ] Deploy mockup to temporary URL (blueprint.quadframe.work)
- [ ] Implement iteration flow (user feedback → update mockup)

### Phase 4: Tech Stack & Domain Selection (Q1) ⏳ PENDING
- [ ] Create multi-step wizard UI
- [ ] Domain type selector (8 initial domains)
- [ ] Project type selector (4 types)
- [ ] Tech stack selector (framework + CSS)
- [ ] Domain support validation
- [ ] Sample data loading based on domain

### Phase 5: Integration with QUAD Agents ⏳ PENDING
- [ ] QUAD agents read blueprint from database
- [ ] Parse Figma designs (if applicable)
- [ ] Use tech stack info to generate correct code
- [ ] Apply domain-specific patterns (HIPAA for healthcare, etc.)

---

## Technical Decisions

### File Storage Strategy

**Recommendation:** Support all three based on deployment type

```typescript
// Environment-aware file storage
if (process.env.DEPLOYMENT_TYPE === 'cloud') {
  // Use AWS S3 or GCP Cloud Storage
  uploadToS3(file);
} else if (process.env.DEPLOYMENT_TYPE === 'self-hosted') {
  // Use local filesystem
  uploadToLocalStorage(file);
} else {
  // Default: GCP Cloud Storage (QUAD Platform default)
  uploadToGCP(file);
}
```

**File paths:**
- AWS S3: `s3://quad-blueprints/{company_id}/{domain_id}/{filename}`
- GCP: `gs://quad-blueprints/{company_id}/{domain_id}/{filename}`
- Local: `/var/quad/blueprints/{company_id}/{domain_id}/{filename}`

---

## Sample Data Templates

### Healthcare Domain - Claims Dashboard

```json
{
  "domain": "healthcare",
  "project_type": "web_app",
  "sample_data": {
    "claims": [
      {
        "claim_id": "CLM-2025-001234",
        "patient_name": "John Smith",
        "diagnosis": "Hypertension",
        "claim_amount": "$1,250.00",
        "submission_date": "2025-01-15",
        "status": "pending_review",
        "priority": "normal"
      },
      {
        "claim_id": "CLM-2025-001235",
        "patient_name": "Sarah Johnson",
        "diagnosis": "Diabetes Type 2",
        "claim_amount": "$3,400.00",
        "submission_date": "2025-01-10",
        "status": "approved",
        "priority": "high"
      }
    ],
    "terminology": {
      "user": "Patient",
      "record": "Medical Record",
      "transaction": "Claim",
      "id_prefix": "CLM-"
    }
  }
}
```

### Finance Domain - Transaction Dashboard

```json
{
  "domain": "finance",
  "project_type": "web_app",
  "sample_data": {
    "transactions": [
      {
        "transaction_id": "TXN-9812",
        "account_holder": "Michael Chen",
        "amount": "$1,250.00",
        "type": "deposit",
        "date": "2025-01-20",
        "status": "completed"
      },
      {
        "transaction_id": "TXN-9813",
        "account_holder": "Emily Davis",
        "amount": "-$45.99",
        "type": "withdrawal",
        "date": "2025-01-19",
        "status": "pending"
      }
    ],
    "terminology": {
      "user": "Account Holder",
      "record": "Transaction",
      "id_prefix": "TXN-"
    }
  }
}
```

---

## Integration Points

### 1. Domain Creation Flow
- **Current:** `/configure/integrations` page shows prerequisites
- **New:** Add blueprint upload step before integration method selection

### 2. QUAD Development Agents
- **Input:** Read from `QUAD_domain_blueprints` table
- **Usage:**
  - Parse blueprint (Figma API, image analysis, competitor screenshot)
  - Generate code matching tech stack
  - Use domain-specific sample data

### 3. Dashboard Warnings
- **If no blueprint:** Show "⚠️ Upload blueprint to start development"
- **If blueprint uploaded but not approved:** Show "⏳ Blueprint pending approval"
- **If blueprint approved:** Show "✅ Blueprint ready. Start development"

---

## Next Steps

1. ✅ Q1 COMPLETED: Tech stack & domain selection (multi-step wizard, 8 domains, support checking)
2. ✅ Q2 COMPLETED: Upload flow decisions (URLs only, auto-approve, multiple URLs, previews)
3. 🔄 Q3 IN PROGRESS: Define complete integration method flow
4. ⏳ Q4: Implement all blueprint format support
5. ⏳ Q5: Git repo handling (clone, analyze, etc.)
6. ⏳ Q6-Q10: Remaining questions

---

## Notes & Reminders

### For Auto-Compact (Context Limit)
When this conversation gets auto-compacted, preserve:
1. ✅ All database schemas above
2. ✅ All design decisions in Q1 (completed)
3. ✅ Pending decisions in Q2 (in progress)
4. ✅ User flows and implementation phases
5. ✅ Tech stack recommendation (use framework-specific code generation)
6. ✅ 8 initial domains with sample data

### Key User Preferences
- ✅ Multi-step wizard for first domain (full walkthrough)
- ✅ Subdomain inherits parent settings (shorter flow)
- ✅ Subdomain requests changes via email to domain admin
- ✅ Tech stack awareness in blueprint generation (30-40% faster)
- ✅ Domain-specific sample data (realistic, not generic)

---

**Document Version:** 1.0
**Last Updated:** December 31, 2025
**Next Update:** After Q2 completion
