<?php
/**
 * Plugin Name: Five Rivers Tutoring Scheduler
 * Plugin URI: https://fiveriverstutoring.com
 * Description: Advanced tutoring booking system with mobile optimization for Australian students
 * Version: 1.0.0
 * Author: Dhillon Corporation
 * Author URI: https://dhilloncorporation.com
 * License: GPL v2 or later
 * Text Domain: fiverivers-tutoring
 * Domain Path: /languages
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('FIVERIVERS_TUTORING_VERSION', '1.0.0');
define('FIVERIVERS_TUTORING_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('FIVERIVERS_TUTORING_PLUGIN_URL', plugin_dir_url(__FILE__));

/**
 * Main Tutoring Scheduler Class
 */
class FiveRiversTutoringScheduler {
    
    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
        add_action('wp_ajax_book_tutoring_session', array($this, 'book_tutoring_session'));
        add_action('wp_ajax_nopriv_book_tutoring_session', array($this, 'book_tutoring_session'));
        add_shortcode('tutoring_scheduler', array($this, 'tutoring_scheduler_shortcode'));
    }
    
    /**
     * Initialize the plugin
     */
    public function init() {
        // Load text domain for translations
        load_plugin_textdomain('fiverivers-tutoring', false, dirname(plugin_basename(__FILE__)) . '/languages');
    }
    
    /**
     * Enqueue scripts and styles
     */
    public function enqueue_scripts() {
        wp_enqueue_style(
            'fiverivers-tutoring-scheduler',
            FIVERIVERS_TUTORING_PLUGIN_URL . 'frontend/assets/css/scheduler.css',
            array(),
            FIVERIVERS_TUTORING_VERSION
        );
        
        wp_enqueue_script(
            'fiverivers-tutoring-scheduler',
            FIVERIVERS_TUTORING_PLUGIN_URL . 'frontend/assets/js/scheduler.js',
            array('jquery'),
            FIVERIVERS_TUTORING_VERSION,
            true
        );
        
        wp_localize_script('fiverivers-tutoring-scheduler', 'fiverivers_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('fiverivers_tutoring_nonce')
        ));
    }
    
    /**
     * Handle tutoring session booking
     */
    public function book_tutoring_session() {
        // Verify nonce
        if (!wp_verify_nonce($_POST['nonce'], 'fiverivers_tutoring_nonce')) {
            wp_die('Security check failed');
        }
        
        $student_name = sanitize_text_field($_POST['student_name']);
        $subject = sanitize_text_field($_POST['subject']);
        $date = sanitize_text_field($_POST['date']);
        $time = sanitize_text_field($_POST['time']);
        $contact_email = sanitize_email($_POST['contact_email']);
        
        // Store booking in localStorage (client-side storage)
        $response = array(
            'success' => true,
            'message' => 'Booking saved successfully! We will contact you soon.',
            'booking_data' => array(
                'student_name' => $student_name,
                'subject' => $subject,
                'date' => $date,
                'time' => $time,
                'contact_email' => $contact_email,
                'booking_id' => uniqid('booking_')
            )
        );
        
        wp_send_json($response);
    }
    
    /**
     * Tutoring scheduler shortcode
     */
    public function tutoring_scheduler_shortcode($atts) {
        $atts = shortcode_atts(array(
            'title' => 'Book Your Tutoring Session',
            'subtitle' => 'Choose your subject, date, and time'
        ), $atts);
        
        ob_start();
        ?>
        <div class="fiverivers-tutoring-scheduler">
            <div class="scheduler-header">
                <h2><?php echo esc_html($atts['title']); ?></h2>
                <p><?php echo esc_html($atts['subtitle']); ?></p>
            </div>
            
            <form id="tutoring-booking-form" class="booking-form">
                <div class="form-group">
                    <label for="student_name">Student Name *</label>
                    <input type="text" id="student_name" name="student_name" required>
                </div>
                
                <div class="form-group">
                    <label for="subject">Subject *</label>
                    <select id="subject" name="subject" required>
                        <option value="">Select a subject</option>
                        <option value="high_school_math">High School Math (Years 6-10)</option>
                        <option value="vce_physics">VCE Physics</option>
                        <option value="vce_general">VCE General Mathematics</option>
                        <option value="exam_prep">Exam Preparation</option>
                        <option value="homework_help">Homework Help</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="date">Preferred Date *</label>
                    <input type="date" id="date" name="date" required>
                </div>
                
                <div class="form-group">
                    <label for="time">Preferred Time *</label>
                    <select id="time" name="time" required>
                        <option value="">Select a time</option>
                        <option value="09:00">9:00 AM</option>
                        <option value="10:00">10:00 AM</option>
                        <option value="11:00">11:00 AM</option>
                        <option value="14:00">2:00 PM</option>
                        <option value="15:00">3:00 PM</option>
                        <option value="16:00">4:00 PM</option>
                        <option value="17:00">5:00 PM</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="contact_email">Contact Email *</label>
                    <input type="email" id="contact_email" name="contact_email" required>
                </div>
                
                <div class="form-group">
                    <label for="notes">Additional Notes</label>
                    <textarea id="notes" name="notes" rows="3" placeholder="Any specific topics or concerns you'd like to discuss?"></textarea>
                </div>
                
                <button type="submit" class="booking-submit-btn">Book Session</button>
            </form>
            
            <div id="booking-confirmation" class="booking-confirmation" style="display: none;">
                <h3>Booking Confirmed!</h3>
                <p>Thank you for booking with Five Rivers Tutoring. We will contact you within 24 hours to confirm your session.</p>
                <div id="booking-details"></div>
            </div>
        </div>
        <?php
        return ob_get_clean();
    }
}

// Initialize the plugin
new FiveRiversTutoringScheduler(); 