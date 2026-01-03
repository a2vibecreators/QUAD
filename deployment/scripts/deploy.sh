#!/bin/bash
# =============================================================================
# QUAD Framework - Master Deployment Script
# =============================================================================
# Deploys all submodules to specified environment
#
# Usage:
#   ./deploy.sh dev              # Deploy all to DEV
#   ./deploy.sh qa               # Deploy all to QA
#   ./deploy.sh prod             # Deploy all to PROD
#   ./deploy.sh dev web          # Deploy only quad-web to DEV
#   ./deploy.sh dev api          # Deploy only quad-services to DEV
#   ./deploy.sh dev db           # Deploy only database to DEV
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV="${1:-dev}"
COMPONENT="${2:-all}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  QUAD Framework - ${ENV^^} Deployment                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

# Environment-specific configs
case "$ENV" in
    dev)
        WEB_PORT=14001
        API_PORT=14101
        DB_PORT=14201
        DB_HOST="postgres-dev"
        DB_NAME="quad_dev_db"
        DB_PASS="quad_dev_pass"
        DOMAIN="dev.quadframe.work"
        NETWORK="docker_dev-network"
        ;;
    qa)
        WEB_PORT=15001
        API_PORT=15101
        DB_PORT=15201
        DB_HOST="postgres-qa"
        DB_NAME="quad_qa_db"
        DB_PASS="quad_qa_pass"
        DOMAIN="qa.quadframe.work"
        NETWORK="docker_qa-network"
        ;;
    prod)
        print_error "PROD deployment uses GCP Cloud Run"
        print_status "Use: ./cloud/deploy-gcp.sh prod"
        exit 1
        ;;
    *)
        echo "Usage: $0 {dev|qa|prod} [web|api|db|all]"
        exit 1
        ;;
esac

export DATABASE_URL="postgresql://quad_user:${DB_PASS}@localhost:${DB_PORT}/${DB_NAME}"

# Check prerequisites
check_env() {
    print_section "Checking Prerequisites"

    if [[ "$(hostname)" != *"Mac"* && "$(hostname)" != *"mac"* ]]; then
        print_error "This script must be run on Mac Studio"
        exit 1
    fi
    print_status "Running on Mac Studio"

    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running"
        exit 1
    fi
    print_status "Docker is running"

    echo ""
}

# Deploy quad-database (schema push)
deploy_db() {
    print_section "Deploying Database Schema"

    if [ -f "$ROOT_DIR/quad-web/deployment/deploy.sh" ]; then
        cd "$ROOT_DIR/quad-web" && ./deployment/deploy.sh "$ENV" db
    else
        cd "$ROOT_DIR/quad-web"
        print_status "Pushing Prisma schema to $ENV..."
        npx prisma db push --accept-data-loss 2>/dev/null || npx prisma db push
    fi
    print_status "Database schema deployed"
    echo ""
}

# Deploy quad-services (Java backend)
deploy_api() {
    print_section "Deploying quad-services (Java Backend)"

    if [ -f "$ROOT_DIR/quad-services/deployment/deploy.sh" ]; then
        cd "$ROOT_DIR/quad-services" && ./deployment/deploy.sh "$ENV"
    else
        cd "$ROOT_DIR/quad-services"
        print_status "Building with Maven..."
        JAVA_HOME=/opt/homebrew/opt/openjdk@21 mvn clean package -DskipTests -q
        print_status "JAR built: target/quad-services-*.jar"
        print_warning "Manual start required: java -jar target/quad-services-*.jar"
    fi
    echo ""
}

# Deploy quad-web (Next.js frontend)
deploy_web() {
    print_section "Deploying quad-web (Next.js Frontend)"

    if [ -f "$ROOT_DIR/quad-web/deployment/deploy.sh" ]; then
        cd "$ROOT_DIR/quad-web" && ./deployment/deploy.sh "$ENV"
    else
        # Fallback to existing deploy-studio.sh
        cd "$SCRIPT_DIR" && ./deploy-studio.sh "$ENV"
    fi
    echo ""
}

# Main execution
print_banner
check_env

case "$COMPONENT" in
    db|database)
        deploy_db
        ;;
    api|services)
        deploy_api
        ;;
    web)
        deploy_web
        ;;
    all|"")
        deploy_db
        deploy_api
        deploy_web
        echo ""
        print_status "All ${ENV^^} deployments complete!"
        echo ""
        echo -e "  ${CYAN}Web:${NC}  https://${DOMAIN}"
        echo -e "  ${CYAN}API:${NC}  http://localhost:${API_PORT}/api"
        echo -e "  ${CYAN}DB:${NC}   localhost:${DB_PORT}"
        ;;
    *)
        echo "Usage: $0 {dev|qa|prod} [web|api|db|all]"
        exit 1
        ;;
esac

echo ""
print_status "Deployment finished at $(date)"
