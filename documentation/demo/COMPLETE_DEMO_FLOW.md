# Complete Demo Flow - Org Setup to Code Generation

**Goal:** Show complete QUAD workflow from organization creation to deployed code

---

## Flow Overview

```
1. Create Organization (MassMutual)
   ↓
2. Set up Roles (RBAC: BA, Developer, DevOps)
   ↓
3. Assign Team Members
   ↓
4. Configure Industry Rules (Investment Banking / FINRA)
   ↓
5. USE CASE 1: Build Payment API
   - BA writes requirement
   - Developer uses QUAD to generate code
   - DevOps deploys to cloud
   ↓
6. Show Results (cost, time, compliance)
```

---

## Pre-Demo Setup (5 minutes before meeting)

```bash
# 1. Database is seeded
docker exec postgres-quad-dev psql -U quad_user -d quad_dev_db -c "SELECT COUNT(*) FROM quad_industry_defaults;"
# Should show: 9 rules

# 2. Containers running
docker ps | grep quad
# Should show: quad-services-dev, quad-web-dev, postgres-quad-dev

# 3. Java backend works
curl http://localhost:14101/v1/agent-rules/by-industry?industry=investment_banking&activityType=add_api_endpoint
# Should return JSON with FINRA rules

# 4. Gemini API key configured
grep GEMINI_API_KEY /Users/semostudio/git/a2vibes/QUAD/quad-web/.env.local
# Should show: GEMINI_API_KEY=AIzaSyBA27fTF2AyRISvz0LAJTX9mCL8B2PJxBY
```

---

## Demo Flow (Role-Play)

### Step 1: Create Organization (2 minutes)

**YOU (Narrator):**
> "First, MassMutual signs up and creates their organization in QUAD Platform."

**DEMO (Show Screen):**
```bash
# For demo, we'll use existing org, but explain the flow:
# 1. Signup at quadframe.work
# 2. Create organization: "MassMutual"
# 3. Select industry: "Investment Banking"
# 4. System auto-loads FINRA compliance rules
```

**Database (Behind the scenes):**
```sql
-- This already exists in quad_companies
INSERT INTO quad_companies (id, name, industry) VALUES
('massmutual-uuid', 'MassMutual', 'investment_banking');
```

---

### Step 2: Set Up Roles - RBAC (3 minutes)

**YOU:**
> "MassMutual has different roles: Business Analyst, Developer, DevOps. Let's set them up."

**Roles in QUAD:**

| Role | Permissions | Person (Role-Play) |
|------|-------------|-------------------|
| **Business Analyst (BA)** | Write requirements, create tickets | Daniel (daughter reference?) |
| **Developer** | Generate code, review code | Bright (function role) |
| **DevOps** | Deploy code, manage infrastructure | Suman |
| **Admin** | Manage org, configure rules | Lokesh |

**Database:**
```sql
-- quad_roles table
SELECT role_code, role_name FROM quad_roles WHERE company_id = 'massmutual-uuid';

-- Output:
-- ADMIN        | Administrator
-- BA           | Business Analyst
-- DEVELOPER    | Developer
-- DEVOPS       | DevOps Engineer
```

**YOU:**
> "Each person has specific responsibilities. This is enterprise RBAC - not a toy."

---

### Step 3: Assign Team Members (2 minutes)

**YOU:**
> "Let's assign our team to roles..."

**Team Setup:**

| Person | Role | Email | Access |
|--------|------|-------|--------|
| Lokesh | Admin | lokesh@massmutual.com | Full access |
| Daniel | BA | daniel@massmutual.com | Create tickets, view reports |
| Bright | Developer | bright@massmutual.com | Generate code, review |
| Suman | DevOps | suman@massmutual.com | Deploy, monitor |

**YOU:**
> "QUAD enforces permissions. A BA can't deploy code. A Developer can't change rules. Enterprise-grade security."

---

### Step 4: Configure Industry Rules (2 minutes)

**YOU:**
> "QUAD comes with FINRA defaults. But MassMutual can customize them..."

**Show Rules:**
```bash
curl "http://localhost:14101/v1/agent-rules/by-industry?industry=investment_banking&activityType=add_api_endpoint" | jq .rules
```

**Output:**
```json
{
  "DO": [
    "Use Java Spring Boot",
    "Add FINRA compliance logging for all transactions",
    "Follow Clean Architecture (Controller → Service → Repository)",
    "Validate all financial data with BigDecimal (not float/double)",
    "Add proper error handling with meaningful error codes"
  ],
  "DONT": [
    "Store PII in logs",
    "Use reflection for financial calculations",
    "Skip input validation",
    "Use float or double for money amounts"
  ]
}
```

**YOU:**
> "These rules are applied AUTOMATICALLY to every code generation. No developer can skip them."

---

### Step 5: USE CASE 1 - Build Payment API (5 minutes - THE MAIN DEMO)

#### Scene 1: BA Writes Requirement

**DANIEL (BA Role):**
> "I need a payment processing API for wire transfers. It should:
> - Accept wire transfer requests
> - Validate account numbers
> - Log everything for FINRA audits
> - Return confirmation number"

*(Types into QUAD)*

#### Scene 2: QUAD Reads Rules + Generates Code

**BRIGHT (Developer Role):**
> "I'm going to generate this code using QUAD..."

*(Runs command)*
```bash
curl -X POST https://dev.quadframe.work/api/agent-rules/generate \
  -H "Content-Type: application/json" \
  -d '{
    "task": "Build payment processing API for wire transfers. Accept wire transfer requests, validate account numbers, log everything for FINRA audits, return confirmation number.",
    "industry": "investment_banking",
    "activityType": "add_api_endpoint",
    "orgId": "massmutual-uuid"
  }' | jq .
```

**Expected Output:**
```json
{
  "success": true,
  "data": {
    "generatedCode": "package com.massmutual.payment;\n\nimport java.math.BigDecimal;\n...",
    "metadata": {
      "task": "Build payment processing API...",
      "activityType": "add_api_endpoint",
      "industry": "investment_banking",
      "rulesApplied": {
        "do": 5,
        "dont": 4
      }
    },
    "usage": {
      "inputTokens": 523,
      "outputTokens": 1847,
      "totalTokens": 2370
    },
    "model": "gemini-1.5-flash",
    "latencyMs": 3214
  }
}
```

**BRIGHT:**
> "Done! Look at the code..."
>
> *(Shows generated Java code with:)*
> - ✅ BigDecimal (not float)
> - ✅ FINRA logging
> - ✅ Input validation
> - ✅ Clean Architecture
>
> "Cost: $0.001. Time: 3 seconds."

#### Scene 3: DevOps Deploys

**SUMAN (DevOps Role):**
> "I'm deploying this to our DEV environment..."

*(In real demo, this would be a real deploy. For now, just explain)*
```bash
# Deploy command (simulated)
./deploy-to-dev.sh payment-api

# Output:
# ✅ Deployed to: https://dev-api.massmutual.com/payment
# ✅ Health check: PASS
# ✅ Time: 2 minutes
```

**YOU (Lokesh):**
> "From requirement to deployed code: **5 minutes total.**
>
> **Without QUAD?**
> - BA writes 10-page spec: 1 week
> - Developer codes: 1 week
> - Code review: 2 days
> - Compliance review: 3 days
> - Deploy: 1 day
>
> **Total: 2-3 weeks + $10,000 cost**
>
> **With QUAD: 5 minutes + $0.001**"

---

## Step 6: Show Results - The Proof (3 minutes)

### Cost Breakdown

| Item | Without QUAD | With QUAD |
|------|-------------|-----------|
| Developer time | 80 hours × $125/hr = $10,000 | 5 min × $125/hr = $10 |
| AI cost | N/A | $0.001 |
| Compliance risk | High (manual review) | Low (auto-enforced) |
| **Total** | **$10,000 + 2 weeks** | **$10 + 5 minutes** |

### Token Usage (SOC 2 Compliance)

```json
{
  "organization": "MassMutual",
  "user": "bright@massmutual.com",
  "action": "generate_code",
  "timestamp": "2026-01-09T15:23:41Z",
  "tokensUsed": 2370,
  "cost": 0.001,
  "rulesApplied": ["BigDecimal", "FINRA logging", "Input validation"],
  "auditTrail": "audit-log-uuid-12345"
}
```

**YOU:**
> "Every action is logged. SOC 2 compliant out of the box."

---

## The Ask (5 minutes)

**YOU:**
> "MassMutual, this is what we built with ZERO funding. Just three people working nights/weekends.
>
> **What we need from you:**
> - $500K for 30-day pilot
> - 10 developers from your team
> - Access to your GitHub and Confluence
>
> **What you get:**
> - GitHub integration (learns from your repos)
> - Confluence connector (learns from your docs)
> - VS Code extension (developers use daily)
> - Full SOC 2 audit trail
> - Enterprise support
>
> **ROI:**
> - 10 developers × 40 hours/week × 4 weeks = 1,600 hours saved
> - At $125/hr = **$200,000 saved in first month**
> - Your $500K pays for itself in 2.5 months
>
> **Are you ready to start Monday?**"

---

## Q&A Preparation

### Q: "What if the generated code has bugs?"

**A:** "Great question! We have three layers:
1. Rules prevent common bugs (BigDecimal, validation, etc.)
2. Developer reviews code before commit (not blind auto-commit)
3. Your existing CI/CD catches anything else

This is AI-ASSISTED development, not AI-ONLY. Developer is always in control."

### Q: "What about our existing codebase?"

**A:** "Right now, we generate NEW code. With your funding, we'll add:
- GitHub integration (reads your repos)
- RAG search (learns your patterns)
- Refactoring mode (updates existing code)

That's exactly what the pilot is for!"

### Q: "What about security?"

**A:** "Your code never leaves your infrastructure:
- Self-hosted on YOUR cloud
- YOUR API keys (BYOK)
- YOUR data stays with YOU
- We just provide the orchestration

Think of QUAD like VS Code - runs on your machine, YOUR code, YOUR control."

### Q: "What if Gemini goes down?"

**A:** "Multi-provider fallback:
- Primary: Gemini (cheap)
- Fallback: Claude (expensive but reliable)
- Fallback: OpenAI (alternative)

You're never dependent on one vendor."

---

## Success Metrics (What MassMutual Tracks During Pilot)

| Metric | Target | How Measured |
|--------|--------|--------------|
| **Time savings** | 80% reduction | Before/after timestamps |
| **Cost savings** | $200K/month | Developer hours × hourly rate |
| **Compliance violations** | 0 (vs 5-10 typical) | Code review findings |
| **Developer satisfaction** | 90%+ | Survey after 30 days |
| **Code quality** | Same or better | SonarQube metrics |

---

## Post-Pilot (What Happens After 30 Days)

**If successful:**
1. Enterprise contract: $499/month × 100 developers = $49,900/month
2. Custom features: GitHub integration, Confluence, RAG
3. Expand to 100 developers over 3 months
4. Case study: "MassMutual saves $2.4M/year with QUAD Platform"

**If not successful:**
- We refund $500K (no questions asked)
- You keep the code we generated
- No hard feelings

**Risk:** Zero. You literally cannot lose.

---

## Call to Action

**YOU (Final Close):**
> "MassMutual, you have two choices:
>
> **Choice A:** Keep doing what you're doing. 2-3 weeks per feature, $10K per endpoint, manual compliance reviews.
>
> **Choice B:** Pilot QUAD for 30 days. Risk-free. Money-back guarantee. Start Monday.
>
> **What do you choose?**"

---

**Version:** 1.0
**Last Updated:** January 9, 2026
**Authors:** Lokesh, Suman, Sharath

**Ready for Demo:** ✅ YES
