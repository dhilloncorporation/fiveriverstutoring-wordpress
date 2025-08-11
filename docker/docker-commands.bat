@echo off
setlocal enabledelayedexpansion

REM Five Rivers Tutoring - Docker Management Commands
REM This script provides easy commands for managing Docker images and containers

echo 🐳 Five Rivers Tutoring - Docker Management
echo =========================================

if "%1"=="" goto usage

if "%1"=="build" goto build
if "%1"=="rebuild" goto rebuild
if "%1"=="clean" goto clean
if "%1"=="logs" goto logs
if "%1"=="shell" goto shell
if "%1"=="status" goto status
if "%1"=="push" goto push
if "%1"=="pull" goto pull
goto usage

:build
echo Building Five Rivers Tutoring WordPress image...
docker build -f Dockerfile -t fiverivertutoring-wordpress:latest ..
echo ✅ Docker image built successfully!
echo 📋 Image: fiverivertutoring-wordpress:latest
goto end

:rebuild
echo Rebuilding Five Rivers Tutoring WordPress image (no cache)...
docker build --no-cache -f Dockerfile -t fiverivertutoring-wordpress:latest ..
echo ✅ Docker image rebuilt successfully!
echo 📋 Image: fiverivertutoring-wordpress:latest
goto end

:clean
echo Cleaning Docker system...
echo Stopping all containers...
docker stop $(docker ps -aq) 2>nul
echo Removing all containers...
docker rm $(docker ps -aq) 2>nul
echo Removing all images...
docker rmi $(docker images -q) 2>nul
echo Removing all volumes...
docker volume rm $(docker volume ls -q) 2>nul
echo Removing all networks...
docker network rm $(docker network ls -q) 2>nul
echo Pruning system...
docker system prune -af
echo ✅ Docker system cleaned!
goto end

:logs
if "%2"=="" (
    echo Showing logs for fiverivertutoring-wordpress container...
    docker logs fiverivertutoring-wordpress
) else (
    echo Showing logs for container: %2
    docker logs %2
)
goto end

:shell
if "%2"=="" (
    echo Opening shell in fiverivertutoring-wordpress container...
    docker exec -it fiverivertutoring-wordpress /bin/bash
) else (
    echo Opening shell in container: %2
    docker exec -it %2 /bin/bash
)
goto end

:status
echo Checking Docker status...
echo.
echo 📊 Docker Images:
docker images | findstr fiverivertutoring
echo.
echo 📊 Running Containers:
docker ps | findstr fiverivertutoring
echo.
echo 📊 All Containers:
docker ps -a | findstr fiverivertutoring
echo.
echo 📊 Docker System Info:
docker system df
goto end

:push
echo Pushing Docker image to registry...
if "%2"=="" (
    echo ❌ Please provide registry tag: docker-commands.bat push registry/tag
    goto end
)
docker tag fiverivertutoring-wordpress:latest %2
docker push %2
echo ✅ Docker image pushed to %2
goto end

:pull
echo Pulling Docker image from registry...
if "%2"=="" (
    echo ❌ Please provide registry tag: docker-commands.bat pull registry/tag
    goto end
)
docker pull %2
docker tag %2 fiverivertutoring-wordpress:latest
echo ✅ Docker image pulled and tagged as fiverivertutoring-wordpress:latest
goto end

:usage
echo Usage: %0 {build^|rebuild^|clean^|logs^|shell^|status^|push^|pull}
echo.
echo Commands:
echo   build    - Build Docker image
echo   rebuild  - Rebuild Docker image (no cache)
echo   clean    - Clean all Docker containers, images, and volumes
echo   logs     - Show container logs
echo   shell    - Open shell in container
echo   status   - Show Docker status
echo   push     - Push image to registry (requires registry/tag)
echo   pull     - Pull image from registry (requires registry/tag)

goto end

:end
pause
