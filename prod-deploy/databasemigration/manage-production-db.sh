#!/bin/bash

# Five Rivers Tutoring - Production Database Management Script
# This script manages production database operations for GCP Cloud SQL
# 
# Features:
# - Automatic staging to production database migration
# - Production database backup and restore
# - Backup files stored in ./backups/ directory
# - GCP-native database connectivity
# - Comprehensive error handling and debugging

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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to handle errors with detailed information
handle_error() {
    local exit_code=$1
    local error_message=$2
    local command_output=$3
    
    print_error "❌ Operation failed with exit code: $exit_code"
    print_error "Error: $error_message"
    
    if [ -n "$command_output" ]; then
        print_error "Command output:"
        echo "$command_output" | head -20
    fi
    
    print_error "Troubleshooting steps:"
    print_error "1. Check gcloud authentication: gcloud auth list"
    print_error "2. Check project configuration: gcloud config get-value project"
    print_error "3. Check instance status: gcloud sql instances describe $CLOUD_SQL_INSTANCE"
    print_error "4. Check permissions: gcloud projects get-iam-policy \$(gcloud config get-value project)"
    
    return $exit_code
}

# Function to execute gcloud command with error handling
execute_gcloud_command() {
    local command="$1"
    local description="$2"
    
    print_status "$description"
    print_debug "Executing: $command"
    
    local output
    output=$(eval "$command" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        print_status "✅ $description completed successfully"
        echo "$output"
        return 0
    else
        handle_error $exit_code "$description failed" "$output"
        return $exit_code
    fi
}

# Function to print debug information
print_debug() {
    if [ "${DEBUG:-false}" = "true" ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Script information
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORDPRESS_TFVARS="../terraform/wordpress.tfvars"
STAGING_ENV="../../staging-deploy/env.staging"
PROPERTIES_FILE="../properties/fiverivertutoring-wordpress.properties"

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if [ ! -d "../terraform" ]; then
        print_error "terraform/ directory not found. Please run this script from databasemigration directory."
        exit 1
    fi
    
    if [ ! -f "$WORDPRESS_TFVARS" ]; then
        print_error "WordPress Terraform variables file not found: $WORDPRESS_TFVARS"
        exit 1
    fi
    
    if ! command -v mysql &> /dev/null; then
        print_error "mysql client not found. Please install MySQL client."
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        print_warning "gcloud CLI not found. Some operations may not work."
    fi
    
    print_status "All prerequisites are met!"
}

# Function to load configuration from wordpress.tfvars and staging properties
load_wordpress_config() {
    print_header "Loading Configuration"
    
    print_status "Loading production configuration from: $WORDPRESS_TFVARS"
    
    # Extract values from tfvars file
    WORDPRESS_DB_HOST=$(grep "wordpress_db_host" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    WORDPRESS_DB_NAME=$(grep "wordpress_db_name" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    WORDPRESS_DB_USER=$(grep "wordpress_db_user" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    WORDPRESS_DB_PASSWORD=$(grep "wordpress_db_password" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    WORDPRESS_DB_ADMIN_USER=$(grep "wordpress_db_admin_user" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    WORDPRESS_DB_ADMIN_PASSWORD=$(grep "wordpress_db_admin_password" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    
    # Get Cloud SQL instance name from wordpress_db_instance variable
    CLOUD_SQL_INSTANCE=$(grep "wordpress_db_instance" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
    
    # Load staging configuration from staging environment file
    print_status "Loading staging configuration from: $STAGING_ENV"
    
    if [ -f "$STAGING_ENV" ]; then
        # Extract staging database values from env.staging
        STAGING_DB_HOST=$(grep "WORDPRESS_DB_HOST" "$STAGING_ENV" | cut -d'=' -f2)
        STAGING_DB_PORT=3306  # Default MySQL port
        STAGING_DB_NAME=$(grep "WORDPRESS_DB_NAME" "$STAGING_ENV" | cut -d'=' -f2)
        STAGING_DB_USER=$(grep "WORDPRESS_DB_USER" "$STAGING_ENV" | cut -d'=' -f2)
        STAGING_DB_PASSWORD=$(grep "WORDPRESS_DB_PASSWORD" "$STAGING_ENV" | cut -d'=' -f2)
        STAGING_DB_ADMIN_USER=$(grep "WORDPRESS_DB_USER" "$STAGING_ENV" | cut -d'=' -f2)
        STAGING_DB_ADMIN_PASSWORD=$(grep "WORDPRESS_DB_PASSWORD" "$STAGING_ENV" | cut -d'=' -f2)
        
        # Extract staging URL from env.staging
        STAGING_URL=$(grep "STAGING_URL" "$STAGING_ENV" | cut -d'=' -f2)
        PRODUCTION_URL="https://fiveriverstutoring.com"  # Your actual domain with HTTPS
        
        # Set migration defaults
        MIGRATION_BACKUP_ENABLED=true
        MIGRATION_URL_UPDATE_ENABLED=true
        
        print_status "✅ Staging configuration loaded successfully!"
    else
        print_warning "⚠️  Staging environment file not found: $STAGING_ENV"
        print_warning "You will need to enter staging details manually"
    fi
    
    # Set final configuration
    PRODUCTION_DB="$WORDPRESS_DB_NAME"
    DB_HOST="$WORDPRESS_DB_HOST"
    DB_USER="$WORDPRESS_DB_USER"
    DB_PASSWORD="$WORDPRESS_DB_PASSWORD"
    ADMIN_USER="$WORDPRESS_DB_ADMIN_USER"
    ADMIN_PASSWORD="$WORDPRESS_DB_ADMIN_PASSWORD"
    
    print_status "Configuration loaded successfully!"
    echo
    echo "ℹ️  Production Configuration:"
    echo "   Cloud SQL Instance: $CLOUD_SQL_INSTANCE"
    echo "   Database Host: $DB_HOST"
    echo "   Database Name: $PRODUCTION_DB"
    echo "   Database User: $DB_USER"
    echo "   Admin User: $ADMIN_USER"
    echo
    
    if [ -f "$STAGING_PROPERTIES" ]; then
        echo "ℹ️  Staging Configuration:"
        echo "   Database Host: $STAGING_DB_HOST"
        echo "   Database Name: $STAGING_DB_NAME"
        echo "   Database User: $STAGING_DB_USER"
        echo "   Staging URL: $STAGING_URL"
        echo "   Production URL: $PRODUCTION_URL"
        echo
    fi
}

# Function to test staging database connection
test_staging_connection() {
    print_header "Testing Staging Database Connection"
    
    if [ -z "$STAGING_DB_HOST" ] || [ -z "$STAGING_DB_USER" ] || [ -z "$STAGING_DB_NAME" ]; then
        print_error "❌ Staging configuration not loaded!"
        print_error "Please check your staging environment file: $STAGING_ENV"
        return 1
    fi
    
    print_status "Testing staging connection with:"
    echo "   Host: $STAGING_DB_HOST"
    echo "   User: $STAGING_DB_USER"
    echo "   Database: $STAGING_DB_NAME"
    echo "   Port: ${STAGING_DB_PORT:-3306}"
    echo
    
    # Test basic connection
    print_status "Testing basic connection..."
    if mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" -e "SELECT 1 as test;" 2>/dev/null; then
        print_status "✅ Basic connection successful!"
    else
        print_error "❌ Basic connection failed!"
        print_error "Check if MySQL is running on $STAGING_DB_HOST"
        return 1
    fi
    
    # Test database access
    print_status "Testing database access..."
    if mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" -e "USE $STAGING_DB_NAME; SELECT 1 as test;" 2>/dev/null; then
        print_status "✅ Database access successful!"
    else
        print_error "❌ Database access failed!"
        print_error "User may not have access to database: $STAGING_DB_NAME"
        return 1
    fi
    
    # Show database info
    print_status "Getting database information..."
    TABLE_COUNT=$(mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" "$STAGING_DB_NAME" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$STAGING_DB_NAME';" 2>/dev/null | tail -1)
    
    if [ -n "$TABLE_COUNT" ] && [ "$TABLE_COUNT" != "NULL" ]; then
        print_status "✅ Staging database accessible!"
        print_status "   Tables found: $TABLE_COUNT"
        
        # Show some table names
        print_status "Sample tables:"
        mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" "$STAGING_DB_NAME" -e "SHOW TABLES LIMIT 5;" 2>/dev/null | head -10
    else
        print_warning "⚠️  Could not determine table count"
    fi
    
    print_status "🎉 Staging database connection test completed successfully!"
}

# Function to test both staging and production database connections
test_database_connection() {
    print_header "Testing Database Connections"
    
    # Test 1: Staging Database Connection
    print_header "🔍 STAGING DATABASE TEST"
    
    if [ -z "$STAGING_DB_HOST" ] || [ -z "$STAGING_DB_USER" ] || [ -z "$STAGING_DB_NAME" ]; then
        print_error "❌ Staging configuration not loaded!"
        print_error "Please check your staging environment file: $STAGING_ENV"
        return 1
    fi
    
    print_status "Testing staging connection with:"
    echo "   Host: $STAGING_DB_HOST"
    echo "   User: $STAGING_DB_USER"
    echo "   Database: $STAGING_DB_NAME"
    echo "   Port: ${STAGING_DB_PORT:-3306}"
    echo
    
    # Test basic staging connection
    print_status "Testing basic staging connection..."
    if mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" -e "SELECT 1 as test;" 2>/dev/null; then
        print_status "✅ Basic staging connection successful!"
    else
        print_error "❌ Basic staging connection failed!"
        print_error "Check if MySQL is running on $STAGING_DB_HOST"
        STAGING_STATUS="FAILED"
    fi
    
    # Test staging database access
    if [ "$STAGING_STATUS" != "FAILED" ]; then
        print_status "Testing staging database access..."
        if mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" -e "USE $STAGING_DB_NAME; SELECT 1 as test;" 2>/dev/null; then
            print_status "✅ Staging database access successful!"
            
            # Get staging database info
            TABLE_COUNT=$(mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" "$STAGING_DB_NAME" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$STAGING_DB_NAME';" 2>/dev/null | tail -1)
            
            if [ -n "$TABLE_COUNT" ] && [ "$TABLE_COUNT" != "NULL" ]; then
                print_status "✅ Staging database accessible!"
                print_status "   Tables found: $TABLE_COUNT"
                
                # Show some table names
                print_status "Sample tables:"
                mysql -h "$STAGING_DB_HOST" -u "$STAGING_DB_USER" -p"$STAGING_DB_PASSWORD" "$STAGING_DB_NAME" -e "SHOW TABLES LIMIT 5;" 2>/dev/null | head -10
            else
                print_warning "⚠️  Could not determine staging table count"
            fi
            STAGING_STATUS="SUCCESS"
        else
            print_error "❌ Staging database access failed!"
            print_error "User may not have access to database: $STAGING_DB_NAME"
            STAGING_STATUS="FAILED"
        fi
    fi
    
    echo
    print_header "🔍 PRODUCTION DATABASE TEST"
    
    print_status "Testing production connection with:"
    echo "   Cloud SQL Instance: $CLOUD_SQL_INSTANCE"
    echo "   User: $DB_USER"
    echo "   Database: $PRODUCTION_DB"
    echo "   Project: $(gcloud config get-value project 2>/dev/null || echo 'NOT SET')"
    
    # Test production connection using gcloud sql connect (GCP-native method)
    if command -v gcloud &> /dev/null; then
        print_status "Using gcloud sql connect (GCP-native method)..."
        
        # First, check gcloud authentication
        print_status "Checking gcloud authentication..."
        AUTH_STATUS=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
        if [ -z "$AUTH_STATUS" ]; then
            print_error "❌ gcloud authentication failed!"
            print_error "No active accounts found. Please run: gcloud auth login"
            PRODUCTION_STATUS="FAILED"
        else
            print_status "✅ Authenticated as: $AUTH_STATUS"
        fi
        
        # Check project configuration
        if [ "$PRODUCTION_STATUS" != "FAILED" ]; then
            print_status "Checking project configuration..."
            CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
            if [ -z "$CURRENT_PROJECT" ]; then
                print_error "❌ No project configured!"
                print_error "Please run: gcloud config set project storied-channel-467012-r6"
                PRODUCTION_STATUS="FAILED"
            else
                print_status "✅ Using project: $CURRENT_PROJECT"
            fi
        fi
        
        # Check if instance exists and get its status
        if [ "$PRODUCTION_STATUS" != "FAILED" ]; then
            print_status "Checking Cloud SQL instance status..."
            INSTANCE_STATUS=$(gcloud sql instances describe "$CLOUD_SQL_INSTANCE" --project="$CURRENT_PROJECT" --format="value(state)" 2>/dev/null)
            if [ $? -ne 0 ]; then
                print_error "❌ Failed to access instance '$CLOUD_SQL_INSTANCE'!"
                print_error "Error details:"
                gcloud sql instances describe "$CLOUD_SQL_INSTANCE" --project="$CURRENT_PROJECT" 2>&1 | head -10
                print_error "Possible issues:"
                print_error "1. Instance doesn't exist"
                print_error "2. Insufficient permissions"
                print_error "3. Wrong project"
                PRODUCTION_STATUS="FAILED"
            else
                print_status "✅ Instance status: $INSTANCE_STATUS"
                
                # Check if instance is running
                if [ "$INSTANCE_STATUS" != "RUNNABLE" ]; then
                    print_warning "⚠️  Instance is not running (status: $INSTANCE_STATUS)"
                    if [ "$INSTANCE_STATUS" = "STOPPED" ]; then
                        print_status "Starting instance..."
                        if gcloud sql instances patch "$CLOUD_SQL_INSTANCE" --activation-policy ALWAYS --project="$CURRENT_PROJECT" --quiet; then
                            print_status "✅ Instance started successfully!"
                            print_status "Waiting for instance to be ready..."
                            sleep 30
                        else
                            print_error "❌ Failed to start instance!"
                            PRODUCTION_STATUS="FAILED"
                        fi
                    fi
                fi
            fi
        fi
        
        # Now test the actual production connection
        if [ "$PRODUCTION_STATUS" != "FAILED" ]; then
            print_status "Testing production database connection..."
            CONNECTION_OUTPUT=$(gcloud sql connect "$CLOUD_SQL_INSTANCE" --user="$DB_USER" --database="$PRODUCTION_DB" --quiet -e "SELECT 1 as test_connection;" 2>&1)
            CONNECTION_EXIT_CODE=$?
            
            if [ $CONNECTION_EXIT_CODE -eq 0 ]; then
                print_status "✅ Production connection successful using gcloud!"
                PRODUCTION_STATUS="SUCCESS"
            else
                print_error "❌ Production gcloud connection failed!"
                print_error "Exit code: $CONNECTION_EXIT_CODE"
                print_error "Error output:"
                echo "$CONNECTION_OUTPUT" | head -20
                
                print_error "Detailed troubleshooting:"
                print_error "1. Check authentication: gcloud auth list"
                print_error "2. Check project: gcloud config get-value project"
                print_error "3. Check instance: gcloud sql instances describe $CLOUD_SQL_INSTANCE"
                print_error "4. Check permissions: gcloud projects get-iam-policy $CURRENT_PROJECT"
                print_error "5. Check instance status: gcloud sql instances list"
                
                PRODUCTION_STATUS="FAILED"
            fi
        fi
    else
        print_error "gcloud CLI not found. Please install it for GCP-native database access."
        print_status "Install: https://cloud.google.com/sdk/docs/install"
        PRODUCTION_STATUS="FAILED"
    fi
    
    # Summary
    echo
    print_header "📊 CONNECTION TEST SUMMARY"
    
    if [ "$STAGING_STATUS" = "SUCCESS" ]; then
        print_status "✅ Staging Database: CONNECTED"
    else
        print_error "❌ Staging Database: FAILED"
    fi
    
    if [ "$PRODUCTION_STATUS" = "SUCCESS" ]; then
        print_status "✅ Production Database: CONNECTED"
    else
        print_error "❌ Production Database: FAILED"
    fi
    
    echo
    if [ "$STAGING_STATUS" = "SUCCESS" ] && [ "$PRODUCTION_STATUS" = "SUCCESS" ]; then
        print_status "🎉 All database connections successful! Ready for migration."
    elif [ "$STAGING_STATUS" = "SUCCESS" ]; then
        print_warning "⚠️  Staging works but production failed. Fix production before migration."
    elif [ "$PRODUCTION_STATUS" = "SUCCESS" ]; then
        print_warning "⚠️  Production works but staging failed. Fix staging before migration."
    else
        print_error "❌ Both connections failed. Fix database connectivity issues."
    fi
}

# Function to copy staging to production
copy_staging_to_production() {
    print_header "Copying Staging Database to Production"
    print_warning "This will overwrite the production database!"
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled."
        return 1
    fi
    
    # Use staging database details from properties file
    if [ -n "$STAGING_DB_HOST" ] && [ -n "$STAGING_DB_NAME" ] && [ -n "$STAGING_DB_USER" ] && [ -n "$STAGING_DB_PASSWORD" ]; then
        print_status "Using staging configuration from properties file:"
        echo "   Host: $STAGING_DB_HOST"
        echo "   Database: $STAGING_DB_NAME"
        echo "   User: $STAGING_DB_USER"
        echo "   Staging URL: $STAGING_URL"
        echo "   Production URL: $PRODUCTION_URL"
        echo
        
        # Set staging variables from properties
        STAGING_HOST="$STAGING_DB_HOST"
        STAGING_DB="$STAGING_DB_NAME"
        STAGING_USER="$STAGING_DB_USER"
        STAGING_PASSWORD="$STAGING_DB_PASSWORD"
    else
        print_warning "⚠️  Staging configuration not found in properties file"
        print_status "Please enter staging database details manually:"
        read -p "Enter staging database host: " STAGING_HOST
        read -p "Enter staging database name: " STAGING_DB
        read -p "Enter staging database user: " STAGING_USER
        read -s -p "Enter staging database password: " STAGING_PASSWORD
        echo
    fi
    
    print_status "Creating backup of current production database..."
    
    # Create backup of current production (if exists)
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $PRODUCTION_DB;" 2>/dev/null; then
        # Create backup directory if it doesn't exist
        BACKUP_DIR="./backups"
        if [ ! -d "$BACKUP_DIR" ]; then
            print_status "Creating backup directory: $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
        fi
        
        BACKUP_FILE="$BACKUP_DIR/production_backup_$(date +%Y%m%d_%H%M%S).sql"
        if mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" > "$BACKUP_FILE"; then
            print_status "✅ Production backup created: $BACKUP_FILE"
            print_status "   Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
        else
            print_error "❌ Production backup failed!"
        fi
    fi
    
    # Drop production database if exists
    print_status "Dropping existing production database..."
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS $PRODUCTION_DB;"
    
    # Create new production database
    print_status "Creating new production database..."
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE $PRODUCTION_DB;"
    
    # Test staging database connection first
    print_status "Testing staging database connection..."
    if ! mysql -h "$STAGING_HOST" -u "$STAGING_USER" -p"$STAGING_PASSWORD" -e "USE $STAGING_DB; SELECT 1;" 2>/dev/null; then
        print_error "❌ Cannot connect to staging database!"
        print_error "Host: $STAGING_HOST"
        print_error "User: $STAGING_USER"
        print_error "Database: $STAGING_DB"
        print_error ""
        print_error "Troubleshooting:"
        print_error "1. Check if staging database is running"
        print_error "2. Verify credentials in properties file"
        print_error "3. Check network connectivity to $STAGING_HOST"
        print_error "4. Run: mysql -h $STAGING_HOST -u $STAGING_USER -p $STAGING_DB"
        return 1
    fi
    
    print_status "✅ Staging database connection successful!"
    
    # Copy staging data to production
    print_status "Copying staging database to production..."
    if mysqldump -h "$STAGING_HOST" -u "$STAGING_USER" -p"$STAGING_PASSWORD" "$STAGING_DB" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB"; then
        print_status "✅ Staging database copied to production successfully!"
        
        # Update production URLs
        print_status "Updating production URLs..."
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" -e "
        UPDATE wp_options SET option_value = 'http://$DB_HOST' WHERE option_name IN ('home', 'siteurl');
        "
        
        print_status "🌐 Production site is now updated with staging data!"
    else
        print_error "Failed to copy staging database to production!"
        return 1
    fi
}

# Function to backup production database
backup_production() {
    print_header "Creating Production Database Backup"
    
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $PRODUCTION_DB;" 2>/dev/null; then
        # Create backup directory if it doesn't exist
        BACKUP_DIR="./backups"
        if [ ! -d "$BACKUP_DIR" ]; then
            print_status "Creating backup directory: $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
        fi
        
        BACKUP_FILE="$BACKUP_DIR/production_backup_$(date +%Y%m%d_%H%M%S).sql"
        if mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" > "$BACKUP_FILE"; then
            print_status "✅ Production database backup created: $BACKUP_FILE"
            print_status "   Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
            print_status "   Backup location: $BACKUP_FILE"
        else
            print_error "❌ Failed to create backup!"
            return 1
        fi
    else
        print_error "Production database does not exist or is not accessible!"
        return 1
    fi
}

# Function to restore production database
restore_production() {
    if [ -z "$1" ]; then
        print_error "Please specify backup file to restore from"
        print_status "Usage: $0 restore <backup_file.sql>"
        exit 1
    fi
    
    BACKUP_FILE="$1"
    
    # If no path specified, look in backups directory
    if [[ "$BACKUP_FILE" != *"/"* ]] && [[ "$BACKUP_FILE" != *"\\"* ]]; then
        BACKUP_FILE="./backups/$BACKUP_FILE"
    fi
    
    if [ ! -f "$BACKUP_FILE" ]; then
        print_error "Backup file not found: $BACKUP_FILE"
        print_status "Available backups in ./backups/:"
        if [ -d "./backups" ]; then
            ls -la "./backups/" | grep "\.sql$" | head -10
        else
            print_warning "No backups directory found"
        fi
        exit 1
    fi
    
    print_header "Restoring Production Database"
    print_warning "This will overwrite the current production database!"
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled."
        return 1
    fi
    
    print_status "Restoring from: $BACKUP_FILE"
    
    # Drop and recreate production database
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS $PRODUCTION_DB;"
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE $PRODUCTION_DB;"
    
    # Restore from backup
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" < "$BACKUP_FILE"; then
        print_status "✅ Production database restored from backup!"
    else
        print_error "Failed to restore database!"
        return 1
    fi
}

# Function to verify production database
verify_production() {
    print_header "Verifying Production Database"
    
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $PRODUCTION_DB;" 2>/dev/null; then
        print_status "Production database exists and is accessible"
        
        # Check table count (cross-platform compatible)
        TABLE_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$PRODUCTION_DB';" 2>/dev/null | tail -1)
        if [ -n "$TABLE_COUNT" ] && [ "$TABLE_COUNT" != "NULL" ]; then
            print_status "Tables found: $TABLE_COUNT"
        else
            print_warning "Could not determine table count"
        fi
        
        # Check WordPress options
        HOME_URL=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" -e "SELECT option_value FROM wp_options WHERE option_name='home';" 2>/dev/null | tail -1)
        if [ -n "$HOME_URL" ] && [ "$HOME_URL" != "NULL" ]; then
            print_status "Home URL: $HOME_URL"
        else
            print_warning "Home URL not found (wp_options table may be empty)"
        fi
        
        # Check post count
        POST_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" -e "SELECT COUNT(*) FROM wp_posts;" 2>/dev/null | tail -1)
        if [ -n "$POST_COUNT" ] && [ "$POST_COUNT" != "NULL" ]; then
            print_status "Total posts: $POST_COUNT"
        else
            print_warning "Could not determine post count"
        fi
        
        # Check user count
        USER_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB" -e "SELECT COUNT(*) FROM wp_users;" 2>/dev/null | tail -1)
        if [ -n "$USER_COUNT" ]; then
            print_status "Total users: $USER_COUNT"
        fi
        
    else
        print_error "Production database does not exist or is not accessible"
        return 1
    fi
}

# Function to debug configuration extraction
debug_config() {
    print_header "Staging Data Extraction Debug"
    
    if [ -f "$STAGING_PROPERTIES" ]; then
        echo "📋 STAGING DATA EXTRACTED:"
        echo "=========================="
        echo "Host: $STAGING_DB_HOST"
        echo "Port: $STAGING_DB_PORT"
        echo "Database: $STAGING_DB_NAME"
        echo "User: $STAGING_DB_USER"
        echo "Password: [${#STAGING_DB_PASSWORD} chars]"
        echo "Admin User: $STAGING_DB_ADMIN_USER"
        echo "Admin Password: [${#STAGING_DB_ADMIN_PASSWORD} chars]"
        echo
        
        echo "🔧 MIGRATION SETTINGS:"
        echo "======================"
        echo "Backup Enabled: $MIGRATION_BACKUP_ENABLED"
        echo "URL Update: $MIGRATION_URL_UPDATE_ENABLED"
        echo "Staging URL: $STAGING_URL"
        echo "Production URL: $PRODUCTION_URL"
    else
        print_error "Staging environment file not found: $STAGING_ENV"
    fi
}

# Function to list available backups
list_backups() {
    print_header "Available Database Backups"
    
    BACKUP_DIR="./backups"
    if [ ! -d "$BACKUP_DIR" ]; then
        print_warning "No backups directory found: $BACKUP_DIR"
        return 1
    fi
    
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "*.sql" | wc -l)
    if [ "$BACKUP_COUNT" -eq 0 ]; then
        print_warning "No backup files found in $BACKUP_DIR"
        return 1
    fi
    
    print_status "Found $BACKUP_COUNT backup(s) in $BACKUP_DIR:"
    echo
    
    # List backups with details
    find "$BACKUP_DIR" -name "*.sql" -type f -exec ls -lh {} \; | while read -r line; do
        echo "  $line"
    done
    
    echo
    print_status "To restore from a backup, use:"
    print_status "  $0 restore <backup_filename>"
    print_status "  Example: $0 restore production_backup_20241227_143022.sql"
}

# Function to show production configuration
show_config() {
    print_header "Current Production Configuration"
    echo "Database Host: $DB_HOST"
    echo "Database Name: $PRODUCTION_DB"
    echo "Database User: $DB_USER"
    echo "Admin User: $ADMIN_USER"
    echo "WordPress User: $WORDPRESS_DB_USER"
}

# Function to show help
show_help() {
    echo "🗄️ Five Rivers Tutoring - Production Database Management"
    echo "======================================================="
    echo
    echo "Usage: $0 {command} [--debug] [options]"
    echo
    echo "Commands:"
    echo "  copy-staging        # Copy staging database to production"
    echo "  backup              # Create production database backup"
    echo "  restore <file>      # Restore production from backup file"
    echo "  list-backups        # List available backup files"
    echo "  debug-config        # Show staging data extraction only"
    echo "  verify              # Verify production database status"
    echo "  test-connection     # Test both staging and production connections"
    echo "  show-config         # Show current production configuration"
    echo "  help                # Show this help message"
    echo
    echo "Options:"
    echo "  --debug             # Enable debug mode for detailed output"
    echo
    echo "Examples:"
    echo "  $0 copy-staging"
    echo "  $0 backup"
    echo "  $0 restore production_backup_20241227_143022.sql"
    echo "  $0 list-backups               # List available backups"
    echo "  $0 verify"
    echo "  $0 test-connection --debug    # Test both connections with debug output"
    echo
    echo "Workflow:"
    echo "  1. $0 copy-staging    # Copy staging data to production"
    echo "  2. $0 verify          # Verify the migration"
    echo "  3. $0 backup          # Create backup after changes"
    echo
    echo "Debug Mode:"
    echo "  Use --debug flag for detailed error information and troubleshooting"
    echo
    echo "Configuration:"
    echo "  Production config: ../terraform/wordpress.tfvars"
    echo "  Staging config: ../../staging-deploy/env.staging"
    echo
    echo "Backup Directory:"
    echo "  Backups are stored in: ./backups/"
    echo "  Backup files: production_backup_YYYYMMDD_HHMMSS.sql"
}

# Main function
main() {
    # Check for debug flag
    if [ "$1" = "--debug" ] || [ "$2" = "--debug" ]; then
        DEBUG=true
        print_debug "Debug mode enabled"
    fi
    
    case "${1:-help}" in
        copy-staging)
            check_prerequisites
            load_wordpress_config
            copy_staging_to_production
            ;;
        backup)
            check_prerequisites
            load_wordpress_config
            backup_production
            ;;
        restore)
            check_prerequisites
            load_wordpress_config
            restore_production "$2"
            ;;
        verify)
            check_prerequisites
            load_wordpress_config
            verify_production
            ;;
        test-connection)
            check_prerequisites
            load_wordpress_config
            test_database_connection
            ;;

        show-config)
            check_prerequisites
            load_wordpress_config
            show_config
            ;;
        list-backups)
            list_backups
            ;;
        debug-config)
            check_prerequisites
            load_wordpress_config
            debug_config
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
