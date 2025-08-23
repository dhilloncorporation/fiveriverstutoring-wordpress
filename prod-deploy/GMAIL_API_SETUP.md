# Gmail API Setup for Production

This document explains how to set up Gmail API integration in the production environment.

## **Overview**

The production environment uses a custom Docker image (`fiverivertutoring:production`) that includes:
- WordPress core
- Custom themes and plugins
- Google API Client library (via Composer)
- Gmail API integration

## **Prerequisites**

1. **Google Cloud Console Setup:**
   - Gmail API enabled
   - OAuth2 credentials created
   - Redirect URI: `https://fiverivertutoring.com/?contact_us_oauth=callback`

2. **Docker Image Built:**
   - Custom image with Google API Client library
   - Tagged as `fiverivertutoring:production`

## **Deployment Steps**

### **1. Build Production Image**

```bash
# From project root
cd docker
./build-image.sh

# Verify image was created
docker images fiverivertutoring:production
```

### **2. Deploy to Production**

```bash
# From prod-deploy directory
terraform apply -var-file="wordpress.tfvars"
```

### **3. Configure Gmail API**

1. **Access WordPress Admin:**
   - URL: `https://fiverivertutoring.com/wp-admin`
   - Navigate to: Contact Us → Gmail API Settings

2. **Enter OAuth2 Credentials:**
   - Client ID
   - Client Secret
   - From Email (your Gmail address)
   - From Name

3. **Authorize Gmail Access:**
   - Click "Authorize Gmail Access"
   - Complete OAuth2 flow
   - Verify connection

## **Environment Variables**

The production environment should have these WordPress constants:

```php
// Gmail API Configuration (optional - can be set via admin)
define('CONTACT_US_GMAIL_ENABLED', true);
define('CONTACT_US_GMAIL_CLIENT_ID', 'your-client-id');
define('CONTACT_US_GMAIL_CLIENT_SECRET', 'your-client-secret');
```

## **Testing**

1. **Test Contact Form:**
   - Use shortcode: `[contact_us_form]`
   - Submit test message
   - Verify email delivery

2. **Test Gmail API:**
   - Admin → Contact Us → Gmail API Settings
   - Click "Test Gmail API Connection"
   - Verify test email is sent

## **Monitoring**

- **Logs:** Check WordPress debug log for Gmail API activity
- **Status:** Monitor Gmail API status in admin panel
- **Emails:** Verify contact form submissions are received

## **Troubleshooting**

### **Common Issues:**

1. **OAuth2 Redirect URI Mismatch:**
   - Ensure redirect URI in Google Console matches exactly
   - Check for trailing slashes or protocol differences

2. **Google Client Library Not Found:**
   - Verify Docker image includes Google API Client
   - Check Composer installation in image

3. **Permission Denied:**
   - Verify OAuth2 scopes include `https://www.googleapis.com/auth/gmail.send`
   - Check Gmail API is enabled in Google Console

## **Security Notes**

- OAuth2 credentials are stored in WordPress options (encrypted)
- Access tokens are automatically refreshed
- No sensitive data is logged
- HTTPS is required for production OAuth2

## **Support**

For issues with Gmail API setup:
1. Check WordPress debug logs
2. Verify Google Console configuration
3. Test OAuth2 flow manually
4. Contact system administrator

