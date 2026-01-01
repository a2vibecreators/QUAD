#!/bin/bash

# QUAD Framework Deploy Script
# Deploys to Mac Studio (local Docker)
#
# Usage:
#   ./deploy-studio.sh dev   - Deploy to DEV (dev.quadframe.work)
#   ./deploy-studio.sh qa    - Deploy to QA (qa.quadframe.work)
#   ./deploy-studio.sh all   - Deploy to both DEV and QA
#
# Note: PROD (quadframe.work) is deployed to GCP Cloud Run, not Mac Studio

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="quadframework"
NETWORK_NAME="caddy-network"

# Port assignments (similar to a2vibecreators-web pattern)
DEV_PORT=18001
QA_PORT=18501

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

deploy_env() {
    local ENV=$1
    local PORT=$2
    local CONTAINER_NAME="${PROJECT_NAME}-${ENV}"
    local IMAGE_NAME="${PROJECT_NAME}:${ENV}"

    print_status "Deploying ${PROJECT_NAME} to ${ENV}..."

    # Build the Docker image
    print_status "Building Docker image: ${IMAGE_NAME}"
    docker build -t ${IMAGE_NAME} .

    # Stop and remove existing container if it exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Stopping existing container: ${CONTAINER_NAME}"
        docker stop ${CONTAINER_NAME} 2>/dev/null || true
        docker rm ${CONTAINER_NAME} 2>/dev/null || true
    fi

    # Set environment-specific credentials
    # Source from .env.deploy file (gitignored) or environment variables
    # Create .env.deploy from .env.deploy.example and fill in real values
    if [ -f ".env.deploy" ]; then
        source .env.deploy
    fi

    if [ "${ENV}" = "dev" ]; then
        DB_HOST="${DEV_DB_HOST:-postgres-dev}"
        DB_NAME="${DEV_DB_NAME:-quad_dev_db}"
        DB_PASS="${DEV_DB_PASS:-quad_dev_pass}"
        GOOGLE_CLIENT_ID="${DEV_GOOGLE_CLIENT_ID:?ERROR: DEV_GOOGLE_CLIENT_ID not set. Create .env.deploy from .env.deploy.example}"
        GOOGLE_CLIENT_SECRET="${DEV_GOOGLE_CLIENT_SECRET:?ERROR: DEV_GOOGLE_CLIENT_SECRET not set. Create .env.deploy from .env.deploy.example}"
        NEXTAUTH_SECRET="${DEV_NEXTAUTH_SECRET:?ERROR: DEV_NEXTAUTH_SECRET not set. Create .env.deploy from .env.deploy.example}"
    else
        DB_HOST="${QA_DB_HOST:-postgres-qa}"
        DB_NAME="${QA_DB_NAME:-quad_qa_db}"
        DB_PASS="${QA_DB_PASS:-quad_qa_pass}"
        GOOGLE_CLIENT_ID="${QA_GOOGLE_CLIENT_ID:?ERROR: QA_GOOGLE_CLIENT_ID not set. Create .env.deploy from .env.deploy.example}"
        GOOGLE_CLIENT_SECRET="${QA_GOOGLE_CLIENT_SECRET:?ERROR: QA_GOOGLE_CLIENT_SECRET not set. Create .env.deploy from .env.deploy.example}"
        NEXTAUTH_SECRET="${QA_NEXTAUTH_SECRET:?ERROR: QA_NEXTAUTH_SECRET not set. Create .env.deploy from .env.deploy.example}"
    fi

    # Run the new container
    print_status "Starting container: ${CONTAINER_NAME} on port ${PORT}"
    docker run -d \
        --name ${CONTAINER_NAME} \
        --network ${NETWORK_NAME} \
        -p ${PORT}:3000 \
        --restart unless-stopped \
        -e NEXTAUTH_URL=https://${ENV}.quadframe.work \
        -e NEXTAUTH_SECRET=${NEXTAUTH_SECRET} \
        -e GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID} \
        -e GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET} \
        -e DB_HOST=${DB_HOST} \
        -e DB_PORT=5432 \
        -e DB_NAME=${DB_NAME} \
        -e DB_USER=quad_user \
        -e DB_PASSWORD=${DB_PASS} \
        ${IMAGE_NAME}

    # Verify the container is running
    sleep 2
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Container ${CONTAINER_NAME} is running"

        # Test the container
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT} | grep -q "200"; then
            print_status "Health check passed for ${CONTAINER_NAME}"
        else
            print_warning "Health check returned non-200 status"
        fi
    else
        print_error "Container ${CONTAINER_NAME} failed to start"
        docker logs ${CONTAINER_NAME}
        exit 1
    fi
}

# Check if we're on Mac Studio (hostname could be "Mac", "Mac-Studio", etc.)
if [[ "$(hostname)" != *"Mac"* && "$(hostname)" != *"mac"* ]]; then
    print_error "This script must be run on Mac Studio"
    print_status "Current hostname: $(hostname)"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running"
    exit 1
fi

# Check if caddy-network exists
if ! docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    print_status "Creating Docker network: ${NETWORK_NAME}"
    docker network create ${NETWORK_NAME}
fi

# Parse command line argument
case "${1}" in
    dev)
        deploy_env "dev" ${DEV_PORT}
        echo ""
        print_status "DEV deployed successfully!"
        print_status "URL: https://dev.quadframe.work"
        print_status "Local: http://localhost:${DEV_PORT}"
        ;;
    qa)
        deploy_env "qa" ${QA_PORT}
        echo ""
        print_status "QA deployed successfully!"
        print_status "URL: https://qa.quadframe.work"
        print_status "Local: http://localhost:${QA_PORT}"
        ;;
    all)
        deploy_env "dev" ${DEV_PORT}
        deploy_env "qa" ${QA_PORT}
        echo ""
        print_status "Both environments deployed successfully!"
        print_status "DEV: https://dev.quadframe.work (localhost:${DEV_PORT})"
        print_status "QA: https://qa.quadframe.work (localhost:${QA_PORT})"
        ;;
    *)
        echo "QUAD Framework Deploy Script"
        echo ""
        echo "Usage: $0 {dev|qa|all}"
        echo ""
        echo "  dev  - Deploy to DEV (dev.quadframe.work)"
        echo "  qa   - Deploy to QA (qa.quadframe.work)"
        echo "  all  - Deploy to both DEV and QA"
        echo ""
        echo "Note: PROD (quadframe.work) is deployed to GCP Cloud Run"
        exit 1
        ;;
esac

echo ""
print_status "Remember to update Caddyfile if this is first deployment!"
print_status "Add these entries to /Users/semostudio/docker/caddy/Caddyfile:"
echo ""
echo "  dev.quadframe.work {"
echo "      reverse_proxy quadframework-dev:80"
echo "  }"
echo ""
echo "  qa.quadframe.work {"
echo "      reverse_proxy quadframework-qa:80"
echo "  }"
