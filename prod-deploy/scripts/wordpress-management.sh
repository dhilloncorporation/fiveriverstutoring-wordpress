#!/bin/bash

# WordPress Management Script for Five Rivers Tutoring
# Manages WordPress container on GCP VM

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
    echo "  start           Start WordPress (start VM if needed)"
    echo "  stop            Stop WordPress (stop entire VM)"
    echo "  restart         Restart WordPress (restart VM)"
    echo "  status          Check WordPress and VM status"
    echo "  logs            View WordPress container logs"
    echo "  backup          Create backup of wp-content"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
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
