# COMPLETE DOCKER WORKFLOW COMMANDS
# ==================================

# DEVELOPMENT WORKFLOW
# --------------------

# Start Local Development
docker-compose -f docker-compose.local.yml up -d
docker-compose -f docker-compose.local.yml logs -f
docker-compose -f docker-compose.local.yml down

# PRODUCTION WORKFLOW
# -------------------

# 1. Update Environment Variables
# Edit env.production with your actual values

# 2. Build Production Image
docker-compose -f docker-compose.prod.yml --env-file env.production build

# 3. Run Production Container
docker-compose -f docker-compose.prod.yml --env-file env.production up -d

# 4. Check Production Logs
docker-compose -f docker-compose.prod.yml logs -f

# 5. Stop Production Container
docker-compose -f docker-compose.prod.yml down

# QUICK COMMANDS
# --------------

# Build and Run Production (One Command)
docker-compose -f docker-compose.prod.yml --env-file env.production up -d --build

# Restart Production
docker-compose -f docker-compose.prod.yml restart

# Update Production (Rebuild and Restart)
docker-compose -f docker-compose.prod.yml --env-file env.production up -d --build --force-recreate

# CLEANUP COMMANDS
# ----------------

# Remove All Containers
docker-compose -f docker-compose.prod.yml down --rmi all --volumes --remove-orphans

# Clean Docker System
docker system prune -a

# Remove Unused Images
docker image prune -a 