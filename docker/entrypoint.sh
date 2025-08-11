#!/bin/bash
set -euo pipefail

# Five Rivers Tutoring - Custom WordPress Entrypoint
# Handles external database connection and WordPress configuration

echo "🚀 Starting Five Rivers Tutoring WordPress..."

# Function to wait for external database
wait_for_external_db() {
    echo "⏳ Waiting for external database connection..."
    echo "Database Host: ${WORDPRESS_DB_HOST:-localhost}"
    echo "Database Name: ${WORDPRESS_DB_NAME:-fiveriverstutoring_db}"
    
    # Add initial delay to allow database to be ready
    echo "Waiting 5 seconds for database to be ready..."
    sleep 5
    
    # Wait for database to be ready using direct MySQL connection
    local attempts=0
    local max_attempts=3
    
    while ! mysql -h"${WORDPRESS_DB_HOST:-localhost}" -u"${WORDPRESS_DB_USER:-root}" -p"${WORDPRESS_DB_PASSWORD:-}" -e "SELECT 1;" >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        echo "Database not ready, waiting... (Attempt $attempts/$max_attempts)"
        
        if [ $attempts -ge $max_attempts ]; then
            echo "❌ Failed to connect to database after $max_attempts attempts"
            echo "Database connection details:"
            echo "Host: ${WORDPRESS_DB_HOST:-localhost}"
            echo "User: ${WORDPRESS_DB_USER:-root}"
            echo "Database: ${WORDPRESS_DB_NAME:-fiveriverstutoring_db}"
            echo "Testing connection manually..."
            mysql -h"${WORDPRESS_DB_HOST:-localhost}" -u"${WORDPRESS_DB_USER:-root}" -p"${WORDPRESS_DB_PASSWORD:-}" -e "SELECT 1;" || echo "Manual connection test failed"
            exit 1
        fi
        
        sleep 5
    done
    echo "✅ External database connection established"
}

# Function to create wp-config.php if it doesn't exist
create_wp_config() {
    if [ ! -f "wp-config.php" ]; then
        echo "📝 Creating wp-config.php from environment variables..."
        
        # Create wp-config.php using wp config create
        wp config create \
            --dbname="${WORDPRESS_DB_NAME:-fiveriverstutoring_db}" \
            --dbuser="${WORDPRESS_DB_USER:-root}" \
            --dbpass="${WORDPRESS_DB_PASSWORD:-}" \
            --dbhost="${WORDPRESS_DB_HOST:-localhost}" \
            --dbprefix=wp_ \
            --dbcharset=utf8mb4 \
            --dbcollate=utf8mb4_unicode_ci \
            --allow-root \
            --extra-php <<PHP
// Custom WordPress configuration
define( 'WP_DEBUG', ${WORDPRESS_DEBUG:-false} );
define( 'WP_ENVIRONMENT_TYPE', '${WP_ENVIRONMENT_TYPE:-production}' );
define( 'WP_HOME', '${WORDPRESS_HOME:-http://localhost}' );
define( 'WP_SITEURL', '${WORDPRESS_SITEURL:-http://localhost}' );
PHP
        
        echo "✅ wp-config.php created successfully"
    else
        echo "✅ wp-config.php already exists"
    fi
}

# Function to check if WordPress is installed
is_wordpress_installed() {
    wp core is-installed --allow-root 2>/dev/null
}

# Function to install WordPress if needed
install_wordpress() {
    if ! is_wordpress_installed; then
        echo "📦 Installing WordPress with external database..."
        wp core install \
            --url="${WORDPRESS_HOME:-http://localhost}" \
            --title="Five Rivers Tutoring" \
            --admin_user=admin \
            --admin_password=admin123 \
            --admin_email=admin@fiverivertutoring.com \
            --allow-root
        echo "✅ WordPress installed successfully"
    else
        echo "✅ WordPress already installed"
    fi
}

# Function to configure WordPress
configure_wordpress() {
    echo "⚙️ Configuring WordPress..."
    
    # Set WordPress URLs if provided
    if [ ! -z "${WORDPRESS_HOME:-}" ]; then
        echo "Setting WordPress home URL: $WORDPRESS_HOME"
        wp option update home "$WORDPRESS_HOME" --allow-root
    fi
    
    if [ ! -z "${WORDPRESS_SITEURL:-}" ]; then
        echo "Setting WordPress site URL: $WORDPRESS_SITEURL"
        wp option update siteurl "$WORDPRESS_SITEURL" --allow-root
    fi
    
    # Set environment type
    if [ ! -z "${WP_ENVIRONMENT_TYPE:-}" ]; then
        echo "Setting environment type: $WP_ENVIRONMENT_TYPE"
        wp config set WP_ENVIRONMENT_TYPE "$WP_ENVIRONMENT_TYPE" --allow-root
    fi
    
    # Set debug mode
    if [ ! -z "${WORDPRESS_DEBUG:-}" ]; then
        echo "Setting debug mode: $WORDPRESS_DEBUG"
        wp config set WP_DEBUG "$WORDPRESS_DEBUG" --allow-root
    fi
}

# Function to update WordPress URLs in database
update_urls() {
    if [ ! -z "${WORDPRESS_HOME:-}" ] && [ ! -z "${WORDPRESS_SITEURL:-}" ]; then
        echo "🔍 Checking if URLs need updating..."
        
        # Check if URLs need updating (look for development URLs in content)
        echo "🔍 Checking for development URLs that need conversion..."
        
        
        
        # Check if there are any URLs that need conversion (look for non-staging URLs)
        STAGING_DOMAIN=$(echo "$WORDPRESS_HOME" | sed 's|https\?://||' | sed 's|/.*||')
        DEV_URLS_COUNT=$(wp db query "SELECT COUNT(*) FROM wp_posts WHERE guid NOT LIKE '%$STAGING_DOMAIN%'" --allow-root | grep -v "COUNT" | tr -d ' ' || echo "0")
        
        if [ "$DEV_URLS_COUNT" = "0" ]; then
            echo "✅ No development URLs found, skipping update"
            return 0
        fi
        
        echo "🔍 Found $DEV_URLS_COUNT development URLs that need conversion"
        
        echo "🔄 Updating WordPress URLs..."
        
        # Comprehensive URL replacement for staging environment
        echo "Replacing ALL development URLs with staging URLs..."
        
        # Replace development URLs with staging URL
        echo "Replacing development URLs with staging URLs..."
        
        # Get development URL from environment (fallback to default)
        DEV_URL="${WORDPRESS_DEV_URL:-http://localhost:8082}"
        echo "Converting from: $DEV_URL to: $WORDPRESS_HOME"
        
        # Count and replace development URLs
        dev_url_count=$(wp search-replace "$DEV_URL" "$WORDPRESS_HOME" --allow-root --dry-run | grep -o '[0-9]\+ replacements' | head -1 | grep -o '[0-9]\+' || echo "0")
        echo "Found $dev_url_count development URLs to replace"
        
        wp search-replace \
            "$DEV_URL" "$WORDPRESS_HOME" \
            --allow-root
        
                         # Note: Removed generic localhost replacement to prevent URL corruption
                 # Only specific development URL replacement is performed above
        
        # Update WordPress core options
        echo "Updating WordPress core options..."
        wp option update home "$WORDPRESS_HOME" --allow-root
        wp option update siteurl "$WORDPRESS_SITEURL" --allow-root
        
        # Verify the update worked
        UPDATED_HOME=$(wp option get home --allow-root 2>/dev/null)
        if [ "$UPDATED_HOME" = "$WORDPRESS_HOME" ]; then
            echo "✅ URLs updated successfully and verified"
            echo "📊 Database cleaned of all development URLs"
            echo "📈 Replacement Summary:"
            echo "   - Development URLs ($DEV_URL): $dev_url_count replaced"
            echo "   - Total replacements: $dev_url_count"
        else
            echo "❌ URL update failed - current: $UPDATED_HOME, expected: $WORDPRESS_HOME"
        fi
    fi
}

# Function to verify database connection
verify_database() {
    echo "🔍 Verifying database connection..."
    
    # Test database connection
    if wp db check --allow-root; then
        echo "✅ Database connection verified"
        
        # Show database info
        echo "📊 Database Information:"
        wp db size --allow-root --human-readable
        wp db tables --allow-root | wc -l | xargs echo "Total tables:"
    else
        echo "❌ Database connection failed"
        exit 1
    fi
}

# Function to activate essential plugins
activate_plugins() {
    echo "🔌 Activating essential plugins..."
    
    # List of plugins to auto-activate (only essential plugins you plan to use)
    ESSENTIAL_PLUGINS=(
        "wpforms-lite"
        "wordpress-seo"
    )
    
    for plugin in "${ESSENTIAL_PLUGINS[@]}"; do
        if wp plugin is-installed "$plugin" --allow-root; then
            if ! wp plugin is-active "$plugin" --allow-root; then
                echo "Activating plugin: $plugin"
                wp plugin activate "$plugin" --allow-root
            else
                echo "Plugin already active: $plugin"
            fi
        else
            echo "Plugin not installed: $plugin"
        fi
    done
    
    echo "✅ Plugin activation completed"
}

# Function to activate theme
activate_theme() {
    echo "🎨 Activating theme..."
    
    # Activate Trend Business theme
    if wp theme is-installed trend-business --allow-root; then
        if ! wp theme is-active trend-business --allow-root; then
            echo "Activating theme: Trend Business"
            wp theme activate trend-business --allow-root
        else
            echo "Theme already active: Trend Business"
        fi
    else
        echo "Theme not found: trend-business"
        # Try alternative theme names
        if wp theme is-installed trend-business-theme --allow-root; then
            echo "Activating theme: trend-business-theme"
            wp theme activate trend-business-theme --allow-root
        else
            echo "⚠️ Trend Business theme not found. Available themes:"
            wp theme list --allow-root
        fi
    fi
    
    echo "✅ Theme activation completed"
}

# Function to show WordPress status
show_status() {
    echo "📋 WordPress Status:"
    echo "  Site URL: ${WORDPRESS_HOME:-http://localhost}"
    echo "  Admin URL: ${WORDPRESS_HOME:-http://localhost}/wp-admin"
    echo "  Database: $WORDPRESS_DB_HOST/$WORDPRESS_DB_NAME"
    echo "  Environment: ${WP_ENVIRONMENT_TYPE:-production}"
    echo "  Debug Mode: ${WORDPRESS_DEBUG:-0}"
}

# Main execution
main() {
    echo "🎯 Five Rivers Tutoring WordPress Container Starting..."
    echo "=================================================="
    
    # Wait for external database
    wait_for_external_db
    
    # Create wp-config.php if it doesn't exist
    create_wp_config
    
    # Install WordPress if needed
    install_wordpress
    
    # Configure WordPress
    configure_wordpress
    
    # Update URLs if needed
    update_urls
    
    # Activate essential plugins
    activate_plugins
    
    # Activate theme
    activate_theme
    
    # Verify database connection
    verify_database
    
    # Show status
    show_status
    
    echo ""
    echo "🎉 Five Rivers Tutoring WordPress ready!"
    echo "=================================================="
    
    # Execute the main command (apache2-foreground)
    exec "$@"
}

# Run main function
main "$@" 