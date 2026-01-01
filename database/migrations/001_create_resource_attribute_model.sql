-- Migration 001: Create Resource/Attribute Model for QUAD Platform
-- Date: December 31, 2025
-- Purpose: Implement EAV (Entity-Attribute-Value) pattern for flexible resource configuration
--
-- Design Rationale:
-- - Attributes stored as ROWS (not columns) for unlimited expansion
-- - No schema changes needed when adding new resource types or attributes
-- - display_order controls form field sequence in UI
-- - See: QUAD_OBJECT_MODEL.md for complete architecture

-- ============================================================================
-- TABLE 1: QUAD_domain_resources
-- ============================================================================
-- Purpose: Resources that belong to a domain (projects, integrations, repos)
-- Examples: "Claims Dashboard" (web app), "GitHub Webhook" (integration)

CREATE TABLE IF NOT EXISTS QUAD_domain_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,

  resource_type VARCHAR(50) NOT NULL,
  -- Resource types:
  -- 'web_app_project', 'mobile_app_project', 'api_project', 'landing_page_project'
  -- 'git_repository', 'itsm_integration', 'blueprint', 'sso_config', 'integration_method'

  resource_name VARCHAR(255) NOT NULL,
  resource_status VARCHAR(50) DEFAULT 'pending_setup',
  -- Status: 'pending_setup', 'active', 'inactive', 'archived'

  -- Metadata
  created_by UUID REFERENCES QUAD_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_resources_domain ON QUAD_domain_resources(domain_id);
CREATE INDEX idx_resources_type ON QUAD_domain_resources(resource_type);
CREATE INDEX idx_resources_status ON QUAD_domain_resources(resource_status);
CREATE INDEX idx_resources_domain_type ON QUAD_domain_resources(domain_id, resource_type);

-- Trigger to update updated_at
CREATE TRIGGER trg_resources_updated_at
  BEFORE UPDATE ON QUAD_domain_resources
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLE 2: QUAD_resource_attributes
-- ============================================================================
-- Purpose: Key-value attributes for each resource (EAV pattern)
-- Examples: blueprint_url, tech_stack, git_repo_url, frontend_framework

CREATE TABLE IF NOT EXISTS QUAD_resource_attributes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES QUAD_domain_resources(id) ON DELETE CASCADE,

  attribute_name VARCHAR(50) NOT NULL,
  -- Examples: 'project_type', 'frontend_framework', 'css_framework',
  --           'blueprint_url', 'blueprint_type', 'git_repo_url'

  attribute_value TEXT,
  -- Stored as text, can be JSON for complex values

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Unique constraint: one attribute per resource
  UNIQUE(resource_id, attribute_name)
);

-- Indexes
CREATE INDEX idx_attributes_resource ON QUAD_resource_attributes(resource_id);
CREATE INDEX idx_attributes_name ON QUAD_resource_attributes(attribute_name);
CREATE INDEX idx_attributes_resource_name ON QUAD_resource_attributes(resource_id, attribute_name);

-- Trigger to update updated_at
CREATE TRIGGER trg_attributes_updated_at
  BEFORE UPDATE ON QUAD_resource_attributes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLE 3: QUAD_resource_attribute_requirements
-- ============================================================================
-- Purpose: Define which attributes are required for which resource types
-- Examples: 'blueprint_url' is required for 'web_app_project' but not for 'api_project'

CREATE TABLE IF NOT EXISTS QUAD_resource_attribute_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  resource_type VARCHAR(50) NOT NULL,
  -- 'web_app_project', 'mobile_app_project', 'api_project', 'landing_page_project'

  attribute_name VARCHAR(50) NOT NULL,
  -- 'project_type', 'frontend_framework', 'blueprint_url', etc.

  is_required BOOLEAN DEFAULT false,
  display_order INT,  -- Controls form field sequence (1, 2, 3...)

  validation_rule VARCHAR(50),
  -- 'url', 'enum', 'string', 'integer', 'boolean', 'json'

  allowed_values TEXT[],
  -- For enum validation: ARRAY['nextjs', 'react', 'vue', 'angular']

  help_text TEXT,
  -- Help text displayed in UI

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Unique constraint: one requirement per resource type + attribute
  UNIQUE(resource_type, attribute_name)
);

-- Indexes
CREATE INDEX idx_requirements_type ON QUAD_resource_attribute_requirements(resource_type);
CREATE INDEX idx_requirements_name ON QUAD_resource_attribute_requirements(attribute_name);
CREATE INDEX idx_requirements_type_name ON QUAD_resource_attribute_requirements(resource_type, attribute_name);
CREATE INDEX idx_requirements_required ON QUAD_resource_attribute_requirements(is_required);

-- Trigger to update updated_at
CREATE TRIGGER trg_requirements_updated_at
  BEFORE UPDATE ON QUAD_resource_attribute_requirements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- INITIAL DATA: Attribute Requirements for Web App Projects
-- ============================================================================

INSERT INTO QUAD_resource_attribute_requirements (
  resource_type, attribute_name, is_required, display_order,
  validation_rule, allowed_values, help_text
) VALUES
  -- ========== REQUIRED ATTRIBUTES (display_order 1-10) ==========

  -- Project identification
  ('web_app_project', 'project_type', true, 1, 'enum',
   ARRAY['web_internal', 'web_external'],
   'Is this an internal or external web application?'),

  -- Frontend stack (REQUIRED for UI projects)
  ('web_app_project', 'frontend_framework', true, 2, 'enum',
   ARRAY['nextjs', 'react', 'vue', 'angular', 'svelte'],
   'Select your frontend framework'),

  ('web_app_project', 'css_framework', true, 3, 'enum',
   ARRAY['tailwind', 'bootstrap', 'mui', 'chakra', 'ant-design'],
   'Select your CSS framework'),

  -- Blueprint (REQUIRED for UI projects)
  ('web_app_project', 'blueprint_type', true, 4, 'enum',
   ARRAY['figma_url', 'sketch_url', 'adobe_xd_url', 'competitor_url', 'blueprint_agent', 'wireframe_image'],
   'Type of blueprint you are providing'),

  ('web_app_project', 'blueprint_url', true, 5, 'url',
   NULL,
   'Figma/Sketch URL, competitor website, or generated mockup URL'),

  -- ========== OPTIONAL ATTRIBUTES (display_order 11-20) ==========

  -- Backend stack (OPTIONAL for web apps)
  ('web_app_project', 'backend_framework', false, 11, 'enum',
   ARRAY['nodejs', 'java_spring_boot', 'python_fastapi', 'python_django', 'ruby_rails', 'none'],
   'Select your backend framework (if full-stack)'),

  ('web_app_project', 'database_type', false, 12, 'enum',
   ARRAY['postgresql', 'mysql', 'mongodb', 'sqlite', 'none'],
   'Select your database (optional)'),

  -- Git repository (OPTIONAL but helpful)
  ('web_app_project', 'git_repo_url', false, 13, 'url',
   NULL,
   'URL to existing codebase for style matching (optional)'),

  ('web_app_project', 'git_repo_type', false, 14, 'enum',
   ARRAY['github', 'gitlab', 'bitbucket', 'azure_devops'],
   'Git hosting provider'),

  ('web_app_project', 'git_repo_private', false, 15, 'boolean',
   NULL,
   'Is this a private repository?'),

  ('web_app_project', 'git_access_token_vault_path', false, 16, 'string',
   NULL,
   'Path to access token in Vaultwarden (for private repos)'),

  -- Blueprint metadata
  ('web_app_project', 'blueprint_verified', false, 17, 'boolean',
   NULL,
   'Has the blueprint URL been verified as accessible?'),

  ('web_app_project', 'blueprint_verification_date', false, 18, 'string',
   NULL,
   'Timestamp when blueprint was last verified'),

  ('web_app_project', 'blueprint_screenshot_url', false, 19, 'url',
   NULL,
   'Auto-captured screenshot URL (for competitor websites)'),

  ('web_app_project', 'blueprint_additional_urls', false, 20, 'json',
   NULL,
   'Additional blueprint URLs (e.g., dashboard, login page) as JSON array'),

  -- Blueprint Agent metadata (if AI-generated)
  ('web_app_project', 'blueprint_agent_session_id', false, 21, 'string',
   NULL,
   'Blueprint Agent conversation session ID'),

  ('web_app_project', 'blueprint_agent_answers', false, 22, 'json',
   NULL,
   'Answers to Blueprint Agent questions (JSON)'),

  -- Branding assets (OPTIONAL)
  ('web_app_project', 'branding_logo_url', false, 23, 'url',
   NULL,
   'Company logo URL'),

  ('web_app_project', 'branding_color_primary', false, 24, 'string',
   NULL,
   'Primary brand color (hex code)'),

  ('web_app_project', 'branding_color_secondary', false, 25, 'string',
   NULL,
   'Secondary brand color (hex code)'),

  ('web_app_project', 'branding_font_family', false, 26, 'string',
   NULL,
   'Brand font family'),

  -- Git repo analysis results (cached)
  ('web_app_project', 'git_repo_analyzed', false, 27, 'boolean',
   NULL,
   'Has the Git repo been analyzed?'),

  ('web_app_project', 'git_repo_analysis_result', false, 28, 'json',
   NULL,
   'Cached Git repo analysis results (JSON)');

-- ============================================================================
-- INITIAL DATA: Attribute Requirements for Mobile App Projects
-- ============================================================================

INSERT INTO QUAD_resource_attribute_requirements (
  resource_type, attribute_name, is_required, display_order,
  validation_rule, allowed_values, help_text
) VALUES
  -- Mobile-specific attributes
  ('mobile_app_project', 'project_type', true, 1, 'enum',
   ARRAY['mobile_ios', 'mobile_android', 'mobile_cross_platform'],
   'Target mobile platform'),

  ('mobile_app_project', 'mobile_framework', true, 2, 'enum',
   ARRAY['react_native', 'flutter', 'swift', 'kotlin'],
   'Mobile development framework'),

  -- Blueprint REQUIRED for mobile apps too
  ('mobile_app_project', 'blueprint_type', true, 3, 'enum',
   ARRAY['figma_url', 'sketch_url', 'adobe_xd_url', 'competitor_url', 'blueprint_agent'],
   'Type of mobile app design'),

  ('mobile_app_project', 'blueprint_url', true, 4, 'url',
   NULL,
   'Mobile app design mockup URL'),

  -- Optional mobile-specific
  ('mobile_app_project', 'backend_framework', false, 11, 'enum',
   ARRAY['nodejs', 'java_spring_boot', 'python_fastapi', 'firebase'],
   'Backend API framework'),

  ('mobile_app_project', 'git_repo_url', false, 12, 'url',
   NULL,
   'Existing mobile app codebase (optional)');

-- ============================================================================
-- INITIAL DATA: Attribute Requirements for API Projects
-- ============================================================================

INSERT INTO QUAD_resource_attribute_requirements (
  resource_type, attribute_name, is_required, display_order,
  validation_rule, allowed_values, help_text
) VALUES
  -- API projects have different requirements
  ('api_project', 'project_type', true, 1, 'enum',
   ARRAY['rest_api', 'graphql_api', 'websocket_api'],
   'Type of API to build'),

  ('api_project', 'backend_framework', true, 2, 'enum',
   ARRAY['nodejs', 'java_spring_boot', 'python_fastapi', 'python_django', 'go'],
   'Backend framework for API'),

  ('api_project', 'database_type', false, 11, 'enum',
   ARRAY['postgresql', 'mysql', 'mongodb', 'redis'],
   'Database for API (optional)'),

  -- Blueprint NOT REQUIRED for API projects
  ('api_project', 'blueprint_url', false, 12, 'url',
   NULL,
   'API documentation or Swagger/OpenAPI spec URL (optional)'),

  ('api_project', 'git_repo_url', false, 13, 'url',
   NULL,
   'Existing API codebase (optional)');

-- ============================================================================
-- INITIAL DATA: Attribute Requirements for Landing Page Projects
-- ============================================================================

INSERT INTO QUAD_resource_attribute_requirements (
  resource_type, attribute_name, is_required, display_order,
  validation_rule, allowed_values, help_text
) VALUES
  ('landing_page_project', 'project_type', true, 1, 'enum',
   ARRAY['marketing', 'product_launch', 'event', 'lead_generation'],
   'Purpose of landing page'),

  ('landing_page_project', 'frontend_framework', true, 2, 'enum',
   ARRAY['nextjs', 'astro', 'gatsby', 'webflow'],
   'Landing page framework'),

  -- Blueprint REQUIRED for landing pages
  ('landing_page_project', 'blueprint_type', true, 3, 'enum',
   ARRAY['figma_url', 'sketch_url', 'competitor_url', 'blueprint_agent'],
   'Landing page design'),

  ('landing_page_project', 'blueprint_url', true, 4, 'url',
   NULL,
   'Landing page design mockup URL');

-- ============================================================================
-- HELPER FUNCTION: Get Required Attributes for Resource Type
-- ============================================================================

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

-- ============================================================================
-- HELPER FUNCTION: Validate Resource Attributes
-- ============================================================================

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

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE QUAD_domain_resources IS 'Resources belonging to domains (projects, integrations, repos). Uses EAV pattern for flexible configuration.';
COMMENT ON TABLE QUAD_resource_attributes IS 'Key-value attributes for resources. Stores blueprint URLs, tech stack, Git repos, etc. as rows (not columns).';
COMMENT ON TABLE QUAD_resource_attribute_requirements IS 'Defines which attributes are required for which resource types. Controls form validation and display order.';

COMMENT ON FUNCTION get_required_attributes IS 'Returns required attributes for a given resource type, ordered by display_order for UI rendering.';
COMMENT ON FUNCTION validate_resource_attributes IS 'Validates that a resource has all required attributes with valid values.';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

-- Verification queries (commented out - run manually if needed):
-- SELECT * FROM QUAD_resource_attribute_requirements WHERE resource_type = 'web_app_project' ORDER BY display_order;
-- SELECT * FROM get_required_attributes('web_app_project');
-- SELECT * FROM validate_resource_attributes('some-uuid');
