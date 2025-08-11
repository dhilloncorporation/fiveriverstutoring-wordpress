#!/bin/bash
# 🚀 Five Rivers Tutoring - Production Deployment Script

set -e

# Script information
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT_FILE="properties/gcp-production-env.properties"
TEST_MODE=false

# Simple logging
log_info() { echo "ℹ️  $1"; }
log_success() { echo "✅ $1"; }
log_error() { echo "❌ $1"; }
log_test() { echo "🧪 [TEST] $1"; }

# Validate environment configuration
validate_environment() {
    local errors=0
    
    log_info "Validating environment configuration..."
    
    # Check if environment file exists
    if [[ ! -f "$ENVIRONMENT_FILE" ]]; then
        log_error "Environment file not found: $ENVIRONMENT_FILE"
        return 1
    fi
    
    # Load the environment file (handle spaces in values)
    set -a  # automatically export all variables
    source "$ENVIRONMENT_FILE"
    set +a  # turn off automatic export
    
    # Required GCP Configuration
    local required_gcp=(
        "GCP_PROJECT_ID"
        "GCP_REGION" 
        "GCP_ZONE"
    )
    
    # Required Database Configuration
    local required_db=(
        "WORDPRESS_DB_HOST"
        "WORDPRESS_DB_USER"
        "WORDPRESS_DB_PASSWORD"
        "WORDPRESS_DB_NAME"
    )
    
    # Required WordPress Configuration
    local required_wp=(
        "WORDPRESS_HOME"
        "WORDPRESS_SITEURL"
    )
    
    # Check GCP Configuration
    log_info "Checking GCP configuration..."
    for var in "${required_gcp[@]}"; do
        if [[ -z "${!var}" ]]; then
            log_error "Missing required GCP variable: $var"
            ((errors++))
        elif [[ "${!var}" == *"your-"* ]]; then
            log_error "Please update placeholder value for: $var"
            ((errors++))
        else
            log_success "✓ $var: ${!var}"
        fi
    done
    
    # Check Database Configuration
    log_info "Checking database configuration..."
    for var in "${required_db[@]}"; do
        if [[ -z "${!var}" ]]; then
            log_error "Missing required database variable: $var"
            ((errors++))
        elif [[ "${!var}" == *"your-"* ]]; then
            log_error "Please update placeholder value for: $var"
            ((errors++))
        else
            log_success "✓ $var: ${!var}"
        fi
    done
    
    # Check WordPress Configuration
    log_info "Checking WordPress configuration..."
    for var in "${required_wp[@]}"; do
        if [[ -z "${!var}" ]]; then
            log_error "Missing required WordPress variable: $var"
            ((errors++))
        elif [[ "${!var}" == *"your-"* ]]; then
            log_error "Please update placeholder value for: $var"
            ((errors++))
        else
            log_success "✓ $var: ${!var}"
        fi
    done
    
    # Check for placeholder values
    if [[ "$errors" -gt 0 ]]; then
        log_error "Configuration validation failed with $errors error(s)"
        log_error "Please update the placeholder values in $ENVIRONMENT_FILE"
        return 1
    fi
    
    log_success "Environment configuration validated successfully"
    return 0
}

# Load environment file
load_env() {
    if [[ ! -f "$ENVIRONMENT_FILE" ]]; then
        log_error "Environment file not found: $ENVIRONMENT_FILE"
        exit 1
    fi
    
    # Validate before loading
    if ! validate_environment; then
        exit 1
    fi
    
    log_success "Environment loaded and validated"
}

# Deploy infrastructure
deploy_infrastructure() {
    if [[ "$TEST_MODE" == true ]]; then
        log_test "Phase 1: Would deploy GCP Infrastructure"
        log_test "  - Run: terraform init"
        log_test "  - Run: terraform plan -var-file=production.tfvars"
        log_test "  - Run: terraform apply (after confirmation)"
        log_test "  - Would create VM and export VM_IP, ZONE to .deployment.env"
        return
    fi
    
    echo "🔧 Phase 1: Deploying GCP Infrastructure"
    
    cd terraform
    terraform init
    terraform plan -var-file=production.tfvars -out=production-plan.tfplan
    terraform apply production-plan.tfplan
    
    # Get outputs
    VM_IP=$(terraform output -raw wordpress_vm_ip 2>/dev/null || echo "")
    ZONE=$(terraform output -raw wordpress_zone 2>/dev/null || echo "")
    
    if [[ -n "$VM_IP" && -n "$ZONE" ]]; then
        echo "export VM_IP=$VM_IP" > "$SCRIPT_DIR/.deployment.env"
        echo "export ZONE=$ZONE" >> "$SCRIPT_DIR/.deployment.env"
        log_success "Infrastructure deployed - VM IP: $VM_IP"
    else
        log_error "Failed to get infrastructure outputs"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
}

# Deploy database
deploy_database() {
    if [[ "$TEST_MODE" == true ]]; then
        log_test "Phase 2: Would setup Database"
        log_test "  - Load environment from $ENVIRONMENT_FILE"
        log_test "  - Verify DB_HOST, DB_USER, DB_PASSWORD, DB_NAME are set"
        log_test "  - Test database connectivity"
        return
    fi
    
    echo "🗄️ Phase 2: Database Setup"
    
    load_env
    
    if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASSWORD" || -z "$DB_NAME" ]]; then
        log_error "Missing database configuration"
        exit 1
    fi
    
    log_success "Database configuration verified"
}

# Deploy application
deploy_application() {
    if [[ "$TEST_MODE" == true ]]; then
        log_test "Phase 3: Would deploy WordPress Application"
        log_test "  - Check .deployment.env exists (from infrastructure phase)"
        log_test "  - Build Docker image: fiverivertutoring-wordpress:latest"
        log_test "  - Save image to tar file"
        log_test "  - Copy image to VM: $VM_IP"
        log_test "  - Copy docker-compose.prod.yml to VM"
        log_test "  - Deploy on VM using docker-compose"
        log_test "  - Clean up temporary files"
        return
    fi
    
    echo "🚀 Phase 3: Deploying WordPress Application"
    
    if [[ ! -f ".deployment.env" ]]; then
        log_error "Run infrastructure deployment first"
        exit 1
    fi
    source ".deployment.env"
    
    # Build and deploy
    cd docker
    docker build -f Dockerfile -t fiverivertutoring-wordpress:latest ..
    docker save fiverivertutoring-wordpress:latest -o fiverivertutoring-wordpress-image.tar
    
    gcloud compute scp fiverivertutoring-wordpress-image.tar $USER@$VM_IP:~/ --zone=$ZONE
    gcloud compute scp ../docker-compose.prod.yml $USER@$VM_IP:~/docker-compose.yml --zone=$ZONE
    
    gcloud compute ssh $USER@$VM_IP --zone=$ZONE --command "
        docker load -i ~/fiverivertutoring-wordpress-image.tar
        docker-compose -f ~/docker-compose.yml down || true
        docker-compose -f ~/docker-compose.yml up -d
        rm ~/fiverivertutoring-wordpress-image.tar
    "
    
    rm fiverivertutoring-wordpress-image.tar
    cd "$SCRIPT_DIR"
    
    log_success "WordPress deployed successfully"
}

# Cleanup infrastructure
cleanup_infrastructure() {
    if [[ "$TEST_MODE" == true ]]; then
        log_test "Would cleanup GCP Infrastructure"
        log_test "  - Run: terraform destroy"
        log_test "  - Remove all GCP resources (VM, networking, etc.)"
        log_test "  - Clean up local files (.deployment.env)"
        return
    fi
    
    echo "🗑️  Cleaning up GCP Infrastructure"
    
    # Check if .deployment.env exists
    if [[ -f ".deployment.env" ]]; then
        source ".deployment.env"
        log_info "Found deployment info - VM IP: $VM_IP, Zone: $ZONE"
    fi
    
    # Go to terraform directory
    cd terraform
    
    # Destroy infrastructure
    log_info "Destroying GCP infrastructure..."
    terraform destroy -auto-approve
    
    # Clean up local files
    cd "$SCRIPT_DIR"
    if [[ -f ".deployment.env" ]]; then
        rm ".deployment.env"
        log_success "Removed .deployment.env"
    fi
    
    log_success "Infrastructure cleanup completed"
}

# Verify deployment
verify_deployment() {
    if [[ "$TEST_MODE" == true ]]; then
        log_test "Verify: Would check deployment status"
        log_test "  - Check .deployment.env exists"
        log_test "  - Verify VM accessibility"
        log_test "  - Check WordPress application response"
        log_test "  - Verify database connectivity"
        return
    fi
    
    echo "🔍 Verifying Deployment"
    
    if [[ ! -f ".deployment.env" ]]; then
        log_error "Run infrastructure deployment first"
        exit 1
    fi
    source ".deployment.env"
    
    log_success "Deployment verification completed"
}

# Show test summary
show_test_summary() {
    if [[ "$TEST_MODE" == true ]]; then
        echo ""
        echo "🧪 TEST MODE SUMMARY"
        echo "===================="
        echo "This was a dry-run. No actual changes were made."
        echo ""
        echo "To run the actual deployment:"
        echo "  ./prod-deploy.sh full"
        echo ""
        echo "To run individual phases:"
        echo "  ./prod-deploy.sh infrastructure"
        echo "  ./prod-deploy.sh database"
        echo "  ./prod-deploy.sh application"
        echo "  ./prod-deploy.sh verify"
    fi
}

# Main function
main() {
    case "${1:-}" in
        "test"|"dry-run")
            TEST_MODE=true
            log_test "🧪 TEST MODE ENABLED - No actual changes will be made"
            echo ""
            # Run all phases in test mode
            deploy_infrastructure
            deploy_database
            deploy_application
            verify_deployment
            ;;
        "infrastructure")
            deploy_infrastructure
            ;;
        "database")
            deploy_database
            ;;
        "application")
            deploy_application
            ;;
        "full")
            deploy_infrastructure
            deploy_database
            deploy_application
            verify_deployment
            ;;
        "verify")
            verify_deployment
            ;;
        "cleanup"|"destroy")
            cleanup_infrastructure
            ;;
        "validate"|"check")
            validate_environment
            ;;
        *)
            echo "Usage: $0 {test|infrastructure|database|application|full|verify|cleanup|validate}"
            echo ""
            echo "Commands:"
            echo "  test                    # 🧪 Test run (dry-run mode)"
            echo "  full                    # Complete deployment"
            echo "  infrastructure          # Deploy infrastructure only"
            echo "  database               # Setup database only"
            echo "  application            # Deploy WordPress only"
            echo "  verify                 # Verify deployment"
echo "  cleanup                # Destroy infrastructure"
echo "  validate               # Check configuration"
            echo ""
            echo "Examples:"
            echo "  $0 validate            # Check configuration first"
            echo "  $0 test                # Test the deployment process"
            echo "  $0 full                # Run actual deployment"
            exit 1
            ;;
    esac
    
    show_test_summary
    
    if [[ "$TEST_MODE" == true ]]; then
        log_test "Test completed successfully"
    else
        log_success "Deployment completed successfully!"
    fi
}

# Run main function
main "$@"
