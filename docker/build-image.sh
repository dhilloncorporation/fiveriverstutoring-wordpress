#!/bin/bash

# Five Rivers Tutoring - Docker Image Build Script
set -e

echo "🏗️ Building Five Rivers Tutoring Docker Image..."

# Configuration
IMAGE_NAME="fiverivers-tutoring"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if wp-content directory exists (from docker directory)
if [ ! -d "../fiverivertutoring_wordpress/wp-content" ]; then
    print_error "wp-content directory not found at ../fiverivertutoring_wordpress/wp-content"
    print_error "Please run this script from the docker directory or project root"
    exit 1
fi

print_status "Building Docker image: $FULL_IMAGE_NAME"
print_status "Build context: .. (project root)"
print_status "Dockerfile: Dockerfile"

# Build the Docker image
docker build \
    --tag "$FULL_IMAGE_NAME" \
    --file Dockerfile \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown") \
    ..

# Check if build was successful
if [ $? -eq 0 ]; then
    print_status "✅ Docker image built successfully!"
    
    # Show image information
    print_status "Image details:"
    docker images "$FULL_IMAGE_NAME"
    
    # Show image size
    IMAGE_SIZE=$(docker images "$FULL_IMAGE_NAME" --format "table {{.Size}}" | tail -n 1)
    print_status "Image size: $IMAGE_SIZE"
    
    echo ""
    print_status "🎉 Five Rivers Tutoring Docker image is ready!"
    print_status ""
    print_status "Next steps:"
    echo "  1. Test locally: docker run -p 8081:80 $FULL_IMAGE_NAME"
    echo "  2. Deploy to staging: cd staging-deploy && docker-compose -f docker-compose.staging.yml up -d"
    echo "  3. Deploy to production: cd gcp-deploy/deployment && ./deploy-on-vm.sh"
    echo "  4. Push to registry: docker tag $FULL_IMAGE_NAME your-registry/$FULL_IMAGE_NAME"
    
else
    print_error "❌ Docker image build failed!"
    exit 1
fi 