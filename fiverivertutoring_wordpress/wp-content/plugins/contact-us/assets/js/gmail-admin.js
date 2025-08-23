/**
 * Gmail Admin JavaScript for Contact Us Plugin
 * Handles admin interface interactions
 */

jQuery(document).ready(function($) {
    
    // Test Gmail API connection
    $('#test-gmail-btn').on('click', function() {
        var $btn = $(this);
        var $result = $('#gmail-test-result');
        var testEmail = $('#test-email-address').val();
        
        // Validate email address
        if (!testEmail || !testEmail.includes('@')) {
            $result.html('<div class="notice notice-error"><p>Please enter a valid email address.</p></div>');
            return;
        }
        
        // Check if AJAX object is available
        if (typeof gmail_admin_ajax === 'undefined') {
            $result.html('<div class="notice notice-error"><p>AJAX configuration error. Please refresh the page.</p></div>');
            return;
        }
        
        $btn.prop('disabled', true).text('Testing...');
        $result.html('<p>Testing Gmail API connection...</p>');
        
        // Add timeout to prevent infinite waiting
        var ajaxTimeout = setTimeout(function() {
            $result.html('<div class="notice notice-error"><p>Request timed out. Please try again.</p></div>');
            $btn.prop('disabled', false).text('📧 Send Test Email');
        }, 30000); // 30 second timeout
        
        $.ajax({
            url: gmail_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'test_gmail_connection',
                nonce: gmail_admin_ajax.nonce,
                test_email: testEmail
            },
            dataType: 'json',
            timeout: 25000, // 25 second timeout
            success: function(response) {
                clearTimeout(ajaxTimeout);
                
                // Handle different response formats
                var success = false;
                var message = '';
                
                if (response && typeof response === 'object') {
                    // Check if response has success property
                    if (response.hasOwnProperty('success')) {
                        success = response.success;
                    }
                    
                    // Try to extract message from different possible locations
                    if (response.data && response.data.message) {
                        message = response.data.message;
                    } else if (response.message) {
                        message = response.message;
                    } else if (response.data) {
                        message = response.data;
                    } else {
                        message = 'Response received but no message found';
                    }
                } else if (typeof response === 'string') {
                    // Response is a string
                    message = response;
                    success = true; // Assume success if it's a string
                } else {
                    // Unknown response format
                    message = 'Unknown response format received';
                    success = false;
                }
                
                if (success) {
                    $result.html('<div class="notice notice-success"><p>' + message + '</p></div>');
                    // Refresh page to update status
                    setTimeout(function() {
                        location.reload();
                    }, 2000);
                } else {
                    $result.html('<div class="notice notice-error"><p>' + message + '</p></div>');
                }
            },
            error: function(xhr, status, error) {
                clearTimeout(ajaxTimeout);
                $result.html('<div class="notice notice-error"><p>Failed to test connection. Please try again.</p></div>');
            },
            complete: function() {
                clearTimeout(ajaxTimeout);
                $btn.prop('disabled', false).text('📧 Send Test Email');
            }
        });
    });
    
    // Clear Gmail tokens and start fresh
    $('#clear-tokens-btn').on('click', function() {
        var $btn = $(this);
        
        if (!confirm('Are you sure you want to clear all Gmail API tokens? This will require you to re-authorize the application.')) {
            return;
        }
        
        $btn.prop('disabled', true).text('Clearing...');
        
        $.ajax({
            url: gmail_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'clear_gmail_tokens',
                nonce: gmail_admin_ajax.nonce
            },
            success: function(response) {
                if (response.success) {
                    // Show success message
                    var $notice = $('<div class="notice notice-success"><p>' + response.data + '</p></div>');
                    $('.wrap h1').after($notice);
                    
                    // Refresh page to update status
                    setTimeout(function() {
                        location.reload();
                    }, 2000);
                } else {
                    // Show error message
                    var $notice = $('<div class="notice notice-error"><p>' + response.data + '</p></div>');
                    $('.wrap h1').after($notice);
                }
            },
            error: function() {
                var $notice = $('<div class="notice notice-error"><p>Failed to clear tokens. Please try again.</p></div>');
                $('.wrap h1').after($notice);
            },
            complete: function() {
                $btn.prop('disabled', false).text('Clear Tokens & Start Fresh');
            }
        });
    });
    
    // Collapsible sections
    $('.section-toggle').on('click', function() {
        var $btn = $(this);
        var sectionId = $btn.data('section');
        var $content = $('#' + sectionId);
        var $icon = $btn.find('.toggle-icon');
        var $text = $btn.find('.toggle-text');
        
        if ($content.hasClass('expanded') || $content.is(':visible')) {
            // Collapse
            $content.removeClass('expanded').slideUp(300);
            $icon.text('▼');
            $text.text('Show Details');
            
            // Hide edit form and show credentials display
            if (sectionId === 'auth-section') {
                $('.credentials-display').hide();
                $('#edit-credentials-form').removeClass('show').hide();
            }
        } else {
            // Expand
            $content.addClass('expanded').slideDown(300);
            $icon.text('▲');
            $text.text('Hide Details');
            
            // Show edit form and hide credentials display
            if (sectionId === 'auth-section') {
                $('.credentials-display').hide();
                $('#edit-credentials-form').addClass('show').show();
            }
        }
    });
    
    // Initialize collapsible sections on page load
    function initializeCollapsibleSections() {
        
        $('.collapsible-content').each(function() {
            var $content = $(this);
            var sectionId = $content.attr('id');
            var $toggle = $('[data-section="' + sectionId + '"]');
            
            if ($toggle.length) {
                // Start collapsed
                $content.removeClass('expanded').hide();
                $toggle.find('.toggle-icon').text('▼');
                $toggle.find('.toggle-text').text('Show Details');
                
                // Make sure the toggle button is visible
                $toggle.show();
                
                // Hide edit form and credentials display by default
                if (sectionId === 'auth-section') {
                    $('.credentials-display').hide();
                    $('#edit-credentials-form').removeClass('show').hide();
                }
            }
        });
    }
    
    // Call initialization function
    setTimeout(function() {
        initializeCollapsibleSections();
    }, 100);
    
    // Edit credentials functionality
    $('#edit-credentials-btn').on('click', function() {
        var $btn = $(this);
        var $credentialsDisplay = $('.credentials-display');
        var $editForm = $('#edit-credentials-form');
        
        $credentialsDisplay.hide();
        $editForm.show();
        $btn.text('✏️ Editing...').prop('disabled', true);
    });
    
    $('#cancel-edit-btn').on('click', function() {
        var $credentialsDisplay = $('.credentials-display');
        var $editForm = $('#edit-credentials-form');
        var $editBtn = $('#edit-credentials-btn');
        
        $editForm.hide();
        $credentialsDisplay.show();
        $editBtn.text('✏️ Edit Credentials').prop('disabled', false);
    });
    
    // Force re-authorization
    $('#force-reauth-btn').on('click', function() {
        var $btn = $(this);
        
        if (!confirm('This will force a complete re-authorization. All existing tokens will be cleared. Continue?')) {
            return;
        }
        
        $btn.prop('disabled', true).text('Processing...');
        
        // First clear tokens
        $.ajax({
            url: gmail_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'clear_gmail_tokens',
                nonce: gmail_admin_ajax.nonce
            },
            success: function(response) {
                if (response.success) {
                    // Show success message and redirect to authorization
                    var $notice = $('<div class="notice notice-success"><p>Tokens cleared. Redirecting to authorization...</p></div>');
                    $('.wrap h1').after($notice);
                    
                    // Redirect to authorization page
                    setTimeout(function() {
                        location.reload();
                    }, 1500);
                } else {
                    var $notice = $('<div class="notice notice-error"><p>' + response.data + '</p></div>');
                    $('.wrap h1').after($notice);
                }
            },
            error: function() {
                var $notice = $('<div class="notice notice-error"><p>Failed to clear tokens. Please try again.</p></div>');
                $('.wrap h1').after($notice);
            },
            complete: function() {
                $btn.prop('disabled', false).text('🔐 Force Re-authorization');
            }
        });
    });
    
    // Refresh token functionality
    $('#refresh-token-btn').on('click', function() {
        var $btn = $(this);
        
        $btn.prop('disabled', true).text('Refreshing...');
        
        // Reload page to trigger token refresh
        setTimeout(function() {
            location.reload();
        }, 1000);
    });
    
    // Form validation
    $('form').on('submit', function(e) {
        var $form = $(this);
        var $clientId = $form.find('input[name*="client_id"]');
        var $clientSecret = $form.find('input[name*="client_secret"]');
        var $fromEmail = $form.find('input[name*="from_email"]');
        
        var errors = [];
        
        // Validate Client ID
        if ($clientId.length && !$clientId.val().trim()) {
            errors.push('Client ID is required');
            $clientId.addClass('error');
        } else {
            $clientId.removeClass('error');
        }
        
        // Validate Client Secret
        if ($clientSecret.length && !$clientSecret.val().trim()) {
            errors.push('Client Secret is required');
            $clientSecret.addClass('error');
        } else {
            $clientSecret.removeClass('error');
        }
        
        // Validate From Email
        if ($fromEmail.length && !$fromEmail.val().trim()) {
            errors.push('From Email is required');
            $fromEmail.addClass('error');
        } else if ($fromEmail.length && !isValidEmail($fromEmail.val())) {
            errors.push('From Email must be a valid email address');
            $fromEmail.addClass('error');
        } else {
            $fromEmail.removeClass('error');
        }
        
        if (errors.length > 0) {
            e.preventDefault();
            showErrors(errors);
            return false;
        }
        
        return true;
    });
    
    // Show validation errors
    function showErrors(errors) {
        var errorHtml = '<div class="notice notice-error"><ul>';
        errors.forEach(function(error) {
            errorHtml += '<li>' + error + '</li>';
        });
        errorHtml += '</ul></div>';
        
        $('.wrap h1').after(errorHtml);
        
        // Auto-hide errors after 5 seconds
        setTimeout(function() {
            $('.notice-error').fadeOut();
        }, 5000);
    }
    
    // Email validation
    function isValidEmail(email) {
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    // Remove error class on input
    $('input').on('input', function() {
        $(this).removeClass('error');
    });
    
    // Copy redirect URI to clipboard
    $('.copy-redirect-uri').on('click', function(e) {
        e.preventDefault();
        var redirectUri = $(this).data('uri');
        
        if (navigator.clipboard) {
            navigator.clipboard.writeText(redirectUri).then(function() {
                showCopySuccess();
            });
        } else {
            // Fallback for older browsers
            var textArea = document.createElement('textarea');
            textArea.value = redirectUri;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            showCopySuccess();
        }
    });
    
    // Show copy success message
    function showCopySuccess() {
        var $copyBtn = $('.copy-redirect-uri');
        var originalText = $copyBtn.text();
        
        $copyBtn.text('Copied!').addClass('copied');
        
        setTimeout(function() {
            $copyBtn.text(originalText).removeClass('copied');
        }, 2000);
    }
    
    // Auto-save settings
    var autoSaveTimer;
    $('input, select, textarea').on('change', function() {
        clearTimeout(autoSaveTimer);
        autoSaveTimer = setTimeout(function() {
            autoSaveSettings();
        }, 2000);
    });
    
    // Auto-save function
    function autoSaveSettings() {
        var $form = $('form');
        var formData = $form.serialize();
        
        $.ajax({
            url: gmail_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'auto_save_gmail_settings',
                nonce: gmail_admin_ajax.nonce,
                form_data: formData
            },
            success: function(response) {
                if (response.success) {
                    showAutoSaveSuccess();
                }
            }
        });
    }
    
    // Show auto-save success
    function showAutoSaveSuccess() {
        var $notice = $('<div class="notice notice-success auto-save-notice"><p>Settings auto-saved</p></div>');
        $('.wrap h1').after($notice);
        
        setTimeout(function() {
            $notice.fadeOut();
        }, 3000);
    }
    
    // Help tooltips
    $('.help-tooltip').on('click', function(e) {
        e.preventDefault();
        var helpText = $(this).data('help');
        
        if (helpText) {
            showHelpTooltip(helpText, $(this));
        }
    });
    
    // Show help tooltip
    function showHelpTooltip(text, $element) {
        var $tooltip = $('<div class="help-tooltip-popup">' + text + '</div>');
        $('body').append($tooltip);
        
        var elementPos = $element.offset();
        $tooltip.css({
            position: 'absolute',
            top: elementPos.top - $tooltip.outerHeight() - 10,
            left: elementPos.left,
            background: '#333',
            color: '#fff',
            padding: '10px',
            borderRadius: '4px',
            fontSize: '12px',
            maxWidth: '300px',
            zIndex: 9999
        });
        
        // Hide tooltip on click outside
        $(document).on('click.help-tooltip', function(e) {
            if (!$(e.target).closest('.help-tooltip-popup, .help-tooltip').length) {
                $tooltip.remove();
                $(document).off('click.help-tooltip');
            }
        });
    }
    
    // Initialize tooltips
    $('[data-help]').each(function() {
        $(this).addClass('help-tooltip');
    });
    
});
