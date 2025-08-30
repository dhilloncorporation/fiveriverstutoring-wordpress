# Five Rivers Tutoring - Production Scripts

This folder contains all production deployment and management scripts for the Five Rivers Tutoring infrastructure.

## 📁 Available Scripts

### 🚀 Main Deployment Script
- **`deploy.sh`** - Main production deployment script with comprehensive infrastructure management

### 🗄️ Database Management
- **`database-management.sh`** - Production database operations and staging migrations
  - Copy staging database to production
  - Create and restore database backups
  - Verify database status and connections
  - Manage backup files

### 🌐 WordPress Management
- **`wordpress-management.sh`** - WordPress container and VM management
  - Start/stop WordPress application
  - View logs and status
  - Manage VM instances

### 🛠️ Operations and Maintenance
- **`operations.sh`** - Infrastructure maintenance and cleanup operations
  - Docker image management
  - HTTPS certificate management
  - Resource cleanup and optimization

## 🔧 Usage Examples

### 🎯 **Unified Interface (Recommended)**
All database operations can be accessed through the main deployment script for a consistent experience:

```bash
./deploy.sh db-manage [COMMAND] [OPTIONS]
```

### Database Management
```bash
# Via deploy.sh (recommended - unified interface)
./deploy.sh db-manage copy-staging
./deploy.sh db-manage backup
./deploy.sh db-manage restore production_backup_20241227_143022.sql
./deploy.sh db-manage verify
./deploy.sh db-manage test-connection --debug

# Direct script usage (standalone)
./database-management.sh copy-staging
./database-management.sh backup
./database-management.sh restore production_backup_20241227_143022.sql
./database-management.sh verify
./database-management.sh test-connection --debug
```

### WordPress Management
```bash
# Deploy WordPress application
./deploy.sh wp-deploy

# Check WordPress status
./deploy.sh wp-status

# View WordPress logs
./deploy.sh wp-logs

# Stop WordPress
./deploy.sh wp-stop
```

### Infrastructure Operations
```bash
# Deploy infrastructure
./deploy.sh plan
./deploy.sh apply

# Check component status
./deploy.sh component-status

# Cost optimization
./deploy.sh winddown    # Stop resources to save costs
./deploy.sh windup      # Start resources back up
```

## 🔄 **Complete Database Workflow**

### Staging to Production Migration
```bash
# 1. Verify staging environment
./deploy.sh db-manage test-connection --debug

# 2. Create production backup (safety first)
./deploy.sh db-manage backup

# 3. Copy staging data to production
./deploy.sh db-manage copy-staging

# 4. Verify the migration
./deploy.sh db-manage verify

# 5. Test production connections
./deploy.sh db-manage test-connection
```

### Backup and Restore Operations
```bash
# Create backup before changes
./deploy.sh db-manage backup

# List available backups
./deploy.sh db-manage list-backups

# Restore from specific backup
./deploy.sh db-manage restore production_backup_20241227_143022.sql
```

## 📋 Script Dependencies

All scripts in this folder:
- Require proper GCP authentication (`gcloud auth login`)
- Depend on configuration files in parent directories
- Use consistent error handling and colored output
- Follow the same coding patterns and structure

## 🔒 Security Notes

- Scripts handle sensitive database operations
- Always use `--debug` flag for troubleshooting
- Backup operations are performed before destructive changes
- Interactive confirmations for critical operations

## 📚 Documentation

- **`execution-order.md`** - Recommended execution sequence for deployments
- **`README.md`** - This documentation file
- Individual script help: `./script-name.sh help`

## 🚨 Troubleshooting

For issues with any script:
1. Check prerequisites: `./deploy.sh check`
2. Enable debug mode: add `--debug` flag
3. Verify GCP authentication: `gcloud auth list`
4. Check project configuration: `gcloud config get-value project`
