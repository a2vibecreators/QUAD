# QUAD Framework Authentication Flow

## Overview

QUAD Framework supports multiple authentication methods:
1. **OAuth (Google/GitHub)** - SSO authentication
2. **Email/OTP (Passwordless)** - 6-digit verification code
3. **Password (Legacy)** - Traditional email/password

All methods lead to either:
- **Existing user** → Dashboard
- **New user** → Signup flow (org type selection → form → setup)

---

## Authentication Flow Diagrams

### Flow 1: OAuth Authentication (Google/GitHub)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        OAUTH AUTHENTICATION FLOW                            │
└─────────────────────────────────────────────────────────────────────────────┘

User clicks "Continue with Google/GitHub"
          │
          ▼
┌─────────────────────────┐
│   OAuth Provider        │
│   (Google/GitHub)       │
│   Authenticates User    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    authOptions.ts signIn callback                           │
└─────────────────────────────────────────────────────────────────────────────┘
            │
            ├─────────────────────────────────────────────┐
            │                                             │
            ▼                                             ▼
┌───────────────────────┐                     ┌───────────────────────────────┐
│   User EXISTS         │                     │   User NOT EXISTS             │
│   in QUAD_users       │                     │   New OAuth user              │
└───────────┬───────────┘                     └───────────────┬───────────────┘
            │                                                 │
            ▼                                                 ▼
┌───────────────────────┐                     ┌───────────────────────────────┐
│   return true         │                     │   Redirect to:                │
│   → /dashboard        │                     │   /auth/signup?               │
│                       │                     │     oauth=true&               │
│                       │                     │     provider=google&          │
│                       │                     │     email=xxx&                │
│                       │                     │     name=xxx                  │
└───────────────────────┘                     └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Signup Page detects:        │
                                              │   - oauth=true                │
                                              │   - Pre-fills email/name      │
                                              │   - Shows "Verified" badge    │
                                              │   - Email field read-only     │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Step 1: Select Org Type    │
                                              │   [Startup] [Business] [Ent] │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Step 2: Complete Form      │
                                              │   - Email: [pre-filled, RO]  │
                                              │   - Name: [pre-filled, RO]   │
                                              │   - Company: [user enters]   │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   POST /api/auth/signup       │
                                              │   { isOAuth: true, ... }      │
                                              │                               │
                                              │   Creates:                    │
                                              │   - QUAD_organizations        │
                                              │   - QUAD_users (verified)     │
                                              │   - QUAD_org_setup_status     │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Frontend calls:             │
                                              │   signIn(provider)            │
                                              │   → Creates NextAuth session  │
                                              │   → Redirect to /setup        │
                                              └───────────────────────────────┘
```

### Flow 2: Email/OTP Authentication (Passwordless)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      EMAIL/OTP AUTHENTICATION FLOW                          │
└─────────────────────────────────────────────────────────────────────────────┘

User clicks "Email / Code" on login page
          │
          ▼
┌─────────────────────────┐
│   Enter Email           │
│   [john@acmecorp.com]   │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│   POST /api/auth/send-code                                                  │
│   Sends 6-digit OTP to email                                                │
│   Returns: { isExistingUser: true/false }                                   │
└─────────────────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│   Enter 6-digit code    │
│   [_ _ _ _ _ _]         │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│   POST /api/auth/verify-code                                                │
│   Validates OTP code                                                        │
└─────────────────────────────────────────────────────────────────────────────┘
            │
            ├─────────────────────────────────────────────┐
            │                                             │
            ▼                                             ▼
┌───────────────────────┐                     ┌───────────────────────────────┐
│   User EXISTS         │                     │   User NOT EXISTS             │
│   in QUAD_users       │                     │   New email user              │
└───────────┬───────────┘                     └───────────────┬───────────────┘
            │                                                 │
            ▼                                                 ▼
┌───────────────────────┐                     ┌───────────────────────────────┐
│   Returns:            │                     │   Returns:                    │
│   { isNewUser: false, │                     │   { isNewUser: true,          │
│     token: "xxx",     │                     │     redirectTo: /auth/signup? │
│     redirectTo:       │                     │       email=xxx&              │
│       /dashboard }    │                     │       verified=true }         │
└───────────┬───────────┘                     └───────────────┬───────────────┘
            │                                                 │
            ▼                                                 ▼
┌───────────────────────┐                     ┌───────────────────────────────┐
│   Store token         │                     │   Signup Page detects:        │
│   → /dashboard        │                     │   - verified=true             │
│                       │                     │   - Pre-fills email           │
│                       │                     │   - Shows "Email Verified"    │
│                       │                     │   - Email field read-only     │
│                       │                     │   - Name field editable       │
└───────────────────────┘                     └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Step 1: Select Org Type    │
                                              │   [Startup] [Business] [Ent] │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Step 2: Complete Form      │
                                              │   - Email: [pre-filled, RO]  │
                                              │   - Name: [user enters]      │
                                              │   - Company: [user enters]   │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   POST /api/auth/signup       │
                                              │   { isEmailVerified: true }   │
                                              │                               │
                                              │   Creates:                    │
                                              │   - QUAD_organizations        │
                                              │   - QUAD_users (verified)     │
                                              │   - QUAD_org_setup_status     │
                                              │                               │
                                              │   Returns:                    │
                                              │   - token (auto-login)        │
                                              └───────────────┬───────────────┘
                                                              │
                                                              ▼
                                              ┌───────────────────────────────┐
                                              │   Store token                 │
                                              │   → /setup                    │
                                              └───────────────────────────────┘
```

---

## API Endpoints

### Authentication APIs

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth/send-code` | POST | Send 6-digit OTP to email |
| `/api/auth/verify-code` | POST | Verify OTP and return token or redirect |
| `/api/auth/signup` | POST | Create organization and user |
| `/api/auth/[...nextauth]` | * | NextAuth.js OAuth handlers |

### Request/Response Examples

#### POST /api/auth/send-code
```json
// Request
{ "email": "john@acmecorp.com" }

// Response (existing user)
{
  "success": true,
  "isExistingUser": true,
  "message": "Verification code sent"
}

// Response (new user)
{
  "success": true,
  "isExistingUser": false,
  "message": "Verification code sent"
}
```

#### POST /api/auth/verify-code
```json
// Request
{ "email": "john@acmecorp.com", "code": "123456" }

// Response (existing user)
{
  "success": true,
  "isNewUser": false,
  "token": "eyJhbGc...",
  "redirectTo": "/dashboard"
}

// Response (new user)
{
  "success": true,
  "isNewUser": true,
  "email": "john@acmecorp.com",
  "redirectTo": "/auth/signup?email=john%40acmecorp.com&verified=true"
}
```

#### POST /api/auth/signup
```json
// Request (OAuth)
{
  "email": "john@gmail.com",
  "fullName": "John Smith",
  "companyName": "Acme Corp",
  "orgType": "startup",
  "isOAuth": true,
  "oauthProvider": "google"
}

// Request (Email Verified)
{
  "email": "john@acmecorp.com",
  "fullName": "John Smith",
  "companyName": "Acme Corp",
  "orgType": "business",
  "isEmailVerified": true
}

// Response (OAuth)
{
  "success": true,
  "message": "Account created successfully via OAuth.",
  "isOAuth": true,
  "data": {
    "organization": { "id": "uuid", "name": "Acme Corp" },
    "user": { "id": "uuid", "email": "john@gmail.com" }
  }
}

// Response (Email Verified)
{
  "success": true,
  "message": "Account created successfully.",
  "autoLogin": true,
  "data": {
    "organization": { "id": "uuid", "name": "Acme Corp" },
    "user": { "id": "uuid", "email": "john@acmecorp.com" },
    "token": "eyJhbGc..."
  }
}
```

---

## URL Parameters

### Signup Page Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `oauth` | `true` | Indicates OAuth verified user |
| `provider` | `google`/`github` | OAuth provider name |
| `email` | email address | Pre-filled email (read-only) |
| `name` | full name | Pre-filled name (OAuth only) |
| `verified` | `true` | Indicates email/OTP verified user |

### Examples
```
# OAuth user (Google)
/auth/signup?oauth=true&provider=google&email=john@gmail.com&name=John%20Smith

# Email verified user
/auth/signup?email=john@acmecorp.com&verified=true
```

---

## Database Tables

### QUAD_users
```sql
CREATE TABLE "QUAD_users" (
  id UUID PRIMARY KEY,
  company_id UUID REFERENCES "QUAD_organizations"(id),
  email VARCHAR UNIQUE NOT NULL,
  password_hash VARCHAR NOT NULL,
  role VARCHAR NOT NULL,  -- OWNER, ADMIN, MEMBER, etc.
  full_name VARCHAR,
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,  -- Set to true for OAuth/email-verified users
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### QUAD_email_verification_codes
```sql
CREATE TABLE "QUAD_email_verification_codes" (
  id UUID PRIMARY KEY,
  email VARCHAR NOT NULL,
  code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  attempts INTEGER DEFAULT 0,
  used BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## Key Files

| File | Purpose |
|------|---------|
| `/src/lib/authOptions.ts` | NextAuth.js OAuth configuration |
| `/src/app/auth/login/page.tsx` | Login page with email/OTP UI |
| `/src/app/auth/signup/page.tsx` | Multi-step signup wizard |
| `/src/app/api/auth/signup/route.ts` | Signup API endpoint |
| `/src/app/api/auth/send-code/route.ts` | Send OTP API |
| `/src/app/api/auth/verify-code/route.ts` | Verify OTP API |
| `/src/lib/auth.ts` | JWT token generation and session management |

---

## Verification States

The signup page tracks user verification status:

```typescript
interface VerifiedUserData {
  isVerified: boolean;      // User is pre-verified (OAuth or email)
  isOAuth: boolean;         // Verified via OAuth (Google/GitHub)
  provider: string;         // 'google', 'github', or 'email'
  email: string;            // Pre-filled email
  name: string;             // Pre-filled name (OAuth only)
}
```

### UI Behavior by State

| State | Email Field | Name Field | Badge |
|-------|-------------|------------|-------|
| No verification | Editable | Editable | None |
| OAuth verified | Read-only | Read-only | "Signed in with Google/GitHub" |
| Email verified | Read-only | Editable | "Email verified via code" |

---

## Security Considerations

1. **OTP Expiration**: Codes expire after 10 minutes
2. **Rate Limiting**: Max 5 OTP attempts before lockout
3. **Password Hashing**: BCrypt with salt rounds = 10
4. **JWT Tokens**: 24-hour expiration, signed with JWT_SECRET
5. **Session Tracking**: All sessions logged with IP and user agent
6. **Email Normalization**: All emails lowercased and trimmed

---

## Last Updated
- **Date**: January 2, 2026
- **Author**: Claude Code
- **Changes**: Added email/OTP verification flow support
