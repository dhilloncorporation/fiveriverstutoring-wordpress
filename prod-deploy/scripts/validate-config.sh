#!/bin/bash

# 🔍 Production Deployment - Configuration Validator
# This script validates all production deployment configurations

set -euo pipefail

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

# Configuration files to validate
CONFIG_FILES=(
    "../gcp-production-env.properties"
    "../terraform/production.tfvars"
    "../deployment/docker-compose.prod.yml"
)

# Required environment variables
REQUIRED_ENV_VARS=(
    "DB_HOST"
    "DB_USER"
    "DB_PASSWORD"
    "DB_NAME"
    "WORDPRESS_HOME"
    "WORDPRESS_SITEURL"
    "WP_ENVIRONMENT_TYPE"
)

# Required Terraform variables
REQUIRED_TERRAFORM_VARS=(
    "project_id"
    "region"
    "zone"
    "machine_type"
    "disk_size_gb"
)

# Validation results
VALIDATION_ERRORS=()
VALIDATION_WARNINGS=()

# Validate configuration file
validate_config_file() {
    local config_file=$1
    local config_type=$2
    
    log_step "Validating $config_type: $config_file"
    
    if [[ ! -f "$config_file" ]]; then
        VALIDATION_ERRORS+=("$config_type file not found: $config_file")
        return 1
    fi
    
    case "$config_type" in
        "Environment")
            validate_env_file "$config_file"
            ;;
        "Terraform")
            validate_terraform_file "$config_file"
            ;;
        "Docker Compose")
            validate_docker_compose_file "$config_file"
            ;;
        *)
            log_warning "Unknown config type: $config_type"
            ;;
    esac
}

# Validate environment file
validate_env_file() {
    local env_file=$1
    
    # Check for required variables
    for var in "${REQUIRED_ENV_VARS[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            VALIDATION_ERRORS+=("Missing required environment variable: $var")
        fi
    done
    
    # Check for empty values
    while IFS= read -r line; do
        if [[ $line =~ ^[A-Z_]+=$ ]]; then
            local var_name=$(echo "$line" | cut -d'=' -f1)
            VALIDATION_ERRORS+=("Environment variable has empty value: $var_name")
        fi
    done < "$env_file"
    
    # Check for proper URL format
    if grep -q "WORDPRESS_HOME=" "$env_file"; then
        local home_url=$(grep "^WORDPRESS_HOME=" "$env_file" | cut -d'=' -f2)
        if [[ ! "$home_url" =~ ^https?:// ]]; then
            VALIDATION_WARNINGS+=("WORDPRESS_HOME may not be a valid URL: $home_url")
        fi
    fi
    
    if grep -q "WORDPRESS_SITEURL=" "$env_file"; then
        local site_url=$(grep "^WORDPRESS_SITEURL=" "$env_file" | cut -d'=' -f2)
        if [[ ! "$site_url" =~ ^https?:// ]]; then
            VALIDATION_WARNINGS+=("WORDPRESS_SITEURL may not be a valid URL: $site_url")
        fi
    fi
    
    # Check for development URLs in production
    if grep -q "localhost:8082" "$env_file"; then
        VALIDATION_ERRORS+=("Development URL (localhost:8082) found in production config")
    fi
    
    if grep -q "localhost:8083" "$env_file"; then
        VALIDATION_WARNINGS+=("Staging URL (localhost:8083) found in production config")
    fi
}

# Validate Terraform variables file
validate_terraform_file() {
    local tfvars_file=$1
    
    # Check for required variables
    for var in "${REQUIRED_TERRAFORM_VARS[@]}"; do
        if ! grep -q "^${var}=" "$tfvars_file"; then
            VALIDATION_ERRORS+=("Missing required Terraform variable: $var")
        fi
    done
    
    # Check for empty values
    while IFS= read -r line; do
        if [[ $line =~ ^[a-z_]+=$ ]]; then
            local var_name=$(echo "$line" | cut -d'=' -f1)
            VALIDATION_ERRORS+=("Terraform variable has empty value: $var_name")
        fi
    done < "$tfvars_file"
    
    # Check for reasonable values
    if grep -q "machine_type=" "$tfvars_file"; then
        local machine_type=$(grep "^machine_type=" "$tfvars_file" | cut -d'=' -f2 | tr -d '"')
        if [[ "$machine_type" == "f1-micro" ]]; then
            VALIDATION_WARNINGS+=("Using f1-micro machine type - may be too small for production")
        fi
    fi
    
    if grep -q "disk_size_gb=" "$tfvars_file"; then
        local disk_size=$(grep "^disk_size_gb=" "$tfvars_file" | cut -d'=' -f2 | tr -d '"')
        if [[ "$disk_size" -lt 20 ]]; then
            VALIDATION_WARNINGS+=("Disk size $disk_size GB may be too small for production")
        fi
    fi
}

# Validate Docker Compose file
validate_docker_compose_file() {
    local compose_file=$1
    
    # Check if file exists and is readable
    if [[ ! -r "$compose_file" ]]; then
        VALIDATION_ERRORS+=("Docker Compose file not readable: $compose_file")
        return 1
    fi
    
    # Check for required services
    if ! grep -q "wordpress:" "$compose_file"; then
        VALIDATION_ERRORS+=("WordPress service not found in Docker Compose file")
    fi
    
    # Check for environment variables
    if ! grep -q "WORDPRESS_" "$compose_file"; then
        VALIDATION_WARNINGS+=("No WordPress environment variables found in Docker Compose file")
    fi
    
    # Check for proper port mapping
    if ! grep -q "80:" "$compose_file"; then
        VALIDATION_WARNINGS+=("Port 80 mapping not found in Docker Compose file")
    fi
}

# Validate directory structure
validate_directory_structure() {
    log_step "Validating directory structure"
    
    local required_dirs=(
        "terraform"
        "databasemigration"
        "deployment"
        "config"
        "docs"
        "scripts"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            VALIDATION_ERRORS+=("Required directory not found: $dir")
        fi
    done
}

# Validate script permissions
validate_script_permissions() {
    log_step "Validating script permissions"
    
    local scripts=(
        "deploy.sh"
        "scripts/common-functions.sh"
        "scripts/validate-config.sh"
        "databasemigration/production-deploy.sh"
        "deployment/deploy-on-vm.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if [[ ! -x "$script" ]]; then
                VALIDATION_WARNINGS+=("Script not executable: $script")
            fi
        else
            VALIDATION_WARNINGS+=("Script not found: $script")
        fi
    done
}

# Validate external dependencies
validate_dependencies() {
    log_step "Validating external dependencies"
    
    local commands=(
        "terraform"
        "gcloud"
        "docker"
        "mysql"
        "scp"
        "ssh"
    )
    
    for command in "${commands[@]}"; do
        if ! command -v "$command" >/dev/null 2>&1; then
            VALIDATION_WARNINGS+=("Command not available: $command")
        fi
    done
}

# Print validation summary
print_validation_summary() {
    echo
    log_info "🔍 Configuration Validation Summary"
    echo "======================================"
    
    if [[ ${#VALIDATION_ERRORS[@]} -eq 0 && ${#VALIDATION_WARNINGS[@]} -eq 0 ]]; then
        log_success "✅ All configurations are valid!"
        return 0
    fi
    
    if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
        echo
        log_error "❌ Validation Errors (${#VALIDATION_ERRORS[@]}):"
        for error in "${VALIDATION_ERRORS[@]}"; do
            echo "   • $error"
        done
    fi
    
    if [[ ${#VALIDATION_WARNINGS[@]} -gt 0 ]]; then
        echo
        log_warning "⚠️  Validation Warnings (${#VALIDATION_WARNINGS[@]}):"
        for warning in "${VALIDATION_WARNINGS[@]}"; do
            echo "   • $warning"
        done
    fi
    
    echo
    if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
        log_error "Configuration validation failed with ${#VALIDATION_ERRORS[@]} errors"
        return 1
    else
        log_warning "Configuration validation passed with ${#VALIDATION_WARNINGS[@]} warnings"
        return 0
    fi
}

# Main validation function
main() {
    log_info "🔍 Starting Production Deployment Configuration Validation"
    
    # Change to script directory
    cd "$SCRIPT_DIR/.."
    
    # Run all validations
    validate_directory_structure
    validate_script_permissions
    validate_dependencies
    
    # Validate configuration files
    validate_config_file "../gcp-production-env.properties" "Environment"
    validate_config_file "../terraform/production.tfvars" "Terraform"
    validate_config_file "../deployment/docker-compose.prod.yml" "Docker Compose"
    
    # Print summary
    print_validation_summary
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
