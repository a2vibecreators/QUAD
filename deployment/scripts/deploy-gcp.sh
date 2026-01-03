#!/bin/bash
#
# Convenience wrapper for GCP Cloud Run deployment
# Deploys QUAD Framework to Production (quadframe.work)
#

set -e

echo "🚀 Deploying QUAD Framework to GCP Cloud Run (PRODUCTION)"
echo ""
echo "This will deploy to: quadframe.work"
echo ""
read -p "Continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Call the actual deployment script
./deployment/cloud/gcp/deploy.sh
