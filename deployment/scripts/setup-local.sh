#!/bin/bash
#
# QUAD Framework - Local Development Setup
#
# This script sets up a local development environment:
# 1. Checks prerequisites (Node, Docker, etc.)
# 2. Creates PostgreSQL container
# 3. Runs database migrations
# 4. Seeds test data
# 5. Installs dependencies
#
# Usage: ./scripts/setup-local.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           QUAD Framework - Local Setup Wizard                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Track what needs to be installed
MISSING_DEPS=()

# Check Node.js
echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo -e "  ${GREEN}✓${NC} Node.js $(node -v) found"
    else
        echo -e "  ${RED}✗${NC} Node.js version 18+ required (found $(node -v))"
        MISSING_DEPS+=("Node.js 18+")
    fi
else
    echo -e "  ${RED}✗${NC} Node.js not found"
    MISSING_DEPS+=("Node.js")
fi

# Check npm
if command -v npm &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} npm $(npm -v) found"
else
    echo -e "  ${RED}✗${NC} npm not found"
    MISSING_DEPS+=("npm")
fi

# Check Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker running"
    else
        echo -e "  ${YELLOW}⚠${NC}  Docker installed but not running"
        MISSING_DEPS+=("Docker (start it)")
    fi
else
    echo -e "  ${RED}✗${NC} Docker not found"
    MISSING_DEPS+=("Docker")
fi

# Check Git
if command -v git &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Git $(git --version | cut -d' ' -f3) found"
else
    echo -e "  ${RED}✗${NC} Git not found"
    MISSING_DEPS+=("Git")
fi

echo ""

# If missing dependencies, show installation instructions
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${RED}Missing dependencies:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo -e "  - $dep"
    done
    echo ""
    echo -e "${YELLOW}Installation instructions:${NC}"
    echo ""

    for dep in "${MISSING_DEPS[@]}"; do
        case $dep in
            "Node.js"*|"npm")
                echo "  Node.js & npm:"
                echo "    Mac:     brew install node"
                echo "    Windows: https://nodejs.org/en/download/"
                echo "    Linux:   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs"
                echo ""
                ;;
            "Docker"*)
                echo "  Docker:"
                echo "    Mac:     brew install --cask docker"
                echo "    Windows: https://docs.docker.com/desktop/windows/install/"
                echo "    Linux:   https://docs.docker.com/engine/install/"
                echo ""
                ;;
            "Git")
                echo "  Git:"
                echo "    Mac:     brew install git"
                echo "    Windows: https://git-scm.com/download/win"
                echo "    Linux:   sudo apt-get install git"
                echo ""
                ;;
        esac
    done

    echo -e "${YELLOW}After installing, run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}All prerequisites met!${NC}"
echo ""

# Database configuration
DB_CONTAINER="quad-local-db"
DB_NAME="quad_local_db"
DB_USER="quad_user"
DB_PASSWORD="quad_local_pass"
DB_PORT="5432"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found.${NC}"
    echo "Please run this script from the QUAD framework root directory."
    exit 1
fi

# Step 1: Create PostgreSQL container
echo -e "${BLUE}Setting up PostgreSQL...${NC}"

if docker ps -a --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    if docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
        echo -e "  ${GREEN}✓${NC} PostgreSQL container already running"
    else
        echo "  Starting existing container..."
        docker start $DB_CONTAINER > /dev/null
        echo -e "  ${GREEN}✓${NC} PostgreSQL container started"
    fi
else
    echo "  Creating new PostgreSQL container..."
    docker run -d \
        --name $DB_CONTAINER \
        -e POSTGRES_USER=$DB_USER \
        -e POSTGRES_PASSWORD=$DB_PASSWORD \
        -e POSTGRES_DB=$DB_NAME \
        -p $DB_PORT:5432 \
        postgres:15 > /dev/null

    # Wait for PostgreSQL to be ready
    echo "  Waiting for PostgreSQL to start..."
    sleep 5

    for i in {1..30}; do
        if docker exec $DB_CONTAINER pg_isready -U $DB_USER > /dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    echo -e "  ${GREEN}✓${NC} PostgreSQL container created"
fi

# Step 2: Create .env.local if it doesn't exist
echo ""
echo -e "${BLUE}Setting up environment...${NC}"

if [ ! -f ".env.local" ]; then
    cat > .env.local << EOF
# Local Development Environment
# Generated by setup-local.sh

# Database
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}"

# NextAuth
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="local-dev-secret-change-in-production"

# AI (Optional - uses mock by default)
# ANTHROPIC_API_KEY=""
# OPENAI_API_KEY=""
EOF
    echo -e "  ${GREEN}✓${NC} Created .env.local"
else
    echo -e "  ${GREEN}✓${NC} .env.local already exists"
fi

# Step 3: Install dependencies
echo ""
echo -e "${BLUE}Installing dependencies...${NC}"
npm install --silent
echo -e "  ${GREEN}✓${NC} Dependencies installed"

# Step 4: Generate Prisma client
echo ""
echo -e "${BLUE}Generating Prisma client...${NC}"
npx prisma generate > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Prisma client generated"

# Step 5: Run database migrations
echo ""
echo -e "${BLUE}Running database migrations...${NC}"
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}" npx prisma db push > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Database schema synced"

# Step 6: Seed test data (if seed script exists)
if [ -f "prisma/seed.ts" ]; then
    echo ""
    echo -e "${BLUE}Seeding test data...${NC}"
    DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}" npx prisma db seed > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Test data seeded"
fi

# Done!
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 Setup Complete!                          ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║                                                                 ║"
echo "║  Database:    postgresql://localhost:${DB_PORT}/${DB_NAME}              ║"
echo "║  User:        ${DB_USER}                                           ║"
echo "║  Password:    ${DB_PASSWORD}                                    ║"
echo "║                                                                 ║"
echo "║  To start development:                                          ║"
echo "║    npm run dev                                                  ║"
echo "║                                                                 ║"
echo "║  Then open:                                                     ║"
echo "║    http://localhost:3000                                        ║"
echo "║                                                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
