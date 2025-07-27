<?php
// Production WordPress Configuration for ValueLadder
// Add this to wp-config.php

// Database Configuration
define('DB_NAME', 'valueladder_prod');
define('DB_USER', 'wordpress_user');
define('DB_PASSWORD', 'your_secure_password_here');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// Security Settings
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);
define('AUTOMATIC_UPDATER_DISABLED', false);

// Performance Settings
define('WP_CACHE', true);
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');

// SSL/HTTPS Settings
define('FORCE_SSL_ADMIN', true);
define('FORCE_SSL_LOGIN', true);

// File System Settings
define('FS_METHOD', 'direct');
define('WP_CONTENT_DIR', '/var/www/html/wp-content');
define('WP_CONTENT_URL', 'https://your-domain.com/wp-content');

// Security Keys (generate new ones)
define('AUTH_KEY',         'your-unique-phrase-here');
define('SECURE_AUTH_KEY',  'your-unique-phrase-here');
define('LOGGED_IN_KEY',    'your-unique-phrase-here');
define('NONCE_KEY',        'your-unique-phrase-here');
define('AUTH_SALT',        'your-unique-phrase-here');
define('SECURE_AUTH_SALT', 'your-unique-phrase-here');
define('LOGGED_IN_SALT',   'your-unique-phrase-here');
define('NONCE_SALT',       'your-unique-phrase-here');

// Disable XML-RPC (security)
add_filter('xmlrpc_enabled', '__return_false');

// Disable file editing in admin
define('DISALLOW_FILE_EDIT', true);

// Set proper timezone
date_default_timezone_set('Australia/Sydney');
?> 