# QUAD Platform - Database Schema Documentation

**Date:** December 31, 2025
**PostgreSQL Version:** 15.x
**Total Tables:** 10 (current)

---

## Table of Contents

1. [Schema Overview](#schema-overview)
2. [Core Tables](#core-tables)
3. [Resource/Attribute Tables (EAV Pattern)](#resourceattribute-tables-eav-pattern)
4. [Helper Functions](#helper-functions)
5. [Triggers](#triggers)
6. [Example Queries](#example-queries)

---

## Schema Overview

```
QUAD_companies                               ← Top-level organizations
  └─ QUAD_users                             ← User accounts
      ├─ QUAD_domain_members                ← User roles per domain
      └─ QUAD_user_sessions                 ← Active login sessions

QUAD_domains                                 ← Organizational units (hierarchical)
  └─ QUAD_domain_resources                  ← Projects, integrations, repos
      ├─ QUAD_resource_attributes           ← Key-value attributes (EAV)
      └─ (references) QUAD_resource_attribute_requirements

QUAD_resource_attribute_requirements         ← Attribute validation rules
```

---

## Core Tables

### 1. QUAD_companies

**Purpose:** Top-level customer organizations

```sql
CREATE TABLE QUAD_companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  admin_email VARCHAR(255) NOT NULL UNIQUE,
  size VARCHAR(50) DEFAULT 'medium',  -- 'small', 'medium', 'large', 'enterprise'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_companies_admin_email ON QUAD_companies(admin_email);
```

**Example Data:**
```sql
INSERT INTO QUAD_companies (name, admin_email, size) VALUES
  ('A2Vibe Creators', 'admin@a2vibecreators.com', 'small'),
  ('MassMutual', 'admin@massmutual.com', 'enterprise');
```

---

### 2. QUAD_users

**Purpose:** User accounts with email/password authentication

```sql
CREATE TABLE QUAD_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_companies(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'DEVELOPER',  -- 'QUAD_ADMIN', 'DOMAIN_ADMIN', 'DEVELOPER', 'QA', 'VIEWER'
  full_name VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(email)
);

CREATE INDEX idx_users_company ON QUAD_users(company_id);
CREATE INDEX idx_users_email ON QUAD_users(email);
CREATE INDEX idx_users_role ON QUAD_users(role);
```

**Example Data:**
```sql
INSERT INTO QUAD_users (company_id, email, password_hash, role, full_name) VALUES
  ('{a2vibe-id}', 'suman@a2vibecreators.com', '$2b$10$...', 'QUAD_ADMIN', 'Suman Addanke'),
  ('{massmutual-id}', 'alice@massmutual.com', '$2b$10$...', 'DOMAIN_ADMIN', 'Alice Smith');
```

---

### 3. QUAD_domain_members

**Purpose:** User membership in domains with roles

```sql
CREATE TABLE QUAD_domain_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL,  -- 'DOMAIN_ADMIN', 'SUBDOMAIN_ADMIN', 'DEVELOPER', 'QA', 'VIEWER'
  allocation_percentage INT DEFAULT 100,  -- 50% = working 50% time on this domain
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(user_id, domain_id)
);

CREATE INDEX idx_domain_members_user ON QUAD_domain_members(user_id);
CREATE INDEX idx_domain_members_domain ON QUAD_domain_members(domain_id);
```

**Example Data:**
```sql
-- Alice is DOMAIN_ADMIN in MassMutual root, DEVELOPER in Insurance sub-domain
INSERT INTO QUAD_domain_members (user_id, domain_id, role, allocation_percentage) VALUES
  ('{alice-id}', '{massmutual-root-id}', 'DOMAIN_ADMIN', 50),
  ('{alice-id}', '{massmutual-insurance-id}', 'DEVELOPER', 50);
```

---

### 4. QUAD_domains

**Purpose:** Organizational units (hierarchical)

```sql
CREATE TABLE QUAD_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  parent_domain_id UUID REFERENCES QUAD_domains(id) ON DELETE CASCADE,  -- NULL = root domain
  domain_type VARCHAR(50),  -- 'healthcare', 'finance', 'e_commerce', 'saas', 'internal'
  path TEXT,  -- Auto-generated: '/massmutual/insurance-division/claims'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_domains_parent ON QUAD_domains(parent_domain_id);
CREATE INDEX idx_domains_type ON QUAD_domains(domain_type);
CREATE INDEX idx_domains_path ON QUAD_domains(path);
```

**Example Data:**
```sql
-- Root domain
INSERT INTO QUAD_domains (name, parent_domain_id, domain_type, path) VALUES
  ('MassMutual', NULL, 'finance', '/massmutual');

-- Sub-domain
INSERT INTO QUAD_domains (name, parent_domain_id, domain_type, path) VALUES
  ('Insurance Division', '{massmutual-id}', 'healthcare', '/massmutual/insurance-division');

-- Sub-sub-domain
INSERT INTO QUAD_domains (name, parent_domain_id, domain_type, path) VALUES
  ('Claims Processing', '{insurance-id}', 'healthcare', '/massmutual/insurance-division/claims');
```

---

## Resource/Attribute Tables (EAV Pattern)

### 5. QUAD_domain_resources

**Purpose:** Resources belonging to domains (projects, integrations, repos)

```sql
CREATE TABLE QUAD_domain_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  resource_type VARCHAR(50) NOT NULL,
  -- Types: 'web_app_project', 'mobile_app_project', 'api_project', 'landing_page_project',
  --        'git_repository', 'itsm_integration', 'blueprint', 'sso_config', 'integration_method'

  resource_name VARCHAR(255) NOT NULL,
  resource_status VARCHAR(50) DEFAULT 'pending_setup',
  -- Status: 'pending_setup', 'active', 'inactive', 'archived'

  created_by UUID REFERENCES QUAD_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_resources_domain ON QUAD_domain_resources(domain_id);
CREATE INDEX idx_resources_type ON QUAD_domain_resources(resource_type);
CREATE INDEX idx_resources_status ON QUAD_domain_resources(resource_status);
CREATE INDEX idx_resources_domain_type ON QUAD_domain_resources(domain_id, resource_type);
```

**Example Data:**
```sql
INSERT INTO QUAD_domain_resources (domain_id, resource_type, resource_name, created_by) VALUES
  ('{claims-domain-id}', 'web_app_project', 'Claims Dashboard', '{alice-id}'),
  ('{claims-domain-id}', 'git_repository', 'github.com/massmutual/claims-portal', '{alice-id}'),
  ('{claims-domain-id}', 'blueprint', 'Figma Claims Dashboard Design', '{alice-id}');
```

---

### 6. QUAD_resource_attributes

**Purpose:** Key-value attributes for resources (EAV pattern)

```sql
CREATE TABLE QUAD_resource_attributes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES QUAD_domain_resources(id) ON DELETE CASCADE,
  attribute_name VARCHAR(50) NOT NULL,
  -- Examples: 'project_type', 'frontend_framework', 'css_framework',
  --           'blueprint_url', 'git_repo_url', 'backend_framework'

  attribute_value TEXT,
  -- Stored as text, can be JSON for complex values

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(resource_id, attribute_name)
);

CREATE INDEX idx_attributes_resource ON QUAD_resource_attributes(resource_id);
CREATE INDEX idx_attributes_name ON QUAD_resource_attributes(attribute_name);
CREATE INDEX idx_attributes_resource_name ON QUAD_resource_attributes(resource_id, attribute_name);
```

**Example Data:**
```sql
-- Web app project attributes
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value) VALUES
  ('{claims-dashboard-id}', 'project_type', 'web_internal'),
  ('{claims-dashboard-id}', 'frontend_framework', 'nextjs'),
  ('{claims-dashboard-id}', 'css_framework', 'tailwind'),
  ('{claims-dashboard-id}', 'blueprint_url', 'https://figma.com/file/abc123'),
  ('{claims-dashboard-id}', 'blueprint_type', 'figma_url'),
  ('{claims-dashboard-id}', 'blueprint_verified', 'true'),
  ('{claims-dashboard-id}', 'git_repo_url', 'https://github.com/massmutual/claims-portal'),
  ('{claims-dashboard-id}', 'git_repo_type', 'github'),
  ('{claims-dashboard-id}', 'git_repo_private', 'false'),
  ('{claims-dashboard-id}', 'git_repo_analyzed', 'true'),
  ('{claims-dashboard-id}', 'git_repo_analysis_result', '{
    "success": true,
    "techStack": {
      "frontend": {"framework": "nextjs", "cssFramework": "tailwind"},
      "backend": {"framework": "java_spring_boot", "language": "java"}
    },
    "codePatterns": {...},
    "fileStructure": {...}
  }');
```

---

### 7. QUAD_resource_attribute_requirements

**Purpose:** Define which attributes are required for which resource types

```sql
CREATE TABLE QUAD_resource_attribute_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_type VARCHAR(50) NOT NULL,
  -- 'web_app_project', 'mobile_app_project', 'api_project', etc.

  attribute_name VARCHAR(50) NOT NULL,
  -- 'project_type', 'frontend_framework', 'blueprint_url', etc.

  is_required BOOLEAN DEFAULT false,
  display_order INT,  -- Controls form field sequence (1, 2, 3...)
  validation_rule VARCHAR(50),  -- 'url', 'enum', 'string', 'integer', 'boolean', 'json'
  allowed_values TEXT[],  -- For enum validation: ARRAY['nextjs', 'react', 'vue']
  help_text TEXT,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(resource_type, attribute_name)
);

CREATE INDEX idx_requirements_type ON QUAD_resource_attribute_requirements(resource_type);
CREATE INDEX idx_requirements_name ON QUAD_resource_attribute_requirements(attribute_name);
CREATE INDEX idx_requirements_type_name ON QUAD_resource_attribute_requirements(resource_type, attribute_name);
CREATE INDEX idx_requirements_required ON QUAD_resource_attribute_requirements(is_required);
```

**Example Data:**
```sql
-- Web app project requirements
INSERT INTO QUAD_resource_attribute_requirements (
  resource_type, attribute_name, is_required, display_order,
  validation_rule, allowed_values, help_text
) VALUES
  -- Required attributes
  ('web_app_project', 'project_type', true, 1, 'enum',
   ARRAY['web_internal', 'web_external'],
   'Is this an internal or external web application?'),

  ('web_app_project', 'frontend_framework', true, 2, 'enum',
   ARRAY['nextjs', 'react', 'vue', 'angular', 'svelte'],
   'Select your frontend framework'),

  ('web_app_project', 'css_framework', true, 3, 'enum',
   ARRAY['tailwind', 'bootstrap', 'mui', 'chakra', 'ant-design'],
   'Select your CSS framework'),

  ('web_app_project', 'blueprint_url', true, 5, 'url',
   NULL,
   'Figma/Sketch URL, competitor website, or generated mockup URL'),

  -- Optional attributes
  ('web_app_project', 'git_repo_url', false, 13, 'url',
   NULL,
   'URL to existing codebase for style matching (optional)'),

  ('web_app_project', 'backend_framework', false, 11, 'enum',
   ARRAY['nodejs', 'java_spring_boot', 'python_fastapi', 'python_django', 'ruby_rails', 'none'],
   'Select your backend framework (if full-stack)');
```

---

## Helper Functions

### get_required_attributes()

**Purpose:** Get all required attributes for a resource type, ordered by display_order

```sql
CREATE OR REPLACE FUNCTION get_required_attributes(p_resource_type VARCHAR)
RETURNS TABLE (
  attribute_name VARCHAR,
  validation_rule VARCHAR,
  allowed_values TEXT[],
  help_text TEXT,
  display_order INT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.attribute_name,
    r.validation_rule,
    r.allowed_values,
    r.help_text,
    r.display_order
  FROM QUAD_resource_attribute_requirements r
  WHERE r.resource_type = p_resource_type
    AND r.is_required = true
  ORDER BY r.display_order;
END;
$$ LANGUAGE plpgsql;
```

**Usage:**
```sql
SELECT * FROM get_required_attributes('web_app_project');
-- Returns: project_type, frontend_framework, css_framework, blueprint_url
```

---

### validate_resource_attributes()

**Purpose:** Validate that a resource has all required attributes with valid values

```sql
CREATE OR REPLACE FUNCTION validate_resource_attributes(p_resource_id UUID)
RETURNS TABLE (
  is_valid BOOLEAN,
  missing_attributes VARCHAR[],
  invalid_attributes VARCHAR[]
) AS $$
DECLARE
  v_resource_type VARCHAR;
  v_missing VARCHAR[];
  v_invalid VARCHAR[];
BEGIN
  -- Get resource type
  SELECT resource_type INTO v_resource_type
  FROM QUAD_domain_resources
  WHERE id = p_resource_id;

  -- Find missing required attributes
  SELECT ARRAY_AGG(req.attribute_name)
  INTO v_missing
  FROM QUAD_resource_attribute_requirements req
  LEFT JOIN QUAD_resource_attributes attr
    ON attr.resource_id = p_resource_id
    AND attr.attribute_name = req.attribute_name
  WHERE req.resource_type = v_resource_type
    AND req.is_required = true
    AND attr.id IS NULL;

  -- Find invalid enum values
  SELECT ARRAY_AGG(attr.attribute_name)
  INTO v_invalid
  FROM QUAD_resource_attributes attr
  JOIN QUAD_resource_attribute_requirements req
    ON req.attribute_name = attr.attribute_name
    AND req.resource_type = v_resource_type
  WHERE attr.resource_id = p_resource_id
    AND req.validation_rule = 'enum'
    AND NOT (attr.attribute_value = ANY(req.allowed_values));

  -- Return results
  RETURN QUERY SELECT
    (v_missing IS NULL AND v_invalid IS NULL) AS is_valid,
    COALESCE(v_missing, ARRAY[]::VARCHAR[]) AS missing_attributes,
    COALESCE(v_invalid, ARRAY[]::VARCHAR[]) AS invalid_attributes;
END;
$$ LANGUAGE plpgsql;
```

**Usage:**
```sql
SELECT * FROM validate_resource_attributes('{resource-id}');
-- Returns: {is_valid: false, missing_attributes: ['blueprint_url'], invalid_attributes: []}
```

---

## Triggers

### update_updated_at_column()

**Purpose:** Automatically update `updated_at` timestamp on row updates

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER trg_companies_updated_at
  BEFORE UPDATE ON QUAD_companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON QUAD_users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_domains_updated_at
  BEFORE UPDATE ON QUAD_domains
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_resources_updated_at
  BEFORE UPDATE ON QUAD_domain_resources
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_attributes_updated_at
  BEFORE UPDATE ON QUAD_resource_attributes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## Example Queries

### 1. Get All Domains for User

```sql
SELECT d.id, d.name, d.path, dm.role, dm.allocation_percentage
FROM QUAD_domains d
JOIN QUAD_domain_members dm ON dm.domain_id = d.id
WHERE dm.user_id = '{user-id}'
ORDER BY d.path;
```

### 2. Get Resources for Domain (with Attributes)

```sql
SELECT
  r.id,
  r.resource_name,
  r.resource_type,
  r.resource_status,
  jsonb_object_agg(
    a.attribute_name,
    a.attribute_value
  ) AS attributes
FROM QUAD_domain_resources r
LEFT JOIN QUAD_resource_attributes a ON a.resource_id = r.id
WHERE r.domain_id = '{domain-id}'
GROUP BY r.id, r.resource_name, r.resource_type, r.resource_status;
```

**Result:**
```json
{
  "id": "550e8400-...",
  "resource_name": "Claims Dashboard",
  "resource_type": "web_app_project",
  "resource_status": "active",
  "attributes": {
    "project_type": "web_internal",
    "frontend_framework": "nextjs",
    "css_framework": "tailwind",
    "blueprint_url": "https://figma.com/...",
    "git_repo_url": "https://github.com/..."
  }
}
```

### 3. Get Domain Hierarchy (Recursive)

```sql
WITH RECURSIVE domain_tree AS (
  -- Root domains
  SELECT id, name, parent_domain_id, path, 1 AS level
  FROM QUAD_domains
  WHERE parent_domain_id IS NULL

  UNION ALL

  -- Child domains
  SELECT d.id, d.name, d.parent_domain_id, d.path, dt.level + 1
  FROM QUAD_domains d
  JOIN domain_tree dt ON d.parent_domain_id = dt.id
)
SELECT * FROM domain_tree ORDER BY path;
```

### 4. Validate All Resources in Domain

```sql
SELECT
  r.id,
  r.resource_name,
  v.is_valid,
  v.missing_attributes,
  v.invalid_attributes
FROM QUAD_domain_resources r
CROSS JOIN LATERAL validate_resource_attributes(r.id) v
WHERE r.domain_id = '{domain-id}';
```

---

## Migration Files

**Location:** `quadframework/database/migrations/`

```
001_create_resource_attribute_model.sql  ← Current (Dec 31, 2025)
002_add_user_sessions.sql                ← Future
003_add_integration_methods.sql          ← Future
```

**Run Migration:**
```bash
psql -U quad_user -d quad_dev_db -f database/migrations/001_create_resource_attribute_model.sql
```

---

## Database Size Estimates

| Table | Rows (Estimate) | Size per Row | Total Size |
|-------|----------------|--------------|------------|
| QUAD_companies | 100 | 1 KB | 100 KB |
| QUAD_users | 10,000 | 1 KB | 10 MB |
| QUAD_domains | 5,000 | 1 KB | 5 MB |
| QUAD_domain_resources | 50,000 | 1 KB | 50 MB |
| QUAD_resource_attributes | 500,000 | 512 bytes | 250 MB |

**Total Database Size (1 year):** ~500 MB

---

**Next:** See [API_OVERVIEW.md](API_OVERVIEW.md) for complete API documentation.
