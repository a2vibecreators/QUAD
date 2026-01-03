# QUAD Platform - Deployment Modes

**Date:** January 1, 2026
**Version:** 1.0

---

## Overview

QUAD Framework offers three deployment modes using mathematical complexity notation to reflect scaling characteristics:

| Mode | Name | Target | Users | Complexity |
|------|------|--------|-------|------------|
| **O(1)** | Seed | Startups | 1-10 | Constant (fixed cost) |
| **O(n)** | Growth | Small Business | 10-100 | Linear (scales with usage) |
| **O(n²)** | Scale | Enterprise | 100+ | Quadratic (full customization) |

---

## Mode Comparison

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DEPLOYMENT MODE MATRIX                               │
├─────────────────────┬─────────────────┬─────────────────┬───────────────────┤
│ Feature             │ O(1) Seed       │ O(n) Growth     │ O(n²) Scale       │
├─────────────────────┼─────────────────┼─────────────────┼───────────────────┤
│ Target Users        │ 1-10            │ 10-100          │ 100+              │
│ Platform Hosting    │ A2Vibe Cloud    │ A2Vibe Cloud    │ Client On-Prem    │
│ Database            │ Shared          │ Dedicated       │ Client Managed    │
│ AI Provider         │ A2Vibe Key      │ Client Key      │ Client Key        │
│ Who Pays AI         │ A2Vibe          │ Client          │ Client            │
│ Data Isolation      │ Logical         │ Physical        │ Complete          │
│ Support             │ Community       │ Email (48h)     │ Dedicated (4h)    │
│ Customization       │ None            │ Limited         │ Full              │
│ SLA                 │ 99%             │ 99.5%           │ 99.9%             │
└─────────────────────┴─────────────────┴─────────────────┴───────────────────┘
```

---

## O(1) Seed Mode

**For:** Startups, solo developers, proof-of-concept projects

### What's Included

| Component | Provider | Details |
|-----------|----------|---------|
| Platform | A2Vibe Cloud | Shared Next.js instance |
| Database | A2Vibe Cloud | Shared PostgreSQL (logical isolation) |
| AI (Claude) | A2Vibe API Key | 1,000 AI calls/month included |
| Storage | A2Vibe Cloud | 1GB file storage |
| Support | Community | Discord + GitHub Issues |

### Pricing

```
Monthly: $49/month
Annual:  $470/year (20% discount)

Includes:
- Up to 10 users
- 1,000 AI API calls/month
- 1 domain (organizational unit)
- Community support

Overage:
- Additional AI calls: $0.01/call
- Additional users: $5/user/month
```

### Limitations

- No custom branding
- No SSO/SAML
- Shared infrastructure (noisy neighbor risk)
- AI usage capped (prevents cost overrun for us)
- No dedicated support

### Best For

- Testing QUAD methodology
- Small teams exploring AI adoption
- Budget-conscious startups
- POC before enterprise rollout

---

## O(n) Growth Mode

**For:** Small businesses, growing teams, departments within larger orgs

### What's Included

| Component | Provider | Details |
|-----------|----------|---------|
| Platform | A2Vibe Cloud | Dedicated Next.js instance |
| Database | A2Vibe Cloud | Dedicated PostgreSQL |
| AI (Claude) | **Client's API Key** | BYOK (Bring Your Own Key) |
| Storage | A2Vibe Cloud | 10GB file storage |
| Support | Email | 48-hour response SLA |

### Pricing

```
Monthly: $199/month
Annual:  $1,990/year (17% discount)

Includes:
- Up to 100 users
- Unlimited AI calls (client pays Anthropic directly)
- 5 domains
- Email support (48h SLA)
- Custom subdomain (company.quad.a2vibecreators.com)

Additional:
- Extra domains: $20/domain/month
- Priority support upgrade: $100/month
```

### BYOK (Bring Your Own Key)

Client provides their own Anthropic API key:

```typescript
// Client configuration
{
  "ai_provider": "anthropic",
  "api_key": "sk-ant-api03-...",  // Client's key
  "model": "claude-sonnet-4-20250514",
  "monthly_budget_alert": 500  // USD
}
```

**Benefits:**
- Client controls AI spend
- No usage caps from us
- Client's enterprise Anthropic agreement applies
- We never see their API key (stored encrypted)

### Best For

- Growing startups (Series A/B)
- SMB with 20-50 employees
- Departmental pilots in large orgs
- Teams needing dedicated resources

---

## O(n²) Scale Mode

**For:** Enterprises requiring full control, compliance, data sovereignty

### What's Included

| Component | Provider | Details |
|-----------|----------|---------|
| Platform | **Client Infrastructure** | Docker/Kubernetes deployment |
| Database | **Client Infrastructure** | PostgreSQL (any version 14+) |
| AI (Claude) | **Client's API Key** | Enterprise agreement |
| Storage | **Client Infrastructure** | S3-compatible or local |
| Support | Dedicated | 4-hour response, named engineer |

### Pricing

```
One-Time License: $10,000
Annual Support:   $2,000/year

Includes:
- Unlimited users
- Unlimited domains
- Source code access (read-only)
- Deployment assistance (up to 8 hours)
- Dedicated support engineer
- 4-hour response SLA
- Quarterly business reviews
```

### Deployment Options

**Option A: Docker Compose (Simple)**
```bash
# Single-server deployment
docker-compose -f docker-compose.prod.yml up -d
```

**Option B: Kubernetes (Scalable)**
```bash
# Multi-node cluster
helm install quad ./charts/quad \
  --set database.host=your-rds.amazonaws.com \
  --set ai.apiKeySecret=your-k8s-secret
```

**Option C: Air-Gapped (Maximum Security)**
```bash
# Offline installation
./install-airgapped.sh --bundle quad-v1.0.tar.gz
```

### Compliance Support

| Standard | Support Level |
|----------|---------------|
| SOC 2 Type II | Documentation provided |
| HIPAA | BAA available |
| GDPR | Data residency controls |
| FedRAMP | Guidance only (not certified) |

### Best For

- Fortune 500 companies
- Regulated industries (finance, healthcare)
- Government contractors
- Organizations with strict data sovereignty requirements

---

## Cost Comparison

### Example: 50-User Team

| Cost Item | O(1) Seed | O(n) Growth | O(n²) Scale |
|-----------|-----------|-------------|-------------|
| Platform | $49/mo | $199/mo | $833/mo* |
| AI Calls (5K/mo) | $40/mo** | ~$15/mo*** | ~$15/mo*** |
| **Total Monthly** | **$89** | **$214** | **$848** |
| **Total Annual** | **$1,068** | **$2,568** | **$10,176** |

*Amortized ($10K license / 12 months)
**Overage at $0.01/call for 4K extra calls
***Client pays Anthropic directly at ~$0.003/call

### Break-Even Analysis

```
O(1) → O(n):  When AI usage exceeds 15K calls/month
O(n) → O(n²): When users exceed 100 OR compliance required
```

---

## Migration Paths

### O(1) → O(n) Upgrade

1. Export data from shared instance
2. Provision dedicated database
3. Import data
4. Configure client's API key
5. Update DNS (if custom domain)

**Downtime:** ~30 minutes
**Data Loss:** None

### O(n) → O(n²) Migration

1. Deploy infrastructure (client responsibility)
2. We provide deployment scripts
3. Database dump/restore
4. Configure client's AI key
5. Validation and cutover

**Downtime:** 2-4 hours (planned maintenance window)
**Data Loss:** None

---

## AI Provider Support

### Currently Supported

| Provider | O(1) | O(n) | O(n²) | Models |
|----------|------|------|-------|--------|
| Anthropic | ✅ | ✅ | ✅ | Claude Sonnet 4, Claude Opus 4 |

### Planned Support

| Provider | Target Date | Notes |
|----------|-------------|-------|
| OpenAI | Q2 2026 | GPT-4o, GPT-4o-mini |
| Google | Q3 2026 | Gemini Pro, Gemini Ultra |
| Azure OpenAI | Q3 2026 | For Azure-only enterprises |
| Local LLM | Q4 2026 | Ollama, vLLM (O(n²) only) |

---

## Security Comparison

| Security Feature | O(1) | O(n) | O(n²) |
|------------------|------|------|-------|
| Data Encryption (rest) | ✅ | ✅ | ✅ |
| Data Encryption (transit) | ✅ | ✅ | ✅ |
| SSO/SAML | ❌ | ✅ | ✅ |
| MFA | ✅ | ✅ | ✅ |
| Audit Logs | 30 days | 1 year | Unlimited |
| IP Whitelisting | ❌ | ✅ | ✅ |
| VPC/Private Link | ❌ | ❌ | ✅ |
| Custom Domain | ❌ | ✅ | ✅ |
| Data Residency | US only | US/EU | Anywhere |

---

## Decision Matrix

Choose your mode based on these questions:

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHICH MODE IS RIGHT FOR YOU?                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Do you have compliance requirements (SOC2, HIPAA, etc.)?       │
│     YES → O(n²) Scale                                           │
│     NO  ↓                                                        │
│                                                                  │
│  Do you have more than 100 users?                               │
│     YES → O(n²) Scale                                           │
│     NO  ↓                                                        │
│                                                                  │
│  Do you want to control AI costs directly?                      │
│     YES → O(n) Growth                                           │
│     NO  ↓                                                        │
│                                                                  │
│  Are you a startup or testing QUAD methodology?                 │
│     YES → O(1) Seed                                             │
│     NO  → O(n) Growth                                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Next Steps

1. **O(1) Seed:** [Sign up at quad.a2vibecreators.com](https://quad.a2vibecreators.com)
2. **O(n) Growth:** Contact sales@a2vibecreators.com
3. **O(n²) Scale:** Schedule a demo at calendly.com/a2vibecreators/quad-demo

---

**Last Updated:** January 1, 2026
