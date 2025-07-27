/**
 * Five Rivers Tutoring Scheduler - Frontend JavaScript
 * Mobile optimized with localStorage support
 */

(function($) {
    'use strict';
    
    // Initialize when document is ready
    $(document).ready(function() {
        initTutoringScheduler();
    });
    
    function initTutoringScheduler() {
        const $form = $('#tutoring-booking-form');
        const $confirmation = $('#booking-confirmation');
        const $details = $('#booking-details');
        
        if (!$form.length) return;
        
        // Set minimum date to today
        setMinimumDate();
        
        // Handle form submission
        $form.on('submit', function(e) {
            e.preventDefault();
            handleFormSubmission();
        });
        
        // Real-time validation
        $form.find('input, select, textarea').on('blur', function() {
            validateField($(this));
        });
        
        // Load existing bookings from localStorage
        loadExistingBookings();
    }
    
    function setMinimumDate() {
        const today = new Date().toISOString().split('T')[0];
        $('#date').attr('min', today);
    }
    
    function validateField($field) {
        const fieldName = $field.attr('name');
        const value = $field.val().trim();
        const $formGroup = $field.closest('.form-group');
        
        // Remove existing error states
        $formGroup.removeClass('error');
        $formGroup.find('.error-message').remove();
        
        // Validate required fields
        if ($field.prop('required') && !value) {
            showFieldError($field, 'This field is required');
            return false;
        }
        
        // Validate email
        if (fieldName === 'contact_email' && value) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) {
                showFieldError($field, 'Please enter a valid email address');
                return false;
            }
        }
        
        // Validate date
        if (fieldName === 'date' && value) {
            const selectedDate = new Date(value);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            if (selectedDate < today) {
                showFieldError($field, 'Please select a future date');
                return false;
            }
        }
        
        return true;
    }
    
    function showFieldError($field, message) {
        const $formGroup = $field.closest('.form-group');
        $formGroup.addClass('error');
        $formGroup.append('<div class="error-message">' + message + '</div>');
    }
    
    function validateForm() {
        let isValid = true;
        const $form = $('#tutoring-booking-form');
        
        $form.find('input, select, textarea').each(function() {
            if (!validateField($(this))) {
                isValid = false;
            }
        });
        
        return isValid;
    }
    
    function handleFormSubmission() {
        const $form = $('#tutoring-booking-form');
        const $submitBtn = $form.find('.booking-submit-btn');
        
        // Validate form
        if (!validateForm()) {
            return;
        }
        
        // Show loading state
        $form.addClass('loading');
        $submitBtn.prop('disabled', true);
        
        // Collect form data
        const formData = {
            action: 'book_tutoring_session',
            nonce: fiverivers_ajax.nonce,
            student_name: $('#student_name').val().trim(),
            subject: $('#subject').val(),
            date: $('#date').val(),
            time: $('#time').val(),
            contact_email: $('#contact_email').val().trim(),
            notes: $('#notes').val().trim()
        };
        
        // Submit via AJAX
        $.ajax({
            url: fiverivers_ajax.ajax_url,
            type: 'POST',
            data: formData,
            success: function(response) {
                if (response.success) {
                    // Store booking in localStorage
                    saveBookingToLocalStorage(response.booking_data);
                    
                    // Show confirmation
                    showBookingConfirmation(response.booking_data);
                    
                    // Reset form
                    $form[0].reset();
                    setMinimumDate();
                } else {
                    showErrorMessage('An error occurred. Please try again.');
                }
            },
            error: function() {
                showErrorMessage('Network error. Please check your connection and try again.');
            },
            complete: function() {
                // Remove loading state
                $form.removeClass('loading');
                $submitBtn.prop('disabled', false);
            }
        });
    }
    
    function saveBookingToLocalStorage(bookingData) {
        try {
            const existingBookings = JSON.parse(localStorage.getItem('fiverivers_bookings') || '[]');
            existingBookings.push({
                ...bookingData,
                created_at: new Date().toISOString()
            });
            localStorage.setItem('fiverivers_bookings', JSON.stringify(existingBookings));
        } catch (error) {
            console.error('Error saving booking to localStorage:', error);
        }
    }
    
    function loadExistingBookings() {
        try {
            const bookings = JSON.parse(localStorage.getItem('fiverivers_bookings') || '[]');
            if (bookings.length > 0) {
                console.log('Found', bookings.length, 'existing bookings');
            }
        } catch (error) {
            console.error('Error loading bookings from localStorage:', error);
        }
    }
    
    function showBookingConfirmation(bookingData) {
        const $confirmation = $('#booking-confirmation');
        const $details = $('#booking-details');
        
        // Format the booking details
        const subjectLabels = {
            'high_school_math': 'High School Math (Years 6-10)',
            'vce_physics': 'VCE Physics',
            'vce_general': 'VCE General Mathematics',
            'exam_prep': 'Exam Preparation',
            'homework_help': 'Homework Help'
        };
        
        const detailsHtml = `
            <h4>Booking Details</h4>
            <div class="booking-detail">
                <span class="booking-detail-label">Student:</span>
                <span class="booking-detail-value">${bookingData.student_name}</span>
            </div>
            <div class="booking-detail">
                <span class="booking-detail-label">Subject:</span>
                <span class="booking-detail-value">${subjectLabels[bookingData.subject] || bookingData.subject}</span>
            </div>
            <div class="booking-detail">
                <span class="booking-detail-label">Date:</span>
                <span class="booking-detail-value">${formatDate(bookingData.date)}</span>
            </div>
            <div class="booking-detail">
                <span class="booking-detail-label">Time:</span>
                <span class="booking-detail-value">${formatTime(bookingData.time)}</span>
            </div>
            <div class="booking-detail">
                <span class="booking-detail-label">Email:</span>
                <span class="booking-detail-value">${bookingData.contact_email}</span>
            </div>
            <div class="booking-detail">
                <span class="booking-detail-label">Booking ID:</span>
                <span class="booking-detail-value">${bookingData.booking_id}</span>
            </div>
        `;
        
        $details.html(detailsHtml);
        $confirmation.show();
        
        // Scroll to confirmation
        $('html, body').animate({
            scrollTop: $confirmation.offset().top - 50
        }, 500);
        
        // Hide form
        $('#tutoring-booking-form').hide();
    }
    
    function formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-AU', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }
    
    function formatTime(timeString) {
        const [hours, minutes] = timeString.split(':');
        const hour = parseInt(hours);
        const ampm = hour >= 12 ? 'PM' : 'AM';
        const displayHour = hour > 12 ? hour - 12 : hour === 0 ? 12 : hour;
        return `${displayHour}:${minutes} ${ampm}`;
    }
    
    function showErrorMessage(message) {
        const $form = $('#tutoring-booking-form');
        const $errorDiv = $('<div class="error-message" style="margin-top: 10px; text-align: center; color: #f44336;">' + message + '</div>');
        
        // Remove existing error messages
        $form.find('.error-message').remove();
        
        // Add new error message
        $form.append($errorDiv);
        
        // Auto-remove after 5 seconds
        setTimeout(function() {
            $errorDiv.fadeOut(function() {
                $(this).remove();
            });
        }, 5000);
    }
    
    // Mobile-specific enhancements
    function enhanceMobileExperience() {
        // Prevent zoom on input focus (iOS)
        const $inputs = $('input, select, textarea');
        $inputs.on('focus', function() {
            if (/iPhone|iPad|iPod/.test(navigator.userAgent)) {
                $(this).css('font-size', '16px');
            }
        });
        
        // Smooth scrolling for iOS
        if (/iPhone|iPad|iPod/.test(navigator.userAgent)) {
            $('html').css('-webkit-overflow-scrolling', 'touch');
        }
    }
    
    // Initialize mobile enhancements
    enhanceMobileExperience();
    
})(jQuery); 