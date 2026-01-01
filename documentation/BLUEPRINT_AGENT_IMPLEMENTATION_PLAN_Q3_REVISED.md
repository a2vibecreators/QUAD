# Q3: Integration Method Flow - REVISED (Blueprint as Attribute)

**Date:** December 31, 2025
**Status:** In Progress

## USER FEEDBACK - CRITICAL DESIGN CHANGE

**User said:** "Blueprint is not a separate step - it's a **requirement attribute** like tech stack or language. When user selects Web App, we ask for blueprint as a field in the same form."

**Old (wrong) approach:**
```
Step 1: Domain creation
Step 2: Blueprint upload (separate page)
Step 3: Integration method
```

**New (correct) approach:**
```
Step 1: Domain creation (includes blueprint as a required field for UI projects)
Step 2: Integration method
```

Blueprint is just another form field/attribute during domain creation, not a separate workflow step.

---

## Q3a: Domain Attributes - Mandatory vs Optional

**Objective:** Design database and form to track which attributes are mandatory/optional based on project_type.

### Attribute Requirements Matrix

| Attribute | Web App | Mobile App | API Only | Landing Page |
|-----------|---------|------------|----------|--------------|
| **Domain name** | ✅ Required | ✅ Required | ✅ Required | ✅ Required |
| **Domain type** | ✅ Required | ✅ Required | ✅ Required | ✅ Required |
| **Project type** | ✅ Required | ✅ Required | ✅ Required | ✅ Required |
| **Frontend framework** | ✅ Required | ✅ Required | ❌ N/A | ✅ Required |
| **CSS framework** | ✅ Required | ✅ Required | ❌ N/A | ✅ Required |
| **Blueprint URL** | ✅ **Required** | ✅ **Required** | ❌ Optional | ✅ **Required** |
| **Git repo URL** | ⚪ Optional | ⚪ Optional | ⚪ Optional | ⚪ Optional |
| **Backend framework** | ⚪ Optional | ⚪ Optional | ✅ Required | ❌ N/A |
| **Database** | ⚪ Optional | ⚪ Optional | ⚪ Optional | ❌ N/A |

### Database Schema Enhancement

Add `is_required` and `applies_to_project_types` columns to track attribute requirements:

```sql
CREATE TABLE QUAD_domain_attribute_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  attribute_name VARCHAR(50) NOT NULL, -- 'blueprint_url', 'tech_stack', 'git_repo', etc.
  applies_to_project_types TEXT[] NOT NULL, -- ['web_app', 'mobile_app', 'landing_page']
  is_required BOOLEAN DEFAULT false,

  validation_rule TEXT, -- 'url', 'enum', 'string', etc.
  default_value TEXT,

  display_order INT, -- Order in the form
  help_text TEXT,

  created_at TIMESTAMP DEFAULT NOW()
);

-- Initial data
INSERT INTO QUAD_domain_attribute_requirements (attribute_name, applies_to_project_types, is_required, validation_rule, display_order, help_text) VALUES
  ('domain_name', ARRAY['web_app', 'mobile_app', 'api', 'landing_page'], true, 'string', 1, 'Choose a unique name for your domain'),
  ('domain_type', ARRAY['web_app', 'mobile_app', 'api', 'landing_page'], true, 'enum', 2, 'Select the industry/domain type'),
  ('project_type', ARRAY['web_app', 'mobile_app', 'api', 'landing_page'], true, 'enum', 3, 'What type of project are you building?'),
  ('frontend_framework', ARRAY['web_app', 'mobile_app', 'landing_page'], true, 'enum', 4, 'Select your frontend framework'),
  ('css_framework', ARRAY['web_app', 'mobile_app', 'landing_page'], true, 'enum', 5, 'Select your CSS framework'),

  -- Blueprint URL - REQUIRED for UI projects
  ('blueprint_url', ARRAY['web_app', 'mobile_app', 'landing_page'], true, 'url', 6, 'Figma/Sketch URL or competitor website reference'),

  -- Git repo - OPTIONAL for all
  ('git_repo_url', ARRAY['web_app', 'mobile_app', 'api', 'landing_page'], false, 'url', 7, 'Optional: Existing codebase for style matching'),

  ('backend_framework', ARRAY['api'], true, 'enum', 8, 'Select your backend framework'),
  ('database', ARRAY['web_app', 'mobile_app', 'api'], false, 'enum', 9, 'Optional: Select database if needed');
```

---

## Q3b: Smart Form with Conditional Fields

### Form Validation Logic (TypeScript)

```typescript
interface DomainFormData {
  domain_name: string;
  domain_type: string; // 'healthcare', 'finance', etc.
  project_type: string; // 'web_app', 'mobile_app', 'api', 'landing_page'

  // Conditional fields (shown/hidden based on project_type)
  frontend_framework?: string;
  css_framework?: string;
  blueprint_url?: string; // REQUIRED if UI project
  git_repo_url?: string; // OPTIONAL always
  backend_framework?: string;
  database?: string;
}

// Smart validation function
function validateDomainForm(data: DomainFormData): ValidationResult {
  const errors: string[] = [];

  // Always required
  if (!data.domain_name) errors.push('Domain name is required');
  if (!data.domain_type) errors.push('Domain type is required');
  if (!data.project_type) errors.push('Project type is required');

  // Conditional requirements based on project_type
  const isUIProject = ['web_app', 'mobile_app', 'landing_page'].includes(data.project_type);
  const isAPIProject = data.project_type === 'api';

  if (isUIProject) {
    // UI projects require frontend stack + blueprint
    if (!data.frontend_framework) errors.push('Frontend framework is required for UI projects');
    if (!data.css_framework) errors.push('CSS framework is required for UI projects');
    if (!data.blueprint_url) errors.push('Blueprint URL is required for UI projects');
  }

  if (isAPIProject) {
    // API projects require backend framework
    if (!data.backend_framework) errors.push('Backend framework is required for API projects');
  }

  // URL validation (if provided)
  if (data.blueprint_url && !isValidURL(data.blueprint_url)) {
    errors.push('Blueprint URL must be a valid URL');
  }

  if (data.git_repo_url && !isValidURL(data.git_repo_url)) {
    errors.push('Git repo URL must be a valid URL');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}
```

---

## Q3c: Revised User Flow (2 Steps, Not 3)

### STEP 1: CREATE DOMAIN (Single Form with Conditional Fields)

**Page:** `/configure/domain/create`

```
┌───────────────────────────────────────────────────────────────┐
│ Create New Domain                                             │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│ Domain Name: *                                                 │
│ [massmutual-claims-dashboard_______]                          │
│                                                                │
│ Domain Type: *                                                 │
│ ◉ Healthcare     ○ Finance      ○ E-commerce                  │
│ ○ SaaS Dashboard ○ Real Estate  ○ Education                   │
│ ○ Logistics      ○ CRM          ○ Other                       │
│                                                                │
│ Project Type: *                                                │
│ ◉ Web App (Internal)  ○ Web App (External)                    │
│ ○ Mobile App (iOS)    ○ Mobile App (Android)                  │
│ ○ API Only            ○ Landing Page                           │
│                                                                │
│ ✅ This combination is supported!                             │
│                                                                │
├─────────────────── CONDITIONAL FIELDS ────────────────────────┤
│                                                                │
│ [IF project_type = web_app/mobile_app/landing_page:]          │
│                                                                │
│ Frontend Framework: *                                          │
│ ◉ Next.js 14   ○ React 18   ○ Vue 3   ○ Angular 17           │
│                                                                │
│ CSS Framework: *                                               │
│ ◉ Tailwind CSS   ○ Bootstrap   ○ Material-UI   ○ Chakra      │
│                                                                │
│ Blueprint URL: * (REQUIRED for UI projects)                    │
│ ┌────────────────────────────────────────────────────────┐   │
│ │ Do you have a UI design?                               │   │
│ │   ◉ Figma/Sketch URL                                   │   │
│ │   ○ Competitor website URL                             │   │
│ │   ○ No - Launch Blueprint Agent AI                     │   │
│ │                                                         │   │
│ │ [If Figma/competitor selected:]                        │   │
│ │ Paste URL: [https://figma.com/abc123_______________]   │   │
│ │                                                         │   │
│ │ [+ Add More URLs] (Dashboard, Login, etc.)             │   │
│ │                                                         │   │
│ │ ✅ URL verified [Preview] [Auto-screenshot]            │   │
│ │                                                         │   │
│ │ [If Blueprint Agent selected:]                         │   │
│ │ [Launch Blueprint Agent Interview →]                   │   │
│ └────────────────────────────────────────────────────────┘   │
│                                                                │
├──────────────────── OPTIONAL FIELDS ──────────────────────────┤
│                                                                │
│ Sample Git Repository (Optional)                               │
│ ☐ I have an existing codebase to reference                    │
│                                                                │
│ [If checked:]                                                  │
│ Git URL: [https://github.com/company/project___________]      │
│ Type: ◉ GitHub  ○ GitLab  ○ Bitbucket                         │
│ ☐ Private repo (link to Vaultwarden for token)                │
│                                                                │
│ Backend Framework (Optional for web/mobile, Required for API) │
│ ○ Node.js + Express   ○ Java Spring Boot                      │
│ ○ Python FastAPI      ○ None                                  │
│                                                                │
│ Database (Optional)                                            │
│ ○ PostgreSQL   ○ MySQL   ○ MongoDB   ○ None                   │
│                                                                │
│                                                                │
│                  [Cancel]        [Create Domain →]             │
└───────────────────────────────────────────────────────────────┘
```

**Form Behavior:**
- All fields start collapsed
- As user selects `project_type`, relevant fields appear with slide-down animation
- Required fields marked with `*`
- Real-time validation (URL check, domain name uniqueness)
- "Create Domain" button disabled until all required fields filled

---

### STEP 2: SELECT INTEGRATION METHOD

**Page:** `/configure/integrations`

```
┌───────────────────────────────────────────────────────────────┐
│ Select Integration Method                                     │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│ ✅ Domain created: massmutual / claims-dashboard              │
│ ✅ Project: Healthcare Web App (Next.js + Tailwind)           │
│ ✅ Blueprint: https://figma.com/... (verified)                │
│                                                                │
│ Now choose how QUAD Platform will connect to your repos:      │
│                                                                │
│ [Three method cards: Webhooks, SSH Polling, MCP Agents]       │
│                                                                │
│ [User selects method → Continue to Setup Guide]               │
└───────────────────────────────────────────────────────────────┘
```

**Note:** Prerequisites checklist REMOVED from IntegrationMethodSelector.tsx (already collected in Step 1)

---

## Q3d: Database Schema for Domain Attributes

**IMPORTANT:** Do NOT add columns to QUAD_domains. Use the Resource/Attribute model instead.

```sql
-- ❌ WRONG APPROACH - Don't do this!
-- ALTER TABLE QUAD_domains ADD COLUMN project_type VARCHAR(50);

-- ✅ CORRECT APPROACH - Attributes as rows in separate table
-- See QUAD_OBJECT_MODEL.md for complete schema

-- Attributes stored as rows (not columns)
CREATE TABLE QUAD_resource_attributes (
  id UUID PRIMARY KEY,
  resource_id UUID REFERENCES QUAD_domain_resources(id),
  attribute_name VARCHAR(50),
  attribute_value TEXT,
  created_at TIMESTAMP
);

-- Attribute requirements with display order (sequence)
CREATE TABLE QUAD_resource_attribute_requirements (
  id UUID PRIMARY KEY,
  resource_type VARCHAR(50),
  attribute_name VARCHAR(50),
  is_required BOOLEAN,
  display_order INT,  -- Controls form field sequence (1, 2, 3...)
  validation_rule VARCHAR(50),
  allowed_values TEXT[]
);
```

**Rationale:**
- Multi-level hierarchy support (unlimited depth via parent_domain_id)
- Attributes as rows allows unlimited expansion without schema changes
- `display_order` controls form field sequence
- See [QUAD_OBJECT_MODEL.md](QUAD_OBJECT_MODEL.md) for complete object model

---

## Q3e: Implementation Impact (REVISED)

### Files to Create
1. `/configure/domain/create` - Single-page domain creation form with conditional fields

### Files to Modify
1. `IntegrationMethodSelector.tsx` - **Remove** prerequisites checklist section (lines 348-489)
2. Create new `DomainCreateForm.tsx` component with smart validation

### Backend APIs
1. `POST /api/domain/create` - Create domain with all attributes
   - Input: DomainFormData
   - Validates required fields based on project_type
   - Creates domain in `QUAD_domains`
   - Creates blueprint record in `QUAD_domain_blueprints` if provided
   - Returns: domain_id

2. `GET /api/domain/validate-name` - Check if domain name is unique
3. `GET /api/domain/blueprints/verify-url` - Verify blueprint URL accessibility
4. `POST /api/domain/blueprints/screenshot` - Auto-screenshot competitor URLs

---

## Summary: Blueprint as Attribute (Not Separate Step)

| Aspect | Old Approach (Wrong) | New Approach (Correct) |
|--------|---------------------|----------------------|
| **Workflow** | 3 steps: Domain → Blueprint → Integration | 2 steps: Domain (includes blueprint) → Integration |
| **Blueprint Input** | Separate page/step | Field in domain creation form |
| **Form Design** | Multi-page wizard | Single smart form with conditional fields |
| **Database** | Separate workflow state | Blueprint is domain attribute |
| **Validation** | Check at Step 2 | Check in real-time during Step 1 |
| **User Experience** | Too many steps | Streamlined, context-aware |

**Key Insight:** Blueprint is not a "thing to upload separately" - it's just another configuration attribute (like tech stack or database), required for UI projects and optional for API projects.

---

**Status:** ✅ Q3 REDESIGNED - Awaiting user confirmation
**Next:** Update BLUEPRINT_AGENT_IMPLEMENTATION_PLAN.md main file with this revised approach
