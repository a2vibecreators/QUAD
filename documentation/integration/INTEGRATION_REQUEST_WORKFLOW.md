# QUAD Platform - Integration Request Workflow

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Purpose:** How users can request new tool integrations

---

## Overview

QUAD Platform currently supports **14 integrations** (GitHub, Jira, Slack, Figma, etc.). If your team uses a tool that's not yet supported, you can request it via the **Request Integration** feature in the QUAD Platform UI.

**How It Works:**
1. User finds a tool they need is not available
2. User clicks "Request Integration" button in QUAD Platform
3. Email sent to QUAD support team
4. QUAD team builds the integration
5. QUAD team sends deployment patch to client
6. Client deploys patch to their self-hosted instance
7. New integration is now available

---

## User Flow

### Step 1: User Discovers Missing Tool

**Scenario:** Developer wants to use Postman for API testing, but it's not in the list.

**UI (Company Settings → Integrations):**
```
Backend Developer Integrations:
  [x] GitHub ✅
  [x] Jira ✅
  [x] Slack ✅
  [ ] Postman 🔜 Coming Soon
  [ ] Docker 🔜 Coming Soon

Don't see the tool you need?
[Request Integration] button
```

---

### Step 2: User Clicks "Request Integration"

**Modal Opens:**
```
Request New Integration
────────────────────────────────────

Which tool would you like to integrate?
Tool Name: [Postman                    ]

What will you use it for?
Category: [API Testing ▼              ]

How many team members need this?
Team Size: [5                          ]

Additional Details (optional):
[We use Postman for API testing and want
agents to automatically generate Postman
collections from our backend APIs.       ]

Your Email: admin@acmecorp.com (auto-filled)
Company: Acme Corp (auto-filled)

[Cancel]  [Submit Request]
```

---

### Step 3: Email Sent to QUAD Support

**Email Template (Automated):**
```
To: integrations@quadframe.work
From: admin@acmecorp.com
Subject: Integration Request: Postman (Acme Corp)

Company: Acme Corp
Requested By: admin@acmecorp.com
Tool: Postman
Category: API Testing
Team Size Needing This: 5 users

Details:
"We use Postman for API testing and want agents to automatically
generate Postman collections from our backend APIs."

Company Info:
- Current Plan: Pro ($99/month)
- Users: 12
- Self-Hosted: Yes (version 1.2.3)

────────────────────────────────────
Reply to this email if you have questions.

QUAD Platform Support
```

---

### Step 4: QUAD Team Acknowledges Request

**Auto-Reply to User:**
```
To: admin@acmecorp.com
From: integrations@quadframe.work
Subject: Re: Integration Request: Postman (Acme Corp)

Hi Acme Corp team,

Thanks for requesting Postman integration! We've received your request.

Timeline: 2-4 weeks (depending on API complexity)

We'll send you:
1. Email when we start building (within 5 business days)
2. Email when integration is ready for testing (beta patch)
3. Email when production patch is available

You can check status anytime at:
https://quadframe.work/integrations/requests/postman-1234

Questions? Reply to this email.

Best,
QUAD Platform Support Team
```

---

### Step 5: QUAD Team Builds Integration

**Internal QUAD Team Workflow:**

1. **Assign to Engineer** (within 5 days)
   - Engineer researches Postman API
   - Creates integration plan
   - Estimates effort (2-4 weeks)

2. **Development** (1-3 weeks)
   - Builds Postman integration
   - Adds to `QUAD_company_integrations` table
   - Creates API polling logic
   - Writes tests

3. **Beta Testing** (1 week)
   - Deploys beta patch to Acme Corp
   - Acme Corp tests in their environment
   - Collects feedback
   - Fixes bugs

4. **Production Release**
   - Final patch sent to Acme Corp
   - Integration added to QUAD Platform for all future customers

---

### Step 6: User Receives Beta Patch

**Email to User:**
```
To: admin@acmecorp.com
From: integrations@quadframe.work
Subject: Beta Ready: Postman Integration (Acme Corp)

Hi Acme Corp team,

Great news! Postman integration is ready for beta testing.

How to Install Beta Patch:
────────────────────────────────────
1. Backup your current deployment:
   docker exec quad-platform /scripts/backup.sh

2. Download beta patch:
   wget https://releases.quadframe.work/patches/postman-beta-1.0.tar.gz

3. Apply patch:
   cd /opt/quad-platform
   tar -xzf postman-beta-1.0.tar.gz
   docker-compose restart

4. Verify installation:
   curl http://localhost:3000/api/integrations/postman/health
   → Should return: {"status": "ok"}

5. Configure in UI:
   Settings → Integrations → Postman
   Add your Postman API key

Test Instructions:
────────────────────────────────────
- Try creating a Postman collection from your API
- Verify agents can read/update collections
- Report any bugs by replying to this email

Estimated Testing Time: 3-5 days
────────────────────────────────────

Questions? Reply to this email or join our support Slack:
https://quadframe.work/support-slack

Best,
QUAD Platform Support Team
```

---

### Step 7: User Tests Beta Patch

**User Actions:**
1. Backs up current deployment
2. Downloads and applies beta patch
3. Configures Postman API key in UI
4. Tests with their team (3-5 days)
5. Reports bugs/feedback via email

**Bug Report Example:**
```
To: integrations@quadframe.work
Subject: Re: Beta Ready: Postman Integration

Hi QUAD team,

We tested the Postman integration. Found 2 issues:

1. Bug: Agent can't read collections with spaces in name
   Example: "User API Tests" fails, "UserAPITests" works

2. Feature Request: Can agent auto-sync collection changes?
   Right now we have to manually click "Refresh" in UI.

Otherwise looks great! Team loves it.

Thanks,
Acme Corp
```

---

### Step 8: QUAD Team Fixes Bugs

**Email to User:**
```
To: admin@acmecorp.com
From: integrations@quadframe.work
Subject: Beta v1.1 Ready: Postman Integration (Bug Fixes)

Hi Acme Corp team,

Thanks for the bug reports! We've fixed both issues:

✅ Fixed: Collections with spaces now work
✅ Added: Auto-sync every 30 seconds (configurable)

Updated Beta Patch:
────────────────────────────────────
wget https://releases.quadframe.work/patches/postman-beta-1.1.tar.gz

Apply same way as before. No database changes needed.

Please test again (1-2 days) and let us know if it's ready for production.

Best,
QUAD Platform Support Team
```

---

### Step 9: Production Patch Released

**Email to User:**
```
To: admin@acmecorp.com
From: integrations@quadframe.work
Subject: Production Patch: Postman Integration v1.0 (Final)

Hi Acme Corp team,

Postman integration is now production-ready! 🎉

Production Patch (Final):
────────────────────────────────────
wget https://releases.quadframe.work/patches/postman-prod-1.0.tar.gz

cd /opt/quad-platform
docker-compose down
tar -xzf postman-prod-1.0.tar.gz
docker-compose up -d

What's Included:
────────────────────────────────────
✅ Postman API integration (read/write collections)
✅ Auto-sync every 30 seconds
✅ Support for collection names with spaces
✅ Agent can generate Postman tests from backend APIs
✅ Full documentation in UI

This integration is now available to all QUAD Platform customers.

Questions? Reply to this email.

Thank you for helping us improve QUAD Platform!

Best,
QUAD Platform Support Team
```

---

## UI Design

### Integration Request Button

**Location:** Company Settings → Integrations

**Design:**
```
┌─────────────────────────────────────────────────┐
│ Backend Developer Integrations                  │
│                                                  │
│ [x] GitHub        ✅ Active                     │
│ [x] Jira          ✅ Active                     │
│ [x] Slack         ✅ Active                     │
│ [ ] Postman       🔜 Coming Soon                │
│ [ ] Docker        🔜 Coming Soon                │
│                                                  │
│ ┌──────────────────────────────────────────┐   │
│ │  Don't see the tool you need?            │   │
│ │  [Request Integration]                   │   │
│ └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

### Request Integration Modal

**Form Fields:**
```typescript
interface IntegrationRequest {
  toolName: string;           // Required
  category: string;           // Dropdown: API Testing, Cloud, CI/CD, etc.
  teamSize: number;           // Required
  details: string;            // Optional (500 chars max)
  userEmail: string;          // Auto-filled (from session)
  companyId: string;          // Auto-filled
}
```

**API Endpoint:**
```
POST /api/integrations/request
Body: {
  "toolName": "Postman",
  "category": "API Testing",
  "teamSize": 5,
  "details": "We use Postman for API testing...",
  "userEmail": "admin@acmecorp.com",
  "companyId": "company-uuid-123"
}

Response: {
  "requestId": "req-postman-1234",
  "status": "submitted",
  "estimatedTime": "2-4 weeks",
  "trackingUrl": "https://quadframe.work/integrations/requests/postman-1234"
}
```

---

### Request Tracking Page

**URL:** `https://quadframe.work/integrations/requests/postman-1234`

**UI:**
```
Integration Request: Postman
────────────────────────────────────

Status: In Progress (Step 2 of 4)

Timeline:
  ✅ 1. Request Submitted (Dec 31, 2025)
  ✅ 2. Development Started (Jan 5, 2025)
  ⏳ 3. Beta Testing (Est. Jan 20, 2025)
  ⏳ 4. Production Release (Est. Jan 30, 2025)

Details:
  Company: Acme Corp
  Requested By: admin@acmecorp.com
  Category: API Testing
  Team Size: 5 users

Updates:
  Jan 5, 2025: Development started by QUAD engineer
  Dec 31, 2024: Request submitted

Questions? Email integrations@quadframe.work
```

---

## Database Schema

**Store integration requests:**
```sql
CREATE TABLE IF NOT EXISTS QUAD_integration_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES QUAD_organizations(id) ON DELETE CASCADE,  -- Maps to org_id in Prisma

    -- Request details
    tool_name TEXT NOT NULL,
    category TEXT NOT NULL, -- API Testing, Cloud, CI/CD, etc.
    team_size INTEGER,
    details TEXT,

    -- Status tracking
    status TEXT NOT NULL DEFAULT 'submitted', -- submitted, in_progress, beta, released, rejected
    estimated_release_date DATE,

    -- User info
    requested_by_email TEXT NOT NULL,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    beta_released_at TIMESTAMP,
    prod_released_at TIMESTAMP
);

CREATE INDEX idx_quad_integration_requests_company ON QUAD_integration_requests(company_id);
CREATE INDEX idx_quad_integration_requests_status ON QUAD_integration_requests(status);
```

---

## QUAD Team Workflow

**When integration request comes in:**

1. **Auto-Create Ticket** (GitHub Issues or Jira)
   ```
   Title: [Integration Request] Postman - Acme Corp
   Labels: integration-request, customer-request
   Priority: P2 (based on team size + plan)
   Assignee: TBD
   ```

2. **Prioritize Requests**
   - Enterprise customers (highest priority)
   - Pro customers (medium priority)
   - Free tier (lowest priority)
   - Team size (more users = higher priority)
   - How many companies requested same tool

3. **Batch Similar Requests**
   - If 3+ companies request Postman → High priority
   - If only 1 company requests → Lower priority

4. **Estimate Effort**
   - Simple API (REST with docs) → 1-2 weeks
   - Complex API (GraphQL, auth) → 3-4 weeks
   - No API (requires custom solution) → Reject or discuss alternatives

---

## SLA (Service Level Agreement)

**Response Times:**
| Customer Plan | Initial Response | Development Start | Beta Release | Production |
|---------------|------------------|-------------------|--------------|------------|
| Enterprise    | 1 business day   | 5 business days   | 2-3 weeks    | 3-4 weeks  |
| Pro           | 2 business days  | 10 business days  | 3-4 weeks    | 4-6 weeks  |
| Free          | 5 business days  | Best effort       | Best effort  | Best effort |

**Notes:**
- Enterprise customers get priority
- Simple integrations may be faster
- Complex integrations may take longer
- If 5+ companies request same tool → Expedited (1-2 weeks)

---

## Future Enhancements

**Phase 2:**
- **Community Voting** - Users can upvote integration requests
- **Integration Marketplace** - Third-party developers can build integrations
- **Self-Service SDK** - Companies can build their own integrations

**Phase 3:**
- **Auto-Integration Generator** - AI generates integration from API docs
- **Integration Templates** - Reusable templates for common API patterns

---

## Example: Real Integration Requests

**Most Common Requests (Expected):**
1. **Postman** - API testing (5+ companies)
2. **Docker** - Containerization (10+ companies)
3. **AWS** - Cloud infrastructure (15+ companies)
4. **Terraform** - Infrastructure as Code (8+ companies)
5. **Selenium** - QA testing (6+ companies)

**Less Common Requests:**
- **SAP** - Enterprise ERP (1 company, complex, may reject)
- **Salesforce** - CRM (3 companies, medium priority)
- **ServiceNow** - ITSM (2 companies, medium priority)

---

## Support

**Questions?**
- Email: integrations@quadframe.work
- Slack: https://quadframe.work/support-slack
- Docs: https://quadframe.work/docs/integrations/request

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
