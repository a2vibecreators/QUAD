# Multi-Tenant Domain & SSO Setup Guide

**Date:** December 31, 2025
**Purpose:** Enable clients to use their own domains with custom SSO for QUAD Platform

---

## Overview

QUAD Platform supports **three hosting models**:

| Model | Domain Pattern | SSO | Example |
|-------|----------------|-----|---------|
| **Startup (Free)** | QUAD subdomain | Google OAuth | `acme.quadframe.work` |
| **Small Business** | Custom domain | Client's SSO | `app.acmecorp.com` |
| **Enterprise** | Custom domain | Client's SSO | `quad.megacorp.com` |

**Key Benefits:**
- ✅ No VPN required - cloud-only authentication
- ✅ Client controls SSO on their side (Okta, Azure AD, etc.)
- ✅ We host and maintain the infrastructure
- ✅ Client's employees use company credentials
- ✅ Multi-tenant database with company isolation

---

## Architecture

### DEV/QA Environment (Mac Studio)

```
Client Domain: app.acmecorp.com
       ↓
   DNS CNAME → quadframe.work (96.240.97.243)
       ↓
   Caddy (Mac Studio) - SSL termination
       ↓
   Docker Container: quadframework-qa:80
       ↓
   Next.js App → PostgreSQL
```

**Infrastructure:**
- **Host:** Mac Studio M4 Max (192.168.1.X)
- **Reverse Proxy:** Caddy (automatic SSL via Let's Encrypt)
- **Database:** PostgreSQL (Docker container `postgres-dev` / `postgres-qa`)
- **DNS:** Cloudflare (Proxied for DDoS protection)

### PROD Environment (GCP Cloud Run)

```
Client Domain: app.acmecorp.com
       ↓
   DNS CNAME → ghs.googlehosted.com
       ↓
   GCP Load Balancer - SSL termination
       ↓
   Cloud Run Service: quadframework-prod
       ↓
   Next.js App → Cloud SQL PostgreSQL
```

**Infrastructure:**
- **Host:** GCP Cloud Run (us-east1)
- **Database:** Cloud SQL PostgreSQL (`nutrinine-db`)
- **Load Balancer:** GCP Application Load Balancer
- **DNS:** Cloudflare (DNS-only mode for GCP)
- **SSL:** GCP-managed certificates

---

## Setup Process

### Step 1: Client Side (DNS Configuration)

**Client Actions:**
1. Log into domain registrar (Namecheap, GoDaddy, etc.)
2. Add DNS record:

**For DEV/QA (Mac Studio):**
```
Type: CNAME
Name: app (or subdomain of choice)
Value: quadframe.work
TTL: 300 (5 minutes)
```

**For PROD (GCP Cloud Run):**
```
Type: CNAME
Name: app (or subdomain of choice)
Value: ghs.googlehosted.com
TTL: 300 (5 minutes)
```

3. Wait for DNS propagation (5-30 minutes)

**Verification:**
```bash
# Check DNS propagation
dig app.acmecorp.com

# Expected result (DEV/QA):
app.acmecorp.com. 300 IN CNAME quadframe.work.

# Expected result (PROD):
app.acmecorp.com. 300 IN CNAME ghs.googlehosted.com.
```

---

### Step 2: QUAD Admin Side - Database Configuration

**Add company and domain to database:**

```sql
-- 1. Add company
INSERT INTO QUAD_companies (id, name, admin_email, size)
VALUES (
  gen_random_uuid(),
  'Acme Corp',
  'admin@acmecorp.com',
  'medium'
);

-- 2. Add custom domain
INSERT INTO company_domains (company_id, domain, is_primary, verified, ssl_status)
SELECT
  id,
  'app.acmecorp.com',
  true,
  true,  -- Mark as verified after DNS confirmation
  'active'
FROM QUAD_companies
WHERE name = 'Acme Corp';

-- 3. Verify domain added
SELECT
  c.name AS company,
  cd.domain,
  cd.verified,
  cd.ssl_status
FROM company_domains cd
JOIN QUAD_companies c ON c.id = cd.company_id
WHERE cd.domain = 'app.acmecorp.com';
```

---

### Step 3: Client Side - SSO Configuration

**Client sets up SSO provider** (e.g., Okta):

1. **Create OAuth Application** in their Okta dashboard
2. **Set Redirect URI:**
   - DEV/QA: `https://app.acmecorp.com/api/auth/callback/okta`
   - PROD: `https://app.acmecorp.com/api/auth/callback/okta`
3. **Obtain credentials:**
   - Client ID: `0oa123abc456def`
   - Client Secret: `xyz789secretHere`
   - Issuer URL: `https://acmecorp.okta.com`
4. **Share credentials** with QUAD admin (via secure channel)

**Common SSO Providers:**
| Provider | Redirect URI Pattern | Additional Config |
|----------|---------------------|-------------------|
| Okta | `/api/auth/callback/okta` | Issuer URL |
| Azure AD | `/api/auth/callback/azure-ad` | Tenant ID |
| Google Workspace | `/api/auth/callback/google` | None |
| Auth0 | `/api/auth/callback/auth0` | Domain |

---

### Step 4: QUAD Admin Side - Store SSO Credentials

**Option A: Directly in Database (Not Recommended - Secrets Visible)**
```sql
INSERT INTO company_sso_configs (
  company_id,
  provider,
  provider_name,
  client_id,
  client_secret_vault_path,  -- Leave NULL if storing directly
  issuer_url,
  enabled
)
SELECT
  c.id,
  'okta',
  'Acme Corp SSO',
  '0oa123abc456def',
  NULL,
  'https://acmecorp.okta.com',
  true
FROM QUAD_companies c
WHERE c.name = 'Acme Corp';
```

**Option B: Store in Vaultwarden (Recommended - Secure)**
```bash
# 1. Store secret in Vaultwarden
# Path: company/{company_id}/sso/okta
# Secret value: xyz789secretHere

# 2. Store only path in database
INSERT INTO company_sso_configs (
  company_id,
  provider,
  provider_name,
  client_id,
  client_secret_vault_path,
  issuer_url,
  enabled
)
SELECT
  c.id,
  'okta',
  'Acme Corp SSO',
  '0oa123abc456def',
  'company/' || c.id || '/sso/okta',  -- Vault path
  'https://acmecorp.okta.com',
  true
FROM QUAD_companies c
WHERE c.name = 'Acme Corp';
```

---

### Step 5A: QUAD Admin Side - Infrastructure Setup (DEV/QA)

**Add domain to Caddyfile:**

```bash
# 1. Edit Caddyfile on Mac Studio
nano /Users/semostudio/docker/caddy/Caddyfile

# 2. Add new domain block (choose environment)
# For DEV:
app.acmecorp.com {
  reverse_proxy quadframework-dev:80
}

# For QA:
app.acmecorp.com {
  reverse_proxy quadframework-qa:80
}

# 3. Reload Caddy (no restart needed)
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# 4. Verify SSL certificate obtained
docker exec caddy caddy list-certificates
```

**Caddy automatically:**
- ✅ Obtains Let's Encrypt SSL certificate
- ✅ Handles HTTP → HTTPS redirect
- ✅ Renews certificates before expiry

---

### Step 5B: QUAD Admin Side - Infrastructure Setup (PROD - GCP)

**Add domain to GCP Load Balancer:**

```bash
# 1. Add domain mapping to Cloud Run service
gcloud run domain-mappings create \
  --service quadframework-prod \
  --domain app.acmecorp.com \
  --region us-east1 \
  --project nutrinine-project

# 2. GCP will show DNS records to add (usually already done in Step 1)
# Output:
# ✓ CNAME: app.acmecorp.com → ghs.googlehosted.com

# 3. Wait for SSL certificate provisioning (5-30 minutes)
gcloud run domain-mappings describe app.acmecorp.com \
  --region us-east1 \
  --project nutrinine-project

# 4. Verify certificate status
# Look for: certificateStatus: ACTIVE
```

**GCP automatically:**
- ✅ Provisions Google-managed SSL certificate
- ✅ Handles HTTP → HTTPS redirect
- ✅ Routes traffic to Cloud Run service
- ✅ Renews certificates before expiry

---

### Step 6: Verification & Testing

**1. Test DNS Resolution:**
```bash
# Should resolve to correct IP
dig app.acmecorp.com +short

# DEV/QA expected: 96.240.97.243 (Mac Studio)
# PROD expected: GCP load balancer IP
```

**2. Test SSL Certificate:**
```bash
# Check certificate validity
curl -vI https://app.acmecorp.com 2>&1 | grep -i "SSL\|TLS\|certificate"

# Expected: Valid certificate, no errors
```

**3. Test Login Page:**
```bash
# Open in browser
open https://app.acmecorp.com/login

# Expected:
# - Page loads successfully
# - Shows "Acme Corp" as company name (not "QUAD Platform")
# - Shows ONLY "Continue with Okta" button (not Google/GitHub)
```

**4. Test SSO Flow:**
1. Click "Continue with Okta"
2. Should redirect to: `https://acmecorp.okta.com/...`
3. Employee logs in with company credentials
4. Should redirect back to: `https://app.acmecorp.com/dashboard`
5. User should be authenticated

**5. Database Verification:**
```sql
-- Check user was created on first login
SELECT
  c.name AS company,
  u.email,
  u.oauth_provider,
  u.role,
  u.created_at
FROM QUAD_users u
JOIN QUAD_companies c ON c.id = u.company_id
WHERE c.name = 'Acme Corp'
ORDER BY u.created_at DESC;
```

---

## NextAuth Dynamic SSO Configuration

**How it works:**

1. **User visits:** `https://app.acmecorp.com/login`
2. **Frontend calls:** `GET /api/auth/sso-config?domain=app.acmecorp.com`
3. **API looks up:**
   - `company_domains` table → Find company by domain
   - `company_sso_configs` table → Get company's SSO providers
4. **API returns:**
   ```json
   {
     "isCustomDomain": true,
     "companyName": "Acme Corp",
     "providers": [
       {
         "id": "okta",
         "name": "Acme Corp SSO",
         "icon": "/icons/okta.svg",
         "bgColor": "bg-blue-600 hover:bg-blue-700 text-white",
         "enabled": true
       }
     ]
   }
   ```
5. **Login page shows ONLY Okta button**
6. **NextAuth uses dynamic credentials** from database

---

## Troubleshooting

### Issue: "Domain not loading"

**Check DNS:**
```bash
dig app.acmecorp.com
nslookup app.acmecorp.com
```

**Solutions:**
- Wait for DNS propagation (up to 48 hours, usually 5-30 min)
- Verify CNAME points to correct target
- Clear DNS cache: `sudo dscacheutil -flushcache` (macOS)

### Issue: "SSL certificate error"

**Check certificate status:**

**DEV/QA (Caddy):**
```bash
docker exec caddy caddy list-certificates
docker logs caddy --tail 50
```

**PROD (GCP):**
```bash
gcloud run domain-mappings describe app.acmecorp.com \
  --region us-east1 | grep certificateStatus
```

**Solutions:**
- DEV/QA: Check Caddy logs for Let's Encrypt errors
- PROD: Wait for GCP certificate provisioning (up to 30 min)
- Verify domain is in `company_domains` table with `verified=true`

### Issue: "Login page shows wrong company name"

**Check database:**
```sql
SELECT * FROM company_domains WHERE domain = 'app.acmecorp.com';
```

**Solutions:**
- Verify domain is registered in `company_domains`
- Check `verified` column is `true`
- Clear browser cache and reload

### Issue: "SSO login fails"

**Check SSO configuration:**
```sql
SELECT * FROM company_sso_configs WHERE company_id = (
  SELECT company_id FROM company_domains WHERE domain = 'app.acmecorp.com'
);
```

**Common mistakes:**
- Wrong `issuer_url` (must match client's Okta domain exactly)
- Wrong `client_id` or `client_secret`
- Redirect URI mismatch in client's SSO settings
- Client's SSO app not active/published

**Debug NextAuth:**
```bash
# Check Next.js logs
docker logs quadframework-qa --tail 100 | grep -i "auth\|sso"
```

---

## Summary: DEV/QA vs PROD

| Aspect | DEV/QA (Mac Studio) | PROD (GCP Cloud Run) |
|--------|---------------------|----------------------|
| **DNS Target** | `quadframe.work` | `ghs.googlehosted.com` |
| **Reverse Proxy** | Caddy (Docker) | GCP Load Balancer |
| **SSL** | Let's Encrypt (Caddy) | Google-managed |
| **Container** | quadframework-dev/qa:80 | Cloud Run service |
| **Database** | postgres-dev/qa (Docker) | Cloud SQL PostgreSQL |
| **Domain Setup** | Edit Caddyfile + reload | `gcloud run domain-mappings create` |
| **IP Address** | 96.240.97.243 (static) | GCP managed (dynamic) |
| **Cost** | $0 (self-hosted) | GCP charges apply |

---

## Next Steps

After completing client domain setup:

1. ✅ Test login flow with client's employees
2. ✅ Create first domain for client (e.g., NutriNine project)
3. ✅ Upload first blueprint and test Blueprint Agent
4. ✅ Monitor logs for errors
5. ✅ Schedule regular SSL certificate checks

---

**Questions?** Contact QUAD Platform team.
