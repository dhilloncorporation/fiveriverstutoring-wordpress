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
    
    # Try SSL connection with configurable SSL settings
    while ! mysql --ssl --ssl-verify-server-cert="${MYSQL_SSL_VERIFY_SERVER_CERT:-0}" -h"${WORDPRESS_DB_HOST:-localhost}" -u"${WORDPRESS_DB_USER:-root}" -p"${WORDPRESS_DB_PASSWORD:-}" -e "SELECT 1;" >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        echo "Database not ready, waiting... (Attempt $attempts/$max_attempts)"
        
        if [ $attempts -ge $max_attempts ]; then
            echo "❌ Failed to connect to database after $max_attempts attempts"
            echo "Database connection details:"
            echo "Host: ${WORDPRESS_DB_HOST:-localhost}"
            echo "User: ${WORDPRESS_DB_USER:-root}"
            echo "Database: ${WORDPRESS_DB_NAME:-fiveriverstutoring_db}"
            echo "Testing connection manually..."
            echo "Trying SSL connection with configurable settings..."
            mysql --ssl --ssl-verify-server-cert="${MYSQL_SSL_VERIFY_SERVER_CERT:-0}" -h"${WORDPRESS_DB_HOST:-localhost}" -u"${WORDPRESS_DB_USER:-root}" -p"${WORDPRESS_DB_PASSWORD:-}" -e "SELECT 1;" || echo "SSL connection failed"
            exit 1
        fi
        
        sleep 5
    done
    echo "✅ External database connection established"
}

# Function to create wp-config.php if it doesn't exist
create_wp_config() {
    # WordPress CLI SSL configuration
    if [ "${MYSQL_SSL_VERIFY_SERVER_CERT:-0}" = "0" ]; then
        # For staging/self-signed certificates - skip SSL verification
        export MYSQL_CLIENT_FLAGS="MYSQLI_CLIENT_SSL_DONT_VERIFY_SERVER_CERT"
        export WP_CLI_CONFIG_PATH="$HOME/.wp-cli/config.yml"
        mkdir -p "$HOME/.wp-cli"
        cat > "$HOME/.wp-cli/config.yml" << EOF
# WordPress CLI configuration for SSL
db:
  ssl:
    ca: /etc/ssl/certs/ca-certificates.crt
    verify_server_cert: false
    cipher: ""
EOF
    else
        # For production - verify SSL certificates
        export MYSQL_CLIENT_FLAGS="MYSQLI_CLIENT_SSL"
        export WP_CLI_CONFIG_PATH="$HOME/.wp-cli/config.yml"
        mkdir -p "$HOME/.wp-cli"
        cat > "$HOME/.wp-cli/config.yml" << EOF
# WordPress CLI configuration for SSL
db:
  ssl:
    ca: /etc/ssl/certs/ca-certificates.crt
    verify_server_cert: true
    cipher: ""
EOF
    fi
    
    # Set standard environment variables
    export MYSQL_SSL_CA=/etc/ssl/certs/ca-certificates.crt
    export MYSQL_SSL_VERIFY_SERVER_CERT=${MYSQL_SSL_VERIFY_SERVER_CERT:-0}
    export MYSQL_SSL=1
    
    # Create MySQL client config in user's home directory (for mysql command)
    mkdir -p ~/.mysql
    cat > ~/.mysql/my.cnf << EOF
[client]
ssl-ca=/etc/ssl/certs/ca-certificates.crt
ssl-verify-server-cert=${MYSQL_SSL_VERIFY_SERVER_CERT:-0}
ssl=1

[mysql]
ssl-ca=/etc/ssl/certs/ca-certificates.crt
ssl-verify-server-cert=${MYSQL_SSL_VERIFY_SERVER_CERT:-0}
ssl=1
EOF
    
    # Debug: Show the configurations
    echo "🔧 WordPress CLI SSL config created in ~/.wp-cli/config.yml:"
    cat ~/.wp-cli/config.yml
    echo "🔧 MySQL client config created in ~/.mysql/my.cnf:"
    cat ~/.mysql/my.cnf
    echo "🔧 MySQL SSL environment variables:"
    echo "  MYSQL_SSL_CA: $MYSQL_SSL_CA"
    echo "  MYSQL_SSL_VERIFY_SERVER_CERT: $MYSQL_SSL_VERIFY_SERVER_CERT"
    echo "  MYSQL_SSL: $MYSQL_SSL"
    echo "  WP_CLI_CONFIG_PATH: $WP_CLI_CONFIG_PATH"
    
    if [ ! -f "wp-config.php" ]; then
        echo "📝 Creating wp-config.php from environment variables..."
        
        # Create wp-config.php using wp config create with SSL configuration
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

// WordPress Database SSL Configuration
define( 'DB_SSL', true );
define( 'DB_SSL_CA', '/etc/ssl/certs/ca-certificates.crt' );
define( 'DB_SSL_VERIFY', ${MYSQL_SSL_VERIFY_SERVER_CERT:-0} == 1 );
define( 'DB_SSL_CIPHER', '' );
define( 'DB_SSL_KEY', '' );
define( 'DB_SSL_CERT', '' );

// MySQL Client Flags for WordPress
define( 'MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL | MYSQLI_CLIENT_SSL_DONT_VERIFY_SERVER_CERT );
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
            --admin_email=admin@fiveriverstutoring.com \
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
        
        # Detect environment and set up URL conversion patterns
        ENVIRONMENT="${WP_ENVIRONMENT_TYPE:-development}"
        TARGET_URL="$WORDPRESS_HOME"
        
        echo "🌐 Environment: $ENVIRONMENT"
        echo "🎯 Target URL: $TARGET_URL"
        
        # Get current WordPress URLs to check if update is needed
        CURRENT_HOME=$(wp option get home --allow-root 2>/dev/null || echo "")
        CURRENT_SITEURL=$(wp option get siteurl --allow-root 2>/dev/null || echo "")
        
        echo "🔍 Current Home URL: $CURRENT_HOME"
        echo "🔍 Current Site URL: $CURRENT_SITEURL"
        
        # Check for development URLs in database content (more reliable check)
        DEV_URL_COUNT=0
        
        # Define source URLs to check based on environment
        declare -a CHECK_URLS=()
        case "$ENVIRONMENT" in
            "staging")
                CHECK_URLS+=("${WORDPRESS_DEV_URL:-http://localhost:8082}")
                CHECK_URLS+=("http://localhost:8082")
                ;;
            "production")
                CHECK_URLS+=("${WORDPRESS_DEV_URL:-http://localhost:8082}")
                CHECK_URLS+=("http://localhost:8082")
                CHECK_URLS+=("${STAGING_URL:-http://localhost:8083}")
                CHECK_URLS+=("http://localhost:8083")
                ;;
            *)
                CHECK_URLS+=("${PRODUCTION_URL:-https://yourdomain.com}")
                CHECK_URLS+=("${STAGING_URL:-http://localhost:8083}")
                ;;
        esac
        
        # Count development URLs in database content using wp search-replace dry-run
        for check_url in "${CHECK_URLS[@]}"; do
            if [ ! -z "$check_url" ] && [ "$check_url" != "$TARGET_URL" ]; then
                echo "🔍 Checking for URLs: $check_url"
                
                # Use wp search-replace dry-run to get accurate count
                replacement_output=$(wp search-replace "$check_url" "$TARGET_URL" --allow-root --dry-run 2>/dev/null || echo "0 replacements")
                
                # Extract number from "Made X replacements" or "X replacements"
                url_count=$(echo "$replacement_output" | grep -o '[0-9]\+ replacements' | head -1 | grep -o '[0-9]\+' || echo "0")
                
                # Fallback: try simple database check if wp search-replace fails
                if [ "$url_count" = "0" ]; then
                    # Simple test - check if URL exists in database at all
                    db_test=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_value LIKE '%${check_url}%' LIMIT 1;" --allow-root 2>/dev/null | tail -1 | tr -d ' ' || echo "0")
                    if [ "$db_test" != "0" ] && [ "$db_test" != "count" ]; then
                        url_count="$db_test"
                        echo "🔍 Fallback database check found $db_test URLs"
                    fi
                fi
                
                DEV_URL_COUNT=$((DEV_URL_COUNT + url_count))
                
                if [ "$url_count" -gt 0 ]; then
                    echo "🔍 Found $url_count instances of $check_url that need conversion"
                else
                    echo "🔍 No instances of $check_url found"
                fi
                
                # Debug output
                echo "🔧 Debug - wp search-replace output: $replacement_output"
                echo "🔧 Debug - extracted count: $url_count"
                echo "🔧 Debug - running total: $DEV_URL_COUNT"
            fi
        done
        
        # Check if URLs are already correct AND no development URLs in content
        if [ "$CURRENT_HOME" = "$WORDPRESS_HOME" ] && [ "$CURRENT_SITEURL" = "$WORDPRESS_SITEURL" ] && [ "$DEV_URL_COUNT" -eq 0 ]; then
            echo "✅ WordPress URLs and database content already correct, skipping update"
            return 0
        fi
        
        if [ "$DEV_URL_COUNT" -gt 0 ]; then
            echo "🔄 Found $DEV_URL_COUNT development URLs in database content - conversion needed"
        fi
        if [ "$CURRENT_HOME" != "$WORDPRESS_HOME" ] || [ "$CURRENT_SITEURL" != "$WORDPRESS_SITEURL" ]; then
            echo "🔄 WordPress options need updating - conversion needed"
        fi
        
        echo "🔄 URLs need updating - starting conversion process..."
        
        # Define source URLs to replace based on environment
        declare -a SOURCE_URLS=()
        
        case "$ENVIRONMENT" in
            "staging")
                # Staging: Replace development URLs
                SOURCE_URLS+=("${WORDPRESS_DEV_URL:-http://localhost:8082}")
                SOURCE_URLS+=("http://localhost:8082")
                echo "📝 Staging environment: Converting development URLs to staging"
                ;;
            "production")
                # Production: Replace both development and staging URLs
                SOURCE_URLS+=("${WORDPRESS_DEV_URL:-http://localhost:8082}")
                SOURCE_URLS+=("http://localhost:8082")
                SOURCE_URLS+=("${STAGING_URL:-http://localhost:8083}")
                SOURCE_URLS+=("http://localhost:8083")
                echo "📝 Production environment: Converting development and staging URLs to production"
                ;;
            *)
                # Development or unknown: Replace any other URLs
                SOURCE_URLS+=("${PRODUCTION_URL:-https://yourdomain.com}")
                SOURCE_URLS+=("${STAGING_URL:-http://localhost:8083}")
                echo "📝 Development environment: Converting staging/production URLs to development"
                ;;
        esac
        
        # Perform URL replacements
        total_replacements=0
        for source_url in "${SOURCE_URLS[@]}"; do
            if [ ! -z "$source_url" ] && [ "$source_url" != "$TARGET_URL" ]; then
                echo "🔄 Converting: $source_url → $TARGET_URL"
                
                # Count replacements for this URL
                replacement_count=$(wp search-replace "$source_url" "$TARGET_URL" --allow-root --dry-run 2>/dev/null | grep -o '[0-9]\+ replacements' | head -1 | grep -o '[0-9]\+' || echo "0")
                
                if [ "$replacement_count" -gt 0 ]; then
                    echo "   Found $replacement_count instances to replace"
                    
                    # Perform the actual replacement (including GUIDs for staging/dev environments)
                    if [ "$ENVIRONMENT" = "production" ]; then
                        # Production: Skip GUIDs to maintain WordPress best practices
                        wp search-replace "$source_url" "$TARGET_URL" --allow-root --skip-columns=guid || echo "   ⚠️ Some replacements may have had issues"
                    else
                        # Staging/Development: Include GUIDs for complete URL conversion
                        wp search-replace "$source_url" "$TARGET_URL" --allow-root || echo "   ⚠️ Some replacements may have had issues"
                    fi
                    
                    total_replacements=$((total_replacements + replacement_count))
                else
                    echo "   No instances found"
                fi
            fi
        done
        
        # Update WordPress core options (always ensure these are correct)
        echo "🔧 Updating WordPress core options..."
        wp option update home "$WORDPRESS_HOME" --allow-root
        wp option update siteurl "$WORDPRESS_SITEURL" --allow-root
        
        # Verify the update worked
        UPDATED_HOME=$(wp option get home --allow-root 2>/dev/null || echo "")
        UPDATED_SITEURL=$(wp option get siteurl --allow-root 2>/dev/null || echo "")
        
        if [ "$UPDATED_HOME" = "$WORDPRESS_HOME" ] && [ "$UPDATED_SITEURL" = "$WORDPRESS_SITEURL" ]; then
            echo "✅ URLs updated successfully and verified"
            echo "📊 Environment: $ENVIRONMENT"
            echo "📈 Replacement Summary:"
            echo "   - Total URL replacements: $total_replacements"
            echo "   - Home URL: $UPDATED_HOME"
            echo "   - Site URL: $UPDATED_SITEURL"
        else
            echo "⚠️ URL verification had mixed results:"
            echo "   Expected Home: $WORDPRESS_HOME"
            echo "   Actual Home: $UPDATED_HOME"
            echo "   Expected Site: $WORDPRESS_SITEURL"
            echo "   Actual Site: $UPDATED_SITEURL"
        fi
        
        echo "✅ URL update process completed for $ENVIRONMENT environment"
    else
        echo "⚠️ WORDPRESS_HOME or WORDPRESS_SITEURL not set, skipping URL updates"
    fi
}

# Function to verify WordPress SSL configuration
verify_wordpress_ssl() {
    echo "🔍 Verifying WordPress SSL configuration..."
    
    # Check if PHP MySQL extensions are loaded
    if php -m | grep -q mysqli; then
        echo "✅ mysqli extension loaded"
    else
        echo "❌ mysqli extension not loaded"
        return 1
    fi
    
    if php -m | grep -q pdo_mysql; then
        echo "✅ pdo_mysql extension loaded"
    else
        echo "❌ pdo_mysql extension not loaded"
        return 1
    fi
    
    # Check WordPress SSL configuration in wp-config.php
    if [ -f "wp-config.php" ]; then
        echo "🔧 WordPress SSL Configuration in wp-config.php:"
        grep -E "DB_SSL|MYSQL_CLIENT_FLAGS" wp-config.php || echo "No WordPress SSL configuration found"
    else
        echo "⚠️ wp-config.php not found"
    fi
    
    # Check WordPress CLI SSL configuration
    if [ -f "$HOME/.wp-cli/config.yml" ]; then
        echo "🔧 WordPress CLI SSL Configuration in ~/.wp-cli/config.yml:"
        cat "$HOME/.wp-cli/config.yml"
    else
        echo "⚠️ WordPress CLI config not found"
    fi
    
    echo "✅ WordPress SSL configuration verified"
}

# Function to verify database connection
verify_database() {
    echo "🔍 Verifying database connection..."
    
    # First verify WordPress SSL configuration
    verify_wordpress_ssl
    
    # Test database connection using direct PHP (avoid wp db check which uses mariadb-check)
    echo "🔍 Testing database connection with PHP MySQL..."
    
    # Test direct PHP MySQL connection
    php -r "
    \$mysqli = new mysqli('${WORDPRESS_DB_HOST:-localhost}', '${WORDPRESS_DB_USER:-root}', '${WORDPRESS_DB_PASSWORD:-}', '${WORDPRESS_DB_NAME:-fiveriverstutoring_db}');
    if (\$mysqli->connect_error) {
        echo '❌ PHP MySQL connection failed: ' . \$mysqli->connect_error . PHP_EOL;
        exit(1);
    } else {
        echo '✅ PHP MySQL connection successful' . PHP_EOL;
        \$result = \$mysqli->query('SELECT 1 as test, COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = \"${WORDPRESS_DB_NAME:-fiveriverstutoring_db}\"');
        if (\$result) {
            \$row = \$result->fetch_assoc();
            echo '✅ Test query successful: ' . \$row['test'] . PHP_EOL;
            echo '📊 Database tables found: ' . \$row['table_count'] . PHP_EOL;
        } else {
            echo '❌ Test query failed: ' . \$mysqli->error . PHP_EOL;
            exit(1);
        }
        \$mysqli->close();
        echo '✅ Database connection verified - WordPress is ready!' . PHP_EOL;
    }
    "
    
    # Check PHP exit code
    if [ $? -ne 0 ]; then
        echo "❌ Database connection failed"
        exit 1
    fi
    
    # Test with our configured MySQL client (optional)
    echo "🔍 Testing MySQL client connection..."
    if mysql -h"${WORDPRESS_DB_HOST:-localhost}" -u"${WORDPRESS_DB_USER:-root}" -p"${WORDPRESS_DB_PASSWORD:-}" -e "SELECT 'MySQL client connection successful' as status;" "${WORDPRESS_DB_NAME:-fiveriverstutoring_db}" 2>/dev/null; then
        echo "✅ MySQL client connection verified"
    else
        echo "⚠️ MySQL client connection failed (but PHP connection works)"
    fi
}



# Function to activate essential plugins
activate_plugins() {
    echo "🔌 Activating essential plugins..."
    
    # Debug: Check wp-content/plugins directory structure
    echo "🔍 Checking wp-content/plugins directory:"
    if [ -d "wp-content/plugins" ]; then
        echo "📁 wp-content/plugins directory exists"
        echo "📋 Contents:"
        ls -la wp-content/plugins/ || echo "⚠️ Could not list plugins directory"
    else
        echo "❌ wp-content/plugins directory not found"
    fi
    
    # Debug: List all available plugins first
    echo "🔍 Available plugins in WordPress:"
    wp plugin list --allow-root --status=inactive || echo "⚠️ Could not list plugins"
    
    # List of plugins to auto-activate (only essential plugins you actually have)
    ESSENTIAL_PLUGINS=(
        "wordpress-seo"
        "elementor"
        "contact-us"
    )
    
    for plugin in "${ESSENTIAL_PLUGINS[@]}"; do
        echo "🔍 Checking plugin: $plugin"
        if wp plugin is-installed "$plugin" --allow-root; then
            if ! wp plugin is-active "$plugin" --allow-root; then
                echo "Activating plugin: $plugin"
                wp plugin activate "$plugin" --allow-root
            else
                echo "Plugin already active: $plugin"
            fi
        else
            echo "Plugin not installed: $plugin"
            # Debug: Check if plugin directory exists
            if [ -d "wp-content/plugins/$plugin" ]; then
                echo "⚠️ Plugin directory exists but not recognized by WordPress: wp-content/plugins/$plugin"
                # Check if plugin has proper structure
                if [ -f "wp-content/plugins/$plugin/$plugin.php" ] || [ -f "wp-content/plugins/$plugin/contact-us.php" ]; then
                    echo "✅ Plugin main file found"
                else
                    echo "❌ Plugin main file not found"
                fi
            fi
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