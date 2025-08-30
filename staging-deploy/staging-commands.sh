#!/usr/bin/env bash

# Five Rivers Tutoring - Staging Environment Commands (Git Bash / Linux / macOS)
# Usage: ./staging-commands.sh {start|stop|restart|logs|status|build|clean|db-backup|db-restore}

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.staging.yml"
ENV_FILE="$SCRIPT_DIR/fiverivertutoring-wordpress-staging.properties"

# Detect compose command (docker-compose vs docker compose)
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD=(docker-compose)
else
    COMPOSE_CMD=(docker compose)
fi

ensure_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker CLI not found. Please install Docker Desktop and try again."
        exit 1
    fi
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Cannot connect to Docker daemon."
        echo "   - Start Docker Desktop"
        echo "   - Ensure the context is set correctly (e.g. 'desktop-linux')"
        echo "     Use: docker context ls && docker context use desktop-linux"
        exit 1
    fi
}

echo "🚀 Five Rivers Tutoring - Staging Environment Manager"
echo "=================================================="

cmd="${1:-}"

start() {
    echo "Starting staging environment..."
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    echo "✅ Staging environment started!"
    echo "🌐 Access at: http://localhost:8083"
}

stop() {
    echo "Stopping staging environment..."
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" down
    echo "✅ Staging environment stopped!"
}

restart() {
    echo "Restarting staging environment..."
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    echo "✅ Staging environment restarted!"
    echo "🌐 Access at: http://localhost:8083"
}

logs() {
    echo "Showing staging logs... (Ctrl+C to exit)"
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" logs -f
}

status() {
    echo "Checking staging environment status..."
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" ps
}

build() {
    echo "Building staging environment..."
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --build
    echo "✅ Staging environment built and started!"
    echo "🌐 Access at: http://localhost:8083"
}

clean() {
    echo "Cleaning staging environment..."
    ensure_docker
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" down -v
    docker system prune -f
    echo "✅ Staging environment cleaned!"
}

db_backup() {
    echo "Creating staging database backup..."
    datestamp="$(date +%Y%m%d_%H%M%S)"
    out_file="$SCRIPT_DIR/staging_backup_${datestamp}.sql"
    # Mirrors the .bat connection details
    docker exec fiverivertutoring-wp-staging \
        mysqldump -h 192.168.50.158 -u fiverriversadmin -pPassword@123 \
        fiveriverstutoring_staging_db > "$out_file"
    echo "✅ Staging database backup created: $out_file"
}

db_restore() {
    local backup_file="${1:-}"
    if [[ -z "$backup_file" ]]; then
        echo "❌ Please provide backup file: ./staging-commands.sh db-restore /path/to/backup.sql"
        exit 1
    fi
    echo "Restoring staging database from $backup_file..."
    docker exec -i fiverivertutoring-wp-staging \
        mysql -h 192.168.50.158 -u fiverriversadmin -pPassword@123 \
        fiveriverstutoring_staging_db < "$backup_file"
    echo "✅ Staging database restored!"
}

shell() {
    echo "Opening shell in staging container..."
    ensure_docker
    docker exec -it fiverivertutoring-wp-staging /bin/bash
}

usage() {
    cat <<USAGE
Usage: ./staging-commands.sh {start|stop|restart|logs|status|build|clean|db-backup|db-restore|shell}

Commands:
  start       - Start staging environment
  stop        - Stop staging environment
  restart     - Restart staging environment
  logs        - Show staging logs
  status      - Check staging status
  build       - Build and start staging
  clean       - Clean staging environment
  db-backup   - Backup staging database
  db-restore  - Restore staging database (requires backup file)
  shell       - Open shell in staging container

Examples:
  ./staging-commands.sh start
  ./staging-commands.sh db-backup
  ./staging-commands.sh db-restore "$SCRIPT_DIR/staging_backup_20250127_143022.sql"
  ./staging-commands.sh shell
USAGE
}

case "$cmd" in
    start) start ;;
    stop) stop ;;
    restart) restart ;;
    logs) logs ;;
    status) status ;;
    build) build ;;
    clean) clean ;;
    db-backup) db_backup ;;
    db-restore) shift || true; db_restore "${1:-}" ;;
    shell) shell ;;
    *) usage ;;
esac


