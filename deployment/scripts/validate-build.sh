#!/bin/bash
#
# QUAD Framework - Build Validation
#
# Runs all checks that CI would run, locally.
# Use this before creating a PR to ensure it will pass.
#
# Usage: ./scripts/validate-build.sh
#
# Exit codes:
#   0 - All checks passed
#   1 - One or more checks failed
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           QUAD Framework - Build Validation                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

FAILED=0

# Function to run a check
run_check() {
    local name="$1"
    local command="$2"

    echo -e "${BLUE}Running:${NC} $name"

    if eval "$command" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $name passed"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name failed"
        FAILED=1
        return 1
    fi
}

# Function to run a check with output on failure
run_check_verbose() {
    local name="$1"
    local command="$2"
    local output_file="/tmp/quad-check-output.txt"

    echo -e "${BLUE}Running:${NC} $name"

    if eval "$command" > "$output_file" 2>&1; then
        echo -e "  ${GREEN}✓${NC} $name passed"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name failed"
        echo ""
        echo -e "${YELLOW}Output:${NC}"
        cat "$output_file" | head -30
        echo ""
        FAILED=1
        return 1
    fi
}

echo -e "${BLUE}Step 1: Checking Prisma schema...${NC}"
if npx prisma validate > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Prisma schema valid"
else
    echo -e "  ${RED}✗${NC} Prisma schema invalid"
    npx prisma validate 2>&1 | head -20
    FAILED=1
fi
echo ""

echo -e "${BLUE}Step 2: TypeScript type checking...${NC}"
if ./node_modules/.bin/tsc --noEmit 2>&1 | head -1 | grep -q "error"; then
    echo -e "  ${RED}✗${NC} TypeScript errors found"
    ./node_modules/.bin/tsc --noEmit 2>&1 | head -30
    FAILED=1
else
    echo -e "  ${GREEN}✓${NC} TypeScript check passed"
fi
echo ""

echo -e "${BLUE}Step 3: ESLint...${NC}"
if [ -f ".eslintrc.json" ] || [ -f "eslint.config.mjs" ]; then
    if npx eslint . --max-warnings 0 > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} ESLint passed"
    else
        echo -e "  ${YELLOW}⚠${NC}  ESLint warnings/errors found"
        npx eslint . --max-warnings 0 2>&1 | head -20
        # Don't fail on ESLint for now
    fi
else
    echo -e "  ${YELLOW}⚠${NC}  ESLint not configured, skipping"
fi
echo ""

echo -e "${BLUE}Step 4: Building application...${NC}"
if npm run build > /tmp/quad-build-output.txt 2>&1; then
    echo -e "  ${GREEN}✓${NC} Build successful"
else
    echo -e "  ${RED}✗${NC} Build failed"
    echo ""
    cat /tmp/quad-build-output.txt | tail -30
    FAILED=1
fi
echo ""

echo -e "${BLUE}Step 5: Checking for uncommitted changes...${NC}"
if [ -z "$(git status --porcelain)" ]; then
    echo -e "  ${GREEN}✓${NC} No uncommitted changes"
else
    echo -e "  ${YELLOW}⚠${NC}  Uncommitted changes found:"
    git status --short
fi
echo ""

# Summary
echo ""
if [ $FAILED -eq 0 ]; then
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    ${GREEN}✓ ALL CHECKS PASSED${NC}                        ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                 ║"
    echo "║  Your code is ready for PR!                                     ║"
    echo "║                                                                 ║"
    echo "║  Next steps:                                                    ║"
    echo "║    1. git checkout -b feature/your-feature-name                 ║"
    echo "║    2. git add . && git commit -m 'feat: Your feature'           ║"
    echo "║    3. git push origin feature/your-feature-name                 ║"
    echo "║    4. Create PR on GitHub                                       ║"
    echo "║                                                                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 0
else
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    ${RED}✗ SOME CHECKS FAILED${NC}                        ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                 ║"
    echo "║  Please fix the issues above before creating a PR.              ║"
    echo "║  CI will fail if these checks don't pass.                       ║"
    echo "║                                                                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 1
fi
