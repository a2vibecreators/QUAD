# QUAD Platform - Technical Documentation

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Status:** Active Development

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Two-Tier Offering](#two-tier-offering)
4. [Database Schema](#database-schema)
5. [Authentication](#authentication)
6. [Deployment Models](#deployment-models)
7. [Real-Time Agents](#real-time-agents)
8. [Pricing & Free Tier](#pricing--free-tier)

---

## Overview

**QUAD Platform** is a self-hosted enterprise SaaS for AI-powered software development workflow automation.

**Target Market:**
- Mid-size companies (50-200 developers)
- Enterprise companies (200+ developers)
- Teams using Jira, GitHub, Slack

**Key Features:**
- Self-hosted (runs in customer's cloud)
- Real-time polling agents (Jira, GitHub, Slack sync)
- Role-based agent configuration (QUAD_ADMIN, DEVELOPER, QA, etc.)
- Enterprise SSO (Okta, Azure AD, Google, GitHub, Auth0, OIDC)
- Live dashboards with project metrics
- Free tier (5 users), Pro tier (unlimited users)

---

## Architecture

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|----------|
| **Frontend** | Next.js 15 (App Router) | Web dashboard |
| **Backend** | Next.js API Routes | REST API |
| **Database** | PostgreSQL 15 | Data storage |
| **Authentication** | NextAuth.js | OAuth/SSO |
| **Real-Time Sync** | Polling (30s interval) | Jira/GitHub/Slack sync |
| **Deployment** | Docker Compose | Self-hosted containers |

### System Diagram

```
Customer's Private Cloud (AWS/GCP/Azure/On-Premise)
┌─────────────────────────────────────────────────────┐
│                                                     │
│  ┌─────────────┐     ┌──────────────┐             │
│  │   Docker    │     │  PostgreSQL  │             │
│  │   Compose   │────▶│  (QUAD_ DB)  │             │
│  └─────────────┘     └──────────────┘             │
│         │                                           │
│         ├─── Next.js Web App (Port 3003)           │
│         │                                           │
│         └─── Polling Agents (Background Workers)   │
│              ├─ Jira Poller (every 30s)            │
│              ├─ GitHub Poller (every 30s)          │
│              └─ Slack Poller (every 60s)           │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  Customer's Internal Tools (Same Network)   │  │
│  ├─ Jira Server/Cloud                          │  │
│  ├─ GitHub Enterprise                          │  │
│  └─ Slack                                      │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## Two-Tier Offering

### Tier 1: quadframe.work (Free Static Website)

**What it is:**
- Marketing & documentation website
- Interactive demo dashboard (fake data)
- Agent MD file generator/downloader
- Free forever

**Who uses it:**
- Anyone learning QUAD methodology
- Teams downloading agent templates
- Developers trying QUAD with Claude Code

**Technology:**
- Next.js static export
- No backend, no database
- Hosted on Vercel or our server

**URL:** https://quadframe.work

### Tier 2: QUAD Platform (Self-Hosted Docker)

**What it is:**
- Full production dashboard
- Real-time polling agents
- Live data from Jira/GitHub/Slack
- User management (RBAC)
- Analytics & metrics

**Who uses it:**
- Companies with 5+ developers
- Enterprises needing self-hosted solution
- Teams wanting live dashboards

**Technology:**
- Docker Compose stack
- PostgreSQL database
- Runs in customer's cloud

**Pricing:**
- Free: 5 users
- Pro: $99/month (unlimited users)
- Enterprise: $499/month (white-label + support)

---

## Database Schema

**Location:** `/Users/semostudio/git/a2vibecreators/nutrinine/nutrinine-database/sql/tables/quad_platform/`

**Tables (6 total):**

| Table | Purpose | Records (Est.) |
|-------|---------|----------------|
| `QUAD_companies` | Company accounts | ~100 companies |
| `QUAD_users` | User accounts (RBAC) | ~500 users |
| `QUAD_company_integrations` | Enabled integrations | ~300 records |
| `QUAD_agent_downloads` | Download audit trail | ~2,000 downloads |
| `QUAD_sessions` | Active sessions (JWT) | ~50-100 active |
| `QUAD_login_codes` | Passwordless login codes | ~10-20 active |

**Shared Database:**
- QUAD Platform uses NutriNine PostgreSQL database
- Tables prefixed with `QUAD_` for clean separation
- No foreign keys between NutriNine and QUAD tables
- Easy to split into separate database later

**Loading Tables:**
```bash
cd /Users/semostudio/git/a2vibecreators/nutrinine/nutrinine-database/sql
docker exec -i postgres-dev psql -U nutrinine_user -d nutrinine_dev_db < schema.sql
```

---

## Authentication

### SSO Providers Supported (Out of the Box)

| Provider | Use Case | Companies Using It |
|----------|----------|-------------------|
| **Okta** | Enterprise SSO | Mass Mutual, FedEx, T-Mobile |
| **Azure AD** | Microsoft 365 | Most enterprises |
| **Google** | Startups, SMBs | Tech companies |
| **GitHub** | Developer teams | Open source teams |
| **Auth0** | Modern SSO | Atlassian, Mozilla |
| **OIDC** | Custom SSO | OneLogin, Ping, Keycloak |

### Authentication Flow

```
User visits /login
  ↓
Clicks "Sign in with Okta"
  ↓
Redirected to Okta login page
  ↓
User enters Okta credentials
  ↓
Okta redirects back to QUAD Platform
  ↓
NextAuth.js callback:
  1. Check if user exists (by email)
  2. If yes → Update OAuth info, login
  3. If no → Check company by email domain
     - If @massmutual.com found → Create user, login
     - If not found → Redirect to /signup
  ↓
JWT token created → User logged in
```

### Free Tier Enforcement (5 Users)

```sql
-- Check user count before allowing new signup
SELECT COUNT(*) FROM QUAD_users WHERE company_id = $1;
-- If count >= 5 AND company.size = 'startup' → Redirect to /upgrade
```

**Documentation:** [SSO Setup Guide](integration/SSO_SETUP_GUIDE.md)

---

## Deployment Models

### Option A: SaaS (Our Cloud) - Not Implemented

**Pros:** Easy for customers, we manage everything
**Cons:** Security concerns, GDPR compliance, customer hesitation
**Status:** ❌ Not building this (self-hosted only)

### Option B: Self-Hosted (Customer's Cloud) - ✅ Current Approach

**What customer gets:**
- Docker Compose YAML file
- Pre-built Docker images
- PostgreSQL database
- Next.js web app
- Polling agents

**Customer runs:**
```bash
docker-compose up -d
```

**Accessible at:**
```
http://localhost:3003 (dev)
https://quad.company-internal.com (production)
```

**Benefits:**
- ✅ Customer data stays in their cloud
- ✅ No compliance issues (GDPR, SOC2, HIPAA)
- ✅ Faster access to Jira/GitHub (same network)
- ✅ No firewall issues
- ✅ Enterprise-friendly

**Deployment Guide:** [Deployment Documentation](deployment/DEPLOYMENT.md) *(to be created)*

---

## Real-Time Agents

### Polling vs Webhooks

**Decision:** Polling (Every 30 seconds)

**Why?**
- ✅ No firewall issues (outbound requests always work)
- ✅ Zero webhook configuration
- ✅ Works everywhere (cloud, on-premise, air-gapped)
- ✅ 30s delay = "real-time enough" for dashboards
- ✅ Industry standard (Zapier polls every 15 minutes)

**How it works:**
```javascript
// Jira Poller (runs every 30 seconds)
setInterval(async () => {
  const thirtySecondsAgo = new Date(Date.now() - 30000);

  // Query Jira for recent changes
  const tickets = await jira.search({
    jql: `updated >= "${thirtySecondsAgo.toISOString()}"`
  });

  // Save to database
  for (const ticket of tickets) {
    await db.saveTicket(ticket);
  }
}, 30000);
```

**API Rate Limits (No Problem):**
```
Jira: 10,000 requests/hour
Our usage: 120 requests/hour (1.2% of limit)
```

**Configurable Refresh:**
- Admin can change interval: 15s, 30s, 1min, 5min
- User can click "Refresh Now" button
- Auto-refresh can be disabled

---

## Pricing & Free Tier

| Plan | Price | Users | Features |
|------|-------|-------|----------|
| **Free** | $0 | 5 | All features, self-hosted |
| **Pro** | $99/month | Unlimited | Updates, support |
| **Enterprise** | $499/month | Unlimited | White-label, priority support, SLA |

**Free Tier Enforcement:**
- 6th user tries to login → Redirect to /upgrade
- Message: "Upgrade to Pro for unlimited users"
- No credit card required for free tier

**Revenue Model:**
- Customer pays monthly subscription
- We provide Docker image updates
- Support via email/Slack

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| [SSO Setup Guide](integration/SSO_SETUP_GUIDE.md) | Configure Okta, Azure AD, Google, etc. |
| [Deployment Guide](deployment/DEPLOYMENT.md) | Docker Compose setup *(to be created)* |
| [Architecture Docs](architecture/ARCHITECTURE.md) | Technical architecture *(to be created)* |
| [API Reference](architecture/API_REFERENCE.md) | REST API endpoints *(to be created)* |

---

## Project Status

**Current Sprint (Dec 2025):**
- ✅ Database schema (6 QUAD_ tables)
- ✅ OAuth SSO authentication (6 providers)
- ✅ NextAuth.js integration
- ✅ Documentation structure
- 🔄 Auth pages (signup/login UI)
- ⏳ Dashboard pages
- ⏳ Polling agents (Jira, GitHub, Slack)
- ⏳ Docker Compose setup

**Next Sprint (Jan 2026):**
- Agent download flow
- Company settings page
- User management (RBAC)
- Analytics dashboard

---

**Author:** A2Vibe Creators LLC
**Contact:** support@a2vibecreators.com
**GitHub:** https://github.com/a2vibecreators/quadframework
