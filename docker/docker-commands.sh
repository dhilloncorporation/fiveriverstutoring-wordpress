#!/bin/bash

# Five Rivers Tutoring - Docker Management Commands
# This script provides easy commands for managing Docker images and containers
# Builds from parent directory to ensure all required files are accessible

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if we're in the right directory (but don't exit)
check_directory() {
    if [ ! -f "Dockerfile" ]; then
        print_warning "Dockerfile not found in current directory. Trying to continue..."
        return 1
    fi
    return 0
}

# Function to check if Docker is running (but don't exit)
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_warning "Docker might not be running. Trying to continue..."
        return 1
    fi
    return 0
}

# Main script logic
main() {
    echo "🐳 Five Rivers Tutoring - Docker Management"
    echo "=========================================="
    
    # Check prerequisites (but don't exit)
    check_directory
    check_docker
    
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    case "$1" in
        "build")
            build_image
            ;;
        "rebuild")
            rebuild_image
            ;;
        "clean")
            clean_docker
            ;;
        "logs")
            show_logs "$2"
            ;;
        "shell")
            open_shell "$2"
            ;;
        "status")
            show_status
            ;;
        "push")
            push_image "$2"
            ;;
        "pull")
            pull_image "$2"
            ;;
        "run")
            run_container
            ;;
        "stop")
            stop_container
            ;;
        "restart")
            restart_container
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Build Docker image
build_image() {
    echo "🔨 Building Five Rivers Tutoring WordPress image..."
    print_info "Building from parent directory to ensure all files are accessible..."
    
    if docker build -f Dockerfile -t fiverivertutoring-wordpress:latest ..; then
        print_status "Docker image built successfully!"
        print_info "Image: fiverivertutoring-wordpress:latest"
    else
        print_error "Docker build failed!"
        print_info "Check the error messages above for details"
    fi
}

# Rebuild Docker image (no cache)
rebuild_image() {
    echo "🔄 Rebuilding Five Rivers Tutoring WordPress image (no cache)..."
    print_info "Building from parent directory with --no-cache..."
    
    if docker build --no-cache -f Dockerfile -t fiverivertutoring-wordpress:latest ..; then
        print_status "Docker image rebuilt successfully!"
        print_info "Image: fiverivertutoring-wordpress:latest"
    else
        print_error "Docker rebuild failed!"
        print_info "Check the error messages above for details"
    fi
}

# Clean Docker system
clean_docker() {
    echo "🧹 Cleaning Docker system..."
    
    print_warning "This will remove ALL containers, images, and volumes. Are you sure? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        return 0
    fi
    
    echo "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    
    echo "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    echo "Removing all images..."
    docker rmi $(docker images -q) 2>/dev/null || true
    
    echo "Removing all volumes..."
    docker volume rm $(docker volume ls -q) 2>/dev/null || true
    
    echo "Removing all networks..."
    docker network rm $(docker network ls -q) 2>/dev/null || true
    
    echo "Pruning system..."
    docker system prune -af
    
    print_status "Docker system cleaned!"
}

# Show container logs
show_logs() {
    local container_name=${1:-"fiverivertutoring-wordpress"}
    
    if [ -z "$1" ]; then
        echo "Showing logs for fiverivertutoring-wordpress container..."
    else
        echo "Showing logs for container: $1"
    fi
    
    if docker logs "$container_name"; then
        print_status "Logs displayed successfully"
    else
        print_warning "Container not found or not running"
    fi
}

# Open shell in container
open_shell() {
    local container_name=${1:-"fiverivertutoring-wordpress"}
    
    if [ -z "$1" ]; then
        echo "Opening shell in fiverivertutoring-wordpress container..."
    else
        echo "Opening shell in container: $1"
    fi
    
    if docker exec -it "$container_name" /bin/bash; then
        print_status "Shell session ended"
    else
        print_warning "Container not found or not running"
    fi
}

# Show Docker status
show_status() {
    echo "📊 Checking Docker status..."
    echo ""
    
    echo "🐳 Docker Images:"
    if docker images | grep fiverivertutoring; then
        echo "Fiverivertutoring images found"
    else
        echo "No fiverivertutoring images found"
    fi
    echo ""
    
    echo "📦 Running Containers:"
    if docker ps | grep fiverivertutoring; then
        echo "Fiverivertutoring containers running"
    else
        echo "No fiverivertutoring containers running"
    fi
    echo ""
    
    echo "📋 All Containers:"
    if docker ps -a | grep fiverivertutoring; then
        echo "Fiverivertutoring containers found"
    else
        echo "No fiverivertutoring containers found"
    fi
    echo ""
    
    echo "💾 Docker System Info:"
    docker system df
}

# Push Docker image to registry
push_image() {
    if [ -z "$1" ]; then
        print_error "Please provide registry tag: ./docker-commands.sh push registry/tag"
        return 1
    fi
    
    echo "📤 Pushing Docker image to registry..."
    if docker tag fiverivertutoring-wordpress:latest "$1" && docker push "$1"; then
        print_status "Docker image pushed to $1"
    else
        print_error "Failed to push image to $1"
    fi
}

# Pull Docker image from registry
pull_image() {
    if [ -z "$1" ]; then
        print_error "Please provide registry tag: ./docker-commands.sh pull registry/tag"
        return 1
    fi
    
    echo "📥 Pulling Docker image from registry..."
    if docker pull "$1" && docker tag "$1" fiverivertutoring-wordpress:latest; then
        print_status "Docker image pulled and tagged as fiverivertutoring-wordpress:latest"
    else
        print_error "Failed to pull image from $1"
    fi
}

# Run container
run_container() {
    echo "🚀 Running Five Rivers Tutoring WordPress container..."
    
    # Check if image exists
    if ! docker images | grep -q "fiverivertutoring-wordpress"; then
        print_warning "Image not found. Please build the image first: ./docker-commands.sh build"
        return 1
    fi
    
    # Run the container
    if docker run -d \
        --name fiverivertutoring-wordpress \
        -p 8080:80 \
        -e WORDPRESS_DB_HOST=localhost \
        -e WORDPRESS_DB_NAME=fiveriverstutoring_db \
        -e WORDPRESS_DB_USER=root \
        -e WORDPRESS_DB_PASSWORD=password \
        fiverivertutoring-wordpress:latest; then
        print_status "Container started successfully!"
        print_info "Access your site at: http://localhost:8080"
    else
        print_error "Failed to start container"
    fi
}

# Stop container
stop_container() {
    echo "🛑 Stopping Five Rivers Tutoring WordPress container..."
    docker stop fiverivertutoring-wordpress 2>/dev/null || print_warning "Container not running"
    docker rm fiverivertutoring-wordpress 2>/dev/null || print_warning "Container not found"
    print_status "Container stopped and removed!"
}

# Restart container
restart_container() {
    echo "🔄 Restarting Five Rivers Tutoring WordPress container..."
    stop_container
    sleep 2
    run_container
}

# Show usage information
show_usage() {
    echo "Usage: $0 {build|rebuild|clean|logs|shell|status|push|pull|run|stop|restart}"
    echo ""
    echo "Commands:"
    echo "  build     - Build Docker image"
    echo "  rebuild   - Rebuild Docker image (no cache)"
    echo "  clean     - Clean all Docker containers, images, and volumes"
    echo "  logs      - Show container logs [container_name]"
    echo "  shell     - Open shell in container [container_name]"
    echo "  status    - Show Docker status"
    echo "  push      - Push image to registry (requires registry/tag)"
    echo "  pull      - Pull image from registry (requires registry/tag)"
    echo "  run       - Run the container"
    echo "  stop      - Stop and remove the container"
    echo "  restart   - Restart the container"
    echo ""
    echo "Examples:"
    echo "  $0 build                    # Build the image"
    echo "  $0 run                      # Run the container"
    echo "  $0 logs                     # Show logs"
    echo "  $0 shell                    # Open shell in container"
    echo "  $0 push myregistry.com/fiverivertutoring:latest"
}

# Run main function
main "$@"
