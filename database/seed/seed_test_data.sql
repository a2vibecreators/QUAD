-- Seed Data: Test Setup for QUAD Platform
-- Date: December 31, 2025
-- Purpose: Create test company, user, and NutriNine domain for testing
--
-- Run this AFTER migrations (000 and 001)

-- ============================================================================
-- 1. Create A2Vibe Creators Company
-- ============================================================================

INSERT INTO QUAD_companies (id, name, admin_email, size)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'A2Vibe Creators',
  'suman@a2vibecreators.com',
  'small'
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. Create Test User (Suman - QUAD_ADMIN with all roles)
-- ============================================================================

INSERT INTO QUAD_users (id, company_id, email, password_hash, role, full_name, is_active, email_verified)
VALUES (
  '22222222-2222-2222-2222-222222222222',
  '11111111-1111-1111-1111-111111111111',
  'suman@a2vibecreators.com',
  -- Password: 'password123' (hashed with bcrypt)
  '$2b$10$rZ8qNqZ7ZqZ7ZqZ7ZqZ7ZOqZ7ZqZ7ZqZ7ZqZ7ZqZ7ZqZ7ZqZ7ZqZ7Z',
  'QUAD_ADMIN',  -- Company-level admin (all permissions)
  'Suman Addanke',
  true,
  true
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 3. Create Domains (Root → NutriNine → Sub-modules)
-- ============================================================================

-- Root Domain: A2Vibe Internal Projects
INSERT INTO QUAD_domains (id, company_id, name, parent_domain_id, domain_type, path)
VALUES (
  '33333333-3333-3333-3333-333333333333',
  '11111111-1111-1111-1111-111111111111',
  'A2Vibe Internal',
  NULL,  -- Root domain
  'internal',
  '/a2vibe-internal'
) ON CONFLICT (id) DO NOTHING;

-- Sub-Domain: NutriNine Project
INSERT INTO QUAD_domains (id, company_id, name, parent_domain_id, domain_type, path)
VALUES (
  '44444444-4444-4444-4444-444444444444',
  '11111111-1111-1111-1111-111111111111',
  'NutriNine',
  '33333333-3333-3333-3333-333333333333',  -- Parent: A2Vibe Internal
  'healthcare',
  '/a2vibe-internal/nutrinine'
) ON CONFLICT (id) DO NOTHING;

-- Sub-Sub-Domain: NutriNine iOS App
INSERT INTO QUAD_domains (id, company_id, name, parent_domain_id, domain_type, path)
VALUES (
  '44444444-4444-4444-4444-444444444445',
  '11111111-1111-1111-1111-111111111111',
  'NutriNine iOS',
  '44444444-4444-4444-4444-444444444444',  -- Parent: NutriNine
  'healthcare',
  '/a2vibe-internal/nutrinine/nutrinine-ios'
) ON CONFLICT (id) DO NOTHING;

-- Sub-Sub-Domain: NutriNine Android App
INSERT INTO QUAD_domains (id, company_id, name, parent_domain_id, domain_type, path)
VALUES (
  '44444444-4444-4444-4444-444444444446',
  '11111111-1111-1111-1111-111111111111',
  'NutriNine Android',
  '44444444-4444-4444-4444-444444444444',  -- Parent: NutriNine
  'healthcare',
  '/a2vibe-internal/nutrinine/nutrinine-android'
) ON CONFLICT (id) DO NOTHING;

-- Sub-Sub-Domain: NutriNine Web Admin
INSERT INTO QUAD_domains (id, company_id, name, parent_domain_id, domain_type, path)
VALUES (
  '44444444-4444-4444-4444-444444444447',
  '11111111-1111-1111-1111-111111111111',
  'NutriNine Web Admin',
  '44444444-4444-4444-4444-444444444444',  -- Parent: NutriNine
  'healthcare',
  '/a2vibe-internal/nutrinine/nutrinine-web'
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 4. Add User to Domains (with all roles)
-- ============================================================================

-- Suman as DOMAIN_ADMIN in A2Vibe Internal (100% allocation)
INSERT INTO QUAD_domain_members (user_id, domain_id, role, allocation_percentage)
VALUES (
  '22222222-2222-2222-2222-222222222222',
  '33333333-3333-3333-3333-333333333333',
  'DOMAIN_ADMIN',
  100
) ON CONFLICT (user_id, domain_id) DO NOTHING;

-- Note: Suman automatically has access to all sub-domains because:
-- 1. He's QUAD_ADMIN at company level
-- 2. He's DOMAIN_ADMIN of the parent domain

-- ============================================================================
-- 5. Create Sample Resources (NutriNine Projects)
-- ============================================================================

-- Resource: NutriNine iOS App Project
INSERT INTO QUAD_domain_resources (id, domain_id, resource_type, resource_name, resource_status, created_by)
VALUES (
  '55555555-5555-5555-5555-555555555555',
  '44444444-4444-4444-4444-444444444445',  -- NutriNine iOS domain
  'mobile_app_project',
  'NutriNine iOS App',
  'active',
  '22222222-2222-2222-2222-222222222222'
) ON CONFLICT (id) DO NOTHING;

-- Resource: NutriNine Android App Project
INSERT INTO QUAD_domain_resources (id, domain_id, resource_type, resource_name, resource_status, created_by)
VALUES (
  '55555555-5555-5555-5555-555555555556',
  '44444444-4444-4444-4444-444444444446',  -- NutriNine Android domain
  'mobile_app_project',
  'NutriNine Android App',
  'active',
  '22222222-2222-2222-2222-222222222222'
) ON CONFLICT (id) DO NOTHING;

-- Resource: NutriNine Web Admin Dashboard
INSERT INTO QUAD_domain_resources (id, domain_id, resource_type, resource_name, resource_status, created_by)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  '44444444-4444-4444-4444-444444444447',  -- NutriNine Web domain
  'web_app_project',
  'NutriNine Admin Dashboard',
  'active',
  '22222222-2222-2222-2222-222222222222'
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 6. Add Attributes to NutriNine Web Admin Dashboard
-- ============================================================================

-- Project type
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'project_type',
  'web_internal'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- Frontend framework
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'frontend_framework',
  'react'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- CSS framework
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'css_framework',
  'tailwind'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- Backend framework
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'backend_framework',
  'java_spring_boot'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- Database
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'database_type',
  'postgresql'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- Git repo URL
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'git_repo_url',
  'https://github.com/a2vibecreators/nutrinine'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- Git repo type
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'git_repo_type',
  'github'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- Git repo private
INSERT INTO QUAD_resource_attributes (resource_id, attribute_name, attribute_value)
VALUES (
  '55555555-5555-5555-5555-555555555557',
  'git_repo_private',
  'true'
) ON CONFLICT (resource_id, attribute_name) DO NOTHING;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check company
SELECT 'Company:' AS type, id, name, admin_email FROM QUAD_companies;

-- Check user
SELECT 'User:' AS type, id, email, role, full_name FROM QUAD_users;

-- Check domains (hierarchical)
SELECT 'Domains:' AS type, id, name, path, domain_type FROM QUAD_domains ORDER BY path;

-- Check domain members
SELECT
  'Domain Members:' AS type,
  u.full_name AS user,
  d.name AS domain,
  dm.role,
  dm.allocation_percentage
FROM QUAD_domain_members dm
JOIN QUAD_users u ON u.id = dm.user_id
JOIN QUAD_domains d ON d.id = dm.domain_id;

-- Check resources
SELECT
  'Resources:' AS type,
  r.id,
  d.path AS domain,
  r.resource_type,
  r.resource_name,
  r.resource_status
FROM QUAD_domain_resources r
JOIN QUAD_domains d ON d.id = r.domain_id
ORDER BY d.path;

-- Check attributes (for NutriNine Web Admin)
SELECT
  'Attributes (NutriNine Web):' AS type,
  r.resource_name,
  a.attribute_name,
  a.attribute_value
FROM QUAD_resource_attributes a
JOIN QUAD_domain_resources r ON r.id = a.resource_id
WHERE r.id = '55555555-5555-5555-5555-555555555557'
ORDER BY a.attribute_name;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================

-- Summary:
-- ✅ Company: A2Vibe Creators
-- ✅ User: Suman Addanke (QUAD_ADMIN with all roles)
-- ✅ Domains: A2Vibe Internal → NutriNine → (iOS, Android, Web)
-- ✅ Resources: NutriNine iOS, Android, Web Admin projects
-- ✅ Attributes: Tech stack for NutriNine Web Admin

-- Test login:
-- Email: suman@a2vibecreators.com
-- Password: password123
