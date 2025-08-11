@echo off
setlocal enabledelayedexpansion

REM Five Rivers Tutoring - Development Environment Commands
REM This script provides easy commands for managing the development environment

echo 🚀 Five Rivers Tutoring - Development Environment Manager
echo =====================================================

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
if "%1"=="shell" goto shell
if "%1"=="wp-cli" goto wp-cli
goto usage

:start
echo Starting development environment...
docker-compose -f docker-compose.develop.yml up -d
echo ✅ Development environment started!
echo 🌐 Access at: http://localhost:8082
echo 🔧 Admin at: http://localhost:8082/wp-admin
goto end

:stop
echo Stopping development environment...
docker-compose -f docker-compose.develop.yml down
echo ✅ Development environment stopped!
goto end

:restart
echo Restarting development environment...
docker-compose -f docker-compose.develop.yml down
docker-compose -f docker-compose.develop.yml up -d
echo ✅ Development environment restarted!
echo 🌐 Access at: http://localhost:8082
echo 🔧 Admin at: http://localhost:8082/wp-admin
goto end

:logs
echo Showing development logs...
docker-compose -f docker-compose.develop.yml logs -f
goto end

:status
echo Checking development environment status...
docker-compose -f docker-compose.develop.yml ps
goto end

:build
echo Building development environment...
docker-compose -f docker-compose.develop.yml up -d --build
echo ✅ Development environment built and started!
echo 🌐 Access at: http://localhost:8082
echo 🔧 Admin at: http://localhost:8082/wp-admin
goto end

:clean
echo Cleaning development environment...
docker-compose -f docker-compose.develop.yml down -v
docker system prune -f
echo ✅ Development environment cleaned!
goto end

:shell
echo Opening shell in development container...
docker exec -it fiverivertutoring-wp-local /bin/bash
goto end

:wp-cli
if "%2"=="" (
    echo ❌ Please provide WP-CLI command: develop-commands.bat wp-cli "plugin list"
    goto end
)
echo Running WP-CLI command: %2
docker exec -it fiverivertutoring-wp-local wp %2
goto end

:db-backup
echo Creating development database backup...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
docker exec fiverivertutoring-wp-local mysqldump -h 192.168.50.158 -u fiverriversadmin -pPassword@123 fiveriverstutoring_db > develop_backup_%datestamp%.sql
echo ✅ Development database backup created!
goto end

:db-restore
if "%2"=="" (
    echo ❌ Please provide backup file: develop-commands.bat db-restore backup_file.sql
    goto end
)
echo Restoring development database from %2...
docker exec -i fiverivertutoring-wp-local mysql -h 192.168.50.158 -u fiverriversadmin -pPassword@123 fiveriverstutoring_db < "%2"
echo ✅ Development database restored!
goto end

:usage
echo Usage: %0 {start^|stop^|restart^|logs^|status^|build^|clean^|db-backup^|db-restore^|shell^|wp-cli}
echo.
echo Commands:
echo   start      - Start development environment
echo   stop       - Stop development environment
echo   restart    - Restart development environment
echo   logs       - Show development logs
echo   status     - Check development status
echo   build      - Build and start development
echo   clean      - Clean development environment
echo   shell      - Open shell in development container
echo   wp-cli     - Run WP-CLI command (requires command)
echo   db-backup  - Backup development database
echo   db-restore - Restore development database (requires backup file)
echo.
echo Examples:
echo   %0 start
echo   %0 wp-cli "plugin list"
echo   %0 wp-cli "plugin install contact-form-7 --activate"
echo   %0 db-backup
echo   %0 db-restore backup_20241227_143022.sql
goto end

:end
pause
