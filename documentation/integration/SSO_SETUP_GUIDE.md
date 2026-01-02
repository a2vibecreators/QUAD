# QUAD Platform - Enterprise SSO Setup Guide

**Version:** 1.0.0
**Last Updated:** December 31, 2025

## Supported SSO Providers (Out of the Box)

QUAD Platform supports **6 major SSO providers** used by Fortune 500 companies:

| Provider | Use Case | Example Companies | Setup Time |
|----------|----------|-------------------|------------|
| **Okta** | Enterprise SSO | Mass Mutual, FedEx, T-Mobile | 15 min |
| **Azure AD / Entra ID** | Microsoft 365 companies | Most enterprises | 10 min |
| **Auth0** | Modern SSO | Atlassian, Mozilla | 10 min |
| **Google Workspace** | Startups, SMBs | Startups, tech companies | 5 min |
| **GitHub** | Developer teams | Open source teams | 5 min |
| **Generic OIDC** | OneLogin, Ping, Keycloak | Custom setups | 20 min |

---

## Quick Start (Choose One)

You only need to configure **ONE SSO provider** - the one your company uses.

### Option 1: Okta Setup (Most Enterprise Companies)

**Prerequisites:**
- Okta Admin access
- Okta domain (e.g., `https://dev-12345.okta.com`)

**Steps:**

1. **Create App Integration**
   ```
   Okta Admin Console → Applications → Create App Integration
   - Sign-in method: OIDC - OpenID Connect
   - Application type: Web Application
   - Click Next
   ```

2. **Configure App Settings**
   ```
   App integration name: QUAD Platform

   Sign-in redirect URIs:
   - http://localhost:3003/api/auth/callback/okta (dev)
   - https://quad.yourcompany.com/api/auth/callback/okta (prod)

   Sign-out redirect URIs:
   - http://localhost:3003 (dev)
   - https://quad.yourcompany.com (prod)

   Assignments → Allow everyone in your organization
   ```

3. **Get Credentials**
   ```
   Client ID: Copy this (looks like: 0oa2x3y4z5...)
   Client secret: Copy this (looks like: abc123def456...)
   Okta domain: https://dev-12345.okta.com
   ```

4. **Update .env File**
   ```bash
   OKTA_CLIENT_ID=0oa2x3y4z5...
   OKTA_CLIENT_SECRET=abc123def456...
   OKTA_ISSUER=https://dev-12345.okta.com
   ```

5. **Test**
   ```
   Go to: http://localhost:3003/login
   Click: "Sign in with Okta"
   → Redirects to Okta login → Success!
   ```

---

### Option 2: Azure AD / Microsoft Entra ID Setup

**Prerequisites:**
- Azure Admin access
- Microsoft 365 tenant

**Steps:**

1. **Register App**
   ```
   Azure Portal → Azure Active Directory → App registrations → New registration

   Name: QUAD Platform
   Supported account types: Accounts in this organizational directory only

   Redirect URI:
   - Platform: Web
   - URI: http://localhost:3003/api/auth/callback/azure-ad
   ```

2. **Create Client Secret**
   ```
   Certificates & secrets → New client secret
   Description: QUAD Platform Secret
   Expires: 24 months
   → Copy the secret value (shows once!)
   ```

3. **API Permissions**
   ```
   API permissions → Add permission → Microsoft Graph → Delegated
   Add these permissions:
   - openid
   - email
   - profile

   → Grant admin consent
   ```

4. **Get Credentials**
   ```
   Application (client) ID: Copy this
   Client secret: Copy this (from step 2)
   Directory (tenant) ID: Copy this
   ```

5. **Update .env File**
   ```bash
   AZURE_AD_CLIENT_ID=12345678-1234-1234-1234-123456789abc
   AZURE_AD_CLIENT_SECRET=abc~123...
   AZURE_AD_TENANT_ID=87654321-4321-4321-4321-210987654321
   ```

---

### Option 3: Google Workspace Setup

**Prerequisites:**
- Google Workspace admin access
- Google Cloud Project

**Steps:**

1. **Create OAuth App**
   ```
   Google Cloud Console → APIs & Services → Credentials
   → Create Credentials → OAuth client ID

   Application type: Web application
   Name: QUAD Platform

   Authorized redirect URIs:
   - http://localhost:3003/api/auth/callback/google
   - https://quad.yourcompany.com/api/auth/callback/google
   ```

2. **Get Credentials**
   ```
   Client ID: Copy this
   Client secret: Copy this
   ```

3. **Update .env File**
   ```bash
   GOOGLE_CLIENT_ID=123456789-abc123.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=GOCSPX-abc123...
   ```

---

### Option 4: Generic OIDC (OneLogin, Ping Identity, Keycloak)

**Use this for any OpenID Connect compatible provider.**

**Steps:**

1. **Get OIDC Discovery URL**
   ```
   Most OIDC providers have a discovery endpoint:
   https://your-sso-provider.com/.well-known/openid-configuration
   ```

2. **Register App in Your SSO Provider**
   ```
   Redirect URI: http://localhost:3003/api/auth/callback/oidc
   Scopes: openid, email, profile
   ```

3. **Update .env File**
   ```bash
   OIDC_CLIENT_ID=your-client-id
   OIDC_CLIENT_SECRET=your-client-secret
   OIDC_ISSUER=https://your-sso-provider.com
   OIDC_PROVIDER_NAME=Your Company SSO
   ```

---

## User Experience

### First-Time Company Setup

**QUAD Admin (First User):**

1. Visit `http://localhost:3003/signup`
2. Fill in:
   - Company name: Mass Mutual
   - Admin email: admin@massmutual.com
   - Choose plan: Free (5 users), Pro, Enterprise
3. Configure SSO provider (Okta)
4. Save

**Result:** Company created, Okta enabled

### Team Member Login

**Developer (2nd-5th User):**

1. Visit `http://localhost:3003/login`
2. See: "Sign in with Okta" button
3. Click → Redirected to Okta
4. Login with Mass Mutual Okta credentials
5. Automatically added to company (same email domain: @massmutual.com)
6. Dashboard access granted

**No signup needed** - SSO handles everything!

---

## Free Tier Enforcement (5 Users)

**What happens when 6th user tries to login?**

```
User: john@massmutual.com (6th user)
  ↓
Clicks "Sign in with Okta"
  ↓
Okta authentication succeeds
  ↓
QUAD Platform checks: SELECT COUNT(*) WHERE company_id = ...
  ↓
Count = 5 (limit reached!)
  ↓
Redirect to: /upgrade?reason=user-limit
  ↓
Message: "Your team has reached the free tier limit (5 users).
         Upgrade to Pro ($99/month) for unlimited users."
```

---

## Security Best Practices

### 1. Use Environment Variables (Never Hardcode)
```bash
✅ OKTA_CLIENT_SECRET=${OKTA_CLIENT_SECRET}  # From env
❌ OKTA_CLIENT_SECRET="abc123..."            # Hardcoded (BAD!)
```

### 2. Rotate Secrets Regularly
- Rotate OAuth secrets every 90 days
- Use secret management tools (AWS Secrets Manager, HashiCorp Vault)

### 3. Restrict Redirect URIs
```bash
✅ http://localhost:3003/api/auth/callback/okta  # Exact match
❌ http://localhost:*/api/auth/callback/*       # Wildcard (UNSAFE!)
```

### 4. Enable MFA on SSO Provider
- Require multi-factor authentication in Okta/Azure AD
- QUAD Platform inherits MFA from your SSO

---

## Troubleshooting

### Error: "Redirect URI Mismatch"

**Problem:** OAuth provider rejects callback

**Solution:**
```bash
Check .env:
NEXTAUTH_URL=http://localhost:3003  # Must match exactly

Check SSO provider:
Redirect URI: http://localhost:3003/api/auth/callback/{provider}
                                      ↑ Must match NEXTAUTH_URL
```

### Error: "User Not Found"

**Problem:** User's email domain doesn't match any company

**Solution:**
```sql
-- QUAD_ADMIN must create organization first:
INSERT INTO QUAD_organizations (name, admin_email)
VALUES ('Mass Mutual', 'admin@massmutual.com');

-- Then users with @massmutual.com can login via SSO
-- Note: company_id column in QUAD_users maps to org_id in Prisma
```

### Error: "Invalid Client Secret"

**Problem:** Secret expired or wrong

**Solution:**
1. Go to SSO provider → Regenerate client secret
2. Update .env file
3. Restart app: `docker-compose restart`

---

## Production Deployment

**Docker Compose Setup:**

```yaml
# docker-compose.yml
version: '3.8'
services:
  quad-platform:
    image: quadframework/platform:latest
    environment:
      - NEXTAUTH_URL=https://quad.yourcompany.com
      - OKTA_CLIENT_ID=${OKTA_CLIENT_ID}
      - OKTA_CLIENT_SECRET=${OKTA_CLIENT_SECRET}
      - OKTA_ISSUER=https://yourcompany.okta.com
    ports:
      - "3003:3003"
```

**Update SSO Redirect URI for Production:**
```
Okta/Azure/Google:
Redirect URI: https://quad.yourcompany.com/api/auth/callback/{provider}
```

---

## Support

**Questions?**
- Documentation: https://quadframe.work/docs/sso
- GitHub Issues: https://github.com/a2vibecreators/quadframework/issues
- Email: support@quadframe.work

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
