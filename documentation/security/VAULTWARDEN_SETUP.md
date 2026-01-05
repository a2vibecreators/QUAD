# Vaultwarden Setup - A2Vibe Creators

**Purpose:** Centralized secrets management for all A2Vibe Creators projects

**Date:** January 5, 2026

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     VAULTWARDEN ARCHITECTURE                     │
└─────────────────────────────────────────────────────────────────┘

                    ┌────────────────────┐
                    │  vault.a2vibes.tech│
                    │   (GCP Cloud Run)  │
                    └─────────┬──────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
         ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
         │  QUAD   │    │NutriNine│    │A2Vibe   │
         │ Secrets │    │ Secrets │    │ Secrets │
         └─────────┘    └─────────┘    └─────────┘

                    ┌────────────────────┐
                    │   Mac Studio       │
                    │  (DEV/QA ONLY)     │
                    │  NO VAULT HERE     │
                    └────────────────────┘
```

## Key Principles

1. **One Vault for All Projects** - vault.a2vibes.tech serves QUAD, NutriNine, A2Vibe Creators
2. **GCP Hosted ONLY** - Vault runs in Google Cloud Platform, NOT on Mac Studio
3. **Mac Studio = DEV/QA** - Mac Studio only runs development and QA environments
4. **Company-Wide Resource** - Shared by all A2Vibe Creators projects

---

## Vault Details

| Property | Value |
|----------|-------|
| **URL** | https://vault.a2vibes.tech |
| **Hosting** | Google Cloud Platform (GCP) |
| **Service** | Cloud Run |
| **Region** | us-east1 |
| **Database** | Cloud SQL PostgreSQL 15 |
| **Admin** | sumanaddanki |

---

## GCP Configuration

### Cloud Run Service

**Service Name:** `vaultwarden-prod`

**Container Image:** `vaultwarden/server:latest`

**Environment Variables:**
```bash
DOMAIN=https://vault.a2vibes.tech
SIGNUPS_ALLOWED=false  # Invite only
ADMIN_TOKEN=<from-secrets>
WEBSOCKET_ENABLED=true
LOG_LEVEL=info
```

**Resources:**
- CPU: 1 vCPU
- Memory: 512 MB
- Min Instances: 1 (always running)
- Max Instances: 10

**Cloud SQL Connection:**
- Instance: `vaultwarden-db`
- Database: `vaultwarden_prod`
- User: `vaultwarden`
- Connection: Via Cloud SQL Proxy

### Cloud SQL Database

**Instance Name:** `vaultwarden-db`

**Configuration:**
- Database Version: PostgreSQL 15
- Tier: db-f1-micro
- Storage: 10 GB SSD
- Region: us-east1
- Backups: Daily at 3 AM UTC

**Databases:**
```sql
vaultwarden_prod  -- Production vault data
```

---

## DNS Configuration

**Domain:** vault.a2vibes.tech

**DNS Provider:** Cloudflare

**Record Type:** CNAME

**Target:** GCP Cloud Run service URL

**Cloudflare Settings:**
- Proxy Status: ✅ Proxied (Orange cloud)
- SSL/TLS: Full (strict)
- Auto HTTPS Rewrites: Enabled

---

## Organization Structure

### QUAD Organization
**Organization ID:** `579c22f3-4f13-447c-a861-9a4aa0ab7fbc`

**Collections:**
- `dev` (e4f03d1a-b8ac-4186-a384-0fb62d431ddd)
- `qa` (75fb3b57-9e84-4e2d-8b4f-447518e0a315)
- `prod` (cc4a16a2-9acc-459a-ad37-a8ef99592366)

**Secrets:**
- Anthropic API Key
- Cloudflare API Token
- Database Credentials
- GitHub OAuth
- Google OAuth
- NextAuth Secret
- JWT Secret

### NutriNine Organization
**Organization ID:** `a2608572-3e25-4b3a-996b-cd5be95b12c0`

**Collections:**
- `dev` (c792c297-8ccd-46a1-b691-7955ede25eb5)
- `qa` (532a3e70-d93b-42d8-8ebb-87ab0706786c)
- `prod` (97a77f38-24f3-4782-90c7-bc37e078e029)

**Secrets:**
- AWS Credentials
- Database Credentials
- Email HMAC Secret
- GitHub Backup Sync
- Gmail SMTP
- Google Gemini API Key
- JWT Secret
- MSG91 (India OTP)
- Sarvam AI
- Twilio
- Zoho SMTP

---

## Team Access

| Member | Email | Role | Access |
|--------|-------|------|--------|
| Suman Addanki | madhuri.recherla@gmail.com | Owner | All collections (dev/qa/prod) |
| Sharath | sharath.email@example.com | Member | dev/qa only (no prod) |

---

## Using the Vault

### Web UI Access

1. Go to https://vault.a2vibes.tech
2. Login with your Vaultwarden account
3. Navigate to organization → collection
4. View/copy secrets

### CLI Access (bw)

**Installation:**
```bash
brew install bitwarden-cli
# or
npm install -g @bitwarden/cli
```

**Login:**
```bash
# Set server URL
export BW_CLIENTID="user.your-client-id"
export BW_CLIENTSECRET="your-client-secret"

# Login
bw config server https://vault.a2vibes.tech
bw login

# Unlock (get session token)
export BW_SESSION=$(bw unlock --raw)
```

**List Secrets:**
```bash
# List all organizations
bw list organizations

# List QUAD secrets (dev collection)
bw list items --organizationid 579c22f3-4f13-447c-a861-9a4aa0ab7fbc --collectionid e4f03d1a-b8ac-4186-a384-0fb62d431ddd

# Get specific secret
bw get item "NextAuth Secret" --organizationid 579c22f3-4f13-447c-a861-9a4aa0ab7fbc
```

---

## Adding New Projects

When adding a new A2Vibe Creators project:

1. **Create Organization** in Vaultwarden
2. **Create Collections** (dev/qa/prod)
3. **Add Team Members** with appropriate access levels
4. **Store Secrets** in respective collections
5. **Document** organization ID and collection IDs

**Example for new project "ProjectX":**
```bash
# Organization: ProjectX
# ID: <generated-by-vaultwarden>

# Collections:
# - dev: <generated-id>
# - qa: <generated-id>
# - prod: <generated-id>

# Update this file with new IDs
```

---

## Security Best Practices

1. **Never Commit Secrets** - Always use vault, never hardcode
2. **Use Environment-Specific Collections** - dev/qa/prod separation
3. **Rotate Regularly** - Change passwords/tokens every 90 days
4. **Limit Production Access** - Only admins can access prod collection
5. **Use Strong Passwords** - 20+ characters, random generated
6. **Enable 2FA** - All team members must enable two-factor authentication

---

## Backup and Recovery

**Automated Backups:**
- Cloud SQL automated backups: Daily at 3 AM UTC
- Retention: 7 days
- Location: us-east1

**Manual Backup:**
```bash
# Export all vault data
bw export --format json --output vault-backup.json

# Store in secure location (encrypted)
gpg -c vault-backup.json
```

**Recovery:**
1. Restore Cloud SQL database from backup
2. Redeploy Cloud Run service
3. Update DNS if needed
4. Test access from all projects

---

## Troubleshooting

### Cannot Access Vault

**Symptom:** https://vault.a2vibes.tech returns 502 or timeout

**Causes:**
1. Cloud Run service stopped
2. Cloud SQL database offline
3. DNS misconfiguration

**Fix:**
```bash
# Check Cloud Run service
gcloud run services describe vaultwarden-prod --region=us-east1

# Check Cloud SQL instance
gcloud sql instances describe vaultwarden-db

# Check DNS
dig vault.a2vibes.tech
```

### Forgot Master Password

**Recovery:** No recovery possible - this is Vaultwarden security by design

**Prevention:**
1. Store master password in secure offline location
2. Use password manager (not Vaultwarden itself)
3. Share recovery key with trusted team member

### Cannot Access Organization

**Symptom:** "You don't have access to this organization"

**Fix:**
1. Contact admin (sumanaddanki)
2. Admin invites you to organization
3. Accept invitation via email
4. Refresh vault

---

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - Secrets Management section
- [GCP Infrastructure](GCP_INFRASTRUCTURE.md) - Cloud Run setup
- [Team Onboarding](TEAM_ONBOARDING.md) - New developer setup

---

**Maintained By:** Suman Addanki
**Last Updated:** January 5, 2026
