# QUAD Platform - Database Schema Documentation

**Date:** January 1, 2026
**PostgreSQL Version:** 15.x
**Total Tables:** 15
**Total Functions:** 4

---

## Table of Contents

1. [Schema Overview](#schema-overview)
2. [Core Tables](#core-tables)
3. [Feature Tables](#feature-tables)
4. [Resource/Attribute Tables (EAV Pattern)](#resourceattribute-tables-eav-pattern)
5. [Helper Functions](#helper-functions)
6. [Auto-Init Triggers](#auto-init-triggers)
7. [Example Queries](#example-queries)

---

## Schema Overview

```
QUAD_organizations                           ← Top-level organizations
  ├─ QUAD_roles                              ← Organization-specific roles with Q-U-A-D participation
  │     └─ QUAD_users                        ← User accounts (linked to role)
  │           ├─ QUAD_user_sessions          ← Active login sessions
  │           ├─ QUAD_domain_members         ← User roles per domain
  │           ├─ QUAD_adoption_matrix        ← AI adoption skill/trust tracking
  │           ├─ QUAD_work_sessions          ← Daily 4-4-4 work tracking
  │           ├─ QUAD_workload_metrics       ← Weekly workload summaries
  │           └─ QUAD_circle_members         ← Team circle assignments
  └─ QUAD_domains                            ← Organizational units (hierarchical)
        ├─ QUAD_circles                      ← 4 circles per domain (auto-created)
        ├─ QUAD_flows                        ← Work items with Q-U-A-D stages
        │     └─ QUAD_flow_stage_history     ← Stage transition audit log
        ├─ QUAD_domain_resources             ← Projects, integrations, repos
        │     └─ QUAD_resource_attributes    ← Key-value attributes (EAV)
        └─ QUAD_workload_metrics             ← Domain-level metrics
```

---

## Core Tables

### 1. QUAD_organizations

**Purpose:** Top-level customer organizations

> **Note:** The database table column `company_id` is mapped to `org_id` in Prisma for code clarity. API responses may still use `company_id` for backward compatibility.

```sql
CREATE TABLE QUAD_organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  admin_email VARCHAR(255) NOT NULL UNIQUE,
  size VARCHAR(50) DEFAULT 'medium',  -- 'small', 'medium', 'large', 'enterprise'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**Auto-Init Trigger:** When an organization is created, 6 default roles are automatically created.

---

### 2. QUAD_roles ✨ NEW

**Purpose:** Organization-specific role definitions with Q-U-A-D stage participation

```sql
CREATE TABLE QUAD_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_organizations(id) ON DELETE CASCADE,  -- Maps to org_id in Prisma

  -- Role identification
  role_code VARCHAR(50) NOT NULL,      -- 'ADMIN', 'MANAGER', 'DEVELOPER', etc.
  role_name VARCHAR(100) NOT NULL,     -- Display name
  description TEXT,

  -- Permission flags
  can_manage_company BOOLEAN DEFAULT FALSE,
  can_manage_users BOOLEAN DEFAULT FALSE,
  can_manage_domains BOOLEAN DEFAULT FALSE,
  can_manage_flows BOOLEAN DEFAULT FALSE,
  can_view_all_metrics BOOLEAN DEFAULT FALSE,
  can_manage_circles BOOLEAN DEFAULT FALSE,
  can_manage_resources BOOLEAN DEFAULT FALSE,

  -- Q-U-A-D Stage Participation
  -- Values: 'PRIMARY', 'SUPPORT', 'REVIEW', 'INFORM', NULL
  q_participation VARCHAR(10),  -- Question stage
  u_participation VARCHAR(10),  -- Understand stage
  a_participation VARCHAR(10),  -- Allocate stage
  d_participation VARCHAR(10),  -- Deliver stage

  -- UI display
  color_code VARCHAR(20),       -- Hex color: '#3B82F6'
  icon_name VARCHAR(50),        -- Icon name: 'shield', 'code'
  display_order INTEGER DEFAULT 0,

  -- Hierarchy (higher = more authority)
  hierarchy_level INTEGER DEFAULT 0,

  -- Status
  is_system_role BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(company_id, role_code)
);
```

**Default Roles (auto-created):**

| Role | Hierarchy | Q | U | A | D |
|------|-----------|---|---|---|---|
| ADMIN | 100 | INFORM | INFORM | REVIEW | INFORM |
| MANAGER | 80 | PRIMARY | PRIMARY | PRIMARY | REVIEW |
| TECH_LEAD | 60 | SUPPORT | PRIMARY | SUPPORT | REVIEW |
| DEVELOPER | 40 | INFORM | SUPPORT | INFORM | PRIMARY |
| QA | 40 | INFORM | SUPPORT | INFORM | REVIEW |
| OBSERVER | 20 | INFORM | INFORM | INFORM | INFORM |

---

### 3. QUAD_users

**Purpose:** User accounts with role assignment

```sql
CREATE TABLE QUAD_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_organizations(id) ON DELETE CASCADE,  -- Maps to org_id in Prisma
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id UUID REFERENCES QUAD_roles(id) ON DELETE SET NULL,
  role VARCHAR(50) DEFAULT 'DEVELOPER',  -- Legacy field (deprecated)
  full_name VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**Auto-Init Trigger:** When a user is created, an adoption matrix entry is automatically created.

---

### 4. QUAD_user_sessions

**Purpose:** Active login sessions with JWT tracking

```sql
CREATE TABLE QUAD_user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  session_token VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### 5. QUAD_domains

**Purpose:** Organizational units (hierarchical tree structure)

```sql
CREATE TABLE QUAD_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_organizations(id) ON DELETE CASCADE,  -- Maps to org_id in Prisma
  name VARCHAR(255) NOT NULL,
  parent_domain_id UUID REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  domain_type VARCHAR(50),   -- 'healthcare', 'finance', 'e_commerce', 'saas'
  path TEXT,                 -- Auto-generated: '/company/division/team'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**Auto-Init Trigger:** When a domain is created, 4 circles are automatically created.

---

### 6. QUAD_domain_members

**Purpose:** User membership in domains with allocation percentage

```sql
CREATE TABLE QUAD_domain_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL,
  allocation_percentage INT DEFAULT 100,  -- 50% = half-time on this domain
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(user_id, domain_id)
);
```

---

## Feature Tables

### 7. QUAD_adoption_matrix ✨ NEW

**Purpose:** Track user's AI adoption journey (Skill × Trust matrix)

```sql
CREATE TABLE QUAD_adoption_matrix (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES QUAD_users(id) ON DELETE CASCADE,
  skill_level INT DEFAULT 1,           -- 1-3: Beginner, Intermediate, Expert
  trust_level INT DEFAULT 1,           -- 1-3: Low, Medium, High
  previous_skill_level INT,
  previous_trust_level INT,
  level_changed_at TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**Matrix Positions:**
| Position | Skill | Trust | Label |
|----------|-------|-------|-------|
| (1,1) | Beginner | Low | AI Skeptic |
| (2,2) | Intermediate | Medium | AI Collaborator |
| (3,3) | Expert | High | AI Champion |

---

### 8. QUAD_circles ✨ NEW

**Purpose:** Team organization within domains (4 circles per domain)

```sql
CREATE TABLE QUAD_circles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  circle_number INT NOT NULL,          -- 1, 2, 3, 4
  circle_name VARCHAR(100) NOT NULL,
  description TEXT,
  lead_user_id UUID REFERENCES QUAD_users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(domain_id, circle_number)
);
```

**Default Circles (auto-created):**

| # | Name | Description |
|---|------|-------------|
| 1 | Management | Project management, requirements, stakeholder communication |
| 2 | Development | Design, coding, code review, architecture |
| 3 | QA | Testing, quality assurance, bug verification |
| 4 | Infrastructure | DevOps, deployment, monitoring, security |

---

### 9. QUAD_circle_members ✨ NEW

**Purpose:** User assignments to circles with allocation

```sql
CREATE TABLE QUAD_circle_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id UUID NOT NULL REFERENCES QUAD_circles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'member',   -- 'lead', 'member'
  allocation_pct INT DEFAULT 100,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(circle_id, user_id)
);
```

---

### 10. QUAD_flows ✨ NEW

**Purpose:** Work items that move through Q-U-A-D stages

```sql
CREATE TABLE QUAD_flows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  description TEXT,
  flow_type VARCHAR(50) DEFAULT 'feature',  -- 'feature', 'bug', 'task', 'spike'

  -- Current position in Q-U-A-D lifecycle
  quad_stage VARCHAR(1) DEFAULT 'Q',        -- 'Q', 'U', 'A', 'D'
  stage_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'in_progress', 'completed'

  -- Stage timestamps
  question_started_at TIMESTAMP,
  question_completed_at TIMESTAMP,
  understand_started_at TIMESTAMP,
  understand_completed_at TIMESTAMP,
  allocate_started_at TIMESTAMP,
  allocate_completed_at TIMESTAMP,
  deliver_started_at TIMESTAMP,
  deliver_completed_at TIMESTAMP,

  -- Assignment
  assigned_to UUID REFERENCES QUAD_users(id),
  circle_number INT,                        -- Which circle owns this
  priority VARCHAR(20) DEFAULT 'medium',    -- 'low', 'medium', 'high', 'critical'

  -- Estimation
  ai_estimate_hours DECIMAL(5,2),
  buffer_pct INT,
  actual_hours DECIMAL(5,2),

  -- External linking
  external_id VARCHAR(100),                 -- Jira ticket ID, etc.
  external_url TEXT,

  created_by UUID REFERENCES QUAD_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### 11. QUAD_flow_stage_history ✨ NEW

**Purpose:** Audit trail for flow stage transitions

```sql
CREATE TABLE QUAD_flow_stage_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flow_id UUID NOT NULL REFERENCES QUAD_flows(id) ON DELETE CASCADE,
  from_stage VARCHAR(1),         -- NULL for initial creation
  to_stage VARCHAR(1) NOT NULL,
  from_status VARCHAR(20),
  to_status VARCHAR(20) NOT NULL,
  changed_by UUID REFERENCES QUAD_users(id),
  change_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 12. QUAD_work_sessions ✨ NEW

**Purpose:** Daily work tracking (4-4-4 model: 4 days, 4 hours, 4 deliverables)

```sql
CREATE TABLE QUAD_work_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  session_date DATE NOT NULL,
  hours_worked DECIMAL(4,2) DEFAULT 0,
  is_workday BOOLEAN DEFAULT true,
  start_time TIME,
  end_time TIME,
  deep_work_pct DECIMAL(5,2),      -- % of time in focused work
  meeting_hours DECIMAL(4,2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(user_id, session_date)
);
```

---

### 13. QUAD_workload_metrics ✨ NEW

**Purpose:** Weekly/monthly workload aggregations per user per domain

```sql
CREATE TABLE QUAD_workload_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  domain_id UUID REFERENCES QUAD_domains(id) ON DELETE SET NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  period_type VARCHAR(20) DEFAULT 'week',  -- 'week', 'month', 'quarter'

  -- Metrics
  assignments INT DEFAULT 0,
  completes INT DEFAULT 0,
  output_score DECIMAL(5,2),
  hours_worked DECIMAL(5,2) DEFAULT 0,
  target_hours DECIMAL(5,2) DEFAULT 16,    -- 4 days × 4 hours
  days_worked INT DEFAULT 0,
  target_days INT DEFAULT 4,

  -- Root cause analysis (if underperforming)
  root_cause VARCHAR(50),                   -- 'meetings', 'interruptions', 'blockers'
  root_cause_notes TEXT,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(user_id, domain_id, period_start, period_end)
);
```

---

## Resource/Attribute Tables (EAV Pattern)

### 14. QUAD_domain_resources

**Purpose:** Resources belonging to domains (projects, integrations, repos)

```sql
CREATE TABLE QUAD_domain_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  resource_type VARCHAR(50) NOT NULL,
  -- Types: 'web_app_project', 'mobile_app_project', 'api_project',
  --        'git_repository', 'itsm_integration', 'blueprint', 'sso_config'

  resource_name VARCHAR(255) NOT NULL,
  resource_status VARCHAR(50) DEFAULT 'pending_setup',
  -- Status: 'pending_setup', 'active', 'inactive', 'archived'

  created_by UUID REFERENCES QUAD_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### 15. QUAD_resource_attributes

**Purpose:** Key-value attributes for resources (EAV pattern)

```sql
CREATE TABLE QUAD_resource_attributes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES QUAD_domain_resources(id) ON DELETE CASCADE,
  attribute_name VARCHAR(50) NOT NULL,
  attribute_value TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(resource_id, attribute_name)
);
```

---

## Helper Functions

### QUAD_update_updated_at_column()

**Purpose:** Automatically update `updated_at` timestamp on row updates

```sql
CREATE OR REPLACE FUNCTION QUAD_update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Applied to all tables with `updated_at` column via triggers.

---

## Auto-Init Triggers

### QUAD_init_org_roles()

**Purpose:** Auto-create 6 default roles when organization is created

```sql
CREATE TRIGGER trg_organizations_init_roles
  AFTER INSERT ON QUAD_organizations
  FOR EACH ROW
  EXECUTE FUNCTION QUAD_init_org_roles();
```

Creates: ADMIN, MANAGER, TECH_LEAD, DEVELOPER, QA, OBSERVER

---

### QUAD_init_user_adoption_matrix()

**Purpose:** Auto-create adoption matrix entry when user is created

```sql
CREATE TRIGGER trg_QUAD_users_init_adoption_matrix
  AFTER INSERT ON QUAD_users
  FOR EACH ROW
  EXECUTE FUNCTION QUAD_init_user_adoption_matrix();
```

Initializes user at position (1,1) = "AI Skeptic"

---

### QUAD_init_domain_circles()

**Purpose:** Auto-create 4 circles when domain is created

```sql
CREATE TRIGGER trg_QUAD_domains_init_circles
  AFTER INSERT ON QUAD_domains
  FOR EACH ROW
  EXECUTE FUNCTION QUAD_init_domain_circles();
```

Creates: Management, Development, QA, Infrastructure circles

---

## Example Queries

### Get All Domains for User

```sql
SELECT d.id, d.name, d.path, dm.role, dm.allocation_percentage
FROM QUAD_domains d
JOIN QUAD_domain_members dm ON dm.domain_id = d.id
WHERE dm.user_id = '{user-id}'
ORDER BY d.path;
```

### Get User's Q-U-A-D Stage Participation

```sql
SELECT
  u.full_name,
  r.role_name,
  r.q_participation,
  r.u_participation,
  r.a_participation,
  r.d_participation
FROM QUAD_users u
JOIN QUAD_roles r ON u.role_id = r.id
WHERE u.id = '{user-id}';
```

### Get Flows by Stage

```sql
SELECT
  f.title,
  f.quad_stage,
  f.stage_status,
  u.full_name as assigned_to
FROM QUAD_flows f
LEFT JOIN QUAD_users u ON f.assigned_to = u.id
WHERE f.domain_id = '{domain-id}'
  AND f.quad_stage = 'D'
ORDER BY f.priority DESC;
```

### Get User's Adoption Matrix Position

```sql
SELECT
  u.full_name,
  am.skill_level,
  am.trust_level,
  CASE
    WHEN am.skill_level = 1 AND am.trust_level = 1 THEN 'AI Skeptic'
    WHEN am.skill_level = 2 AND am.trust_level = 2 THEN 'AI Collaborator'
    WHEN am.skill_level = 3 AND am.trust_level = 3 THEN 'AI Champion'
    ELSE 'Transitioning'
  END as adoption_label
FROM QUAD_users u
JOIN QUAD_adoption_matrix am ON am.user_id = u.id
WHERE u.company_id = '{org-id}';  -- company_id column maps to org_id in Prisma
```

---

## Schema File Organization

**QUAD uses Prisma ORM for schema management:**

```
quadframework/
├── prisma/
│   ├── schema.prisma                       ← Prisma schema definition
│   └── seeds/
│       └── journey1_healthtrack.sql        ← Test data for Journey 1
├── src/generated/prisma/                   ← Auto-generated Prisma client
└── .env                                    ← DATABASE_URL for quad_dev_db
```

**Database Setup:**
```bash
# Generate Prisma client
npx prisma generate

# Push schema to database (creates/updates tables)
npx prisma db push

# View database in browser
npx prisma studio

# Run seed data
docker cp prisma/seeds/journey1_healthtrack.sql postgres-dev:/tmp/
docker exec postgres-dev psql -U nutrinine_user -d quad_dev_db -f /tmp/journey1_healthtrack.sql
```

**Database Connection:**
```env
DATABASE_URL="postgresql://nutrinine_user:nutrinine_dev_pass@localhost:16201/quad_dev_db?schema=public"
```

**Note:** QUAD uses a **separate database** (`quad_dev_db`) from NutriNine (`nutrinine_dev_db`), both hosted in the same postgres-dev container.

---

**Last Updated:** January 1, 2026
**Next:** See [API_REFERENCE.md](API_REFERENCE.md) for complete API documentation.
