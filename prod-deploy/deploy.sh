#!/bin/bash

# Five Rivers Tutoring - Production Deployment Script
# This script deploys WordPress infrastructure (compute + storage)

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Script information
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if we're in the right directory
    if [ ! -d "$TERRAFORM_DIR" ]; then
        print_error "terraform/ directory not found. Please run this script from prod-deploy directory."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if gcloud is installed and authenticated
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK is not installed. Please install gcloud first."
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "Not authenticated with Google Cloud. Please run 'gcloud auth login' first."
        exit 1
    fi
    
    print_status "All prerequisites are met!"
}

# Function to initialize Terraform
init_terraform() {
    print_header "Initializing Terraform"
    
    # Change to terraform directory
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init
    
    # Return to script directory
    cd "$SCRIPT_DIR"
    
    print_status "Terraform initialized successfully!"
}

# Function to plan deployment
plan_deployment() {
    print_header "Planning Infrastructure Deployment"
    
    # Change to terraform directory
    cd "$TERRAFORM_DIR"
    
    # Create plans directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/plans"
    
    # Plan the deployment with WordPress variables
    terraform plan -var-file="wordpress.tfvars" -out=../plans/infrastructure-plan.tfplan
    
    # Return to script directory
    cd "$SCRIPT_DIR"
    
    print_status "Deployment plan created successfully!"
    print_warning "Review the plan and run './deploy.sh apply' to deploy"
}

# Function to apply deployment
apply_deployment() {
    print_header "Applying Infrastructure Deployment"
    
    # Check if plan exists
    if [ ! -f "plans/infrastructure-plan.tfplan" ]; then
        print_error "No deployment plan found. Please run './deploy.sh plan' first."
        exit 1
    fi
    
    # Change to terraform directory
    cd "$TERRAFORM_DIR"
    
    # Apply the plan
    terraform apply "../plans/infrastructure-plan.tfplan"
    
    # Return to script directory
    cd "$SCRIPT_DIR"
    
    print_status "Infrastructure deployed successfully!"
}

# Function to show outputs
show_outputs() {
    print_header "Infrastructure Outputs"
    
    # Change to terraform directory
    cd "$TERRAFORM_DIR"
    
    # Show all outputs
    terraform output
    
    # Return to script directory
    cd "$SCRIPT_DIR"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_header "Destroying Infrastructure"
    
    print_warning "This will permanently delete all infrastructure resources!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        # Change to terraform directory
        cd "$TERRAFORM_DIR"
        
        # Destroy the infrastructure with WordPress variables
        terraform destroy -var-file="wordpress.tfvars" -auto-approve
        
        # Return to script directory
        cd "$SCRIPT_DIR"
        
        print_status "Infrastructure destroyed successfully!"
    else
        print_status "Destruction cancelled."
    fi
}

# Function to show status
show_status() {
    print_header "Infrastructure Status"
    
    # Change to terraform directory
    cd "$TERRAFORM_DIR"
    
    # Show current state
    terraform show
    
    # Show HTTPS status if available
    echo
    print_header "HTTPS Status"
    if terraform output -json https_status 2>/dev/null | grep -q "Let's Encrypt configured"; then
        print_status "✅ HTTPS: ENABLED with Let's Encrypt"
        
        # Get domain information
        domain=$(terraform output -raw domain_name 2>/dev/null)
        if [ -n "$domain" ]; then
            print_status "Domain: $domain"
        fi
        
        # Get DNS nameservers
        nameservers=$(terraform output -json dns_nameservers 2>/dev/null)
        if [ -n "$nameservers" ] && [ "$nameservers" != "[]" ]; then
            print_status "DNS Nameservers:"
            echo "$nameservers" | jq -r '.[]' 2>/dev/null || echo "$nameservers"
        fi
    else
        print_warning "⚠️  HTTPS: NOT CONFIGURED"
        print_status "Run: $0 https-setup to configure HTTPS"
    fi
    
    # Return to script directory
    cd "$SCRIPT_DIR"
}

# Function to show help
show_help() {
    echo "Five Rivers Tutoring - Production Deployment Script"
    echo "Usage: $0 <command> [options]"
    echo
    echo "=========================================="
    echo "🔧 TECHNICAL DETAILS"
    echo "=========================================="
    echo "  # Configuration files:"
    echo "  Production config: ../terraform/wordpress.tfvars"
    echo "  Staging config: ../../staging-deploy/env.staging"
    echo "  Terraform state: ../terraform/terraform.tfstate"
    echo
    echo "  # Key resources:"
    echo "  VM Instance: jamr-websites-prod-wordpress"
    echo "  Cloud SQL: jamr-websites-db-prod"
    echo "  Docker Image: gcr.io/storied-channel-467012-r6/fiverivers-tutoring:latest"
    echo
    echo "  # Network:"
    echo "  VPC: jamr-websites-vpc-prod"
    echo "  Subnet: jamr-websites-web-subnet"
    echo "  Region: australia-southeast1"
    echo "  Zone: australia-southeast1-a"
    echo
    echo "=========================================="
    echo "🔍 PREREQUISITES & SETUP"
    echo "=========================================="
    echo "  check              # Check prerequisites (gcloud, terraform, auth)"
    echo "  init               # Initialize Terraform"
    echo "  plan               # Plan infrastructure deployment"
    echo "  show               # Show Terraform outputs and status"
    echo "  status             # Show deployment status"
    echo
    echo "=========================================="
    echo "🚀 INFRASTRUCTURE DEPLOYMENT"
    echo "=========================================="
    echo "  apply              # Deploy ALL infrastructure (compute + database + networking)"
    echo "  destroy            # Destroy all infrastructure (⚠️ DESTRUCTIVE)"
    echo "  graph              # Generate infrastructure visualization graph"
    echo
    echo "=========================================="
    echo "🏗️  COMPONENT-SPECIFIC DEPLOYMENT"
    echo "=========================================="
    echo "  compute-deploy     # Deploy only compute resources (VM, disks, networking)"
    echo "  database-deploy    # Deploy only database resources (Cloud SQL, users)"
    echo "  wordpress-deploy   # Deploy only WordPress application configuration"
    echo
    echo "=========================================="
    echo "🌐 WORDPRESS APPLICATION MANAGEMENT"
    echo "=========================================="
    echo "  wp-deploy          # Deploy WordPress application (runs entrypoint.sh)"
    echo "  wp-stop            # Stop WordPress application"
    echo "  wp-start           # Start WordPress application"
    echo "  wp-status          # Check WordPress application status"
    echo "  wp-logs            # View WordPress application logs"
    echo "  wp-backup          # Create WordPress backup"
    echo
    echo "=========================================="
    echo "💻 COMPUTE RESOURCE MANAGEMENT"
    echo "=========================================="
    echo "  compute-stop       # Stop VM instances (save ~$6/month)"
    echo "  compute-start      # Start VM instances back up"
    echo "  component-status   # Check status of all components"
    echo
    echo "=========================================="
    echo "💰 COST OPTIMIZATION & RESOURCE CONTROL"
    echo "=========================================="
    echo "  winddown           # Stop ALL resources (VM + Cloud SQL) - save ~$15/month"
    echo "  windup             # Start all resources back up"
    echo "  windstatus         # Check winddown status"
    echo "  cost-estimate      # Estimate monthly cost savings"
    echo
    echo "=========================================="
    echo "🧹 MAINTENANCE & CLEANUP"
    echo "=========================================="
    echo "  Note: Docker image management and cleanup operations"
    echo "        have been moved to ./operations.sh"
    echo "  Use: ./operations.sh cleanup-images"
    echo "       ./operations.sh preview-cleanup"
    echo
    echo "=========================================="
    echo "🔒 HTTPS & SECURITY MANAGEMENT"
    echo "=========================================="
    echo "  wp-https-setup     # Automated HTTPS setup with Let's Encrypt (one-time)"
    echo "  Note: HTTPS status, testing, and renewal moved to ./operations.sh"
    echo "  Use: ./operations.sh https-status, https-test, https-renew, https-logs"
    echo
    echo "=========================================="
    echo "📋 COMMON USAGE EXAMPLES"
    echo "=========================================="
    echo "  # Initial deployment:"
    echo "  $0 check           # Verify you're ready to deploy"
    echo "  $0 init            # Initialize Terraform"
    echo "  $0 plan            # Review what will be deployed"
    echo "  $0 apply           # Deploy all infrastructure"
    echo "  $0 deploy-wordpress # Deploy WordPress app (runs entrypoint.sh)"
    echo
    echo "  # Daily operations:"
    echo "  $0 status          # Check current status"
    echo "  $0 app-status      # Check WordPress status"
    echo "  $0 app-logs        # View WordPress logs"
    echo
    echo "  # Cost optimization:"
    echo "  $0 compute-stop    # Stop VM (save ~$6/month)"
    echo "  $0 winddown        # Stop everything (save ~$15/month)"
    echo "  $0 windup          # Start everything back up"
    echo
    echo "  # Maintenance:"
    echo "  Note: Docker cleanup and operational tasks moved to ./operations.sh"
    echo "  $0 app-backup      # Create WordPress backup"
    echo "  $0 app-start       # Start WordPress application"
    echo
    echo "  # HTTPS setup:"
    echo "  $0 wp-https-setup  # Setup HTTPS automatically (reads from wordpress.tfvars)"
    echo "  Note: HTTPS monitoring and renewal moved to ./operations.sh"
}

# Function to generate infrastructure graph
generate_graph() {
    print_header "Generating Infrastructure Graph"
    
    # Check if graphviz is installed
    if ! command -v dot &> /dev/null; then
        print_warning "Graphviz not installed. Installing graphviz..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y graphviz
        elif command -v yum &> /dev/null; then
            sudo yum install -y graphviz
        elif command -v brew &> /dev/null; then
            brew install graphviz
        else
            print_error "Cannot install graphviz automatically. Please install it manually."
            print_status "Installation commands:"
            echo "  Ubuntu/Debian: sudo apt-get install graphviz"
            echo "  CentOS/RHEL: sudo yum install graphviz"
            echo "  macOS: brew install graphviz"
            echo "  Windows: Download from https://graphviz.org/download/"
            exit 1
        fi
    fi
    
    # Change to terraform directory
    cd "$TERRAFORM_DIR"
    
    # Create graphs directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/graphs"
    
    # Generate Terraform dependency graph
    print_status "Generating Terraform dependency graph..."
    terraform graph -var-file="wordpress.tfvars" | dot -Tsvg -o ../graphs/infrastructure-dependency.svg
    print_status "Dependency graph saved to: graphs/infrastructure-dependency.svg"
    
    # Generate resource graph
    print_status "Generating resource graph..."
    terraform graph -var-file="wordpress.tfvars" -type=plan | dot -Tsvg -o ../graphs/resource-graph.svg
    print_status "Resource graph saved to: graphs/resource-graph.svg"
    
    # Generate detailed graph with labels
    print_status "Generating detailed infrastructure graph..."
    terraform graph -var-file="wordpress.tfvars" | dot -Tsvg -Grankdir=TB -Gdpi=300 -Gfontsize=10 -o ../graphs/infrastructure-detailed.svg
    print_status "Detailed graph saved to: graphs/infrastructure-detailed.svg"
    
    # Generate PNG version for better compatibility
    print_status "Generating PNG versions..."
    terraform graph -var-file="wordpress.tfvars" | dot -Tpng -Gdpi=300 -o ../graphs/infrastructure-dependency.png
    terraform graph -var-file="wordpress.tfvars" -type=plan | dot -Tpng -Gdpi=300 -o ../graphs/resource-graph.png
    print_status "PNG graphs saved to graphs/ directory"
    
    # Generate text-based graph for console viewing
    print_status "Generating text-based graph..."
    terraform graph -var-file="wordpress.tfvars" | dot -Tplain > ../graphs/infrastructure-text.txt
    print_status "Text graph saved to: graphs/infrastructure-text.txt"
    
    # Return to script directory
    cd "$SCRIPT_DIR"
    
    print_status "All infrastructure graphs generated successfully!"
    echo
    echo "Generated files:"
    echo "  📊 SVG Graphs:"
    echo "    - graphs/infrastructure-dependency.svg"
    echo "    - graphs/resource-graph.svg"
    echo "    - graphs/infrastructure-detailed.svg"
    echo "  🖼️  PNG Graphs:"
    echo "    - graphs/infrastructure-dependency.png"
    echo "    - graphs/resource-graph.png"
    echo "  📝 Text Graph:"
    echo "    - graphs/infrastructure-text.txt"
    echo
    print_warning "Open SVG files in a web browser for best viewing experience"
}

# WordPress Management Functions
deploy_wordpress() {
    print_header "WordPress Deployment"
    print_status "Running WordPress deployment script..."
    "$SCRIPT_DIR/scripts/deploy-wordpress.sh" full
}

stop_wordpress() {
    print_header "Stopping WordPress"
    print_status "Running WordPress management script..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" stop
}

start_wordpress() {
    print_header "Starting WordPress"
    print_status "Running WordPress management script..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" start
}

view_wordpress_logs() {
    print_header "Viewing WordPress Logs"
    print_status "Running WordPress management script..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" logs
}

check_wordpress_status() {
    print_header "Checking WordPress Status"
    print_status "Running WordPress management script..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" status
}

backup_wordpress() {
    print_header "WordPress Backup"
    print_status "Running WordPress management script..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" backup
}

# Function to cleanup old Docker images
cleanup_docker_images() {
    print_header "Docker Image Cleanup"
    print_status "Cleaning up old Docker images to reduce costs..."
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    print_status "Current project: $CURRENT_PROJECT"
    
    # List current images
    print_status "Current Docker images in Container Registry:"
    gcloud container images list --repository=gcr.io/$CURRENT_PROJECT 2>/dev/null || {
        print_error "Failed to list images. Check if you have access to Container Registry."
        return 1
    }
    
    # Ask user which images to keep
    echo
    print_status "Image cleanup options:"
    echo "1. Keep only the latest 2 versions of each image"
    echo "2. Keep only the latest version of each image"
    echo "3. Remove all images except the current one"
    echo "4. Custom cleanup (manual selection)"
    echo "5. Cancel cleanup"
    
    read -p "Choose option (1-5): " cleanup_option
    
    case $cleanup_option in
        1)
            print_status "Keeping latest 2 versions of each image..."
            cleanup_keep_latest_versions 2
            ;;
        2)
            print_status "Keeping only latest version of each image..."
            cleanup_keep_latest_versions 1
            ;;
        3)
            print_status "Removing all images except current one..."
            cleanup_keep_current_only
            ;;
        4)
            print_status "Manual cleanup mode..."
            cleanup_manual_selection
            ;;
        5)
            print_status "Cleanup cancelled."
            return 0
            ;;
        *)
            print_error "Invalid option. Cleanup cancelled."
            return 1
            ;;
    esac
    
    print_status "Docker image cleanup completed!"
}

# Helper function to keep N latest versions
cleanup_keep_latest_versions() {
    local keep_count=$1
    print_status "Keeping latest $keep_count version(s) of each image..."
    
    # Get list of unique image names (without tags)
    local image_names=$(gcloud container images list --repository=gcr.io/$CURRENT_PROJECT --format="value(name)" | sort -u)
    
    for image_name in $image_names; do
        print_status "Processing image: $image_name"
        
        # Get all tags for this image, sorted by creation time (newest first)
        local all_tags=$(gcloud container images list-tags $image_name --format="value(tags)" --sort-by=timestamp)
        
        # Count total tags
        local total_tags=$(echo "$all_tags" | wc -l)
        print_status "  Total versions: $total_tags"
        
        # ALWAYS preserve the 'latest' tag if it exists
        local has_latest=$(echo "$all_tags" | grep -q "latest" && echo "yes" || echo "no")
        if [ "$has_latest" = "yes" ]; then
            print_status "  Preserving 'latest' tag (always kept)"
        fi
        
        if [ $total_tags -gt $keep_count ]; then
            # Get tags to remove (all except the latest N, but NEVER remove 'latest')
            local tags_to_remove=$(echo "$all_tags" | tail -n +$((keep_count + 1)) | grep -v "latest")
            local remove_count=$(echo "$tags_to_remove" | wc -l)
            
            if [ $remove_count -gt 0 ]; then
                print_status "  Removing $remove_count old version(s) (excluding 'latest' if present)..."
                
                for tag in $tags_to_remove; do
                    print_status "    Removing: $image_name:$tag"
                    gcloud container images delete "$image_name:$tag" --quiet 2>/dev/null || {
                        print_warning "    Failed to remove $image_name:$tag"
                    }
                done
            else
                print_status "  No cleanup needed (only 'latest' tag exists or all tags are recent)"
            fi
        else
            print_status "  No cleanup needed (only $total_tags version(s) exist)"
        fi
    done
}

# Helper function to keep only current image
cleanup_keep_current_only() {
    print_status "Keeping only the current production image..."
    
    # Get current project
    local current_project=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    
    # List all images
    local all_images=$(gcloud container images list --repository=gcr.io/$current_project --format="value(name)")
    
    for image in $all_images; do
        # Check if this image has a 'latest' tag - if so, keep it
        local has_latest_tag=$(gcloud container images list-tags $image --format="value(tags)" | grep -q "latest" && echo "yes" || echo "no")
        
        if [ "$has_latest_tag" = "yes" ]; then
            print_status "Keeping image with 'latest' tag: $image"
            continue
        fi
        
        # Check if this is the most recent image by timestamp
        local latest_image=$(gcloud container images list --repository=gcr.io/$current_project --format="value(name)" --sort-by=timestamp | head -1)
        
        if [ "$image" = "$latest_image" ]; then
            print_status "Keeping most recent image: $image"
            continue
        fi
        
        # Remove older images without 'latest' tag
        print_status "Removing older image: $image"
        gcloud container images delete "$image" --quiet 2>/dev/null || {
            print_warning "Failed to remove $image"
        }
    done
}

# Helper function for manual cleanup
cleanup_manual_selection() {
    print_status "Manual cleanup mode..."
    
    # List all images with details
    print_status "Available images:"
    gcloud container images list --repository=gcr.io/$CURRENT_PROJECT --format="table(name,tags,timestamp,digest"
    
    echo
    print_status "To manually remove images, use:"
    echo "  gcloud container images delete gcr.io/PROJECT/IMAGE:TAG --quiet"
    echo
    print_status "Example:"
    echo "  gcloud container images delete gcr.io/$CURRENT_PROJECT/fiverivers-tutoring:old-tag --quiet"
}

# Function to list current Docker images
list_docker_images() {
    print_header "Current Docker Images in Container Registry"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    print_status "Project: $CURRENT_PROJECT"
    echo
    
    # Try different approaches to list images
    print_status "Attempting to list Docker images..."
    
    # Method 1: Try with full repository path
    if gcloud container images list --repository=gcr.io/$CURRENT_PROJECT 2>/dev/null; then
        print_status "✅ Successfully listed images using repository method"
    else
        print_status "⚠️  Repository method failed, trying alternative approaches..."
        
        # Method 2: Try listing all repositories first
        print_status "Available repositories:"
        if gcloud container images list --repository=gcr.io 2>/dev/null | grep "$CURRENT_PROJECT"; then
            print_status "Found project repositories"
        else
            print_status "No repositories found for project: $CURRENT_PROJECT"
        fi
        
        # Method 3: Try with Artifact Registry (newer GCP service)
        print_status "Checking Artifact Registry..."
        if gcloud artifacts repositories list --location=australia-southeast1 2>/dev/null; then
            print_status "Found Artifact Registry repositories"
        else
            print_status "No Artifact Registry repositories found"
        fi
        
        # Method 4: Manual gcloud command suggestion
        echo
        print_status "Manual commands to try:"
        echo "  gcloud container images list --repository=gcr.io/$CURRENT_PROJECT"
        echo "  gcloud container images list --repository=gcr.io"
        echo "  gcloud artifacts repositories list --location=australia-southeast1"
        echo "  gcloud artifacts docker images list gcr.io/$CURRENT_PROJECT"
    fi
    
    echo
    print_status "Quick actions:"
    echo "  ./deploy.sh cleanup-images    # Clean up old images"
    echo "  ./deploy.sh list-images       # Show this list again"
    echo "  gcloud auth list              # Check authentication"
    echo "  gcloud config get-value project # Check current project"
}

# Function to preview cleanup (what would be deleted)
preview_cleanup() {
    print_header "Docker Image Cleanup Preview"
    print_status "This will show what would be deleted without actually removing anything..."
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    print_status "Current project: $CURRENT_PROJECT"
    
    # List current images
    print_status "Current Docker images in Container Registry:"
    gcloud container images list --repository=gcr.io/$CURRENT_PROJECT 2>/dev/null || {
        print_error "Failed to list images. Check if you have access to Container Registry."
        return 1
    }
    
    echo
    print_status "Cleanup preview options:"
    echo "1. Preview keeping latest 2 versions of each image"
    echo "2. Preview keeping only latest version of each image"
    echo "3. Preview removing all images except current one"
    echo "4. Cancel preview"
    
    read -p "Choose option (1-4): " preview_option
    
    case $preview_option in
        1)
            print_status "Preview: Keeping latest 2 versions of each image..."
            preview_keep_latest_versions 2
            ;;
        2)
            print_status "Preview: Keeping only latest version of each image..."
            preview_keep_latest_versions 1
            ;;
        3)
            print_status "Preview: Removing all images except current one..."
            preview_keep_current_only
            ;;
        4)
            print_status "Preview cancelled."
            return 0
            ;;
        *)
            print_error "Invalid option. Preview cancelled."
            return 1
            ;;
    esac
    
    echo
    print_status "Preview completed. Use './deploy.sh cleanup-images' to perform actual cleanup."
}

# Helper function to preview keeping N latest versions
preview_keep_latest_versions() {
    local keep_count=$1
    print_status "Preview: Would keep latest $keep_count version(s) of each image..."
    
    # Get list of unique image names (without tags)
    local image_names=$(gcloud container images list --repository=gcr.io/$CURRENT_PROJECT --format="value(name)" | sort -u)
    
    for image_name in $image_names; do
        print_status "Image: $image_name"
        
        # Get all tags for this image, sorted by creation time (newest first)
        local all_tags=$(gcloud container images list-tags $image_name --format="value(tags)" --sort-by=timestamp)
        
        # Count total tags
        local total_tags=$(echo "$all_tags" | wc -l)
        
        if [ $total_tags -gt $keep_count ]; then
            # Get tags that would be removed
            local tags_to_remove=$(echo "$all_tags" | tail -n +$((keep_count + 1)) | grep -v "latest")
            local remove_count=$(echo "$tags_to_remove" | wc -l)
            
            if [ $remove_count -gt 0 ]; then
                print_warning "  Would remove $remove_count old version(s):"
                echo "$tags_to_remove" | while read tag; do
                    echo "    - $tag"
                done
            else
                print_status "  No cleanup needed (only 'latest' tag exists or all tags are recent)"
            fi
        else
            print_status "  No cleanup needed (only $total_tags version(s) exist)"
        fi
        echo
    done
}

# Helper function to preview keeping only current image
preview_keep_current_only() {
    print_status "Preview: Would keep only the current production image..."
    
    # Get current project
    local current_project=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    
    # List all images
    local all_images=$(gcloud container images list --repository=gcr.io/$current_project --format="value(name)")
    
    for image in $all_images; do
        # Check if this image has a 'latest' tag
        local has_latest_tag=$(gcloud container images list-tags $image --format="value(tags)" | grep -q "latest" && echo "yes" || echo "no")
        
        if [ "$has_latest_tag" = "yes" ]; then
            print_status "Would keep (has 'latest' tag): $image"
        else
            # Check if this is the most recent image by timestamp
            local latest_image=$(gcloud container images list --repository=gcr.io/$current_project --format="value(name)" --sort-by=timestamp | head -1)
            
            if [ "$image" = "$latest_image" ]; then
                print_status "Would keep (most recent): $image"
            else
                print_warning "Would remove (older image): $image"
            fi
        fi
    done
}

# =============================================================================
# COMPONENT-SPECIFIC DEPLOYMENT
# =============================================================================

# Deploy compute resources only
deploy_compute() {
    print_header "Deploying Compute Resources Only"
    print_status "This will deploy VM instances, disks, and networking..."
    
    cd "$TERRAFORM_DIR"
    terraform init
    terraform plan -target=module.compute -var-file="wordpress.tfvars" -var-file="terraform.tfvars" -out=plans/compute-plan.tfplan
    
    if [ $? -eq 0 ]; then
        print_status "Compute plan created successfully!"
        read -p "Apply compute plan? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            terraform apply "plans/compute-plan.tfplan"
            print_status "Compute resources deployed successfully!"
        else
            print_status "Compute deployment cancelled."
        fi
    else
        print_error "Compute plan failed!"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Deploy WordPress application only
deploy_wordpress_app() {
    print_header "Deploying WordPress Application Only"
    print_status "This will deploy WordPress configuration and application..."
    
    cd "$TERRAFORM_DIR"
    terraform init
    terraform plan -target=module.wordpress -var-file="wordpress.tfvars" -var-file="terraform.tfvars" -out=plans/wordpress-plan.tfplan
    
    if [ $? -eq 0 ]; then
        print_status "WordPress plan created successfully!"
        read -p "Apply WordPress plan? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            terraform apply "plans/wordpress-plan.tfplan"
            print_status "WordPress application deployed successfully!"
        else
            print_status "WordPress deployment cancelled."
        fi
    else
        print_error "WordPress plan failed!"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Deploy database resources only
deploy_database() {
    print_header "Deploying Database Resources Only"
    print_status "This will deploy Cloud SQL database, users, and privileges..."
    
    cd "$TERRAFORM_DIR"
    terraform init
    terraform plan -target=module.database -var-file="wordpress.tfvars" -var-file="terraform.tfvars" -out=plans/database-plan.tfplan
    
    if [ $? -eq 0 ]; then
        print_status "Database plan created successfully!"
        read -p "Apply database plan? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            terraform apply "plans/database-plan.tfplan"
            print_status "Database resources deployed successfully!"
        else
            print_status "Database deployment cancelled."
        fi
    else
        print_error "Database plan failed!"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
}

# =============================================================================
# COMPONENT MANAGEMENT
# =============================================================================

# Stop compute resources only
stop_compute() {
    print_header "Stopping Compute Resources Only"
    print_status "This will stop VM instances for cost savings..."
    
    cd "$TERRAFORM_DIR"
    if [ -f "terraform.tfstate" ]; then
        print_warning "This will stop all compute resources!"
        read -p "Continue? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            # Stop the WordPress VM using gcloud directly
            gcloud compute instances stop jamr-websites-prod-wordpress --zone=australia-southeast1-a --project=storied-channel-467012-r6
            print_status "Compute resources stopped successfully!"
        else
            print_status "Compute stop cancelled."
        fi
    else
        print_error "No Terraform state found!"
    fi
    
    cd "$SCRIPT_DIR"
}

# Start compute resources only
start_compute() {
    print_header "Starting Compute Resources Only"
    print_status "This will start VM instances..."
    
    cd "$TERRAFORM_DIR"
    if [ -f "terraform.tfstate" ]; then
        # Start the WordPress VM using gcloud directly
        gcloud compute instances start jamr-websites-prod-wordpress --zone=australia-southeast1-a --project=storied-channel-467012-r6
        print_status "Compute resources started successfully!"
    else
        print_error "No Terraform state found!"
    fi
    
    cd "$SCRIPT_DIR"
}

# Check component status
check_component_status() {
    print_header "Component Status Check"
    
    cd "$TERRAFORM_DIR"
    
    if [ -f "terraform.tfstate" ]; then
        print_status "Checking Compute Status..."
        terraform output -json | jq -r '.wordpress_instance_name.value // "Not deployed"'
        
        print_status "Checking Database Status..."
        terraform output -json | jq -r '.wordpress_database_name.value // "Not deployed"'
        
        print_status "Checking WordPress Status..."
        terraform output -json | jq -r '.wordpress_deployment_status.value // "Not deployed"'
        
        print_status "Checking Overall Status..."
        terraform output -json | jq -r '.deployment_summary.value'
    else
        print_warning "No Terraform state found. Run 'terraform init' first."
    fi
    
    cd "$SCRIPT_DIR"
}

# =============================================================================
# WINDDOWN RESOURCE MANAGEMENT (Cost Optimization)
# =============================================================================

# Function to wind down resources (stop for cost savings)
winddown_resources() {
    print_header "Winding Down Resources for Cost Savings"
    print_status "Stopping WordPress VM and other resources..."
    
    # Stop WordPress VM
    "$SCRIPT_DIR/scripts/wordpress-management.sh" stop
    
    print_status "Stopping MySQL database for additional cost savings..."
    
    # Stop Cloud SQL instance (this will stop the MySQL database)
    if command -v gcloud &> /dev/null; then
        print_status "Stopping Cloud SQL instance: jamr-websites-db-prod"
        gcloud sql instances patch jamr-websites-db-prod \
            --activation-policy NEVER \
            --project storied-channel-467012-r6 \
            --quiet
        
        if [ $? -eq 0 ]; then
            print_status "MySQL database stopped successfully!"
            print_status "Additional monthly savings: ~$25 (database running 24/7 vs stopped)"
        else
            print_warning "Failed to stop MySQL database. It may already be stopped."
        fi
    else
        print_warning "gcloud CLI not found. Cannot stop MySQL database automatically."
        print_status "Manual stop required: gcloud sql instances patch jamr-websites-db-prod --activation-policy NEVER"
    fi
    
    print_status "Winddown complete! Resources are now stopped."
    print_warning "Run './deploy.sh windup' when you need resources again"
                    print_status "Total estimated monthly savings: ~$13 (VM + Database stopped)"
}

# Function to wind up resources (start after winddown)
windup_resources() {
    print_header "Winding Up Resources"
    print_status "Starting WordPress VM and other resources..."
    
    print_status "Starting MySQL database..."
    
    # Start Cloud SQL instance (this will start the MySQL database)
    if command -v gcloud &> /dev/null; then
        print_status "Starting Cloud SQL instance: jamr-websites-db-prod"
        gcloud sql instances patch jamr-websites-db-prod \
            --activation-policy ALWAYS \
            --project storied-channel-467012-r6 \
            --quiet
        
        if [ $? -eq 0 ]; then
            print_status "MySQL database started successfully!"
            print_status "Database will be ready in 2-3 minutes..."
        else
            print_warning "Failed to start MySQL database. It may already be running."
        fi
    else
        print_warning "gcloud CLI not found. Cannot start MySQL database automatically."
        print_status "Manual start required: gcloud sql instances patch jamr-websites-db-prod --activation-policy ALWAYS"
    fi
    
    print_status "Starting WordPress VM..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" start
    
    print_status "Starting other resources..."
    # Add more resource starting commands here as needed
    
    print_status "Windup complete! Resources are now running."
    print_warning "Note: Database may take 2-3 minutes to fully start up"
}

# Function to check winddown status
check_winddown_status() {
    print_header "Winddown Resource Status"
    
    print_status "Checking WordPress VM status..."
    "$SCRIPT_DIR/scripts/wordpress-management.sh" status
    
    print_status "Checking MySQL database status..."
    
    # Check Cloud SQL instance status
    if command -v gcloud &> /dev/null; then
        db_status=$(gcloud sql instances describe jamr-websites-db-prod \
            --project storied-channel-467012-r6 \
            --format="value(state)" 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            case "$db_status" in
                "RUNNABLE")
                    print_status "MySQL Database: RUNNING (Active)"
                    ;;
                "STOPPED")
                    print_status "MySQL Database: STOPPED (Winddown mode)"
                    ;;
                "PENDING_CREATE"|"MAINTENANCE")
                    print_status "MySQL Database: $db_status (Starting up...)"
                    ;;
                *)
                    print_status "MySQL Database: $db_status"
                    ;;
            esac
        else
            print_warning "Cannot determine MySQL database status"
        fi
    else
        print_warning "gcloud CLI not found. Cannot check MySQL database status"
    fi
    
    print_status "Checking other resource statuses..."
    # Add more resource status checks here as needed
    
    print_status "Winddown status check complete!"
}

# Function to estimate cost savings
estimate_cost_savings() {
    print_header "Cost Savings Estimation"
    
    print_status "Calculating estimated monthly cost savings from winddown..."
    
    # WordPress VM cost estimation (db-f1-micro equivalent)
    vm_monthly_cost=6   # Approximate cost for running e2-micro VM 24/7
    vm_stopped_cost=2   # Approximate cost for stopped VM (storage only)
    vm_savings=$((vm_monthly_cost - vm_stopped_cost))
    
    # MySQL Database cost estimation (Cloud SQL db-f1-micro)
    db_monthly_cost=7   # Approximate cost for running db-f1-micro 24/7
    db_stopped_cost=2   # Approximate cost for stopped Cloud SQL (storage only)
    db_savings=$((db_monthly_cost - db_stopped_cost))
    
    # Total savings and running costs
    total_savings=$((vm_savings + db_savings))
    total_running_cost=$((vm_monthly_cost + db_monthly_cost))
    total_stopped_cost=$((vm_stopped_cost + db_stopped_cost))
    
    # Verify calculation manually
    expected_total=$((6 + 7))
    print_status "Expected total: 6 + 7 = $expected_total"
    print_status "Actual total: $total_running_cost"
    
    print_status "=== CURRENT RUNNING COSTS ==="
    print_status "Total monthly cost (running 24/7): ~\$${total_running_cost}/month"
    print_status "Total monthly cost (winddown mode): ~\$${total_stopped_cost}/month"
    print_status ""
    
    print_status "=== COMPONENT BREAKDOWN ==="
    print_status "WordPress VM (e2-micro):"
    print_status "  - Running 24/7: ~\$${vm_monthly_cost}/month"
    print_status "  - Stopped (winddown): ~\$${vm_stopped_cost}/month"
    print_status "  - Potential savings: ~\$${vm_savings}/month"
    
    print_status "MySQL Database:"
    print_status "  - Running 24/7: ~\$${db_monthly_cost}/month"
    print_status "  - Stopped (winddown): ~\$${db_stopped_cost}/month"
    print_status "  - Potential savings: ~\$${db_savings}/month"
    
    print_status ""
    print_status "=== SUMMARY ==="
    print_status "Total estimated monthly savings: ~\$${total_savings}"
    print_status "Cost reduction: ~$(( (total_savings * 100) / total_running_cost ))%"
    print_warning "These are rough estimates. Actual costs may vary."
}

# =============================================================================
# HTTPS MANAGEMENT FUNCTIONS
# =============================================================================

# Function to check HTTPS status
check_https_status() {
    print_header "HTTPS Status Check"
    
    cd "$TERRAFORM_DIR"
    
    print_status "Checking HTTPS configuration..."
    
    # Get HTTPS status from Terraform
    if terraform output -json https_status 2>/dev/null | grep -q "Let's Encrypt configured"; then
        print_status "✅ HTTPS: ENABLED with Let's Encrypt"
        
        # Get domain information
        domain=$(terraform output -raw domain_name 2>/dev/null)
        if [ -n "$domain" ]; then
            print_status "Domain: $domain"
        fi
        
        # Get DNS nameservers
        nameservers=$(terraform output -json dns_nameservers 2>/dev/null)
        if [ -n "$nameservers" ] && [ "$nameservers" != "[]" ]; then
            print_status "DNS Nameservers:"
            echo "$nameservers" | jq -r '.[]' 2>/dev/null || echo "$nameservers"
        fi
        
        # Check firewall rules
        https_firewall=$(terraform output -raw https_firewall 2>/dev/null)
        if [ -n "$https_firewall" ]; then
            print_status "HTTPS Firewall: $https_firewall"
        fi
        
    else
        print_warning "⚠️  HTTPS: NOT CONFIGURED"
        print_status "Run: $0 https-setup to configure HTTPS"
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to test HTTPS connectivity
test_https_connectivity() {
    print_header "HTTPS Connectivity Test"
    
    cd "$TERRAFORM_DIR"
    
    # Get domain name
    domain=$(terraform output -raw domain_name 2>/dev/null)
    if [ -z "$domain" ]; then
        print_error "No domain configured. Run: $0 https-setup"
        cd "$SCRIPT_DIR"
        return 1
    fi
    
    print_status "Testing HTTPS connectivity for: $domain"
    
    # Test HTTP (port 80) - needed for Let's Encrypt validation
    print_status "Testing HTTP (port 80)..."
    if curl -s --connect-timeout 10 "http://$domain" >/dev/null 2>&1; then
        print_status "✅ HTTP (port 80): ACCESSIBLE"
    else
        print_warning "⚠️  HTTP (port 80): NOT ACCESSIBLE"
        print_warning "This may prevent Let's Encrypt validation"
    fi
    
    # Test HTTPS (port 443)
    print_status "Testing HTTPS (port 443)..."
    if curl -s --connect-timeout 10 "https://$domain" >/dev/null 2>&1; then
        print_status "✅ HTTPS (port 443): ACCESSIBLE"
        
        # Check SSL certificate
        print_status "Checking SSL certificate..."
        if openssl s_client -connect "$domain:443" -servername "$domain" </dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
            print_status "✅ SSL Certificate: VALID"
        else
            print_warning "⚠️  SSL Certificate: ISSUES DETECTED"
        fi
    else
        print_warning "⚠️  HTTPS (port 443): NOT ACCESSIBLE"
        print_warning "HTTPS may not be fully configured yet"
    fi
    
    cd "$SCRIPT_DIR"
}

# Function to renew SSL certificates
renew_ssl_certificates() {
    print_header "SSL Certificate Renewal"
    
    print_status "This will attempt to renew SSL certificates..."
    print_warning "Note: Let's Encrypt certificates auto-renew every 90 days"
    
    # Check if we can SSH to the VM
    vm_ip=$(cd "$TERRAFORM_DIR" && terraform output -raw wordpress_static_ip 2>/dev/null)
    if [ -z "$vm_ip" ]; then
        print_error "Cannot determine VM IP. Check Terraform state."
        return 1
    fi
    
    print_status "VM IP: $vm_ip"
    print_status "Attempting to connect and renew certificates..."
    
    # Try to SSH and renew (this is a simplified approach)
    print_warning "Manual renewal requires SSH access to the VM"
    print_status "You can manually SSH and run: sudo certbot renew"
    print_status "Or wait for automatic renewal (every 90 days)"
    
    print_status "SSL renewal check complete!"
}

# Function to view HTTPS logs
view_https_logs() {
    print_header "HTTPS Setup Logs"
    
    print_status "Checking for HTTPS-related logs..."
    
    # Check Terraform logs
    if [ -f "$TERRAFORM_DIR/terraform.log" ]; then
        print_status "Terraform logs (HTTPS-related):"
        grep -i "https\|ssl\|certificate\|dns" "$TERRAFORM_DIR/terraform.log" 2>/dev/null || print_warning "No HTTPS-related Terraform logs found"
    fi
    
    # Check for Cloud DNS logs
    print_status "Checking Cloud DNS status..."
    if command -v gcloud &> /dev/null; then
        gcloud dns managed-zones list --format="table(name,dnsName,visibility)" 2>/dev/null || print_warning "Cannot list DNS zones"
    fi
    
    # Check firewall rules
    print_status "Checking HTTPS firewall rules..."
    if command -v gcloud &> /dev/null; then
        gcloud compute firewall-rules list --filter="name~https" --format="table(name,network,allowed[].ports[],sourceRanges.list())" 2>/dev/null || print_warning "Cannot list firewall rules"
    fi
    
    print_status "HTTPS logs check complete!"
}

# Function to setup HTTPS interactively
setup_https_interactive() {
    print_header "Automated HTTPS Setup"
    
    print_status "Reading domain configuration from wordpress.tfvars..."
    
    # Check if HTTPS is already configured
    cd "$TERRAFORM_DIR"
    if terraform output -json https_status 2>/dev/null | grep -q "Let's Encrypt configured"; then
        print_warning "HTTPS is already configured!"
        print_status "Current status:"
        check_https_status
        cd "$SCRIPT_DIR"
        return 0
    fi
    cd "$SCRIPT_DIR"
    
    # Read domain configuration from wordpress.tfvars
    if [ -f "$TERRAFORM_DIR/wordpress.tfvars" ]; then
        # Extract domain name from wordpress.tfvars (remove comments and clean)
        domain_name=$(grep "domain_name" "$TERRAFORM_DIR/wordpress.tfvars" | cut -d'=' -f2 | sed 's/#.*$//' | tr -d ' "')
        admin_email=$(grep "admin_email" "$TERRAFORM_DIR/wordpress.tfvars" | cut -d'=' -f2 | sed 's/#.*$//' | tr -d ' "')
        
        if [ -z "$domain_name" ] || [ -z "$admin_email" ]; then
            print_error "Domain configuration not found in wordpress.tfvars"
            print_status "Please ensure domain_name and admin_email are set in wordpress.tfvars"
            return 1
        fi
        
        print_status "✅ Configuration loaded from wordpress.tfvars:"
        print_status "  Domain: $domain_name"
        print_status "  Email: $admin_email"
    else
        print_error "wordpress.tfvars not found"
        return 1
    fi
    
    # Deploy HTTPS infrastructure automatically
    echo
    print_status "🚀 Deploying HTTPS infrastructure automatically..."
    print_warning "This will create:"
    print_warning "  - Cloud DNS zone (~$0.40/month)"
    print_warning "  - Firewall rules for ports 80 & 443"
    print_warning "  - Automatic SSL certificate setup"
    
    print_status "Starting deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Check if HTTPS module is initialized, if not, run terraform init
    print_status "Checking if HTTPS module is initialized..."
    if ! terraform validate 2>/dev/null; then
        print_status "HTTPS module not initialized. Running terraform init..."
        if terraform init; then
            print_status "✅ Terraform initialized successfully"
        else
            print_error "Failed to initialize Terraform"
            cd "$SCRIPT_DIR"
            return 1
        fi
    fi
    
    # Plan the deployment
    print_status "Planning deployment..."
    if terraform plan -var-file="wordpress.tfvars"; then
        print_status "✅ Plan successful! Applying changes..."
        
        # Apply automatically without asking
        print_status "Applying HTTPS configuration..."
        if terraform apply -var-file="wordpress.tfvars" -auto-approve; then
            print_status "✅ HTTPS infrastructure deployed successfully!"
            echo
            print_status "🎉 Next steps:"
            print_status "1. Get DNS nameservers: $0 https-status"
            print_status "2. Update your domain's nameservers at your domain provider"
            print_status "3. Wait 5-10 minutes for DNS propagation"
            print_status "4. Test HTTPS: $0 https-test"
            echo
            print_status "Your site will be accessible at:"
            print_status "  - https://$domain_name"
            print_status "  - https://www.$domain_name"
        else
            print_error "HTTPS deployment failed"
            cd "$SCRIPT_DIR"
            return 1
        fi
    else
        print_error "HTTPS plan failed"
        cd "$SCRIPT_DIR"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Main function
main() {
    case "${1:-help}" in
        check)
            check_prerequisites
            ;;
        init)
            check_prerequisites
            init_terraform
            ;;
        plan)
            check_prerequisites
            plan_deployment
            ;;
        apply)
            check_prerequisites
            apply_deployment
            ;;
        show)
            show_outputs
            ;;
        status)
            show_status
            ;;
        destroy)
            destroy_infrastructure
            ;;
        graph)
            check_prerequisites
            generate_graph
            ;;
        # WordPress Application Commands
        wp-deploy|deploy-app|deploy-wordpress)
            deploy_wordpress
            ;;
        wp-stop|app-stop|stop-app|wordpress-stop)
            stop_wordpress
            ;;
        wp-start|app-start|start-app|wordpress-start)
            start_wordpress
            ;;
        wp-logs|app-logs|wordpress-logs)
            view_wordpress_logs
            ;;
        wp-status|app-status|wordpress-status)
            check_wordpress_status
            ;;
        wp-backup|app-backup|wordpress-backup)
            backup_wordpress
            ;;
        
        # Infrastructure Commands
        wp-infra-deploy|compute-deploy)
            deploy_compute
            ;;
        wp-db-deploy|database-deploy)
            deploy_database
            ;;
        wp-infra-stop|compute-stop)
            stop_compute
            ;;
        wp-infra-start|compute-start)
            start_compute
            ;;
        wp-infra-status|component-status)
            check_component_status
            ;;
        
        # Cost Optimization Commands
        wp-winddown|winddown)
            winddown_resources
            ;;
        wp-windup|windup)
            windup_resources
            ;;
        wp-windstatus|windstatus)
            check_winddown_status
            ;;
        wp-cost-estimate|cost-estimate)
            estimate_cost_savings
            ;;
        
        # HTTPS Commands
        wp-https-setup|https-setup)
            setup_https_interactive
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
