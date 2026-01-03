# Google Cloud Account Migration Guide

## Overview

This document describes how to migrate QUAD Framework from the current personal Google account to a company Google Workspace account.

## Current State

| Service | Account | Project |
|---------|---------|---------|
| Google OAuth (SSO) | madhuri.recherla@gmail.com | nutrinine-prod |
| Gemini API | madhuri.recherla@gmail.com | nutrinine-prod |
| GCP Cloud Run | madhuri.recherla@gmail.com | nutrinine-prod |
| GCP Cloud SQL | madhuri.recherla@gmail.com | nutrinine-prod |

**Current Credits:** $300 free tier (expires when depleted or after 90 days)

## What's Tied to Google Account

### 1. Google OAuth (User Login)
- **Client ID:** `805817782076-b6975p184nj0kqcs9l0hurjj2bv6gkev.apps.googleusercontent.com`
- **Purpose:** "Sign in with Google" on QUAD Framework
- **Authorized Domains:** dev.quadframe.work, qa.quadframe.work, quadframe.work

### 2. Gemini API (Future AI Features)
- **Purpose:** AI-powered features (not yet implemented in QUAD)
- **Key Location:** Google Cloud Console → APIs & Services → Credentials

### 3. GCP Infrastructure
- **Cloud Run:** quadframework-prod service
- **Cloud SQL:** quad-prod-db instance (PostgreSQL 15)
- **Container Registry:** gcr.io/nutrinine-prod/quadframework-prod

## When to Migrate

Migrate when ANY of these occur:
- $300 credits are depleted
- You're ready to set up company billing
- You want cleaner separation between personal and business
- Compliance/audit requirements

## Pre-Migration Checklist

- [ ] Create company Google Workspace account (e.g., admin@quadframe.work)
- [ ] Verify company domain ownership in Google Workspace
- [ ] Set up billing on new account
- [ ] Have access to current .env.deploy credentials

## Migration Steps

### Step 1: Create Company Google Account

**Option A: Google Workspace (Recommended for Business)**
- Go to workspace.google.com
- Set up with quadframe.work domain
- Create admin account (e.g., admin@quadframe.work)
- Cost: $6-18/user/month

**Option B: Free Gmail (Simpler)**
- Create gmail account (e.g., quadframework.app@gmail.com)
- Good for small projects
- Cost: Free

### Step 2: Create New Google Cloud Project

```bash
# Login with new account
gcloud auth login

# Create new project
gcloud projects create quadframework-prod --name="QUAD Framework Production"

# Set as default
gcloud config set project quadframework-prod

# Enable billing (required for Cloud Run/SQL)
# Do this in console: console.cloud.google.com/billing
```

### Step 3: Enable Required APIs

```bash
gcloud services enable \
  run.googleapis.com \
  sqladmin.googleapis.com \
  containerregistry.googleapis.com \
  iamcredentials.googleapis.com
```

### Step 4: Create New OAuth Credentials

1. Go to: console.cloud.google.com → APIs & Services → Credentials
2. Click "Create Credentials" → "OAuth 2.0 Client ID"
3. Application type: Web application
4. Name: "QUAD Platform"
5. Add Authorized JavaScript origins:
   - `https://dev.quadframe.work`
   - `https://qa.quadframe.work`
   - `https://quadframe.work`
6. Add Authorized redirect URIs:
   - `https://dev.quadframe.work/api/auth/callback/google`
   - `https://qa.quadframe.work/api/auth/callback/google`
   - `https://quadframe.work/api/auth/callback/google`
7. Click Create
8. Save the new Client ID and Client Secret

### Step 5: Create New Gemini API Key (If Using AI Features)

1. Go to: console.cloud.google.com → APIs & Services → Credentials
2. Click "Create Credentials" → "API Key"
3. Restrict key to Gemini API only
4. Save the new API key

### Step 6: Update Credentials

**Update .env.deploy:**
```bash
# PROD Environment - NEW CREDENTIALS
PROD_GOOGLE_CLIENT_ID=<new-client-id>
PROD_GOOGLE_CLIENT_SECRET=<new-secret>

# Also update DEV/QA if using same OAuth client
DEV_GOOGLE_CLIENT_ID=<new-client-id>
DEV_GOOGLE_CLIENT_SECRET=<new-secret>
```

**Update Vaultwarden:**
1. Open vault.nutrinine.app
2. Update "QUAD Google OAuth" entry with new credentials
3. Update "QUAD Gemini API" entry if applicable

### Step 7: Recreate Cloud SQL (If Migrating Database)

**Option A: Keep Existing Database (Recommended)**
- Database IP (34.148.105.158) remains accessible
- Just update Cloud Run to connect to it
- No data migration needed

**Option B: Create New Database (Clean Start)**
```bash
# Create new Cloud SQL instance
gcloud sql instances create quad-prod-db-new \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-east1

# Create database
gcloud sql databases create quad_prod_db --instance=quad-prod-db-new

# Create user
gcloud sql users create quad_user \
  --instance=quad-prod-db-new \
  --password=<new-password>

# Migrate data if needed
pg_dump -h <old-ip> -U quad_user quad_prod_db | \
  psql -h <new-ip> -U quad_user quad_prod_db
```

### Step 8: Redeploy All Environments

```bash
# Update GCP project in deploy script
cd /Users/semostudio/git/a2vibecreators/quadframework

# Edit deployment/cloud/gcp/deploy.sh
# Change: PROJECT_ID="nutrinine-prod"
# To:     PROJECT_ID="quadframework-prod"

# Deploy to PROD
./deployment/cloud/gcp/deploy.sh

# Deploy to DEV/QA (Mac Studio)
./deploy-studio.sh all
```

### Step 9: Verify Everything Works

```bash
# Test OAuth login on each environment
curl -I https://dev.quadframe.work
curl -I https://qa.quadframe.work
curl -I https://quadframe.work

# Test login flow manually in browser
# Verify "Sign in with Google" works
```

## Rollback Plan

If migration fails, revert to old credentials:

1. Restore old .env.deploy from backup
2. Restore Vaultwarden entries
3. Redeploy all environments
4. Old OAuth still works (credentials don't expire)

## Post-Migration Cleanup

After successful migration:
- [ ] Update documentation with new project ID
- [ ] Revoke old OAuth credentials (optional - keeps as backup)
- [ ] Close old GCP project (only after 30 days of stable operation)
- [ ] Update any CI/CD pipelines with new credentials

## Cost Comparison

| Resource | Free Tier | After Free Tier |
|----------|-----------|-----------------|
| Cloud Run | 2M requests/month | ~$0.40/million requests |
| Cloud SQL (f1-micro) | None | ~$10/month |
| Container Registry | 0.5GB free | ~$0.026/GB |
| OAuth | Free | Free |
| Gemini API | Varies | Pay per use |

**Estimated Monthly Cost After Migration:** $15-30/month (low traffic)

## Related Documentation

- [Deploy Script](../deployment/cloud/gcp/deploy.sh) - GCP deployment automation
- [.env.deploy](../.env.deploy) - Environment credentials (gitignored)
- [Vaultwarden](https://vault.nutrinine.app) - Secrets management

---

**Last Updated:** January 2, 2026
**Author:** Claude Code
