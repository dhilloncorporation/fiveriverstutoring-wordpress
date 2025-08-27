jQuery(document).ready(function($) {
    console.log('Contact form script loaded');
    
    // Ensure form is visible on page load
    var $form = $('#contact-us-form');
    if ($form.length && $form.is(':hidden')) {
        console.log('Form was hidden, making it visible');
        $form.show().css({
            'display': 'flex',
            'visibility': 'visible',
            'opacity': '1'
        });
    }
    
    $('#contact-us-form').on('submit', function(e) {
        e.preventDefault();
        console.log('Form submission started');
        
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
        
        console.log('Form data:', formData);
        
        // Validate required fields
        if (!formData.name || !formData.email || !formData.subject || !formData.message) {
            console.log('Validation failed - missing required fields');
            showResponse('Please fill in all required fields.', 'error');
            return;
        }
        
        // Validate email format
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(formData.email)) {
            console.log('Validation failed - invalid email format');
            showResponse('Please enter a valid email address.', 'error');
            return;
        }
        
        console.log('Validation passed, sending AJAX request');
        
        // Disable submit button and show loading
        $submitBtn.prop('disabled', true).text('Sending...');
        
        // Send AJAX request
        $.ajax({
            url: contact_us_ajax.ajax_url,
            type: 'POST',
            data: formData,
            success: function(response) {
                console.log('AJAX response received:', response);
                
                if (response.success) {
                    console.log('Success response - hiding form and showing success message');
                    // Hide the form and show success message
                    $form.slideUp(400, function() {
                        // Ensure response container is visible and ready
                        $response.removeClass('success error').show().css({
                            'display': 'block',
                            'visibility': 'visible',
                            'opacity': '1',
                            'position': 'relative',
                            'z-index': '9999'
                        });
                        showResponse(createSuccessMessage(), 'success');
                    });
                } else {
                    console.log('Error response:', response.data);
                    showResponse(response.data || 'An error occurred', 'error');
                }
            },
            error: function(xhr, status, error) {
                console.log('AJAX error:', {xhr: xhr, status: status, error: error});
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
        console.log('Response container found:', $response.length);
        
        var cssClass = type === 'success' ? 'success' : 'error';
        
        // Clear previous content and set new content
        $response
            .removeClass('success error')
            .addClass(cssClass)
            .html(message);
        
        // Only show the response element when we have content
        if (message && message.trim() !== '') {
            $response.show().css({
                'display': 'block',
                'visibility': 'visible',
                'opacity': '1',
                'position': 'relative',
                'z-index': '9999'
            });
        }
        
        console.log('Response element updated, CSS applied');
        
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
        return `
            <div class="contact-success-message">
                <div class="success-icon">🎉</div>
                <h3>Thank You!</h3>
                <p>Thank you for reaching out to Five Rivers Tutoring! Your message has been received, and one of our mentors will be in touch shortly.</p>
                
                <div class="social-follow-section">
                    <h4>Stay Connected with Us!</h4>
                    <p>In the meantime, stay inspired and connected—follow us for tips, updates, and student success stories:</p>
                    
                    <div class="social-links">
                        <a href="https://www.facebook.com/fiverivers.tutoring.australia" class="social-link facebook" target="_blank" rel="noopener noreferrer">
                            <svg width="24" height="24" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                                <path d="M12 2C6.5 2 2 6.5 2 12c0 5 3.7 9.1 8.4 9.9v-7H7.9V12h2.5V9.8c0-2.5 1.5-3.9 3.8-3.9 1.1 0 2.2.2 2.2.2v2.5h-1.3c-1.2 0-1.6.8-1.6 1.6V12h2.8l-.4 2.9h-2.3v7C18.3 21.1 22 17 22 12c0-5.5-4.5-10-10-10z"></path>
                            </svg>
                            <span>Facebook</span>
                        </a>
                        
                        <a href="https://www.instagram.com/fiverivers.tutoring.australia/" class="social-link instagram" target="_blank" rel="noopener noreferrer">
                            <svg width="24" height="24" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                                <path d="M12,4.622c2.403,0,2.688,0.009,3.637,0.052c0.877,0.04,1.354,0.187,1.671,0.31c0.42,0.163,0.72,0.358,1.035,0.673 c0.315,0.315,0.51,0.615,0.673,1.035c0.123,0.317,0.27,0.794,0.31,1.671c0.043,0.949,0.052,1.234,0.052,3.637 s-0.009,2.688-0.052,3.637c-0.04,0.877-0.187,1.354-0.31,1.671c-0.163,0.42-0.358,0.72-1.035,0.673c-0.317,0.123-0.794,0.27-1.671,0.31c-0.949,0.043-1.233,0.052-3.637,0.052 s-2.688-0.009-3.637-0.052c-0.877-0.04-1.354-0.187-1.671-0.31c-0.42-0.163-0.72-0.358-1.035-0.673 c-0.315-0.315-0.51-0.615-0.673-1.035c-0.123-0.317-0.27-0.794-0.31-1.671C4.631,14.688,4.622,14.403,4.622,12 s0.009-2.688,0.052-3.637c0.04-0.877,0.187-1.354,0.31-1.671c0.163-0.42,0.358-0.72,0.673-1.035 c0.315-0.315,0.615-0.51,1.035-0.673c0.317,0.123,0.794-0.27,1.671-0.31C9.312,4.631,9.597,4.622,12,4.622 M12,3 C9.556,3,9.249,3.01,8.289,3.054C7.331,3.098,6.677,3.25,6.105,3.472C5.513,3.702,5.011,4.01,4.511,4.511 c-0.5,0.5-0.808,1.002-1.038,1.594C3.25,6.677,3.098,7.331,3.054,8.289C3.01,9.249,3,9.556,3,12c0,2.444,0.01,2.751,0.054,3.711 c0.044,0.958,0.196,1.612,0.418,2.185c0.23,0.592,0.538,1.094,1.038,1.594c0.5,0.5,1.002,0.808,1.594,1.038 c0.572,0.222,1.227,0.375,2.185,0.418C9.249,20.99,9.556,21,12,21s2.751-0.01,3.711-0.054c0.958-0.044,1.612-0.196,2.185-0.418 c0.592-0.23,1.094-0.538,1.594-1.038c-0.5-0.5,0.808-1.002,1.038-1.594c0.222-0.572,0.375-1.227,0.418-2.185 C20.99,14.751,21,14.444,21,12s-0.01-2.751-0.054-3.711c-0.044-0.958-0.196-1.612-0.418-2.185c-0.23-0.592-0.538-1.094-1.038-1.594 c-0.5-0.5-1.002-0.808-1.594-1.038c-0.572-0.222-1.227-0.375-2.185-0.418C14.751,3.01,14.444,3,12,3L12,3z M12,7.378 c-2.552,0-4.622,2.069-4.622,4.622S9.448,16.622,12,16.622s4.622-2.069,4.622-4.622S14.552,7.378,12,7.378z M12,15 c-1.657,0-3-1.343-3-3s1.343-3,3-3s3,1.343,3-3S13.657,15,12,15z M16.804,6.116c-0.596,0-1.08,0.484-1.08,1.08 s0.484,1.08,1.08,1.08c0.596,0,1.08-0.484,1.08-1.08S17.401,6.116,16.804,6.116z"></path>
                            </svg>
                            <span>Instagram</span>
                        </a>
                        
                        <a href="https://business.google.com/v/five-rivers-tutoring/05230615865829165891/bd31/_?caid=21752702047&agid=169582458162&gclid=CjwKCAjw0t63BhAUEiwA5xP54fSwDN_C72hvrqzmHLVt4x0ejsBTuQvW4i-nF_UMmQppBDJ0evS7bxoCYDEQAvD_BwE" class="social-link google" target="_blank" rel="noopener noreferrer">
                            <svg width="24" height="24" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                                <path d="M12.02,10.18v3.72v0.01h5.51c-0.26,1.57-1.67,4.22-5.5,4.22c-3.31,0-6.01-2.75-6.01-6.12s2.7-6.12,6.01-6.12 c1.87,0,3.13,0.8,3.85,1.48l2.84-2.76C16.99,2.99,14.73,2,12.03,2c-5.52,0-10,4.48-10,10s4.48,10,10,10c5.77,0,9.6-4.06,9.6-9.77 c0-0.83-0.11-1.42-0.25-2.05H12.02z"></path>
                            </svg>
                            <span>Google Business</span>
                        </a>
                        
                        <a href="mailto:fiverivers.tutoring@outlook.com" class="social-link email">
                            <svg width="24" height="24" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                                <path d="M19,5H5c-1.1,0-2,.9-2,2v10c0,1.1.9,2,2,2h14c1.1,0,2-.9,2-2V7c0-1.1-.9-2-2-2zm.5,12c0,.3-.2.5-.5.5H5c-.3,0-.5-.2-.5-.5V9.8l7.5,5.6,7.5-5.6V17zm0-9.1L12,13.6,4.5,7.9V7c0-.3.2-.5.5-.5h14c.3,0,.5.2.5.5v.9z"></path>
                            </svg>
                            <span>Email Us</span>
                        </a>
                    </div>
                    
                    <p class="social-note">Connect with us on social media for updates and student success stories!</p>
                </div>
                
                <div class="action-buttons">
                    <button class="reset-form-btn" data-action="reset">
                        Send Another Message
                    </button>
                    <button class="ok-btn" data-action="ok">
                        Ok
                    </button>
                </div>
            </div>
        `;
    }
    
    function resetContactForm() {
        console.log('resetContactForm function called');
        $('#contact-form-response').slideUp(400, function() {
            $('#contact-us-form').slideDown(400).removeClass('force-show');
            $('#contact-us-form')[0].reset();
            // Clear any previous response content
            $('#contact-form-response').removeClass('success error').html('');
            console.log('Form reset completed');
        });
    }
    
    function goToHomePage() {
        console.log('goToHomePage function called');
        console.log('Home URL:', contact_us_ajax.home_url);
        window.location.href = contact_us_ajax.home_url || '/';
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

    // Event delegation for action buttons
    $(document).on('click', '.contact-success-message .action-buttons button', function(e) {
        var action = $(this).data('action');
        if (action === 'reset') {
            resetContactForm();
        } else if (action === 'ok') {
            goToHomePage();
        }
    });
});
