#!/bin/bash

# Production Deployment Script for ValueLadder
set -e

echo "🚀 Starting ValueLadder Production Deployment..."

# Configuration
PROJECT_ID="valueladder-websites"
REGION="australia-southeast1"
ZONE="australia-southeast1-a"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Pre-deployment checks
print_status "Running pre-deployment checks..."

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    print_error "Not authenticated with gcloud. Please run: gcloud auth login"
    exit 1
fi

# Check if project exists
if ! gcloud projects describe $PROJECT_ID >/dev/null 2>&1; then
    print_error "Project $PROJECT_ID does not exist. Please create it first."
    exit 1
fi

# Set project
print_status "Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable required APIs
print_status "Enabling required APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable monitoring.googleapis.com

# Create backup of current state (if exists)
if terraform state list >/dev/null 2>&1; then
    print_status "Creating backup of current state..."
    terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
fi

# Deploy infrastructure
print_status "Deploying infrastructure..."
cd terraform

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Plan deployment
print_status "Planning deployment..."
terraform plan -var-file=production.tfvars -out=production-plan.tfplan

# Ask for confirmation
echo ""
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled by user."
    exit 0
fi

# Apply deployment
print_status "Applying deployment..."
terraform apply production-plan.tfplan

# Get deployment outputs
print_status "Getting deployment information..."
IP_ADDRESS=$(terraform output -raw wordpress_ip)
INSTANCE_NAME=$(terraform output -raw wordpress_instance_name)

print_status "Deployment completed successfully!"
print_status "Instance Name: $INSTANCE_NAME"
print_status "IP Address: $IP_ADDRESS"
print_status "Website URL: http://$IP_ADDRESS:8081"

# Post-deployment checks
print_status "Running post-deployment checks..."

# Wait for instance to be ready
print_status "Waiting for instance to be ready..."
sleep 30

# Test website accessibility
print_status "Testing website accessibility..."
if curl -f -s "http://$IP_ADDRESS:8081" >/dev/null; then
    print_status "✅ Website is accessible!"
else
    print_warning "⚠️  Website might not be ready yet. Please check in a few minutes."
fi

# Setup monitoring alerts
print_status "Setting up monitoring alerts..."
gcloud alpha monitoring policies create \
    --policy-from-file=monitoring-policy.yaml \
    --project=$PROJECT_ID

print_status "🎉 Production deployment completed!"
echo ""
echo "Next steps:"
echo "1. Configure your domain DNS to point to: $IP_ADDRESS"
echo "2. Set up SSL certificate for HTTPS"
echo "3. Configure WordPress settings"
echo "4. Upload your wp-content files"
echo "5. Test all functionality"
echo ""
echo "For monitoring, visit: https://console.cloud.google.com/monitoring" 