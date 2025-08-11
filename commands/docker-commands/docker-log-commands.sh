# DOCKER LOG COMMANDS FOR MONITORING
# ===================================


## Getting into Docker Container
docker exec -it fiverivers-wp-staging bash


# Check Production Logs
docker-compose -f docker-compose.prod.yml logs

# Follow Production Logs (Real-time)
docker-compose -f docker-compose.prod.yml logs -f

# Show Last 10 Lines
docker-compose -f docker-compose.prod.yml logs --tail 10

# Show Last 50 Lines
docker-compose -f docker-compose.prod.yml logs --tail 50

# Show Logs with Timestamps
docker-compose -f docker-compose.prod.yml logs -t

# Show Logs Since Container Started
docker logs --since 0 valueladder-wp-prod

# Show Logs Since Specific Time
docker logs --since "2024-01-01T00:00:00" valueladder-wp-prod

# Follow Logs for Specific Container
docker logs -f valueladder-wp-prod

# Show Last 20 Lines with Follow
docker logs -f --tail 20 valueladder-wp-prod

# Check Container Status
docker-compose -f docker-compose.prod.yml ps

# Check Container Health
docker inspect valueladder-wp-prod 