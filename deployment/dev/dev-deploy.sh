#!/bin/bash
# =============================================================================
# QUAD Framework - DEV Deployment
# =============================================================================
# Deploys all submodules to DEV environment
#
# Usage:
#   ./dev-deploy.sh              # Deploy all
#   ./dev-deploy.sh web          # Deploy only quad-web
#   ./dev-deploy.sh api          # Deploy only quad-services
#   ./dev-deploy.sh db           # Deploy only database
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../scripts/deploy.sh" dev "$@"
