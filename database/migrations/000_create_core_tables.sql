-- Migration 000: Create Core Tables for QUAD Platform
-- Date: December 31, 2025
-- Purpose: Create companies, users, domains, and domain members tables
--
-- Run this BEFORE 001_create_resource_attribute_model.sql

-- ============================================================================
-- HELPER FUNCTION: update_updated_at_column
-- ============================================================================
-- Purpose: Automatically update updated_at timestamp on row updates

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TABLE 1: QUAD_companies
-- ============================================================================
-- Purpose: Top-level customer organizations

CREATE TABLE IF NOT EXISTS QUAD_companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  admin_email VARCHAR(255) NOT NULL UNIQUE,
  size VARCHAR(50) DEFAULT 'medium',  -- 'small', 'medium', 'large', 'enterprise'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_companies_admin_email ON QUAD_companies(admin_email);

CREATE TRIGGER trg_companies_updated_at
  BEFORE UPDATE ON QUAD_companies
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE QUAD_companies IS 'Top-level customer organizations (A2Vibe Creators, MassMutual, etc.)';

-- ============================================================================
-- TABLE 2: QUAD_users
-- ============================================================================
-- Purpose: User accounts with email/password authentication

CREATE TABLE IF NOT EXISTS QUAD_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_companies(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'DEVELOPER',
  -- Roles: 'QUAD_ADMIN', 'DOMAIN_ADMIN', 'SUBDOMAIN_ADMIN', 'DEVELOPER', 'QA', 'VIEWER'

  full_name VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_company ON QUAD_users(company_id);
CREATE INDEX idx_users_email ON QUAD_users(email);
CREATE INDEX idx_users_role ON QUAD_users(role);

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON QUAD_users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE QUAD_users IS 'User accounts with email/password authentication';

-- ============================================================================
-- TABLE 3: QUAD_domains
-- ============================================================================
-- Purpose: Organizational units (hierarchical)

CREATE TABLE IF NOT EXISTS QUAD_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  parent_domain_id UUID REFERENCES QUAD_domains(id) ON DELETE CASCADE,
  -- NULL = root domain, UUID = sub-domain

  domain_type VARCHAR(50),
  -- Types: 'healthcare', 'finance', 'e_commerce', 'saas', 'internal', 'client_project'

  path TEXT,
  -- Auto-generated hierarchical path: '/a2vibe/nutrinine' or '/massmutual/insurance/claims'

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_domains_company ON QUAD_domains(company_id);
CREATE INDEX idx_domains_parent ON QUAD_domains(parent_domain_id);
CREATE INDEX idx_domains_type ON QUAD_domains(domain_type);
CREATE INDEX idx_domains_path ON QUAD_domains(path);

CREATE TRIGGER trg_domains_updated_at
  BEFORE UPDATE ON QUAD_domains
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE QUAD_domains IS 'Organizational units (hierarchical). Root domain: parent_domain_id = NULL';

-- ============================================================================
-- TABLE 4: QUAD_domain_members
-- ============================================================================
-- Purpose: User membership in domains with roles and allocation

CREATE TABLE IF NOT EXISTS QUAD_domain_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,

  role VARCHAR(50) NOT NULL,
  -- Roles: 'DOMAIN_ADMIN', 'SUBDOMAIN_ADMIN', 'DEVELOPER', 'QA', 'VIEWER'
  -- Note: QUAD_ADMIN is company-level (in QUAD_users.role)

  allocation_percentage INT DEFAULT 100,
  -- 50 = working 50% time on this domain, 100 = full-time

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(user_id, domain_id)
);

CREATE INDEX idx_domain_members_user ON QUAD_domain_members(user_id);
CREATE INDEX idx_domain_members_domain ON QUAD_domain_members(domain_id);
CREATE INDEX idx_domain_members_role ON QUAD_domain_members(role);

CREATE TRIGGER trg_domain_members_updated_at
  BEFORE UPDATE ON QUAD_domain_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE QUAD_domain_members IS 'User membership in domains with roles. One user can have different roles in different domains.';

-- ============================================================================
-- TABLE 5: QUAD_user_sessions
-- ============================================================================
-- Purpose: Track active login sessions (for NextAuth.js)

CREATE TABLE IF NOT EXISTS QUAD_user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES QUAD_users(id) ON DELETE CASCADE,
  session_token VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,

  ip_address VARCHAR(50),
  user_agent TEXT,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sessions_user ON QUAD_user_sessions(user_id);
CREATE INDEX idx_sessions_token ON QUAD_user_sessions(session_token);
CREATE INDEX idx_sessions_expires ON QUAD_user_sessions(expires_at);

CREATE TRIGGER trg_sessions_updated_at
  BEFORE UPDATE ON QUAD_user_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE QUAD_user_sessions IS 'Active login sessions for JWT token management';

-- ============================================================================
-- HELPER FUNCTION: generate_domain_path
-- ============================================================================
-- Purpose: Auto-generate hierarchical path for domains

CREATE OR REPLACE FUNCTION generate_domain_path()
RETURNS TRIGGER AS $$
DECLARE
  parent_path TEXT;
  domain_slug TEXT;
BEGIN
  -- Generate URL-friendly slug from domain name
  domain_slug := LOWER(REGEXP_REPLACE(NEW.name, '[^a-zA-Z0-9]+', '-', 'g'));

  -- If root domain (no parent)
  IF NEW.parent_domain_id IS NULL THEN
    NEW.path := '/' || domain_slug;
  ELSE
    -- Get parent path
    SELECT path INTO parent_path
    FROM QUAD_domains
    WHERE id = NEW.parent_domain_id;

    -- Append to parent path
    NEW.path := parent_path || '/' || domain_slug;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to auto-generate path
CREATE TRIGGER trg_domains_generate_path
  BEFORE INSERT OR UPDATE ON QUAD_domains
  FOR EACH ROW
  EXECUTE FUNCTION generate_domain_path();

-- ============================================================================
-- HELPER FUNCTION: check_allocation_total
-- ============================================================================
-- Purpose: Ensure user's total allocation across all domains <= 100%

CREATE OR REPLACE FUNCTION check_allocation_total()
RETURNS TRIGGER AS $$
DECLARE
  total_allocation INT;
BEGIN
  -- Calculate total allocation for this user across all domains
  SELECT COALESCE(SUM(allocation_percentage), 0)
  INTO total_allocation
  FROM QUAD_domain_members
  WHERE user_id = NEW.user_id
    AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID);

  -- Add current allocation
  total_allocation := total_allocation + NEW.allocation_percentage;

  -- Check if exceeds 100%
  IF total_allocation > 100 THEN
    RAISE EXCEPTION 'User allocation cannot exceed 100%%. Current total: %', total_allocation;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to validate allocation
CREATE TRIGGER trg_domain_members_check_allocation
  BEFORE INSERT OR UPDATE ON QUAD_domain_members
  FOR EACH ROW
  EXECUTE FUNCTION check_allocation_total();

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON COLUMN QUAD_companies.size IS 'Company size: small (1-10), medium (11-50), large (51-200), enterprise (200+)';
COMMENT ON COLUMN QUAD_users.role IS 'Company-level role. Domain-specific roles are in QUAD_domain_members.';
COMMENT ON COLUMN QUAD_domains.path IS 'Auto-generated hierarchical path like /a2vibe/nutrinine or /massmutual/insurance/claims';
COMMENT ON COLUMN QUAD_domain_members.allocation_percentage IS 'Percentage of time user works on this domain (must total <= 100% across all domains)';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

-- Verification queries (commented out - run manually if needed):
-- SELECT * FROM QUAD_companies;
-- SELECT * FROM QUAD_users;
-- SELECT * FROM QUAD_domains ORDER BY path;
-- SELECT * FROM QUAD_domain_members;
