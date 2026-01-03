# Portal Organization Architecture Plan

## Overview

A **Portal Organization** is a special "system" org that provides:
1. Platform-wide admin access (AI pool, billing, all orgs)
2. Internal testing environment
3. Demo/showcase projects
4. Invisible to regular users

## Portal Org Properties

| Property | Value |
|----------|-------|
| Name | `QUAD Portal` |
| Slug | `portal` |
| Type | `PORTAL` (new org_type) |
| Domain | `quadframe.work` |
| Visibility | Hidden from org listings |
| Access | Platform admins only |

## User Access Model

### Portal Roles

| Role | Access Level |
|------|--------------|
| `PORTAL_OWNER` | Full platform admin (billing, all orgs, AI pool) |
| `PORTAL_ADMIN` | Platform reports, user management |
| `PORTAL_TESTER` | Test domains only, no billing access |
| `PORTAL_SUPPORT` | Read-only access to customer orgs (with audit) |

### Login Flow

```
User: suman@quadframe.work
  ↓
Check: Is email domain = quadframe.work?
  ↓ YES
Grant: Portal access + assigned portal role
  ↓
Show: Portal Dashboard (not regular dashboard)
```

## Portal Dashboard Features

### 1. Platform Overview
- Total orgs (paying/free/BYOK)
- Total users
- AI pool health
- Revenue metrics

### 2. AI Credits Admin
- Platform pool balance
- Per-org usage breakdown
- Reconciliation with Claude billing
- Free tier runway

### 3. Org Management
- List all orgs (search, filter)
- View any org's details (with audit log)
- Impersonate user (for support, with audit)
- Manage org tiers

### 4. User Management
- List all users
- View user activity
- Support actions (reset password, verify email)

### 5. Test Projects
- nutrinine.ai (NutriNine test project)
- a2vibes.life (Lifestyle test project)
- Internal QUAD testing

### 6. Billing Admin
- Revenue reports
- Invoice generation
- Payment status
- Refund processing

## Database Schema Changes

### 1. Add org_type to QUAD_organizations

```prisma
model QUAD_organizations {
  // ... existing fields ...

  org_type    String @default("CUSTOMER") @db.VarChar(20)
  // CUSTOMER = normal org
  // PORTAL = system portal org
  // TEST = internal testing org
  // DEMO = demo/showcase org

  is_visible  Boolean @default(true) // false for PORTAL
}
```

### 2. Add QUAD_portal_access table

```prisma
model QUAD_portal_access {
  id          String @id @default(uuid()) @db.Uuid
  user_id     String @db.Uuid

  portal_role String @db.VarChar(50) // PORTAL_OWNER, PORTAL_ADMIN, etc.

  // Granular permissions
  can_view_all_orgs    Boolean @default(false)
  can_impersonate      Boolean @default(false)
  can_manage_billing   Boolean @default(false)
  can_manage_ai_pool   Boolean @default(false)
  can_access_test_orgs Boolean @default(true)

  granted_by  String? @db.Uuid
  granted_at  DateTime @default(now())
  expires_at  DateTime?

  is_active   Boolean @default(true)

  @@unique([user_id])
}
```

### 3. Add QUAD_portal_audit_log

```prisma
model QUAD_portal_audit_log {
  id          String @id @default(uuid()) @db.Uuid

  portal_user_id  String @db.Uuid  // Who did the action
  action_type     String @db.VarChar(50) // view_org, impersonate, edit_billing

  // What was affected
  target_org_id   String? @db.Uuid
  target_user_id  String? @db.Uuid

  // Details
  action_details  Json?   // { "reason": "support ticket #123" }
  ip_address      String? @db.VarChar(45)
  user_agent      String?

  created_at      DateTime @default(now())

  @@index([portal_user_id])
  @@index([target_org_id])
  @@index([created_at])
}
```

## Test Projects Structure

### nutrinine.ai (NutriNine Test)

| Property | Value |
|----------|-------|
| Org | `QUAD Portal` (shared) or dedicated `NutriNine Test` |
| Type | `TEST` |
| Domains | Health tracking, Nutrition, Family |
| Purpose | Test AI features with health context |

### a2vibes.life (Lifestyle Test)

| Property | Value |
|----------|-------|
| Org | `QUAD Portal` (shared) or dedicated |
| Type | `TEST` |
| Domains | Wellness, Productivity, Lifestyle |
| Purpose | Test general project management |

### Test Data Strategy

```
Option A: Shared Portal Org
├── QUAD Portal (org)
│   ├── [PORTAL] Admin Domain
│   ├── [TEST] NutriNine Domain
│   └── [TEST] A2Vibes Domain

Option B: Separate Test Orgs (Recommended)
├── QUAD Portal (PORTAL org) - Admin only
├── NutriNine Test (TEST org) - nutrinine.ai
└── A2Vibes Test (TEST org) - a2vibes.life
```

**Recommendation**: Option B - Separate orgs keep test data isolated and prevent accidental mixing with admin functions.

## API Routes to Create

### Portal Admin APIs

| Route | Purpose |
|-------|---------|
| `GET /api/portal/overview` | Platform stats |
| `GET /api/portal/orgs` | List all orgs |
| `GET /api/portal/orgs/[id]` | View org details |
| `GET /api/portal/users` | List all users |
| `POST /api/portal/impersonate` | Start impersonation session |
| `GET /api/portal/audit` | Audit log |

### Middleware Update

```typescript
// Check portal access on /api/portal/* routes
if (pathname.startsWith('/api/portal')) {
  const portalAccess = await getPortalAccess(userId);
  if (!portalAccess?.is_active) {
    return 403 Forbidden;
  }
  // Log access to audit
}
```

## UI Pages

### Portal Dashboard Layout

```
/portal                    → Overview
/portal/ai-pool            → AI Credits Admin
/portal/orgs               → Org Management
/portal/orgs/[id]          → Org Details
/portal/users              → User Management
/portal/test/nutrinine     → NutriNine Test
/portal/test/a2vibes       → A2Vibes Test
/portal/billing            → Billing Admin
/portal/audit              → Audit Logs
```

## Implementation Order

### Phase 1: Database + Seed (1-2 hours)
1. Add org_type, is_visible to QUAD_organizations
2. Create QUAD_portal_access table
3. Create QUAD_portal_audit_log table
4. Seed: Create Portal org, grant access to suman@quadframe.work
5. Seed: Create test orgs for nutrinine.ai, a2vibes.life

### Phase 2: Portal APIs (2-3 hours)
1. Portal access check middleware
2. GET /api/portal/overview
3. GET /api/portal/orgs (paginated)
4. Integrate existing /api/admin/ai-pool into portal

### Phase 3: Portal UI (3-4 hours)
1. Portal layout (different from main app)
2. Overview dashboard
3. Org list with search
4. AI pool visualization

### Phase 4: Test Projects (1-2 hours)
1. Create test domains in test orgs
2. Seed sample data for testing
3. Document test accounts

## Bootstrap Script

```bash
# Run after db push
npx prisma db seed

# Seed script will:
# 1. Create QUAD Portal org (if not exists)
# 2. Create or update suman@quadframe.work as PORTAL_OWNER
# 3. Create NutriNine Test org
# 4. Create A2Vibes Test org
# 5. Create sample domains in test orgs
```

## Security Considerations

1. **All portal actions logged** - audit trail required
2. **IP restriction** (optional) - limit portal access to known IPs
3. **Session timeout** - shorter session for portal (1 hour)
4. **2FA required** - for PORTAL_OWNER role
5. **Impersonation limits** - can't impersonate other portal users
6. **No data modification** - most portal access is read-only

## Questions to Resolve

1. Should test orgs share Portal org or be separate?
   - **Recommendation**: Separate (cleaner isolation)

2. Should testers have their own credentials or shared?
   - **Recommendation**: Own credentials (audit trail)

3. Which email domains grant portal access?
   - quadframe.work (confirmed)
   - a2vibecreators.com (TBD)

4. Should impersonation require 2FA confirmation?
   - **Recommendation**: Yes for production

---

## Ready to Implement?

This plan covers:
- [x] Portal org concept
- [x] Database schema
- [x] API structure
- [x] UI pages
- [x] Test projects (nutrinine.ai, a2vibes.life)
- [x] Security model
- [x] Implementation order

**Estimated Total**: 8-12 hours

Shall I proceed with Phase 1 (Database + Seed)?
