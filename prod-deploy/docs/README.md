# Five Rivers Tutoring - Production Deployment Documentation

Welcome to the production deployment documentation for Five Rivers Tutoring. This directory contains comprehensive guides for managing your WordPress infrastructure on Google Cloud Platform.

## 📚 Documentation Index

### 🚀 **Core Deployment Guides**
- **[README.md](README.md)** - This overview and navigation guide
- **[EXECUTION_GUIDE.md](EXECUTION_GUIDE.md)** - Step-by-step execution guide for deployments
- **[WORDPRESS_DEPLOYMENT_GUIDE.md](WORDPRESS_DEPLOYMENT_GUIDE.md)** - Complete WordPress deployment guide

### 🔒 **Security & HTTPS**
- **[HTTPS_SETUP_GUIDE.md](HTTPS_SETUP_GUIDE.md)** - Complete HTTPS setup with Let's Encrypt
- **[DEPLOY_HTTPS_NOW.md](DEPLOY_HTTPS_NOW.md)** - Quick HTTPS deployment guide

### 🧹 **Maintenance & Operations**
- **[FIREWALL_FIX_SUMMARY.md](FIREWALL_FIX_SUMMARY.md)** - Firewall configuration for direct Cloud SQL connections
- **[DOCKER_CLEANUP_IMPROVEMENTS.md](DOCKER_CLEANUP_IMPROVEMENTS.md)** - Safe Docker image cleanup with latest tag protection
- **[SCRIPT_SEPARATION_GUIDE.md](SCRIPT_SEPARATION_GUIDE.md)** - Guide to using deploy.sh vs operations.sh

## 🎯 **Quick Start Guide**

### 1. **Initial Setup**
```bash
cd prod-deploy
./deploy.sh check           # Verify you're ready to deploy
./deploy.sh init            # Initialize Terraform
./deploy.sh plan            # Review what will be deployed
./deploy.sh apply           # Deploy all infrastructure
```

### 2. **WordPress Deployment**
```bash
./deploy.sh wp-deploy         # Deploy WordPress application
./operations.sh app-status     # Check application status
./operations.sh app-logs       # View application logs
```

### 3. **HTTPS Setup**
```bash
./deploy.sh wp-https-setup    # Setup HTTPS automatically
./deploy.sh wp-https-status   # Check HTTPS status
./deploy.sh wp-https-test     # Test HTTPS connectivity
```

### 4. **Daily Operations**
```bash
./operations.sh status          # Check infrastructure status
./operations.sh app-status      # Check WordPress status
./operations.sh preview-cleanup # Preview Docker cleanup (safe)
./operations.sh cleanup-images  # Clean up old Docker images
```

## 🛠️ **Scripts Overview**

### **`deploy.sh`** - Core Deployment Operations
- Infrastructure deployment with Terraform
- WordPress application deployment
- **Initial HTTPS setup** (one-time configuration)
- Infrastructure planning and management
- Infrastructure visualization (graphs)

### **`operations.sh`** - Day-to-Day Operations
- Application monitoring and status checks
- **Database management** (restart, status)
- **HTTPS monitoring and renewal** (status, test, renew, logs)
- Docker image management and cleanup
- Cost optimization (start/stop resources)
- Application backup and restore

## 📁 **Directory Structure**

```
prod-deploy/
├── deploy.sh                    # Core deployment script
├── operations.sh                # Operations and maintenance script
├── terraform/                   # Terraform infrastructure code
├── docs/                        # This documentation directory
│   ├── README.md               # This overview file
│   ├── EXECUTION_GUIDE.md      # Deployment execution guide
│   ├── WORDPRESS_DEPLOYMENT_GUIDE.md # WordPress deployment guide
│   ├── HTTPS_SETUP_GUIDE.md    # HTTPS setup guide
│   ├── DEPLOY_HTTPS_NOW.md     # Quick HTTPS guide
│   ├── FIREWALL_FIX_SUMMARY.md # Firewall configuration guide
│   └── DOCKER_CLEANUP_IMPROVEMENTS.md # Docker cleanup guide
├── properties/                  # Configuration properties
├── plans/                       # Terraform plan files
├── scripts/                     # Additional deployment scripts
└── databasemigration/          # Database migration scripts
```

## 🔍 **Common Operations**

### **Infrastructure Management**
- **Deploy**: `./deploy.sh apply`
- **Plan**: `./deploy.sh plan`
- **Destroy**: `./deploy.sh destroy`
- **Status**: `./operations.sh status`

### **Application Management**
- **Start**: `./operations.sh app-start`
- **Stop**: `./operations.sh app-stop`
- **Restart**: `./operations.sh app-restart`
- **Logs**: `./operations.sh app-logs`
- **Backup**: `./operations.sh app-backup`

### **Cost Optimization**
- **Stop VM**: `./operations.sh compute-stop` (save ~$6/month)
- **Stop All**: `./operations.sh winddown` (save ~$15/month)
- **Start All**: `./operations.sh windup`

### **Maintenance**
- **List Images**: `./operations.sh list-images`
- **Preview Cleanup**: `./operations.sh preview-cleanup`
- **Cleanup Images**: `./operations.sh cleanup-images`

## 🚨 **Important Notes**

### **Safety Features**
- **Preview Mode**: Always use `preview-cleanup` before running cleanup
- **Latest Tag Protection**: Docker cleanup never deletes `latest` tagged images
- **Interactive Confirmation**: Most destructive operations require user confirmation

### **Prerequisites**
- Google Cloud SDK (`gcloud`) installed and authenticated
- Terraform installed (version >= 1.0)
- Proper GCP project permissions
- Domain name configured for HTTPS

### **Best Practices**
1. **Always preview** cleanup operations before executing
2. **Test changes** on staging before production
3. **Keep backups** before major changes
4. **Monitor costs** using the cost estimation tools
5. **Use HTTPS** for all production traffic

## 📞 **Getting Help**

### **Troubleshooting**
1. Check the specific guide for your operation
2. Review the execution guide for common issues
3. Check script help: `./deploy.sh help` or `./operations.sh help`
4. Verify prerequisites and authentication

### **Common Issues**
- **Authentication**: Run `gcloud auth login` if you get permission errors
- **Project**: Verify current project with `gcloud config get-value project`
- **Terraform**: Run `./deploy.sh init` if Terraform isn't initialized
- **HTTPS**: Check domain DNS configuration if HTTPS setup fails

## 🔄 **Recent Updates**

- **Docker Cleanup Safety**: Enhanced cleanup functions now protect `latest` tags
- **Script Separation**: Split monolithic deploy.sh into focused deploy.sh and operations.sh
- **Firewall Configuration**: Added direct Cloud SQL connection support
- **Documentation Organization**: Consolidated all docs into organized structure

---

**Need help?** Start with the [EXECUTION_GUIDE.md](EXECUTION_GUIDE.md) for step-by-step instructions, or use the specific guides for your operation.
