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
    echo "🔍 Verifying staging database..."
    
    # First, try to set up the database using the script
    echo "Setting up database structure..."
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" < "$BASIC_SETUP" >/dev/null 2>&1 || echo "Database setup completed or user already exists"
    
    # Check if database exists
    if ! mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "USE $WORDPRESS_DB_NAME;" >/dev/null 2>&1; then
        echo "❌ Database '$WORDPRESS_DB_NAME' does not exist!"
        echo "💡 Run: $0 copy-develop"
        return 1
    fi
    
    echo ""
    echo "📊 Database Structure Verification:"
    echo "=================================="
    
    # Basic database info
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "
    USE $WORDPRESS_DB_NAME;
    SELECT 'Database exists and accessible' as status;
    SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = '$WORDPRESS_DB_NAME';
    SELECT COUNT(*) as total_posts FROM wp_posts;
    SELECT COUNT(*) as total_users FROM wp_users;
    SELECT COUNT(*) as total_pages FROM wp_posts WHERE post_type = 'page';
    " 2>/dev/null || { echo "❌ Database verification failed"; return 1; }
    
    echo ""
    echo "🌐 WordPress URL Configuration:"
    echo "=============================="
    
    # Check WordPress URLs
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "
    USE $WORDPRESS_DB_NAME;
    SELECT 
        CASE 
            WHEN option_name = 'home' THEN '🏠 Home URL'
            WHEN option_name = 'siteurl' THEN '🌍 Site URL'
            WHEN option_name = 'blogname' THEN '📝 Blog Name'
            WHEN option_name = 'admin_email' THEN '📧 Admin Email'
        END as setting,
        option_value as value
    FROM wp_options 
    WHERE option_name IN ('home', 'siteurl', 'blogname', 'admin_email');
    " 2>/dev/null
    
    echo ""
    echo "🔍 URL Analysis (Development vs Staging):"
    echo "========================================"
    
    # Check for development URLs in content
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "
    USE $WORDPRESS_DB_NAME;
    SELECT 
        'WordPress Options' as location,
        COUNT(*) as dev_urls_found
    FROM wp_options 
    WHERE option_value LIKE '%localhost:8082%' 
       OR option_value LIKE '%http://localhost:8082%';
    
    SELECT 
        'Post Content' as location,
        COUNT(*) as dev_urls_found
    FROM wp_posts 
    WHERE post_content LIKE '%localhost:8082%' 
       OR post_content LIKE '%http://localhost:8082%';
    
    SELECT 
        'Post GUIDs' as location,
        COUNT(*) as dev_urls_found
    FROM wp_posts 
    WHERE guid LIKE '%localhost:8082%' 
       OR guid LIKE '%http://localhost:8082%';
    
    SELECT 
        'Post Meta' as location,
        COUNT(*) as dev_urls_found
    FROM wp_postmeta 
    WHERE meta_value LIKE '%localhost:8082%' 
       OR meta_value LIKE '%http://localhost:8082%';
    " 2>/dev/null
    
    echo ""
    echo "📄 Sample Content Verification:"
    echo "=============================="
    
    # Show sample posts with URLs
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "
    USE $WORDPRESS_DB_NAME;
    SELECT 
        ID,
        LEFT(post_title, 30) as title,
        post_type,
        LEFT(guid, 50) as guid_url
    FROM wp_posts 
    WHERE post_status = 'publish' 
    ORDER BY post_date DESC 
    LIMIT 5;
    " 2>/dev/null
    
    echo ""
    echo "⚠️  Development URLs Still Present:"
    echo "=================================="
    
    # Show specific development URLs that need attention
    mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "
    USE $WORDPRESS_DB_NAME;
    (SELECT 
        'OPTIONS' as table_name,
        option_name as location,
        LEFT(option_value, 60) as problematic_url
    FROM wp_options 
    WHERE option_value LIKE '%localhost:8082%' 
    LIMIT 3)
    UNION ALL
    (SELECT 
        'POSTS' as table_name,
        CONCAT('Post ID: ', ID) as location,
        LEFT(guid, 60) as problematic_url
    FROM wp_posts 
    WHERE guid LIKE '%localhost:8082%' 
    LIMIT 3);
    " 2>/dev/null
    
    echo ""
    echo "✅ Verification Summary:"
    echo "======================"
    
    # Count issues
    dev_url_count=$(mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "
    USE $WORDPRESS_DB_NAME;
    SELECT (
        (SELECT COUNT(*) FROM wp_options WHERE option_value LIKE '%localhost:8082%') +
        (SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%localhost:8082%' OR guid LIKE '%localhost:8082%') +
        (SELECT COUNT(*) FROM wp_postmeta WHERE meta_value LIKE '%localhost:8082%')
    ) as total;
    " 2>/dev/null | tail -1)
    
    if [ "$dev_url_count" -gt 0 ]; then
        echo "⚠️  Found $dev_url_count development URLs that need conversion"
        echo "💡 Run the staging container to auto-convert URLs:"
        echo "   cd .. && ./staging-commands.sh restart"
    else
        echo "✅ No development URLs found - staging is properly configured!"
    fi
    
    echo ""
    echo "🚀 Staging Status: Ready for testing at http://localhost:8083"
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

# Database configuration - Load from properties file
PROPERTIES_FILE="../fiverivertutoring-wordpress-staging.properties"
if [ -f "$PROPERTIES_FILE" ]; then
    echo "📄 Loading configuration from $PROPERTIES_FILE"
    source "$PROPERTIES_FILE"
    
    # Use WORDPRESS_DB_* variables for consistency with Docker container
    # Fallback to DB_* variables if WORDPRESS_DB_* are not set
    WORDPRESS_DB_HOST="${WORDPRESS_DB_HOST:-$DB_HOST}"
    WORDPRESS_DB_USER="${WORDPRESS_DB_USER:-$DB_USER}"
    WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-$DB_PASSWORD}"
    WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME:-$STAGING_DB}"
    DEVELOP_DB="${DEVELOP_DB:-fiveriverstutoring_db}"
    PRODUCTION_DB="${PRODUCTION_DB:-fiveriverstutoring_prod_db}"
    
    echo "🔧 Database configuration loaded:"
    echo "   Host: $WORDPRESS_DB_HOST"
    echo "   User: $WORDPRESS_DB_USER"
    echo "   Staging DB: $WORDPRESS_DB_NAME"
    echo "   Develop DB: $DEVELOP_DB"
else
    echo "❌ Properties file not found: $PROPERTIES_FILE"
    echo "💡 Make sure you're running from staging-deploy/db-scripts/"
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
