# Five Rivers Tutoring - Staging Environment

A staging environment for testing code and database changes before production deployment.

## 🎯 Purpose

The staging environment allows you to:
- **Test code changes** before production
- **Test database migrations** safely
- **Preview new features** in a production-like environment
- **Debug issues** without affecting live site
- **Train team members** on new features

## 📁 Files

- `docker-compose.staging.yml` - Staging Docker configuration
- `env.staging` - Staging environment variables
- `staging-commands.sh` - Easy management commands
- `staging-db-setup.sh` - Database management commands
- `README.md` - This documentation

## 🚀 Quick Start

### 1. Set up Staging Database
```bash
cd staging-deploy
./staging-db-setup.sh copy-develop
```

### 2. Start Staging Environment
```bash
./staging-commands.sh start
```

### 3. Access Staging Site
- **URL**: http://localhost:8083
- **Admin**: http://localhost:8083/wp-admin

### 4. Stop Staging Environment
```bash
./staging-commands.sh stop
```

## 🛠️ Management Commands

### Environment Commands
```bash
# Start staging
./staging-commands.sh start

# Stop staging
./staging-commands.sh stop

# Restart staging
./staging-commands.sh restart

# Check status
./staging-commands.sh status

# View logs
./staging-commands.sh logs

# Build and start (force rebuild)
./staging-commands.sh build

# Clean environment
./staging-commands.sh clean
```

### Database Commands
```bash
# Copy develop database to staging
./staging-db-setup.sh copy-develop

# Verify staging database
./staging-db-setup.sh verify

# Backup staging database
./staging-db-setup.sh backup

# Restore staging database
./staging-db-setup.sh restore backup_file.sql

# Reset staging database
./staging-db-setup.sh reset
```

### Production Deployment Commands
```bash
# Navigate to GCP database migration folder
cd ../gcp-deploy/databasemigration

# Set up production environment
./production-deploy.sh setup-production

# Deploy staging to production
./production-deploy.sh staging-to-production

# Deploy develop directly to production
./production-deploy.sh develop-to-production

# Backup production database
./production-deploy.sh backup-production

# Verify production database
./production-deploy.sh verify-production
```

## 🗄️ Database Management

### Staging Database
- **Database Name**: `fiveriverstutoring_staging_db`
- **Host**: `192.168.50.158`
- **User**: `fiverriversadmin`
- **Password**: `Password@123`

### Production Database
- **Configuration**: Externalized in `env.production`
- **Security**: Separate credentials from staging
- **Domain**: Configurable production domain

### Copy Develop Data to Staging
```bash
./staging-db-setup.sh copy-develop
```
This copies all your develop content (posts, plugins, settings) to staging.

### Backup Staging Database
```bash
./staging-db-setup.sh backup
```
This creates: `staging_backup_YYYYMMDD_HHMMSS.sql`

### Restore Staging Database
```bash
./staging-db-setup.sh restore staging_backup_20241227_143022.sql
```

## 🔧 Production Configuration

Production configuration has been moved to `../gcp-deploy/databasemigration/` for better organization.

### Setting up Production Environment
1. **Navigate to GCP database migration folder:**
   ```bash
   cd ../gcp-deploy/databasemigration
   ```

2. **Copy example file:**
   ```bash
   cp env.production.example env.production
   ```

3. **Edit production configuration:**
   ```bash
   nano env.production
   ```

4. **Update with your values:**
   ```bash
   WORDPRESS_DB_HOST=your-production-db-host.com
   WORDPRESS_DB_PASSWORD=your-secure-production-password
   PRODUCTION_DOMAIN=your-production-domain.com
   GCP_PROJECT_ID=your-gcp-project-id
   ```

### Production Environment Variables
See `../gcp-deploy/databasemigration/README.md` for complete production configuration details.

## 🔄 Workflow

### Development Workflow
1. **Make changes** to code in `fiverivertutoring_wordpress/`
2. **Copy develop to staging**: `./staging-db-setup.sh copy-develop`
3. **Start staging**: `./staging-commands.sh start`
4. **Test changes** at http://localhost:8083
5. **Fix issues** if needed
6. **Stop staging**: `./staging-commands.sh stop`
7. **Deploy to production** when ready

### Database Workflow
1. **Copy develop to staging**: `./staging-db-setup.sh copy-develop`
2. **Test migrations**: Apply database changes
3. **Verify functionality**: Test all features
4. **Apply to production**: When confident

### Production Deployment Workflow
1. **Navigate to GCP database migration**: `cd ../gcp-deploy/databasemigration`
2. **Set up production config**: `./production-deploy.sh setup-production`
3. **Copy env.production.example to env.production**
4. **Update production values** in env.production
5. **Deploy staging to production**: `./production-deploy.sh staging-to-production`
6. **Verify production**: `./production-deploy.sh verify-production`

## 🌐 Environment Differences

| Feature | Local | Staging | Production |
|---------|-------|---------|------------|
| **Port** | 8082 | 8083 | 80/443 |
| **Database** | fiveriverstutoring_db | fiveriverstutoring_staging_db | fiveriverstutoring_prod_db |
| **Debug** | Enabled | Enabled | Disabled |
| **Environment** | local | staging | production |
| **Purpose** | Development | Testing | Live |
| **Config** | env.example | env.staging | env.production |

## 🔧 Configuration

### Environment Variables (`env.staging`)
```bash
WORDPRESS_DB_HOST=192.168.50.158
WORDPRESS_DB_USER=fiverriversadmin
WORDPRESS_DB_PASSWORD=Password@123
WORDPRESS_DB_NAME=fiveriverstutoring_staging_db
WORDPRESS_HOME=http://localhost:8083
WORDPRESS_SITEURL=http://localhost:8083
WP_ENVIRONMENT_TYPE=staging
WORDPRESS_DEBUG=1
```

### Docker Configuration
- **Container Name**: `fiverivertutoring-wp-staging`
- **Port**: `8083:80`
- **Network**: `fiverivertutoring_staging_network`
- **Volumes**: Same as local (shared wp-content)

## 🚨 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using port 8083
netstat -tulpn | grep 8083

# Kill process or change port in docker-compose.staging.yml
```

#### Database Connection Issues
```bash
# Check database connectivity
docker exec fiverivertutoring-wp-staging mysql -h 192.168.50.158 -u fiverriversadmin -pPassword@123 -e "SELECT 1;"
```

#### Container Won't Start
```bash
# Check logs
./staging-commands.sh logs

# Clean and rebuild
./staging-commands.sh clean
./staging-commands.sh build
```

#### Production Configuration Issues
```bash
# Navigate to GCP database migration folder
cd ../gcp-deploy/databasemigration

# Check if env.production exists
ls -la env.production

# Set up production environment
./production-deploy.sh setup-production
```

### Reset Staging Environment
```bash
# Complete reset
./staging-commands.sh clean
./staging-commands.sh build
```

## 📝 Best Practices

1. **Always backup** before major changes
2. **Test thoroughly** in staging before production
3. **Use staging** for all database migrations
4. **Keep staging** similar to production
5. **Document changes** made in staging
6. **Clean up** staging regularly
7. **Secure production credentials** in gcp-deploy/databasemigration/env.production
8. **Never commit** gcp-deploy/databasemigration/env.production to version control

## 🔗 Related Files

- `../local-deploy/` - Local development
- `../gcp-deploy/` - Production deployment
- `../gcp-deploy/databasemigration/` - Production database migration
- `../fiverivertutoring_wordpress/` - WordPress content
- `../config/` - Configuration files 