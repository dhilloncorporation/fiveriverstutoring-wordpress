@echo off
REM Five Rivers Tutoring - Development Gmail API Setup Script
REM This script sets up the Google API Client library for development

echo 🚀 Setting up Gmail API for Development Environment...

REM Check if we're in the right directory
if not exist "..\fiverivertutoring_wordpress" (
    echo ❌ Error: fiverivertutoring_wordpress directory not found.
    echo Please run this script from the develop-deploy\ directory.
    pause
    exit /b 1
)

REM Check if Composer is installed
composer --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Composer is not installed.
    echo Please install Composer from https://getcomposer.org/
    echo Then run this script again.
    pause
    exit /b 1
)

REM Navigate to WordPress directory
cd ..\fiverivertutoring_wordpress

echo 📦 Installing Google API Client library...
composer require google/apiclient

echo ✅ Google API Client library installed successfully!
echo.
echo 📋 Next steps:
echo   1. Restart your development Docker container:
echo      docker-compose -f develop-deploy\docker-compose.develop.yml restart
echo   2. Go to WordPress admin → Contact Us → Gmail API Settings
echo   3. Enter your Google OAuth2 credentials
echo   4. Test the Gmail API connection
echo.
echo 🎉 Gmail API is now ready for development!
pause

