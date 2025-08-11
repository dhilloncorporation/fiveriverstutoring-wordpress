# DOCKER BUILD COMMANDS FOR PRODUCTION
# ======================================

# Basic Build
docker-compose -f docker-compose.prod.yml build

# Build with No Cache (Fresh Build)
docker-compose -f docker-compose.prod.yml build --no-cache

# Build with Environment Variables
docker-compose -f docker-compose.prod.yml --env-file gcp-production-env.properties build

# Build Using Docker Directly
docker build -t valueladder/wordpress-production:latest .

# Build with Different Tag
docker build -t valueladder/wordpress-production:v1.0 .

# Build with Specific Version
docker build -t valueladder/wordpress-production:$(date +%Y%m%d) .

# Build and Run in One Command
docker-compose -f docker-compose.prod.yml --env-file gcp-production-env.properties up -d --build 