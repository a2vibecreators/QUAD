#!/bin/bash
# =============================================================================
# QUAD Framework - Interactive Setup Script
# =============================================================================
# First-time setup for QUAD Framework deployment
#
# Usage: ./setup.sh
#
# This script will:
# 1. Check prerequisites (Docker, Node.js, Java, Maven, etc.)
# 2. Fetch secrets from Vaultwarden (OAuth credentials)
# 3. Set up Caddy reverse proxy configuration
# 4. Create Docker networks
# 5. Optionally deploy to DEV/QA
# =============================================================================

# Bash strict mode (industry standard)
set -euo pipefail
IFS=$'\n\t'

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    *)          PLATFORM="Unknown";;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Load configuration
if [[ -f "$SCRIPT_DIR/../quad.conf" ]]; then
    source "$SCRIPT_DIR/../quad.conf"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

# =============================================================================
# Banner
# =============================================================================

clear
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║  ${CYAN}QUAD Framework - Interactive Setup${NC}                    ${BLUE}║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║  ${NC}This wizard will help you set up QUAD for the first  ${BLUE}║${NC}"
echo -e "${BLUE}║  ${NC}time by:                                               ${BLUE}║${NC}"
echo -e "${BLUE}║  ${NC}  • Checking prerequisites                             ${BLUE}║${NC}"
echo -e "${BLUE}║  ${NC}  • Fetching secrets from Vaultwarden                  ${BLUE}║${NC}"
echo -e "${BLUE}║  ${NC}  • Configuring Caddy reverse proxy                    ${BLUE}║${NC}"
echo -e "${BLUE}║  ${NC}  • Creating Docker networks                           ${BLUE}║${NC}"
echo -e "${BLUE}║  ${NC}  • Deploying to DEV/QA                                ${BLUE}║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

read -p "Press Enter to continue..."
echo ""

# =============================================================================
# Step 1: Prerequisites Check
# =============================================================================

print_section "Step 1: Checking Prerequisites"
echo ""

if [[ -f "$SCRIPT_DIR/check-prerequisites.sh" ]]; then
    bash "$SCRIPT_DIR/check-prerequisites.sh"
    PREREQ_EXIT=$?

    if [[ $PREREQ_EXIT -ne 0 ]]; then
        echo ""
        print_error "Prerequisites check failed"
        read -p "Continue anyway? (y/N): " CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            print_info "Setup cancelled. Please install missing software and try again."
            exit 1
        fi
    fi
else
    print_warning "Prerequisites checker not found (skipping)"
fi

echo ""
read -p "Press Enter to continue..."
echo ""

# =============================================================================
# Step 2: Choose Environment
# =============================================================================

print_section "Step 2: Environment Selection"
echo ""

echo "Which environment(s) do you want to set up?"
echo "  1) DEV only"
echo "  2) QA only"
echo "  3) Both DEV and QA"
echo ""

while true; do
    read -p "Enter choice (1-3) [1]: " ENV_CHOICE
    ENV_CHOICE=${ENV_CHOICE:-1}

    case "$ENV_CHOICE" in
        1)
            ENVIRONMENTS=("dev")
            break
            ;;
        2)
            ENVIRONMENTS=("qa")
            break
            ;;
        3)
            ENVIRONMENTS=("dev" "qa")
            break
            ;;
        *)
            print_error "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac
done

print_status "Selected: ${ENVIRONMENTS[*]}"
echo ""

# =============================================================================
# Step 3: Fetch Secrets from Vaultwarden
# =============================================================================

print_section "Step 3: Fetch Secrets from Vaultwarden"
echo ""

echo "QUAD uses Vaultwarden to store OAuth credentials and secrets."
echo ""
read -p "Fetch secrets from Vaultwarden? (Y/n): " FETCH_SECRETS
FETCH_SECRETS=${FETCH_SECRETS:-y}

if [[ "$FETCH_SECRETS" =~ ^[Yy]$ ]]; then
    echo ""
    print_info "You need to authenticate with Vaultwarden first."
    echo ""

    # Check if bw is installed
    if ! command -v bw &> /dev/null; then
        print_warning "Bitwarden CLI not installed"
        echo ""
        echo "Install: npm install -g @bitwarden/cli"
        echo ""
        read -p "Continue without fetching secrets? (y/N): " SKIP_VAULT
        if [[ ! "$SKIP_VAULT" =~ ^[Yy]$ ]]; then
            print_info "Setup cancelled. Install bw CLI and try again."
            exit 1
        fi
        FETCH_SECRETS="n"
    else
        # Check if already logged in
        if ! bw status &> /dev/null; then
            echo "Login to Vaultwarden:"
            echo "  Server: https://vault.nutrinine.app"
            echo ""
            bw config server https://vault.nutrinine.app
            bw login
        fi

        # Unlock vault
        echo ""
        echo "Unlocking vault..."
        export BW_SESSION=$(bw unlock --raw)

        if [[ -z "$BW_SESSION" ]]; then
            print_error "Failed to unlock vault"
            FETCH_SECRETS="n"
        else
            print_status "Vault unlocked"

            # Fetch secrets for each environment
            for env in "${ENVIRONMENTS[@]}"; do
                echo ""
                print_info "Fetching secrets for $env..."
                bash "$SCRIPT_DIR/fetch-secrets.sh" "$env"
            done
        fi
    fi
else
    print_warning "Skipping secret fetch. You'll need to manually create .env files."
    echo ""
    echo "See: quad-web/deployment/dev/.env.example"
fi

echo ""
read -p "Press Enter to continue..."
echo ""

# =============================================================================
# Step 4: Caddy Reverse Proxy Setup
# =============================================================================

print_section "Step 4: Caddy Reverse Proxy Configuration"
echo ""

echo "Caddy provides SSL/HTTPS for dev.quadframe.work and qa.quadframe.work"
echo ""
read -p "Set up Caddy configuration? (Y/n): " SETUP_CADDY
SETUP_CADDY=${SETUP_CADDY:-y}

if [[ "$SETUP_CADDY" =~ ^[Yy]$ ]]; then
    CADDY_DIR="/Users/semostudio/docker/caddy"

    if [[ ! -d "$CADDY_DIR" ]]; then
        print_warning "Caddy directory not found: $CADDY_DIR"
        echo ""
        read -p "Create directory? (Y/n): " CREATE_DIR
        if [[ "$CREATE_DIR" =~ ^[Yy]$ ]]; then
            mkdir -p "$CADDY_DIR"
            print_status "Created: $CADDY_DIR"
        else
            print_warning "Skipping Caddy setup"
            SETUP_CADDY="n"
        fi
    fi

    if [[ "$SETUP_CADDY" =~ ^[Yy]$ ]]; then
        # Backup existing Caddyfile
        if [[ -f "$CADDY_DIR/Caddyfile" ]]; then
            BACKUP_FILE="$CADDY_DIR/Caddyfile.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$CADDY_DIR/Caddyfile" "$BACKUP_FILE"
            print_status "Backed up existing Caddyfile to: $BACKUP_FILE"
        fi

        # Copy Caddyfile templates
        echo ""
        for env in "${ENVIRONMENTS[@]}"; do
            if [[ -f "$PROJECT_ROOT/deployment/caddy/Caddyfile.$env" ]]; then
                print_info "Merging Caddyfile.$env configuration..."

                # Append to main Caddyfile (or create if doesn't exist)
                if [[ ! -f "$CADDY_DIR/Caddyfile" ]]; then
                    cat "$PROJECT_ROOT/deployment/caddy/Caddyfile.$env" > "$CADDY_DIR/Caddyfile"
                else
                    echo "" >> "$CADDY_DIR/Caddyfile"
                    cat "$PROJECT_ROOT/deployment/caddy/Caddyfile.$env" >> "$CADDY_DIR/Caddyfile"
                fi

                print_status "Added $env configuration"
            else
                print_warning "Caddyfile.$env template not found"
            fi
        done

        # Restart Caddy
        echo ""
        read -p "Restart Caddy container? (Y/n): " RESTART_CADDY
        if [[ "${RESTART_CADDY:-y}" =~ ^[Yy]$ ]]; then
            if docker ps --format '{{.Names}}' | grep -q "^caddy$"; then
                docker restart caddy
                print_status "Caddy restarted"
            else
                print_warning "Caddy container not running"
                echo ""
                echo "Start Caddy manually or it will auto-start on next boot"
            fi
        fi
    fi
else
    print_warning "Skipping Caddy setup"
    echo ""
    echo "Note: Without Caddy, you can only access via localhost:PORT"
fi

echo ""
read -p "Press Enter to continue..."
echo ""

# =============================================================================
# Step 5: Docker Networks
# =============================================================================

print_section "Step 5: Docker Networks"
echo ""

for env in "${ENVIRONMENTS[@]}"; do
    NETWORK="docker_${env}-network"

    if docker network inspect "$NETWORK" &> /dev/null; then
        print_status "Network exists: $NETWORK"
    else
        print_info "Creating network: $NETWORK"
        docker network create "$NETWORK"
        print_status "Created: $NETWORK"
    fi
done

echo ""

# =============================================================================
# Step 6: Deploy
# =============================================================================

print_section "Step 6: Deploy to Environment(s)"
echo ""

echo "Deploy now or deploy manually later?"
echo "  1) Deploy now"
echo "  2) Skip deployment (I'll deploy manually later)"
echo ""

read -p "Enter choice (1-2) [2]: " DEPLOY_CHOICE
DEPLOY_CHOICE=${DEPLOY_CHOICE:-2}

if [[ "$DEPLOY_CHOICE" == "1" ]]; then
    echo ""

    for env in "${ENVIRONMENTS[@]}"; do
        print_info "Deploying to $env..."
        echo ""

        DEPLOY_SCRIPT="$PROJECT_ROOT/quad-web/deployment/${env}/${env}-deploy.sh"

        if [[ -f "$DEPLOY_SCRIPT" ]]; then
            bash "$DEPLOY_SCRIPT"
        else
            print_warning "Deployment script not found: $DEPLOY_SCRIPT"
            echo ""
            echo "Run manually:"
            echo "  cd $PROJECT_ROOT"
            echo "  ./deployment/scripts/deploy.sh $env"
        fi

        echo ""
    done
else
    print_info "Skipping deployment"
    echo ""
    echo "Deploy manually when ready:"
    for env in "${ENVIRONMENTS[@]}"; do
        echo "  cd quad-web && ./deployment/${env}/${env}-deploy.sh"
    done
fi

echo ""

# =============================================================================
# Summary
# =============================================================================

print_section "Setup Complete!"
echo ""

echo -e "${GREEN}✓ QUAD Framework setup finished!${NC}"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo ""

if [[ "$DEPLOY_CHOICE" == "2" ]]; then
    echo "1. Deploy to environment(s):"
    for env in "${ENVIRONMENTS[@]}"; do
        echo "   cd quad-web && ./deployment/${env}/${env}-deploy.sh"
    done
    echo ""
fi

echo "2. Access your deployments:"
for env in "${ENVIRONMENTS[@]}"; do
    if [[ "$env" == "dev" ]]; then
        echo "   DEV: https://dev.quadframe.work"
    elif [[ "$env" == "qa" ]]; then
        echo "   QA: https://qa.quadframe.work"
    fi
done

echo ""
echo "3. Check deployment status:"
echo "   docker ps | grep quad"
echo ""

echo -e "${CYAN}Documentation:${NC}"
echo "  - Deployment guide: deployment/README.md"
echo "  - Project docs: CLAUDE.md"
echo ""

echo -e "${GREEN}Happy coding, macha! 🚀${NC}"
echo ""
