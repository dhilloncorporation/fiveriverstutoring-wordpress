<?php
/**
 * Gmail API Service for Contact Us Plugin
 * Handles email delivery through Google's Gmail API
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

class ContactUsGmailAPI {
    
    private $client;
    private $service;
    private $settings;
    
    public function __construct() {
        $this->settings = get_option('contact_us_gmail_settings', array());
        
        // Always try to load Google Client immediately when class is instantiated
        if (!class_exists('Google_Client')) {
            $this->load_google_client();
        }
        
        add_action('init', array($this, 'init_gmail_client'));
    }
    
    /**
     * Initialize Gmail API client
     */
    public function init_gmail_client() {
        // Only initialize if Gmail API is enabled
        if (empty($this->settings) || !isset($this->settings['enabled']) || !$this->settings['enabled']) {
            return;
        }
        
        // Check if Google Client library is available
        if (!class_exists('Google_Client')) {
            $this->load_google_client();
        }
        
        try {
            $this->setup_gmail_client();
        } catch (Exception $e) {
            error_log('Gmail API Client Error: ' . $e->getMessage());
        }
    }
    
    /**
     * Load Google Client library
     */
    private function load_google_client() {
        // Try to load from WordPress directory Composer (most likely location)
        $composer_autoload = ABSPATH . 'vendor/autoload.php';
        if (file_exists($composer_autoload)) {
            require_once $composer_autoload;
            return;
        }
        
        // Try to load from project root Composer if available
        $composer_autoload = ABSPATH . '../../vendor/autoload.php';
        if (file_exists($composer_autoload)) {
            require_once $composer_autoload;
            return;
        }
        
        // Try to load from plugin directory
        $google_client_path = plugin_dir_path(__FILE__) . '../vendor/google/apiclient/src/Google/Client.php';
        if (file_exists($google_client_path)) {
            require_once $google_client_path;
            return;
        }
        
        // If Google Client is not available, log error and disable Gmail API
        error_log('[Gmail API] Google Client library not available. Gmail API will be disabled.');
        error_log('[Gmail API] Checked paths: ' . ABSPATH . 'vendor/autoload.php, ' . ABSPATH . '../../vendor/autoload.php, ' . $google_client_path);
        $this->settings['enabled'] = 0;
        update_option('contact_us_gmail_settings', $this->settings);
        
        throw new Exception('Google Client library not available. Please install it via Composer or contact your administrator.');
    }
    
    /**
     * Setup Gmail API client
     */
    private function setup_gmail_client() {
        if (!class_exists('Google_Client')) {
            return false;
        }
        
        try {
            $this->client = new Google_Client();
            
            // Set application name
            $this->client->setApplicationName('Five Rivers Tutoring Contact Form');
            
            // Set scopes
            $this->client->setScopes(Google_Service_Gmail::GMAIL_SEND);
            
            // Set auth config
            $this->client->setAuthConfig(array(
                'client_id' => $this->settings['client_id'],
                'client_secret' => $this->settings['client_secret']
            ));
            
            // Set access type and prompt
            $this->client->setAccessType('offline');
            $this->client->setPrompt('consent');
            
            // Set access token if available
            if (!empty($this->settings['access_token'])) {
                $this->client->setAccessToken($this->settings['access_token']);
                
                // Check if token is expired and refresh if possible
                if ($this->client->isAccessTokenExpired()) {
                    if (!empty($this->settings['refresh_token'])) {
                        $this->client->refreshToken($this->settings['refresh_token']);
                        $this->update_tokens_from_client();
                    } else {
                        // Token expired and no refresh token available - clear token
                        $this->clear_tokens_and_reset();
                        return false;
                    }
                }
            }
            
            // Create Gmail service
            $this->service = new Google_Service_Gmail($this->client);
            return true;
            
        } catch (Exception $e) {
            return false;
        }
    }
    
    /**
     * Update tokens from client
     */
    private function update_tokens_from_client() {
        if (!$this->client) {
            return false;
        }
        
        try {
            $token_info = $this->client->getAccessToken();
            
            if (isset($token_info['access_token'])) {
                $this->settings['access_token'] = $token_info['access_token'];
                
                if (isset($token_info['refresh_token'])) {
                    $this->settings['refresh_token'] = $token_info['refresh_token'];
                }
                
                update_option('contact_us_gmail_settings', $this->settings);
                return true;
            }
            
            return false;
        } catch (Exception $e) {
            error_log('Failed to update tokens from client: ' . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Get OAuth credentials from settings
     */
    private function get_oauth_credentials() {
        return array(
            'client_id' => $this->settings['client_id'] ?? '',
            'client_secret' => $this->settings['client_secret'] ?? '',
            'redirect_uri' => home_url('/?contact_us_oauth=callback'),
            'auth_uri' => 'https://accounts.google.com/o/oauth2/auth',
            'token_uri' => 'https://oauth2.googleapis.com/token',
            'auth_provider_x509_cert_url' => 'https://www.googleapis.com/oauth2/v1/certs'
        );
    }
    
    /**
     * Refresh access token
     */
    private function refresh_access_token() {
        if (empty($this->settings['refresh_token'])) {
            return false;
        }
        
        try {
            $this->client->refreshToken($this->settings['refresh_token']);
            $this->update_tokens_from_client();
            return true;
        } catch (Exception $e) {
            error_log('Failed to refresh access token: ' . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Refresh access token via public method
     */
    public function refresh_access_token_public() {
        if (empty($this->settings['refresh_token'])) {
            return false;
        }
        
        try {
            if (!$this->client) {
                if (!$this->setup_gmail_client()) {
                    return false;
                }
            }
            
            $this->client->refreshToken($this->settings['refresh_token']);
            $this->update_tokens_from_client();
            return true;
        } catch (Exception $e) {
            error_log('Failed to refresh access token via public method: ' . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send email via Gmail API
     */
    public function send_email($to, $subject, $message, $headers = array()) {
        // Ensure Gmail service is initialized
        if (!$this->service) {
            if (!$this->setup_gmail_client()) {
                error_log('[Gmail API] Failed to setup Gmail client for sending email');
                return false;
            }
        }
        
        if (!$this->service) {
            error_log('[Gmail API] Gmail service not available after setup');
            return false;
        }
        
        try {
            // Create email message
            $email = $this->create_email_message($to, $subject, $message, $headers);
            
            // Encode message
            $encoded_message = base64_encode($email);
            $encoded_message = str_replace(['+', '/', '='], ['-', '_', ''], $encoded_message);
            
            // Create Gmail message object
            $gmail_message = new Google_Service_Gmail_Message();
            $gmail_message->setRaw($encoded_message);
            
            // Send email
            $sent_message = $this->service->users_messages->send('me', $gmail_message);
            
            error_log('[Gmail API] Email sent successfully with ID: ' . $sent_message->getId());
            return !empty($sent_message->getId());
            
        } catch (Exception $e) {
            error_log('[Gmail API] Send email error: ' . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Create email message in RFC 2822 format
     */
    private function create_email_message($to, $subject, $message, $headers = array()) {
        $from_email = $this->settings['from_email'] ?? get_option('admin_email');
        $from_name = $this->settings['from_name'] ?? 'Five Rivers Tutoring';
        
        $email_headers = array(
            'From: ' . $from_name . ' <' . $from_email . '>',
            'To: ' . $to,
            'Subject: ' . $subject,
            'MIME-Version: 1.0',
            'Content-Type: text/plain; charset=UTF-8',
            'Content-Transfer-Encoding: 7bit'
        );
        
        // Add custom headers
        foreach ($headers as $header) {
            if (strpos($header, 'From:') === false && strpos($header, 'To:') === false && strpos($header, 'Subject:') === false) {
                $email_headers[] = $header;
            }
        }
        
        $email_content = implode("\r\n", $email_headers) . "\r\n\r\n" . $message;
        
        return $email_content;
    }
    
    /**
     * Test Gmail API connection
     */
    public function test_connection($custom_test_email = null) {
        try {
            // Ensure Gmail service is initialized
            if (!$this->service) {
                if (!$this->setup_gmail_client()) {
                    return array('success' => false, 'message' => 'Gmail API service not initialized');
                }
            }
            
            if (!$this->service) {
                return array('success' => false, 'message' => 'Gmail API service not initialized');
            }
            
            // Get the email address to send to (use custom email if provided, otherwise fallback to configured email)
            $test_email = $custom_test_email ?: ($this->settings['from_email'] ?? get_option('admin_email'));
            
            // Try to send a test email
            $test_result = $this->send_email(
                $test_email,
                'Test Email from WordPress Contact Us Plugin',
                'This is a test email sent from your WordPress Contact Us plugin using the Gmail API. If you received this, your configuration is working!',
                array('Content-Type: text/plain; charset=UTF-8')
            );
            
            if ($test_result) {
                return array('success' => true, 'message' => 'Gmail API connection successful! Test email sent to ' . $test_email . '.');
            } else {
                return array('success' => false, 'message' => 'Failed to send test email.');
            }
        } catch (Exception $e) {
            error_log('Gmail API test connection error: ' . $e->getMessage());
            return array('success' => false, 'message' => 'Gmail API Error: ' . $e->getMessage());
        }
    }
    
    /**
     * Get authorization URL for OAuth2
     */
    public function get_authorization_url() {
        try {
            // Check if we have the required credentials
            if (empty($this->settings['client_id']) || empty($this->settings['client_secret'])) {
                error_log('[Gmail API Debug] Missing client_id or client_secret');
                throw new Exception('Client ID and Client Secret are required');
            }
            
            if (!$this->client) {
                error_log('[Gmail API Debug] Client not initialized, calling setup_gmail_client()');
                $this->setup_gmail_client();
            }
            
            if (!$this->client) {
                error_log('[Gmail API Debug] Client still not available after setup');
                throw new Exception('Failed to initialize Gmail API client');
            }
            
            // Set our custom redirect URI
            $redirect_uri = home_url('/?contact_us_oauth=callback');
            $this->client->setRedirectUri($redirect_uri);
            
            $auth_url = $this->client->createAuthUrl();
            return $auth_url;
        } catch (Exception $e) {
            error_log('[Gmail API] Error creating authorization URL: ' . $e->getMessage());
            error_log('[Gmail API Debug] Exception details: ' . $e->getTraceAsString());
            return false;
        }
    }
    
    /**
     * Handle OAuth callback
     */
    public function handle_oauth_callback($code) {
        try {
            // Ensure client is initialized
            if (!$this->client) {
                if (!$this->setup_gmail_client()) {
                    return false;
                }
            }
            
            if (!$this->client) {
                return false;
            }
            
            // CRITICAL: Set the redirect URI again before exchanging the code
            $redirect_uri = home_url('/?contact_us_oauth=callback');
            $this->client->setRedirectUri($redirect_uri);
            
            $token = $this->client->fetchAccessTokenWithAuthCode($code);
            
            if (isset($token['access_token'])) {
                $this->settings['access_token'] = $token['access_token'];
                
                if (isset($token['refresh_token']) && !empty($token['refresh_token'])) {
                    $this->settings['refresh_token'] = $token['refresh_token'];
                }
                
                update_option('contact_us_gmail_settings', $this->settings);
                return true;
            }
            
            if (isset($token['error'])) {
                error_log('Google OAuth error: ' . $token['error']);
                if (isset($token['error_description'])) {
                    error_log('Error description: ' . $token['error_description']);
                }
                return false;
            }
            
            return false;
            
        } catch (Exception $e) {
            error_log('OAuth callback error: ' . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Check if Gmail API is properly configured
     */
    public function is_configured() {
        return !empty($this->settings['enabled']) && 
               !empty($this->settings['client_id']) && 
               !empty($this->settings['client_secret']) &&
               !empty($this->settings['access_token']);
    }
    
    /**
     * Get Gmail API status
     */
    public function get_status() {
        // First check if Google Client library is available
        if (!class_exists('Google_Client')) {
            return 'library_missing';
        }
        
        // Check if we have basic credentials
        if (empty($this->settings['client_id']) || empty($this->settings['client_secret'])) {
            return 'not_configured';
        }
        
        // Check if we have access token
        if (empty($this->settings['access_token'])) {
            return 'credentials_saved'; // New status for when credentials are saved but not authorized
        }
        
        // Check if client is initialized and token is expired
        if ($this->client) {
            $is_expired = $this->client->isAccessTokenExpired();
            
            if ($is_expired) {
                if (!empty($this->settings['refresh_token'])) {
                    return 'token_expired';
                } else {
                    return 'token_expired_no_refresh';
                }
            }
        } else {
            // Try to initialize client to check token status
            try {
                $this->setup_gmail_client();
                if ($this->client && $this->client->isAccessTokenExpired()) {
                    if (!empty($this->settings['refresh_token'])) {
                        return 'token_expired';
                    } else {
                        return 'token_expired_no_refresh';
                    }
                }
            } catch (Exception $e) {
                return 'client_error';
            }
        }
        
        return 'ready';
    }
    
    /**
     * Check if Google Client library is available
     */
    public function is_library_available() {
        return class_exists('Google_Client');
    }
    
    /**
     * Check if tokens are stale (expired or about to expire)
     */
    public function are_tokens_stale() {
        if (empty($this->settings['access_token'])) {
            return false; // No tokens to check
        }
        
        if (!$this->client) {
            try {
                $this->setup_gmail_client();
            } catch (Exception $e) {
                return true; // Consider stale if we can't check
            }
        }
        
        if (!$this->client) {
            return true; // Consider stale if client is not available
        }
        
        // Check if token is expired
        if ($this->client->isAccessTokenExpired()) {
            return true;
        }
        
        // Check if token expires within the next hour (3600 seconds)
        $token_info = $this->client->getAccessToken();
        if (isset($token_info['expires_in'])) {
            $expires_in = $token_info['expires_in'];
            if ($expires_in < 3600) { // Less than 1 hour remaining
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Get detailed token information
     */
    public function get_token_info() {
        if (empty($this->settings['access_token'])) {
            return array(
                'has_tokens' => false,
                'expired' => false,
                'stale' => false,
                'expires_in' => null,
                'has_refresh_token' => !empty($this->settings['refresh_token'])
            );
        }
        
        if (!$this->client) {
            try {
                $this->setup_gmail_client();
            } catch (Exception $e) {
                return array(
                    'has_tokens' => true,
                    'expired' => true,
                    'stale' => true,
                    'expires_in' => null,
                    'has_refresh_token' => !empty($this->settings['refresh_token']),
                    'error' => $e->getMessage()
                );
            }
        }
        
        if (!$this->client) {
            return array(
                'has_tokens' => true,
                'expired' => true,
                'stale' => true,
                'expires_in' => null,
                'has_refresh_token' => !empty($this->settings['refresh_token'])
            );
        }
        
        $token_info = $this->client->getAccessToken();
        $is_expired = $this->client->isAccessTokenExpired();
        $expires_in = isset($token_info['expires_in']) ? $token_info['expires_in'] : null;
        $is_stale = $expires_in !== null && $expires_in < 3600; // Less than 1 hour remaining
        
        return array(
            'has_tokens' => true,
            'expired' => $is_expired,
            'stale' => $is_stale,
            'expires_in' => $expires_in,
            'has_refresh_token' => !empty($this->settings['refresh_token']),
            'token_type' => $token_info['token_type'] ?? 'unknown'
        );
    }
    
    /**
     * Clear all tokens and reset configuration
     */
    public function clear_tokens_and_reset() {
        // Clear tokens but keep credentials
        $this->settings['access_token'] = '';
        $this->settings['refresh_token'] = '';
        
        // Reset client
        $this->client = null;
        $this->service = null;
        
        // Update settings
        update_option('contact_us_gmail_settings', $this->settings);
        
        return true;
    }
    
    /**
     * Check if authentication is complete (has valid tokens)
     */
    public function is_authenticated() {
        if (empty($this->settings['access_token'])) {
            return false;
        }
        
        // If client is not initialized, try to initialize it
        if (!$this->client) {
            try {
                $this->setup_gmail_client();
            } catch (Exception $e) {
                return false;
            }
        }
        
        // Check if client is available and token is not expired
        if ($this->client) {
            $is_expired = $this->client->isAccessTokenExpired();
            return !$is_expired;
        } else {
            return false;
        }
    }
    
    /**
     * Check if authorization is complete (has valid tokens)
     */
    public function is_authorized() {
        return $this->is_authenticated();
    }
}

// Initialize Gmail API service - now handled in main plugin
// new ContactUsGmailAPI();
