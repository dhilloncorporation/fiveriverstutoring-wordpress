#!/bin/bash

# WordPress Management Script for Five Rivers Tutoring
# Manages WordPress container on GCP VM
# 
# USAGE:
# - Direct usage: ./wordpress-management.sh [COMMAND]
# - Called by deploy.sh: ./deploy.sh wp-deploy (calls this script)
# - This script handles both direct WordPress management and deployment

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VM_NAME="jamr-websites-prod-wordpress"
ZONE="australia-southeast1-a"

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

# Function to check VM status
check_vm_status() {
    print_status "Checking VM status..."
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)" 2>/dev/null || echo "NOT_FOUND")
    
    if [ "$VM_STATUS" = "NOT_FOUND" ]; then
        print_error "VM $VM_NAME not found in zone $ZONE"
        return 1
    fi
    
    print_status "VM Status: $VM_STATUS"
    return 0
}

# Function to start WordPress
start_wordpress() {
    print_header "Starting WordPress"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    # Start VM if not running
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)")
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_status "Starting VM..."
        gcloud compute instances start "$VM_NAME" --zone="$ZONE"
        print_status "Waiting for VM to start..."
        sleep 30
    fi
    
    print_status "WordPress should be starting automatically..."
    print_status "Access at: http://$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")"
}

# Function to stop WordPress
stop_wordpress() {
    print_header "Stopping WordPress"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    print_warning "This will stop the entire VM, not just WordPress!"
    read -p "Are you sure you want to stop the VM? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping VM..."
        gcloud compute instances stop "$VM_NAME" --zone="$ZONE"
        print_status "VM stopped successfully!"
        print_status "Cost savings: ~$18-24/month while stopped"
    else
        print_status "Operation cancelled"
    fi
}

# Function to restart WordPress
restart_wordpress() {
    print_header "Restarting WordPress"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    print_status "Restarting VM to restart WordPress..."
    gcloud compute instances reset "$VM_NAME" --zone="$ZONE"
    print_status "Waiting for VM to restart..."
    sleep 60
    
    print_status "WordPress should be accessible at: http://$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")"
}

# Function to view WordPress logs
view_wordpress_logs() {
    print_header "Viewing WordPress Logs"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)")
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "VM is not running. Start it first with: $0 start"
        exit 1
    fi
    
    print_status "Fetching WordPress container logs..."
    gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="docker logs wordpress --tail=50"
}

# Function to check WordPress status
check_wordpress_status() {
    print_header "Checking WordPress Status"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)")
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_status "VM Status: $VM_STATUS"
        print_status "WordPress is not accessible (VM not running)"
        return
    fi
    
    print_status "VM Status: $VM_STATUS"
    print_status "IP Address: $(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")"
    
    # Check container status
    print_status "Checking WordPress container status..."
    gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="docker ps --filter name=wordpress --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    
    # Test WordPress accessibility
    IP_ADDRESS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    print_status "Testing WordPress accessibility..."
    if curl -s --connect-timeout 10 "http://$IP_ADDRESS" > /dev/null; then
        print_status "✅ WordPress is accessible at http://$IP_ADDRESS"
    else
        print_warning "⚠️  WordPress might not be fully started yet"
        print_status "Try again in a few minutes or check logs with: $0 logs"
    fi
}

# Function to deploy WordPress with direct image transfer
deploy_wordpress() {
    print_header "Deploying WordPress with Direct Image Transfer"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)")
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_status "Starting VM first..."
        gcloud compute instances start "$VM_NAME" --zone="$ZONE"
        print_status "Waiting for VM to start..."
        sleep 30
    fi
    
    print_status "Deploying WordPress using direct image transfer..."
    
    # Step 1: Check if image transfer is needed
    print_status "Step 1: Checking if image transfer is needed..."
    
    LOCAL_IMAGE="fiverivertutoring-wordpress:production"
    
    print_status "Local image: $LOCAL_IMAGE"
    
    # Check if local image exists
    if ! docker images | grep -q "fiverivertutoring-wordpress.*production"; then
        print_error "Local image '$LOCAL_IMAGE' not found!"
        print_status "Please build the image first with: cd docker && ./build-environments.sh production"
        exit 1
    fi
    
    # Check if image already exists on VM
    print_status "Checking if image already exists on VM..."
    IMAGE_EXISTS_ON_VM=$(gcloud compute ssh "$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="docker images | grep -q 'fiverivertutoring-wordpress.*production' && echo 'EXISTS' || echo 'NOT_EXISTS'" 2>/dev/null || echo "NOT_EXISTS")
    
    if [ "$IMAGE_EXISTS_ON_VM" = "EXISTS" ]; then
        print_status "✅ Image already exists on VM - skipping transfer!"
        SKIP_TRANSFER=true
    else
        print_status "📦 Image not found on VM - will transfer..."
        SKIP_TRANSFER=false
        
        # Save image to tar file for transfer
        print_status "Saving image to tar file..."
        docker save "$LOCAL_IMAGE" > /tmp/fiverivertutoring-wordpress-production.tar
        
        if [ $? -eq 0 ]; then
            print_status "✅ Image saved to tar file successfully!"
        else
            print_error "❌ Failed to save image to tar file"
            exit 1
        fi
    fi
    
    # Step 2: Deploy to VM
    print_status "Step 2: Deploying to GCP VM..."
    
    # Copy files to VM
    print_status "Copying deployment files to VM..."
    
    # Create the directory on VM first (detect VM user dynamically)
    print_status "Creating deployment directory on VM..."
    
    # Use the correct VM user (hardcoded for reliability)
    print_status "Setting VM user..."
    VM_USER="dhilloncorporations"
    print_status "VM user set to: $VM_USER"
    print_status "Full user details: $VM_USER@$VM_NAME"
    print_status "SSH command: gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE --tunnel-through-iap"
    
    gcloud compute ssh "$VM_USER@$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
        # Use current SSH user's home directory (should be dhilloncorporations)
        USER_HOME=\"/home/$VM_USER\"
        DEPLOY_DIR=\"\$USER_HOME/wordpress\"
        mkdir -p \"\$DEPLOY_DIR\" && \
        chmod 755 \"\$DEPLOY_DIR\" && \
        echo \"Deployment directory created: \$DEPLOY_DIR\"
    "
    
    # Check if directory creation was successful
    if [ $? -eq 0 ]; then
        print_status "✅ Directory created successfully on VM"
    else
        print_warning "⚠️  Directory creation may have failed, but continuing..."
    fi
    
    # Generate clean Docker environment file from properties
    print_status "Generating clean Docker environment file..."
    if [ -f "./generate-docker-env.sh" ]; then
        bash "./generate-docker-env.sh"
        if [ $? -eq 0 ]; then
            print_status "✅ Environment file generated successfully"
        else
            print_status "⚠️  Environment file generation failed, continuing with existing file"
        fi
    else
        print_warning "⚠️  Environment generator script not found, using existing file"
    fi
    
    # Copy the generated clean environment file
    print_status "Copying clean environment file..."
    
    # Check if the clean properties file exists locally
    if [ ! -f "../properties/fiverivertutoring-wordpress-clean.properties" ]; then
        print_error "Clean properties file not found locally. Regenerating..."
        bash "./generate-docker-env.sh"
    fi
    
    # Copy the file directly to the final destination using gcloud scp
    print_status "Copying clean properties file directly to VM..."
    gcloud compute scp "../properties/fiverivertutoring-wordpress-clean.properties" "$VM_USER@$VM_NAME:/home/$VM_USER/wordpress/fiverivertutoring-wordpress-clean.properties" --zone="$ZONE" --tunnel-through-iap
    
    # Verify the file was copied successfully
    gcloud compute ssh "$VM_USER@$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
        # Check if file exists and show details
        if [ -f \"/home/$VM_USER/wordpress/fiverivertutoring-wordpress-clean.properties\" ]; then
            echo '✅ Properties file copied successfully to final location'
            ls -la \"/home/$VM_USER/wordpress/fiverivertutoring-wordpress-clean.properties\"
        else
            echo '❌ Properties file not found in final location'
            exit 1
        fi
    "
    
    # Copy the Docker image tar file (only if needed)
    if [ "$SKIP_TRANSFER" = "false" ]; then
        print_status "Copying Docker image to VM..."
        gcloud compute scp /tmp/fiverivertutoring-wordpress-production.tar "$VM_NAME:/tmp/" --zone="$ZONE" --tunnel-through-iap
    else
        print_status "Skipping image copy - already exists on VM"
    fi
    
    # Step 3: Deploy using Docker Run
    print_status "Step 3: Starting WordPress with Docker Run..."
    gcloud compute ssh "$VM_USER@$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
        # Use detected VM user
        USER_HOME=\"/home/$VM_USER\"
        DEPLOY_DIR=\"\$USER_HOME/wordpress\"
        
        cd \"\$DEPLOY_DIR\" &&
        echo 'Stopping any existing containers...' &&
        docker stop fiverivers-wp-prod || true &&
        docker rm fiverivers-wp-prod || true &&
        echo 'Starting WordPress with Docker Run...' &&
        docker run -d \\
            --name fiverivers-wp-prod \\
            --restart always \\
            --env-file \"\$DEPLOY_DIR/fiverivertutoring-wordpress-clean.properties\" \\
            -p 80:80 \\
            -v fiverivers_uploads:/var/www/html/wp-content/uploads \\
            -v fiverivers_cache:/var/www/html/wp-content/cache \\
            fiverivertutoring-wordpress:production &&
        echo 'Deployment completed!'
    "
    
    # Cleanup temporary files
    rm -f /tmp/fiverivertutoring-wordpress-production.tar
    
    print_status "✅ WordPress deployment completed!"
    print_status "🌐 Access at: http://$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")"
    print_status "📦 Image: $LOCAL_IMAGE (transferred directly)"
}

# Function to backup WordPress
backup_wordpress() {
    print_header "Backing Up WordPress"
    
    if ! check_vm_status; then
        exit 1
    fi
    
    VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)")
    if [ "$VM_STATUS" != "RUNNING" ]; then
        print_error "VM is not running. Start it first with: $0 start"
        exit 1
    fi
    
    BACKUP_DATE=$(date +"%Y%m%d_%H%M%S")
    BACKUP_NAME="wordpress_backup_$BACKUP_DATE"
    
    print_status "Creating backup: $BACKUP_NAME"
    
    # Create backup of wp-content
    gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="
        cd /mnt/disks/wp-content && 
        tar -czf /tmp/$BACKUP_NAME.tar.gz . &&
        echo 'Backup created: /tmp/$BACKUP_NAME.tar.gz'
    "
    
    # Download backup to local machine
    print_status "Downloading backup to local machine..."
    gcloud compute scp "$VM_NAME:/tmp/$BACKUP_NAME.tar.gz" "./$BACKUP_NAME.tar.gz" --zone="$ZONE"
    
    print_status "Backup completed: $BACKUP_NAME.tar.gz"
}

# Function to show help
show_help() {
    echo "WordPress Management Script for Five Rivers Tutoring"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy          Deploy WordPress with direct image transfer (recommended)"
    echo "  start           Start WordPress (start VM if needed)"
    echo "  stop            Stop WordPress (stop entire VM)"
    echo "  restart         Restart WordPress (restart VM)"
    echo "  status          Check WordPress and VM status"
    echo "  logs            View WordPress container logs"
    echo "  backup          Create backup of wp-content"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy       # Deploy WordPress with direct image transfer"
    echo "  $0 start        # Start WordPress"
    echo "  $0 status       # Check status"
    echo "  $0 logs         # View logs"
    echo "  $0 backup       # Create backup"
    echo ""
    echo "Cost Management:"
    echo "  $0 stop         # Stop VM to save ~$18-24/month"
    echo "  $0 start        # Start VM when needed"
}

# Main function
main() {
    case "${1:-help}" in
        deploy)
            deploy_wordpress
            ;;
        start)
            start_wordpress
            ;;
        stop)
            stop_wordpress
            ;;
        restart)
            restart_wordpress
            ;;
        status)
            check_wordpress_status
            ;;
        logs)
            view_wordpress_logs
            ;;
        backup)
            backup_wordpress
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
