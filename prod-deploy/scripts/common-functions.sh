#!/bin/bash

# 🚀 Production Deployment - Common Functions Library
# This file contains shared functions used across production deployment scripts

set -euo pipefail

# Colors for output (Windows compatible)
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ $1"
}

log_step() {
    echo "🔧 $1"
}

# Error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Error occurred in script at line $line_number (exit code: $exit_code)"
    exit $exit_code
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Validation functions
validate_environment() {
    local required_vars=("$@")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Missing required environment variables: ${missing_vars[*]}"
        return 1
    fi
    
    log_success "Environment validation passed"
    return 0
}

# Database connection test
test_database_connection() {
    local host=$1
    local user=$2
    local password=$3
    local database=$4
    
    log_step "Testing database connection to $database on $host..."
    
    if mysql -h "$host" -u "$user" -p"$password" -e "SELECT 1;" "$database" >/dev/null 2>&1; then
        log_success "Database connection successful"
        return 0
    else
        log_error "Database connection failed"
        return 1
    fi
}

# File existence check
check_file_exists() {
    local file_path=$1
    local description=${2:-"Required file"}
    
    if [[ ! -f "$file_path" ]]; then
        log_error "$description not found: $file_path"
        return 1
    fi
    
    log_success "$description found: $file_path"
    return 0
}

# Directory existence check
check_directory_exists() {
    local dir_path=$1
    local description=${2:-"Required directory"}
    
    if [[ ! -d "$dir_path" ]]; then
        log_error "$description not found: $dir_path"
        return 1
    fi
    
    log_success "$description found: $dir_path"
    return 0
}

# Command availability check
check_command() {
    local command=$1
    local description=${2:-"Required command"}
    
    if ! command -v "$command" >/dev/null 2>&1; then
        log_error "$description not available: $command"
        return 1
    fi
    
    log_success "$description available: $command"
    return 0
}

# Backup function
create_backup() {
    local source=$1
    local backup_dir=$2
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name=$(basename "$source")_$timestamp
    
    log_step "Creating backup of $source..."
    
    if [[ -d "$source" ]]; then
        tar -czf "$backup_dir/$backup_name.tar.gz" -C "$(dirname "$source")" "$(basename "$source")"
    else
        cp "$source" "$backup_dir/$backup_name"
    fi
    
    log_success "Backup created: $backup_dir/$backup_name"
}

# Confirmation prompt
confirm_action() {
    local message=$1
    local default=${2:-"n"}
    
    if [[ "$default" == "y" ]]; then
        read -p "$message [Y/n]: " -r response
        response=${response:-y}
    else
        read -p "$message [y/N]: " -r response
        response=${response:-n}
    fi
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Load environment file
load_env_file() {
    local env_file=$1
    
    if [[ -f "$env_file" ]]; then
        log_step "Loading environment from $env_file..."
        set -a
        source "$env_file"
        set +a
        log_success "Environment loaded from $env_file"
    else
        log_error "Environment file not found: $env_file"
        return 1
    fi
}

# Print environment summary
print_environment_summary() {
    log_info "Environment Configuration Summary:"
    echo "  Database Host: ${DB_HOST:-NOT SET}"
    echo "  Database User: ${DB_USER:-NOT SET}"
    echo "  Database Name: ${DB_NAME:-NOT SET}"
    echo "  WordPress Home: ${WORDPRESS_HOME:-NOT SET}"
    echo "  WordPress Site URL: ${WORDPRESS_SITEURL:-NOT SET}"
    echo "  Environment Type: ${WP_ENVIRONMENT_TYPE:-NOT SET}"
}

# Wait for service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=${3:-"Service"}
    local max_attempts=${4:-30}
    local delay=${5:-2}
    
    log_step "Waiting for $service_name to be ready on $host:$port..."
    
    for ((i=1; i<=max_attempts; i++)); do
        if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            log_success "$service_name is ready on $host:$port"
            return 0
        fi
        
        if [[ $i -lt $max_attempts ]]; then
            log_info "Attempt $i/$max_attempts: $service_name not ready yet, waiting ${delay}s..."
            sleep "$delay"
        fi
    done
    
    log_error "$service_name failed to become ready on $host:$port after $max_attempts attempts"
    return 1
}
