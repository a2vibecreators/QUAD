# QUAD Platform Onboarding Flow

## Table of Contents

- [Overview](#overview)
- [Key Concepts](#key-concepts)
  - [Email Classification](#email-classification)
- [Four Onboarding Paths](#four-onboarding-paths)
- [Path 1: Create Organization (Startup/Small Business)](#path-1-create-organization-startupsmall-business)
  - [Flow](#flow)
  - [Database Changes](#database-changes)
- [Path 2: Join Team via Invitation](#path-2-join-team-via-invitation)
  - [Invitation Flow](#invitation-flow)
  - [Invitation States](#invitation-states)
- [Path 3: Observer Mode](#path-3-observer-mode)
  - [Observer Permissions](#observer-permissions)
  - [Converting Observer to Member](#converting-observer-to-member)
- [Path 4: Enterprise SSO Request](#path-4-enterprise-sso-request)
  - [Enterprise SSO Integration](#enterprise-sso-integration)
  - [SCIM Provisioning (Enterprise)](#scim-provisioning-enterprise)
- [Database Schema Support](#database-schema-support)
  - [Required Tables](#required-tables)
- [UI Components Needed](#ui-components-needed)
- [Terminology Changes](#terminology-changes)
- [Summary: Path Selection Logic](#summary-path-selection-logic)
- [Decisions Made](#decisions-made)
  - [1. Invitation Email Matching: STRICT](#1-invitation-email-matching-strict)
  - [2. Default State: Observer](#2-default-state-observer)
  - [3. Observer Conversion Flow](#3-observer-conversion-flow)
  - [4. Enterprise: Self-Hosted Only](#4-enterprise-self-hosted-only)
- [Hosting & Pricing Model](#hosting--pricing-model)
  - [Three Deployment Options](#three-deployment-options)
  - [AI Pricing: Claude Integration](#ai-pricing-claude-integration)
  - [What Enterprise Brings](#what-enterprise-brings)
- [Revised Path Flow (Final)](#revised-path-flow-final)
- [Free Tier Limits](#free-tier-limits)
  - [Startup Free Plan](#startup-free-plan)
  - [What Happens at Limit?](#what-happens-at-limit)
- [Sources](#sources)

---

## Overview

This document defines the user onboarding flow for QUAD Platform, covering all paths from initial sign-in to dashboard access.

## Key Concepts

### Email Classification

QUAD distinguishes between **personal emails** and **organizational emails**:

```typescript
const PERSONAL_EMAIL_DOMAINS = [
  // Google
  'gmail.com', 'googlemail.com',
  // Microsoft
  'hotmail.com', 'outlook.com', 'live.com', 'msn.com',
  // Yahoo
  'yahoo.com', 'yahoo.co.in', 'yahoo.co.uk', 'ymail.com',
  // Apple
  'icloud.com', 'me.com', 'mac.com',
  // Others
  'aol.com', 'protonmail.com', 'proton.me', 'zoho.com',
  'mail.com', 'gmx.com', 'yandex.com', 'rediffmail.com'
];

function isPersonalEmail(email: string): boolean {
  const domain = email.split('@')[1].toLowerCase();
  return PERSONAL_EMAIL_DOMAINS.includes(domain);
}
```

| Email Type | Examples | Implications |
|------------|----------|--------------|
| **Personal** | john@gmail.com, jane@yahoo.com | Can create org, needs invite to join team |
| **Organizational** | john@massmutual.com, dev@startup.io | Can create org, can receive invites |

---

## Four Onboarding Paths

```
┌─────────────────────────────────────────────────────────────────────┐
│                    User Clicks "Sign In"                             │
│              (Google, GitHub, or Enterprise SSO)                     │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                   ┌────────────────────┐
                   │ User exists in DB? │
                   └────────────────────┘
                      │              │
                    YES             NO
                      │              │
                      ▼              ▼
               ┌──────────┐   ┌──────────────────┐
               │ Dashboard│   │ Show Path Choice │
               └──────────┘   └──────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
           ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
           │ Path 1:     │  │ Path 2:     │  │ Path 3:     │
           │ Create Org  │  │ Join Team   │  │ Observer    │
           │ (Startup)   │  │ (Invite)    │  │ (Browse)    │
           └─────────────┘  └─────────────┘  └─────────────┘
                                                    │
                                         ┌──────────┴──────────┐
                                         │ Path 4: Enterprise  │
                                         │ (SSO Request)       │
                                         └─────────────────────┘
```

---

## Path 1: Create Organization (Startup/Small Business)

**Who:** Founders, small teams, anyone wanting to start fresh

**Trigger:** User clicks "Create Organization" after sign-in

### Flow

```
1. User signs in with Google/GitHub
   Email: madhuri.recherla@gmail.com ✓

2. System detects: No existing user, no pending invite
   → Shows "Choose Your Path" screen

3. User selects "Create Organization"

4. Simple form appears:
   ┌────────────────────────────────────────────────────────┐
   │  🚀 Create Your Organization                           │
   │                                                        │
   │  Organization Name *                                   │
   │  [A2Vibe Creators LLC                    ]            │
   │                                                        │
   │  Organization Size                                     │
   │  ○ Startup (1-10 employees)     - Free, up to 5 users │
   │  ○ Small Business (11-50)       - Free, up to 5 users │
   │  ○ Medium (51-200)              - Contact for pricing │
   │  ○ Large (201-500)              - Contact for pricing │
   │  ○ Enterprise (500+)            - Custom SSO available│
   │                                                        │
   │  ─────────────────────────────────────────────────────│
   │  Your Account                                          │
   │  Email: madhuri.recherla@gmail.com ✓ (from sign-in)   │
   │  Role: QUAD_ADMIN (Organization Owner)                 │
   │  SSO: Google ✓ (already configured)                   │
   │                                                        │
   │  ⚠️ Using personal email (gmail.com)                   │
   │     Team members will need invitation links to join.   │
   │                                                        │
   │  [Create Organization]                                 │
   └────────────────────────────────────────────────────────┘

5. On submit:
   - Create QUAD_organizations record
   - Create QUAD_users record (role: QUAD_ADMIN)
   - Set org.admin_email = user's email
   - Set org.sso_provider = 'google' (from sign-in method)

6. → Redirect to Dashboard (INSTANT access)
```

### Database Changes

```sql
-- Organization created
INSERT INTO "QUAD_organizations" (
  name, admin_email, size, sso_provider, is_active
) VALUES (
  'A2Vibe Creators LLC',
  'madhuri.recherla@gmail.com',
  'startup',
  'google',
  true
);

-- User created as QUAD_ADMIN
INSERT INTO "QUAD_users" (
  company_id, email, full_name, role, is_active, email_verified
) VALUES (
  <org_id>,
  'madhuri.recherla@gmail.com',
  'Madhuri Recherla',
  'QUAD_ADMIN',
  true,
  true
);
```

---

## Path 2: Join Team via Invitation

**Who:** Team members invited by existing organization

**Trigger:** User clicks invitation link OR enters invite code

### Invitation Flow

```
1. QUAD_ADMIN sends invitation:
   - From Dashboard → Team → Invite Member
   - Enter email: john.developer@gmail.com
   - Select role: DEVELOPER
   - Click "Send Invitation"

2. System creates invitation record:
   INSERT INTO "QUAD_org_invitations" (
     org_id, email, role, invited_by, token, expires_at
   ) VALUES (...);

3. Email sent to john.developer@gmail.com:
   ┌────────────────────────────────────────────────────────┐
   │  You're invited to join A2Vibe Creators on QUAD       │
   │                                                        │
   │  Madhuri Recherla has invited you to join             │
   │  A2Vibe Creators LLC as a Developer.                  │
   │                                                        │
   │  [Accept Invitation]                                   │
   │                                                        │
   │  Or enter this code: ABCD-1234-EFGH                   │
   │  at https://quadframe.work/join                       │
   └────────────────────────────────────────────────────────┘

4. User clicks link or enters code:
   https://quadframe.work/invite/abc123xyz

5. Invitation acceptance screen:
   ┌────────────────────────────────────────────────────────┐
   │  📨 You're Invited!                                    │
   │                                                        │
   │  Organization: A2Vibe Creators LLC                    │
   │  Invited by: madhuri.recherla@gmail.com               │
   │  Your Role: DEVELOPER                                  │
   │                                                        │
   │  Sign in to accept:                                    │
   │  [🔵 Continue with Google]                             │
   │  [⬛ Continue with GitHub]                             │
   └────────────────────────────────────────────────────────┘

6. User signs in with Google (john.developer@gmail.com)

7. System validates:
   - Invitation exists and not expired
   - Email matches (or allow any email for flexibility?)
   - User not already in org

8. On success:
   - Create QUAD_users record with invited role
   - Mark invitation as accepted
   - → Redirect to Dashboard
```

### Invitation States

| State | Description |
|-------|-------------|
| `pending` | Invitation sent, awaiting acceptance |
| `accepted` | User accepted and joined org |
| `expired` | Invitation expired (default: 7 days) |
| `revoked` | Admin cancelled the invitation |

---

## Path 3: Observer Mode

**Who:** Users browsing without organization commitment

**Trigger:** User signs in but chooses to browse without creating/joining org

### Flow

```
1. User signs in with Google
   Email: curious.user@gmail.com

2. System detects: No existing user, no pending invite

3. "Choose Your Path" screen shows option:
   ┌────────────────────────────────────────────────────────┐
   │  Welcome to QUAD Framework!                            │
   │                                                        │
   │  [🚀 Create Organization]  Start your own team         │
   │  [📨 I Have an Invite]     Enter invitation code       │
   │  [👀 Browse as Observer]   Explore first, decide later │
   └────────────────────────────────────────────────────────┘

4. User clicks "Browse as Observer"

5. Create user with special status:
   INSERT INTO "QUAD_users" (
     email, full_name, role, is_active, is_observer
   ) VALUES (
     'curious.user@gmail.com',
     'Curious User',
     'OBSERVER',
     true,
     true
   );

6. → Redirect to limited view
```

### Observer Permissions

| Can Access | Cannot Access |
|------------|---------------|
| QUAD methodology docs | Dashboard |
| Concept explanation | Domains |
| Terminology glossary | Tickets |
| Cheat sheet | Deployments |
| Quiz | Team management |
| Public content | Any org data |

### Converting Observer to Member

Observer can later:
1. **Create Organization** → Becomes QUAD_ADMIN
2. **Accept Invitation** → Joins with invited role

```sql
-- When observer creates org
UPDATE "QUAD_users" SET
  company_id = <new_org_id>,
  role = 'QUAD_ADMIN',
  is_observer = false
WHERE email = 'curious.user@gmail.com';
```

---

## Path 4: Enterprise SSO Request

**Who:** Large companies needing custom SSO (Okta, Azure AD, SAML)

**Trigger:** User clicks "Enterprise SSO" or organization needs corporate identity

### Flow

```
1. User visits: https://quadframe.work/enterprise
   OR selects "Enterprise SSO" from path selection

2. Enterprise request form:
   ┌────────────────────────────────────────────────────────┐
   │  🏛️ Enterprise SSO Setup Request                       │
   │                                                        │
   │  Organization Details                                  │
   │  ─────────────────────────────────────────────────────│
   │  Organization Name *                                   │
   │  [Massachusetts Mutual Life Insurance    ]            │
   │                                                        │
   │  Organization Domain *                                 │
   │  [massmutual.com                         ]            │
   │                                                        │
   │  Company Size *                                        │
   │  [Enterprise (500+ employees)            ▼]           │
   │                                                        │
   │  Contact Information                                   │
   │  ─────────────────────────────────────────────────────│
   │  Your Name *                                           │
   │  [John Smith                             ]            │
   │                                                        │
   │  Your Email *                                          │
   │  [john.smith@massmutual.com              ]            │
   │                                                        │
   │  Your Role *                                           │
   │  [IT Administrator                       ]            │
   │                                                        │
   │  IT Admin Email (will be QUAD_ADMIN) *                │
   │  [it-admin@massmutual.com                ]            │
   │                                                        │
   │  SSO Configuration                                     │
   │  ─────────────────────────────────────────────────────│
   │  SSO Provider *                                        │
   │  ○ Okta                                                │
   │  ○ Microsoft Azure AD / Entra ID                      │
   │  ○ Auth0                                               │
   │  ○ OneLogin                                            │
   │  ○ Ping Identity                                       │
   │  ○ SAML 2.0 (Generic)                                 │
   │  ○ OIDC (Generic)                                     │
   │                                                        │
   │  Additional Requirements                               │
   │  [We need SCIM provisioning and role mapping      ]   │
   │  [from our LDAP groups...                         ]   │
   │                                                        │
   │  [Submit Request]                                      │
   └────────────────────────────────────────────────────────┘

3. On submit:
   - Create pending organization request
   - Send notification to QUAD support team
   - Show confirmation page

4. Confirmation page:
   ┌────────────────────────────────────────────────────────┐
   │  ✅ Enterprise Request Submitted                       │
   │                                                        │
   │  Reference: ENT-2026-0102-001                         │
   │                                                        │
   │  What happens next:                                    │
   │  1. Our team will review within 1-2 business days     │
   │  2. We'll schedule a call to discuss SSO setup        │
   │  3. You'll receive configuration instructions         │
   │  4. Your team can start using QUAD                    │
   │                                                        │
   │  Questions? Contact enterprise@quadframe.work          │
   └────────────────────────────────────────────────────────┘

5. QUAD admin reviews and:
   - Configures SSO provider (Okta, Azure AD)
   - Creates organization
   - Sends setup instructions to IT admin email

6. Enterprise users can then:
   - Sign in via corporate SSO
   - Roles mapped from LDAP/SCIM groups
```

### Enterprise SSO Integration

| Provider | Integration Type | Role Mapping |
|----------|------------------|--------------|
| **Okta** | OIDC + SCIM | LDAP groups → QUAD roles |
| **Azure AD** | OIDC + Graph API | AD groups → QUAD roles |
| **Auth0** | OIDC | Auth0 roles → QUAD roles |
| **SAML 2.0** | SAML assertions | Attributes → QUAD roles |

### SCIM Provisioning (Enterprise)

For large enterprises, SCIM enables:
- Automatic user provisioning/deprovisioning
- Group membership sync
- Role assignment from IdP

```
Corporate IdP                    QUAD Platform
────────────                    ─────────────
User created    ──SCIM POST──►  Create QUAD_users
User updated    ──SCIM PATCH─►  Update QUAD_users
User deleted    ──SCIM DELETE►  Deactivate user
Group changed   ──SCIM PATCH─►  Update domain membership
```

---

## Database Schema Support

### Required Tables

```sql
-- Organizations (already exists)
QUAD_organizations (
  id, name, admin_email, size, sso_provider, is_active, ...
)

-- Users (already exists)
QUAD_users (
  id, company_id, email, full_name, role, is_active,
  is_observer,  -- NEW: for observer mode
  email_verified, ...
)

-- Invitations (already exists)
QUAD_org_invitations (
  id, org_id, email, role, invited_by, token,
  status,  -- pending, accepted, expired, revoked
  expires_at, accepted_at, ...
)

-- Enterprise Requests (NEW)
QUAD_enterprise_requests (
  id UUID PRIMARY KEY,
  org_name VARCHAR(255) NOT NULL,
  org_domain VARCHAR(255) NOT NULL,
  company_size VARCHAR(50) NOT NULL,
  contact_name VARCHAR(255) NOT NULL,
  contact_email VARCHAR(255) NOT NULL,
  contact_role VARCHAR(255),
  admin_email VARCHAR(255) NOT NULL,
  sso_provider VARCHAR(50) NOT NULL,
  requirements TEXT,
  status VARCHAR(50) DEFAULT 'pending',  -- pending, in_review, approved, rejected
  reference_number VARCHAR(50) UNIQUE,
  reviewed_by UUID REFERENCES "QUAD_users"(id),
  reviewed_at TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## UI Components Needed

| Component | Path | Purpose |
|-----------|------|---------|
| `/auth/login` | All | Sign in with SSO providers |
| `/auth/choose-path` | New users | Select onboarding path |
| `/auth/create-org` | Path 1 | Organization creation form |
| `/auth/join` | Path 2 | Enter invitation code |
| `/invite/[token]` | Path 2 | Accept invitation link |
| `/auth/observer` | Path 3 | Observer welcome page |
| `/enterprise` | Path 4 | Enterprise request form |
| `/enterprise/status/[ref]` | Path 4 | Request status tracking |

---

## Terminology Changes

Throughout the codebase, update:

| Old Term | New Term |
|----------|----------|
| Company | Organization |
| company_id | org_id (display), company_id (DB column) |
| Company Name | Organization Name |
| Company Size | Organization Size |

---

## Summary: Path Selection Logic

```typescript
async function determineOnboardingPath(user: GoogleUser): Promise<OnboardingPath> {
  // 1. Check if user exists
  const existingUser = await findUserByEmail(user.email);
  if (existingUser && existingUser.company_id) {
    return { path: 'dashboard', user: existingUser };
  }

  // 2. Check for pending invitation
  const invitation = await findPendingInvitation(user.email);
  if (invitation) {
    return { path: 'accept-invite', invitation };
  }

  // 3. New user - show path selection
  return {
    path: 'choose-path',
    isPersonalEmail: isPersonalEmail(user.email),
    email: user.email
  };
}
```

---

## Decisions Made

### 1. Invitation Email Matching: STRICT

Invitations are tied to specific email addresses:
- Invitation sent to `john@company.com` can ONLY be accepted by `john@company.com`
- If user signs in with different email, invitation won't be found
- Without valid invitation → User becomes **Observer** by default (both personal and org emails)

### 2. Default State: Observer

Any new user without invitation becomes Observer:
```
New User Signs In
       │
       ▼
┌─────────────────────┐
│ Has Valid Invite?   │
└─────────────────────┘
    │           │
   YES         NO
    │           │
    ▼           ▼
 Join Org    OBSERVER
 (invited    (default)
  role)
```

### 3. Observer Conversion Flow

Observer can convert via two paths:

**Path A: Create Organization**
```
Observer → "Create Organization" → Fill form → Becomes QUAD_ADMIN
```

**Path B: Receive Invitation**
```
Observer → Admin sends invite to observer's email → Observer accepts → Joins with invited role
```

### 4. Enterprise: Self-Hosted Only

Enterprise customers:
- **MUST self-host** QUAD Platform
- Bring their own:
  - Infrastructure (servers, K8s, cloud)
  - Database (PostgreSQL)
  - SSO (Okta, Azure AD)
  - AI Keys (Claude, OpenAI)
- QUAD provides: Code license + support

---

## Hosting & Pricing Model

### Three Deployment Options

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        QUAD Platform Hosting Options                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐      │
│  │  🌩️ QUAD CLOUD   │  │  🏠 SELF-HOSTED  │  │  🏛️ ENTERPRISE   │      │
│  │                  │  │                  │  │                  │      │
│  │  We host         │  │  You host        │  │  You host        │      │
│  │  everything      │  │  QUAD provides   │  │  everything      │      │
│  │                  │  │  support         │  │                  │      │
│  │  $XX/mo + AI     │  │  $XX/mo + BYOK   │  │  License + BYOK  │      │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘      │
│                                                                          │
│  Startup/Small Biz      Small/Medium Biz       Enterprise (500+)        │
│  1-50 employees         10-500 employees       500+ employees           │
└─────────────────────────────────────────────────────────────────────────┘
```

### AI Pricing: Claude Integration

**Option 1: QUAD-Provided Claude (Recommended for simplicity)**
- QUAD resells Claude Pro equivalent
- Price: ~$17-20/user/month (annual) or ~$20/user/month (monthly)
- Included in QUAD subscription
- No API key management needed

**Option 2: BYOK - Bring Your Own Key**
- User provides their own Anthropic API key
- No markup from QUAD
- User pays Anthropic directly
- Full control over usage/limits

| Plan | Hosting | AI Model | Target |
|------|---------|----------|--------|
| **Startup Free** | QUAD Cloud | Limited Claude | Solo/Small teams (≤5) |
| **Small Business** | QUAD Cloud OR Self | QUAD Claude OR BYOK | Teams 6-50 |
| **Medium Business** | Self-Hosted | BYOK Required | Teams 51-200 |
| **Enterprise** | Self-Hosted | BYOK Required | 500+ |

### What Enterprise Brings

| Component | Enterprise Provides | QUAD Provides |
|-----------|---------------------|---------------|
| Infrastructure | Servers, K8s, Cloud | Helm charts, Docker images |
| Database | PostgreSQL instance | Schema, migrations |
| SSO | Okta/Azure AD config | OIDC/SAML integration |
| AI Keys | Claude/OpenAI API keys | Provider adapters |
| Storage | S3/GCS buckets | Storage abstraction |
| Support | - | 24/7 enterprise support |

---

## Revised Path Flow (Final)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         User Visits quadframe.work                       │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │ Sign In     │ │ Enterprise  │ │ Browse Docs │
            │ (Google/GH) │ │ Contact     │ │ (No login)  │
            └─────────────┘ └─────────────┘ └─────────────┘
                    │               │               │
                    ▼               │               │
         ┌────────────────────┐     │               │
         │ Check User Status  │     │               │
         └────────────────────┘     │               │
           │          │             │               │
        EXISTS    NEW USER          │               │
           │          │             │               │
           ▼          ▼             │               │
      Dashboard   ┌───────────┐     │               │
                  │Has Invite?│     │               │
                  └───────────┘     │               │
                    │      │        │               │
                   YES    NO        │               │
                    │      │        │               │
                    ▼      ▼        ▼               ▼
              Join Org  OBSERVER  Enterprise    Public Docs
              (role)    (default)  Request      (read-only)
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        Create Org              Wait for Invite
        (become QUAD_ADMIN)     (stay Observer)
```

---

## Free Tier Limits

### Startup Free Plan
- **Users:** Up to 5 per organization
- **AI Usage:** Limited Claude calls/day
- **Features:** Full feature access
- **Support:** Community only

### What Happens at Limit?

```
Organization hits 5 user limit
              │
              ▼
┌─────────────────────────────────────────┐
│ "Upgrade Required"                       │
│                                          │
│ Your organization has reached the        │
│ free tier limit of 5 users.              │
│                                          │
│ Options:                                 │
│ • Upgrade to Small Business ($XX/mo)     │
│ • Remove inactive users                  │
│ • Contact sales for custom plan          │
│                                          │
│ [View Plans]  [Manage Users]             │
└─────────────────────────────────────────┘
```

**Behavior:**
- Existing users continue working (no disruption)
- New invitations blocked until upgrade or user removal
- Admins see upgrade prompts in dashboard

---

## Sources

- [Claude Pricing](https://claude.com/pricing) - Official pricing page
- [Claude Pro Plan](https://support.claude.com/en/articles/8325606-what-is-the-pro-plan) - Pro plan details
- [Claude Max Plan](https://support.claude.com/en/articles/11049741-what-is-the-max-plan) - Max plan details
- [JetBrains BYOK](https://blog.jetbrains.com/ai/2025/12/bring-your-own-key-byok-is-now-live-in-jetbrains-ides/) - BYOK implementation example
- [Warp BYOK](https://docs.warp.dev/support-and-billing/plans-and-pricing/bring-your-own-api-key) - Another BYOK example
- [VS Code BYOK](https://code.visualstudio.com/blogs/2025/10/22/bring-your-own-key) - VS Code approach
- [Anthropic Startups Program](https://www.anthropic.com/startups) - Partner program

---

**Last Updated:** January 2, 2026
**Author:** Claude Code + Suman Addanki
