# WordPress Module
# This module manages WordPress application deployment and configuration

# =============================================================================
# WORDPRESS APPLICATION DEPLOYMENT
# =============================================================================

# WordPress application deployment script
resource "null_resource" "deploy_wordpress" {
  triggers = {
    # Trigger on changes to WordPress configuration
    wordpress_image = var.wordpress_image
    wordpress_db_host = var.wordpress_db_host
    wordpress_db_name = var.wordpress_db_name
    wordpress_db_user = var.wordpress_db_user
  }

  provisioner "local-exec" {
    command = "echo 'WordPress deployment will be handled by deploy-wordpress.sh script'"
    interpreter = ["cmd", "/c"]
  }
}

# =============================================================================
# WORDPRESS CONFIGURATION FILES
# =============================================================================

# WordPress configuration file
resource "local_file" "wordpress_config" {
  filename = "${path.module}/wordpress-config.php"
  content  = <<-EOT
<?php
// WordPress Database Configuration
define('DB_NAME', '${var.wordpress_db_name}');
define('DB_USER', '${var.wordpress_db_user}');
define('DB_PASSWORD', '${var.wordpress_db_password}');
define('DB_HOST', '${var.wordpress_db_host}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// WordPress URLs
define('WP_HOME', 'http://${var.wordpress_domain}');
define('WP_SITEURL', 'http://${var.wordpress_domain}');

// Security
define('AUTH_KEY', '${random_password.wordpress_auth_key.result}');
define('SECURE_AUTH_KEY', '${random_password.wordpress_secure_auth_key.result}');
define('LOGGED_IN_KEY', '${random_password.wordpress_logged_in_key.result}');
define('NONCE_KEY', '${random_password.wordpress_nonce_key.result}');
define('AUTH_SALT', '${random_password.wordpress_auth_salt.result}');
define('SECURE_AUTH_SALT', '${random_password.wordpress_secure_auth_salt.result}');
define('LOGGED_IN_SALT', '${random_password.wordpress_logged_in_salt.result}');
define('NONCE_SALT', '${random_password.wordpress_nonce_salt.result}');

// Performance
define('WP_CACHE', true);
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

// File permissions
define('FS_METHOD', 'direct');
define('WP_TEMP_DIR', '/tmp');

// Memory limits
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');
EOT
}

# =============================================================================
# WORDPRESS SECURITY KEYS
# =============================================================================

# Generate random WordPress security keys
resource "random_password" "wordpress_auth_key" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_secure_auth_key" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_logged_in_key" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_nonce_key" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_auth_salt" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_secure_auth_salt" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_logged_in_salt" {
  length  = 64
  special = true
}

resource "random_password" "wordpress_nonce_salt" {
  length  = 64
  special = true
}

# =============================================================================
# WORDPRESS HEALTH CHECKS
# =============================================================================

# WordPress health check endpoint
resource "null_resource" "wordpress_health_check" {
  triggers = {
    wordpress_deployed = null_resource.deploy_wordpress.id
  }

  provisioner "local-exec" {
    command = "echo 'WordPress health check will be performed after deployment'"
    interpreter = ["cmd", "/c"]
  }
}
