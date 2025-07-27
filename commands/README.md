# ValueLadder WordPress Docker Setup

A complete Docker-based WordPress development and production environment with multisite support, custom plugins, and persistent storage.

## 🚀 Features

- **WordPress Multisite** - Support for multiple sites
- **Custom Plugins** - EMI Calculators and other custom functionality
- **Dual Environment Setup** - Local development and production deployment
- **Persistent Storage** - Data survives container restarts
- **Production Ready** - Bundled image with all content included

## 📁 Project Structure

```
wp-content-fiverivers/
├── docker-compose.yml              # Production configuration
├── docker-compose.local.yml        # Local development configuration
├── docker-compose.prod.yml         # Production build configuration
├── Dockerfile                      # Production image definition
├── env.production                  # Production environment variables
├── valueladderfinance_wordpress/
│   ├── wp-content/
│   │   ├── plugins/
│   │   │   ├── emi-calculators-tools/  # Custom EMI calculator plugin
│   │   │   ├── advanced-import/
│   │   │   ├── elementor/
│   │   │   └── ...                    # Other plugins
│   │   ├── themes/
│   │   │   ├── blockskit-base/
│   │   │   ├── moneymind-finance-advisor/
│   │   │   └── ...                    # Other themes
│   │   └── uploads/                   # Media files
│   ├── config/
│   │   └── uploads.ini               # PHP upload configuration
│   └── wp-config.php                # WordPress configuration
└── README.md                       # This file
```

## 🛠️ Prerequisites

- Docker Desktop
- Docker Compose
- Git

## 🏃‍♂️ Quick Start

### Local Development

```bash
# Start local development environment
docker-compose -f docker-compose.local.yml up -d

# Access WordPress
# URL: http://localhost:8080
# Admin: http://localhost:8080/wp-admin/
```

### Production Deployment

```bash
# Build and run production image
docker-compose -f docker-compose.prod.yml --env-file env.production up -d --build

# Access production WordPress
# URL: http://localhost:8080
```

## 📋 Command Reference Files

The project includes organized command reference files for easy access:

### 1. `docker-build-commands.txt`
All commands for building your production image with different build options and tags.

**Key Commands:**
```bash
# Basic build
docker-compose -f docker-compose.prod.yml build

# Build with no cache
docker-compose -f docker-compose.prod.yml build --no-cache

# Build with environment variables
docker-compose -f docker-compose.prod.yml --env-file env.production build

docker build -t valueladder/wordpress-production:latest .
```

### 2. `docker-run-commands.txt`
Commands to run and manage containers with different deployment scenarios.

**Key Commands:**
```bash
# Start production container
docker-compose -f docker-compose.prod.yml --env-file env.production up -d

# Run container directly
docker run -d --name valueladder-wp-prod -p 8080:80 valueladder/wordpress-production:latest
```

### 3. `docker-log-commands.txt`
All monitoring and logging commands for real-time log following.

**Key Commands:**
```bash
# Follow production logs
docker-compose -f docker-compose.prod.yml logs -f

# Show last 10 lines
docker-compose -f docker-compose.prod.yml logs --tail 10
```

### 4. `docker-registry-commands.txt`
Push/pull to Docker registries and image management.

**Key Commands:**
```bash
# Tag for registry
docker tag valueladder/wordpress-production:latest your-registry/valueladder/wordpress-production:latest

# Push to registry
docker push your-registry/valueladder/wordpress-production:latest
```

### 5. `docker-workflow-commands.txt`
Complete development to production workflow with quick commands and cleanup.

**Key Commands:**
```bash
# Complete workflow (build and run)
docker-compose -f docker-compose.prod.yml --env-file env.production up -d --build

# Update production
docker-compose -f docker-compose.prod.yml --env-file env.production up -d --build --force-recreate
```

## 🔧 Configuration

### Environment Variables

Update `env.production` with your actual values:

```bash
WORDPRESS_DB_HOST=your-production-db-host
WORDPRESS_DB_USER=your-production-db-user
WORDPRESS_DB_PASSWORD=your-production-db-password
WORDPRESS_DB_NAME=your-production-db-name
WORDPRESS_HOME=https://your-domain.com
WORDPRESS_SITEURL=https://your-domain.com
```

### WordPress Configuration

The project includes custom WordPress configuration:
- **Multisite enabled** - Support for multiple sites
- **Custom upload limits** - Configured via `uploads.ini`
- **Debug settings** - Optimized for production

## 🏗️ Architecture

### Local Development
- **Bind Mounts** - Direct file access for development
- **Volume**: `./valueladderfinance_wordpress/wp-content:/var/www/html/wp-content`
- **Benefits**: Easy file editing, immediate changes

### Production Deployment
- **Bundled Image** - All content included in Docker image
- **Image**: `valueladder/wordpress-production:latest`
- **Benefits**: Self-contained, consistent, fast deployment

## 🔌 Custom Plugins

### EMI Calculators Tools
- **Location**: `valueladderfinance_wordpress/wp-content/plugins/emi-calculators-tools/`
- **Features**: EMI calculation, customizable styling
- **Configuration**: Settings in `default.php`

### Adding New Plugins
1. **Local Development**: Add to `./valueladderfinance_wordpress/wp-content/plugins/`
2. **Production**: Rebuild Docker image to include new plugins

## 🎨 Themes

### Available Themes
- **blockskit-base** - Base theme for development
- **moneymind-finance-advisor** - Finance-focused theme
- **blockskit-online-education** - Education theme

## 📊 Monitoring

### Health Checks
```bash
# Check container status
docker-compose -f docker-compose.prod.yml ps

# Check container health
docker inspect valueladder-wp-prod
```

### Logs
```bash
# Real-time logs
docker-compose -f docker-compose.prod.yml logs -f

# Historical logs
docker-compose -f docker-compose.prod.yml logs --tail 50
```

## 🚀 Deployment

### Local to Production Workflow

1. **Develop locally** using `docker-compose.local.yml`
2. **Test thoroughly** in local environment
3. **Build production image** with all content bundled
4. **Deploy to cloud** using production configuration
5. **Monitor logs** for any issues

### Cloud Deployment Steps

```bash
# 1. Update environment variables
nano env.production

# 2. Build production image
docker-compose -f docker-compose.prod.yml --env-file env.production build

# 3. Deploy to production
docker-compose -f docker-compose.prod.yml --env-file env.production up -d

# 4. Monitor deployment
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔒 Security

### Production Security Features
- **Debug disabled** - `WORDPRESS_DEBUG: 0`
- **Proper permissions** - Files owned by `www-data`
- **Environment variables** - Sensitive data externalized
- **HTTPS ready** - Configured for SSL certificates

## 🛠️ Troubleshooting

### Common Issues

#### Permission Errors
```bash
# Fix permissions in container
docker exec -it valueladder-wp-prod chown -R www-data:www-data /var/www/html/wp-content
```

#### Database Connection Issues
- Verify database credentials in `env.production`
- Check database server accessibility
- Ensure database exists

#### Container Won't Start
```