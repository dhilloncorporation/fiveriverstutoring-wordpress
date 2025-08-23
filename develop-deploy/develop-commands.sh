#!/bin/bash

# Five Rivers Tutoring - Development Environment Commands
# This script provides easy commands for managing the development environment

# Function definitions
usage() {
    echo "Usage: $0 {start|stop|restart|logs|status|build|clean|db-backup|db-restore|shell|wp-cli}"
    echo ""
    echo "Commands:"
    echo "  start      - Start development environment"
    echo "  stop       - Stop development environment"
    echo "  restart    - Restart development environment"
    echo "  logs       - Show development logs"
    echo "  status     - Check development status"
    echo "  build      - Build and start development"
    echo "  clean      - Clean development environment"
    echo "  shell      - Open shell in development container"
    echo "  wp-cli     - Run WP-CLI command (requires command)"
    echo "  db-backup  - Backup development database"
    echo "  db-restore - Restore development database (requires backup file)"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 wp-cli \"plugin list\""
    echo "  $0 wp-cli \"plugin install contact-form-7 --activate\""
    echo "  $0 db-backup"
    echo "  $0 db-restore backup_20241227_143022.sql"
}

start_env() {
    echo "Starting development environment..."
    docker-compose -f docker-compose.develop.yml up -d
    echo "✅ Development environment started!"
    echo "🌐 Access at: http://localhost:8082"
    echo "🔧 Admin at: http://localhost:8082/wp-admin"
}

stop_env() {
    echo "Stopping development environment..."
    docker-compose -f docker-compose.develop.yml down
    echo "✅ Development environment stopped!"
}

restart_env() {
    echo "Restarting development environment..."
    docker-compose -f docker-compose.develop.yml down
    docker-compose -f docker-compose.develop.yml up -d
    echo "✅ Development environment restarted!"
    echo "🌐 Access at: http://localhost:8082"
    echo "🔧 Admin at: http://localhost:8082/wp-admin"
}

show_logs() {
    echo "Showing development logs..."
    docker-compose -f docker-compose.develop.yml logs -f
}

show_status() {
    echo "Checking development environment status..."
    docker-compose -f docker-compose.develop.yml ps
}

build_env() {
    echo "Building development environment..."
    docker-compose -f docker-compose.develop.yml up -d --build
    echo "✅ Development environment built and started!"
    echo "🌐 Access at: http://localhost:8082"
    echo "🔧 Admin at: http://localhost:8082/wp-admin"
}

clean_env() {
    echo "Cleaning development environment..."
    docker-compose -f docker-compose.develop.yml down -v
    docker system prune -f
    echo "✅ Development environment cleaned!"
}

open_shell() {
    echo "Opening shell in development container..."
    docker exec -it fiverivertutoring-wp-local /bin/bash
}

run_wp_cli() {
    if [ -z "$1" ]; then
        echo "❌ Please provide WP-CLI command: ./develop-commands.sh wp-cli \"plugin list\""
        exit 1
    fi
    echo "Running WP-CLI command: $1"
    docker exec -it fiverivertutoring-wp-local wp "$1"
}

backup_db() {
    echo "Creating development database backup..."
    datestamp=$(date +"%Y%m%d_%H%M%S")
    docker exec fiverivertutoring-wp-local mysqldump -h 192.168.50.158 -u fiverriversadmin -pPassword@123 fiveriverstutoring_db > "develop_backup_${datestamp}.sql"
    echo "✅ Development database backup created!"
}

restore_db() {
    if [ -z "$1" ]; then
        echo "❌ Please provide backup file: ./develop-commands.sh db-restore backup_file.sql"
        exit 1
    fi
    echo "Restoring development database from $1..."
    docker exec -i fiverivertutoring-wp-local mysql -h 192.168.50.158 -u fiverriversadmin -pPassword@123 fiveriverstutoring_db < "$1"
    echo "✅ Development database restored!"
}

# Main script logic
echo "🚀 Five Rivers Tutoring - Development Environment Manager"
echo "====================================================="

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    "start")
        start_env
        ;;
    "stop")
        stop_env
        ;;
    "restart")
        restart_env
        ;;
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "build")
        build_env
        ;;
    "clean")
        clean_env
        ;;
    "db-backup")
        backup_db
        ;;
    "db-restore")
        restore_db "$2"
        ;;
    "shell")
        open_shell
        ;;
    "wp-cli")
        run_wp_cli "$2"
        ;;
    *)
        usage
        exit 1
        ;;
esac
