# QUAD Platform - Authentication Testing Guide

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** Step-by-step testing guide for OAuth SSO authentication flows

---

## Test Environment Setup

### Prerequisites

1. **Database Running**
   ```bash
   # Mac Studio PostgreSQL (DEV)
   docker ps | grep postgres-dev
   # Should show: postgres-dev running on port 16201
   ```

2. **QUAD Tables Loaded**
   ```bash
   docker exec postgres-dev psql -U nutrinine_user -d nutrinine_dev_db -c "\dt QUAD_*"
   # Should show: 6 QUAD tables
   ```

3. **Next.js Dev Server**
   ```bash
   cd /Users/semostudio/git/a2vibecreators/quadframework
   npm run dev
   # Should run on: http://localhost:3003
   ```

---

## Testing Combinations

We will test these SSO provider combinations to ensure flexibility:

| Test Case | Okta | Azure AD | Google | GitHub | Auth0 | OIDC | Purpose |
|-----------|------|----------|--------|--------|-------|------|---------|
| **TC1** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | Mass Mutual (single provider) |
| **TC2** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | Enterprise (Okta + Microsoft) |
| **TC3** | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | Startup (Google + GitHub) |
| **TC4** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | Medium (3 providers) |
| **TC5** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | No providers (should show error) |

---

## Test Case 1: Okta Only (Mass Mutual)

**Goal:** Test single-provider setup (most common for enterprises)

### Step 1: Configure `.env.local`

```bash
# Copy example
cp .env.example .env.local

# Edit .env.local
NEXTAUTH_URL=http://localhost:3003
NEXTAUTH_SECRET=test-secret-key-minimum-32-characters-long

# Enable ONLY Okta
NEXT_PUBLIC_OKTA_ENABLED=true
NEXT_PUBLIC_AZURE_AD_ENABLED=false
NEXT_PUBLIC_GOOGLE_ENABLED=false
NEXT_PUBLIC_GITHUB_ENABLED=false
NEXT_PUBLIC_AUTH0_ENABLED=false
NEXT_PUBLIC_OIDC_ENABLED=false

# Okta credentials (get from Okta Admin Console)
OKTA_CLIENT_ID=your-okta-client-id
OKTA_CLIENT_SECRET=your-okta-client-secret
OKTA_ISSUER=https://dev-12345.okta.com
```

### Step 2: Restart Dev Server

```bash
# Kill existing server (Ctrl+C)
npm run dev
```

### Step 3: Test Signup Flow

1. **Navigate to signup:**
   ```
   http://localhost:3003/auth/signup
   ```

2. **Fill form:**
   - Company Name: `Test Company - Okta`
   - Admin Email: `admin@testcompany.com`
   - Company Size: `Enterprise`
   - SSO Provider: `Okta`
   - Message: `Testing Okta SSO integration`

3. **Submit form**

4. **Expected result:**
   - ✅ Success screen appears
   - ✅ Database check:
     ```sql
     SELECT name, admin_email, size FROM QUAD_organizations WHERE admin_email = 'admin@testcompany.com';
     ```
     Should return: `Test Company - Okta | admin@testcompany.com | enterprise`

### Step 4: Test Login Flow

1. **Navigate to login:**
   ```
   http://localhost:3003/auth/login
   ```

2. **Expected UI:**
   - ✅ ONE button visible: "Continue with Okta"
   - ❌ NO other provider buttons
   - ✅ Security badge: "Secured with OAuth 2.0 / OIDC"

3. **Click "Continue with Okta"**

4. **Expected flow:**
   - Redirect to: `https://dev-12345.okta.com/oauth2/authorize?...`
   - Okta login screen appears
   - Enter Okta credentials
   - Redirect back to: `http://localhost:3003/api/auth/callback/okta`
   - Auto-login → Dashboard

5. **Verify dashboard:**
   - ✅ User name/email displayed
   - ✅ Company name: "Test Company - Okta"
   - ✅ Plan: "Enterprise"
   - ✅ Avatar image (if provided by Okta)

### Step 5: Verify Database

```sql
-- Check user was created
SELECT email, role, oauth_provider, is_active
FROM QUAD_users
WHERE email = 'admin@testcompany.com';

-- Expected:
-- email: admin@testcompany.com
-- role: QUAD_ADMIN
-- oauth_provider: okta
-- is_active: true
```

### Step 6: Test Sign Out

1. Click "Sign Out" button
2. Expected: Redirect to `/` (homepage or login)
3. Try accessing `/dashboard` directly
4. Expected: Redirect to `/auth/login` (session cleared)

---

## Test Case 2: Okta + Azure AD (Multi-Provider)

**Goal:** Test that users can choose between multiple SSO providers

### Step 1: Configure `.env.local`

```bash
# Enable TWO providers
NEXT_PUBLIC_OKTA_ENABLED=true
NEXT_PUBLIC_AZURE_AD_ENABLED=true
NEXT_PUBLIC_GOOGLE_ENABLED=false
NEXT_PUBLIC_GITHUB_ENABLED=false
NEXT_PUBLIC_AUTH0_ENABLED=false
NEXT_PUBLIC_OIDC_ENABLED=false

# Okta credentials
OKTA_CLIENT_ID=your-okta-client-id
OKTA_CLIENT_SECRET=your-okta-client-secret
OKTA_ISSUER=https://dev-12345.okta.com

# Azure AD credentials
AZURE_AD_CLIENT_ID=your-azure-client-id
AZURE_AD_CLIENT_SECRET=your-azure-client-secret
AZURE_AD_TENANT_ID=common
```

### Step 2: Test Login Page

1. Navigate to: `http://localhost:3003/auth/login`

2. **Expected UI:**
   - ✅ TWO buttons visible:
     - "Continue with Okta" (blue)
     - "Continue with Microsoft" (gray/black)
   - ❌ NO other provider buttons

### Step 3: Test Okta Login

1. Click "Continue with Okta"
2. Complete Okta flow
3. Should land on `/dashboard`

### Step 4: Sign Out and Test Azure Login

1. Sign out
2. Click "Continue with Microsoft"
3. Complete Microsoft flow
4. Should land on `/dashboard`

### Step 5: Verify Both Users in Database

```sql
-- Check both OAuth providers created separate users
-- Note: company_id column maps to org_id in Prisma
SELECT email, oauth_provider FROM QUAD_users
WHERE company_id = (SELECT id FROM QUAD_organizations WHERE admin_email = 'admin@testcompany.com');

-- Expected: TWO rows (if different emails) or ONE row (if same email used)
```

---

## Test Case 3: Google + GitHub (Startup)

**Goal:** Test startup-friendly SSO providers

### Step 1: Configure `.env.local`

```bash
NEXT_PUBLIC_OKTA_ENABLED=false
NEXT_PUBLIC_AZURE_AD_ENABLED=false
NEXT_PUBLIC_GOOGLE_ENABLED=true
NEXT_PUBLIC_GITHUB_ENABLED=true
NEXT_PUBLIC_AUTH0_ENABLED=false
NEXT_PUBLIC_OIDC_ENABLED=false

# Google credentials
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# GitHub credentials
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret
```

### Step 2: Test Signup with Google

1. Navigate to: `http://localhost:3003/auth/signup`
2. Fill form:
   - Company Name: `Startup Test`
   - Admin Email: `founder@startup.com`
   - Company Size: `Startup`
   - SSO Provider: `Google`
3. Submit

### Step 3: Test Login Page

1. Navigate to: `http://localhost:3003/auth/login`
2. **Expected UI:**
   - ✅ "Continue with Google" (white button with Google colors)
   - ✅ "Continue with GitHub" (dark button)

### Step 4: Test Free Tier User Limit

1. **Create 5 users** (via Google or GitHub login with different emails)
2. **Try to add 6th user**
3. **Expected:**
   - Redirect to: `/upgrade?reason=user-limit`
   - Error message: "Free tier limited to 5 users"

---

## Test Case 4: Three Providers (Medium Company)

**Goal:** Test UI with 3 providers enabled

### Configuration

```bash
NEXT_PUBLIC_OKTA_ENABLED=true
NEXT_PUBLIC_AZURE_AD_ENABLED=true
NEXT_PUBLIC_GOOGLE_ENABLED=true
```

### Expected Login Page

```
┌─────────────────────────────────────┐
│  Continue with Okta        (blue)   │
├─────────────────────────────────────┤
│  Continue with Microsoft   (gray)   │
├─────────────────────────────────────┤
│  Continue with Google      (white)  │
└─────────────────────────────────────┘
```

### Test All 3 Flows

1. Test Okta login → Dashboard → Sign out
2. Test Microsoft login → Dashboard → Sign out
3. Test Google login → Dashboard → Sign out

---

## Test Case 5: No Providers Enabled (Error State)

**Goal:** Test graceful error handling when no SSO configured

### Configuration

```bash
NEXT_PUBLIC_OKTA_ENABLED=false
NEXT_PUBLIC_AZURE_AD_ENABLED=false
NEXT_PUBLIC_GOOGLE_ENABLED=false
NEXT_PUBLIC_GITHUB_ENABLED=false
NEXT_PUBLIC_AUTH0_ENABLED=false
NEXT_PUBLIC_OIDC_ENABLED=false
```

### Expected Login Page

```
┌─────────────────────────────────────┐
│  No SSO providers configured.       │
│  Please contact your administrator. │
└─────────────────────────────────────┘
```

---

## Testing Checklist

Before marking auth as "complete", verify:

### Login Page
- [ ] Only enabled providers show buttons
- [ ] Disabled providers are hidden
- [ ] Loading states work (spinner appears on click)
- [ ] Error messages display correctly
- [ ] "Request access" link works

### Signup Page
- [ ] Form validation works (required fields)
- [ ] Email validation works (invalid@)
- [ ] Duplicate email detection works
- [ ] Success screen appears after submit
- [ ] Database entry created correctly

### Dashboard Page
- [ ] Requires authentication (redirects if not logged in)
- [ ] User info displays correctly
- [ ] Company info displays correctly
- [ ] Avatar image displays (if provided by SSO)
- [ ] Sign out button works

### Database
- [ ] `QUAD_organizations` table populated
- [ ] `QUAD_users` table populated (company_id maps to org_id in Prisma)
- [ ] `oauth_provider` column set correctly
- [ ] User count enforced for free tier

### API Endpoints
- [ ] `/api/auth/request-access` creates company
- [ ] `/api/company/profile` returns correct data
- [ ] `/api/auth/callback/{provider}` handles OAuth flow
- [ ] Protected routes return 401 when not authenticated

---

## Common Issues & Fixes

### Issue 1: "No providers configured" even with .env.local set

**Cause:** Next.js didn't reload environment variables

**Fix:**
```bash
# Kill server and restart
npm run dev
```

### Issue 2: OAuth callback fails with 400 error

**Cause:** Redirect URI mismatch in SSO provider settings

**Fix:**
- Go to provider's admin console
- Update redirect URI to: `http://localhost:3003/api/auth/callback/{provider}`
- For Okta: `http://localhost:3003/api/auth/callback/okta`
- For Azure: `http://localhost:3003/api/auth/callback/azure-ad`

### Issue 3: User created but dashboard shows "Loading..."

**Cause:** `/api/company/profile` endpoint failing

**Fix:**
```bash
# Check server logs for errors
# Common: Database connection timeout
# Fix: Verify DATABASE_URL in .env.local
```

### Issue 4: Free tier limit not working

**Cause:** User count query failing or company_size not set

**Fix:**
```sql
-- Verify organization size
SELECT name, size FROM QUAD_organizations;

-- Update if needed
UPDATE QUAD_organizations SET size = 'startup' WHERE admin_email = 'test@example.com';
```

---

## Test Environment Variables Quick Reference

**Okta Test:**
```bash
NEXT_PUBLIC_OKTA_ENABLED=true
OKTA_CLIENT_ID=0oa...
OKTA_CLIENT_SECRET=abc123...
OKTA_ISSUER=https://dev-12345.okta.com
```

**Google Test:**
```bash
NEXT_PUBLIC_GOOGLE_ENABLED=true
GOOGLE_CLIENT_ID=123-abc.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-...
```

**GitHub Test:**
```bash
NEXT_PUBLIC_GITHUB_ENABLED=true
GITHUB_ID=Iv1.abc123...
GITHUB_SECRET=abc123...
```

**Azure AD Test:**
```bash
NEXT_PUBLIC_AZURE_AD_ENABLED=true
AZURE_AD_CLIENT_ID=12345678-1234-1234-1234-123456789abc
AZURE_AD_CLIENT_SECRET=abc~123...
AZURE_AD_TENANT_ID=common
```

---

## Mass Mutual Demo Test Script

**For Mass Mutual presentation, test this specific combination:**

1. **Setup:**
   - Enable: Okta ONLY
   - Company: Massachusetts Mutual Life Insurance
   - Admin: demo@massmutual.com

2. **Demo Flow:**
   - Show signup form → Submit
   - Show login page (Okta button)
   - Click Okta → Mock login (or real Okta test account)
   - Land on dashboard
   - Show company info, integrations

3. **Talking Points:**
   - "Your Okta credentials work immediately"
   - "No password to remember"
   - "Free tier: 5 users included"
   - "Self-hosted: Runs in your cloud"

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
