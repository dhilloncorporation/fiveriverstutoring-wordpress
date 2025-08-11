@echo off
setlocal enabledelayedexpansion

REM Five Rivers Tutoring - Staging Environment Commands
REM This script provides easy commands for managing the staging environment

echo 🚀 Five Rivers Tutoring - Staging Environment Manager
echo ==================================================

if "%1"=="" goto usage

if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="logs" goto logs
if "%1"=="status" goto status
if "%1"=="build" goto build
if "%1"=="clean" goto clean
if "%1"=="db-backup" goto db-backup
if "%1"=="db-restore" goto db-restore
goto usage

:start
echo Starting staging environment...
docker-compose -f docker-compose.staging.yml --env-file env.staging up -d
echo ✅ Staging environment started!
echo 🌐 Access at: http://localhost:8083
goto end

:stop
echo Stopping staging environment...
docker-compose -f docker-compose.staging.yml down
echo ✅ Staging environment stopped!
goto end

:restart
echo Restarting staging environment...
docker-compose -f docker-compose.staging.yml --env-file env.staging down
docker-compose -f docker-compose.staging.yml --env-file env.staging up -d
echo ✅ Staging environment restarted!
echo 🌐 Access at: http://localhost:8083
goto end

:logs
echo Showing staging logs...
docker-compose -f docker-compose.staging.yml logs -f
goto end

:status
echo Checking staging environment status...
docker-compose -f docker-compose.staging.yml ps
goto end

:build
echo Building staging environment...
docker-compose -f docker-compose.staging.yml --env-file env.staging up -d --build
echo ✅ Staging environment built and started!
echo 🌐 Access at: http://localhost:8083
goto end

:clean
echo Cleaning staging environment...
docker-compose -f docker-compose.staging.yml down -v
docker system prune -f
echo ✅ Staging environment cleaned!
goto end

:db-backup
echo Creating staging database backup...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
docker exec fiverivertutoring-wp-staging mysqldump -h 192.168.50.158 -u fiverriversadmin -pPassword@123 fiveriverstutoring_staging_db > staging_backup_%datestamp%.sql
echo ✅ Staging database backup created!
goto end

:db-restore
if "%2"=="" (
    echo ❌ Please provide backup file: staging-commands.bat db-restore backup_file.sql
    goto end
)
echo Restoring staging database from %2...
docker exec -i fiverivertutoring-wp-staging mysql -h 192.168.50.158 -u fiverriversadmin -pPassword@123 fiveriverstutoring_staging_db < "%2"
echo ✅ Staging database restored!
goto end

:usage
echo Usage: %0 {start^|stop^|restart^|logs^|status^|build^|clean^|db-backup^|db-restore}
echo.
echo Commands:
echo   start      - Start staging environment
echo   stop       - Stop staging environment
echo   restart    - Restart staging environment
echo   logs       - Show staging logs
echo   status     - Check staging status
echo   build      - Build and start staging
echo   clean      - Clean staging environment
echo   db-backup  - Backup staging database
echo   db-restore - Restore staging database (requires backup file)
echo.
echo Examples:
echo   %0 start
echo   %0 db-backup
echo   %0 db-restore backup_20241227_143022.sql
goto end

:end
pause
