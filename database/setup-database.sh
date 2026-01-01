#!/bin/bash

# QUAD Platform - Database Setup Script
# Date: December 31, 2025
# Purpose: Create all tables and seed test data

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}QUAD Platform - Database Setup${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Database connection details
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-16201}"
DB_NAME="${DB_NAME:-nutrinine_dev_db}"
DB_USER="${DB_USER:-nutrinine_user}"
DB_PASS="${DB_PASS:-nutrinine_dev_pass}"

echo -e "${BLUE}Database:${NC} $DB_NAME"
echo -e "${BLUE}Host:${NC} $DB_HOST:$DB_PORT"
echo -e "${BLUE}User:${NC} $DB_USER"
echo ""

# Check if PostgreSQL is accessible
echo -e "${BLUE}Checking database connection...${NC}"
if ! PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
  echo -e "${RED}❌ Cannot connect to database${NC}"
  echo -e "${RED}   Make sure PostgreSQL is running and credentials are correct${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Database connection successful${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run migrations
echo -e "${BLUE}Running migrations...${NC}"
echo ""

# Migration 000: Core tables
echo -e "${BLUE}[1/2] Running migration 000_create_core_tables.sql...${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$SCRIPT_DIR/migrations/000_create_core_tables.sql" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Core tables created${NC}"
else
  echo -e "${RED}❌ Failed to create core tables${NC}"
  exit 1
fi

# Migration 001: Resource/Attribute tables
echo -e "${BLUE}[2/2] Running migration 001_create_resource_attribute_model.sql...${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$SCRIPT_DIR/migrations/001_create_resource_attribute_model.sql" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Resource/Attribute tables created${NC}"
else
  echo -e "${RED}❌ Failed to create resource/attribute tables${NC}"
  exit 1
fi
echo ""

# Seed test data
echo -e "${BLUE}Seeding test data...${NC}"
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$SCRIPT_DIR/seed/seed_test_data.sql"
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Test data seeded successfully${NC}"
else
  echo -e "${RED}❌ Failed to seed test data${NC}"
  exit 1
fi
echo ""

# Verification
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Database Setup Complete!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${GREEN}Test Login Credentials:${NC}"
echo -e "  Email: suman@a2vibecreators.com"
echo -e "  Password: password123"
echo ""
echo -e "${GREEN}Test Data Created:${NC}"
echo -e "  ✅ Company: A2Vibe Creators"
echo -e "  ✅ User: Suman Addanke (QUAD_ADMIN)"
echo -e "  ✅ Domain: /a2vibe-internal/nutrinine"
echo -e "  ✅ Resources: NutriNine iOS, Android, Web Admin"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "  1. Start development server: npm run dev"
echo -e "  2. Test APIs: curl http://localhost:3000/api/..."
echo -e "  3. View docs: http://localhost:3000/docs"
echo ""
