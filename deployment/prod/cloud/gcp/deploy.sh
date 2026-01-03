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
echo -e "${YELLOW}🔐 Loading credentials from .env.deploy...${NC}"

# Source production credentials
if [ -f ".env.deploy" ]; then
    source .env.deploy
else
    echo -e "${RED}❌ .env.deploy not found. Create it with PROD credentials.${NC}"
    exit 1
fi

# Validate required credentials
if [ -z "$PROD_DB_HOST" ] || [ -z "$PROD_GOOGLE_CLIENT_ID" ]; then
    echo -e "${RED}❌ Missing PROD credentials in .env.deploy${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Credentials loaded${NC}"

# Construct DATABASE_URL for Prisma
DATABASE_URL="postgresql://${PROD_DB_USER}:${PROD_DB_PASS}@${PROD_DB_HOST}:5432/${PROD_DB_NAME}?schema=public"

echo ""
echo -e "${YELLOW}🚀 Step 5/5: Deploying to Cloud Run...${NC}"
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME}:latest \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --port 3000 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 5 \
    --set-env-vars "NODE_ENV=production" \
    --set-env-vars "NEXTAUTH_URL=https://quadframe.work" \
    --set-env-vars "NEXTAUTH_SECRET=${PROD_NEXTAUTH_SECRET}" \
    --set-env-vars "GOOGLE_CLIENT_ID=${PROD_GOOGLE_CLIENT_ID}" \
    --set-env-vars "GOOGLE_CLIENT_SECRET=${PROD_GOOGLE_CLIENT_SECRET}" \
    --set-env-vars "DATABASE_URL=${DATABASE_URL}" \
    --set-env-vars "DB_HOST=${PROD_DB_HOST}" \
    --set-env-vars "DB_PORT=5432" \
    --set-env-vars "DB_NAME=${PROD_DB_NAME}" \
    --set-env-vars "DB_USER=${PROD_DB_USER}" \
    --set-env-vars "DB_PASSWORD=${PROD_DB_PASS}" \
    --set-env-vars "EMAIL_PROVIDER=resend" \
    --set-env-vars "RESEND_API_KEY=${RESEND_API_KEY}" \
    --set-env-vars "EMAIL_FROM=${EMAIL_FROM}"

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
