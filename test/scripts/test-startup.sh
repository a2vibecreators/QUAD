#!/bin/bash
# =============================================================================
# QUAD Framework - Startup Health Check
# =============================================================================
# Verifies all services are running before other tests
#
# Services Checked:
#   1. Next.js Web App (port 3000)
#   2. Java Backend (port 14101)
#   3. PostgreSQL Database (port 14201)
#   4. Basic API Endpoints
# =============================================================================

# Configuration
NEXTJS_URL="${NEXTJS_URL:-http://localhost:3000}"
JAVA_API_URL="${JAVA_API_URL:-http://localhost:14101/api}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-14201}"

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
        echo -e "${RED}    Error: $2${NC}"
    fi
    ((FAILED++))
    ((TOTAL++))
}

print_skip() {
    echo -e "${YELLOW}  ⊘ SKIPPED: $1${NC}"
    ((TOTAL++))
}

check_port() {
    local port=$1
    local name=$2
    if lsof -i :$port > /dev/null 2>&1; then
        print_pass "$name is running on port $port"
        return 0
    else
        print_fail "$name is NOT running on port $port"
        return 1
    fi
}

check_http() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}

    local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" 2>/dev/null)

    if [ "$status" = "$expected_status" ]; then
        print_pass "$name returned HTTP $status"
        return 0
    elif [ -z "$status" ] || [ "$status" = "000" ]; then
        print_fail "$name connection failed (no response)"
        return 1
    else
        print_fail "$name returned HTTP $status (expected $expected_status)"
        return 1
    fi
}

# =============================================================================
# Service Checks
# =============================================================================

check_nextjs() {
    print_section "1. Next.js Web App (Port 3000)"

    print_test "Checking if Next.js is running..."
    check_port 3000 "Next.js"

    print_test "Checking Next.js CPU usage..."
    local cpu=$(ps aux | grep "next" | grep -v grep | awk '{print $3}' | head -1)
    if [ -n "$cpu" ]; then
        # Compare as integers (remove decimal)
        local cpu_int=${cpu%.*}
        if [ "$cpu_int" -gt 80 ]; then
            print_fail "Next.js CPU at ${cpu}% (OVERLOADED - restart needed)"
            echo -e "${YELLOW}    Fix: kill \$(lsof -t -i:3000) && npm run dev${NC}"
        elif [ "$cpu_int" -gt 50 ]; then
            echo -e "${YELLOW}  ⚠ WARNING: Next.js CPU at ${cpu}% (high but ok)${NC}"
            ((PASSED++))
            ((TOTAL++))
        else
            print_pass "Next.js CPU at ${cpu}% (healthy)"
        fi
    else
        print_pass "Next.js CPU check skipped (process info unavailable)"
    fi

    print_test "Checking Next.js health endpoint..."
    local health_response=$(curl -s --max-time 5 "$NEXTJS_URL/api/health" 2>/dev/null)
    local health_status=$(echo "$health_response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

    if [ "$health_status" = "healthy" ]; then
        local db_latency=$(echo "$health_response" | grep -o '"databaseLatencyMs":[0-9]*' | cut -d':' -f2)
        print_pass "Health endpoint: status=healthy, db=${db_latency}ms"
    elif [ "$health_status" = "degraded" ]; then
        echo -e "${YELLOW}  ⚠ WARNING: Health endpoint: status=degraded${NC}"
        ((PASSED++))
        ((TOTAL++))
    elif [ -n "$health_status" ]; then
        print_fail "Health endpoint: status=$health_status"
    else
        # Fallback to homepage check if health endpoint not ready
        check_http "$NEXTJS_URL" "Next.js homepage"
    fi
}

check_java_backend() {
    print_section "2. Java Backend (Port 14101)"

    print_test "Checking if Java backend is running..."
    check_port 14101 "Java Backend"

    print_test "Checking Java backend responds..."
    local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$JAVA_API_URL/health" 2>/dev/null)

    if [ "$status" = "200" ]; then
        print_pass "Java health endpoint returned HTTP 200"
    elif [ "$status" = "404" ]; then
        print_pass "Java backend responding (no /health endpoint yet - HTTP 404)"
    elif [ -n "$status" ] && [ "$status" != "000" ]; then
        print_pass "Java backend responding (HTTP $status)"
    else
        print_fail "Java backend not responding"
    fi
}

check_database() {
    print_section "3. PostgreSQL Database (Port 14201)"

    print_test "Checking if PostgreSQL is running..."
    check_port $DB_PORT "PostgreSQL"

    print_test "Checking database connection via Docker..."
    if docker exec postgres-dev pg_isready -U quad_user -d quad_dev_db > /dev/null 2>&1; then
        print_pass "Database connection successful"
    else
        # Try direct connection
        if pg_isready -h $DB_HOST -p $DB_PORT -U quad_user > /dev/null 2>&1; then
            print_pass "Database connection successful (direct)"
        else
            print_fail "Database connection failed"
        fi
    fi

    print_test "Checking database tables exist..."
    local table_count=$(docker exec postgres-dev psql -U quad_user -d quad_dev_db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'QUAD_%';" 2>/dev/null | tr -d ' ')

    if [ -n "$table_count" ] && [ "$table_count" -gt 0 ]; then
        print_pass "Found $table_count QUAD tables in database"
    else
        print_fail "No QUAD tables found in database"
    fi
}

check_api_endpoints() {
    print_section "4. API Endpoint Checks"

    # Auth endpoints (should return 401 without token)
    print_test "Checking auth/login endpoint..."
    local status=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$NEXTJS_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d '{}' 2>/dev/null)

    if [ "$status" = "400" ] || [ "$status" = "401" ] || [ "$status" = "422" ]; then
        print_pass "Auth login endpoint responding (HTTP $status - expected for empty request)"
    elif [ "$status" = "200" ]; then
        print_pass "Auth login endpoint responding (HTTP $status)"
    else
        print_fail "Auth login endpoint returned HTTP $status"
    fi

    # Domains endpoint (should return 401 without token)
    print_test "Checking domains endpoint..."
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$NEXTJS_URL/api/domains" 2>/dev/null)

    if [ "$status" = "401" ]; then
        print_pass "Domains endpoint requires auth (HTTP 401)"
    elif [ "$status" = "200" ]; then
        print_pass "Domains endpoint responding (HTTP $status)"
    else
        print_fail "Domains endpoint returned HTTP $status"
    fi

    # Core-roles endpoint (may require auth)
    print_test "Checking core-roles endpoint..."
    local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$NEXTJS_URL/api/core-roles" 2>/dev/null)

    if [ "$status" = "200" ]; then
        print_pass "Core-roles endpoint returned data (HTTP 200)"
    elif [ "$status" = "401" ]; then
        print_pass "Core-roles endpoint requires auth (HTTP 401 - expected)"
    else
        print_fail "Core-roles endpoint returned HTTP $status"
    fi

    # Setup check endpoint
    print_test "Checking setup/check endpoint..."
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$NEXTJS_URL/api/setup/check" 2>/dev/null)

    if [ "$status" = "200" ] || [ "$status" = "401" ]; then
        print_pass "Setup check endpoint responding (HTTP $status)"
    else
        print_fail "Setup check endpoint returned HTTP $status"
    fi
}

# =============================================================================
# Summary
# =============================================================================

print_summary() {
    print_banner "STARTUP CHECK SUMMARY                                        "
    echo ""
    echo -e "  Next.js URL:    $NEXTJS_URL"
    echo -e "  Java API URL:   $JAVA_API_URL"
    echo -e "  Database Port:  $DB_PORT"
    echo ""
    echo -e "  Total Checks: ${TOTAL}"
    echo -e "  ${GREEN}Passed: ${PASSED}${NC}"
    echo -e "  ${RED}Failed: ${FAILED}${NC}"
    echo ""

    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}  ╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}  ║         ALL SERVICES HEALTHY - READY FOR TESTING!      ║${NC}"
        echo -e "${GREEN}  ╚════════════════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${RED}  ╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}  ║          SOME SERVICES UNHEALTHY - FIX BEFORE TESTING  ║${NC}"
        echo -e "${RED}  ╚════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}  Troubleshooting:${NC}"
        echo -e "    - Start Next.js:  cd quadframework && npm run dev"
        echo -e "    - Start Java:     cd quad-services && mvn spring-boot:run"
        echo -e "    - Start DB:       docker start postgres-dev"
        exit 1
    fi
}

# =============================================================================
# Main
# =============================================================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          QUAD Framework - Startup Health Check             ║${NC}"
echo -e "${BLUE}║          Verifying all services before testing             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Timestamp: $(date)"
echo ""

check_nextjs
check_java_backend
check_database
check_api_endpoints
print_summary
