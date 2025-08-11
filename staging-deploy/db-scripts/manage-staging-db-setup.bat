@echo off
setlocal enabledelayedexpansion

REM Five Rivers Tutoring - Staging Database Setup Script
REM This script sets up the staging database using develop database as source

echo 🗄️ Five Rivers Tutoring - Staging Database Setup
echo ================================================

REM Database configuration - Load from env.staging
for /f "tokens=1,* delims==" %%a in ('type ..\env.staging ^| findstr /v "^#" ^| findstr /v "^$"') do (
    set "%%a=%%b"
)

REM SQL script paths
set BASIC_SETUP=fiveriverstutoring_staging_db.sql

if "%1"=="" goto usage

if "%1"=="basic" goto basic
if "%1"=="copy-develop" goto copy-develop
if "%1"=="copy-production" goto copy-production
if "%1"=="reset" goto reset
if "%1"=="verify" goto verify
if "%1"=="backup" goto backup
if "%1"=="restore" goto restore
if "%1"=="workflow" goto workflow
goto usage

:basic
echo Setting up basic staging database...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% < %BASIC_SETUP%
echo ✅ Basic staging database setup complete!
goto end

:copy-develop
echo Copying develop database to staging...

REM Create backup of current staging (if exists)
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "USE %STAGING_DB%;" >nul 2>&1
if %errorlevel%==0 (
    echo Backing up current staging database...
    for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
    set "YY=!dt:~2,2!" & set "YYYY=!dt:~0,4!" & set "MM=!dt:~4,2!" & set "DD=!dt:~6,2!"
    set "HH=!dt:~8,2!" & set "Min=!dt:~10,2!" & set "Sec=!dt:~12,2!"
    set "datestamp=!YYYY!!MM!!DD!_!HH!!Min!!Sec!"
    mysqldump -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% > staging_backup_!datestamp!.sql
)

REM Drop staging database if exists
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "DROP DATABASE IF EXISTS %STAGING_DB%;"

REM Create new staging database
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "CREATE DATABASE %STAGING_DB%;"

REM Copy develop data to staging
echo Copying develop database to staging...
mysqldump -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %DEVELOP_DB% | mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB%

REM Update staging URLs - DISABLED: Let entrypoint.sh handle URL conversion
REM echo Updating staging URLs...
REM mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_options SET option_value = 'http://localhost:8083' WHERE option_name IN ('home', 'siteurl');"
REM mysql -h %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8082', 'localhost:8083');"
REM mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_posts SET guid = REPLACE(guid, 'your-production-domain.com', 'localhost:8083');"
REM mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_posts SET guid = REPLACE(guid, 'your-staging-domain.com', 'localhost:8083');"

echo ✅ Develop database copied to staging!
echo 🌐 Staging site will be available at: http://localhost:8083
echo 📊 All your develop posts, plugins, and content are now in staging
goto end

:copy-production
echo Copying production database to staging...

REM Create backup of current staging (if exists)
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "USE %STAGING_DB%;" >nul 2>&1
if %errorlevel%==0 (
    echo Backing up current staging database...
    for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
    set "YY=!dt:~2,2!" & set "YYYY=!dt:~0,4!" & set "MM=!dt:~4,2!" & set "DD=!dt:~6,2!"
    set "HH=!dt:~8,2!" & set "Min=!dt:~10,2!" & set "Sec=!dt:~12,2!"
    set "datestamp=!YYYY!!MM!!DD!_!HH!!Min!!Sec!"
    mysqldump -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% > staging_backup_!datestamp!.sql
)

REM Drop staging database if exists
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "DROP DATABASE IF EXISTS %STAGING_DB%;"

REM Create new staging database
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "CREATE DATABASE %STAGING_DB%;"

REM Copy production data to staging
echo Copying production data to staging...
mysqldump -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %PRODUCTION_DB% | mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB%

REM Update staging URLs
echo Updating staging URLs...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_options SET option_value = 'http://localhost:8083' WHERE option_name IN ('home', 'siteurl');"
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_posts SET guid = REPLACE(guid, 'localhost:8082', 'localhost:8083');"
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% -e "UPDATE wp_posts SET guid = REPLACE(guid, 'your-production-domain.com', 'localhost:8083');"

echo ✅ Production database copied to staging!
echo 🌐 Staging site will be available at: http://localhost:8083
goto end

:reset
echo Resetting staging database...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "DROP DATABASE IF EXISTS %STAGING_DB%;"
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "CREATE DATABASE %STAGING_DB%;"
echo ✅ Staging database reset complete!
goto end

:verify
echo Verifying staging database...

REM First, try to set up the database using the script
echo Setting up database structure...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% < %BASIC_SETUP% >nul 2>&1
if %errorlevel% neq 0 echo Database setup completed or user already exists

REM Now verify the database
echo.
echo Database verification results:
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "USE %STAGING_DB%; SELECT 'Database exists' as status; SHOW TABLES; SELECT COUNT(*) as total_posts FROM wp_posts; SELECT COUNT(*) as total_users FROM wp_users; SELECT option_value as site_url FROM wp_options WHERE option_name = 'siteurl'; SELECT option_value as blog_name FROM wp_options WHERE option_name = 'blogname';" 2>nul
if %errorlevel% neq 0 echo Database verification failed - may need to create database first
goto end

:backup
echo Creating staging database backup...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "USE %STAGING_DB%;" >nul 2>&1
if %errorlevel%==0 (
    for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
    set "YY=!dt:~2,2!" & set "YYYY=!dt:~0,4!" & set "MM=!dt:~4,2!" & set "DD=!dt:~6,2!"
    set "HH=!dt:~8,2!" & set "Min=!dt:~10,2!" & set "Sec=!dt:~12,2!"
    set "datestamp=!YYYY!!MM!!DD!_!HH!!Min!!Sec!"
    mysqldump -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% > staging_backup_!datestamp!.sql
    echo ✅ Staging database backup created!
) else (
    echo ❌ Staging database does not exist!
)
goto end

:restore
if "%2"=="" (
    echo ❌ Please provide backup file: staging-db-setup.bat restore backup_file.sql
    goto end
)
echo Restoring staging database from %2...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %STAGING_DB% < "%2"
echo ✅ Staging database restored!
goto end

:workflow
echo 🚀 Five Rivers Tutoring - Development Workflow
echo ==============================================
echo.
echo Recommended workflow:
echo 1. Develop → Staging → Production
echo.
echo Step 1: Copy develop to staging
echo   staging-db-setup.bat copy-develop
echo.
echo Step 2: Start staging environment
echo   staging-commands.bat start
echo.
echo Step 3: Test at http://localhost:8083
echo.
echo Step 4: When ready, deploy to production
echo   (Production deployment commands)
echo.
echo Step 5: Copy staging to production
echo   staging-db-setup.bat copy-staging-to-production
goto end

:usage
echo Usage: %0 {basic^|copy-develop^|copy-production^|reset^|verify^|backup^|restore^|workflow}
echo.
echo Commands:
echo   basic           - Create basic staging database (structure only)
echo   copy-develop    - Copy develop database to staging (RECOMMENDED)
echo   copy-production - Copy production database to staging
echo   reset           - Reset staging database (drop and recreate)
echo   verify          - Verify staging database status
echo   backup          - Create staging database backup
echo   restore         - Restore staging database from backup file
echo   workflow        - Show recommended development workflow
echo.
echo Examples:
echo   %0 copy-develop
echo   %0 verify
echo   %0 restore staging_backup_20241227_143022.sql
echo.
echo Recommended workflow:
echo   1. %0 copy-develop  # Copy develop data
echo   2. staging-commands.bat start         # Start staging environment
echo   3. Test your changes at http://localhost:8083
echo   4. Deploy to production when ready
goto end

:end
pause
