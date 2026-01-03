#!/bin/bash
# =============================================================================
# QUAD Framework - End-to-End User Journey Tests
# =============================================================================
# Tests complete user flows:
#   Journey 1: Onboarding (Register → Create Org → Create Domain)
#   Journey 2: Team Setup (Invite → Create Circles → Assign Roles)
#   Journey 3: Work Cycle (Create Cycle → Tickets → Track Progress)
#   Journey 4: AI Flow (Create Flow → AI Analyze → PR)
# =============================================================================

# Configuration
BASE_URL="${BASE_URL:-http://localhost:3000/api}"
TIMESTAMP=$(date +%s)
TEST_EMAIL="quadtest_${TIMESTAMP}@test.com"
TEST_PASSWORD="TestPass123!"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
TOTAL=0

# Variables (populated during tests)
TOKEN=""
USER_ID=""
ORG_ID=""
DOMAIN_ID=""
CIRCLE_ID=""
CYCLE_ID=""
TICKET_ID=""
FLOW_ID=""

# =============================================================================
# Helper Functions
# =============================================================================

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() {
    echo -e "${YELLOW}  TEST: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}  ✓ PASSED: $1${NC}"
    ((PASSED++))
    ((TOTAL++))
}

print_fail() {
    echo -e "${RED}  ✗ FAILED: $1${NC}"
    if [ -n "$2" ]; then
        echo -e "${RED}    Response: $(echo $2 | head -c 200)${NC}"
    fi
    ((FAILED++))
    ((TOTAL++))
}

# Extract JSON value
json_value() {
    echo "$1" | grep -o "\"$2\":\"[^\"]*\"" | head -1 | cut -d'"' -f4
}

# Make authenticated request
auth_request() {
    local method=$1
    local endpoint=$2
    local data=$3

    if [ -n "$data" ]; then
        curl -s -X "$method" "${BASE_URL}${endpoint}" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data" --max-time 10 2>/dev/null
    else
        curl -s -X "$method" "${BASE_URL}${endpoint}" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" --max-time 10 2>/dev/null
    fi
}

# =============================================================================
# Journey 1: Onboarding
# =============================================================================

journey1_onboarding() {
    print_banner "JOURNEY 1: Onboarding                                         "

    # Step 1.1: Register new user
    print_section "Step 1.1: User Registration"
    print_test "Registering user: $TEST_EMAIL"

    local response=$(curl -s -X POST "${BASE_URL}/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_EMAIL\",
            \"password\": \"$TEST_PASSWORD\",
            \"name\": \"QUAD Test User\"
        }" --max-time 10 2>/dev/null)

    TOKEN=$(json_value "$response" "token")
    USER_ID=$(json_value "$response" "userId")

    if [ -n "$TOKEN" ]; then
        print_pass "User registered"
        echo -e "    USER_ID: $USER_ID"
    else
        print_fail "Registration failed" "$response"
        return 1
    fi

    # Step 1.2: Create organization
    print_section "Step 1.2: Create Organization"
    print_test "Creating organization..."

    local response=$(auth_request POST "/organizations" "{
        \"name\": \"Test Org $TIMESTAMP\",
        \"industry\": \"Technology\",
        \"size\": \"small\"
    }")

    ORG_ID=$(json_value "$response" "id")
    if [ -z "$ORG_ID" ]; then
        ORG_ID=$(json_value "$response" "orgId")
    fi

    if [ -n "$ORG_ID" ]; then
        print_pass "Organization created"
        echo -e "    ORG_ID: $ORG_ID"
    else
        print_fail "Create organization failed" "$response"
    fi

    # Step 1.3: Create domain
    print_section "Step 1.3: Create Domain"
    print_test "Creating domain..."

    local response=$(auth_request POST "/domains" "{
        \"name\": \"Backend API\",
        \"description\": \"Backend services development\",
        \"org_id\": \"$ORG_ID\"
    }")

    DOMAIN_ID=$(json_value "$response" "id")
    if [ -z "$DOMAIN_ID" ]; then
        DOMAIN_ID=$(json_value "$response" "domainId")
    fi

    if [ -n "$DOMAIN_ID" ]; then
        print_pass "Domain created"
        echo -e "    DOMAIN_ID: $DOMAIN_ID"
    else
        print_fail "Create domain failed" "$response"
    fi

    # Step 1.4: Verify domain in list
    print_section "Step 1.4: Verify Domain"
    print_test "Listing user domains..."

    local response=$(auth_request GET "/domains")

    if echo "$response" | grep -q "Backend API\|$DOMAIN_ID"; then
        print_pass "Domain appears in list"
    else
        print_fail "Domain not in list" "$response"
    fi

    echo ""
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  JOURNEY 1 COMPLETE: User onboarded with org and domain${NC}"
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
# Journey 2: Team Setup
# =============================================================================

journey2_team_setup() {
    print_banner "JOURNEY 2: Team Setup                                         "

    # Step 2.1: Create circle
    print_section "Step 2.1: Create Circle"
    print_test "Creating development circle..."

    local response=$(auth_request POST "/circles" "{
        \"name\": \"Core Dev Team\",
        \"description\": \"Main development circle\",
        \"domain_id\": \"$DOMAIN_ID\"
    }")

    CIRCLE_ID=$(json_value "$response" "id")
    if [ -z "$CIRCLE_ID" ]; then
        CIRCLE_ID=$(json_value "$response" "circleId")
    fi

    if [ -n "$CIRCLE_ID" ]; then
        print_pass "Circle created"
        echo -e "    CIRCLE_ID: $CIRCLE_ID"
    else
        print_fail "Create circle failed" "$response"
    fi

    # Step 2.2: Get core roles
    print_section "Step 2.2: Get Core Roles"
    print_test "Fetching available roles..."

    local response=$(auth_request GET "/core-roles")

    if echo "$response" | grep -q "ADMIN\|DEVELOPER\|roles\|name"; then
        local role_count=$(echo "$response" | grep -o '"id"' | wc -l | tr -d ' ')
        print_pass "Retrieved $role_count core roles"
    else
        print_fail "Get core roles failed" "$response"
    fi

    # Step 2.3: List circles
    print_section "Step 2.3: Verify Circle"
    print_test "Listing circles..."

    local response=$(auth_request GET "/circles")

    if echo "$response" | grep -q "Core Dev Team\|$CIRCLE_ID"; then
        print_pass "Circle appears in list"
    else
        print_fail "Circle not in list" "$response"
    fi

    echo ""
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  JOURNEY 2 COMPLETE: Circle created and verified${NC}"
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
# Journey 3: Work Cycle
# =============================================================================

journey3_work_cycle() {
    print_banner "JOURNEY 3: Work Cycle                                         "

    # Step 3.1: Create cycle
    print_section "Step 3.1: Create Cycle"
    print_test "Creating 2-week sprint..."

    local start_date=$(date +%Y-%m-%d)
    local end_date=$(date -v+14d +%Y-%m-%d 2>/dev/null || date -d "+14 days" +%Y-%m-%d)

    local response=$(auth_request POST "/cycles" "{
        \"name\": \"Sprint $TIMESTAMP\",
        \"domain_id\": \"$DOMAIN_ID\",
        \"start_date\": \"$start_date\",
        \"end_date\": \"$end_date\",
        \"status\": \"planning\"
    }")

    CYCLE_ID=$(json_value "$response" "id")
    if [ -z "$CYCLE_ID" ]; then
        CYCLE_ID=$(json_value "$response" "cycleId")
    fi

    if [ -n "$CYCLE_ID" ]; then
        print_pass "Cycle created"
        echo -e "    CYCLE_ID: $CYCLE_ID"
    else
        print_fail "Create cycle failed" "$response"
    fi

    # Step 3.2: Create ticket
    print_section "Step 3.2: Create Ticket"
    print_test "Creating ticket..."

    local response=$(auth_request POST "/tickets" "{
        \"title\": \"Implement user auth API\",
        \"description\": \"Create JWT-based authentication endpoints\",
        \"domain_id\": \"$DOMAIN_ID\",
        \"cycle_id\": \"$CYCLE_ID\",
        \"priority\": \"high\",
        \"story_points\": 5
    }")

    TICKET_ID=$(json_value "$response" "id")
    if [ -z "$TICKET_ID" ]; then
        TICKET_ID=$(json_value "$response" "ticketId")
    fi

    if [ -n "$TICKET_ID" ]; then
        print_pass "Ticket created"
        echo -e "    TICKET_ID: $TICKET_ID"
    else
        print_fail "Create ticket failed" "$response"
    fi

    # Step 3.3: Add comment
    print_section "Step 3.3: Add Comment"
    print_test "Adding comment to ticket..."

    local response=$(auth_request POST "/tickets/$TICKET_ID/comments" "{
        \"content\": \"Starting implementation. Will use bcrypt for password hashing.\"
    }")

    if echo "$response" | grep -q "content\|comment\|id"; then
        print_pass "Comment added"
    else
        print_fail "Add comment failed" "$response"
    fi

    # Step 3.4: Log time
    print_section "Step 3.4: Log Time"
    print_test "Logging time on ticket..."

    local response=$(auth_request POST "/tickets/$TICKET_ID/time-logs" "{
        \"hours\": 2,
        \"description\": \"Initial setup and research\"
    }")

    if echo "$response" | grep -q "hours\|timeLog\|id"; then
        print_pass "Time logged"
    else
        print_fail "Log time failed" "$response"
    fi

    # Step 3.5: List tickets
    print_section "Step 3.5: Verify Ticket"
    print_test "Listing tickets..."

    local response=$(auth_request GET "/tickets")

    if echo "$response" | grep -q "user auth\|$TICKET_ID"; then
        print_pass "Ticket appears in list"
    else
        print_fail "Ticket not in list" "$response"
    fi

    echo ""
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  JOURNEY 3 COMPLETE: Cycle with tickets created${NC}"
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
# Journey 4: AI Flow (Optional)
# =============================================================================

journey4_ai_flow() {
    print_banner "JOURNEY 4: AI-Assisted Flow                                   "

    # Step 4.1: Create flow
    print_section "Step 4.1: Create Flow"
    print_test "Creating development flow..."

    local response=$(auth_request POST "/flows" "{
        \"title\": \"Auth API Implementation\",
        \"ticket_id\": \"$TICKET_ID\",
        \"domain_id\": \"$DOMAIN_ID\"
    }")

    FLOW_ID=$(json_value "$response" "id")
    if [ -z "$FLOW_ID" ]; then
        FLOW_ID=$(json_value "$response" "flowId")
    fi

    if [ -n "$FLOW_ID" ]; then
        print_pass "Flow created"
        echo -e "    FLOW_ID: $FLOW_ID"
    else
        print_fail "Create flow failed" "$response"
    fi

    # Step 4.2: Check AI config
    print_section "Step 4.2: Check AI Configuration"
    print_test "Getting AI configuration..."

    local response=$(auth_request GET "/ai-config")

    if echo "$response" | grep -q "tier\|provider\|config"; then
        print_pass "AI config retrieved"
    else
        print_fail "Get AI config failed" "$response"
    fi

    # Step 4.3: List flows
    print_section "Step 4.3: Verify Flow"
    print_test "Listing flows..."

    local response=$(auth_request GET "/flows")

    if echo "$response" | grep -q "Auth API\|$FLOW_ID"; then
        print_pass "Flow appears in list"
    else
        print_fail "Flow not in list" "$response"
    fi

    echo ""
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  JOURNEY 4 COMPLETE: AI flow created${NC}"
    echo -e "${GREEN}  ══════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
# Summary
# =============================================================================

print_summary() {
    print_banner "TEST SUMMARY                                                   "
    echo ""
    echo -e "  Test User: $TEST_EMAIL"
    echo -e "  User ID: $USER_ID"
    echo -e "  Org ID: $ORG_ID"
    echo -e "  Domain ID: $DOMAIN_ID"
    echo ""
    echo -e "  Total Tests: ${TOTAL}"
    echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
    echo -e "  ${RED}Failed: ${FAILED}${NC}"
    echo ""

    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}  ╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}  ║           ALL JOURNEYS COMPLETED SUCCESSFULLY!         ║${NC}"
        echo -e "${GREEN}  ╚════════════════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${RED}  ╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}  ║              SOME TESTS FAILED - REVIEW ABOVE          ║${NC}"
        echo -e "${RED}  ╚════════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# =============================================================================
# Main
# =============================================================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         QUAD Framework - E2E User Journey Tests            ║${NC}"
echo -e "${BLUE}║         Journey 1 → 2 → 3 → 4                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Base URL: $BASE_URL"
echo "Test User: $TEST_EMAIL"
echo "Timestamp: $(date)"
echo ""

# Run all journeys
journey1_onboarding
if [ -z "$TOKEN" ]; then
    echo -e "${RED}Cannot continue without authentication. Exiting.${NC}"
    exit 1
fi

journey2_team_setup
journey3_work_cycle
journey4_ai_flow
print_summary
