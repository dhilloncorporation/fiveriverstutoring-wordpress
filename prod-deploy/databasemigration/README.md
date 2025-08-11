# Five Rivers Tutoring - GCP Database Migration

This folder contains all production database migration scripts and configuration for deploying to Google Cloud Platform (GCP).

## 🎯 Purpose

The database migration folder handles:
- **Production database deployments** from staging/develop
- **Database backups and restores** for production
- **Production environment configuration** management
- **GCP-specific database operations**

## 📁 Files

- `env.production` - Production environment variables (create from example)
- `env.production.example` - Example production configuration
- `production-deploy.sh` - Production deployment and management scripts
- `README.md` - This documentation

## 🚀 Quick Start

### 1. Set up Production Configuration
```bash
cd gcp-deploy/databasemigration
cp env.production.example env.production
nano env.production
```

### 2. Update Production Values
```bash
# Database Configuration
WORDPRESS_DB_HOST=your-gcp-db-host.com
WORDPRESS_DB_PASSWORD=your-secure-production-password
PRODUCTION_DOMAIN=your-production-domain.com
GCP_PROJECT_ID=your-gcp-project-id
```

### 3. Deploy to Production
```bash
# From staging (recommended)
./production-deploy.sh staging-to-production

# Or directly from develop
./production-deploy.sh develop-to-production
```

## 🛠️ Management Commands

### Production Deployment
```bash
# Deploy staging to production (RECOMMENDED)
./production-deploy.sh staging-to-production

# Deploy develop directly to production
./production-deploy.sh develop-to-production

# Backup production database
./production-deploy.sh backup-production

# Restore production database
./production-deploy.sh restore-production backup_file.sql

# Verify production database
./production-deploy.sh verify-production

# Set up production environment
./production-deploy.sh setup-production
```

### Complete Workflow
```bash
# Show complete development workflow
./production-deploy.sh workflow
```

## 🔧 Configuration

### Production Environment Variables (`env.production`)
```bash
# Database Configuration
WORDPRESS_DB_HOST=your-production-db-host.com
WORDPRESS_DB_USER=fiverriversadmin
WORDPRESS_DB_PASSWORD=your-secure-production-password
WORDPRESS_DB_NAME=fiveriverstutoring_prod_db

# WordPress Production Site Configuration
WORDPRESS_HOME=https://your-production-domain.com
WORDPRESS_SITEURL=https://your-production-domain.com

# Production Environment Settings
WP_ENVIRONMENT_TYPE=production
WORDPRESS_DEBUG=0

# GCP Production Settings
GCP_PROJECT_ID=your-gcp-project-id
GCP_REGION=australia-southeast1
GCP_ZONE=australia-southeast1-a

# Production Domain (for URL updates)
PRODUCTION_DOMAIN=your-production-domain.com
```

### Example GCP Configurations
```bash
# Cloud SQL Instance
WORDPRESS_DB_HOST=your-instance.cloudsql.googleapis.com

# Compute Engine VM with MySQL
WORDPRESS_DB_HOST=35.201.123.456

# Production Domain
PRODUCTION_DOMAIN=fiverivertutoring.com.au

# GCP Project
GCP_PROJECT_ID=fiverivertutoring-prod
```

## 🔄 Workflow

### Recommended: Develop → Staging → Production
1. **Work in develop** environment
2. **Copy to staging**: `cd ../staging-deploy && ./staging-db-setup.sh copy-develop`
3. **Test in staging**: `./staging-commands.sh start` → http://localhost:8083
4. **Deploy to production**: `cd ../gcp-deploy/databasemigration && ./production-deploy.sh staging-to-production`
5. **Verify production**: `./production-deploy.sh verify-production`

### Alternative: Direct Develop → Production
```bash
./production-deploy.sh develop-to-production
```

## 🗄️ Database Operations

### Production Database
- **Database Name**: `fiveriverstutoring_prod_db` (configurable)
- **Host**: GCP database host (configurable)
- **User**: `fiverriversadmin`
- **Password**: Secure production password (configurable)

### Backup Operations
```bash
# Create backup
./production-deploy.sh backup-production

# Restore from backup
./production-deploy.sh restore-production production_backup_20241227_143022.sql
```

### URL Updates
The deployment script automatically updates:
- WordPress home and site URLs
- Post GUIDs from localhost to production domain
- All internal links to production domain

## 🛡️ Security Features

- **Environment validation** - Checks for `env.production` file
- **Separate credentials** - Production DB credentials isolated
- **Backup creation** - Automatic backups before deployments
- **Example template** - Safe to commit to version control
- **Clear documentation** - Setup and usage instructions

## 🚨 Troubleshooting

### Common Issues

#### Production Environment Not Found
```bash
# Check if env.production exists
ls -la env.production

# Set up production environment
./production-deploy.sh setup-production
```

#### Database Connection Issues
```bash
# Test database connectivity
mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -e "SELECT 1;"
```

#### Permission Issues
```bash
# Make script executable
chmod +x production-deploy.sh
```

### Production Verification
```bash
# Check production database status
./production-deploy.sh verify-production

# Expected output:
# - Total posts count
# - Total users count
# - Site URL (should be production domain)
# - Blog name
```

## 📋 Best Practices

1. **Always backup** before deployments
2. **Test in staging** before production
3. **Use staging-to-production** workflow (recommended)
4. **Secure credentials** in env.production
5. **Never commit** env.production to version control
6. **Verify deployments** after completion
7. **Document changes** made in production
8. **Monitor production** after deployments

## 🔗 Related Files

- `../staging-deploy/` - Staging environment
- `../local-deploy/` - Local development
- `../terraform/` - GCP infrastructure
- `../fiverivertutoring_wordpress/` - WordPress content
- `../config/` - Configuration files

## 📞 Support

For issues with production deployments:
1. Check the troubleshooting section
2. Verify environment configuration
3. Test database connectivity
4. Review deployment logs
5. Check GCP console for infrastructure issues 