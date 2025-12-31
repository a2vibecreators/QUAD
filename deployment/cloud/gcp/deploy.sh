#!/bin/bash
#
# Deploy QUAD Framework to GCP Cloud Run
# Uses nutrinine-prod project
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="nutrinine-prod"
REGION="us-east1"
SERVICE_NAME="quadframework-prod"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  QUAD Framework - GCP Cloud Run Deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Project:  ${GREEN}${PROJECT_ID}${NC}"
echo -e "  Region:   ${GREEN}${REGION}${NC}"
echo -e "  Service:  ${GREEN}${SERVICE_NAME}${NC}"
echo -e "  Domain:   ${GREEN}quadframe.work${NC}"
echo ""

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/../../.."
cd "${PROJECT_ROOT}"

echo -e "${YELLOW}📋 Step 1/5: Checking gcloud authentication...${NC}"
if ! gcloud auth print-access-token &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with gcloud. Run: gcloud auth login${NC}"
    exit 1
fi

# Set project
gcloud config set project ${PROJECT_ID} --quiet
echo -e "${GREEN}✅ Using project: ${PROJECT_ID}${NC}"

echo ""
echo -e "${YELLOW}📋 Step 2/5: Configuring Docker for GCR...${NC}"
gcloud auth configure-docker gcr.io --quiet
echo -e "${GREEN}✅ Docker configured for GCR${NC}"

echo ""
echo -e "${YELLOW}🔨 Step 3/5: Building Docker image...${NC}"
docker build \
    --platform linux/amd64 \
    -t ${IMAGE_NAME}:latest \
    -t ${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S) \
    .

echo -e "${GREEN}✅ Image built: ${IMAGE_NAME}:latest${NC}"

echo ""
echo -e "${YELLOW}📤 Step 4/5: Pushing to Google Container Registry...${NC}"
docker push ${IMAGE_NAME}:latest
echo -e "${GREEN}✅ Image pushed to GCR${NC}"

echo ""
echo -e "${YELLOW}🚀 Step 5/5: Deploying to Cloud Run...${NC}"
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME}:latest \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --port 80 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 5 \
    --set-env-vars "NODE_ENV=production"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')
echo ""
echo -e "  Service URL: ${GREEN}${SERVICE_URL}${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Map custom domain in GCP Console: Cloud Run → ${SERVICE_NAME} → Manage Custom Domains"
echo -e "  2. Add domain: quadframe.work"
echo -e "  3. Update DNS records at domain registrar with provided values"
echo ""
