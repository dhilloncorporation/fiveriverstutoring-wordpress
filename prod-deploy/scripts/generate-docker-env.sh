#!/bin/bash

# Generate Docker Environment File from Properties
# This script creates a clean, Docker-compatible .env file from the original properties file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROPERTIES_FILE="../properties/fiverivertutoring-wordpress.properties"
OUTPUT_ENV="../properties/fiverivertutoring-wordpress-clean.properties"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check if properties file exists
if [ ! -f "$PROPERTIES_FILE" ]; then
    print_error "Properties file not found: $PROPERTIES_FILE"
    exit 1
fi

print_header "Generating Docker Environment File"
print_status "Source: $PROPERTIES_FILE"
print_status "Output: $OUTPUT_ENV"

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_ENV")"

# Generate clean Docker environment file
print_status "Processing properties file..."

# Start with completely clean file (no comments)
cat > "$OUTPUT_ENV" << 'EOF'
EOF

# Extract WordPress-specific variables and clean them
print_status "Extracting WordPress environment variables..."

# Extract WORDPRESS_* variables and clean them
grep "^WORDPRESS_" "$PROPERTIES_FILE" | while IFS='=' read -r key value; do
    # Remove any trailing comments and spaces
    clean_value=$(echo "$value" | sed 's/[[:space:]]*#.*$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    echo "$key=$clean_value" >> "$OUTPUT_ENV"
done

# Extract WP_* variables
grep "^WP_" "$PROPERTIES_FILE" | while IFS='=' read -r key value; do
    clean_value=$(echo "$value" | sed 's/[[:space:]]*#.*$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    echo "$key=$clean_value" >> "$OUTPUT_ENV"
done

# Extract MYSQL_* variables
grep "^MYSQL_" "$PROPERTIES_FILE" | while IFS='=' read -r key value; do
    clean_value=$(echo "$value" | sed 's/[[:space:]]*#.*$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    echo "$key=$clean_value" >> "$OUTPUT_ENV"
done

# Add any additional essential variables
print_status "Adding essential Docker environment variables..."

# Ensure we have all required WordPress variables
if ! grep -q "^WORDPRESS_DB_HOST=" "$OUTPUT_ENV"; then
    print_warning "WORDPRESS_DB_HOST not found, adding default"
    echo "WORDPRESS_DB_HOST=34.116.96.136" >> "$OUTPUT_ENV"
fi

if ! grep -q "^WORDPRESS_DB_USER=" "$OUTPUT_ENV"; then
    print_warning "WORDPRESS_DB_USER not found, adding default"
    echo "WORDPRESS_DB_USER=fiverivertutoring_app" >> "$OUTPUT_ENV"
fi

if ! grep -q "^WORDPRESS_DB_PASSWORD=" "$OUTPUT_ENV"; then
    print_warning "WORDPRESS_DB_PASSWORD not found, adding default"
    echo "WORDPRESS_DB_PASSWORD=FiveRivers_App_Secure_2024!" >> "$OUTPUT_ENV"
fi

if ! grep -q "^WORDPRESS_DB_NAME=" "$OUTPUT_ENV"; then
    print_warning "WORDPRESS_DB_NAME not found, adding default"
    echo "WORDPRESS_DB_NAME=fiveriverstutoring_production_db" >> "$OUTPUT_ENV"
fi

# Show what was generated
print_status "Generated environment file contents:"
echo ""
cat "$OUTPUT_ENV"
echo ""

# Count variables
variable_count=$(grep -c "^[A-Z_]*=" "$OUTPUT_ENV")
print_success "Generated $OUTPUT_ENV with $variable_count environment variables"

print_status "File is ready for Docker --env-file usage"
print_status "You can now run: ./deploy.sh wp-deploy"
