#!/bin/bash
# ============================================================================= # QUAD Framework - Fetch Secrets from Vaultwarden
# =============================================================================
# Fetches OAuth credentials and secrets from Vaultwarden
# and creates .env file for deployment
#
# Usage: ./fetch-secrets.sh [dev|qa]
#        Requires: BW_SESSION environment variable
# =============================================================================

# Bash strict mode (industry standard)
set -euo pipefail
IFS=$'\n\t'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Load configuration
if [[ -f "$SCRIPT_DIR/../vault.conf" ]]; then
    source "$SCRIPT_DIR/../vault.conf"
else
    echo "Error: vault.conf not found"
    exit 1
fi

ENV="${1:-dev}"
ENV_FILE="$PROJECT_ROOT/quad-web/deployment/${ENV}/.env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  QUAD Framework - Fetch Secrets from Vaultwarden         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if bw is installed
if ! command -v bw &> /dev/null; then
    print_error "Bitwarden CLI not found"
    echo ""
    echo "Install: npm install -g @bitwarden/cli"
    exit 1
fi

# Check BW_SESSION
if [[ -z "${BW_SESSION:-}" ]]; then
    print_error "BW_SESSION not set"
    echo "Login: export BW_SESSION=\$(bw unlock --raw)"
    exit 1
fi

# Environment configuration
case "$ENV" in
    dev)
        COLLECTION_ID="$DEV_COLLECTION_ID"
        NEXTAUTH_URL="https://$DEV_DOMAIN"
        DB_HOST="$DEV_DB_CONTAINER"
        DB_NAME="$DEV_DB_NAME"
        QUAD_API_URL="http://$DEV_SERVICES_CONTAINER:8080"
        ;;
    qa)
        COLLECTION_ID="$QA_COLLECTION_ID"
        NEXTAUTH_URL="https://$QA_DOMAIN"
        DB_HOST="$QA_DB_CONTAINER"
        DB_NAME="$QA_DB_NAME"
        QUAD_API_URL="http://$QA_SERVICES_CONTAINER:8080"
        ;;
    *)
        print_error "Invalid environment: $ENV"
        exit 1
        ;;
esac

print_info "Fetching secrets for $ENV..."

# Fetch secrets function
get_secret() {
    local item_name=$1
    local field=$2
    local item
    item=$(bw get item "$item_name" --organizationid "$QUAD_ORG_ID" 2>/dev/null || echo "")
    if [[ -z "$item" ]]; then
        return 1
    fi
    echo "$item" | jq -r ".login.$field // empty"
}

# Fetch OAuth credentials
GOOGLE_CLIENT_ID=$(get_secret "$GOOGLE_OAUTH_ITEM" "username" || echo "")
GOOGLE_CLIENT_SECRET=$(get_secret "$GOOGLE_OAUTH_ITEM" "password" || echo "")
NEXTAUTH_SECRET=$(get_secret "$NEXTAUTH_SECRET_ITEM" "password" || openssl rand -base64 32)

[[ -n "$GOOGLE_CLIENT_ID" ]] && print_status "Google OAuth: Found" || print_warning "Google OAuth: Missing"

# Write .env file
mkdir -p "$(dirname "$ENV_FILE")"
cat > "$ENV_FILE" <<EOF
# QUAD $ENV Environment - Generated $(date)
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
NEXTAUTH_URL=$NEXTAUTH_URL
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
DATABASE_URL=postgresql://quad_user:quad_${ENV}_pass@${DB_HOST}:5432/${DB_NAME}
QUAD_API_URL=$QUAD_API_URL
EOF

print_status "Secrets fetched to: $ENV_FILE"
