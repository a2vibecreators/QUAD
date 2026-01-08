# QUAD Framework - Complete Sitemap & Navigation Flows

**Last Updated:** January 4, 2026

This document provides a comprehensive map of all pages, authentication flows, and navigation paths in the QUAD Framework website.

---

## Table of Contents

1. [Public Pages (Non-Logged-In Users)](#public-pages-non-logged-in-users)
2. [Authentication Flows](#authentication-flows)
3. [Protected Pages (Logged-In Users)](#protected-pages-logged-in-users)
4. [API Endpoints](#api-endpoints)

---

## Public Pages (Non-Logged-In Users)

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PUBLIC SITE MAP                             │
└─────────────────────────────────────────────────────────────────────┘

HOME (/)
├── EXPLORE Flow (Learn QUAD Concepts)
│   ├── /concept ──────────── QUAD Methodology Overview
│   ├── /details ──────────── Detailed QUAD Breakdown
│   ├── /architecture ─────── System Architecture
│   ├── /flow ────────────── Flow Visualization
│   ├── /circles ──────────── 4 Circles Explanation
│   ├── /cycles ──────────── Cycles & Pulses
│   ├── /flows ───────────── Work Item Flows
│   ├── /roles ───────────── Role Definitions
│   ├── /mastery ─────────── Adoption Matrix
│   └── /jargons ─────────── Terminology Guide
│
├── TRY Flow (Interactive Tools)
│   ├── /demo ────────────── Interactive Dashboard Demo
│   ├── /quiz ────────────── Knowledge Quiz
│   ├── /configure ───────── QUAD Config Generator
│   ├── /discovery ───────── Discovery Wizard
│   └── /compare ─────────── Compare with Other Methodologies
│
├── RESOURCES Flow (Reference Materials)
│   ├── /cheatsheet ──────── Quick Reference Guide
│   ├── /book ────────────── Download QUAD Book
│   ├── /docs ────────────── Documentation Hub
│   ├── /sitemap ─────────── Site Navigation Map
│   ├── /support ─────────── Get Help
│   └── /case-study ──────── Real-World Case Studies
│
├── PLATFORM (Product Pages)
│   ├── /platform ────────── QUAD Platform Overview
│   ├── /pitch ───────────── Product Pitch
│   ├── /blueprint-agent ─── Blueprint Agent Feature
│   └── /onboarding ──────── Team Onboarding Guide
│
├── CUSTOMER (Customer/Prospect Pages)
│   │   For enterprise prospects and founding partners
│   │
│   ├── /customer/pitch ────────── Customer Pitch Slides (Founding Partner Program)
│   │   ├── Slide 1: Title & Problem (6-9 weeks problem)
│   │   ├── Slide 2: Comparison (Traditional vs QUAD vs AI Tools)
│   │   ├── Slide 3: Meeting → Code Flow (Q-U-A-D timeline)
│   │   ├── Slide 4: Processing Modes (Real-time vs Batch)
│   │   ├── Slide 5: AI Agents (14 specialized agents)
│   │   ├── Slide 6: Role-Based Dashboards (7 dashboard types)
│   │   ├── Slide 7: Proprietary Technology (12 QUAD technologies)
│   │   ├── Slide 8: Security & BYOK
│   │   ├── Slide 9: Measurable Impact (ROI metrics)
│   │   ├── Slide 10: Features Roadmap (150+ features across 3 phases)
│   │   ├── Slide 11: Founding Customer Program
│   │   └── Slide 12: Contact & Call-to-Action
│   │
│   ├── /customer/roi ────────────── ROI Calculator
│   │   └── Interactive sliders for customized ROI calculation
│   │
│   ├── /customer/features ──────── Complete Features List (150+ total)
│   │   ├── Phase 1 (LIVE)
│   │   ├── Phase 2 (Q2 2026)
│   │   └── Phase 3 (Q4 2026)
│   │
│   ├── /customer/demo ──────────── Interactive Dashboard Demo
│   │   └── Live demo of QUAD Platform dashboard
│   │
│   ├── /customer/about ────────── About QUAD Platform
│   │
│   ├── /customer/contact ─────── Contact & Schedule Demo
│   │   └── Email, calendar booking, team intro form
│   │
│   └── /customer/settings ────── Account Settings (Customer Portal)
│
├── MASSMUTUAL (Partner Pitch Site)
│   │   Subdomain: massmutual.quadframe.work
│   │   Middleware rewrites to /massmutual/* routes
│   │
│   ├── /massmutual ─────────── Landing Page (Problem-Focused)
│   │   ├── Hero: "Why Does a 1-Paragraph Feature Take 6 Weeks?"
│   │   ├── The Real Problem (4 pain points)
│   │   ├── The QUAD Answer (timeline comparison)
│   │   ├── How It Actually Works (Q-U-A-D stages)
│   │   └── The Paradigm Shift (Before/After)
│   │
│   ├── /massmutual/pitch ───── Pitch Deck (5 Slides)
│   │   ├── Slide 1: Executive Summary
│   │   ├── Slide 2: The QUAD Model
│   │   ├── Slide 3: Competitive Advantage
│   │   ├── Slide 4: Partnership Proposal
│   │   └── Slide 5: The Ask (4 weeks, 1 team, $0)
│   │
│   ├── /massmutual/demo ────── Demo Options
│   │   ├── Dashboard Demo link
│   │   ├── QUAD Methodology link
│   │   └── Demo Scenarios list
│   │
│   ├── /massmutual/roi ─────── ROI Calculator
│   │   ├── Interactive sliders (devs, salary, cycle time)
│   │   └── Real-time savings calculation
│   │
│   └── /massmutual/contact ─── Contact & Scheduling
│       ├── Email contact
│       ├── Calendar booking (coming soon)
│       └── Team introductions
│
└── AUTHENTICATION (Login/Signup)
    ├── /auth/login ──────── Login Page → See "Login Flows" below
    └── /auth/signup ─────── Signup Page → See "Signup Flows" below
```

---

## Authentication Flows

### 1. Login Flows (Existing Users)

#### Login Flow A: OAuth (Google/GitHub)

```
┌────────────────────────────────────────────────────────────────────┐
│ LOGIN FLOW A: OAuth (Google/GitHub) - Existing User               │
└────────────────────────────────────────────────────────────────────┘

/auth/login
    │
    │ 1. Click "Continue with Google"
    ▼
[Google OAuth Consent Screen]
    │
    │ 2. User approves → Google redirects back
    ▼
/api/auth/callback/google
    │
    │ 3. NextAuth callback (authOptions.ts signIn)
    │    - Calls getUserByEmail(email)
    │    - User exists? → YES
    │    - Return '/dashboard'
    ▼
/dashboard ✅
    │
    └─→ User is now logged in with OAuth session
```

#### Login Flow B: Email + Verification Code

```
┌────────────────────────────────────────────────────────────────────┐
│ LOGIN FLOW B: Email + Verification Code - Existing User           │
└────────────────────────────────────────────────────────────────────┘

/auth/login
    │
    │ 1. Click "Email / Code" button
    ▼
[Email Input Form]
    │
    │ 2. Enter email → Click "Send code"
    ▼
POST /api/auth/send-code
    │
    │ 3. Backend sends 6-digit code to email
    │    - Checks if user exists
    │    - Generates OTP
    │    - Sends email
    ▼
[Verification Code Input]
    │
    │ 4. User enters 6-digit code from email
    ▼
POST /api/auth/verify-code
    │
    │ 5. Backend verifies code
    │    ├─ Valid code + Existing user? → Creates session token
    │    └─ Valid code + New user? → Redirect to signup
    ▼
/dashboard ✅ (existing user)
    │
    OR
    │
/auth/signup?verified=true&email=... (new user)
```

### 2. Signup Flows (New Users)

#### Signup Flow A: OAuth (Google/GitHub)

```
┌────────────────────────────────────────────────────────────────────┐
│ SIGNUP FLOW A: OAuth (Google/GitHub) - New User                   │
└────────────────────────────────────────────────────────────────────┘

/auth/signup
    │
    │ 1. Click "Continue with Google"
    ▼
[Google OAuth Consent Screen]
    │
    │ 2. User approves → Google redirects back
    ▼
/api/auth/callback/google
    │
    │ 3. NextAuth callback (authOptions.ts signIn)
    │    - Calls getUserByEmail(email)
    │    - User exists? → NO (404)
    │    - Return '/auth/signup?oauth=true&provider=google&email=...&name=...'
    ▼
/auth/signup?oauth=true&provider=google&email=user@gmail.com&name=John
    │
    │ 4. Signup page shows account type selection
    │    [🚀 Startup] [📈 Business] [🏢 Enterprise]
    │
    │ 5. User selects "Startup" (instant access)
    ▼
[Signup Form Pre-filled]
    - Email: user@gmail.com (read-only, verified via OAuth)
    - Name: John (read-only, from Google)
    - Company: Optional
    │
    │ 6. User submits form
    ▼
POST /api/auth/complete-oauth-signup
    │
    │ 7. Backend creates:
    │    - Organization (e.g., "John's Team")
    │    - User account (role: ADMIN)
    │    - Links OAuth provider
    ▼
{success: true}
    │
    │ 8. Frontend calls signIn('google') AGAIN
    │    (Second OAuth roundtrip to create NextAuth session)
    ▼
/api/auth/callback/google (2nd time)
    │
    │ 9. NextAuth callback
    │    - Calls getUserByEmail(email)
    │    - User exists? → YES (just created)
    │    - Return '/dashboard'
    ▼
/dashboard ✅
    │
    └─→ User is now logged in with full account setup
```

#### Signup Flow B: Email + Verification Code

```
┌────────────────────────────────────────────────────────────────────┐
│ SIGNUP FLOW B: Email + Verification Code - New User               │
└────────────────────────────────────────────────────────────────────┘

/auth/login
    │
    │ 1. Click "Email / Code" → Enter email → Get code
    ▼
POST /api/auth/verify-code
    │
    │ 2. Backend verifies code
    │    - User exists? → NO
    │    - Redirect to signup with verified email flag
    ▼
/auth/signup?verified=true&email=user@company.com
    │
    │ 3. Signup page shows account type selection
    │    [🚀 Startup] [📈 Business] [🏢 Enterprise]
    │
    │ 4. User selects account type
    ▼
[Signup Form]
    - Email: user@company.com (read-only, verified via OTP)
    - Name: (user must enter)
    - Company: (optional for Startup)
    │
    │ 5. User submits form
    ▼
POST /api/auth/signup
    │
    │ 6. Backend creates:
    │    - Organization
    │    - User account (no password - passwordless)
    │    - Marks email as verified
    ▼
{success: true, token: "..."}
    │
    │ 7. Frontend stores token → Redirect to dashboard
    ▼
/dashboard ✅
```

### 3. Edge Cases & Special Flows

#### Edge Case A: Existing User Clicks "Sign Up" (OAuth)

```
┌────────────────────────────────────────────────────────────────────┐
│ EDGE CASE A: Existing User Clicks "Sign Up" with OAuth            │
│ ✅ FIXED: Now redirects to dashboard instead of signup loop       │
└────────────────────────────────────────────────────────────────────┘

/auth/signup
    │
    │ 1. EXISTING user clicks "Continue with Google"
    │    (User already has account but clicked wrong button)
    ▼
[Google OAuth Consent Screen]
    │
    │ 2. User approves → Google redirects back
    ▼
/api/auth/callback/google
    │
    │ 3. NextAuth callback (authOptions.ts signIn)
    │    - Calls getUserByEmail(email)
    │    - User exists? → YES
    │    - Return '/dashboard' ✅ (FIXED - was returning true)
    ▼
/dashboard ✅
    │
    └─→ User goes directly to dashboard (onboarding already done)

BEFORE FIX: Would redirect back to /auth/signup → confusing loop
AFTER FIX: Redirects to /dashboard → correct behavior
```

#### Edge Case B: User Logs Out and Signs In Again

```
┌────────────────────────────────────────────────────────────────────┐
│ EDGE CASE B: User Logs Out → Signs In Again                       │
└────────────────────────────────────────────────────────────────────┘

/dashboard
    │
    │ 1. User clicks "Logout"
    ▼
POST /api/auth/logout
    │
    │ 2. NextAuth destroys session → Redirect to login
    ▼
/auth/login
    │
    │ 3. User clicks "Continue with Google" (or Email/Code)
    ▼
[OAuth or OTP Flow - See "Login Flow A" or "Login Flow B"]
    │
    │ 4. User exists → Skip signup → Direct to dashboard
    ▼
/dashboard ✅
    │
    └─→ User is logged in again (no re-onboarding)
```

---

## Protected Pages (Logged-In Users)

```
┌─────────────────────────────────────────────────────────────────────┐
│                   PROTECTED PAGES (Requires Auth)                   │
└─────────────────────────────────────────────────────────────────────┘

/dashboard (Main Hub)
    │
    ├── Header
    │   ├── Company Logo (quadframe.work)
    │   ├── User Avatar + Dropdown
    │   │   ├── Profile
    │   │   ├── Settings
    │   │   └── Logout
    │   └── "Back to Home" link → /
    │
    ├── Domains Section
    │   ├── [Create New Domain] → POST /api/domains/create
    │   └── Domain Cards (for each domain)
    │       ├── View Details → /domains/[id]
    │       ├── Start Blueprint Agent → /blueprint-agent?domainId=...
    │       └── Manage Members → /domains/[id]/members
    │
    ├── Quick Actions
    │   ├── [Create Ticket] → /tickets/create
    │   ├── [View My Tickets] → /tickets?assignee=me
    │   └── [Team Activity] → /activity
    │
    └── Footer Navigation
        ├── /setup ──────────── Initial Setup Wizard
        ├── /configure ───────── Configuration Pages
        ├── /reporting ───────── Analytics Dashboard
        └── /tools ───────────── Tool Management

/domains
    ├── /domains/list ────────── View all domains (API)
    ├── /domains/create ──────── Create new domain
    └── /domains/[id]
        ├── Overview Tab
        ├── Members Tab ──────── /domains/[id]/members
        ├── Circles Tab ──────── /circles?domainId=[id]
        ├── Flows Tab ────────── /flows?domainId=[id]
        ├── Resources Tab ────── /resources?domainId=[id]
        └── Settings Tab

/circles
    ├── /circles?domainId=[id] ─── View circles for domain
    ├── /circles/create ───────── Create new circle
    └── /circles/[id]
        ├── Members ──────────── /circles/[id]/members
        └── Settings

/flows (Work Items / Tickets)
    ├── /flows?domainId=[id] ──── View flows for domain
    ├── /flows/create ─────────── Create new flow
    └── /flows/[id]
        ├── Details
        ├── Comments
        ├── Stage History ────── (Q → U → A → D transitions)
        ├── Branch Info ──────── /flows/[id]/branch
        └── Pull Request ─────── /flows/[id]/pull-request

/tickets
    ├── /tickets ──────────────── All tickets
    ├── /tickets/create ───────── Create ticket
    └── /tickets/[id]
        ├── Details
        ├── Comments ─────────── /tickets/[id]/comments
        ├── Time Logs ────────── /tickets/[id]/time-logs
        └── AI Analysis ──────── /tickets/[id]/analyze

/requirements
    ├── /requirements ─────────── All requirements
    ├── /requirements/create ──── Create requirement
    └── /requirements/[id]
        ├── Details
        ├── AI Analysis ──────── /requirements/[id]/analyze
        └── Generate Tickets ─── /requirements/[id]/generate-tickets

/roles
    ├── /roles ────────────────── All roles
    ├── /roles/create ─────────── Create custom role
    └── /roles/[id] ───────────── Edit role

/setup (Onboarding Wizard)
    ├── /setup ────────────────── Setup overview
    ├── /setup/ai-tier ────────── Select AI tier
    ├── /setup/meetings ───────── Configure meeting integrations
    └── /setup/complete ───────── Setup complete

/configure (Configuration Hub)
    ├── /configure ────────────── Config overview
    ├── /configure/integrations ─ Integration settings
    │   └── /configure/integrations/git ─ Git provider setup
    └── /configure/admin/byok ─── Bring Your Own Key (BYOK) settings

/blueprint-agent
    └── Interactive UI for Blueprint Agent interviews
        ├── Start Interview ─────── POST /api/blueprint-agent/start-interview
        └── Submit Answer ───────── POST /api/blueprint-agent/submit-answer

/reporting
    └── Analytics Dashboard
        ├── Team Velocity ───────── /api/dashboard/velocity
        ├── Cycle Burndown ──────── /api/dashboard/cycles/[id]/burndown
        └── Team Performance ────── /api/dashboard/team

/tools
    ├── /tools ────────────────── Available tools
    └── /tools/request ────────── Request new tool
```

---

## API Endpoints

### Public API (No Auth Required)

```
GET  /api/health ──────────────── Health check
GET  /api/auth/providers ──────── List available OAuth providers
GET  /api/auth/sso-config ──────── Get SSO config for domain
POST /api/auth/send-code ──────── Send email verification code
POST /api/auth/verify-code ─────── Verify email code
POST /api/auth/signup ──────────── Create new user account
POST /api/auth/complete-oauth-signup ─ Complete OAuth signup
GET  /api/book/database ────────── Download Database Design Book
GET  /api/book/nextjs ──────────── Download Next.js Book
```

### Protected API (Requires Authentication)

#### Authentication & Users
```
GET  /api/users ────────────────── List users
GET  /api/users/[id] ───────────── Get user by ID
POST /api/auth/logout ──────────── Logout current user
GET  /api/auth/user-domains ─────── Get user's domains
POST /api/auth/set-domain ──────── Set active domain
```

#### Companies & Organizations
```
GET  /api/companies ────────────── List companies
GET  /api/companies/[id] ────────── Get company by ID
GET  /api/company/profile ──────── Current company profile
```

#### Domains
```
GET  /api/domains/list ─────────── List user's domains
POST /api/domains/create ──────── Create new domain
GET  /api/domains/[id] ─────────── Get domain by ID
PUT  /api/domains/[id] ─────────── Update domain
GET  /api/domains/[id]/members ─── Get domain members
POST /api/domains/[id]/members ── Add domain member
```

#### Circles
```
GET  /api/circles ──────────────── List circles
POST /api/circles ──────────────── Create circle
GET  /api/circles/[id] ─────────── Get circle
PUT  /api/circles/[id] ─────────── Update circle
GET  /api/circles/[id]/members ── Get circle members
POST /api/circles/[id]/members ── Add circle member
```

#### Flows & Tickets
```
GET  /api/flows ────────────────── List flows
POST /api/flows ────────────────── Create flow
GET  /api/flows/[id] ───────────── Get flow
PUT  /api/flows/[id] ───────────── Update flow
POST /api/flows/[id]/branch ────── Create git branch
POST /api/flows/[id]/pull-request ─ Create PR

GET  /api/tickets ──────────────── List tickets
POST /api/tickets ──────────────── Create ticket
GET  /api/tickets/[id] ─────────── Get ticket
PUT  /api/tickets/[id] ─────────── Update ticket
POST /api/tickets/[id]/analyze ── AI analysis
POST /api/tickets/[id]/comments ─ Add comment
GET  /api/tickets/[id]/time-logs ─ Get time logs
POST /api/tickets/[id]/time-logs ─ Log time
```

#### Requirements
```
GET  /api/requirements ─────────── List requirements
POST /api/requirements ─────────── Create requirement
GET  /api/requirements/[id] ────── Get requirement
POST /api/requirements/[id]/analyze ──────── AI analysis
POST /api/requirements/[id]/generate-tickets ─ Generate tickets
```

#### AI & Chat
```
POST /api/ai/chat ──────────────── Send chat message
POST /api/ai/chat/stream ──────── Stream chat response
POST /api/ai/ticket-chat ──────── Ticket-specific chat
GET  /api/ai/usage ─────────────── Get AI usage stats
GET  /api/ai/credits ───────────── Get AI credits
GET  /api/ai-config ─────────────── Get AI configuration
POST /api/ai-config ────────────── Update AI config
```

#### Integrations
```
GET  /api/integrations/git/providers ────── List git providers
GET  /api/integrations/git/status ────────── Git integration status
GET  /api/integrations/git/repositories ──── List repositories
POST /api/integrations/git/[provider]/connect ─── Connect git
GET  /api/integrations/git/[provider]/callback ─ OAuth callback
POST /api/integrations/git/[provider]/disconnect ─ Disconnect

GET  /api/integrations/meeting/providers ─ List meeting providers
GET  /api/integrations/meeting/status ───── Meeting integration status
POST /api/integrations/meeting/[provider]/connect ─── Connect
GET  /api/integrations/meeting/[provider]/callback ─ OAuth callback
POST /api/integrations/meeting/[provider]/webhook ─ Meeting webhook
```

#### Blueprint Agent
```
POST /api/blueprint-agent/start-interview ─ Start AI interview
POST /api/blueprint-agent/submit-answer ─── Submit interview answer
```

#### Admin & Configuration
```
GET  /api/admin/byok ───────────── Get BYOK settings
POST /api/admin/byok ───────────── Update BYOK settings
GET  /api/admin/ai-pool ────────── Get AI pool config
POST /api/admin/ai-pool ────────── Update AI pool
```

---

## Navigation Rules

### Redirect Logic

| Condition | Action |
|-----------|--------|
| Unauthenticated user accesses protected page | → `/auth/login` |
| Authenticated user accesses `/auth/login` | → Stay (no redirect) |
| Authenticated user accesses `/auth/signup` | → Stay (no redirect) ⚠️ |
| New OAuth user (no account) | → `/auth/signup?oauth=true&...` |
| Existing OAuth user (has account) | → `/dashboard` ✅ |
| User completes signup | → `/dashboard` |
| User logs out | → `/auth/login` |

### Session Management

- **Session Strategy:** JWT tokens stored in cookies
- **Session Duration:** 24 hours (NextAuth default)
- **Token Refresh:** Automatic on page load
- **Logout:** Clears session cookie, redirects to login

### Domain Context

- Users can belong to multiple domains (projects)
- Active domain stored in session (`session.user.domainId`)
- Dashboard shows all accessible domains
- Switching domains: `POST /api/auth/set-domain`

---

## OAuth Provider Flow Details

### Google OAuth Flow

```
1. User clicks "Continue with Google"
   → Frontend: signIn('google', { callbackUrl: '/dashboard' })

2. NextAuth redirects to Google
   → https://accounts.google.com/o/oauth2/v2/auth?...

3. User approves → Google redirects back
   → http://localhost:14001/api/auth/callback/google?code=...

4. NextAuth callback (authOptions.ts)
   → signIn() callback runs
   → Checks getUserByEmail()
   → Returns redirect URL or true

5. Final redirect
   → Existing user: /dashboard
   → New user: /auth/signup?oauth=true&...
```

### GitHub OAuth Flow

(Same as Google, replace `google` with `github`)

---

## Error Pages & Special Routes

```
/auth/login?error=... ───────── OAuth error (shows error message)
/404 ─────────────────────────── Page not found
/_not-found ──────────────────── Next.js 404 handler
/api/auth/error ─────────────── NextAuth error page
```

---

## Summary: Key Flow Fixes (Jan 4, 2026)

### ✅ Fixed Issues

1. **Invisible Input Text**
   - **Page:** `/auth/login`
   - **Issue:** Email and code inputs had no text color
   - **Fix:** Added `text-gray-900 placeholder:text-gray-400`
   - **File:** `src/app/auth/login/page.tsx`

2. **OAuth Signup Loop (Existing Users)**
   - **Issue:** Existing user clicks "Sign Up" → OAuth → redirects back to signup → loop
   - **Fix:** Changed `return true` to `return '/dashboard'` for existing users
   - **File:** `src/lib/authOptions.ts:109`
   - **Impact:** Existing users now skip signup flow and go directly to dashboard

### ⚠️ Known Inefficiencies (Not Bugs)

1. **Two OAuth Roundtrips for New Users**
   - New user signup requires 2 OAuth calls (one to detect new user, one to create session)
   - Not a bug, just architectural choice
   - Google auto-approves 2nd OAuth (no consent screen shown twice)

2. **No Logged-In User Redirect on Signup Page**
   - Logged-in users can still access `/auth/signup`
   - Should redirect to dashboard
   - Low priority UX improvement

---

**Last Updated:** January 4, 2026
**Author:** Suman Addanki (via Claude Code)
**Version:** 1.0
