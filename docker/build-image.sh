#!/bin/bash

# Five Rivers Tutoring - Docker Image Build Script
# This script builds the custom WordPress image with Gmail API integration

set -e

echo "🚀 Building Five Rivers Tutoring WordPress Docker Image..."

# Check if we're in the right directory
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile not found. Please run this script from the docker/ directory."
    exit 1
fi

# Build the image
echo "📦 Building Docker image..."
docker build -t fiverivertutoring:latest .

# Tag for different environments
echo "🏷️  Tagging images..."
docker tag fiverivertutoring:latest fiverivertutoring:staging
docker tag fiverivertutoring:latest fiverivertutoring:production

echo "✅ Build completed successfully!"
echo ""
echo "📋 Available images:"
echo "  - fiverivertutoring:latest"
echo "  - fiverivertutoring:staging"
echo "  - fiverivertutoring:production"
echo ""
echo "🚀 To deploy:"
echo "  - Development: Use volume mapping (current setup)"
echo "  - Staging: docker-compose -f staging-deploy/docker-compose.staging.yml up -d"
echo "  - Production: Deploy via Terraform" 