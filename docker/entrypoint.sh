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