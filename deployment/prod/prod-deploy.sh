#!/bin/bash
# =============================================================================
# QUAD Framework - PROD Deployment
# =============================================================================
# Deploys all submodules to PROD environment (GCP Cloud Run)
#
# Usage:
#   ./prod-deploy.sh             # Deploy all
#   ./prod-deploy.sh web         # Deploy only quad-web
#   ./prod-deploy.sh api         # Deploy only quad-services
#   ./prod-deploy.sh db          # Deploy only database
#
# NOTE: PROD uses GCP Cloud Run, not Mac Studio Docker
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/../scripts/deploy.sh" prod "$@"
