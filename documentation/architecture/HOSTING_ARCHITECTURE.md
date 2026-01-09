# QUAD Platform - Hosting Architecture

**Last Updated:** January 9, 2026

---

## 🏗️ Three-Tier Hosting Model

Based on discussion: QUAD Platform supports three deployment models to serve different customer needs.

```
┌─────────────────────────────────────────────────────────────┐
│                    QUAD Product Lineup                      │
├─────────────────────────────────────────────────────────────┤
│ 1. quadframe.work           → Static documentation (FREE)   │
│ 2. user.quadframe.work      → Internet SaaS (PAID)         │
│ 3. customer.quadframe.work  → Enterprise Intranet (PAID)   │
│                                                              │
│ OLD (Demo - Keep As-Is):                                     │
│ - customerdemo.quadframe.work → Demo version (v1.0)        │
└─────────────────────────────────────────────────────────────┘
```

**Note:** `customerdemo.quadframe.work` is the OLD demo version (v1.0). Keep it running for reference, but `customer.quadframe.work` is the NEW real enterprise product (v2.0).

---

## 1️⃣ quadframe.work - Static Documentation Site (FREE)

### Purpose
Marketing, education, and community resource. Learn about QUAD methodology, explore concepts, try interactive demos.

### Target Audience
- Developers learning QUAD methodology
- Students and educators
- Open-source community
- Researchers

### Features
- ✅ QUAD methodology documentation
- ✅ Interactive demos (read-only)
- ✅ Cheat sheets, glossary
- ✅ Blog posts, case studies
- ✅ Community forum (future)

### Technology
- **Framework:** Next.js (static site generation)
- **Hosting:** Vercel (free tier) OR GCP Cloud Storage (static)
- **Database:** None (100% static)
- **Cost:** $0/month (static hosting is free)

### URLs
- `https://quadframe.work` - Homepage
- `https://quadframe.work/concept` - QUAD concepts
- `https://quadframe.work/demo` - Interactive demo (read-only)
- `https://quadframe.work/cheatsheet` - Quick reference
- `https://quadframe.work/blog` - Blog posts

### Monetization
- ❌ No direct revenue
- ✅ Lead generation (users sign up for user.quadframe.work)
- ✅ SEO (drive organic traffic)

### Status
- ✅ **LIVE:** https://dev.quadframe.work (DEV)
- ⏳ Production deployment pending

---

## 2️⃣ user.quadframe.work - Internet SaaS (PAID)

### Purpose
Multi-tenant SaaS platform. Users sign up, get their own workspace, use QUAD Platform to build applications with AI agents.

### Target Audience
- Startups (5-20 developers)
- Small businesses
- Freelance agencies
- Individual developers

### Features
- ✅ Web-based workspace (no installation)
- ✅ AI agent generation
- ✅ Code generation (Factory of Factories)
- ✅ Multi-tenant isolation (one company per workspace)
- ✅ Git integration (GitHub, GitLab)
- ✅ Cloud deployment (GCP Cloud Run, AWS ECS)
- ✅ Prepaid credits OR BYOK (Bring Your Own Key)
- ✅ **Suma Chat Widget** (embedded support/help - uses api.suma.ai)
- ⏳ **Voice Assistant** (future - voice over Suma chat)

### Technology
- **Framework:** Next.js (app router)
- **Backend:** Java Spring Boot (quad-services)
- **Database:** PostgreSQL (shared, multi-tenant)
- **Hosting:** GCP Cloud Run (serverless, auto-scaling)
- **Authentication:** OAuth 2.0 (Google, GitHub, Okta)

### Architecture

```
Internet Users
     ↓
https://user.quadframe.work
     ↓
┌──────────────────────────────────┐
│ QUAD Web Platform (Next.js)     │
│ - Workspace management           │
│ - AI agent builder               │
│ - Code generator                 │
│ - Deployment dashboard           │
└──────────────────────────────────┘
     ↓
┌──────────────────────────────────┐
│ QUAD Services (Java Spring Boot) │
│ - Multi-tenant logic             │
│ - API endpoints                  │
│ - Business logic                 │
└──────────────────────────────────┘
     ↓
┌──────────────────────────────────┐
│ PostgreSQL (Shared)              │
│ - QUAD_companies (tenant ID)     │
│ - QUAD_users                     │
│ - QUAD_domains                   │
│ - Row-level security (RLS)       │
└──────────────────────────────────┘
```

### Multi-Tenant Isolation

**Database Design:**
- Every table has `company_id` column
- PostgreSQL Row-Level Security (RLS) enforces isolation
- Company A CANNOT see Company B's data

**Example:**
```sql
-- Company MassMutual (company_id = uuid1)
SELECT * FROM QUAD_domains WHERE company_id = 'uuid1';
-- Returns: Investment Portfolio, Trading Platform

-- Company Goldman Sachs (company_id = uuid2)
SELECT * FROM QUAD_domains WHERE company_id = 'uuid2';
-- Returns: Risk Management, Compliance Dashboard

-- Row-Level Security prevents cross-tenant access
```

### URLs
- `https://user.quadframe.work` - Login/signup
- `https://user.quadframe.work/dashboard` - Workspace home
- `https://user.quadframe.work/agents` - AI agent builder
- `https://user.quadframe.work/domains` - Domain management
- `https://user.quadframe.work/deploy` - Deployment dashboard

### Pricing
| Tier | Users | Features | Cost |
|------|-------|----------|------|
| **Free** | 5 | 100K tokens/month (QUAD credits) | $0 |
| **Pro** | 20 | Unlimited (BYOK or buy tokens) | $99/month |
| **Business** | 100 | Priority support, custom agents | $499/month |

### Monetization
- ✅ Monthly subscriptions ($99-$499/month)
- ✅ Token sales (if customer doesn't use BYOK)
- ✅ Enterprise upgrades (self-hosted)

### Status
- ✅ DEV: https://dev.quadframe.work
- ✅ QA: https://qa.quadframe.work
- ⏳ Production: user.quadframe.work (pending deployment)

---

## 3️⃣ customer.quadframe.work - Enterprise Intranet (PAID)

### Purpose
Self-hosted, single-tenant deployment inside customer's infrastructure. No data leaves customer's network. Full control, full isolation.

### Target Audience
- Large enterprises (200+ developers)
- Regulated industries (finance, healthcare, government)
- Companies with strict data sovereignty requirements
- Organizations requiring on-premises deployment

### Features
- ✅ Deployed in customer's cloud (GCP, AWS, Azure) OR on-premises (Kubernetes)
- ✅ Single-tenant (dedicated database, no sharing)
- ✅ Customer controls data (zero data leaves their network)
- ✅ BYOK only (customer's AI API keys)
- ✅ Custom integrations (customer's Okta, customer's Jira, customer's Git)
- ✅ Unlimited users (no per-seat pricing)
- ✅ White-label (customer can rebrand as "MassMutual AI Platform")
- ✅ **Suma Chat Widget** (embedded support/help - can use customer's API key)
- ⏳ **Voice Assistant** (future - voice over Suma chat)

### Technology
- **Framework:** Same as user.quadframe.work (Next.js + Java Spring Boot)
- **Deployment:** Docker containers (customer deploys)
- **Database:** Customer's PostgreSQL (not shared)
- **Hosting:** Customer's infrastructure (GCP, AWS, Azure, on-prem Kubernetes)
- **Authentication:** Customer's SSO (Okta, Azure AD, LDAP)

### Architecture

```
Customer's Network (e.g., MassMutual Intranet)
     ↓
https://quad.massmutual.internal (customer's domain)
     ↓
┌──────────────────────────────────┐
│ Customer's Load Balancer         │
└──────────────────────────────────┘
     ↓
┌──────────────────────────────────┐
│ QUAD Web (Docker Container)      │
│ - Runs in customer's Kubernetes  │
│ - Connected to customer's SSO    │
└──────────────────────────────────┘
     ↓
┌──────────────────────────────────┐
│ QUAD Services (Docker Container) │
│ - Customer's environment vars    │
│ - Customer's secrets             │
└──────────────────────────────────┘
     ↓
┌──────────────────────────────────┐
│ Customer's PostgreSQL            │
│ - Single-tenant (only MassMutual)│
│ - Customer controls backups      │
│ - Customer controls access       │
└──────────────────────────────────┘
     ↓
┌──────────────────────────────────┐
│ Customer's AI API Keys           │
│ - Anthropic (BYOK)               │
│ - OpenAI (BYOK)                  │
│ - Customer pays directly         │
└──────────────────────────────────┘
```

### Deployment Models

#### Option A: Cloud (GCP/AWS/Azure)

**Customer Provides:**
- GCP Project OR AWS Account OR Azure Subscription
- Their Anthropic/OpenAI API keys
- Their Okta/Azure AD credentials

**QUAD Provides:**
- Docker images (quad-web, quad-services, quad-database)
- Deployment scripts (Terraform, Helm charts)
- Installation guide
- License key (annual)

**Example: MassMutual GCP Deployment**
```
MassMutual GCP Project: massmutual-quad-prod
├── quad-web (Cloud Run)
├── quad-services (Cloud Run)
├── postgres-massmutual (Cloud SQL)
├── Secrets (Secret Manager)
│   ├── ANTHROPIC_API_KEY (MassMutual's key)
│   ├── OKTA_CLIENT_SECRET (MassMutual's Okta)
│   └── DATABASE_PASSWORD (MassMutual's password)
└── DNS: quad.massmutual.internal
```

**Data Flow:**
- MassMutual employee logs in → MassMutual Okta
- QUAD generates code → Calls Anthropic with MassMutual's API key
- Code stored → MassMutual's PostgreSQL database
- **Zero data leaves MassMutual's GCP project**

---

#### Option B: On-Premises (Kubernetes)

**Customer Provides:**
- Kubernetes cluster (on-prem data center)
- Their Anthropic/OpenAI API keys
- Their LDAP/Active Directory

**QUAD Provides:**
- Helm charts
- Kubernetes manifests
- Installation guide
- License key (annual)

**Example: Goldman Sachs On-Prem Deployment**
```
Goldman Sachs Data Center (New York)
├── Kubernetes Cluster
│   ├── quad-web (pod)
│   ├── quad-services (pod)
│   ├── postgres-goldman (StatefulSet)
│   └── redis-cache (pod)
├── DNS: quad.gs.internal
└── No internet access (air-gapped)
```

**Data Flow:**
- Goldman employee logs in → Goldman LDAP
- QUAD generates code → Calls Anthropic (via proxy if air-gapped)
- Code stored → Goldman's PostgreSQL (on-prem)
- **Zero data leaves Goldman's data center**

---

### URLs (Customer-Controlled)

Each customer chooses their own domain:

| Customer | Domain | Notes |
|----------|--------|-------|
| **MassMutual** | quad.massmutual.internal | Intranet only |
| **Goldman Sachs** | quad.gs.com | Public DNS but access restricted |
| **JPMorgan** | aiplatform.jpmorgan.com | White-labeled |

**QUAD does NOT host customer.quadframe.work** - Each customer self-hosts.

---

### Pricing

| Model | Users | Cost | Notes |
|-------|-------|------|-------|
| **Cloud Hosted** | Unlimited | $499/month OR $5,000/year | BYOK required |
| **On-Premises** | Unlimited | $10,000/year | Includes support |
| **White-Label** | Unlimited | $25,000/year | Custom branding |

**Why Higher Price?**
- Single-tenant (dedicated infrastructure)
- BYOK (customer pays Anthropic directly, no token markup)
- Unlimited users
- Premium support
- Custom integrations

---

### License Key Validation

**How It Works:**
```
Customer's QUAD Instance (quad.massmutual.internal)
     ↓
Every 24 hours: Phone home to license.quadframe.work
     ↓
Send: License key + Customer ID + User count
     ↓
QUAD License Server validates:
- License key valid?
- Annual fee paid?
- User count within limit? (unlimited for enterprise)
     ↓
Return: { valid: true, expires: "2027-01-09" }
     ↓
Customer's QUAD Instance continues operating
```

**If License Expires:**
- Grace period: 30 days
- Warning: "License expires in 30 days. Please renew at quadframe.work"
- After 30 days: Read-only mode (can view existing work, cannot generate new code)

---

### White-Label Option

**What Customer Gets:**
- Remove "QUAD" branding
- Replace with customer's logo
- Custom domain (aiplatform.massmutual.com)
- Custom colors/theme

**Example: MassMutual White-Label**
```
Original: QUAD Platform
White-Label: MassMutual AI Platform

Logo: [MassMutual Logo]
Colors: MassMutual blue (#003F5C)
Domain: aiplatform.massmutual.com
Footer: "Powered by QUAD" (small text)
```

---

## 🔄 Customer Journey: Internet → Intranet

### Scenario: MassMutual starts with user.quadframe.work, then migrates to self-hosted

**Month 1-3: Try Internet SaaS**
1. MassMutual signs up at user.quadframe.work
2. Uses Pro tier ($499/month)
3. 20 developers use QUAD Platform
4. Builds 5 internal apps

**Month 4: Security Review**
- MassMutual Security Team: "We can't use SaaS for production. Data must stay in our network."
- Decision: Migrate to self-hosted enterprise

**Month 5: Migration**
1. MassMutual purchases Enterprise license ($5,000/year)
2. QUAD provides Docker images + deployment scripts
3. MassMutual deploys to their GCP project (massmutual-quad-prod)
4. Data exported from user.quadframe.work → Imported to massmutual GCP
5. MassMutual cancels SaaS subscription

**Month 6+: Self-Hosted**
- 200 developers now use QUAD (no user limits)
- All data stays in MassMutual network
- MassMutual uses their own Anthropic API key (BYOK)
- Annual renewal: $5,000/year

---

## 💬 Suma Chat Integration (All QUAD Products)

### Overview

**Every QUAD product embeds Suma chat widget for user support and assistance.**

```
QUAD Product (user.quadframe.work OR customer.quadframe.work)
     ↓
[Bottom-right corner: Suma Chat Widget]
     ↓
User asks: "How do I create a new domain?"
     ↓
POST https://api.suma.ai/v1/chat
     ↓
Response: "To create a domain, click 'Domains' → '+ New Domain'..."
     ↓
Display in chat widget
```

### Implementation

**React Component:**
```jsx
// app/layout.tsx (both user.quadframe.work and customer.quadframe.work)
import { SumaChatWidget } from '@suma-ai/react';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}

        {/* Suma Chat Widget - Always visible */}
        <SumaChatWidget
          apiKey={process.env.SUMA_API_KEY} // QUAD's key for internet
          systemPrompt="You are a helpful assistant for QUAD Platform. Help users with domains, agents, deployments, and troubleshooting."
          theme="light"
          position="bottom-right"
          welcomeMessage="Hi! Need help with QUAD Platform?"
          placeholder="Ask me anything about QUAD..."
          showCreditsRemaining={false} // Hide for end users
        />
      </body>
    </html>
  );
}
```

### API Key Management

| Environment | API Key Source | Who Pays Tokens |
|-------------|---------------|-----------------|
| **user.quadframe.work** | QUAD's Suma API key | QUAD pays (marketing expense) |
| **customer.quadframe.work** | Customer choice | Customer's Suma API key OR QUAD's key |

**Why Customer Might Use Their Own Key:**
- High volume usage (1000+ support questions/day)
- Cost control
- Custom system prompt (branded responses)

**Example: MassMutual Self-Hosted**
```javascript
// customer.quadframe.work deployed at quad.massmutual.internal
<SumaChatWidget
  apiKey={process.env.MASSMUTUAL_SUMA_API_KEY} // MassMutual's key
  systemPrompt="You are MassMutual AI Assistant. Help users with QUAD Platform..."
  theme="massmutual-blue"
  primaryColor="#003F5C"
/>
```

### Use Cases

**1. Product Help (Most Common)**
```
User: "How do I deploy my application to production?"
Suma: "To deploy to production: 1) Go to Domains → Select domain → Deploy tab. 2) Select 'Production' environment. 3) Click 'Deploy Now'..."
```

**2. Troubleshooting**
```
User: "My deployment failed with error 'insufficient permissions'"
Suma: "This error means your GCP service account lacks Cloud Run Admin role. Fix: 1) Go to Settings → Cloud → Service Account. 2) Add 'Cloud Run Admin' role..."
```

**3. Code Review**
```
User: "Can you review this Java code for security issues?"
Suma: [Calls api.suma.ai/v1/code-review] "Found 2 medium issues: 1) SQL injection risk on line 42..."
```

**4. Feature Discovery**
```
User: "What's the difference between user.quadframe.work and customer.quadframe.work?"
Suma: "user.quadframe.work is our multi-tenant SaaS (shared infrastructure). customer.quadframe.work is enterprise self-hosted..."
```

### Voice Assistant (Future - Phase 2)

**Feature:** Add voice input/output to Suma chat

**Technology:**
- **Speech-to-Text:** Google Cloud Speech-to-Text OR Whisper API
- **Text-to-Speech:** Google Cloud Text-to-Speech OR ElevenLabs

**User Experience:**
```
User clicks 🎤 microphone icon
     ↓
Speaks: "How do I create a new domain?"
     ↓
Speech → Text conversion
     ↓
POST https://api.suma.ai/v1/chat
     ↓
Response: "To create a domain..."
     ↓
Text → Speech conversion
     ↓
🔊 Voice plays response
```

**Implementation Timeline:**
- Phase 1 (Q1 2026): Text chat only ✅
- Phase 2 (Q3 2026): Voice input/output ⏳

---

## 📊 Comparison Table

| Feature | quadframe.work | user.quadframe.work | customer.quadframe.work |
|---------|---------------|---------------------|-------------------------|
| **Purpose** | Marketing/Docs | Multi-tenant SaaS | Single-tenant Enterprise |
| **Target** | Everyone (free) | Startups, small teams | Large enterprises |
| **Hosting** | Vercel/GCP (us) | GCP Cloud Run (us) | Customer's cloud/on-prem |
| **Database** | None (static) | PostgreSQL (shared) | PostgreSQL (dedicated) |
| **Data Isolation** | N/A | Multi-tenant (RLS) | Single-tenant (air-gapped) |
| **Authentication** | None | OAuth (Google, GitHub) | Customer's SSO (Okta, AD) |
| **AI Keys** | None | QUAD OR BYOK | BYOK only |
| **Users** | Unlimited (read-only) | 5-100 (paid tiers) | Unlimited |
| **Cost** | $0 (free) | $0-$499/month | $5,000-$25,000/year |
| **Customization** | None | Limited | Full (white-label) |
| **Support** | Community | Email + Suma chat | Dedicated account manager + Suma chat |
| **Suma Chat** | ❌ No (static site) | ✅ Yes (QUAD pays) | ✅ Yes (customer choice) |
| **Voice Assistant** | ❌ No | ⏳ Future (Q3 2026) | ⏳ Future (Q3 2026) |

---

## 🚀 Deployment Architecture (All Three)

### Internet (user.quadframe.work)

```
┌─────────────────────────────────────────────────┐
│ GCP Cloud Run (QUAD's GCP Project)             │
├─────────────────────────────────────────────────┤
│ user.quadframe.work                             │
│   ├── quad-web-prod (Next.js)                   │
│   ├── quad-services-prod (Java Spring Boot)     │
│   ├── postgres-quad-prod (Cloud SQL)            │
│   └── redis-cache (Memorystore)                 │
│                                                  │
│ Multi-Tenant:                                    │
│   - Company A (MassMutual)                      │
│   - Company B (Startup XYZ)                     │
│   - Company C (Agency ABC)                      │
│                                                  │
│ All share same database (isolated by company_id)│
└─────────────────────────────────────────────────┘
```

### Enterprise (MassMutual Example)

```
┌─────────────────────────────────────────────────┐
│ MassMutual GCP Project (massmutual-quad-prod)  │
├─────────────────────────────────────────────────┤
│ quad.massmutual.internal                        │
│   ├── quad-web (Cloud Run)                      │
│   ├── quad-services (Cloud Run)                 │
│   ├── postgres-massmutual (Cloud SQL)           │
│   └── redis-cache (Memorystore)                 │
│                                                  │
│ Single-Tenant:                                   │
│   - ONLY MassMutual data                        │
│   - MassMutual's Okta SSO                       │
│   - MassMutual's Anthropic API key              │
│   - MassMutual's GitHub repos                   │
│                                                  │
│ Zero data leaves this GCP project               │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Business Strategy

### Why Three Tiers?

**Tier 1 (quadframe.work) = Lead Generation**
- Free documentation attracts developers
- SEO drives organic traffic
- Users learn QUAD → Sign up for Tier 2

**Tier 2 (user.quadframe.work) = Volume Revenue**
- Many small customers ($99-$499/month each)
- Recurring monthly revenue
- Low-touch sales (self-serve)

**Tier 3 (customer.quadframe.work) = High-Value Revenue**
- Few large customers ($5K-$25K/year each)
- Annual contracts (predictable)
- High-touch sales (enterprise reps)

### Revenue Forecast (Year 1)

| Tier | Customers | ARPU | Total Revenue |
|------|-----------|------|---------------|
| **quadframe.work** | 10,000 users | $0 | $0 |
| **user.quadframe.work** | 50 companies | $200/month | $10K/month = $120K/year |
| **customer.quadframe.work** | 2 enterprises | $5K/year | $10K/year |
| **Total Year 1** | | | **$130K** |

### Revenue Forecast (Year 2)

| Tier | Customers | ARPU | Total Revenue |
|------|-----------|------|---------------|
| **quadframe.work** | 50,000 users | $0 | $0 |
| **user.quadframe.work** | 200 companies | $250/month | $50K/month = $600K/year |
| **customer.quadframe.work** | 10 enterprises | $10K/year | $100K/year |
| **Total Year 2** | | | **$700K** |

---

## ✅ Next Steps

### This Week:
1. ⏳ Finalize hosting architecture (this document)
2. ⏳ Register domains (user.quadframe.work)
3. ⏳ Set up DNS for user.quadframe.work
4. ⏳ Deploy user.quadframe.work to GCP (multi-tenant)

### This Month:
5. ⏳ Build enterprise deployment package (Docker images + scripts)
6. ⏳ Create license key validation system
7. ⏳ Test self-hosted deployment (on our own infrastructure first)

### This Quarter:
8. ⏳ Launch user.quadframe.work (public beta)
9. ⏳ Sign first enterprise customer (MassMutual)
10. ⏳ Deploy MassMutual's self-hosted instance

---

**Status:** Architecture finalized, ready for implementation
**Owner:** Gopi Addanke
**Last Updated:** January 9, 2026
