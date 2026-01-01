# Blueprint Agent Implementation - Q4 through Q10

**Date:** December 31, 2025
**Status:** Completing remaining questions

---

## Q4: Blueprint Formats - Support All Formats ✅

**Objective:** Define how we accept and process different blueprint formats

### Accepted Blueprint Formats

| Format | Type | How We Handle | Storage |
|--------|------|---------------|---------|
| **Figma URL** | Design tool | Paste URL → Verify accessible → Store URL | `blueprint_url` attribute |
| **Sketch Cloud URL** | Design tool | Paste URL → Verify accessible → Store URL | `blueprint_url` attribute |
| **Adobe XD Share Link** | Design tool | Paste URL → Verify accessible → Store URL | `blueprint_url` attribute |
| **Competitor Website** | Live website | Paste URL → Auto-screenshot → Store both | `blueprint_url` + `screenshot_url` |
| **Wireframe Image** | Image file | Upload to S3/GCP → Store URL | `blueprint_url` (S3 URL) |
| **Blueprint Agent Generated** | AI-generated | Agent creates mockup → Deploy → Store URL | `blueprint_url` + `blueprint_agent_session_id` |

### Resource Attribute Model

**IMPORTANT:** Blueprint is stored as a **resource attribute**, not a separate table.

```sql
-- Blueprint stored as resource attributes (rows, not columns)

-- Example: MassMutual Claims Dashboard resource
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('res-001', 'project_type', 'web_app'),
  ('res-001', 'frontend_framework', 'nextjs'),
  ('res-001', 'css_framework', 'tailwind'),

  -- Blueprint attribute (REQUIRED for UI projects)
  ('res-001', 'blueprint_type', 'figma_url'),
  ('res-001', 'blueprint_url', 'https://figma.com/file/abc123...'),
  ('res-001', 'blueprint_verified', 'true'),
  ('res-001', 'blueprint_verification_date', '2025-12-31T10:30:00Z'),

  -- Additional blueprint URLs (stored as JSON)
  ('res-001', 'blueprint_additional_urls', '[
    {"name": "Dashboard", "url": "https://figma.com/..."},
    {"name": "Login Page", "url": "https://figma.com/..."}
  ]'),

  -- Git repo (optional)
  ('res-001', 'git_repo_url', 'https://github.com/massmutual/claims'),
  ('res-001', 'git_repo_type', 'github');
```

### Format Detection & Validation

**Backend API:** `POST /api/resources/{resourceId}/attributes/blueprint`

```typescript
interface BlueprintUploadRequest {
  blueprintType: 'figma_url' | 'sketch_url' | 'adobe_xd_url' | 'competitor_url' | 'blueprint_agent';
  blueprintUrl: string;
  additionalUrls?: Array<{ name: string; url: string }>;
}

// Auto-detect format from URL
function detectBlueprintType(url: string): string {
  if (url.includes('figma.com')) return 'figma_url';
  if (url.includes('sketch.cloud')) return 'sketch_url';
  if (url.includes('adobe.com/xd')) return 'adobe_xd_url';
  return 'competitor_url'; // Assume competitor website
}

// Validation pipeline
async function validateBlueprint(url: string, type: string): Promise<ValidationResult> {
  // Step 1: Verify URL is accessible (HTTP HEAD request)
  const isAccessible = await checkUrlAccessibility(url);
  if (!isAccessible) return { valid: false, error: 'URL not accessible' };

  // Step 2: If competitor URL, auto-screenshot
  if (type === 'competitor_url') {
    const screenshotUrl = await captureScreenshot(url); // Puppeteer
    return { valid: true, screenshotUrl };
  }

  return { valid: true };
}
```

---

## Q5: Sample Git Repo - What We Accept and Process ✅

**Objective:** Define how we use Git repos as reference material

### What We Accept

| Repo Type | Access Method | Processing |
|-----------|---------------|------------|
| **Public GitHub** | Direct URL | Clone → Analyze structure |
| **Private GitHub** | Personal Access Token (stored in Vaultwarden) | Clone with token → Analyze |
| **GitLab / Bitbucket** | URL + Token | Same as GitHub |
| **Zip File Upload** | Upload to S3 → Extract | Analyze extracted files |
| **Similar Open Source** | Public repo URL | Clone → Extract patterns |

### Git Repo as Resource Attribute

```sql
-- Git repo stored as resource attributes
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('res-001', 'git_repo_url', 'https://github.com/massmutual/claims-portal'),
  ('res-001', 'git_repo_type', 'github'), -- 'github', 'gitlab', 'bitbucket'
  ('res-001', 'git_repo_private', 'true'),
  ('res-001', 'git_access_token_vault_path', '/vaultwarden/massmutual/github-token'),

  -- Analysis results (cached)
  ('res-001', 'git_repo_analyzed', 'true'),
  ('res-001', 'git_repo_analysis_result', '{
    "techStack": "nextjs",
    "cssFramework": "tailwind",
    "componentLibrary": "shadcn-ui",
    "folderStructure": "app-router",
    "namingConvention": "kebab-case"
  }');
```

### What QUAD Agents Extract

**From Git Repo Analysis:**

1. **Tech Stack Detection**
   - Frontend framework (React, Next.js, Vue, Angular)
   - CSS framework (Tailwind, Bootstrap, MUI)
   - State management (Redux, Context, Zustand)
   - Component library (shadcn/ui, Ant Design, Chakra)

2. **Code Patterns**
   - Folder structure (pages/ vs app/ router)
   - Naming conventions (camelCase, kebab-case, PascalCase)
   - Component patterns (HOC, render props, hooks)
   - API integration patterns (fetch, axios, React Query)

3. **Reusable Components**
   - Header/Footer components
   - Form components
   - Button styles
   - Layout patterns

4. **Configuration**
   - ESLint rules
   - Prettier config
   - tsconfig.json settings
   - Environment variables structure

**Backend Service:** `GitRepoAnalyzer`

```typescript
interface GitRepoAnalysis {
  techStack: {
    frontend: string;
    cssFramework: string;
    stateManagement?: string;
    componentLibrary?: string;
  };
  patterns: {
    folderStructure: string;
    namingConvention: string;
    componentPattern: string[];
  };
  reusableComponents: string[]; // Paths to components
  styleGuide: {
    eslintRules?: object;
    prettierConfig?: object;
  };
}

async function analyzeGitRepo(repoUrl: string, accessToken?: string): Promise<GitRepoAnalysis> {
  // 1. Clone repo to temp directory
  const repoPath = await cloneRepo(repoUrl, accessToken);

  // 2. Analyze package.json
  const techStack = await extractTechStack(repoPath);

  // 3. Analyze folder structure
  const patterns = await extractPatterns(repoPath);

  // 4. Find reusable components
  const components = await findReusableComponents(repoPath);

  // 5. Extract configs
  const styleGuide = await extractStyleGuide(repoPath);

  // 6. Clean up temp directory
  await cleanup(repoPath);

  return { techStack, patterns, reusableComponents, styleGuide };
}
```

---

## Q6: Homepage Integration - Prerequisites on Homepage? ✅

**Decision:** ✅ YES - Show simplified prerequisites on homepage as value proposition

### Homepage Section Design

```
┌───────────────────────────────────────────────────────────────┐
│ QUAD Platform - AI-Powered Development                       │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│ From Idea to Production in 2-8 Hours                          │
│                                                                │
│ ┌────────────────────────────────────────────────────────┐   │
│ │ 📋 What You Need to Get Started                       │   │
│ ├────────────────────────────────────────────────────────┤   │
│ │                                                         │   │
│ │ ✅ UI Blueprint (Required)                             │   │
│ │    Figma, Sketch, wireframes, or competitor website    │   │
│ │                                                         │   │
│ │ ⚪ Sample Git Repo (Optional but Helpful)              │   │
│ │    Help us match your coding style & patterns          │   │
│ │                                                         │   │
│ │          [Learn More] [Get Started →]                  │   │
│ └────────────────────────────────────────────────────────┘   │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

**Implementation:**
- Homepage shows **WHY** prerequisites are needed (value prop)
- Actual upload happens during onboarding wizard (Step 2)
- Link to `/configure/domain/create` to start wizard

---

## Q7: Additional Prerequisites - Other Required Items ✅

**Beyond Blueprint & Git Repo:**

| Prerequisite | When Required | Why Needed | Storage |
|--------------|---------------|------------|---------|
| **Domain Access** | For deployment | SSH keys, credentials | Vaultwarden |
| **API Keys** | If integrating external services | Third-party integrations | Vaultwarden |
| **Database Credentials** | If connecting existing DB | Data migration, integration | Vaultwarden |
| **Branding Assets** | For UI polish | Logo, fonts, color palette | S3/GCP Storage |
| **Test Data** | For realistic demos | Sample records, mock users | Database seeding |

### Branding Assets as Resource Attributes

```sql
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('res-001', 'branding_logo_url', 'https://s3.../massmutual-logo.png'),
  ('res-001', 'branding_color_primary', '#003B5C'), -- MassMutual blue
  ('res-001', 'branding_color_secondary', '#FFB81C'), -- MassMutual gold
  ('res-001', 'branding_font_family', 'Helvetica Neue, Arial, sans-serif'),
  ('res-001', 'branding_style_guide_url', 'https://massmutual.com/brand-guidelines.pdf');
```

**Decision:** Branding assets are **optional** for Phase 1. QUAD agents will use blueprint colors/fonts as default.

---

## Q8: Blueprint Agent Questions - Question Set Definition ✅

**Objective:** Define the exact questions Blueprint Agent asks during interview

### Blueprint Agent Interview Flow

**Context Provided to Agent:**
- Domain type (Healthcare, Finance, etc.)
- Project type (Web App, Mobile App, etc.)
- Tech stack (Next.js, Tailwind, etc.)
- Sample Git repo (if provided)

### Question Set (5-10 Questions)

**Q1: Page Purpose**
```
Blueprint Agent: What is the main purpose of this page/feature?

Examples:
- "Insurance agents need to view and process claims"
- "Customers want to track their policy status"
- "Admins need to manage user permissions"
```

**Q2: Target Users**
```
Blueprint Agent: Who will use this page?

Options:
○ Internal employees (agents, admins, support)
○ External customers (policyholders, clients)
○ Both (hybrid portal)

Follow-up: What's their technical proficiency?
○ Non-technical (simple, guided UI)
○ Power users (keyboard shortcuts, advanced features)
```

**Q3: Key Actions**
```
Blueprint Agent: What are the top 3-5 actions users need to perform?

Examples:
- Search claims by ID, customer name, date range
- Filter by status (pending, approved, denied)
- Approve or deny a claim
- Add notes to a claim
- Export report to PDF
```

**Q4: Data Display**
```
Blueprint Agent: What information should be displayed?

Examples:
- Table: Claim ID, Customer, Amount, Date, Status
- Charts: Claims by status (pie chart), Monthly trends (line chart)
- Summary cards: Total pending claims, Average processing time
```

**Q5: Existing Reference**
```
Blueprint Agent: Do you have an existing page that looks similar?

Options:
○ Yes, here's the URL: [___________]
○ Yes, I have a screenshot (upload)
○ No, but I like this competitor's design: [___________]
○ No, please design from scratch
```

**Q6: Layout Preference**
```
Blueprint Agent: How should the page be organized?

Options:
○ Table-focused (like Excel, lots of data)
○ Card-based (like Trello, visual chunks)
○ Dashboard with widgets (like analytics)
○ Form-heavy (like settings page)
```

**Q7: Branding**
```
Blueprint Agent: Do you have brand colors/logo to use?

Options:
○ Yes, here's our style guide: [URL]
○ Yes, use these colors: Primary [#______] Secondary [#______]
○ No, use neutral professional theme
○ No, match our existing website: [URL]
```

**Q8: Mobile Responsiveness**
```
Blueprint Agent: Will this be used on mobile devices?

Options:
○ Desktop only (internal tool)
○ Mobile-first (customer-facing)
○ Both (responsive design)
```

**Q9: Special Features**
```
Blueprint Agent: Any special requirements?

Examples (checkboxes):
☐ Real-time updates (WebSockets)
☐ Offline mode (PWA)
☐ Dark mode support
☐ Accessibility (WCAG compliance)
☐ Multi-language (i18n)
```

**Q10: Inspiration**
```
Blueprint Agent: Show me 2-3 websites with designs you like

Examples:
- "I like Stripe's dashboard - clean, minimal, lots of white space"
- "I like Notion's card layout - organized, scannable"
- "I like Linear's sidebar navigation - easy to find features"
```

### Output Format

After questions, Blueprint Agent generates:

```json
{
  "blueprintConfig": {
    "pagePurpose": "Claims processing dashboard for insurance agents",
    "targetUsers": "internal_employees",
    "userProficiency": "power_users",
    "keyActions": ["search_claims", "filter_status", "approve_deny", "add_notes"],
    "dataDisplay": {
      "tables": ["claims_list"],
      "charts": ["status_pie_chart", "monthly_trends"],
      "cards": ["pending_count", "avg_processing_time"]
    },
    "layoutType": "dashboard_widgets",
    "referenceUrls": ["https://massmutual.com/policies"],
    "brandColors": {
      "primary": "#003B5C",
      "secondary": "#FFB81C"
    },
    "mobileResponsive": true,
    "specialFeatures": ["real_time_updates", "accessibility"]
  }
}
```

This JSON is passed to **Blueprint Generator Agent** which creates HTML/CSS mockup.

---

## Q9: Visual Design Review - Confirm Current Design ✅

**Question:** Is the current IntegrationMethodSelector.tsx design acceptable for Prerequisites section?

**Current Design Review:**

✅ **Good Elements:**
- Clear two-tier structure (Required vs Optional)
- Visual hierarchy with icons (! for required, i for optional)
- Accepted formats listed clearly
- Blueprint Agent AI call-to-action prominent

❌ **Needs Improvement:**
- Should NOT be on IntegrationMethodSelector page (already moved to Step 2 in Q3 design)
- Should be simplified on homepage (just value prop)
- Should be full form in `/configure/prerequisites` wizard step

**Decision:** Current design is good for **wizard Step 2**, but remove from IntegrationMethodSelector page (as per Q3 revision).

---

## Q10: Documentation vs Website - Dedicated Pages ✅

**Question:** Should prerequisites info live in documentation (QUAD_DEVELOPMENT_MODEL.md) or as dedicated website pages?

**Decision:** **BOTH** - Documentation for developers, Website pages for end users

### Documentation (For Developers/Partners)

**File:** `QUAD_DEVELOPMENT_MODEL.md`
- Technical explanation
- API integration details
- Code samples
- Architecture decisions

### Website Pages (For End Users)

**Route:** `/docs/prerequisites`

```
┌───────────────────────────────────────────────────────────────┐
│ Prerequisites - What You Need to Get Started                  │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│ Before QUAD agents can build your project, we need two things:│
│                                                                │
│ ## 1. UI Blueprint (Required)                                 │
│                                                                │
│ [Visual: Screenshots of Figma, Sketch, wireframes]            │
│                                                                │
│ We accept:                                                     │
│ • Figma or Sketch designs                                     │
│ • Hand-drawn wireframes                                       │
│ • Competitor website references                               │
│ • Or let our Blueprint Agent AI create one for you            │
│                                                                │
│ Why? This ensures the final product matches your expectations.│
│                                                                │
│ [Learn more about Blueprint Agent →]                          │
│                                                                │
│ ## 2. Sample Git Repo (Optional but Helpful)                  │
│                                                                │
│ [Visual: GitHub logo, code snippets]                          │
│                                                                │
│ Share your existing codebase so we can:                       │
│ • Match your coding style                                     │
│ • Reuse your components                                       │
│ • Follow your naming conventions                              │
│                                                                │
│ [See examples of what we extract →]                           │
│                                                                │
│                 [Ready to Start? Create Project →]            │
└───────────────────────────────────────────────────────────────┘
```

**Additional Website Pages:**

| Route | Purpose |
|-------|---------|
| `/docs/blueprint-agent` | How Blueprint Agent AI works |
| `/docs/git-repo-analysis` | What we analyze from Git repos |
| `/docs/supported-formats` | All blueprint formats accepted |

---

## Summary: Q4-Q10 Completed

| Question | Decision | Implementation |
|----------|----------|----------------|
| **Q4** | Support 6 blueprint formats | Store as resource attributes |
| **Q5** | Accept Git repos (public/private), analyze tech stack | Store URL + analysis results as attributes |
| **Q6** | Show prerequisites on homepage (value prop only) | Link to wizard for actual upload |
| **Q7** | Branding assets optional for Phase 1 | Store as resource attributes if provided |
| **Q8** | Blueprint Agent asks 5-10 questions | Generate JSON config → Pass to mockup generator |
| **Q9** | Current design good for wizard Step 2 | Remove from IntegrationMethodSelector |
| **Q10** | Both documentation AND website pages | Docs for devs, website for end users |

---

## Next Steps

1. ✅ Q1-Q10 COMPLETED: All Blueprint Agent questions answered
2. 🔜 Create database migration for resource attributes model
3. 🔜 Implement Backend APIs:
   - `POST /api/resources/{id}/attributes/blueprint` - Upload blueprint
   - `POST /api/resources/{id}/attributes/git-repo` - Link Git repo
   - `POST /api/blueprint-agent/start-interview` - Start Blueprint Agent
4. 🔜 Implement Frontend Pages:
   - `/configure/domain/create` - Domain creation wizard
   - `/configure/prerequisites` - Blueprint + Git repo upload
   - `/docs/prerequisites` - Public documentation page

---

**Document Version:** 1.0
**Last Updated:** December 31, 2025
**Status:** ✅ All questions answered, ready for implementation
