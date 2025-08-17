#!/bin/bash

# Five Rivers Tutoring - Operations Script
# This script handles day-to-day operations, maintenance, and cleanup

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

# Function to show help
show_help() {
    print_header "Operations Script Help"
    echo
    echo "This script handles day-to-day operations and maintenance tasks."
    echo "For infrastructure deployment, use ./deploy.sh instead."
    echo
    echo "=========================================="
    echo "📊 MONITORING & STATUS"
    echo "=========================================="
    echo "  status          # Check overall infrastructure status"
            echo "  wp-status       # Check WordPress application status"
        echo "  wp-logs         # View WordPress application logs"
            echo "  wp-start        # Start WordPress application"
        echo "  wp-stop         # Stop WordPress application"
        echo "  wp-restart      # Restart WordPress application"
        echo "  wp-backup       # Create WordPress backup"
        echo "  wp-restore      # Restore WordPress from backup"
    echo "  db-restart      # Restart database (Cloud SQL)"
    echo "  db-status       # Check database status"
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
    echo "  winddown           # Stop ALL resources (VM + Cloud SQL) - save ~$31/month"
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
    echo "  https-status       # Check HTTPS configuration status"
    echo "  https-test         # Test HTTPS connectivity"
    echo "  https-renew        # SSL certificate renewal information"
    echo "  https-logs         # HTTPS logs information"
    echo "  Note: HTTPS setup moved to ./deploy.sh wp-https-setup"
    echo
    echo "=========================================="
    echo "🔧 TROUBLESHOOTING & DEBUGGING"
    echo "=========================================="
    echo "  troubleshoot-ssh   # Diagnose SSH connectivity issues"
    echo "  debug-artifacts    # Debug Docker image registry issues"
    echo
    echo "=========================================="
    echo "📋 COMMON USAGE EXAMPLES"
    echo "=========================================="
    echo "  # WordPress management:"
    echo "  $0 wp-status       # Check WordPress status"
    echo "  $0 wp-restart      # Restart WordPress application"
    echo "  $0 wp-logs         # View WordPress logs"
    echo
    echo "  # Cost optimization:"
    echo "  $0 compute-stop    # Stop VM (save ~$6/month)"
    echo "  $0 winddown        # Stop everything (save ~$31/month)"
    echo "  $0 windup          # Start everything back up"
    echo
    echo "  # Troubleshooting:"
    echo "  $0 troubleshoot-ssh # Fix SSH connectivity issues"
    echo "  $0 component-status # Check all component statuses"
    echo
    echo "  # Maintenance:"
    echo "  $0 wp-backup       # Create WordPress backup"
    echo "  $0 cleanup-images  # Clean up old Docker images"
    echo
    echo "=========================================="
    echo "🚀 MOST FREQUENTLY USED COMMANDS"
    echo "=========================================="
    echo "  wp-status          # Check WordPress application status (daily)"
    echo "  wp-restart         # Restart WordPress application (when needed)"
    echo "  wp-logs            # View WordPress application logs (troubleshooting)"
    echo "  wp-start           # Start WordPress application"
    echo "  wp-stop            # Stop WordPress application"
    echo "  status             # Check overall infrastructure status (daily)"
    echo "  component-status   # Check all component statuses (overview)"
    echo "  db-status          # Check database connection status"
    echo "  https-status       # Check HTTPS certificate status"
    echo "  cleanup-images     # Clean up old Docker images"
    echo
    echo "=========================================="
    echo "💡 QUICK REFERENCE"
    echo "=========================================="
    echo "  # Daily operations: $0 wp-status && $0 status"
    echo "  # Troubleshooting: $0 wp-logs && $0 troubleshoot-ssh"
    echo "  # Cost savings: $0 winddown (stop) && $0 windup (start)"
    echo "  # Help: $0 help"
}

# =============================================================================
# DEBUG FUNCTIONS
# =============================================================================

# Function to debug Artifact Registry access
debug_artifacts() {
    print_header "Debug Artifact Registry Access"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    print_status "Current project: $CURRENT_PROJECT"
    
    # Test basic gcloud access
    print_status "Testing gcloud authentication..."
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
        print_status "✅ gcloud authenticated as: $(gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -1)"
    else
        print_error "❌ gcloud not authenticated"
        return 1
    fi
    
    # Test Container Registry access
    print_status "Testing Container Registry access..."
    if gcloud container images list --repository=gcr.io/$CURRENT_PROJECT 2>/dev/null; then
        print_status "✅ Container Registry access OK"
    else
        print_warning "⚠️  Container Registry access failed"
    fi
    
    # Test Artifact Registry access in different locations
    print_status "Testing Artifact Registry access..."
    local repo_path="gcr.io/$CURRENT_PROJECT/fiverivers-tutoring"
    
    for location in "us" "australia-southeast1" "europe-west1" "asia-east1"; do
        print_status "  Testing location: $location"
        
        # Test basic access
        if gcloud artifacts docker images list "$repo_path" --location=$location --limit=1 2>/dev/null; then
            print_status "    ✅ Access OK - Found images"
            
            # Count total images
            local count=$(gcloud artifacts docker images list "$repo_path" --location=$location --format="value(digest)" 2>/dev/null | wc -l)
            print_status "    📊 Total images found: $count"
            
            # Show sample images
            print_status "    📋 Sample images:"
            gcloud artifacts docker images list "$repo_path" --location=$location --limit=3 --format="table(digest,createTime,size" 2>/dev/null
            
            break
        else
            print_status "    ❌ Access failed"
        fi
    done
    
    # Test delete permission (dry run)
    print_status "Testing delete permissions..."
    local test_digest=$(gcloud artifacts docker images list "$repo_path" --location=us --limit=1 --format="value(digest)" 2>/dev/null | head -1)
    if [ -n "$test_digest" ]; then
        print_status "  Testing with digest: $test_digest"
        if gcloud artifacts docker images delete "$repo_path@$test_digest" --location=us --dry-run 2>/dev/null; then
            print_status "    ✅ Delete permission OK"
        else
            print_warning "    ⚠️  Delete permission failed"
        fi
    else
        print_warning "  No test digest available"
    fi
    
    print_status "Debug completed!"
}

# =============================================================================
# MONITORING & STATUS FUNCTIONS
# =============================================================================

# Function to check overall infrastructure status
check_status() {
    print_header "Infrastructure Status Check"
    
    # Check if we're in the right directory
    if [ ! -d "$SCRIPT_DIR/terraform" ]; then
        print_error "terraform/ directory not found. Please run this script from prod-deploy directory."
        exit 1
    fi
    
    # Check if Terraform is initialized
    if [ ! -f "$SCRIPT_DIR/terraform/.terraform/terraform.tfstate" ]; then
        print_warning "Terraform not initialized. Run './deploy.sh init' first."
        return 1
    fi
    
    # Change to terraform directory
    cd "$SCRIPT_DIR/terraform"
    
    # Check Terraform state
    print_status "Checking Terraform state..."
    terraform show -json | jq -r '.values.root_module.resources[] | "\(.type): \(.name) - \(.values.name // .values.id // "N/A")"' 2>/dev/null || {
        print_warning "Could not parse Terraform state. Checking basic status..."
        terraform show | head -20
    }
    
    # Return to script directory
    cd "$SCRIPT_DIR"
    
    print_status "Status check completed!"
}

# Function to check WordPress application status
check_app_status() {
    print_header "WordPress Application Status"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Checking WordPress VM status..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ -z "$VM_STATUS" ]; then
        print_error "Could not get VM status. Check if instance exists."
        return 1
    fi
    
    case "$VM_STATUS" in
        "RUNNING")
            print_status "✅ WordPress VM: RUNNING"
            
            # Check container status
            print_status "Checking WordPress container status..."
            CONTAINER_STATUS=$(gcloud compute ssh jamr-websites-prod-wordpress \
                --zone=australia-southeast1-a \
                --project="$CURRENT_PROJECT" \
                --command="docker ps --filter name=klt-wordpress-qayk --format '{{.Status}}'" \
                --quiet 2>/dev/null)
            
            if [ -n "$CONTAINER_STATUS" ]; then
                print_status "✅ WordPress Container: $CONTAINER_STATUS"
            else
                print_warning "⚠️  WordPress Container: Not running"
            fi
            
            # Check external IP
            EXTERNAL_IP=$(gcloud compute instances describe jamr-websites-prod-wordpress \
                --zone=australia-southeast1-a \
                --project="$CURRENT_PROJECT" \
                --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
            
            if [ -n "$EXTERNAL_IP" ]; then
                print_status "🌐 External IP: $EXTERNAL_IP"
            fi
            ;;
        "STOPPED")
            print_status "⏸️  WordPress VM: STOPPED"
            ;;
        "TERMINATED")
            print_status "❌ WordPress VM: TERMINATED"
            ;;
        *)
            print_status "❓ WordPress VM: $VM_STATUS"
            ;;
    esac
    
    print_status "WordPress application status check completed!"
}

# Function to view WordPress application logs
view_app_logs() {
    print_header "WordPress Application Logs"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Checking WordPress VM status..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "WordPress VM is not running (status: $VM_STATUS). Start the VM first."
        return 1
    fi
    
    print_status "VM is running. Fetching WordPress container logs..."
    
    # Get recent logs from the WordPress container
    if gcloud compute ssh jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --command="docker logs --tail=50 klt-wordpress-qayk 2>/dev/null || echo 'Container not found or no logs available'" \
        --quiet; then
        print_status "✅ WordPress container logs retrieved successfully!"
    else
        print_warning "⚠️  Could not retrieve container logs"
    fi
    
    print_status "WordPress application logs view completed!"
}

# Function to create WordPress backup
create_app_backup() {
    print_header "Creating WordPress Backup"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Creating WordPress backup..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "WordPress VM is not running (status: $VM_STATUS). Start the VM first."
        return 1
    fi
    
    # Create backup directory
    BACKUP_DIR="/tmp/wordpress-backup-$(date +%Y%m%d-%H%M%S)"
    
    print_status "Creating backup directory: $BACKUP_DIR"
    
    # SSH into VM and create backup
    if gcloud compute ssh jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --command="mkdir -p $BACKUP_DIR && docker exec klt-wordpress-qayk tar -czf $BACKUP_DIR/wordpress-content.tar.gz -C /var/www/html . 2>/dev/null || echo 'Backup creation failed'" \
        --quiet; then
        print_status "✅ WordPress backup created successfully!"
        print_status "Backup location: $BACKUP_DIR/wordpress-content.tar.gz"
    else
        print_warning "⚠️  Could not create WordPress backup"
    fi
    
    print_status "WordPress backup creation completed!"
}

# Function to restore WordPress from backup
restore_app_backup() {
    print_header "Restoring WordPress from Backup"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Restoring WordPress from backup..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "WordPress VM is not running (status: $VM_STATUS). Start the VM first."
        return 1
    fi
    
    # Ask for backup file path
    echo
    read -p "Enter backup file path (e.g., /tmp/wordpress-backup-20250101-120000/wordpress-content.tar.gz): " BACKUP_PATH
    
    if [ -z "$BACKUP_PATH" ]; then
        print_error "No backup path provided. Restore cancelled."
        return 1
    fi
    
    print_status "Restoring from backup: $BACKUP_PATH"
    
    # SSH into VM and restore backup
    if gcloud compute ssh jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --command="docker exec klt-wordpress-qayk tar -xzf $BACKUP_PATH -C /var/www/html --strip-components=1 2>/dev/null || echo 'Restore failed'" \
        --quiet; then
        print_status "✅ WordPress restore completed successfully!"
        print_status "Restart the container to apply changes: ./operations.sh wp-restart"
    else
        print_warning "⚠️  Could not restore WordPress from backup"
    fi
    
    print_status "WordPress restore operation completed!"
}

# =============================================================================
# DOCKER IMAGE MANAGEMENT FUNCTIONS
# =============================================================================

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
        print_status "✅ Successfully listed images from Container Registry"
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
    echo "  $0 cleanup-images    # Clean up old images"
    echo "  $0 list-images       # Show this list again"
    echo "  gcloud auth list              # Check authentication"
    echo "  gcloud config get-value project # Check current project"
}

# Function to cleanup old Docker images
cleanup_docker_images() {
    print_header "Docker Image Cleanup"
    print_status "Cleaning up old Docker images to reduce costs..."
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    print_status "Current project: $CURRENT_PROJECT"
    
    # Check both Container Registry and Artifact Registry
    print_status "Checking Container Registry (GCR)..."
    GCR_IMAGES=$(gcloud container images list --repository=gcr.io/$CURRENT_PROJECT 2>/dev/null)
    
    print_status "Checking Artifact Registry..."
    # Try multiple locations for Artifact Registry
    ARTIFACT_IMAGES=""
    for location in "us" "australia-southeast1" "europe-west1" "asia-east1"; do
        print_status "  Trying location: $location"
        ARTIFACT_IMAGES=$(gcloud artifacts docker images list gcr.io/$CURRENT_PROJECT/fiverivers-tutoring --location=$location 2>/dev/null)
        if [ -n "$ARTIFACT_IMAGES" ]; then
            print_status "  ✅ Found images in location: $location"
            break
        else
            print_status "  ❌ No images found in location: $location"
        fi
    done
    
    # Debug: Show what we found
    echo
    print_status "=== DEBUG INFO ==="
    print_status "GCR_IMAGES length: ${#GCR_IMAGES}"
    print_status "ARTIFACT_IMAGES length: ${#ARTIFACT_IMAGES}"
    print_status "=================="
    echo
    
    if [ -n "$GCR_IMAGES" ]; then
        print_status "Container Registry images found:"
        echo "$GCR_IMAGES"
    else
        print_status "No images found in Container Registry"
    fi
    
    if [ -n "$ARTIFACT_IMAGES" ]; then
        print_status "Artifact Registry images found:"
        echo "$ARTIFACT_IMAGES"
    else
        print_status "No images found in Artifact Registry"
    fi
    
    if [ -z "$GCR_IMAGES" ] && [ -z "$ARTIFACT_IMAGES" ]; then
        print_error "No Docker images found in either registry. Check project and permissions."
        return 1
    fi
    
    # Determine which registry to use for cleanup
    if [ -n "$ARTIFACT_IMAGES" ]; then
        print_status "Using Artifact Registry for cleanup (newer service)"
        REGISTRY_TYPE="artifact"
        REPO_PATH="gcr.io/$CURRENT_PROJECT/fiverivers-tutoring"
    else
        print_status "Using Container Registry for cleanup (legacy service)"
        REGISTRY_TYPE="container"
        REPO_PATH="gcr.io/$CURRENT_PROJECT"
    fi
    
    # Ask user which images to keep
    echo
    print_status "Image cleanup options:"
    echo "1. Keep only the latest 2 versions of each image"
    echo "2. Keep only latest version of each image"
    echo "3. Remove all images except current one"
    echo "4. Custom cleanup (manual selection)"
    echo "5. Cancel cleanup"
    
    read -p "Choose option (1-5): " choice
    
    case $choice in
        1)
            print_status "Keeping latest 2 version(s) of each image..."
            if [ "$REGISTRY_TYPE" = "artifact" ]; then
                cleanup_keep_latest_versions_artifact 2
            else
                cleanup_keep_latest_versions 2
            fi
            ;;
        2)
            print_status "Keeping latest 1 version(s) of each image..."
            if [ "$REGISTRY_TYPE" = "artifact" ]; then
                cleanup_keep_latest_versions_artifact 1
            else
                cleanup_keep_latest_versions 1
            fi
            ;;
        3)
            print_status "Keeping only current image..."
            if [ "$REGISTRY_TYPE" = "artifact" ]; then
                cleanup_keep_current_only_artifact
            else
                cleanup_keep_current_only
            fi
            ;;
        4)
            print_status "Manual cleanup..."
            if [ "$REGISTRY_TYPE" = "artifact" ]; then
                cleanup_manual_selection_artifact
            else
                cleanup_manual_selection
            fi
            ;;
        5)
            print_status "Cleanup cancelled."
            return 0
            ;;
        *)
            print_error "Invalid choice. Cancelling cleanup."
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
    print_status "Preview completed. Use '$0 cleanup-images' to perform actual cleanup."
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
# ARTIFACT REGISTRY CLEANUP FUNCTIONS
# =============================================================================

# Function to keep N latest versions in Artifact Registry
cleanup_keep_latest_versions_artifact() {
    local keep_count=$1
    local repo_path="gcr.io/$CURRENT_PROJECT/fiverivers-tutoring"
    
    # Try to detect the location
    local location="us"  # Default to US
    for loc in "us" "australia-southeast1" "europe-west1" "asia-east1"; do
        if gcloud artifacts docker images list "$repo_path" --location=$loc --limit=1 2>/dev/null | grep -q .; then
            location=$loc
            break
        fi
    done
    
    print_status "Keeping latest $keep_count version(s) of each image in Artifact Registry (location: $location)..."
    
    # Get all images sorted by creation time (newest first)
    local images=$(gcloud artifacts docker images list "$repo_path" --location=$location --format="table(digest,createTime)" --sort-by=createTime 2>/dev/null | tail -n +2)
    
    if [ -z "$images" ]; then
        print_warning "No images found in Artifact Registry"
        return 0
    fi
    
    # Count total images
    local total_images=$(echo "$images" | wc -l)
    print_status "Total images found: $total_images"
    
    if [ $total_images -le $keep_count ]; then
        print_status "Only $total_images images found, keeping all (no cleanup needed)"
        return 0
    fi
    
    # Calculate how many to remove
    local remove_count=$((total_images - keep_count))
    print_status "Will remove $remove_count old image(s), keeping $keep_count newest"
    
    # Get images to remove (oldest ones)
    local images_to_remove=$(echo "$images" | head -n $remove_count)
    
    print_status "Images to be removed:"
    echo "$images_to_remove"
    
    # Confirm deletion
    echo
    read -p "Are you sure you want to remove these $remove_count images? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_status "Cleanup cancelled."
        return 0
    fi
    
    # Remove old images
    local removed_count=0
    echo "$images_to_remove" | while read -r line; do
        local digest=$(echo "$line" | awk '{print $1}')
        if [ -n "$digest" ]; then
            print_status "Removing image: $digest"
            if gcloud artifacts docker images delete "$repo_path@$digest" --quiet 2>/dev/null; then
                print_status "✅ Removed: $digest"
                removed_count=$((removed_count + 1))
            else
                print_warning "⚠️  Failed to remove: $digest"
            fi
        fi
    done
    
    print_status "Cleanup completed! Removed $removed_count image(s)"
}

# Function to keep only current image in Artifact Registry
cleanup_keep_current_only_artifact() {
    local repo_path="gcr.io/$CURRENT_PROJECT/fiverivers-tutoring"
    
    # Try to detect the location
    local location="us"  # Default to US
    for loc in "us" "australia-southeast1" "europe-west1" "asia-east1"; do
        if gcloud artifacts docker images list "$repo_path" --location=$loc --limit=1 2>/dev/null | grep -q .; then
            location=$loc
            break
        fi
    done
    
    print_status "Keeping only current image in Artifact Registry (location: $location)..."
    
    # Get all images sorted by creation time (newest first)
    local images=$(gcloud artifacts docker images list "$repo_path" --location=$location --format="table(digest,createTime)" --sort-by=createTime 2>/dev/null | tail -n +2)
    
    if [ -z "$images" ]; then
        print_warning "No images found in Artifact Registry"
        return 0
    fi
    
    # Count total images
    local total_images=$(echo "$images" | wc -l)
    print_status "Total images found: $total_images"
    
    if [ $total_images -le 1 ]; then
        print_status "Only $total_images image found, keeping it (no cleanup needed)"
        return 0
    fi
    
    # Keep only the newest image
    local images_to_remove=$(echo "$images" | tail -n +2)
    local remove_count=$((total_images - 1))
    
    print_status "Will remove $remove_count old image(s), keeping 1 newest"
    
    print_status "Images to be removed:"
    echo "$images_to_remove"
    
    # Confirm deletion
    echo
    read -p "Are you sure you want to remove these $remove_count images? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_status "Cleanup cancelled."
        return 0
    fi
    
    # Remove old images
    local removed_count=0
    echo "$images_to_remove" | while read -r line; do
        local digest=$(echo "$line" | awk '{print $1}')
        if [ -n "$digest" ]; then
            print_status "Removing image: $digest"
            if gcloud artifacts docker images delete "$repo_path@$digest" --location=$location --quiet 2>/dev/null; then
                print_status "✅ Removed: $digest"
                removed_count=$((removed_count + 1))
            else
                print_warning "⚠️  Failed to remove: $digest"
            fi
        fi
    done
    
    print_status "Cleanup completed! Removed $removed_count image(s)"
}

# Function for manual selection cleanup in Artifact Registry
cleanup_manual_selection_artifact() {
    local repo_path="gcr.io/$CURRENT_PROJECT/fiverivers-tutoring"
    
    # Try to detect the location
    local location="us"  # Default to US
    for loc in "us" "australia-southeast1" "europe-west1" "asia-east1"; do
        if gcloud artifacts docker images list "$repo_path" --location=$loc --limit=1 2>/dev/null | grep -q .; then
            location=$loc
            break
        fi
    done
    
    print_status "Manual cleanup mode for Artifact Registry (location: $location)..."
    
    # List all images with details
    print_status "Available images:"
    gcloud artifacts docker images list "$repo_path" --location=$location --format="table(digest,createTime,updateTime,size" 2>/dev/null
    
    echo
    print_status "Enter the digest of each image you want to remove (one per line)"
    print_status "Press Enter twice when done, or type 'cancel' to abort:"
    
    local digests_to_remove=""
    while true; do
        read -p "Digest to remove (or Enter to finish): " digest
        if [ -z "$digest" ]; then
            break
        elif [ "$digest" = "cancel" ]; then
            print_status "Manual cleanup cancelled."
            return 0
        else
            digests_to_remove="$digests_to_remove$digest"$'\n'
        fi
    done
    
    if [ -z "$digests_to_remove" ]; then
        print_status "No images selected for removal."
        return 0
    fi
    
    # Confirm deletion
    echo
    print_status "Images to be removed:"
    echo "$digests_to_remove"
    
    read -p "Are you sure you want to remove these images? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_status "Manual cleanup cancelled."
        return 0
    fi
    
    # Remove selected images
    local removed_count=0
    echo "$digests_to_remove" | while read -r digest; do
        if [ -n "$digest" ]; then
            print_status "Removing image: $digest"
            if gcloud artifacts docker images delete "$repo_path@$digest" --location=$location --quiet 2>/dev/null; then
                print_status "✅ Removed: $digest"
                removed_count=$((removed_count + 1))
            else
                print_warning "⚠️  Failed to remove: $digest"
            fi
        fi
    done
    
    print_status "Manual cleanup completed! Removed $removed_count image(s)"
}

# =============================================================================
# COST OPTIMIZATION FUNCTIONS
# =============================================================================

# Function to stop compute resources
stop_compute() {
    print_header "Stopping Compute Resources"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Stopping WordPress VM..."
    
    # Stop the WordPress VM
    if gcloud compute instances stop jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --quiet; then
        print_status "✅ WordPress VM stopped successfully!"
        print_status "Estimated monthly savings: ~$6 (VM stopped)"
    else
        print_warning "⚠️  Could not stop WordPress VM"
    fi
    
    print_status "Compute resources stop operation completed!"
}

# Function to start compute resources
start_compute() {
    print_header "Starting Compute Resources"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Starting WordPress VM..."
    
    # Start the WordPress VM
    if gcloud compute instances start jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --quiet; then
        print_status "✅ WordPress VM started successfully!"
        print_status "VM will be ready in 1-2 minutes..."
    else
        print_warning "⚠️  Could not start WordPress VM"
    fi
    
    print_status "Compute resources start operation completed!"
}

# Function to check component status
check_component_status() {
    print_header "Component Status Check"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Checking WordPress VM status..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    case "$VM_STATUS" in
        "RUNNING")
            print_status "✅ WordPress VM: RUNNING"
            ;;
        "STOPPED")
            print_status "⏸️  WordPress VM: STOPPED"
            ;;
        "TERMINATED")
            print_status "❌ WordPress VM: TERMINATED"
            ;;
        *)
            print_status "❓ WordPress VM: $VM_STATUS"
            ;;
    esac
    
    print_status "Checking Cloud SQL database status..."
    
    # Check database status
    DB_STATUS=$(gcloud sql instances describe jamr-websites-db-prod \
        --project="$CURRENT_PROJECT" \
        --format="value(state)" 2>/dev/null)
    
    case "$DB_STATUS" in
        "RUNNABLE")
            print_status "✅ Cloud SQL Database: RUNNING"
            ;;
        "STOPPED")
            print_status "⏸️  Cloud SQL Database: STOPPED"
            ;;
        "PENDING_CREATE"|"MAINTENANCE")
            print_status "🔄 Cloud SQL Database: $DB_STATUS"
            ;;
        *)
            print_status "❓ Cloud SQL Database: $DB_STATUS"
            ;;
    esac
    
    print_status "Component status check completed!"
}

# Function to wind down resources for cost savings
wind_down() {
    print_header "Winding Down Resources for Cost Savings"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Stopping WordPress VM and other resources..."
    
    # Stop WordPress VM
    stop_compute
    
    print_status "Stopping MySQL database for additional cost savings..."
    
    # Stop Cloud SQL instance
    if gcloud sql instances patch jamr-websites-db-prod \
        --activation-policy NEVER \
        --project="$CURRENT_PROJECT" \
        --quiet; then
        print_status "✅ MySQL database stopped successfully!"
        print_status "Additional monthly savings: ~$25 (database running 24/7 vs stopped)"
    else
        print_warning "⚠️  Failed to stop MySQL database. It may already be stopped."
    fi
    
    print_status "Winddown complete! Resources are now stopped."
    print_warning "Run './operations.sh windup' when you need resources again"
    print_status "Total estimated monthly savings: ~$31 (VM + Database stopped)"
}

# Function to wind up resources after winddown
wind_up() {
    print_header "Winding Up Resources"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Starting MySQL database..."
    
    # Start Cloud SQL instance
    if gcloud sql instances patch jamr-websites-db-prod \
        --activation-policy ALWAYS \
        --project="$CURRENT_PROJECT" \
        --quiet; then
        print_status "✅ MySQL database started successfully!"
        print_status "Database will be ready in 2-3 minutes..."
    else
        print_warning "⚠️  Failed to start MySQL database. It may already be running."
    fi
    
    print_status "Starting WordPress VM..."
    start_compute
    
    print_status "Windup complete! Resources are now running."
    print_warning "Note: Database may take 2-3 minutes to fully start up"
}

# Function to check winddown status
check_wind_status() {
    print_header "Winddown Resource Status"
    
    # Check component status
    check_component_status
    
    print_status "Winddown status check completed!"
}

# Function to estimate cost savings
estimate_costs() {
    print_header "Cost Savings Estimation"
    
    print_status "Current resource costs (monthly estimates):"
    echo "  💻 WordPress VM (e2-micro): ~$6/month"
    echo "  🗄️  Cloud SQL Database: ~$25/month"
    echo "  🌐 Static IP: ~$0.50/month"
    echo "  📊 Total running cost: ~$31.50/month"
    echo
    print_status "Potential savings:"
    echo "  💰 VM stopped: ~$6/month"
    echo "  💰 Database stopped: ~$25/month"
    echo "  💰 Total winddown savings: ~$31/month"
    echo
    print_status "Cost optimization commands:"
    echo "  ./operations.sh compute-stop    # Stop VM only (~$6/month savings)"
    echo "  ./operations.sh winddown       # Stop everything (~$31/month savings)"
    echo "  ./operations.sh windup         # Start everything back up"
    
    print_status "Cost estimation completed!"
}

# =============================================================================
# HTTPS & SECURITY FUNCTIONS
# =============================================================================

# Function to check HTTPS status
check_https_status() {
    print_header "HTTPS Status Check"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Checking HTTPS configuration..."
    
    # Check if HTTPS firewall rule exists
    if gcloud compute firewall-rules describe jamr-websites-prod-https \
        --project="$CURRENT_PROJECT" >/dev/null 2>&1; then
        print_status "✅ HTTPS firewall rule: EXISTS"
    else
        print_status "❌ HTTPS firewall rule: NOT FOUND"
    fi
    
    # Check if HTTPS instance template exists
    if gcloud compute instance-templates describe jamr-websites-prod-wordpress-https-template \
        --project="$CURRENT_PROJECT" >/dev/null 2>&1; then
        print_status "✅ HTTPS instance template: EXISTS"
    else
        print_status "❌ HTTPS instance template: NOT FOUND"
    fi
    
    print_status "HTTPS status check completed!"
}

# Function to test HTTPS connectivity
test_https() {
    print_header "HTTPS Connectivity Test"
    
    print_status "Testing HTTPS connectivity..."
    
    # Get external IP
    EXTERNAL_IP=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project=storied-channel-467012-r6 \
        --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
    
    if [ -n "$EXTERNAL_IP" ]; then
        print_status "Testing HTTPS connection to $EXTERNAL_IP..."
        
        # Test HTTPS connection
        if curl -s -k --connect-timeout 10 "https://$EXTERNAL_IP" >/dev/null 2>&1; then
            print_status "✅ HTTPS connection successful!"
        else
            print_warning "⚠️  HTTPS connection failed"
        fi
    else
        print_error "Could not get external IP for testing"
    fi
    
    print_status "HTTPS connectivity test completed!"
}

# Function to renew SSL certificates
renew_https() {
    print_header "SSL Certificate Renewal"
    
    print_status "SSL certificate renewal requires manual intervention."
    print_status "Please check your Let's Encrypt configuration and renewal process."
    
    print_status "SSL certificate renewal information completed!"
}

# Function to view HTTPS logs
view_https_logs() {
    print_header "HTTPS Logs"
    
    print_status "HTTPS logs are typically available in the WordPress container."
    print_status "Use './operations.sh wp-logs' to view application logs."
    
    print_status "HTTPS logs information completed!"
}

# Function to restart database
restart_database() {
    print_header "Database Restart"
    
    print_status "Restarting Cloud SQL database..."
    
    # Get current project
    local current_project=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$current_project" = "NOT SET" ]; then
        print_error "GCP project not set. Run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    # List available Cloud SQL instances
    print_status "Available Cloud SQL instances:"
    gcloud sql instances list --project=$current_project --format="table(name,region,state,type,version" 2>/dev/null || {
        print_error "Failed to list Cloud SQL instances. Check permissions."
        return 1
    }
    
    # Ask user which instance to restart
    echo
    read -p "Enter the name of the Cloud SQL instance to restart: " instance_name
    
    if [ -z "$instance_name" ]; then
        print_error "No instance name provided."
        return 1
    fi
    
    # Confirm restart
    echo
    print_warning "⚠️  This will restart the Cloud SQL instance: $instance_name"
    print_warning "This may cause temporary downtime for your WordPress application."
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Database restart cancelled."
        return 0
    fi
    
    # Restart the instance
    print_status "Restarting Cloud SQL instance: $instance_name"
    gcloud sql instances restart $instance_name --project=$current_project 2>/dev/null || {
        print_error "Failed to restart Cloud SQL instance: $instance_name"
        return 1
    }
    
    print_status "Cloud SQL instance restart initiated successfully!"
    print_status "The instance is now restarting. This may take a few minutes."
    
    # Wait and check status
    print_status "Waiting for instance to come back online..."
    sleep 30
    
    # Check final status
    local final_status=$(gcloud sql instances describe $instance_name --project=$current_project --format="value(state)" 2>/dev/null)
    if [ "$final_status" = "RUNNABLE" ]; then
        print_status "✅ Database instance is now online and running!"
    else
        print_warning "⚠️  Database instance status: $final_status"
        print_status "Check the status manually with: gcloud sql instances describe $instance_name"
    fi
}

# Function to check database status
check_database_status() {
    print_header "Database Status Check"
    
    print_status "Checking Cloud SQL database status..."
    
    # Get current project
    local current_project=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$current_project" = "NOT SET" ]; then
        print_error "GCP project not set. Run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    # List all Cloud SQL instances with detailed status
    print_status "Cloud SQL Instances Status:"
    echo
    gcloud sql instances list --project=$current_project --format="table(name,region,state,type,version,connectionName,ipAddresses[0].ipAddress" 2>/dev/null || {
        print_error "Failed to list Cloud SQL instances. Check permissions."
        return 1
    }
    
    echo
    print_status "Database Connection Details:"
    echo "To connect to a database instance, use:"
    echo "  gcloud sql connect INSTANCE_NAME --user=root"
    echo
    print_status "For more detailed information about a specific instance:"
    echo "  gcloud sql instances describe INSTANCE_NAME"
}

# =============================================================================
# MAIN COMMAND PROCESSING
# =============================================================================

# Function to establish SSH connection with fallbacks
establish_ssh_connection() {
    local vm_name="$1"
    local zone="$2"
    local project="$3"
    local command="$4"
    
    print_status "Establishing SSH connection to $vm_name..."
    
    # Method 1: Try standard SSH first
    if gcloud compute ssh "$vm_name" \
        --zone="$zone" \
        --project="$project" \
        --command="$command" \
        --quiet 2>/dev/null; then
        return 0
    fi
    
    print_warning "Standard SSH failed, trying IAP tunneling..."
    
    # Method 2: Try IAP tunneling
    if gcloud compute ssh "$vm_name" \
        --zone="$zone" \
        --project="$project" \
        --command="$command" \
        --tunnel-through-iap \
        --quiet 2>/dev/null; then
        return 0
    fi
    
    print_warning "IAP tunneling failed, trying with troubleshooting..."
    
    # Method 3: Try with troubleshooting
    if gcloud compute ssh "$vm_name" \
        --zone="$zone" \
        --project="$project" \
        --command="$command" \
        --tunnel-through-iap \
        --troubleshoot \
        --quiet 2>/dev/null; then
        return 0
    fi
    
    print_error "All SSH methods failed. Using alternative approach..."
    return 1
}

# Function to execute command on VM with multiple fallbacks
execute_vm_command() {
    local vm_name="$1"
    local zone="$2"
    local project="$3"
    local command="$4"
    local fallback_message="$5"
    
    # Try SSH first
    if establish_ssh_connection "$vm_name" "$zone" "$project" "$command"; then
        return 0
    fi
    
    # Fallback: Use gcloud compute instances add-metadata for simple operations
    if [ -n "$fallback_message" ]; then
        print_warning "$fallback_message"
        print_status "Using alternative method: VM restart to apply changes"
        
        # Stop and start the VM to apply changes
        if gcloud compute instances stop "$vm_name" --zone="$zone" --project="$project" --quiet; then
            print_status "✅ VM stopped successfully"
            sleep 5
            if gcloud compute instances start "$vm_name" --zone="$zone" --project="$project" --quiet; then
                print_status "✅ VM started successfully"
                print_status "Changes will be applied when VM restarts"
                return 0
            else
                print_error "❌ Failed to start VM"
                return 1
            fi
        else
            print_error "❌ Failed to stop VM"
            return 1
        fi
    fi
    
    return 1
}

# Function to stop WordPress application
stop_app() {
    print_header "Stopping WordPress Application"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Stopping WordPress application..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_warning "WordPress VM is not running (status: $VM_STATUS)"
        return 0
    fi
    
    print_status "VM is running. Stopping WordPress container..."
    
    # Try to stop container via SSH, fallback to VM restart
    if execute_vm_command "jamr-websites-prod-wordpress" "australia-southeast1-a" "$CURRENT_PROJECT" \
        "docker stop klt-wordpress-qayk 2>/dev/null || echo 'Container not running'" \
        "SSH failed. Using VM restart to stop WordPress."; then
        print_status "✅ WordPress application stopped successfully!"
    else
        print_warning "⚠️  Could not stop WordPress application"
    fi
    
    print_status "WordPress application stopped!"
}

# Function to start WordPress application
start_app() {
    print_header "Starting WordPress Application"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Starting WordPress application..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "WordPress VM is not running (status: $VM_STATUS). Start the VM first."
        return 1
    fi
    
    print_status "VM is running. Starting WordPress container..."
    
    # Try to start container via SSH, fallback to VM restart
    if execute_vm_command "jamr-websites-prod-wordpress" "australia-southeast1-a" "$CURRENT_PROJECT" \
        "docker start klt-wordpress-qayk 2>/dev/null || echo 'Container not found'" \
        "SSH failed. Using VM restart to start WordPress."; then
        print_status "✅ WordPress application started successfully!"
    else
        print_warning "⚠️  Could not start WordPress application"
    fi
    
    print_status "WordPress application started!"
}

# Function to restart WordPress application
restart_app() {
    print_header "Restarting WordPress Application"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Restarting WordPress application..."
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "WordPress VM is not running (status: $VM_STATUS). Start the VM first."
        return 1
    fi
    
    print_status "VM is running. Restarting WordPress container..."
    
    # Try to restart container via SSH, fallback to VM restart
    if execute_vm_command "jamr-websites-prod-wordpress" "australia-southeast1-a" "$CURRENT_PROJECT" \
        "docker restart klt-wordpress-qayk 2>/dev/null || echo 'Container not found'" \
        "SSH failed. Using VM restart to restart WordPress."; then
        print_status "✅ WordPress application restarted successfully!"
        
        # Wait a moment and check status if SSH worked
        if establish_ssh_connection "jamr-websites-prod-wordpress" "australia-southeast1-a" "$CURRENT_PROJECT" \
            "docker ps --filter name=klt-wordpress-qayk --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"; then
            print_status "Container status:"
        fi
    else
        print_warning "⚠️  Could not restart WordPress application"
    fi
    
    print_status "WordPress application restarted!"
}

# Function to troubleshoot SSH connectivity
troubleshoot_ssh() {
    print_header "SSH Connectivity Troubleshooting"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "NOT SET")
    if [ "$CURRENT_PROJECT" = "NOT SET" ]; then
        print_error "Project not set. Please run 'gcloud config set project PROJECT_ID' first."
        return 1
    fi
    
    print_status "Current project: $CURRENT_PROJECT"
    
    # Check VM status
    VM_STATUS=$(gcloud compute instances describe jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --format="value(status)" 2>/dev/null)
    
    print_status "WordPress VM status: $VM_STATUS"
    
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "VM is not running. Start it first with: ./operations.sh compute-start"
        return 1
    fi
    
    # Check if IAP is enabled
    print_status "Checking IAP (Identity-Aware Proxy) configuration..."
    
    # Check firewall rules for IAP
    if gcloud compute firewall-rules describe jamr-websites-prod-ssh-access \
        --project="$CURRENT_PROJECT" >/dev/null 2>&1; then
        print_status "✅ IAP firewall rule exists"
    else
        print_warning "⚠️  IAP firewall rule not found"
    fi
    
    # Test different SSH methods
    print_status "Testing SSH connectivity methods..."
    
    # Method 1: Standard SSH
    print_status "1. Testing standard SSH..."
    if gcloud compute ssh jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --command="echo 'SSH test successful'" \
        --quiet 2>/dev/null; then
        print_status "✅ Standard SSH working"
        return 0
    else
        print_warning "❌ Standard SSH failed"
    fi
    
    # Method 2: IAP tunneling
    print_status "2. Testing IAP tunneling..."
    if gcloud compute ssh jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --command="echo 'IAP test successful'" \
        --tunnel-through-iap \
        --quiet 2>/dev/null; then
        print_status "✅ IAP tunneling working"
        return 0
    else
        print_warning "❌ IAP tunneling failed"
    fi
    
    # Method 3: With troubleshooting
    print_status "3. Testing with troubleshooting..."
    if gcloud compute ssh jamr-websites-prod-wordpress \
        --zone=australia-southeast1-a \
        --project="$CURRENT_PROJECT" \
        --command="echo 'Troubleshoot test successful'" \
        --tunnel-through-iap \
        --troubleshoot \
        --quiet 2>/dev/null; then
        print_status "✅ Troubleshoot mode working"
        return 0
    else
        print_warning "❌ Troubleshoot mode failed"
    fi
    
    # All methods failed
    print_error "All SSH methods failed. Here are troubleshooting steps:"
    echo
    print_status "Manual troubleshooting commands:"
    echo "  gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --tunnel-through-iap"
    echo "  gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --troubleshoot"
    echo "  gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --tunnel-through-iap --troubleshoot"
    echo
    print_status "Alternative: Use VM restart for WordPress operations:"
    echo "  ./operations.sh compute-stop && ./operations.sh compute-start"
    
    return 1
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Process commands
case "$1" in
    # Help
    help|--help|-h)
        show_help
        ;;
    
    # Monitoring & Status
    status)
        check_status
        ;;
            wp-status|app-status)
            check_app_status
            ;;
        wp-logs|app-logs)
            view_app_logs
            ;;
            wp-start|app-start)
            start_app
            ;;
        wp-stop|app-stop)
            stop_app
            ;;
        wp-restart|app-restart)
            restart_app
            ;;
        wp-backup|app-backup)
            create_app_backup
            ;;
        wp-restore|app-restore)
            restore_app_backup
            ;;
    db-restart)
        restart_database
        ;;
    db-status)
        check_database_status
        ;;
    
    # Docker Image Management
    list-images|show-images)
        list_docker_images
        ;;
    preview-cleanup)
        preview_cleanup
        ;;
    cleanup-images|cleanup-docker)
        cleanup_docker_images
        ;;
    
    # Cost Optimization
    compute-stop)
        stop_compute
        ;;
    compute-start)
        start_compute
        ;;
    winddown)
        wind_down
        ;;
    windup)
        wind_up
        ;;
    windstatus)
        check_wind_status
        ;;
    cost-estimate)
        estimate_costs
        ;;
    
    # HTTPS & Security
    https-status)
        check_https_status
        ;;
    https-test)
        test_https
        ;;
    https-renew)
        renew_https
        ;;
    https-logs)
        view_https_logs
        ;;
    
    # Debug
    debug-artifacts)
        debug_artifacts
        ;;
    troubleshoot-ssh)
        troubleshoot_ssh
        ;;
    
    # Unknown command
    *)
        print_error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac
