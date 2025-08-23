<?php
/**
 * Gmail API Admin Settings for Contact Us Plugin
 * Handles Gmail API configuration and OAuth2 setup
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

class ContactUsGmailAdminSettings {
    
    public function __construct() {
        add_action('admin_menu', array($this, 'add_admin_menu'), 20);
        add_action('admin_init', array($this, 'init_settings'));
        add_action('wp_ajax_test_gmail_connection', array($this, 'test_gmail_connection'));
        add_action('wp_ajax_clear_gmail_tokens', array($this, 'clear_gmail_tokens'));
        add_action('wp_ajax_refresh_gmail_token', array($this, 'refresh_gmail_token'));
        add_action('admin_enqueue_scripts', array($this, 'enqueue_admin_scripts'));
    }
    
    /**
     * Add admin menu
     */
    public function add_admin_menu() {
        // Try to add as submenu to contact-us first
        if (menu_page_url('contact-us', false)) {
            add_submenu_page(
                'contact-us',
                'Gmail API Settings',
                'Gmail API',
                'manage_options',
                'contact-us-gmail',
                array($this, 'render_gmail_settings_page')
            );
        } else {
            // Fallback: create as standalone menu
            add_menu_page(
                'Gmail API Settings',
                'Gmail API',
                'manage_options',
                'contact-us-gmail',
                array($this, 'render_gmail_settings_page'),
                'dashicons-email',
                31
            );
        }
    }
    
    /**
     * Enqueue admin scripts
     */
    public function enqueue_admin_scripts($hook) {
        // Check for both possible hook names
        if ($hook !== 'contact-us_page_contact-us-gmail' && $hook !== 'toplevel_page_contact-us-gmail') {
            return;
        }
        
        wp_enqueue_script('contact-us-gmail-admin', plugin_dir_url(__FILE__) . '../assets/js/gmail-admin.js', array('jquery'), '1.0.0', true);
        wp_localize_script('contact-us-gmail-admin', 'gmail_admin_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('gmail_admin_nonce')
        ));
    }
    
    /**
     * Initialize settings
     */
    public function init_settings() {
        register_setting('contact_us_gmail_group', 'contact_us_gmail_settings', array(
            'sanitize_callback' => array($this, 'sanitize_gmail_settings')
        ));
        
        add_settings_section(
            'contact_us_gmail_section',
            'Gmail API Configuration',
            array($this, 'render_gmail_section'),
            'contact_us_gmail_settings'
        );
        
        // Gmail API Settings
        add_settings_field(
            'gmail_enabled',
            'Enable Gmail API',
            array($this, 'render_checkbox_field'),
            'contact_us_gmail_settings',
            'contact_us_gmail_section',
            array('field' => 'enabled', 'label' => 'Use Gmail API for email delivery')
        );
        
        add_settings_field(
            'gmail_client_id',
            'Client ID',
            array($this, 'render_text_field'),
            'contact_us_gmail_settings',
            'contact_us_gmail_section',
            array('field' => 'client_id', 'placeholder' => 'Your Gmail OAuth Client ID')
        );
        
        add_settings_field(
            'gmail_client_secret',
            'Client Secret',
            array($this, 'render_text_field'),
            'contact_us_gmail_settings',
            'contact_us_gmail_section',
            array('field' => 'client_secret', 'placeholder' => 'Your Gmail OAuth Client Secret')
        );
        
        add_settings_field(
            'gmail_from_email',
            'From Email',
            array($this, 'render_text_field'),
            'contact_us_gmail_settings',
            'contact_us_gmail_section',
            array('field' => 'from_email', 'placeholder' => 'your-email@gmail.com')
        );
        
        add_settings_field(
            'gmail_from_name',
            'From Name',
            array($this, 'render_text_field'),
            'contact_us_gmail_settings',
            'contact_us_gmail_section',
            array('field' => 'from_name', 'placeholder' => 'Five Rivers Tutoring')
        );
        
        add_settings_field(
            'gmail_to_email',
            'To Email (Contact Form Recipient)',
            array($this, 'render_text_field'),
            'contact_us_gmail_settings',
            'contact_us_gmail_section',
            array('field' => 'to_email', 'placeholder' => 'contact@yourdomain.com')
        );
    }
    
    /**
     * Render Gmail settings page
     */
    public function render_gmail_settings_page() {
        // ALWAYS load the autoloader first to ensure Google Client is available
        $composer_autoload = ABSPATH . 'vendor/autoload.php';
        if (file_exists($composer_autoload)) {
            require_once $composer_autoload;
        } else {
            ?>
            <div class="wrap">
                <h1>Contact Us - Gmail API Settings</h1>
                <div class="notice notice-error">
                    <p><strong>Error:</strong> Google API Client library not found.</p>
                    <p>The library should be installed at: <code><?php echo ABSPATH; ?>vendor/autoload.php</code></p>
                    <p>Please ensure Composer dependencies are installed in your WordPress directory.</p>
                </div>
            </div>
            <?php
            return;
        }
        
        // Now verify Google Client class is available
        if (!class_exists('Google_Client')) {
            ?>
            <div class="wrap">
                <h1>Contact Us - Gmail API Settings</h1>
                <div class="notice notice-error">
                    <p><strong>Error:</strong> Google API Client library still not available after loading autoloader.</p>
                    <p>This suggests a deeper issue with the library installation.</p>
                </div>
            </div>
            <?php
            return;
        }
        
        // Create Gmail API instance and get status
        $gmail_api = new ContactUsGmailAPI();
        
        // Force refresh status if we just completed OAuth
        if (isset($_GET['oauth_callback']) && $_GET['oauth_callback'] === 'success') {
            // Clear any cached status and force refresh
            // Force a small delay to ensure database is updated
            usleep(100000); // 0.1 second delay
        }
        
        $status = $gmail_api->get_status();
        
        // Check completion status for each section
        $has_credentials = $this->has_credentials();
        $is_authenticated = $gmail_api->is_authenticated();
        $is_authorized = $gmail_api->is_authorized();
        $is_library_available = $gmail_api->is_library_available();
        $are_tokens_stale = $gmail_api->are_tokens_stale();
        $token_info = $gmail_api->get_token_info();
        
        // Determine if re-authentication is needed
        $needs_re_auth = $are_tokens_stale || $status === 'token_expired' || $status === 'token_expired_no_refresh';
        
        ?>
        <div class="wrap">
            <h1>Contact Us - Gmail API Settings</h1>
            
            <?php if (isset($_GET['oauth_callback']) && $_GET['oauth_callback'] === 'success'): ?>
                <div class="notice notice-success is-dismissible">
                    <p><strong>🎉 OAuth2 Authorization Successful!</strong> Gmail API is now connected and ready to use.</p>
                </div>
            <?php endif; ?>
            
            <?php if (isset($_GET['oauth_error'])): ?>
                <div class="notice notice-error is-dismissible">
                    <p><strong>Error!</strong> Failed to connect Gmail API.</p>
                </div>
            <?php endif; ?>
            
            <!-- Debug Information (remove this later) -->
            <?php if (current_user_can('manage_options')): ?>
            <div class="notice notice-info" style="background: #fff3cd; border-color: #ffeaa7;">
                <p><strong>Debug Info:</strong></p>
                <ul style="margin: 10px 0; padding-left: 20px;">
                    <li>Status: <code><?php echo esc_html($status); ?></code></li>
                    <li>Has Credentials: <code><?php echo $has_credentials ? 'Yes' : 'No'; ?></code></li>
                    <li>Is Authenticated: <code><?php echo $is_authenticated ? 'Yes' : 'No'; ?></code></li>
                    <li>Is Authorized: <code><?php echo $is_authorized ? 'Yes' : 'No'; ?></code></li>
                    <li>Are Tokens Stale: <code><?php echo $are_tokens_stale ? 'Yes' : 'No'; ?></code></li>
                    <li>Needs Re-auth: <code><?php echo $needs_re_auth ? 'Yes' : 'No'; ?></code></li>
                    <li>OAuth Callback: <code><?php echo isset($_GET['oauth_callback']) ? esc_html($_GET['oauth_callback']) : 'None'; ?></code></li>
                </ul>
            </div>
            <?php endif; ?>
            
            <div class="notice notice-info">
                <p><strong>Gmail API Setup:</strong> This will replace SMTP email delivery with Google's Gmail API for 100% reliable email delivery.</p>
            </div>
            
            <!-- Library Status Check -->
            <?php if (!$is_library_available): ?>
            <div class="gmail-section library-error">
                <div class="section-header">
                    <h2>⚠️ Library Missing</h2>
                    <span class="section-status error">❌ Critical Error</span>
                </div>
                <div class="section-content">
                    <div class="library-error-message">
                        <p><strong>Google API Client library is not available!</strong></p>
                        <p>This plugin requires the Google API Client library to function. Please ensure:</p>
                        <ol>
                            <li>Composer is installed on your system</li>
                            <li>Run <code>composer require google/apiclient</code> in your WordPress root directory</li>
                            <li>The <code>vendor/autoload.php</code> file exists</li>
                        </ol>
                        <p><strong>Current paths checked:</strong></p>
                        <ul>
                            <li><code><?php echo ABSPATH; ?>vendor/autoload.php</code> - <?php echo file_exists(ABSPATH . 'vendor/autoload.php') ? '✅ Found' : '❌ Not found'; ?></li>
                            <li><code><?php echo ABSPATH; ?>../../vendor/autoload.php</code> - <?php echo file_exists(ABSPATH . '../../vendor/autoload.php') ? '✅ Found' : '❌ Not found'; ?></li>
                        </ul>
                        <p><strong>Contact your administrator or hosting provider to install the required dependencies.</strong></p>
                    </div>
                </div>
            </div>
            <?php endif; ?>
            
            <!-- Section 1: Email Authentication - Google -->
            <div class="gmail-section">
                <div class="section-header">
                    <h2>1. Email Authentication - Google</h2>
                    <?php if ($has_credentials): ?>
                        <span class="section-status completed">✅ Completed</span>
                    <?php else: ?>
                        <span class="section-status pending">⏳ Pending</span>
                    <?php endif; ?>
                    
                    <?php if ($has_credentials): ?>
                        <button type="button" class="section-toggle" id="auth-toggle-btn" data-section="auth-section">
                            <span class="toggle-icon">▼</span>
                            <span class="toggle-text">Show Details</span>
                        </button>
                    <?php endif; ?>
                </div>
                
                <div class="section-content <?php echo $has_credentials ? 'collapsible-content' : ''; ?>" id="auth-section">
                    <?php if (!$has_credentials): ?>
                        <p>Configure your Google OAuth2 credentials to enable Gmail API access.</p>
                        
                        <div class="oauth-config-info">
                            <h3>Google Cloud Console Setup</h3>
                            <ol>
                                <li>Go to <a href="https://console.cloud.google.com/" target="_blank">Google Cloud Console</a></li>
                                <li>Create a new project or select existing</li>
                                <li>Enable Gmail API</li>
                                <li>Create OAuth 2.0 credentials</li>
                                <li>Set redirect URI to: <code><?php echo home_url('/?contact_us_oauth=callback'); ?></code></li>
                                <li>Download credentials and enter below</li>
                            </ol>
                            
                            <div class="redirect-uri-display">
                                <strong>Redirect URI:</strong>
                                <code><?php echo home_url('/?contact_us_oauth=callback'); ?></code>
                                <button type="button" class="button button-small" onclick="navigator.clipboard.writeText('<?php echo home_url('/?contact_us_oauth=callback'); ?>')">Copy</button>
                            </div>
                        </div>
                        
                        <form method="post" action="options.php">
                            <?php
                            settings_fields('contact_us_gmail_group');
                            do_settings_sections('contact_us_gmail_settings');
                            submit_button('Save Gmail Settings');
                            ?>
                        </form>
                    <?php else: ?>
                        <div class="credentials-display" style="display: none;">
                            <h3>Current Credentials</h3>
                            <table class="form-table">
                                <tr>
                                    <th scope="row">Client ID:</th>
                                    <td><?php echo esc_html($this->get_settings()['client_id'] ?? 'Not set'); ?></td>
                                </tr>
                                <tr>
                                    <th scope="row">Client Secret:</th>
                                    <td><?php echo esc_html($this->get_settings()['client_secret'] ? '***' . substr($this->get_settings()['client_secret'], -4) : 'Not set'); ?></td>
                                </tr>
                                <tr>
                                    <th scope="row">From Email:</th>
                                    <td><?php echo esc_html($this->get_settings()['from_email'] ?? 'Not set'); ?></td>
                                </tr>
                                <tr>
                                    <th scope="row">To Email (Contact Form Recipient):</th>
                                    <td><?php echo esc_html($this->get_settings()['to_email'] ?? get_option('admin_email')); ?></td>
                                </tr>
                            </table>
                        </div>
                        
                        <!-- Hidden form for editing credentials -->
                        <div id="edit-credentials-form" style="display: none;">
                            <h4>Edit Gmail API Credentials</h4>
                            <form method="post" action="options.php">
                                <?php
                                settings_fields('contact_us_gmail_group');
                                do_settings_sections('contact_us_gmail_settings');
                                ?>
                                <div class="form-actions">
                                    <button type="submit" class="button button-primary">Update Credentials</button>
                                    <button type="button" id="cancel-edit-btn" class="button button-secondary">Cancel</button>
                                </div>
                            </form>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <!-- Section 2: Email Authorization - Google -->
            <div class="gmail-section">
                <div class="section-header">
                    <h2>2. Email Authorization - Google</h2>
                    <?php if ($is_authorized && !$needs_re_auth): ?>
                        <span class="section-status completed">✅ Completed</span>
                    <?php elseif ($needs_re_auth): ?>
                        <span class="section-status warning">⚠️ Needs Re-authorization</span>
                    <?php elseif ($has_credentials): ?>
                        <span class="section-status current">🔄 Current</span>
                    <?php else: ?>
                        <span class="section-status pending">⏳ Pending</span>
                    <?php endif; ?>
                </div>
                
                <div class="section-content">
                    <?php if (!$has_credentials): ?>
                        <p class="section-locked">Complete Email Authentication first to unlock this section.</p>
                    <?php elseif ($needs_re_auth): ?>
                        <div class="re-authorization-needed">
                            <p><strong>⚠️ Re-authorization Required!</strong></p>
                            
                            <?php if ($token_info['expired']): ?>
                                <p>Your Gmail API access token has expired.</p>
                            <?php elseif ($token_info['stale']): ?>
                                <p>Your Gmail API access token will expire soon (<?php echo $token_info['expires_in'] ? gmdate('H:i:s', $token_info['expires_in']) : 'unknown'; ?> remaining).</p>
                            <?php endif; ?>
                            
                            <?php if ($token_info['has_refresh_token']): ?>
                                <p>You have a refresh token available. Click the button below to refresh your access.</p>
                                <button type="button" id="refresh-token-btn" class="button button-primary button-large">
                                    🔄 Refresh Access Token
                                </button>
                            <?php else: ?>
                                <p>No refresh token available. You need to re-authorize the application.</p>
                            <?php endif; ?>
                            
                            <div class="token-info-display">
                                <h4>Token Status:</h4>
                                <ul>
                                    <li><strong>Access Token:</strong> <?php echo $token_info['expired'] ? '❌ Expired' : '✅ Valid'; ?></li>
                                    <li><strong>Refresh Token:</strong> <?php echo $token_info['has_refresh_token'] ? '✅ Available' : '❌ Not Available'; ?></li>
                                    <li><strong>Expires In:</strong> <?php echo $token_info['expires_in'] ? gmdate('H:i:s', $token_info['expires_in']) : 'Unknown'; ?></li>
                                    <?php if (isset($token_info['error'])): ?>
                                        <li><strong>Error:</strong> <code><?php echo esc_html($token_info['error']); ?></code></li>
                                    <?php endif; ?>
                                </ul>
                            </div>
                            
                            <div class="re-authorization-actions">
                                <p><strong>Choose an action:</strong></p>
                                <div class="action-buttons">
                                    <button type="button" id="clear-tokens-btn" class="button button-secondary">
                                        🗑️ Clear All Tokens & Start Fresh
                                    </button>
                                    <button type="button" id="force-reauth-btn" class="button button-primary">
                                        🔐 Force Re-authorization
                                    </button>
                                </div>
                                <p class="action-note">Clearing tokens will remove all existing authorization and require a complete re-authorization process.</p>
                            </div>
                        </div>
                    <?php elseif (!$is_authorized): ?>
                        <p>Authorize this application to send emails through your Gmail account.</p>
                        
                        <div class="oauth-authorization">
                            <?php 
                            $auth_url = $gmail_api->get_authorization_url();
                            if ($auth_url): ?>
                                <a href="<?php echo esc_url($auth_url); ?>" class="button button-primary button-large">
                                    🔐 Authorize Gmail Access
                                </a>
                                <p class="auth-note">Click the button above to complete OAuth2 authorization with Google.</p>
                            <?php else: ?>
                                <div class="notice notice-error">
                                    <p><strong>Error:</strong> Unable to create authorization URL.</p>
                                </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="reset-option">
                            <p><strong>Need to start fresh?</strong></p>
                            <button type="button" id="clear-tokens-btn" class="button button-secondary">Clear Tokens & Start Fresh</button>
                            <p class="reset-note">This will clear any existing tokens and allow you to re-authorize.</p>
                        </div>
                    <?php else: ?>
                        <div class="authorization-success">
                            <p><strong>✅ Gmail API successfully authorized!</strong></p>
                            <p>Your application is now authorized to send emails through Gmail API.</p>
                            
                            <div class="token-status-display">
                                <h4>Current Token Status:</h4>
                                <ul>
                                    <li><strong>Access Token:</strong> ✅ Valid</li>
                                    <li><strong>Refresh Token:</strong> <?php echo $token_info['has_refresh_token'] ? '✅ Available' : '❌ Not Available'; ?></li>
                                    <li><strong>Expires In:</strong> <?php echo $token_info['expires_in'] ? gmdate('H:i:s', $token_info['expires_in']) : 'Unknown'; ?></li>
                                    <li><strong>Token Type:</strong> <?php echo esc_html($token_info['token_type']); ?></li>
                                </ul>
                            </div>
                            
                            <div class="maintenance-actions">
                                <p><strong>Token Maintenance:</strong></p>
                                <button type="button" id="clear-tokens-btn" class="button button-secondary">
                                    🔄 Refresh Authorization
                                </button>
                                <p class="maintenance-note">Use this if you experience any issues with email delivery.</p>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <!-- Section 3: Test Email -->
            <div class="gmail-section">
                <div class="section-header">
                    <h2>3. Test Email</h2>
                    <?php if ($is_authorized): ?>
                        <span class="section-status current">🔄 Ready to Test</span>
                    <?php else: ?>
                        <span class="section-status pending">⏳ Pending</span>
                    <?php endif; ?>
                </div>
                
                <div class="section-content">
                    <?php if (!$is_authorized): ?>
                        <p class="section-locked">Complete Email Authorization first to unlock this section.</p>
                    <?php else: ?>
                        <p>Test your Gmail API configuration by sending a test email.</p>
                        
                        <div class="test-connection-section">
                            <div class="test-email-input">
                                <label for="test-email-address">Test Email Address:</label>
                                <input type="email" id="test-email-address" 
                                       value="<?php echo esc_attr($this->get_settings()['to_email'] ?? get_option('admin_email')); ?>" 
                                       placeholder="Enter email address to test with"
                                       class="regular-text">
                                <p class="description">Enter the email address where you want to receive the test email.</p>
                            </div>
                            
                            <button type="button" id="test-gmail-btn" class="button button-primary button-large">
                                📧 Send Test Email
                            </button>
                            <div id="gmail-test-result" style="margin-top: 10px;"></div>
                        </div>
                        
                        <div class="test-email-info">
                            <p><strong>Test Email Details:</strong></p>
                            <ul>
                                <li>From: <?php echo esc_html($this->get_settings()['from_name']); ?> &lt;<?php echo esc_html($this->get_settings()['from_email']); ?>&gt;</li>
                                <li>To: Your admin email address</li>
                                <li>Subject: Gmail API Test Email</li>
                                <li>Content: Confirmation that Gmail API is working correctly</li>
                            </ul>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
            
            <!-- OAuth Callback Handler -->
            <?php 
            // OAuth callback is now handled by the main plugin
            // No need to call handle_oauth_callback() here
            ?>
            
        </div>
        
        <style>
        .gmail-section {
            background: #f8f9fa;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            margin: 20px 0;
            overflow: hidden;
        }
        
        .section-header {
            background: #fff;
            padding: 20px;
            border-bottom: 2px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .section-header h2 {
            margin: 0;
            color: #495057;
            font-size: 1.4em;
        }
        
        .section-status {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 14px;
        }
        
        .section-status.completed {
            background: #d4edda;
            color: #155724;
            border: 2px solid #28a745;
        }
        
        .section-status.current {
            background: #e7f3ff;
            color: #007cba;
            border: 2px solid #007cba;
        }
        
        .section-status.pending {
            background: #f8f9fa;
            color: #6c757d;
            border: 2px solid #6c757d;
        }
        
        .section-status.warning {
            background: #fff3cd;
            color: #856404;
            border: 2px solid #ffc107;
        }
        
        .section-status.error {
            background: #f8d7da;
            color: #721c24;
            border: 2px solid #dc3545;
        }
        
        .section-content {
            padding: 20px;
        }
        
        /* Library Error Styles */
        .library-error {
            border-color: #dc3545;
            background: #f8d7da;
        }
        
        .library-error-message {
            background: white;
            padding: 20px;
            border-radius: 5px;
            border: 1px solid #dc3545;
        }
        
        .library-error-message ol,
        .library-error-message ul {
            margin: 15px 0;
            padding-left: 20px;
        }
        
        .library-error-message li {
            margin: 8px 0;
        }
        
        .library-error-message code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 3px;
            border: 1px solid #dee2e6;
        }
        
        /* Re-authorization Styles */
        .re-authorization-needed {
            background: #fff3cd;
            padding: 20px;
            border-radius: 5px;
            border: 1px solid #ffc107;
            margin: 20px 0;
        }
        
        .token-info-display {
            background: white;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #dee2e6;
        }
        
        .token-info-display h4 {
            margin-top: 0;
            color: #495057;
        }
        
        .token-info-display ul {
            margin: 15px 0;
            padding-left: 20px;
        }
        
        .token-info-display li {
            margin: 8px 0;
        }
        
        .re-authorization-actions {
            background: #e7f3ff;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #bee5eb;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            margin: 15px 0;
            flex-wrap: wrap;
        }
        
        .action-note {
            margin-top: 15px;
            color: #0c5460;
            font-size: 14px;
            font-style: italic;
        }
        
        /* Token Status Display */
        .token-status-display {
            background: #d4edda;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #c3e6cb;
        }
        
        .token-status-display h4 {
            margin-top: 0;
            color: #155724;
        }
        
        .token-status-display ul {
            margin: 15px 0;
            padding-left: 20px;
        }
        
        .token-status-display li {
            margin: 8px 0;
        }
        
        .maintenance-actions {
            background: #e7f3ff;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #bee5eb;
            text-align: center;
        }
        
        .maintenance-note {
            margin-top: 15px;
            color: #0c5460;
            font-size: 14px;
            font-style: italic;
        }
        
        .oauth-config-info {
            background: #fff3cd;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #ffeaa7;
        }
        
        .oauth-config-info ol {
            margin: 15px 0;
            padding-left: 20px;
        }
        
        .oauth-config-info li {
            margin: 8px 0;
        }
        
        .redirect-uri-display {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 15px 0;
            background: white;
            padding: 15px;
            border-radius: 4px;
            border: 1px solid #dee2e6;
        }
        
        .redirect-uri-display code {
            flex: 1;
            padding: 10px;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .credentials-display {
            background: #d4edda;
            padding: 20px;
            border-radius: 5px;
            border: 1px solid #c3e6cb;
        }
        
        .credentials-display code {
            background: #c3e6cb;
            padding: 2px 6px;
            border-radius: 3px;
        }
        
        .oauth-authorization {
            background: #d1ecf1;
            padding: 30px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: center;
            border: 1px solid #bee5eb;
        }
        
        .auth-note {
            margin-top: 15px;
            color: #0c5460;
            font-size: 14px;
        }
        
        .reset-option {
            background: #fff3cd;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #ffeaa7;
            text-align: center;
        }
        
        .reset-note {
            margin-top: 10px;
            color: #856404;
            font-size: 14px;
        }
        
        .authorization-success {
            background: #d4edda;
            padding: 20px;
            border-radius: 5px;
            border: 1px solid #c3e6cb;
            text-align: center;
        }
        
        .test-connection-section {
            background: #e7f3ff;
            padding: 30px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: center;
            border: 1px solid #bee5eb;
        }
        
        .test-email-input {
            margin-bottom: 20px;
            text-align: left;
        }

        .test-email-input label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }

        .test-email-input input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
        }

        .test-email-input .description {
            margin-top: 5px;
            font-size: 13px;
            color: #666;
        }
        
        .test-email-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #dee2e6;
        }
        
        .test-email-info ul {
            margin: 15px 0;
            padding-left: 20px;
        }
        
        .test-email-info li {
            margin: 8px 0;
        }
        
        .button-large {
            font-size: 16px;
            padding: 12px 24px;
            height: auto;
        }

        /* Collapsible Section Styles */
        .collapsible-content {
            display: none !important; /* Force hidden initially */
            overflow: hidden;
        }
        
        .collapsible-content.expanded {
            display: block !important;
        }
        
        /* Ensure the toggle button is always visible */
        .section-toggle {
            display: flex !important;
            background: #e7f3ff;
            color: #007cba;
            border: 1px solid #007cba;
            border-radius: 5px;
            padding: 8px 12px;
            font-size: 14px;
            cursor: pointer;
            align-items: center;
            gap: 5px;
            margin-top: 10px;
            transition: all 0.3s ease;
        }
        
        .section-toggle:hover {
            background: #d1ecf1;
            border-color: #005a8b;
        }
        
        .section-toggle .toggle-icon {
            font-size: 16px;
            transition: transform 0.3s ease;
        }
        
        .section-toggle .toggle-text {
            font-weight: bold;
        }
        
        /* Credentials Actions */
        .credentials-actions {
            background: #e7f3ff;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #bee5eb;
            text-align: center;
        }
        
        .edit-note {
            margin-top: 15px;
            color: #0c5460;
            font-size: 14px;
            font-style: italic;
        }
        
        /* Edit Credentials Form */
        #edit-credentials-form {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #dee2e6;
            display: none; /* Hidden by default */
        }
        
        #edit-credentials-form.show {
            display: block !important;
        }
        
        #edit-credentials-form h4 {
            margin-top: 0;
            color: #495057;
            border-bottom: 2px solid #dee2e6;
            padding-bottom: 10px;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            justify-content: flex-start;
        }
        
        /* Ensure form fields are visible */
        #edit-credentials-form input[type="text"],
        #edit-credentials-form input[type="email"],
        #edit-credentials-form input[type="password"] {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        #edit-credentials-form label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        
        #edit-credentials-form .form-table {
            width: 100%;
            margin-bottom: 20px;
        }
        
        #edit-credentials-form .form-table th {
            width: 200px;
            text-align: left;
            padding: 10px 0;
            vertical-align: top;
        }
        
        #edit-credentials-form .form-table td {
            padding: 10px 0;
        }
        
        /* Section Header Layout */
        .section-header {
            background: #fff;
            padding: 20px;
            border-bottom: 2px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
        }
        
        .section-header h2 {
            margin: 0;
            color: #495057;
            font-size: 1.4em;
            flex: 1;
        }
        
        .section-header .section-status {
            margin-left: 15px;
        }
        
        .section-header .section-toggle {
            margin-left: auto;
            margin-top: 0;
        }
        </style>
        <?php
    }
    
    /**
     * Get status display message
     */
    private function get_status_display($status) {
        switch ($status) {
            case 'ready':
                return '✅ Gmail API is ready and configured!';
            case 'credentials_saved':
                return '🔄 Credentials saved. Please complete OAuth2 authorization.';
            case 'token_expired':
                return '⚠️ Access token expired. Please re-authorize.';
            case 'token_expired_no_refresh':
                return '⚠️ Access token expired and no refresh token available. Please re-authorize.';
            case 'not_configured':
                return '❌ Gmail API not configured. Please complete setup below.';
            default:
                return '❓ Unknown status: ' . $status;
        }
    }
    
    /**
     * Get current settings
     */
    private function get_settings() {
        return get_option('contact_us_gmail_settings', array());
    }
    
    /**
     * Check if credentials are entered
     */
    private function has_credentials() {
        $settings = $this->get_settings();
        return !empty($settings['client_id']) && !empty($settings['client_secret']);
    }
    
    /**
     * Render Gmail section
     */
    public function render_gmail_section() {
        echo '<p>Configure Gmail API for reliable email delivery. This replaces traditional SMTP with Google\'s infrastructure.</p>';
    }
    
    /**
     * Render checkbox field
     */
    public function render_checkbox_field($args) {
        $settings = get_option('contact_us_gmail_settings', array());
        $field = $args['field'];
        $label = $args['label'];
        $checked = isset($settings[$field]) && $settings[$field] ? 'checked' : '';
        
        echo '<label><input type="checkbox" name="contact_us_gmail_settings[' . $field . ']" value="1" ' . $checked . '> ' . $label . '</label>';
    }
    
    /**
     * Render text field
     */
    public function render_text_field($args) {
        $settings = get_option('contact_us_gmail_settings', array());
        $field = $args['field'];
        $placeholder = isset($args['placeholder']) ? $args['placeholder'] : '';
        $value = isset($settings[$field]) ? $settings[$field] : '';
        
        // Provide default value for to_email field
        if ($field === 'to_email' && empty($value)) {
            $value = get_option('admin_email');
        }
        
        echo '<input type="text" name="contact_us_gmail_settings[' . $field . ']" value="' . esc_attr($value) . '" placeholder="' . esc_attr($placeholder) . '" class="regular-text">';
    }
    
    /**
     * Sanitize Gmail settings
     */
    public function sanitize_gmail_settings($input) {
        $sanitized = array();
        
        // Sanitize credentials
        $sanitized['client_id'] = sanitize_text_field($input['client_id'] ?? '');
        $sanitized['client_secret'] = sanitize_text_field($input['client_secret'] ?? '');
        $sanitized['from_email'] = sanitize_email($input['from_email'] ?? '');
        $sanitized['from_name'] = sanitize_text_field($input['from_name'] ?? '');
        $sanitized['to_email'] = sanitize_email($input['to_email'] ?? '');
        
        // Preserve existing tokens
        $existing_settings = $this->get_settings();
        if (isset($existing_settings['access_token'])) {
            $sanitized['access_token'] = $existing_settings['access_token'];
        }
        if (isset($existing_settings['refresh_token'])) {
            $sanitized['refresh_token'] = $existing_settings['refresh_token'];
        }
        if (isset($existing_settings['token_expiry'])) {
            $sanitized['token_expiry'] = $existing_settings['token_expiry'];
        }
        
        return $sanitized;
    }
    
    /**
     * Test Gmail connection via AJAX
     */
    public function test_gmail_connection() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['nonce'], 'gmail_admin_nonce')) {
            wp_die('Security check failed');
        }
        
        // Check permissions
        if (!current_user_can('manage_options')) {
            wp_die('Insufficient permissions');
        }
        
        // Get test email address from request
        $test_email = sanitize_email($_POST['test_email'] ?? '');
        
        if (empty($test_email)) {
            wp_send_json_error(array('message' => 'No test email address provided.'));
        }
        
        $gmail_api = new ContactUsGmailAPI();
        $result = $gmail_api->test_connection($test_email);
        
        wp_send_json($result);
    }
    
    /**
     * Clear Gmail tokens via AJAX
     */
    public function clear_gmail_tokens() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['nonce'], 'gmail_admin_nonce')) {
            wp_die('Security check failed');
        }
        
        // Check permissions
        if (!current_user_can('manage_options')) {
            wp_die('Insufficient permissions');
        }
        
        $gmail_api = new ContactUsGmailAPI();
        $success = $gmail_api->clear_tokens_and_reset();
        
        if ($success) {
            wp_send_json_success('Tokens cleared successfully. You can now re-authorize.');
        } else {
            wp_send_json_error('Failed to clear tokens.');
        }
    }
    
    /**
     * Refresh Gmail token via AJAX
     */
    public function refresh_gmail_token() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['nonce'], 'gmail_admin_nonce')) {
            wp_die('Security check failed');
        }
        
        // Check permissions
        if (!current_user_can('manage_options')) {
            wp_die('Insufficient permissions');
        }
        
        $gmail_api = new ContactUsGmailAPI();
        $success = $gmail_api->refresh_access_token_public();
        
        if ($success) {
            wp_send_json_success('Access token refreshed successfully.');
        } else {
            wp_send_json_error('Failed to refresh access token.');
        }
    }
}
