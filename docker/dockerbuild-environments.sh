#!/bin/bash

# Five Rivers Tutoring - Environment-Specific Docker Build Script
# Builds optimized images for staging and production

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Five Rivers Tutoring - Environment-Specific Docker Builds"
echo "=========================================================="

# Function to build staging image
build_staging() {
    echo "🔨 Building STAGING image..."
    cd "$PROJECT_ROOT"
    
    docker build \
        --build-arg ENVIRONMENT=staging \
        --build-arg INCLUDE_DEBUG=true \
        --build-arg OPTIMIZE_FOR_PRODUCTION=false \
        -t fiverivertutoring-wordpress:staging \
        -f docker/Dockerfile .
    
    echo "✅ Staging image built successfully!"
    echo "   Tag: fiverivertutoring-wordpress:staging"
}

# Function to build production image
build_production() {
    echo "🔨 Building PRODUCTION image (optimized)..."
    cd "$PROJECT_ROOT"
    
    docker build \
        --build-arg ENVIRONMENT=production \
        --build-arg OPTIMIZE_FOR_PRODUCTION=true \
        -t fiverivertutoring-wordpress:production \
        -f docker/Dockerfile.production .
    
    echo "✅ Production image built successfully!"
    echo "   Tag: fiverivertutoring-wordpress:production"
}

# Function to build both environments
build_all() {
    echo "🔨 Building ALL environments..."
    build_staging
    build_production
}

# Function to show image differences
show_differences() {
    echo "🔍 Showing image differences..."
    
    echo "📊 Staging Image:"
    docker run --rm fiverivertutoring-wordpress:staging php -m | grep -E "(opcache|debug|dev)" || echo "No development modules found"
    
    echo "📊 Production Image:"
    docker run --rm fiverivertutoring-wordpress:production php -m | grep -E "(opcache|debug|dev)" || echo "No development modules found"
    
    echo "📏 Image Sizes:"
    docker images fiverivertutoring-wordpress --format "table {{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
}

# Function to clean old images
clean_images() {
    echo "🧹 Cleaning old images..."
    docker image prune -f
    echo "✅ Cleanup completed!"
}

# Function to show usage
usage() {
    cat <<USAGE
Usage: $0 {staging|production|all|diff|clean}

Commands:
  staging     - Build staging image (development tools included)
  production  - Build production image (optimized, no dev tools)
  all         - Build both staging and production images
  diff        - Show differences between staging and production images
  clean       - Clean up old Docker images

Examples:
  $0 staging      # Build staging image
  $0 production   # Build production image
  $0 all          # Build both images
  $0 diff         # Compare images
USAGE
}

# Main execution
case "${1:-}" in
    "staging")
        build_staging
        ;;
    "production")
        build_production
        ;;
    "all")
        build_all
        ;;
    "diff")
        show_differences
        ;;
    "clean")
        clean_images
        ;;
    *)
        usage
        exit 1
        ;;
esac

echo ""
echo "🎉 Build process completed!"
echo "💡 Use 'docker images fiverivertutoring-wordpress' to see all images"
