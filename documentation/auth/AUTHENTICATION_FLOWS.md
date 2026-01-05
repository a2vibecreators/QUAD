# QUAD Platform - Complete Authentication Flows

**Last Updated:** January 5, 2026
**Version:** 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Flow vs Journey - Definitions](#flow-vs-journey---definitions)
3. [All Possible Flows](#all-possible-flows)
4. [Detailed Flow Diagrams](#detailed-flow-diagrams)
5. [Known Issues](#known-issues)
6. [Testing Matrix](#testing-matrix)

---

## Overview

QUAD Platform supports multiple authentication methods:
- **OAuth SSO:** Google, GitHub, Azure AD, Okta, Auth0
- **Email/OTP:** Passwordless magic link
- **Credentials:** Email + password (deprecated)

---

## Flow vs Journey - Definitions

### Flow
**Definition:** A specific path through the system from point A to point B.
**Examples:**
- `signin → dashboard`
- `signup → dashboard`
- `OAuth callback → account creation`

**Characteristics:**
- Single purpose
- Linear path
- Technical implementation detail

### Journey
**Definition:** Complete end-to-end user experience across multiple touchpoints.
**Examples:**
- First-time user onboarding (Homepage → Signup → Domain Setup → First Project)
- Returning user daily workflow (Login → Dashboard → Create Ticket → Deploy)

**Characteristics:**
- Multi-step experience
- Includes context switching
- Business/UX focused

**Answer to User's Question:**
> Is "sign in → dashboard" a journey?

**No.** It's a **flow**. A journey would be:
- "New user onboarding journey" (Sign up → Verify email → Select domain → Invite team → Create first project)
- "Daily developer workflow journey" (Sign in → Dashboard → View tickets → Code → Deploy → Review)

---

## All Possible Flows

### 1. Sign-In Flows (Returning Users)

| Flow | Entry Point | Exit Point | Description |
|------|-------------|------------|-------------|
| **OAuth Sign-In (Existing User)** | `/auth/login` → Click Google | `/dashboard` | User exists in DB, OAuth creates session |
| **Email/OTP Sign-In** | `/auth/login` → Enter email | `/dashboard` | Passwordless login via OTP |
| **Credentials Sign-In** | `/auth/login` → Email + password | `/dashboard` | Legacy password-based login |

### 2. Sign-Up Flows (New Users)

| Flow | Entry Point | Exit Point | Description |
|------|-------------|------------|-------------|
| **OAuth Sign-Up (New User)** | `/auth/login` → Click Google | `/dashboard` | User doesn't exist, creates account via OAuth |
| **Email/OTP Sign-Up** | `/auth/signup` → Enter email | `/auth/verify` → `/dashboard` | Passwordless signup via OTP |
| **Credentials Sign-Up** | `/auth/signup` → Form | `/dashboard` | Legacy password-based signup |

### 3. Special Flows

| Flow | Entry Point | Exit Point | Description |
|------|-------------|------------|-------------|
| **Account Linking** | OAuth login with existing email | `/dashboard` | Links OAuth provider to existing account |
| **Domain Selection** | After first login | `/dashboard` | User selects/creates domain |
| **Enterprise Access Request** | `/auth/signup` → Enterprise | `/auth/signup?success=pending` | Manual approval required |

---

## Detailed Flow Diagrams

### Flow 1: OAuth Sign-In (Returning User - Account Exists)

```
┌─────────────────────────────────────────────────────────────────┐
│ FLOW: oauth-signin-existing-user                               │
│ User: madhuri.recherla@gmail.com (EXISTS in database)         │
└─────────────────────────────────────────────────────────────────┘

1. User visits: /auth/login
2. Clicks: "Sign in with Google"
3. Redirect to: accounts.google.com
4. User selects account / authorizes
5. Redirect to: /api/auth/callback/google
6. NextAuth signIn callback:
   ├─ Calls: quad-services-dev:8080/users/email/madhuri.recherla@gmail.com
   ├─ Response: 200 OK (user found)
   ├─ Log: "Account linking: madhuri.recherla@gmail.com signed in via google"
   └─ Returns: true (allow sign-in)
7. NextAuth jwt callback:
   ├─ Fetches user data from backend
   ├─ Creates JWT token
   └─ Stores in session
8. NextAuth redirect callback:
   ├─ URL: /dashboard
   └─ Returns: https://dev.quadframe.work/dashboard
9. User lands on: /dashboard ✅

Duration: 2-3 seconds
Issues: None (works correctly)
```

### Flow 2: OAuth Sign-Up (New User - Account Doesn't Exist)

```
┌─────────────────────────────────────────────────────────────────┐
│ FLOW: oauth-signup-new-user                                    │
│ User: newuser@example.com (DOES NOT EXIST in database)        │
└─────────────────────────────────────────────────────────────────┘

1. User visits: /auth/login
2. Clicks: "Sign in with Google"
3. Redirect to: accounts.google.com (with prompt=select_account)
4. User selects account / authorizes
5. Redirect to: /api/auth/callback/google
6. NextAuth signIn callback:
   ├─ Calls: quad-services-dev:8080/users/email/newuser@example.com
   ├─ Response: 404 Not Found
   ├─ Log: "User not found (404) - treating as new user"
   ├─ Log: "New OAuth user: newuser@example.com via google - redirecting to signup"
   └─ Returns: '/auth/signup?oauth=true&provider=google&email=newuser@example.com&name=New User'
7. NextAuth redirect callback:
   ├─ URL: /auth/signup?oauth=true&provider=google&email=...
   ├─ Log: "New OAuth user, allowing redirect to signup"
   └─ Returns: https://dev.quadframe.work/auth/signup?oauth=true&...
8. User lands on: /auth/signup (with pre-filled email, name)
9. User selects org type: Startup / Business / Enterprise
10. User fills optional fields: Company name (optional)
11. User clicks: "Complete Signup"
12. Frontend calls: POST /api/auth/complete-oauth-signup
    ├─ Backend creates: Organization + User
    ├─ Response: { success: true }
13. ✅ FIXED: Frontend calls: POST /api/auth/create-session
    ├─ Fetches user from backend
    ├─ Creates JWT token
    ├─ Sets NextAuth session cookie
    ├─ Response: { success: true }
14. Frontend redirects: router.push('/dashboard')
15. User lands on: /dashboard ✅

Duration: 3-5 seconds
Issues: ✅ RESOLVED - No double redirect
```

### Flow 3: Email/OTP Sign-In (Returning User)

```
┌─────────────────────────────────────────────────────────────────┐
│ FLOW: email-otp-signin                                         │
│ User: user@example.com (EXISTS in database)                   │
└─────────────────────────────────────────────────────────────────┘

1. User visits: /auth/login
2. Enters email: user@example.com
3. Clicks: "Send Login Code"
4. Backend sends: 6-digit OTP to email
5. User enters: OTP code
6. Frontend calls: POST /api/auth/verify-code
7. Backend validates: OTP code
8. Backend returns: { success: true, token: '...' }
9. Frontend stores: localStorage.setItem('auth_token', token)
10. Redirect to: /dashboard ✅

Duration: 30-60 seconds (email delivery)
Issues: None (works correctly)
```

### Flow 4: Email/OTP Sign-Up (New User)

```
┌─────────────────────────────────────────────────────────────────┐
│ FLOW: email-otp-signup                                         │
│ User: newuser@example.com (DOES NOT EXIST in database)        │
└─────────────────────────────────────────────────────────────────┘

1. User visits: /auth/signup
2. Selects org type: Startup / Business / Enterprise
3. Enters: Full name, email, company name
4. Clicks: "Sign Up"
5. Backend sends: 6-digit OTP to email
6. Redirect to: /auth/verify?email=newuser@example.com
7. User enters: OTP code
8. Frontend calls: POST /api/auth/verify-code
9. Backend:
   ├─ Validates OTP
   ├─ Creates organization + user
   └─ Returns: { success: true, token: '...' }
10. Frontend stores: token
11. Redirect to: /dashboard ✅

Duration: 30-60 seconds
Issues: None (works correctly)
```

---

## Known Issues

### ✅ Issue 1: OAuth Sign-Up Redirects to Google Twice (RESOLVED)

**Status:** ✅ **FIXED** (January 5, 2026)
**Severity:** Medium (UX confusion, but flow completes)
**Affected Flow:** oauth-signup-new-user

**Root Cause:**
```typescript
// BEFORE (line 208-213 in signup/page.tsx)
if (data.success) {
  await signIn(verifiedUser.provider, {
    callbackUrl: '/dashboard',
    redirect: true,  // ← Full OAuth redirect
  });
}
```

**Solution Implemented (Option A - Server-Side Session Creation):**

**1. Created new endpoint:** `/api/auth/create-session/route.ts`
```typescript
// Manually creates NextAuth session without OAuth redirect
const token = await encode({
  secret: JWT_SECRET,
  token: { ...userdata },
  maxAge: 24 * 60 * 60,
});

cookies().set({
  name: 'next-auth.session-token',
  value: token,
  httpOnly: true,
  maxAge: 24 * 60 * 60,
});
```

**2. Updated signup flow:** `signup/page.tsx`
```typescript
// AFTER - Direct session creation
if (data.success) {
  await fetch('/api/auth/create-session', {
    method: 'POST',
    body: JSON.stringify({ email, provider }),
  });
  router.push('/dashboard'); // No OAuth redirect
}
```

**Result:** Users no longer see Google twice. Flow is now:
```
1. Click Google → OAuth → Signup form
2. Complete form → Backend creates user
3. Frontend creates session → Dashboard ✅
```

**Testing:**
```bash
# Test new user OAuth signup
1. Visit https://dev.quadframe.work/auth/login
2. Click "Sign in with Google"
3. Select account (account picker should show)
4. Complete signup form
5. Should go directly to dashboard (no second Google screen)
```

---

## Testing Matrix

### Test Scenarios

| # | Scenario | Entry Point | Expected Outcome | Status |
|---|----------|-------------|------------------|--------|
| 1 | **New user, OAuth sign-up** | Click Google on /auth/login | Create account → Dashboard | ✅ Fixed - No double redirect |
| 2 | **Existing user, OAuth sign-in** | Click Google on /auth/login | Dashboard | ✅ Works |
| 3 | **New user, email/OTP sign-up** | /auth/signup → Enter email | Verify OTP → Dashboard | ✅ Works |
| 4 | **Existing user, email/OTP sign-in** | /auth/login → Enter email | Verify OTP → Dashboard | ✅ Works |
| 5 | **Account linking** | OAuth login with existing email | Link provider → Dashboard | ✅ Works |
| 6 | **Domain selection** | First login, no domain | Select/create domain → Dashboard | ❓ Untested |
| 7 | **Enterprise signup** | Select Enterprise on signup | Access request submitted | ❓ Untested |
| 8 | **Same browser, multiple accounts** | Sign out, sign in different Google | New session | ❓ Untested |
| 9 | **Incognito OAuth** | Incognito mode, OAuth login | Works same as normal | ❓ Untested |
| 10 | **Expired session** | Session expired, revisit /dashboard | Redirect to login | ❓ Untested |

### Test Combinations

| Browser State | User State | Auth Method | Expected |
|---------------|-----------|-------------|----------|
| Logged into Google | New user | Google OAuth | Signup → Dashboard |
| Logged into Google | Existing user | Google OAuth | Dashboard |
| Not logged into Google | New user | Google OAuth | Google login → Signup → Dashboard |
| Not logged into Google | Existing user | Google OAuth | Google login → Dashboard |
| Incognito | New user | Google OAuth | Google login → Signup → Dashboard |
| Incognito | Existing user | Google OAuth | Google login → Dashboard |

---

## Next Steps

1. **Fix Issue #1:** OAuth double redirect (implement Option A)
2. **Test all scenarios:** Complete testing matrix
3. **Add loading states:** Better UX during OAuth redirects
4. **Create journey docs:** Document complete user journeys (onboarding, daily workflow)
5. **Performance metrics:** Track time-to-dashboard for each flow

---

**Related Documentation:**
- [AUTHENTICATION_FLOW.md](AUTHENTICATION_FLOW.md) - High-level overview
- [OAUTH_IMPLEMENTATION.md](OAUTH_IMPLEMENTATION.md) - OAuth technical details
- [ONBOARDING_FLOW.md](ONBOARDING_FLOW.md) - Complete user onboarding journey
