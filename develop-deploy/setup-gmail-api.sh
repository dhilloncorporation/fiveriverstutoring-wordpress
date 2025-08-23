#!/bin/bash

# Five Rivers Tutoring - Development Gmail API Setup Script
# This script sets up the Google API Client library for development

set -e

echo "🚀 Setting up Gmail API for Development Environment..."

# Check if we're in the right directory
if [ ! -d "../fiverivertutoring_wordpress" ]; then
    echo "❌ Error: fiverivertutoring_wordpress directory not found."
    echo "Please run this script from the develop-deploy/ directory."
    exit 1
fi

# Check if Composer is installed
if ! command -v composer &> /dev/null; then
    echo "❌ Error: Composer is not installed."
    echo "Please install Composer from https://getcomposer.org/"
    echo "Then run this script again."
    exit 1
fi

# Navigate to WordPress directory
cd ../fiverivertutoring_wordpress

echo "📦 Installing Google API Client library..."
composer require google/apiclient

echo "✅ Google API Client library installed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Restart your development Docker container:"
echo "     docker-compose -f develop-deploy/docker-compose.develop.yml restart"
echo "  2. Go to WordPress admin → Contact Us → Gmail API Settings"
echo "  3. Enter your Google OAuth2 credentials"
echo "  4. Test the Gmail API connection"
echo ""
echo "🎉 Gmail API is now ready for development!"
