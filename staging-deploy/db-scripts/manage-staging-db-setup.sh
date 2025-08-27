#!/bin/bash

# Five Rivers Tutoring - Staging Database Setup Script
# This script sets up the staging database using develop database as source

# Function definitions
usage() {
    echo "Usage: $0 {copy-develop|copy-production|reset|verify|backup|restore|workflow}"
    echo ""
    echo "Commands:"
    echo "  copy-develop    - Copy develop database to staging (RECOMMENDED)"
    echo "  copy-production - Copy production database to staging"
    echo "  reset           - Reset staging database (drop and recreate)"
    echo "  verify          - Verify staging database status"
    echo "  backup          - Create staging database backup"
    echo "  restore         - Restore staging database from backup file"
    echo "  workflow        - Show recommended development workflow"
    echo ""
    echo "Examples:"
    echo "  $0 copy-develop"
    echo "  $0 verify"
    echo "  $0 restore backups/staging_backup_20241227_143022.sql"
}



copy_develop() {
    echo "Copying develop database to staging..."
    
    # Create backup of current staging (if exists)
    if mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "USE $WORDPRESS_DB_NAME;" >/dev/null 2>&1; then
        echo "Backing up current staging database..."
        datestamp=$(date +"%Y%m%d_%H%M%S")
        mysqldump -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" > "backups/staging_backup_${datestamp}.sql"
        echo "✅ Backup created: backups/staging_backup_${datestamp}.sql"
    fi
    
    # Drop staging database if exists
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME;"
    
    # Create new staging database
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "CREATE DATABASE $WORDPRESS_DB_NAME;"
    
    # Copy develop data to staging
    echo "Copying develop database to staging..."
    mysqldump -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$DEVELOP_DB" | mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME"
    
    # Update staging URLs - DISABLED: Let entrypoint.sh handle URL conversion
    # echo "Updating staging URLs..."
    # mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_options SET option_value = 'http://localhost:8083' WHERE option_name IN ('home', 'siteurl');"
    # mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8082', 'localhost:8083');"
    # mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_posts SET guid = REPLACE(guid, 'your-production-domain.com', 'localhost:8083');"
    # mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_posts SET guid = REPLACE(guid, 'your-staging-domain.com', 'localhost:8083');"
    
    echo "✅ Develop database copied to staging!"
    echo "🌐 Staging site will be available at: http://localhost:8083"
    echo "📊 All your develop posts, plugins, and content are now in staging"
}

copy_production() {
    echo "Copying production database to staging..."
    
    # Create backup of current staging (if exists)
    if mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "USE $WORDPRESS_DB_NAME;" >/dev/null 2>&1; then
        echo "Backing up current staging database..."
        datestamp=$(date +"%Y%m%d_%H%M%S")
        mysqldump -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" > "backups/staging_backup_${datestamp}.sql"
        echo "✅ Backup created: backups/staging_backup_${datestamp}.sql"
    fi
    
    # Drop staging database if exists
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME;"
    
    # Create new staging database
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "CREATE DATABASE $WORDPRESS_DB_NAME;"
    
    # Copy production data to staging
    echo "Copying production data to staging..."
    mysqldump -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$PRODUCTION_DB" | mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME"
    
    # Update staging URLs
    echo "Updating staging URLs..."
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_options SET option_value = 'http://localhost:8083' WHERE option_name IN ('home', 'siteurl');"
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8082', 'localhost:8083');"
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "UPDATE wp_posts SET guid = REPLACE(guid, 'your-production-domain.com', 'localhost:8083');"
    
    echo "✅ Production database copied to staging!"
    echo "🌐 Staging site will be available at: http://localhost:8083"
}

reset_db() {
    echo "Resetting staging database..."
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME;"
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "CREATE DATABASE $WORDPRESS_DB_NAME;"
    echo "✅ Staging database reset complete!"
}

verify_db() {
    echo "Verifying staging database..."
    
    # First, try to set up the database using the script
    echo "Setting up database structure..."
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" < "$BASIC_SETUP" >/dev/null 2>&1 || echo "Database setup completed or user already exists"
    
    # Now verify the database
    echo ""
    echo "Database verification results:"
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "USE $WORDPRESS_DB_NAME; SELECT 'Database exists' as status; SHOW TABLES; SELECT COUNT(*) as total_posts FROM wp_posts; SELECT COUNT(*) as total_users FROM wp_users; SELECT option_value as site_url FROM wp_options WHERE option_name = 'siteurl'; SELECT option_value as blog_name FROM wp_options WHERE option_name = 'blogname';" 2>/dev/null || echo "Database verification failed - may need to create database first"
}

backup_db() {
    echo "Creating staging database backup..."
    if mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "USE $WORDPRESS_DB_NAME;" >/dev/null 2>&1; then
        datestamp=$(date +"%Y%m%d_%H%M%S")
        mysqldump -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" > "backups/staging_backup_${datestamp}.sql"
        echo "✅ Staging database backup created: backups/staging_backup_${datestamp}.sql"
    else
        echo "❌ Staging database does not exist!"
    fi
}

restore_db() {
    local backup_file="$1"
    echo "Restoring staging database from $backup_file..."
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" < "$backup_file"
    echo "✅ Staging database restored!"
}

show_workflow() {
    echo "🚀 Five Rivers Tutoring - Development Workflow"
    echo "============================================="
    echo ""
    echo "Recommended workflow:"
    echo "1. Develop → Staging → Production"
    echo ""
    echo "Step 1: Copy develop to staging"
    echo "  ./manage-staging-db-setup.sh copy-develop"
    echo ""
    echo "Step 2: Start staging environment"
    echo "  ../staging-commands.sh start"
    echo ""
    echo "Step 3: Test at http://localhost:8083"
    echo ""
    echo "Step 4: When ready, deploy to production"
    echo "  (Production deployment commands)"
    echo ""
    echo "Step 5: Copy staging to production"
    echo "  ./manage-staging-db-setup.sh copy-staging-to-production"
}

# Main script execution
echo "🗄️ Five Rivers Tutoring - Staging Database Setup"
echo "================================================"

# Database configuration - Load from env.staging
if [ -f "../env.staging" ]; then
    source "../env.staging"
    
    # Use WORDPRESS_DB_* variables for consistency with Docker container
    # Fallback to DB_* variables if WORDPRESS_DB_* are not set
    WORDPRESS_DB_HOST="${WORDPRESS_DB_HOST:-$DB_HOST}"
    WORDPRESS_DB_USER="${WORDPRESS_DB_USER:-$DB_USER}"
    WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-$DB_PASSWORD}"
    WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME:-$STAGING_DB}"
    DEVELOP_DB="${DEVELOP_DB:-fiveriverstutoring_db}"
    PRODUCTION_DB="${PRODUCTION_DB:-fiveriverstutoring_prod_db}"
else
    echo "❌ env.staging file not found!"
    exit 1
fi

# SQL script paths
BASIC_SETUP="fiveriverstutoring_staging_db.sql"

# Create backups directory if it doesn't exist
mkdir -p backups

# Check if command argument is provided
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in

    "copy-develop")
        copy_develop
        ;;
    "copy-production")
        copy_production
        ;;
    "reset")
        reset_db
        ;;
    "verify")
        verify_db
        ;;
    "backup")
        backup_db
        ;;
    "restore")
        if [ -z "$2" ]; then
            echo "❌ Please provide backup file: ./manage-staging-db-setup.sh restore backup_file.sql"
            exit 1
        fi
        restore_db "$2"
        ;;
    "workflow")
        show_workflow
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0
