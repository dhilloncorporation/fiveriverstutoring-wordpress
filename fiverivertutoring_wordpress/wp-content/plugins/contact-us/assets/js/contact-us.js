jQuery(document).ready(function($) {
    console.log('Contact form script loaded');
    console.log('createSuccessMessage function exists:', typeof createSuccessMessage);
    
    $('#contact-us-form').on('submit', function(e) {
        e.preventDefault();
        
        var $form = $(this);
        var $submitBtn = $form.find('.contact-submit-btn');
        var $response = $('#contact-form-response');
        
        // Get form data
        var formData = {
            action: 'contact_us_submit',
            contact_us_nonce: contact_us_ajax.nonce,
            name: $('#contact_name').val(),
            email: $('#contact_email').val(),
            phone: $('#contact_phone').val(),
            subject: $('#contact_subject').val(),
            message: $('#contact_message').val()
        };
        
        // Validate required fields
        if (!formData.name || !formData.email || !formData.subject || !formData.message) {
            showResponse('Please fill in all required fields.', 'error');
            return;
        }
        
        // Validate email format
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(formData.email)) {
            showResponse('Please enter a valid email address.', 'error');
            return;
        }
        
        // Disable submit button and show loading
        $submitBtn.prop('disabled', true).text('Sending...');
        $response.hide();
        
        // Send AJAX request
        $.ajax({
            url: contact_us_ajax.ajax_url,
            type: 'POST',
            data: formData,
            success: function(response) {
                console.log('AJAX Response received:', response);
                console.log('Response type:', typeof response);
                console.log('Response.success:', response.success);
                
                if (response.success) {
                    console.log('Success branch - calling createSuccessMessage');
                    // Hide the form and show success message
                    $form.slideUp(400, function() {
                        console.log('Form slid up, now showing success message');
                        showResponse(createSuccessMessage(), 'success');
                    });
                } else {
                    console.log('Error branch - showing error message');
                    showResponse(response.data, 'error');
                }
            },
            error: function() {
                showResponse('An error occurred. Please try again.', 'error');
            },
            complete: function() {
                // Re-enable submit button
                $submitBtn.prop('disabled', false).text('Send Message');
            }
        });
    });
    
    function showResponse(message, type) {
        console.log('showResponse called with:', {message: message, type: type});
        var $response = $('#contact-form-response');
        console.log('Response element found:', $response.length);
        console.log('Response element:', $response[0]);
        
        var cssClass = type === 'success' ? 'success' : 'error';
        console.log('CSS class to apply:', cssClass);
        
        $response
            .removeClass('success error')
            .addClass(cssClass)
            .html(message)
            .show();
        
        console.log('Response element after update:', $response.html());
        console.log('Response element display:', $response.css('display'));
        
        // Auto-hide success messages after 5 seconds
        if (type === 'success') {
            setTimeout(function() {
                $response.fadeOut();
            }, 5000);
        }
        
        // Scroll to response message
        $('html, body').animate({
            scrollTop: $response.offset().top - 100
        }, 500);
    }
    
    function createSuccessMessage() {
        console.log('createSuccessMessage function called');
        // Get social media URLs from localized data or use defaults
        const socialUrls = window.contact_us_social || {
            facebook: 'https://facebook.com/fiveriverstutoring',
            instagram: 'https://instagram.com/fiveriverstutoring',
            linkedin: 'https://linkedin.com/company/fiveriverstutoring'
        };
        
        return `
            <div class="contact-success-message">
                <div class="success-icon">🎉</div>
                <h3>Thank You!</h3>
                <p>Thank you for reaching out to Five Rivers Tutoring! Your message has been received, and one of our mentors will be in touch shortly.</p>
                
                <div class="social-follow-section">
                    <h4>Stay Connected with Us!</h4>
                    <p>In the meantime, stay inspired and connected—follow us for tips, updates, and student success stories:</p>
                    
                    <div class="social-hint">
                        <span class="social-hint-icon">🔗</span>
                        <p>📘 Facebook 📸 Instagram</p>
                        <p class="social-note">Check out our social media links in the website header and footer</p>
                    </div>
                    
                    <div class="newsletter-signup">
                        <p>📧 Get our newsletter for exclusive content and updates!</p>
                        <button class="newsletter-btn" onclick="alert('Newsletter signup coming soon!')">
                            Subscribe to Newsletter
                        </button>
                    </div>
                </div>
                
                <div class="action-buttons">
                    <button class="reset-form-btn" onclick="resetContactForm()">
                        Send Another Message
                    </button>
                    <button class="close-message-btn" onclick="closeSuccessMessage()">
                        Close
                    </button>
                </div>
            </div>
        `;
    }
    
    function resetContactForm() {
        $('#contact-form-response').slideUp(400, function() {
            $('#contact-us-form').slideDown(400);
            $('#contact-us-form')[0].reset();
        });
    }
    
    function closeSuccessMessage() {
        $('#contact-form-response').slideUp(400);
    }
    
    // Real-time validation
    $('#contact_email').on('blur', function() {
        var email = $(this).val();
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        
        if (email && !emailRegex.test(email)) {
            $(this).addClass('error');
            if (!$(this).next('.validation-error').length) {
                $(this).after('<span class="validation-error">Please enter a valid email address.</span>');
            }
        } else {
            $(this).removeClass('error');
            $(this).next('.validation-error').remove();
        }
    });
    
    // Remove validation errors on input
    $('input, textarea').on('input', function() {
        $(this).removeClass('error');
        $(this).next('.validation-error').remove();
    });
});
