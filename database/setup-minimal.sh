#!/bin/bash

# QUAD Platform - Minimal Database Setup (No Test Data)
# Date: December 31, 2025
# Purpose: Create tables only, no seed data

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}QUAD Platform - Database Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Database connection
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-16201}"
DB_NAME="${DB_NAME:-nutrinine_dev_db}"
DB_USER="${DB_USER:-nutrinine_user}"
DB_PASS="${DB_PASS:-nutrinine_dev_pass}"

echo -e "${BLUE}Database:${NC} $DB_NAME at $DB_HOST:$DB_PORT"
echo ""

# Check connection
echo -e "${BLUE}Checking database connection...${NC}"
if ! PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
  echo -e "${RED}❌ Cannot connect to database${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Connected${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Migration 000: Core tables
echo -e "${BLUE}[1/2] Creating core tables...${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$SCRIPT_DIR/migrations/000_create_core_tables.sql" > /dev/null 2>&1
echo -e "${GREEN}✅ Core tables created${NC}"

# Migration 001: Resource/Attribute tables
echo -e "${BLUE}[2/3] Creating resource/attribute tables...${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$SCRIPT_DIR/migrations/001_create_resource_attribute_model.sql" > /dev/null 2>&1
echo -e "${GREEN}✅ Resource/Attribute tables created${NC}"

# Migration 002: Multi-tenant Domain & SSO
echo -e "${BLUE}[3/3] Creating multi-tenant domain and SSO tables...${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$SCRIPT_DIR/migrations/002_create_multi_tenant_domain_sso.sql" > /dev/null 2>&1
echo -e "${GREEN}✅ Multi-tenant domain and SSO tables created${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Database Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Tables Created:${NC}"
echo -e "  ${GREEN}Core Tables:${NC}"
echo -e "    • QUAD_companies"
echo -e "    • QUAD_users"
echo -e "    • QUAD_domains"
echo -e "    • QUAD_domain_members"
echo -e "    • QUAD_user_sessions"
echo -e "  ${GREEN}Resource/Attribute Tables:${NC}"
echo -e "    • QUAD_domain_resources"
echo -e "    • QUAD_resource_attributes"
echo -e "    • QUAD_resource_attribute_requirements"
echo -e "  ${GREEN}Multi-Tenant Tables:${NC}"
echo -e "    • company_domains"
echo -e "    • company_sso_configs"
echo -e "    • domain_verification_log"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "  1. Configure Google OAuth in .env"
echo -e "  2. Run: npm run dev"
echo -e "  3. Login with Google"
echo -e "  4. Create NutriNine domain (via UI or SQL)"
echo ""
