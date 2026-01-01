-- ============================================================================
-- Migration 002: Multi-Tenant Domain & SSO Configuration
-- Date: December 31, 2025
-- Purpose: Enable client custom domains with per-company SSO
-- ============================================================================

-- ============================================================================
-- 1. Company Custom Domains Table
-- ============================================================================
-- Allows each company to use their own domain (e.g., app.acmecorp.com)
-- instead of subdomain on QUAD platform (e.g., acmecorp.quadframe.work)

CREATE TABLE IF NOT EXISTS company_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_companies(id) ON DELETE CASCADE,
  domain VARCHAR(255) UNIQUE NOT NULL,  -- 'app.acmecorp.com'
  is_primary BOOLEAN DEFAULT false,      -- Each company can have one primary domain
  verified BOOLEAN DEFAULT false,        -- DNS verification status
  dns_verification_token VARCHAR(100),   -- TXT record value for verification
  ssl_status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'active', 'failed'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure only one primary domain per company
  CONSTRAINT unique_primary_domain UNIQUE (company_id, is_primary)
    WHERE is_primary = true
);

CREATE INDEX idx_company_domains_company_id ON company_domains(company_id);
CREATE INDEX idx_company_domains_domain ON company_domains(domain);
CREATE INDEX idx_company_domains_verified ON company_domains(verified);

COMMENT ON TABLE company_domains IS 'Custom domains for companies to host QUAD on their own domain';
COMMENT ON COLUMN company_domains.domain IS 'FQDN like app.acmecorp.com';
COMMENT ON COLUMN company_domains.dns_verification_token IS 'Random token for DNS TXT record verification';

-- ============================================================================
-- 2. Company SSO Configuration Table
-- ============================================================================
-- Stores per-company SSO provider credentials
-- Secrets stored in Vaultwarden, only vault path stored here

CREATE TABLE IF NOT EXISTS company_sso_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES QUAD_companies(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL,  -- 'okta', 'azure-ad', 'google', 'auth0', 'oidc'
  provider_name VARCHAR(100),     -- Display name: 'Acme Corp SSO'

  -- OAuth/OIDC Configuration
  client_id VARCHAR(255) NOT NULL,
  client_secret_vault_path VARCHAR(255),  -- 'company/{company_id}/sso/{provider}'
  issuer_url VARCHAR(500),                -- https://acmecorp.okta.com
  authorization_url VARCHAR(500),
  token_url VARCHAR(500),
  userinfo_url VARCHAR(500),

  -- SAML Configuration (if needed in future)
  saml_entity_id VARCHAR(500),
  saml_sso_url VARCHAR(500),
  saml_certificate_vault_path VARCHAR(255),

  -- Settings
  enabled BOOLEAN DEFAULT true,
  auto_provision_users BOOLEAN DEFAULT true,  -- Auto-create users on first login
  default_role VARCHAR(50) DEFAULT 'DEVELOPER',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Each company can only have one config per provider
  UNIQUE(company_id, provider)
);

CREATE INDEX idx_company_sso_configs_company_id ON company_sso_configs(company_id);
CREATE INDEX idx_company_sso_configs_enabled ON company_sso_configs(enabled);

COMMENT ON TABLE company_sso_configs IS 'Per-company SSO provider configurations';
COMMENT ON COLUMN company_sso_configs.client_secret_vault_path IS 'Path in Vaultwarden: company/{company_id}/sso/{provider}';
COMMENT ON COLUMN company_sso_configs.auto_provision_users IS 'Create user on first SSO login if they match company email domain';

-- ============================================================================
-- 3. Domain Verification Audit Log
-- ============================================================================
-- Track domain verification attempts

CREATE TABLE IF NOT EXISTS domain_verification_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES company_domains(id) ON DELETE CASCADE,
  verification_type VARCHAR(50) NOT NULL,  -- 'dns_txt', 'http_file', 'cname'
  verification_status VARCHAR(50) NOT NULL,  -- 'success', 'failed'
  verification_details JSONB,  -- Diagnostic info
  verified_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_domain_verification_log_domain_id ON domain_verification_log(domain_id);

-- ============================================================================
-- 4. Helper Function: Generate DNS Verification Token
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_dns_verification_token()
RETURNS VARCHAR(100) AS $$
BEGIN
  RETURN 'quad-verify-' || encode(gen_random_bytes(16), 'hex');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. Trigger: Auto-generate DNS verification token
-- ============================================================================

CREATE OR REPLACE FUNCTION trigger_generate_dns_token()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.dns_verification_token IS NULL THEN
    NEW.dns_verification_token := generate_dns_verification_token();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_company_domains_verification_token
  BEFORE INSERT ON company_domains
  FOR EACH ROW
  EXECUTE FUNCTION trigger_generate_dns_token();

-- ============================================================================
-- 6. Trigger: Updated_at timestamps
-- ============================================================================

CREATE TRIGGER trg_company_domains_updated_at
  BEFORE UPDATE ON company_domains
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_company_sso_configs_updated_at
  BEFORE UPDATE ON company_sso_configs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 7. Default Platform Domains (QUAD's own domains)
-- ============================================================================
-- For companies that don't have custom domains, they use QUAD subdomains

INSERT INTO company_domains (company_id, domain, is_primary, verified, ssl_status)
SELECT
  c.id,
  LOWER(REPLACE(c.name, ' ', '-')) || '.quadframe.work',
  true,
  true,
  'active'
FROM QUAD_companies c
WHERE NOT EXISTS (
  SELECT 1 FROM company_domains cd WHERE cd.company_id = c.id
)
ON CONFLICT (domain) DO NOTHING;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- View all company domains
SELECT
  c.name AS company,
  cd.domain,
  cd.is_primary,
  cd.verified,
  cd.ssl_status,
  cd.dns_verification_token
FROM company_domains cd
JOIN QUAD_companies c ON c.id = cd.company_id
ORDER BY c.name, cd.is_primary DESC;

-- View all SSO configurations
SELECT
  c.name AS company,
  sso.provider,
  sso.provider_name,
  sso.issuer_url,
  sso.enabled
FROM company_sso_configs sso
JOIN QUAD_companies c ON c.id = sso.company_id
ORDER BY c.name, sso.provider;
