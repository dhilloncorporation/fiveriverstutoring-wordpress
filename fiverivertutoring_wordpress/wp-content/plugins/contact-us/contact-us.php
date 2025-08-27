<?php
/**
 * Plugin Name: Contact Us - Five Rivers Tutoring
 * Plugin URI: https://fiveriverstutoring.com
 * Description: Custom contact form plugin for Five Rivers Tutoring with email functionality
 * Version: 1.0.0
 * Author: Five Rivers Tutoring
 * License: GPL v2 or later
 * Text Domain: contact-us
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Include required files
require_once plugin_dir_path(__FILE__) . 'includes/gmail-api-service.php';
require_once plugin_dir_path(__FILE__) . 'includes/gmail-admin-settings.php';

// Initialize Gmail services after main plugin
add_action('plugins_loaded', function() {
    new ContactUsGmailAPI();
    new ContactUsGmailAdminSettings();
}, 20);

class ContactUsPlugin {
    
    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
        add_action('wp_ajax_contact_us_submit', array($this, 'handle_form_submission'));
        add_action('wp_ajax_nopriv_contact_us_submit', array($this, 'handle_form_submission'));
        add_shortcode('contact_us_form', array($this, 'render_contact_form'));
        add_action('admin_menu', array($this, 'add_admin_menu'), 10);
        
        // Add OAuth callback handler
        add_action('init', array($this, 'handle_oauth_callback'), 1); // Run early
        
        // Add admin page logging
        add_action('admin_init', array($this, 'log_admin_actions'));
        
        // Debug: Log plugin initialization
        error_log('[Contact Us Plugin] Plugin initialized');
        
        // Add a simple test action that fires on every page load
        add_action('wp_head', array($this, 'debug_test'));
        add_action('admin_head', array($this, 'debug_test'));
        
    }
    
    public function init() {
        // Initialize plugin
    }
    
    public function enqueue_scripts() {
        wp_enqueue_script('contact-us-js', plugin_dir_url(__FILE__) . 'assets/js/contact-us.js', array('jquery'), '1.0.3', true);
        wp_enqueue_style('contact-us-css', plugin_dir_url(__FILE__) . 'assets/css/contact-us.css', array(), '1.0.3');
        
        // Debug: Log CSS file path
        error_log('[Contact Us Plugin] CSS file path: ' . plugin_dir_url(__FILE__) . 'assets/css/contact-us.css');
        
        // Localize script for AJAX
        wp_localize_script('contact-us-js', 'contact_us_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('contact_us_submit'),
            'home_url' => home_url('/')
        ));
        
        // Add a test action for debugging
        add_action('wp_footer', array($this, 'add_debug_info'));
    }
    
    public function add_debug_info() {
        if (current_user_can('manage_options')) {
            echo '<!-- Contact Us Plugin Debug: Plugin is loaded and scripts enqueued -->';
            echo '<!-- Contact Us Plugin Debug: AJAX URL: ' . admin_url('admin-ajax.php') . ' -->';
            echo '<!-- Contact Us Plugin Debug: Nonce: ' . wp_create_nonce('contact_us_submit') . ' -->';
        }
    }
    
    public function render_contact_form($atts) {
        $atts = shortcode_atts(array(
            'title' => 'Contact Us',
            'show_phone' => 'true',
            'show_subject' => 'true',
            'hide_title' => 'false',
            'theme_inherit' => 'true'
        ), $atts);
        
        // Smart title detection - avoid duplication with page headings
        $smart_title = $this->get_smart_form_title($atts['title'], $atts['hide_title']);
        
        // Theme inheritance class
        $theme_class = ($atts['theme_inherit'] === 'true') ? 'theme-inherit' : 'no-theme-inherit';
        
        ob_start();
        ?>
        <div class="contact-us-form-container<?php echo $smart_title ? '' : ' no-title'; ?> <?php echo esc_attr($theme_class); ?>">
            <?php if ($smart_title): ?>
            <h3><?php echo esc_html($smart_title); ?></h3>
            <?php endif; ?>
            
            <form id="contact-us-form" class="contact-us-form">
                <?php wp_nonce_field('contact_us_submit', 'contact_us_nonce'); ?>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="contact_name">Full Name *</label>
                        <input type="text" id="contact_name" name="name" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="contact_email">Email Address *</label>
                        <input type="email" id="contact_email" name="email" required>
                    </div>
                </div>
                
                <?php if ($atts['show_phone'] === 'true'): ?>
                <div class="form-group">
                    <label for="contact_phone">Phone Number</label>
                    <input type="tel" id="contact_phone" name="phone">
                </div>
                <?php endif; ?>
                
                <?php if ($atts['show_subject'] === 'true'): ?>
                <div class="form-group">
                    <label for="contact_subject">Subject *</label>
                    <input type="text" id="contact_subject" name="subject" required>
                </div>
                <?php endif; ?>
                
                <div class="form-group">
                    <label for="contact_message">Message *</label>
                    <textarea id="contact_message" name="message" rows="5" required></textarea>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="contact-submit-btn">Send Message</button>
                </div>
            </form>
            
            <!-- Response container moved outside the form -->
            <div id="contact-form-response" class="contact-form-response" style="display: none;"></div>
        </div>
        <?php
        return ob_get_clean();
    }
    
    /**
     * Smart title detection to avoid duplication
     */
    private function get_smart_form_title($requested_title, $hide_title) {
        // If hide_title is true, return empty string
        if ($hide_title === 'true') {
            return '';
        }
        
        // If user specifically requested a custom title, use it
        if ($requested_title !== 'Contact Us') {
            return $requested_title;
        }
        
        // Check if we're on a page that likely has "Contact Us" as main heading
        global $post;
        if ($post && $post->post_title) {
            $post_title = strtolower($post->post_title);
            $contact_variations = ['contact', 'contact us', 'get in touch', 'reach us'];
            
            foreach ($contact_variations as $variation) {
                if (strpos($post_title, $variation) !== false) {
                    // Page title contains contact-related words, hide form title to avoid duplication
                    return '';
                }
            }
        }
        
        // Check if we're in a contact-related context
        if (is_page() && (strpos(strtolower(get_the_title()), 'contact') !== false)) {
            return '';
        }
        
        // Default fallback - only show if not in contact context
        return 'Contact Us';
    }
    
    /**
     * Handle form submission
     */
    public function handle_form_submission() {
        // Debug: Log the start of form submission
        error_log('[Contact Us] Form submission started');
        error_log('[Contact Us] POST data: ' . print_r($_POST, true));
        
        // Verify nonce
        if (!wp_verify_nonce($_POST['contact_us_nonce'], 'contact_us_submit')) {
            error_log('[Contact Us] Nonce verification failed');
            wp_send_json_error('Security check failed');
        }
        
        error_log('[Contact Us] Nonce verification passed');
        
        // Get form data
        $name = sanitize_text_field($_POST['name'] ?? '');
        $email = sanitize_email($_POST['email'] ?? '');
        $phone = sanitize_text_field($_POST['phone'] ?? '');
        $subject = sanitize_text_field($_POST['subject'] ?? '');
        $message = sanitize_textarea_field($_POST['message'] ?? '');
        
        error_log('[Contact Us] Form data sanitized:');
        error_log('[Contact Us] - Name: ' . $name);
        error_log('[Contact Us] - Email: ' . $email);
        error_log('[Contact Us] - Phone: ' . $phone);
        error_log('[Contact Us] - Subject: ' . $subject);
        error_log('[Contact Us] - Message: ' . $message);
        
        // Validate required fields
        if (empty($name) || empty($email) || empty($subject) || empty($message)) {
            error_log('[Contact Us] Required field validation failed');
            error_log('[Contact Us] - Name empty: ' . (empty($name) ? 'yes' : 'no'));
            error_log('[Contact Us] - Email empty: ' . (empty($email) ? 'yes' : 'no'));
            error_log('[Contact Us] - Subject empty: ' . (empty($subject) ? 'yes' : 'no'));
            error_log('[Contact Us] - Message empty: ' . (empty($message) ? 'yes' : 'no'));
            wp_send_json_error('Please fill in all required fields');
        }
        
        error_log('[Contact Us] Required field validation passed');
        
        // Get Gmail API settings
        $gmail_settings = get_option('contact_us_gmail_settings', array());
        $to_email = $gmail_settings['to_email'] ?? get_option('admin_email');
        $from_email = $gmail_settings['from_email'] ?? get_option('admin_email');
        $from_name = $gmail_settings['from_name'] ?? get_bloginfo('name');
        
        error_log('[Contact Us] Email settings:');
        error_log('[Contact Us] - To: ' . $to_email);
        error_log('[Contact Us] - From: ' . $from_email);
        error_log('[Contact Us] - From Name: ' . $from_name);
        
        // Prepare email content
        $email_subject = 'New Inquiry - ' . $name;
        
        // Rich HTML email template
        $email_body = $this->get_html_email_template($name, $email, $phone, $subject, $message);
        
        error_log('[Contact Us] Email content prepared');
        
        // Try to send via Gmail API first
        if (!empty($gmail_settings['access_token'])) {
            error_log('[Contact Us] Attempting to send via Gmail API');
            try {
                $gmail_api = new ContactUsGmailAPI();
                $sent = $gmail_api->send_email($to_email, $email_subject, $email_body);
                
                if ($sent) {
                    error_log('[Contact Us] Gmail API email sent successfully');
                    // Log successful submission
                    $this->log_submission($name, $email, $phone, $subject, $message, 'success');
                    wp_send_json_success('Message sent successfully!');
                } else {
                    error_log('[Contact Us] Gmail API email failed to send');
                }
            } catch (Exception $e) {
                error_log('[Contact Us] Gmail API failed: ' . $e->getMessage());
            }
        } else {
            error_log('[Contact Us] No Gmail API access token found. Settings: ' . print_r($gmail_settings, true));
        }
        
        // Fallback to WordPress default email
        error_log('[Contact Us] Falling back to WordPress wp_mail');
        $headers = array(
            'Content-Type: text/html; charset=UTF-8',
            'From: ' . $from_name . ' <' . $from_email . '>',
            'Reply-To: ' . $name . ' <' . $email . '>'
        );
        
        $sent = wp_mail($to_email, $email_subject, $email_body, $headers);
        
        if ($sent) {
            error_log('[Contact Us] WordPress wp_mail succeeded');
            $this->log_submission($name, $email, $phone, $subject, $message, 'success');
            wp_send_json_success('Message sent successfully!');
        } else {
            error_log('[Contact Us] WordPress wp_mail failed');
            $this->log_submission($name, $email, $phone, $subject, $message, 'failed');
            wp_send_json_error('Sorry, there was an error sending your message. Please try again later.');
        }
    }
    
    private function send_auto_reply($name, $email, $subject) {
        $auto_reply_subject = 'Thank you for contacting Five Rivers Tutoring';
        $auto_reply_body = $this->get_auto_reply_html_template($name, $subject);
        
        $headers = array(
            'From: Five Rivers Tutoring <' . get_option('admin_email') . '>',
            'Content-Type: text/html; charset=UTF-8'
        );
        
        $this->send_email_with_gmail_api($email, $auto_reply_subject, $auto_reply_body, $headers);
    }
    
    /**
     * Send email using Gmail API with fallback to wp_mail
     */
    private function send_email_with_gmail_api($to, $subject, $message, $headers = array()) {
        // Try Gmail API first
        try {
            $gmail_api = new ContactUsGmailAPI();
            if ($gmail_api->is_configured()) {
                $result = $gmail_api->send_email($to, $subject, $message, $headers);
                if ($result) {
                    return true;
                }
            }
        } catch (Exception $e) {
            error_log('Gmail API failed: ' . $e->getMessage());
        }
        
        // Fallback to wp_mail if Gmail API fails or not configured
        return wp_mail($to, $subject, $message, $headers);
    }
    
    private function log_submission($name, $email, $phone, $subject, $message, $status) {
        // Log submission to database or file
        $log_entry = array(
            'timestamp' => current_time('mysql'),
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'subject' => $subject,
            'message' => $message,
            'status' => $status,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        );
        
        // Store in WordPress options (simple logging)
        $logs = get_option('contact_us_logs', array());
        $logs[] = $log_entry;
        
        // Keep only last 100 entries
        if (count($logs) > 100) {
            $logs = array_slice($logs, -100);
        }
        
        update_option('contact_us_logs', $logs);
    }
    
    public function add_admin_menu() {
        add_options_page(
            'Contact Us Settings',
            'Contact Us',
            'manage_options',
            'contact-us',
            array($this, 'admin_page'),
            'dashicons-email-alt',
            30
        );
        
        // Debug: Log main menu registration
        error_log('Contact Us main menu registered with slug: contact-us');
        
        // Test if menu was added
        global $menu;
        foreach ($menu as $item) {
            if (isset($item[2]) && $item[2] === 'contact-us') {
                error_log('Contact Us menu found in global menu array');
                break;
            }
        }
    }
    
    public function admin_page() {
        ?>
        <div class="wrap">
            <h1>Contact Us Plugin</h1>
            
            <h2>Usage</h2>
            <p>Use the shortcode <code>[contact_us_form]</code> to display the contact form on any page or post.</p>
            
            <h3>Shortcode Options</h3>
            <ul>
                <li><code>[contact_us_form title="Custom Title"]</code> - Custom form title</li>
                <li><code>[contact_us_form show_phone="false"]</code> - Hide phone field</li>
                <li><code>[contact_us_form show_subject="false"]</code> - Hide subject field</li>
                <li><code>[contact_us_form hide_title="true"]</code> - Hide form title</li>
                <li><code>[contact_us_form theme_inherit="false"]</code> - Disable theme inheritance (use default styling)</li>
            </ul>
            
            <h3>Theme Inheritance</h3>
            <p>The contact form automatically inherits colors, fonts, and styling from your active WordPress theme when <code>theme_inherit="true"</code> (default). This ensures the form seamlessly integrates with your site's design.</p>
            
            <h2>Recent Submissions</h2>
            <?php $this->display_recent_submissions(); ?>
        </div>
        <?php
    }
    
    private function display_recent_submissions() {
        $logs = get_option('contact_us_logs', array());
        
        if (empty($logs)) {
            echo '<p>No submissions yet.</p>';
            return;
        }
        
        echo '<table class="wp-list-table widefat fixed striped">';
        echo '<thead><tr><th>Date</th><th>Name</th><th>Email</th><th>Subject</th><th>Status</th></tr></thead>';
        echo '<tbody>';
        
        $recent_logs = array_slice(array_reverse($logs), 0, 20);
        
        foreach ($recent_logs as $log) {
            echo '<tr>';
            echo '<td>' . esc_html($log['timestamp']) . '</td>';
            echo '<td>' . esc_html($log['name']) . '</td>';
            echo '<td>' . esc_html($log['email']) . '</td>';
            echo '<td>' . esc_html($log['subject']) . '</td>';
            echo '<td>' . esc_html($log['status']) . '</td>';
            echo '</tr>';
        }
        
        echo '</tbody></table>';
    }
    
    public function debug_test() {
        // Simple debug test - add a comment to the page
        echo '<!-- Contact Us Plugin Debug: Plugin is loaded -->';
    }
    
    public function log_admin_actions() {
        // Log admin page loads for debugging
        if (isset($_GET['page'])) {
            error_log('[Contact Us Plugin] Admin page accessed: ' . $_GET['page']);
        }
        
        // Log OAuth callback attempts
        if (isset($_GET['code'])) {
            error_log('[Contact Us Plugin] OAuth callback received with code: ' . substr($_GET['code'], 0, 10) . '...');
        }
        
        // Log any errors
        if (isset($_GET['error'])) {
            error_log('[Contact Us Plugin] OAuth error: ' . $_GET['error']);
        }
    }
    
    public function handle_oauth_callback() {
        error_log('[Contact Us Plugin] handle_oauth_callback() called');
        error_log('[Contact Us Plugin] REQUEST_URI: ' . $_SERVER['REQUEST_URI']);
        error_log('[Contact Us Plugin] All GET parameters: ' . print_r($_GET, true));
        
        // Check if this is our OAuth callback - be more flexible with the check
        if (isset($_GET['contact_us_oauth']) && $_GET['contact_us_oauth'] === 'callback') {
            error_log('[Contact Us Plugin] OAuth callback initiated - contact_us_oauth=callback detected');
        } elseif (isset($_GET['code']) && !isset($_GET['contact_us_oauth'])) {
            error_log('[Contact Us Plugin] OAuth callback initiated - code parameter detected without contact_us_oauth');
        } else {
            error_log('[Contact Us Plugin] Not an OAuth callback - continuing normally');
            return; // Not our callback, continue normally
        }
        
        // If we have a code parameter, process it
        if (isset($_GET['code'])) {
            error_log('[Contact Us Plugin] OAuth code received: ' . substr($_GET['code'], 0, 10) . '...');
            
            try {
                $gmail_api = new ContactUsGmailAPI();
                $result = $gmail_api->handle_oauth_callback($_GET['code']);
                
                if ($result) {
                    error_log('[Contact Us Plugin] OAuth callback successful');
                    wp_redirect(admin_url('admin.php?page=contact-us-gmail&oauth_callback=success'));
                    exit;
                } else {
                    error_log('[Contact Us Plugin] OAuth callback failed');
                    wp_redirect(admin_url('admin.php?page=contact-us-gmail&oauth_error=1'));
                    exit;
                }
            } catch (Exception $e) {
                error_log('[Contact Us Plugin] OAuth callback exception: ' . $e->getMessage());
                wp_redirect(admin_url('admin.php?page=contact-us-gmail&oauth_error=1&error_msg=' . urlencode($e->getMessage())));
                exit;
            }
        } elseif (isset($_GET['error'])) {
            error_log('[Contact Us Plugin] OAuth error: ' . $_GET['error']);
            wp_redirect(admin_url('admin.php?page=contact-us-gmail&oauth_error=1&error_msg=' . urlencode($_GET['error'])));
            exit;
        } else {
            error_log('[Contact Us Plugin] OAuth callback received but no code or error parameter');
            wp_redirect(admin_url('admin.php?page=contact-us-gmail&oauth_error=1&error_msg=no_code_or_error'));
            exit;
        }
    }
    
    /**
     * Generate rich HTML email template
     */
    private function get_html_email_template($name, $email, $phone, $subject, $message) {
        $current_time = current_time('Y-m-d H:i:s');
        $website_url = get_bloginfo('url');
        $site_name = get_bloginfo('name');
        
        return "
        <!DOCTYPE html>
        <html lang='en'>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>Contact Form Submission</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    margin: 0;
                    padding: 0;
                    background-color: #f8f9fa;
                }
                .email-container {
                    max-width: 600px;
                    margin: 20px auto;
                    background: #ffffff;
                    border-radius: 12px;
                    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
                    overflow: hidden;
                }
                .email-header {
                    background: linear-gradient(135deg, #00B647 0%, #008f3a 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                }
                .email-header h1 {
                    margin: 0;
                    font-size: 28px;
                    font-weight: 600;
                    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
                }
                .email-header .subtitle {
                    margin: 10px 0 0 0;
                    font-size: 16px;
                    opacity: 0.9;
                    font-weight: 300;
                }
                .email-content {
                    padding: 40px 30px;
                }
                .contact-details {
                    background: #f8f9fa;
                    border-radius: 8px;
                    padding: 25px;
                    margin-bottom: 30px;
                    border-left: 4px solid #00B647;
                }
                .contact-details h2 {
                    margin: 0 0 20px 0;
                    color: #00B647;
                    font-size: 20px;
                    font-weight: 600;
                }
                .detail-row {
                    display: flex;
                    margin-bottom: 15px;
                    align-items: center;
                }
                .detail-label {
                    width: 100px;
                    font-weight: 600;
                    color: #555;
                    flex-shrink: 0;
                }
                .detail-value {
                    flex: 1;
                    color: #333;
                    font-weight: 500;
                }
                .message-section {
                    background: #fff;
                    border: 2px solid #e9ecef;
                    border-radius: 8px;
                    padding: 25px;
                    margin-bottom: 30px;
                }
                .message-section h2 {
                    margin: 0 0 20px 0;
                    color: #495057;
                    font-size: 20px;
                    font-weight: 600;
                }
                .message-content {
                    background: #f8f9fa;
                    padding: 20px;
                    border-radius: 6px;
                    border-left: 4px solid #00B647;
                    font-style: italic;
                    line-height: 1.7;
                }
                .footer-info {
                    background: #f8f9fa;
                    border-radius: 8px;
                    padding: 20px;
                    text-align: center;
                    border-top: 1px solid #e9ecef;
                }
                .footer-info .timestamp {
                    color: #6c757d;
                    font-size: 14px;
                    margin-bottom: 10px;
                }
                .footer-info .website {
                    color: #00B647;
                    font-weight: 600;
                    text-decoration: none;
                }
                .footer-info .website:hover {
                    text-decoration: underline;
                }
                .action-buttons {
                    text-align: center;
                    margin-top: 25px;
                }
                .btn {
                    display: inline-block;
                    padding: 12px 24px;
                    margin: 0 10px;
                    background: #00B647;
                    color: white;
                    text-decoration: none;
                    border-radius: 6px;
                    font-weight: 600;
                    transition: all 0.3s ease;
                }
                .btn:hover {
                    background: #008f3a;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(0, 182, 71, 0.3);
                }
                .btn-secondary {
                    background: #6c757d;
                }
                .btn-secondary:hover {
                    background: #5a6268;
                }
                @media (max-width: 600px) {
                    .email-container {
                        margin: 10px;
                        border-radius: 8px;
                    }
                    .email-header, .email-content {
                        padding: 20px;
                    }
                    .detail-row {
                        flex-direction: column;
                        align-items: flex-start;
                    }
                    .detail-label {
                        width: auto;
                        margin-bottom: 5px;
                    }
                }
            </style>
        </head>
        <body>
            <div class='email-container'>
                <div class='email-header'>
                    <h1>📧 New Contact Form Submission</h1>
                    <p class='subtitle'>You have received a new message from your website</p>
                </div>
                
                <div class='email-content'>
                    <div class='contact-details'>
                        <h2>👤 Contact Information</h2>
                        <div class='detail-row'>
                            <div class='detail-label'>Name:</div>
                            <div class='detail-value'>" . esc_html($name) . "</div>
                        </div>
                        <div class='detail-row'>
                            <div class='detail-label'>Email:</div>
                            <div class='detail-value'>
                                <a href='mailto:" . esc_attr($email) . "' style='color: #00B647; text-decoration: none;'>" . esc_html($email) . "</a>
                            </div>
                        </div>
                        <div class='detail-row'>
                            <div class='detail-label'>Phone:</div>
                            <div class='detail-value'>
                                <a href='tel:" . esc_attr($phone) . "' style='color: #00B647; text-decoration: none;'>" . esc_html($phone) . "</a>
                            </div>
                        </div>
                        <div class='detail-row'>
                            <div class='detail-label'>Subject:</div>
                            <div class='detail-value'>" . esc_html($subject) . "</div>
                        </div>
                    </div>
                    
                    <div class='message-section'>
                        <h2>💬 Message Content</h2>
                        <div class='message-content'>" . nl2br(esc_html($message)) . "</div>
                    </div>
                    
                    <div class='action-buttons'>
                        <a href='mailto:" . esc_attr($email) . "?subject=Re: " . esc_attr($subject) . "' class='btn'>📧 Reply to Message</a>
                        <a href='" . esc_url($website_url) . "/wp-admin/admin.php?page=contact-us-settings' class='btn btn-secondary'>⚙️ View All Submissions</a>
                    </div>
                </div>
                
                <div class='footer-info'>
                    <div class='timestamp'>📅 Submitted on: " . esc_html($current_time) . "</div>
                    <div class='website'>
                        🌐 <a href='" . esc_url($website_url) . "' style='color: #00B647; text-decoration: none;'>" . esc_html($site_name) . "</a>
                    </div>
                </div>
            </div>
        </body>
        </html>";
    }
    
    /**
     * Generate HTML auto-reply email template
     */
    private function get_auto_reply_html_template($name, $subject) {
        $website_url = get_bloginfo('url');
        $site_name = get_bloginfo('name');
        
        return "
        <!DOCTYPE html>
        <html lang='en'>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>Thank you for contacting us</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    margin: 0;
                    padding: 0;
                    background-color: #f8f9fa;
                }
                .email-container {
                    max-width: 600px;
                    margin: 20px auto;
                    background: #ffffff;
                    border-radius: 12px;
                    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
                    overflow: hidden;
                }
                .email-header {
                    background: linear-gradient(135deg, #00B647 0%, #008f3a 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                }
                .email-header h1 {
                    margin: 0;
                    font-size: 28px;
                    font-weight: 600;
                    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
                }
                .email-header .subtitle {
                    margin: 10px 0 0 0;
                    font-size: 16px;
                    opacity: 0.9;
                    font-weight: 300;
                }
                .email-content {
                    padding: 40px 30px;
                }
                .thank-you-message {
                    text-align: center;
                    margin-bottom: 30px;
                }
                .thank-you-message h2 {
                    color: #00B647;
                    font-size: 24px;
                    margin-bottom: 20px;
                }
                .thank-you-message p {
                    font-size: 16px;
                    color: #555;
                    line-height: 1.7;
                }
                .response-time {
                    background: #f8f9fa;
                    border-radius: 8px;
                    padding: 25px;
                    margin-bottom: 30px;
                    border-left: 4px solid #00B647;
                    text-align: center;
                }
                .response-time h3 {
                    color: #00B647;
                    margin: 0 0 15px 0;
                    font-size: 20px;
                }
                .response-time p {
                    margin: 0;
                    color: #555;
                    font-size: 16px;
                }
                .contact-info {
                    background: #fff;
                    border: 2px solid #e9ecef;
                    border-radius: 8px;
                    padding: 25px;
                    margin-bottom: 30px;
                    text-align: center;
                }
                .contact-info h3 {
                    color: #495057;
                    margin: 0 0 20px 0;
                    font-size: 20px;
                }
                .contact-info p {
                    margin: 10px 0;
                    color: #555;
                }
                .action-buttons {
                    text-align: center;
                    margin-top: 25px;
                }
                .btn {
                    display: inline-block;
                    padding: 12px 24px;
                    margin: 0 10px;
                    background: #00B647;
                    color: white;
                    text-decoration: none;
                    border-radius: 6px;
                    font-weight: 600;
                    transition: all 0.3s ease;
                }
                .btn:hover {
                    background: #008f3a;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(0, 182, 71, 0.3);
                }
                .btn-secondary {
                    background: #6c757d;
                }
                .btn-secondary:hover {
                    background: #5a6268;
                }
                .footer-info {
                    background: #f8f9fa;
                    border-radius: 8px;
                    padding: 20px;
                    text-align: center;
                    border-top: 1px solid #e9ecef;
                }
                .footer-info .website {
                    color: #00B647;
                    font-weight: 600;
                    text-decoration: none;
                }
                .footer-info .website:hover {
                    text-decoration: underline;
                }
                @media (max-width: 600px) {
                    .email-container {
                        margin: 10px;
                        border-radius: 8px;
                    }
                    .email-header, .email-content {
                        padding: 20px;
                    }
                }
            </style>
        </head>
        <body>
            <div class='email-container'>
                <div class='email-header'>
                    <h1>🎉 Thank You!</h1>
                    <p class='subtitle'>We've received your message</p>
                </div>
                
                <div class='email-content'>
                    <div class='thank-you-message'>
                        <h2>Dear " . esc_html($name) . ",</h2>
                        <p>Thank you for contacting <strong>" . esc_html($site_name) . "</strong>! We have received your message regarding <strong>'" . esc_html($subject) . "'</strong> and appreciate you taking the time to reach out to us.</p>
                    </div>
                    
                    <div class='response-time'>
                        <h3>⏰ What Happens Next?</h3>
                        <p>Our team will review your message and get back to you within <strong>24-48 hours</strong> during business days.</p>
                    </div>
                    
                    <div class='contact-info'>
                        <h3>📞 Need Immediate Assistance?</h3>
                        <p>If you have an urgent inquiry, please don't hesitate to call us directly.</p>
                        <p><strong>Phone:</strong> <a href='tel:+61412345678' style='color: #00B647; text-decoration: none;'>+61 412 345 678</a></p>
                        <p><strong>Email:</strong> <a href='mailto:info@" . parse_url($website_url, PHP_URL_HOST) . "' style='color: #00B647; text-decoration: none;'>info@" . parse_url($website_url, PHP_URL_HOST) . "</a></p>
                    </div>
                    
                    <div class='action-buttons'>
                        <a href='" . esc_url($website_url) . "' class='btn'>🏠 Visit Our Website</a>
                        <a href='" . esc_url($website_url . '/about') . "' class='btn btn-secondary'>ℹ️ Learn More About Us</a>
                    </div>
                </div>
                
                <div class='footer-info'>
                    <div class='website'>
                        🌐 <a href='" . esc_url($website_url) . "' style='color: #00B647; text-decoration: none;'>" . esc_html($site_name) . "</a>
                    </div>
                </div>
            </div>
        </body>
        </html>";
    }
}

// Initialize the plugin
new ContactUsPlugin();

// Activation hook for debugging
register_activation_hook(__FILE__, function() {
    error_log('Contact Us Plugin activated');
});

// Deactivation hook for debugging
register_deactivation_hook(__FILE__, function() {
    error_log('Contact Us Plugin deactivated');
});
