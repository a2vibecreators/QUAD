#!/bin/bash
# =============================================================================
# QUAD Framework - Prerequisites Checker
# =============================================================================
# Checks if all required software is installed before deployment
#
# Usage: ./check-prerequisites.sh [--strict]
#        --strict: Exit with error if any required tool is missing
# =============================================================================

# Bash strict mode (industry standard)
set -euo pipefail
IFS=$'\n\t'

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    CYGWIN*)    PLATFORM=Cygwin;;
    MINGW*)     PLATFORM=MinGw;;
    MSYS*)      PLATFORM=Git-Bash;;
    *)          PLATFORM="Unknown:$OS"
esac

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

STRICT_MODE=false
if [[ "${1:-}" == "--strict" ]]; then
    STRICT_MODE=true
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  QUAD Framework - Prerequisites Check                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

MISSING_REQUIRED=()
MISSING_OPTIONAL=()

# Helper functions
check_command() {
    local cmd=$1
    local name=$2
    local version_cmd=$3
    local required=$4
    local install_url=$5

    if command -v "$cmd" &> /dev/null; then
        local version=$(eval "$version_cmd" 2>&1 || echo "unknown")
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: Not installed"
        echo -e "   ${YELLOW}Install:${NC} $install_url"
        if [[ "$required" == "true" ]]; then
            MISSING_REQUIRED+=("$name")
        else
            MISSING_OPTIONAL+=("$name")
        fi
        return 1
    fi
}

check_docker_network() {
    local network=$1
    if docker network inspect "$network" &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker network '$network' exists"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Docker network '$network' does not exist (will be created)"
        return 1
    fi
}

# =============================================================================
# Required Software
# =============================================================================

echo -e "${BLUE}Required Software:${NC}"
echo ""

check_command "docker" "Docker" \
    "docker --version | awk '{print \$3}'" \
    "true" \
    "https://docs.docker.com/get-docker/"

check_command "node" "Node.js" \
    "node --version" \
    "true" \
    "https://nodejs.org/ (v18+ recommended)"

check_command "npm" "npm" \
    "npm --version" \
    "true" \
    "Comes with Node.js"

check_command "java" "Java" \
    "java -version 2>&1 | grep version | awk '{print \$3}' | tr -d '\"'" \
    "true" \
    "brew install openjdk@17 (Mac) or https://adoptium.net/"

check_command "mvn" "Maven" \
    "mvn --version | grep 'Apache Maven' | awk '{print \$3}'" \
    "true" \
    "brew install maven (Mac) or https://maven.apache.org/"

check_command "git" "Git" \
    "git --version | awk '{print \$3}'" \
    "true" \
    "https://git-scm.com/"

check_command "bw" "Bitwarden CLI" \
    "bw --version" \
    "true" \
    "npm install -g @bitwarden/cli (for Vaultwarden secrets)"

# =============================================================================
# Optional Software
# =============================================================================

echo ""
echo -e "${BLUE}Optional Software (Recommended):${NC}"
echo ""

check_command "jq" "jq (JSON processor)" \
    "jq --version" \
    "false" \
    "brew install jq (Mac) or https://stedolan.github.io/jq/"

check_command "migra" "migra (PostgreSQL schema diff)" \
    "migra --version" \
    "false" \
    "brew install pipx && pipx install 'migra[pg]' && pipx inject migra setuptools"

check_command "curl" "curl" \
    "curl --version | head -1 | awk '{print \$2}'" \
    "false" \
    "Usually pre-installed"

# =============================================================================
# Docker Environment Check
# =============================================================================

echo ""
echo -e "${BLUE}Docker Environment:${NC}"
echo ""

if docker info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"

    # Check networks
    check_docker_network "docker_dev-network"
    check_docker_network "docker_qa-network"

    # Check if Caddy is running
    if docker ps --format '{{.Names}}' | grep -q "^caddy$"; then
        echo -e "${GREEN}✓${NC} Caddy reverse proxy is running"
    else
        echo -e "${YELLOW}⚠${NC} Caddy reverse proxy is not running"
        echo -e "   ${YELLOW}Note:${NC} HTTPS access will not work without Caddy"
    fi
else
    echo -e "${RED}✗${NC} Docker daemon is not running"
    echo -e "   ${YELLOW}Start Docker Desktop or:${NC} sudo systemctl start docker"
    MISSING_REQUIRED+=("Docker daemon")
fi

# =============================================================================
# Java Environment Check
# =============================================================================

echo ""
echo -e "${BLUE}Java Environment:${NC}"
echo ""

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | grep version | awk '{print $3}' | tr -d '"' | cut -d. -f1)
    if [[ "$JAVA_VERSION" -ge 17 ]]; then
        echo -e "${GREEN}✓${NC} Java $JAVA_VERSION (>= 17 required)"
    else
        echo -e "${RED}✗${NC} Java $JAVA_VERSION (< 17 - upgrade required)"
        MISSING_REQUIRED+=("Java 17+")
    fi

    # Check JAVA_HOME
    if [[ -n "$JAVA_HOME" ]]; then
        echo -e "${GREEN}✓${NC} JAVA_HOME: $JAVA_HOME"
    else
        echo -e "${YELLOW}⚠${NC} JAVA_HOME not set"
        echo -e "   ${YELLOW}Set:${NC} export JAVA_HOME=/opt/homebrew/opt/openjdk@17"
    fi
fi

# =============================================================================
# Node.js Environment Check
# =============================================================================

echo ""
echo -e "${BLUE}Node.js Environment:${NC}"
echo ""

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | tr -d 'v' | cut -d. -f1)
    if [[ "$NODE_VERSION" -ge 18 ]]; then
        echo -e "${GREEN}✓${NC} Node.js $NODE_VERSION (>= 18 recommended)"
    else
        echo -e "${YELLOW}⚠${NC} Node.js $NODE_VERSION (< 18 - upgrade recommended)"
    fi
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Summary                                                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ ${#MISSING_REQUIRED[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ All required software is installed!${NC}"

    if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Optional software missing:${NC}"
        for item in "${MISSING_OPTIONAL[@]}"; do
            echo -e "  - $item"
        done
        echo ""
        echo -e "${YELLOW}Note:${NC} You can still proceed, but some features may not work."
    fi

    echo ""
    echo -e "${GREEN}✓ Ready to run setup!${NC}"
    echo -e "   ${BLUE}Next:${NC} ./deployment/scripts/setup.sh"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Missing required software:${NC}"
    for item in "${MISSING_REQUIRED[@]}"; do
        echo -e "  - $item"
    done
    echo ""
    echo -e "${RED}Please install missing software and try again.${NC}"
    echo ""

    if [[ "$STRICT_MODE" == "true" ]]; then
        exit 1
    else
        exit 0
    fi
fi
