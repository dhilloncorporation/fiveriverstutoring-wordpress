#!/bin/bash

# WordPress Deployment Script for Five Rivers Tutoring
# Deploys WordPress from local machine to GCP VM

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script information
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/docker"

# Configuration
PROJECT_ID="storied-channel-467012-r6"
VM_NAME="jamr-websites-prod-wordpress"
ZONE="australia-southeast1-a"
IMAGE_NAME="fiverivers-tutoring"
TAG="latest"
REGISTRY="gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG"

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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop first."
        exit 1
    fi
    
    # Check if gcloud is authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "GCloud is not authenticated. Please run 'gcloud auth login' first."
        exit 1
    fi
    
    # Check if Container Registry API is enabled
    if ! gcloud services list --enabled --filter="name:containerregistry.googleapis.com" | grep -q containerregistry; then
        print_warning "Container Registry API not enabled. Enabling now..."
        gcloud services enable containerregistry.googleapis.com
    fi
    
    print_status "All prerequisites are met!"
}

# Function to build Docker image
build_image() {
    print_header "Building WordPress Docker Image"
    
    if [ ! -d "$DOCKER_DIR" ]; then
        print_error "Docker directory not found: $DOCKER_DIR"
        exit 1
    fi
    
    cd "$DOCKER_DIR"
    
    print_status "Building image: $IMAGE_NAME:$TAG"
    print_status "Build context: $PROJECT_ROOT (project root)"
    docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKER_DIR/Dockerfile" "$PROJECT_ROOT"
    
    if [ $? -eq 0 ]; then
        print_status "Docker image built successfully!"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Function to push image to GCP
push_image() {
    print_header "Pushing Image to GCP Container Registry"
    
    # Tag for GCP Container Registry
    print_status "Tagging image for GCP: $REGISTRY"
    docker tag "$IMAGE_NAME:$TAG" "$REGISTRY"
    
    # Configure Docker to use GCP
    print_status "Configuring Docker for GCP..."
    gcloud auth configure-docker --quiet
    
    # Push to GCP
    print_status "Pushing image to GCP Container Registry..."
    docker push "$REGISTRY"
    
    if [ $? -eq 0 ]; then
        print_status "Image pushed successfully to GCP!"
    else
        print_error "Failed to push image to GCP"
        exit 1
    fi
}

# Function to deploy to VM
deploy_to_vm() {
    print_header "Deploying WordPress to GCP VM"
    
    print_status "VM Name: $VM_NAME"
    print_status "Zone: $ZONE"
    print_status "Image: $REGISTRY"
    
    # Check if VM exists and is running
    print_status "Checking VM status..."
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)" 2>/dev/null || echo "NOT_FOUND")
    
    if [ "$VM_STATUS" = "NOT_FOUND" ]; then
        print_error "VM $VM_NAME not found in zone $ZONE"
        print_status "Please run './deploy.sh apply' first to create the infrastructure"
        exit 1
    fi
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_warning "VM is not running. Starting VM..."
        gcloud compute instances start "$VM_NAME" --zone="$ZONE"
        print_status "Waiting for VM to start..."
        sleep 30
    fi
    
    # Update the container declaration on the VM
    print_status "Updating VM container configuration..."
    gcloud compute instances update-container "$VM_NAME" \
        --zone="$ZONE" \
        --container-image="$REGISTRY" \
        --container-restart-policy=always
    
    print_status "WordPress deployment completed!"
    print_status "WordPress should be accessible at: http://$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")"
}

# Function to show help
show_help() {
    echo "WordPress Deployment Script for Five Rivers Tutoring"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build           Build WordPress Docker image locally"
    echo "  push            Push image to GCP Container Registry"
    echo "  deploy          Deploy WordPress to GCP VM"
    echo "  full            Build, push, and deploy (complete workflow)"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build        # Build Docker image locally"
    echo "  $0 push         # Push image to GCP"
    echo "  $0 deploy       # Deploy to VM"
    echo "  $0 full         # Complete deployment workflow"
}

# Main function
main() {
    case "${1:-help}" in
        build)
            check_prerequisites
            build_image
            ;;
        push)
            check_prerequisites
            push_image
            ;;
        deploy)
            check_prerequisites
            deploy_to_vm
            ;;
        full)
            check_prerequisites
            build_image
            push_image
            deploy_to_vm
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
