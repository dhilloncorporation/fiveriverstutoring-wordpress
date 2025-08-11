# 🚀 Five Rivers Tutoring - Production Deployment

This directory contains the complete production deployment infrastructure for the Five Rivers Tutoring WordPress site.

## 📁 Directory Structure

```
prod-deploy/
├── 📁 terraform/                    # Infrastructure as Code (GCP)
├── 📁 databasemigration/           # Database deployment & migration
├── 📁 deployment/                  # Application deployment scripts
├── 📁 config/                      # Configuration templates
├── 📁 docs/                        # Documentation & references
├── 📁 scripts/                     # Common functions & utilities
├── 📄 deploy.sh                    # Main deployment orchestrator
├── 📄 EXECUTION_ORDER.md           # Complete deployment workflow
└── 📄 FILE_ORGANIZATION.md         # File organization guide
```

## 🎯 Quick Start

### **1. Validate Configuration**
```bash
cd prod-deploy
./scripts/validate-config.sh
```

### **2. Complete Deployment**
```bash
./deploy.sh full
```

### **3. Individual Phases**
```bash
./deploy.sh infrastructure    # Deploy GCP infrastructure
./deploy.sh database         # Set up production database
./deploy.sh application      # Deploy WordPress application
./deploy.sh verify           # Verify deployment status
```

## 🚀 Main Deployment Script

The `deploy.sh` script is the central orchestrator for all production deployments.

### **Usage:**
```bash
./deploy.sh [OPTIONS] <deployment-type>
```

### **Options:**
- `-e, --env FILE` - Custom environment file path
- `-y, --yes` - Skip confirmation prompts
- `-v, --verbose` - Enable verbose output
- `-h, --help` - Show help message

### **Examples:**
```bash
# Complete deployment with prompts
./deploy.sh full

# Complete deployment without prompts
./deploy.sh full -y

# Use custom environment file
./deploy.sh database -e custom.env

# Deploy only infrastructure
./deploy.sh infrastructure
```

## 🔧 Scripts Directory

### **Common Functions (`scripts/common-functions.sh`)**
Shared functions used across all deployment scripts:
- **Logging**: Colored output with emojis
- **Error Handling**: Automatic error trapping and reporting
- **Validation**: Environment and file validation
- **Database**: Connection testing and management
- **Utilities**: Backup, confirmation prompts, service waiting

### **Configuration Validator (`scripts/validate-config.sh`)**
Comprehensive validation of all deployment configurations:
- Environment variable validation
- Terraform configuration checks
- Docker Compose validation
- Directory structure verification
- Script permissions checking
- External dependency validation

## 📋 Deployment Phases

### **Phase 1: Infrastructure Setup** 🏗️
- Deploy GCP VM instance
- Configure networking and security
- Set up persistent storage
- Assign static IP addresses

### **Phase 2: Database Migration** 🗄️
- Create production database
- Migrate data from staging/development
- Update URLs and configurations
- Verify database integrity



### **Phase 3: Application Deployment** 🚀
- Deploy Docker containers with pre-built content
- Configure WordPress settings
- Activate plugins and themes
- Verify application functionality

## ⚙️ Configuration

### **Environment Configuration**
The main environment file is located at `databasemigration/env.production`:

```bash
# Database Connection
DB_HOST=your-production-db-host
DB_USER=your-db-user
DB_PASSWORD=your-db-password
DB_NAME=your-production-db

# WordPress Configuration
WORDPRESS_HOME=https://yourdomain.com
WORDPRESS_SITEURL=https://yourdomain.com
WP_ENVIRONMENT_TYPE=production
WORDPRESS_DEBUG=0
```

### **Terraform Configuration**
Infrastructure configuration in `terraform/production.tfvars`:

```hcl
project_id     = "your-gcp-project"
region         = "us-central1"
zone           = "us-central1-a"
machine_type   = "e2-medium"
disk_size_gb   = 50
```

## 🔍 Validation

### **Pre-Deployment Validation**
Always run the configuration validator before deployment:

```bash
./scripts/validate-config.sh
```

This will check:
- ✅ Required files and directories
- ✅ Environment variable completeness
- ✅ Configuration file validity
- ✅ Script permissions
- ✅ External dependencies
- ✅ URL format validation
- ✅ Production readiness checks

### **Common Validation Issues**
- **Missing environment variables**
- **Development URLs in production config**
- **Insufficient disk size or machine type**
- **Missing required scripts or directories**

## 🚨 Error Handling

### **Automatic Error Handling**
All scripts include:
- **Error trapping**: Automatic error detection and reporting
- **Graceful failures**: Clear error messages with line numbers
- **Rollback support**: Automatic cleanup on failure
- **Detailed logging**: Comprehensive operation logging

### **Troubleshooting**
1. **Check logs**: All operations are logged with timestamps
2. **Validate config**: Run validation script to identify issues
3. **Check dependencies**: Ensure all required tools are available
4. **Review permissions**: Verify script and file permissions

## 📚 Documentation

### **Execution Order (`EXECUTION_ORDER.md`)**
Complete step-by-step deployment workflow with commands and expected outputs.

### **File Organization (`FILE_ORGANIZATION.md`)**
Detailed explanation of directory structure and file purposes.

### **Database Migration (`databasemigration/README.md`)**
Specific database migration procedures and troubleshooting.

### **Terraform (`terraform/README.md`)**
Infrastructure configuration and deployment details.

## 🔄 Maintenance

### **Regular Tasks**
- **Configuration validation**: Run before each deployment
- **Backup verification**: Ensure backup procedures work
- **Dependency updates**: Keep tools and scripts current
- **Documentation updates**: Maintain current procedures

### **Updates and Upgrades**
- **Infrastructure**: Use Terraform for infrastructure changes
- **Applications**: Update Docker images and configurations
- **Scripts**: Enhance error handling and validation
- **Documentation**: Keep procedures current

## 🆘 Support

### **Common Issues**
1. **Configuration validation failures**
2. **Database connection issues**
3. **Infrastructure deployment problems**
4. **Content migration failures**

### **Getting Help**
1. **Check logs**: Review detailed operation logs
2. **Validate config**: Run configuration validation
3. **Review documentation**: Check relevant README files
4. **Check prerequisites**: Verify all dependencies are met

## 🎉 Success Indicators

### **Successful Deployment**
- ✅ All validation checks pass
- ✅ Infrastructure deployed without errors
- ✅ Database migration completes successfully
- ✅ Content migration completes without issues
- ✅ Application responds on expected ports
- ✅ WordPress site loads correctly
- ✅ All services are healthy and responsive

---

**🚀 Ready to deploy to production? Start with configuration validation!**
