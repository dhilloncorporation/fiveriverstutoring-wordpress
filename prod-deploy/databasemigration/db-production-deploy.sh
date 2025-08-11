#!/bin/bash

# Five Rivers Tutoring - Production Deployment Script
# This script deploys from staging to production

echo "🚀 Five Rivers Tutoring - Production Deployment"
echo "=============================================="

# Load production environment variables
if [ -f "../gcp-production-env.properties" ]; then
    source "../gcp-production-env.properties"
else
    echo "❌ Production environment file not found!"
    echo "Please copy gcp-production-env.properties.example to gcp-production-env.properties and update with your values"
    exit 1
fi

# Database configuration (from env.production)
DB_HOST="${WORDPRESS_DB_HOST}"
DB_USER="${WORDPRESS_DB_USER}"
DB_PASSWORD="${WORDPRESS_DB_PASSWORD}"
STAGING_DB="fiveriverstutoring_staging_db"
PRODUCTION_DB="${WORDPRESS_DB_NAME}"
DEVELOP_DB="fiveriverstutoring_db"
PRODUCTION_DOMAIN="${PRODUCTION_DOMAIN}"

case "$1" in
    "staging-to-production")
        echo "Deploying from staging to production..."
        
        # Create backup of current production (if exists)
        if mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "USE $PRODUCTION_DB;" 2>/dev/null; then
            echo "Backing up current production database..."
            mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB > production_backup_$(date +%Y%m%d_%H%M%S).sql
        fi
        
        # Drop production database if exists
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $PRODUCTION_DB;"
        
        # Create new production database
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $PRODUCTION_DB;"
        
        # Copy staging data to production
        echo "Copying staging database to production..."
        mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $STAGING_DB | mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB
        
        # Update production URLs
        echo "Updating production URLs..."
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB -e "
        UPDATE wp_options SET option_value = 'https://$PRODUCTION_DOMAIN' WHERE option_name IN ('home', 'siteurl');
        UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8083', '$PRODUCTION_DOMAIN');
        UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8082', '$PRODUCTION_DOMAIN');
        "
        
        echo "✅ Staging deployed to production!"
        echo "🌐 Production site: https://$PRODUCTION_DOMAIN"
        echo "📊 All staging content is now live in production"
        ;;
    "develop-to-production")
        echo "Deploying directly from develop to production..."
        
        # Create backup of current production (if exists)
        if mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "USE $PRODUCTION_DB;" 2>/dev/null; then
            echo "Backing up current production database..."
            mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB > production_backup_$(date +%Y%m%d_%H%M%S).sql
        fi
        
        # Drop production database if exists
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $PRODUCTION_DB;"
        
        # Create new production database
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $PRODUCTION_DB;"
        
        # Copy develop data to production
        echo "Copying develop database to production..."
        mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DEVELOP_DB | mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB
        
        # Update production URLs
        echo "Updating production URLs..."
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB -e "
        UPDATE wp_options SET option_value = 'https://$PRODUCTION_DOMAIN' WHERE option_name IN ('home', 'siteurl');
        UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8082', '$PRODUCTION_DOMAIN');
        UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8083', '$PRODUCTION_DOMAIN');
        "
        
        echo "✅ Develop deployed to production!"
        echo "🌐 Production site: https://$PRODUCTION_DOMAIN"
        echo "📊 All develop content is now live in production"
        ;;
    "backup-production")
        echo "Creating production database backup..."
        if mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "USE $PRODUCTION_DB;" 2>/dev/null; then
            mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB > production_backup_$(date +%Y%m%d_%H%M%S).sql
            echo "✅ Production database backup created!"
        else
            echo "❌ Production database does not exist!"
        fi
        ;;
    "restore-production")
        if [ -z "$2" ]; then
            echo "❌ Please provide backup file: ./production-deploy.sh restore-production backup_file.sql"
            exit 1
        fi
        echo "Restoring production database from $2..."
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $PRODUCTION_DB < "$2"
        echo "✅ Production database restored!"
        ;;
    "verify-production")
        echo "Verifying production database..."
        mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "
        USE $PRODUCTION_DB;
        SELECT 'Production Database Status' as status;
        SELECT COUNT(*) as total_posts FROM wp_posts;
        SELECT COUNT(*) as total_users FROM wp_users;
        SELECT option_value as site_url FROM wp_options WHERE option_name = 'siteurl';
        SELECT option_value as blog_name FROM wp_options WHERE option_name = 'blogname';
        "
        ;;
    "setup-production")
        echo "Setting up production environment..."
        echo "1. Copy gcp-production-env.properties.example to gcp-production-env.properties"
        echo "2. Update gcp-production-env.properties with your production values"
        echo "3. Run: ./production-deploy.sh staging-to-production"
        ;;
    "workflow")
        echo "🚀 Five Rivers Tutoring - Complete Development Workflow"
        echo "======================================================"
        echo ""
        echo "Recommended workflow:"
        echo "1. Develop → Staging → Production"
        echo ""
        echo "Step 1: Copy develop to staging"
        echo "  cd ../staging-deploy"
        echo "  ./staging-db-setup.sh copy-develop"
        echo ""
        echo "Step 2: Start staging environment"
        echo "  ./staging-commands.sh start"
        echo ""
        echo "Step 3: Test at http://localhost:8083"
        echo ""
        echo "Step 4: Deploy staging to production"
        echo "  cd ../gcp-deploy/databasemigration"
        echo "  ./production-deploy.sh staging-to-production"
        echo ""
        echo "Step 5: Verify production"
        echo "  ./production-deploy.sh verify-production"
        echo ""
        echo "Alternative: Direct develop to production"
        echo "  ./production-deploy.sh develop-to-production"
        ;;
    *)
        echo "Usage: $0 {staging-to-production|develop-to-production|backup-production|restore-production|verify-production|setup-production|workflow}"
        echo ""
        echo "Commands:"
        echo "  staging-to-production  - Deploy from staging to production (RECOMMENDED)"
        echo "  develop-to-production  - Deploy directly from develop to production"
        echo "  backup-production      - Create production database backup"
        echo "  restore-production     - Restore production database from backup"
        echo "  verify-production      - Verify production database status"
        echo "  setup-production       - Show production setup instructions"
        echo "  workflow              - Show complete development workflow"
        echo ""
        echo "Examples:"
        echo "  ./production-deploy.sh staging-to-production"
        echo "  ./production-deploy.sh develop-to-production"
        echo "  ./production-deploy.sh backup-production"
        echo ""
        echo "Complete workflow:"
        echo "  1. cd ../staging-deploy && ./staging-db-setup.sh copy-develop"
        echo "  2. ./staging-commands.sh start"
        echo "  3. Test at http://localhost:8083"
        echo "  4. cd ../gcp-deploy/databasemigration && ./production-deploy.sh staging-to-production"
        exit 1
        ;;
esac 