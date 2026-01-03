#!/bin/bash
# =============================================================================
# QUAD Framework - QA Deployment
# =============================================================================
# Deploys all submodules to QA environment
#
# Usage:
#   ./qa-deploy.sh               # Deploy all
#   ./qa-deploy.sh web           # Deploy only quad-web
#   ./qa-deploy.sh api           # Deploy only quad-services
#   ./qa-deploy.sh db            # Deploy only database
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../scripts/deploy.sh" qa "$@"
