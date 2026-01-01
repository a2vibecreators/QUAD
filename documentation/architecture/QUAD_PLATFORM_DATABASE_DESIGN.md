# QUAD Platform - Database Design Documentation

**Created:** December 31, 2025
**Purpose:** Document the complete database architecture for QUAD Platform multi-tenant agent configuration system

---

## Overview

QUAD Platform uses **16 core database tables** organized into 6 functional categories:

1. **Core Identity** (2 tables) - Companies and users
2. **Domain Architecture** (3 tables) - Hierarchical workspaces and roles
3. **ITSM Integration** (4 tables) - Multi-ITSM support with SCIM provisioning
4. **Workload Tracking** (2 tables) - AI-powered developer workload calculation
5. **Key Management** (2 tables) - Hierarchical integration key inheritance
6. **Platform Management** (3 tables) - Sessions, agent downloads, integration requests

---

## Database Tables Summary

### Core Identity

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `QUAD_companies` | Company/workspace accounts | Multi-tier plans (Free/Pro/Enterprise) |
| `QUAD_users` | User accounts with OAuth SSO | 6 SSO providers, avatar URLs |

### Domain Architecture (NEW - Dec 31, 2025)

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `QUAD_domains` | Hierarchical domains/workspaces | Self-hosted (single root) vs Cloud (multiple roots) |
| `QUAD_domain_members` | User roles per domain | Multiple roles, allocation %, primary domain |
| `QUAD_role_capabilities` | ACL permissions per role | 8 roles with granular capabilities |

**Key Concepts:**
- **Domain = Workspace/Project** (NOT email domain)
- **Hierarchy:** Root → Domain → Sub-domain
- **Roles:** QUAD_ADMIN, DOMAIN_ADMIN, SUBDOMAIN_ADMIN, DEVELOPER, QA, QA_LEAD, INFRASTRUCTURE, DATABASE
- **Allocation:** Users can be 50% in Domain A + 50% in Domain B
- **Multiple Roles:** User can be DIRECTOR in Project A, TEAM_LEAD in Project B

### ITSM Integration (NEW - Dec 31, 2025)

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `QUAD_itsm_config` | ITSM tool configuration | Jira, ServiceNow, Linear, Zendesk, Freshservice |
| `QUAD_approval_workflows` | Approval tracking | In-app OR ITSM approval workflows |
| `QUAD_scim_config` | User provisioning | SCIM 2.0 from Okta/Azure AD, group mapping |
| `QUAD_scim_audit_log` | SCIM operation audit | Full request/response logging |

**Supported ITSM Tools (Phase 1):**
- ✅ Jira Service Management
- ✅ ServiceNow
- ✅ Jira Software
- 🔜 Linear
- 📋 Zendesk (Phase 2)
- 📋 Freshservice (Phase 2)

**Two Approval Methods:**
1. **In-app approval:** Simple (for startups/SMBs)
2. **ITSM approval:** Create ticket in ServiceNow/Jira (for enterprises)

### Workload Tracking (NEW - Dec 31, 2025) - Revolutionary Feature

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `QUAD_branch_ticket_mapping` | Auto-link branches to tickets | Extracts ticket ID from branch name |
| `QUAD_workload_tracking` | AI workload calculation | Daily snapshots, overload alerts |

**Branch-Ticket Auto-Coupling:**
```
Branch: feature/JIRA-123-add-login → Ticket: JIRA-123
Branch: bugfix/SNW-456-fix-timeout → Ticket: SNW-456
Branch: hotfix/LIN-789 → Ticket: LIN-789
```

**AI Workload Formula:**
```
base_workload = (active_tickets × 1.0) + (active_branches × 0.5) + (story_points × 0.2)
final_workload = base_workload × estimation_multiplier (0.5x rigid, 1.0x balanced, 1.5x flexible)
capacity_percentage = (final_workload / allocation_percentage) × 100
```

**Overload Alerts:**
- 0-50%: Normal (green)
- 50-70%: Moderate (yellow)
- 70-90%: High (orange)
- 90-100%: At capacity (red)
- >100%: Overloaded (alert DOMAIN_ADMIN)

### Key Management (NEW - Dec 31, 2025)

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `QUAD_domain_integration_keys` | Domain-level keys | Cascading inheritance |
| `QUAD_user_integration_keys` | User-specific keys | Override domain keys |

**Key Priority (highest to lowest):**
1. **User keys** (QUAD_user_integration_keys) ← HIGHEST
2. **Sub-domain keys** (QUAD_domain_integration_keys)
3. **Domain keys** (QUAD_domain_integration_keys)
4. **Root domain keys** (QUAD_domain_integration_keys) ← LOWEST

**Example Inheritance:**
```
Root domain (massmutual) has GitHub org token
  ├── insurance-division (inherits GitHub from root)
  │   ├── life-insurance (inherits GitHub from root)
  │   └── annuities (has own Jira token, inherits GitHub)
  └── wealth-management (has own GitHub token, overrides root)

Developer John uses personal GitHub token → Overrides all domain keys
```

### Platform Management

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `QUAD_sessions` | User sessions | JWT tokens, last activity |
| `QUAD_agent_downloads` | Agent download tracking | Agent type, download count |
| `QUAD_integration_requests` | Integration requests | User requests for new tools |
| `QUAD_company_integrations` | Legacy integrations | Will be migrated to domain-level |

---

## Role Hierarchy

### 1. QUAD_ADMIN (1-2 people in entire company)

**Can Do:**
- Create root domains
- Create any domain/sub-domain
- Invite users to any domain
- Assign any role
- Manage global integration keys
- Approve any request

**Cannot Do:**
- (No restrictions)

### 2. DOMAIN_ADMIN (Directors)

**Can Do:**
- Create sub-domains under their domain
- Invite users to their domain
- Assign roles (except QUAD_ADMIN)
- Manage domain integration keys
- Approve requests in their domain

**Cannot Do:**
- Create root domains
- Delete root domains
- Assign QUAD_ADMIN role

### 3. SUBDOMAIN_ADMIN (Team Leads)

**Can Do:**
- Invite users to their sub-domain
- Assign basic roles (DEVELOPER, QA, etc.)
- Configure agents for their sub-domain
- View sub-domain activity

**Cannot Do:**
- Create domains
- Manage integration keys
- Assign admin roles

### 4. Regular Roles (DEVELOPER, QA, QA_LEAD, INFRASTRUCTURE, DATABASE)

**Can Do:**
- Download agents
- Use agents
- Manage their own integration keys
- Request new integrations
- View their own workload

**Cannot Do:**
- Invite users
- Assign roles
- Manage domain keys
- Create domains

---

## Deployment Models

### Self-Hosted (Enterprise)

**Structure:**
```
Company: Massachusetts Mutual Life Insurance
└── ROOT: massmutual (created at installation)
    ├── DOMAIN: insurance-division
    │   ├── SUB-DOMAIN: life-insurance
    │   ├── SUB-DOMAIN: annuities
    │   └── SUB-DOMAIN: disability
    └── DOMAIN: wealth-management
        ├── SUB-DOMAIN: retirement
        └── SUB-DOMAIN: investments
```

**Characteristics:**
- Single root domain per installation
- All users belong to same company
- Hierarchical sub-domains for divisions/teams
- Free tier limit: 5 users

### Cloud-Hosted (SaaS at quadframe.work)

**Structure:**
```
Company: Startup Alpha (workspace)
└── ROOT: startup-alpha

Company: Freelancer John (workspace)
└── ROOT: freelancer-john

Company: Agency Beta (workspace)
└── ROOT: agency-beta
    ├── DOMAIN: client-project-1
    └── DOMAIN: client-project-2
```

**Characteristics:**
- Multiple independent root domains
- Each company has isolated workspace
- Can create sub-domains for projects
- Free tier: 5 users per workspace

---

## User Journey Examples

### Example 1: Self-Hosted Enterprise (Mass Mutual)

**Step 1: Installation**
```sql
-- Created at installation
INSERT INTO QUAD_companies (name, admin_email, size) VALUES
    ('Massachusetts Mutual Life Insurance', 'it-admin@massmutual.com', 'enterprise');

INSERT INTO QUAD_domains (name, display_name, company_id, domain_type) VALUES
    ('massmutual', 'Mass Mutual', <company_id>, 'root');

INSERT INTO QUAD_domain_members (domain_id, email, role, status) VALUES
    (<domain_id>, 'it-admin@massmutual.com', 'QUAD_ADMIN', 'active');
```

**Step 2: Director Creates Division**
```sql
-- Director creates insurance-division domain
INSERT INTO QUAD_domains (name, display_name, parent_domain_id) VALUES
    ('insurance-division', 'Insurance Division', <massmutual_domain_id>);

INSERT INTO QUAD_domain_members (domain_id, email, role) VALUES
    (<insurance_domain_id>, 'director@massmutual.com', 'DOMAIN_ADMIN');
```

**Step 3: Team Lead Creates Sub-Domain**
```sql
-- Team lead creates life-insurance sub-domain
INSERT INTO QUAD_domains (name, display_name, parent_domain_id) VALUES
    ('life-insurance', 'Life Insurance', <insurance_domain_id>);

INSERT INTO QUAD_domain_members (domain_id, email, role) VALUES
    (<life_insurance_domain_id>, 'teamlead@massmutual.com', 'SUBDOMAIN_ADMIN');
```

**Step 4: Developer Joins Team**
```sql
-- Developer joins life-insurance team
INSERT INTO QUAD_domain_members (domain_id, email, role, allocation_percentage) VALUES
    (<life_insurance_domain_id>, 'dev@massmutual.com', 'DEVELOPER', 100.00);
```

### Example 2: Cloud-Hosted Startup

**Step 1: Signup**
```sql
-- User signs up at quadframe.work
INSERT INTO QUAD_companies (name, admin_email, size) VALUES
    ('Startup Alpha', 'founder@startupalpha.com', 'startup');

INSERT INTO QUAD_domains (name, display_name, company_id, domain_type) VALUES
    ('startup-alpha', 'Startup Alpha', <company_id>, 'root');

INSERT INTO QUAD_domain_members (domain_id, email, role, status) VALUES
    (<domain_id>, 'founder@startupalpha.com', 'DOMAIN_ADMIN', 'active');
```

**Step 2: Invite Team**
```sql
-- Founder invites 2 developers (free tier limit = 5 users)
INSERT INTO QUAD_domain_members (domain_id, email, role, status, invited_by) VALUES
    (<domain_id>, 'dev1@startupalpha.com', 'DEVELOPER', 'pending', <founder_id>),
    (<domain_id>, 'dev2@startupalpha.com', 'DEVELOPER', 'pending', <founder_id>);
```

### Example 3: Shared Resource (Developer Works on Multiple Projects)

**Developer allocated across 3 projects:**
```sql
-- Developer works 50% on insurance + 30% on wealth + 20% on legacy
INSERT INTO QUAD_domain_members (domain_id, email, role, allocation_percentage) VALUES
    (<insurance_domain_id>, 'shared-dev@massmutual.com', 'DEVELOPER', 50.00),
    (<wealth_domain_id>, 'shared-dev@massmutual.com', 'DEVELOPER', 30.00),
    (<legacy_domain_id>, 'shared-dev@massmutual.com', 'DEVELOPER', 20.00);

-- Workload tracking calculates capacity per domain
-- If insurance project has 10 active branches:
-- - Base workload in insurance: 10 branches × 0.5 = 5.0
-- - Capacity: (5.0 / 50) × 100 = 10% ← OK
--
-- If developer gets 20 more branches in wealth:
-- - Base workload in wealth: 20 branches × 0.5 = 10.0
-- - Capacity in wealth: (10.0 / 30) × 100 = 33% ← OK
-- - Total capacity across all domains: 10% + 33% + (legacy) = ~50% ← OK
```

---

## Integration Method Selection

### Webhooks vs SSH vs MCP

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Webhooks** | Real-time, no polling overhead | Requires firewall config, public URL | Cloud-hosted |
| **SSH Polling** | No firewall config, simple setup | 30s delay, higher load | Self-hosted, small teams |
| **MCP Agents** | No firewall, real-time, multi-AI support | Requires Claude Desktop or compatible AI | Self-hosted, enterprises |

**Auto-Setup Webhook (Optional):**
- Admin provides GitHub personal access token
- QUAD Platform uses GitHub API to create webhooks
- Token deleted after setup
- Admin can choose: auto-setup, manual setup, or skip webhooks

---

## Key Database Functions

### 1. Domain Path Auto-Generation

```sql
-- Trigger: update_domain_path()
-- Automatically generates path and depth for domains

Example:
Root: /massmutual (depth = 0)
Domain: /massmutual/insurance-division (depth = 1)
Sub-domain: /massmutual/insurance-division/life-insurance (depth = 2)
```

### 2. Allocation Percentage Check

```sql
-- Trigger: check_user_total_allocation()
-- Ensures user allocation across all domains doesn't exceed 100%

Example:
Developer allocated: 50% + 30% + 20% = 100% ← OK
Developer tries to add: 50% + 30% + 20% + 10% = 110% ← ERROR
```

### 3. Ticket ID Extraction

```sql
-- Function: extract_ticket_id_from_branch(branch_name)
-- Extracts ticket ID from git branch name

Examples:
feature/JIRA-123-add-login → JIRA-123 (provider: jira)
bugfix/SNW-456-fix-timeout → SNW-456 (provider: servicenow)
hotfix/LIN-789 → LIN-789 (provider: jira/linear)
feature/add-login → NULL (is_orphan = true)
```

### 4. Workload Calculation

```sql
-- Function: calculate_developer_workload(domain_id, developer_email, snapshot_date)
-- Calculates AI-powered workload score

Inputs:
- Active tickets (from ITSM)
- Active branches (from branch-ticket mapping)
- Story points (from ITSM tickets)
- Allocation percentage (from domain members)

Output:
- Base workload score
- Final workload score (with multiplier)
- Capacity percentage
- Overload alert (if > 70%)
```

### 5. Integration Key Resolution

```sql
-- Function: resolve_integration_key_for_user(user_id, domain_id, tool_provider)
-- Walks up hierarchy to find effective integration key

Priority:
1. User key (QUAD_user_integration_keys)
2. Sub-domain key (inherit_from_parent = false)
3. Domain key (inherit_from_parent = false)
4. Root domain key (fallback)

Example:
Developer John in life-insurance sub-domain needs GitHub token:
1. Check: John's personal GitHub token? → FOUND (use this)
2. If not found, check: life-insurance domain key? → Not found
3. If not found, check: insurance-division domain key? → Not found
4. If not found, check: massmutual root domain key? → FOUND (use this)
```

---

## Future Enhancements

### Phase 2 (Q1 2026)

1. **Additional ITSM Support:**
   - Zendesk
   - Freshservice
   - Monday.com

2. **Enhanced Workload Features:**
   - AI-suggested task reassignment
   - Workload balancing recommendations
   - Predictive capacity planning

3. **Advanced Key Management:**
   - Key rotation policies
   - Automatic key expiration
   - Key usage analytics

### Phase 3 (Q2 2026)

1. **Multi-Region Support:**
   - Regional domain isolation
   - Data residency compliance
   - Cross-region replication

2. **Advanced Approval Workflows:**
   - Multi-stage approvals
   - Conditional approval rules
   - Integration with custom ITSM workflows

3. **AI Enhancements:**
   - Code complexity analysis
   - Automatic story point estimation
   - Developer skill matching

---

## Technical Notes

### Database Constraints

- All UUIDs use `gen_random_uuid()` (PostgreSQL 13+)
- All timestamps use `CURRENT_TIMESTAMP`
- All tables have `created_at` and `updated_at` (via trigger)
- Foreign keys use `ON DELETE CASCADE` for cleanup

### Performance Considerations

- Indexed columns: domain_id, user_id, email, ticket_id, status
- Materialized path for fast hierarchy queries
- Daily snapshot for workload (not real-time calculation)

### Security

- All API keys stored in Vaultwarden (only path in DB)
- SCIM bearer tokens stored in Vaultwarden
- OAuth tokens stored in Vaultwarden
- Full audit log for SCIM operations

---

**Document Version:** 1.0
**Last Updated:** December 31, 2025
**Next Review:** January 15, 2026
