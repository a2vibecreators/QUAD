#!/bin/bash

# QUAD Framework - Mac/Linux Prerequisites Setup
# Purpose: Check and install required software for QUAD development
# Usage: ./scripts/setup-prerequisites.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     QUAD Framework - Mac/Linux Prerequisites Setup            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo -e "${CYAN}Detected OS: $OS${NC}"
echo ""

# Track what needs to be installed
MISSING_DEPS=()
INSTALL_COMMANDS=()

echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

# Check Homebrew (Mac only)
HAS_BREW=false
if [ "$OS" = "mac" ]; then
    if command -v brew &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Homebrew found"
        HAS_BREW=true
    else
        echo -e "  ${YELLOW}⚠️  Homebrew not found (recommended for auto-install)${NC}"
        echo -e "     ${GRAY}Install from: https://brew.sh${NC}"
        HAS_BREW=false
        echo ""
    fi
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo -e "  ${GREEN}✓${NC} Node.js $(node -v) found"
    else
        echo -e "  ${RED}✗${NC} Node.js version 18+ required (found $(node -v))"
        MISSING_DEPS+=("Node.js 18+")
        if [ "$HAS_BREW" = true ]; then
            INSTALL_COMMANDS+=("brew install node")
        fi
    fi
else
    echo -e "  ${RED}✗${NC} Node.js not found"
    MISSING_DEPS+=("Node.js")
    if [ "$HAS_BREW" = true ]; then
        INSTALL_COMMANDS+=("brew install node")
    fi
fi

# Check npm
if command -v npm &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} npm $(npm -v) found"
else
    echo -e "  ${RED}✗${NC} npm not found"
    MISSING_DEPS+=("npm (comes with Node.js)")
fi

# Check Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        echo -e "  ${GREEN}✓${NC} Docker $DOCKER_VERSION running"
    else
        echo -e "  ${YELLOW}⚠️  Docker installed but not running${NC}"
        echo -e "     ${GRAY}Start Docker Desktop${NC}"
    fi
else
    echo -e "  ${RED}✗${NC} Docker not found"
    MISSING_DEPS+=("Docker Desktop")
    if [ "$HAS_BREW" = true ]; then
        INSTALL_COMMANDS+=("brew install --cask docker")
    fi
fi

# Check Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo -e "  ${GREEN}✓${NC} Git $GIT_VERSION found"
else
    echo -e "  ${RED}✗${NC} Git not found"
    MISSING_DEPS+=("Git")
    if [ "$HAS_BREW" = true ]; then
        INSTALL_COMMANDS+=("brew install git")
    fi
fi

# Check Java
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "  ${GREEN}✓${NC} Java found ($JAVA_VERSION)"
else
    echo -e "  ${YELLOW}⚠️  Java not found (required for QUAD services)${NC}"
    MISSING_DEPS+=("Java JDK 17+")
    if [ "$HAS_BREW" = true ]; then
        INSTALL_COMMANDS+=("brew install openjdk@17")
    fi
fi

# Check Maven
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -v | head -n 1 | cut -d' ' -f3)
    echo -e "  ${GREEN}✓${NC} Maven $MVN_VERSION found"
else
    echo -e "  ${YELLOW}⚠️  Maven not found (required for QUAD services)${NC}"
    MISSING_DEPS+=("Maven")
    if [ "$HAS_BREW" = true ]; then
        INSTALL_COMMANDS+=("brew install maven")
    fi
fi

# Check Bitwarden CLI (optional)
if command -v bw &> /dev/null; then
    BW_VERSION=$(bw --version)
    echo -e "  ${GREEN}✓${NC} Bitwarden CLI $BW_VERSION found (optional)"
else
    echo -e "  ${CYAN}ℹ️  Bitwarden CLI not found (optional - for vault secrets)${NC}"
fi

echo ""

# Summary
if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ✅ All prerequisites met!                         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. cd quad-web"
    echo "  2. npm install"
    echo "  3. npm run dev"
    echo ""
    echo -e "${GREEN}Or run the full setup:${NC}"
    echo "  ./deployment/scripts/setup-local.sh"
    echo ""
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              Missing Dependencies                              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    for dep in "${MISSING_DEPS[@]}"; do
        echo -e "  ${RED}✗${NC} $dep"
    done

    echo ""
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$HAS_BREW" = true ] && [ ${#INSTALL_COMMANDS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Automatic Installation (with Homebrew):${NC}"
        echo ""
        echo -e "${YELLOW}Run these commands:${NC}"
        echo ""
        for cmd in "${INSTALL_COMMANDS[@]}"; do
            echo -e "  ${CYAN}$cmd${NC}"
        done
        echo ""
        echo -e "${YELLOW}Or install all at once:${NC}"
        echo -e "  ${CYAN}$(IFS=" && " ; echo "${INSTALL_COMMANDS[*]}")${NC}"
        echo ""
    fi

    echo -e "${YELLOW}Manual Installation Links:${NC}"
    echo ""

    for dep in "${MISSING_DEPS[@]}"; do
        case $dep in
            "Node.js"*)
                if [ "$OS" = "mac" ]; then
                    echo "  Node.js:  brew install node"
                else
                    echo "  Node.js:  https://nodejs.org/en/download/"
                fi
                ;;
            "Docker"*)
                if [ "$OS" = "mac" ]; then
                    echo "  Docker:   brew install --cask docker"
                else
                    echo "  Docker:   https://docs.docker.com/engine/install/"
                fi
                ;;
            "Git")
                if [ "$OS" = "mac" ]; then
                    echo "  Git:      brew install git"
                else
                    echo "  Git:      sudo apt-get install git (Ubuntu/Debian)"
                fi
                ;;
            "Java"*)
                if [ "$OS" = "mac" ]; then
                    echo "  Java:     brew install openjdk@17"
                else
                    echo "  Java:     https://adoptium.net/temurin/releases/"
                fi
                ;;
            "Maven")
                if [ "$OS" = "mac" ]; then
                    echo "  Maven:    brew install maven"
                else
                    echo "  Maven:    sudo apt-get install maven (Ubuntu/Debian)"
                fi
                ;;
        esac
    done

    echo ""
    echo -e "${YELLOW}After installing, run this script again to verify.${NC}"
    echo ""
fi

# Additional notes
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$OS" = "mac" ]; then
    echo -e "${CYAN}💡 Tips for Mac Development:${NC}"
    echo -e "  ${GRAY}• Install Homebrew if not already: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
    echo -e "  ${GRAY}• Use iTerm2 for better terminal experience${NC}"
    echo -e "  ${GRAY}• Configure Docker Desktop: Preferences → Resources → Advanced${NC}"
    echo -e "  ${GRAY}• Increase Docker memory to 4GB+ for QUAD services${NC}"
elif [ "$OS" = "linux" ]; then
    echo -e "${CYAN}💡 Tips for Linux Development:${NC}"
    echo -e "  ${GRAY}• Add your user to docker group: sudo usermod -aG docker \$USER${NC}"
    echo -e "  ${GRAY}• Then log out and back in for group changes to take effect${NC}"
    echo -e "  ${GRAY}• Configure Docker daemon: /etc/docker/daemon.json${NC}"
fi

echo ""
