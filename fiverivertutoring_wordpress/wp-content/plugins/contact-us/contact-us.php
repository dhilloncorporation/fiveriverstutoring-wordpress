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
        wp_enqueue_script('contact-us-js', plugin_dir_url(__FILE__) . 'assets/js/contact-us.js', array('jquery'), '1.0.0', true);
        wp_enqueue_style('contact-us-css', plugin_dir_url(__FILE__) . 'assets/css/contact-us.css', array(), '1.0.0');
        
        // Localize script for AJAX
        wp_localize_script('contact-us-js', 'contact_us_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('contact_us_submit')
        ));
    }
    
    public function render_contact_form($atts) {
        $atts = shortcode_atts(array(
            'title' => 'Contact Us',
            'show_phone' => 'true',
            'show_subject' => 'true'
        ), $atts);
        
        // Smart title detection - avoid duplication with page headings
        $smart_title = $this->get_smart_form_title($atts['title']);
        
        ob_start();
        ?>
        <div class="contact-us-form-container">
            <h3><?php echo esc_html($smart_title); ?></h3>
            
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
                
                <div id="contact-form-response" class="contact-form-response" style="display: none;"></div>
            </form>
        </div>
        <?php
        return ob_get_clean();
    }
    
    /**
     * Smart title detection to avoid duplication
     */
    private function get_smart_form_title($requested_title) {
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
                    // Page title contains contact-related words, use alternative form title
                    return 'Get in Touch';
                }
            }
        }
        
        // Check if we're in a contact-related context
        if (is_page() && (strpos(strtolower(get_the_title()), 'contact') !== false)) {
            return 'Get in Touch';
        }
        
        // Default fallback
        return 'Contact Us';
    }
    
    /**
     * Handle form submission
     */
    public function handle_form_submission() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['contact_us_nonce'], 'contact_us_submit')) {
            wp_send_json_error('Security check failed');
        }
        
        // Get form data
        $name = sanitize_text_field($_POST['name'] ?? '');
        $email = sanitize_email($_POST['email'] ?? '');
        $phone = sanitize_text_field($_POST['phone'] ?? '');
        $subject = sanitize_text_field($_POST['subject'] ?? '');
        $message = sanitize_textarea_field($_POST['message'] ?? '');
        
        // Validate required fields
        if (empty($name) || empty($email) || empty($message)) {
            wp_send_json_error('Please fill in all required fields');
        }
        
        // Get Gmail API settings
        $gmail_settings = get_option('contact_us_gmail_settings', array());
        $to_email = $gmail_settings['to_email'] ?? get_option('admin_email');
        $from_email = $gmail_settings['from_email'] ?? get_option('admin_email');
        $from_name = $gmail_settings['from_name'] ?? get_bloginfo('name');
        
        // Prepare email content
        $email_subject = 'Contact Form Submission: ' . $subject;
        $email_body = "New contact form submission:\n\n";
        $email_body .= "Name: $name\n";
        $email_body .= "Email: $email\n";
        $email_body .= "Phone: $phone\n";
        $email_body .= "Subject: $subject\n\n";
        $email_body .= "Message:\n$message\n\n";
        $email_body .= "Submitted on: " . current_time('Y-m-d H:i:s') . "\n";
        $email_body .= "Website: " . get_bloginfo('url');
        
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
            'Content-Type: text/plain; charset=UTF-8',
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
        $auto_reply_body = "Dear " . $name . ",\n\n";
        $auto_reply_body .= "Thank you for contacting Five Rivers Tutoring. We have received your message regarding '" . $subject . "' and will get back to you within 24-48 hours.\n\n";
        $auto_reply_body .= "Best regards,\n";
        $auto_reply_body .= "Five Rivers Tutoring Team\n";
        $auto_reply_body .= get_site_url();
        
        $headers = array(
            'From: Five Rivers Tutoring <' . get_option('admin_email') . '>',
            'Content-Type: text/plain; charset=UTF-8'
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
        add_menu_page(
            'Contact Us',
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
            </ul>
            
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
