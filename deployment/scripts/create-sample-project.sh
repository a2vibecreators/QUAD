#!/bin/bash
#
# Create Sample Project for QUAD Framework Testing
# Creates: Organization → Domain → Users → Roles → Sample Tickets
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
API_URL="${API_URL:-http://localhost:3000/api}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  QUAD Framework - Sample Project Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  API URL: ${GREEN}${API_URL}${NC}"
echo ""

# Step 1: Register Admin User and Create Organization
echo -e "${YELLOW}📋 Step 1: Registering admin user and creating organization...${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "${API_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@acme-corp.com",
    "password": "Admin123!@#",
    "fullName": "John Admin",
    "orgName": "ACME Corporation"
  }')

TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
ORG_ID=$(echo $REGISTER_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}❌ Failed to register. Response: ${REGISTER_RESPONSE}${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Organization created: ACME Corporation${NC}"
echo -e "   Token: ${TOKEN:0:30}..."
echo ""

# Step 2: Create Domain (Project)
echo -e "${YELLOW}📋 Step 2: Creating project domain...${NC}"
DOMAIN_RESPONSE=$(curl -s -X POST "${API_URL}/domains" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "name": "Mobile Banking App",
    "domain_type": "PROJECT",
    "is_project": true,
    "ticket_prefix": "BANK"
  }')

DOMAIN_ID=$(echo $DOMAIN_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$DOMAIN_ID" ]; then
  echo -e "${RED}❌ Failed to create domain. Response: ${DOMAIN_RESPONSE}${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Project created: Mobile Banking App (BANK-xxx)${NC}"
echo ""

# Step 3: Create Users with Different Roles
echo -e "${YELLOW}📋 Step 3: Creating team members...${NC}"

# Create BA
curl -s -X POST "${API_URL}/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "email": "sarah.ba@acme-corp.com",
    "password": "Test123!@#",
    "full_name": "Sarah Business Analyst",
    "role": "BUSINESS_ANALYST"
  }' > /dev/null

echo -e "   ✅ Created: Sarah (Business Analyst)"

# Create Developer
curl -s -X POST "${API_URL}/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "email": "mike.dev@acme-corp.com",
    "password": "Test123!@#",
    "full_name": "Mike Developer",
    "role": "DEVELOPER"
  }' > /dev/null

echo -e "   ✅ Created: Mike (Developer)"

# Create QA
curl -s -X POST "${API_URL}/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "email": "lisa.qa@acme-corp.com",
    "password": "Test123!@#",
    "full_name": "Lisa QA Engineer",
    "role": "QA_ENGINEER"
  }' > /dev/null

echo -e "   ✅ Created: Lisa (QA Engineer)"

# Create DevOps
curl -s -X POST "${API_URL}/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "email": "dave.ops@acme-corp.com",
    "password": "Test123!@#",
    "full_name": "Dave DevOps",
    "role": "DEVOPS_ENGINEER"
  }' > /dev/null

echo -e "   ✅ Created: Dave (DevOps Engineer)"
echo ""

# Step 4: Create Sample Requirement
echo -e "${YELLOW}📋 Step 4: Creating sample requirement...${NC}"
REQ_RESPONSE=$(curl -s -X POST "${API_URL}/requirements" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"domain_id\": \"${DOMAIN_ID}\",
    \"title\": \"User Login with Face ID\",
    \"description\": \"As a mobile banking user, I want to login using Face ID so that I can quickly and securely access my account.\",
    \"priority\": \"HIGH\",
    \"acceptance_criteria\": \"1. Face ID prompt appears on app launch\\n2. User can enable/disable Face ID in settings\\n3. Fallback to PIN if Face ID fails 3 times\"
  }")

REQ_ID=$(echo $REQ_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
echo -e "${GREEN}✅ Requirement created: User Login with Face ID${NC}"
echo ""

# Step 5: Create Sample Tickets
echo -e "${YELLOW}📋 Step 5: Creating sample tickets...${NC}"

# Ticket 1 - Q stage
curl -s -X POST "${API_URL}/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"domain_id\": \"${DOMAIN_ID}\",
    \"requirement_id\": \"${REQ_ID}\",
    \"title\": \"Implement Face ID authentication\",
    \"description\": \"Integrate iOS Face ID API for biometric authentication\",
    \"priority\": \"HIGH\",
    \"ticket_type\": \"FEATURE\",
    \"quad_stage\": \"Q\",
    \"stage_status\": \"IN_PROGRESS\",
    \"estimated_hours\": 16
  }" > /dev/null

echo -e "   ✅ BANK-1: Implement Face ID authentication (Q stage)"

# Ticket 2 - U stage
curl -s -X POST "${API_URL}/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"domain_id\": \"${DOMAIN_ID}\",
    \"title\": \"Create Face ID settings UI\",
    \"description\": \"Build settings screen to enable/disable Face ID\",
    \"priority\": \"MEDIUM\",
    \"ticket_type\": \"FEATURE\",
    \"quad_stage\": \"U\",
    \"stage_status\": \"READY\",
    \"estimated_hours\": 8
  }" > /dev/null

echo -e "   ✅ BANK-2: Create Face ID settings UI (U stage)"

# Ticket 3 - A stage
curl -s -X POST "${API_URL}/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"domain_id\": \"${DOMAIN_ID}\",
    \"title\": \"Write biometric auth tests\",
    \"description\": \"Unit tests and integration tests for Face ID flow\",
    \"priority\": \"HIGH\",
    \"ticket_type\": \"TASK\",
    \"quad_stage\": \"A\",
    \"stage_status\": \"READY\",
    \"estimated_hours\": 6
  }" > /dev/null

echo -e "   ✅ BANK-3: Write biometric auth tests (A stage)"

# Ticket 4 - D stage
curl -s -X POST "${API_URL}/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"domain_id\": \"${DOMAIN_ID}\",
    \"title\": \"Deploy Face ID to TestFlight\",
    \"description\": \"Deploy biometric auth feature to TestFlight for beta testing\",
    \"priority\": \"HIGH\",
    \"ticket_type\": \"TASK\",
    \"quad_stage\": \"D\",
    \"stage_status\": \"PENDING\",
    \"estimated_hours\": 2
  }" > /dev/null

echo -e "   ✅ BANK-4: Deploy Face ID to TestFlight (D stage)"
echo ""

# Step 6: Create a Cycle (Sprint)
echo -e "${YELLOW}📋 Step 6: Creating sprint cycle...${NC}"
CYCLE_RESPONSE=$(curl -s -X POST "${API_URL}/cycles" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"domain_id\": \"${DOMAIN_ID}\",
    \"cycle_number\": 1,
    \"cycle_name\": \"Sprint 1 - Biometric Auth\",
    \"goal\": \"Implement and deploy Face ID authentication\",
    \"start_date\": \"$(date -v+1d +%Y-%m-%d)\",
    \"end_date\": \"$(date -v+15d +%Y-%m-%d)\"
  }")

echo -e "${GREEN}✅ Sprint created: Sprint 1 - Biometric Auth${NC}"
echo ""

# Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Sample Project Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📊 Created Resources:${NC}"
echo -e "   • Organization: ACME Corporation"
echo -e "   • Project: Mobile Banking App (BANK-xxx)"
echo -e "   • Users: 5 (Admin, BA, Dev, QA, DevOps)"
echo -e "   • Requirement: 1 (Face ID Login)"
echo -e "   • Tickets: 4 (across Q-U-A-D stages)"
echo -e "   • Sprint: Sprint 1 - Biometric Auth"
echo ""
echo -e "${BLUE}🔑 Login Credentials:${NC}"
echo -e "   Admin:   admin@acme-corp.com / Admin123!@#"
echo -e "   BA:      sarah.ba@acme-corp.com / Test123!@#"
echo -e "   Dev:     mike.dev@acme-corp.com / Test123!@#"
echo -e "   QA:      lisa.qa@acme-corp.com / Test123!@#"
echo -e "   DevOps:  dave.ops@acme-corp.com / Test123!@#"
echo ""
echo -e "${YELLOW}🌐 Test the deployment:${NC}"
echo -e "   curl ${API_URL}/domains -H 'Authorization: Bearer ${TOKEN}'"
echo ""
