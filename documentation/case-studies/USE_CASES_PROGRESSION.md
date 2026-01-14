# QUAD Demo - Use Cases with Progressive Automation

**Strategy:** Show how teams transition from manual approval to AI automation

---

## The Progression (3 Stages)

```
Stage 1: MANUAL GATES (Start Here)
└─> Every step needs approval
    BA writes → Developer reviews → DevOps approves → Deploy

Stage 2: SELECTIVE AUTOMATION (After Trust Built)
└─> Simple tasks auto-approved, complex needs human
    Simple API → Auto-deploy ✅
    Complex logic → Human review ⚠️

Stage 3: FULL AUTOMATION (Mature Teams)
└─> AI handles everything, humans monitor
    All code → Auto-deploy ✅
    Humans → Watch dashboards 👀
```

---

## USE CASE 1: Payment API (WITH Human Gates)

**Scenario:** First time using QUAD - team doesn't trust AI yet

### Step 1: BA Creates Requirement

**DANIEL (BA):**
> "I need a payment processing API for wire transfers."

*(Creates ticket in QUAD)*

**System:** ⏸️ **HUMAN GATE 1** - "Developer, please review requirement"

---

### Step 2: Developer Reviews & Generates Code

**BRIGHT (Developer):**
> "Requirement looks good. Let me generate code..."

*(Approves ticket, QUAD generates code)*

```bash
curl -X POST https://dev.quadframe.work/api/agent-rules/generate \
  -H "Content-Type: application/json" \
  -d '{
    "task": "Build payment API for wire transfers",
    "industry": "investment_banking",
    "activityType": "add_api_endpoint",
    "orgId": "massmutual-uuid",
    "requireApproval": true
  }'
```

**Output:** Code generated, but NOT deployed

**System:** ⏸️ **HUMAN GATE 2** - "Developer, please review generated code"

---

### Step 3: Developer Reviews Code

**BRIGHT:**
> "Let me check the code..."
>
> *(Reviews generated Java code)*
> - ✅ Uses BigDecimal (correct)
> - ✅ FINRA logging (correct)
> - ✅ Input validation (correct)
> - ⚠️ Missing edge case: negative amounts
>
> "I'll add one line manually..."

*(BRIGHT edits the code, adds validation)*

```java
if (amount.compareTo(BigDecimal.ZERO) <= 0) {
    throw new InvalidAmountException("Amount must be positive");
}
```

**System:** ⏸️ **HUMAN GATE 3** - "DevOps, please approve deployment"

---

### Step 4: DevOps Approves & Deploys

**SUMAN (DevOps):**
> "Code looks good. Approving deployment..."

*(Clicks "Approve" button)*

**System:** ✅ Deploying to DEV...

**Result:**
- Time: 10 minutes (with human reviews)
- Cost: $0.001 (AI) + $20 (human review time)
- **Still 95% faster than traditional 2 weeks!**

---

## USE CASE 2: Customer Portal Website (LIFTING Gates)

**Scenario:** After 2 weeks of using QUAD, team trusts simple tasks. Daniel wants to self-service.

### Step 1: BA Creates Requirement (No Developer Needed!)

**DANIEL (BA):**
> "I want to add a customer portal page where customers can view their transaction history. This is simple - I'll generate and review myself."

*(Creates ticket in QUAD with "Simple" complexity)*

**System:** ✅ **GATE LIFTED** - Simple tasks auto-generate, BA reviews

---

### Step 2: QUAD Generates Code + Daniel Reviews

```bash
curl -X POST https://dev.quadframe.work/api/agent-rules/generate \
  -H "Content-Type: application/json" \
  -d '{
    "task": "Create customer portal page showing transaction history table with filters by date, amount, and status",
    "industry": "investment_banking",
    "activityType": "create_ui_screen",
    "orgId": "massmutual-uuid",
    "complexity": "simple",
    "requireApproval": false
  }'
```

**Output:** React component generated + preview URL

```jsx
// Generated: CustomerPortal.tsx
export function CustomerPortal() {
  const [transactions, setTransactions] = useState([]);
  const [filters, setFilters] = useState({ date: '', amount: '', status: '' });

  // ✅ Fetches from API
  // ✅ Filters client-side
  // ✅ Responsive table
  // ✅ FINRA audit logging

  return (
    <div className="customer-portal">
      <h1>Transaction History</h1>
      <TransactionFilters onChange={setFilters} />
      <TransactionTable data={filtered} />
    </div>
  );
}
```

**DANIEL (BA):**
> "Looks good! I can see the preview. Approving..."

*(Clicks "Approve & Deploy to DEV")*

**System:** ✅ Deployed to DEV instantly

**Result:**
- Time: 2 minutes (no developer involved!)
- Cost: $0.001
- **Daniel is empowered - no bottleneck on developers**

---

### Step 3: Automatic Staging Deployment (Gate Lifted!)

**System:** ✅ **GATE LIFTED** - Auto-promotes to staging after 24 hours in DEV with no issues

*(24 hours later, no bugs reported)*

**System:** ✅ Auto-promoted to https://staging.massmutual.com

**Notification to DevOps:**
> "Customer portal auto-deployed to staging. Review before PROD promotion."

---

### Step 4: DevOps Final Approval for PROD

**SUMAN (DevOps):**
> "Staging looks good. Promoting to PROD..."

*(One-click promotion)*

**System:** ✅ Live at https://app.massmutual.com/portal

**Result:**
- Time: 2 minutes (BA) + 1 minute (DevOps)
- Cost: $0.001
- **Developer time: 0 hours (freed up for complex work!)**

---

## Comparison: With Gates vs Lifted Gates

| Stage | Task | Human Gates | Time | Developer Hours |
|-------|------|-------------|------|-----------------|
| **Stage 1** | Payment API | 3 gates (BA → Dev → DevOps) | 10 min | 0.5 hrs |
| **Stage 2** | Customer Portal | 1 gate (DevOps only) | 2 min | 0 hrs |
| **Stage 3** | Bug Fix | 0 gates (auto-deploy) | 30 sec | 0 hrs |

**Traditional (No QUAD):**
- Payment API: 2 weeks, 80 developer hours
- Customer Portal: 1 week, 40 developer hours
- Bug Fix: 3 days, 8 developer hours

---

## The Pitch (During Demo)

**YOU:**
> "Notice what just happened? Daniel, our BA, built and deployed a customer portal WITHOUT needing a developer.
>
> **This is the future:**
> - Stage 1: We hold your hand - every step needs approval
> - Stage 2: You gain confidence - simple tasks auto-approved
> - Stage 3: Full trust - AI handles everything, you monitor
>
> **The transition is gradual. YOU control when gates lift. Not us.**"

**DANIEL (BA, enthusiastically):**
> "I used to wait 2 weeks for a simple page. Now I can build and deploy myself in 2 minutes. This is amazing!"

---

## Human Gates Configuration (Enterprise Feature)

**Admin Panel:**
```
┌─────────────────────────────────────────────────────┐
│  Human Gates Configuration - MassMutual            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Activity Type: add_api_endpoint                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ [x] Require developer review                 │  │
│  │ [x] Require DevOps approval                  │  │
│  │ [x] Require security scan                    │  │
│  │ [ ] Auto-deploy to DEV after approval        │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  Activity Type: create_ui_screen                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ [ ] Require developer review (LIFTED!)       │  │
│  │ [x] Require DevOps approval                  │  │
│  │ [ ] Require security scan                    │  │
│  │ [x] Auto-deploy to DEV after approval        │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  Activity Type: bug_fix                             │
│  ┌──────────────────────────────────────────────┐  │
│  │ [ ] Require developer review (LIFTED!)       │  │
│  │ [ ] Require DevOps approval (LIFTED!)        │  │
│  │ [x] Require security scan                    │  │
│  │ [x] Auto-deploy to DEV immediately           │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ✅ Configuration saved                             │
└─────────────────────────────────────────────────────┘
```

**YOU:**
> "This is enterprise-grade control. You decide which tasks need human approval. Start strict, loosen gradually as trust builds."

---

## Metrics: Gate Lift Impact

**After 30 days of pilot:**

| Metric | Week 1 (All Gates) | Week 4 (Some Lifted) | Impact |
|--------|-------------------|----------------------|--------|
| Tasks completed | 20 | 80 | **4x faster** |
| Developer hours saved | 0 | 60 hrs | **$7,500 saved** |
| BA satisfaction | 70% | 95% | **Empowered!** |
| DevOps workload | High | Medium | **50% reduction** |
| Time to production | 1 day | 2 hours | **12x faster** |

**YOU:**
> "This is the pilot goal - prove that gate lifting works. After 30 days, you'll see 4x productivity gain."

---

## Q&A: Addressing Concerns

### Q: "What if AI makes a mistake after gates are lifted?"

**A:** "Great question! We have rollback automation:
1. Every deploy is versioned
2. One-click rollback (30 seconds)
3. Automatic rollback if error rate spikes
4. You can ALWAYS re-add gates if needed

Think of it like training wheels - you can put them back on anytime."

### Q: "What if someone malicious lifts too many gates?"

**A:** "Admin audit trail:
- Every gate lift is logged
- Requires 2-person approval for production gates
- Can set maximum gates per role
- Weekly security review dashboard

Your security team has full visibility."

### Q: "How do we know when to lift gates?"

**A:** "QUAD recommends based on:
- Error rate (if < 1%, suggest lift)
- Task complexity (simple tasks lift first)
- Team confidence (survey results)
- Historical success rate

We don't force it - you decide."

---

## Call to Action

**YOU:**
> "MassMutual, this is the journey:
>
> **Month 1:** Keep all gates - build trust
> **Month 2:** Lift simple task gates - 2x faster
> **Month 3:** Lift most gates - 4x faster
> **Month 6:** Full automation - 10x faster
>
> **Your developers focus on:**
> - Complex architecture
> - Code reviews (not writing)
> - Mentoring junior devs
> - Innovation
>
> **Not on:**
> - CRUD endpoints
> - Simple UI pages
> - Bug fixes
> - Boilerplate
>
> **Ready to start the journey?**"

---

**Version:** 1.0
**Last Updated:** January 9, 2026
**Key Message:** Gradual trust, gradual automation, full control
