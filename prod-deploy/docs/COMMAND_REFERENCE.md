# Complete Command Reference - deploy.sh vs operations.sh

## Overview
This document provides a complete reference for all available commands in both scripts, organized by functionality and script location.

## 🎯 **Script Responsibilities**

### **`deploy.sh`** - Infrastructure & Deployment
- **Infrastructure deployment** with Terraform
- **WordPress application deployment**
- **Initial HTTPS setup** (one-time configuration)
- **Infrastructure visualization** (graphs)
- **Component-specific deployments**

### **`operations.sh`** - Daily Operations & Maintenance
- **Application monitoring** and status checks
- **Database management** (restart, status)
- **HTTPS monitoring and renewal** (status, test, renew, logs)
- **Docker image management** and cleanup
- **Cost optimization** (start/stop resources)
- **Application backup and restore**

## 📋 **Complete Command List**

### **🔧 deploy.sh Commands**

#### **Prerequisites & Setup**
```bash
./deploy.sh check              # Check prerequisites (gcloud, terraform, auth)
./deploy.sh init               # Initialize Terraform
./deploy.sh plan               # Plan infrastructure deployment
./deploy.sh show               # Show Terraform outputs and status
./deploy.sh status             # Show deployment status
```

#### **Infrastructure Deployment**
```bash
./deploy.sh apply              # Deploy ALL infrastructure (compute + database + networking)
./deploy.sh destroy            # Destroy all infrastructure (⚠️ DESTRUCTIVE)
./deploy.sh graph              # Generate infrastructure visualization graph
```

#### **Component-Specific Deployment**
```bash
./deploy.sh wp-infra-deploy    # Deploy only compute resources (VM, disks, networking)
./deploy.sh wp-db-deploy       # Deploy only database resources (Cloud SQL, users)
./deploy.sh wp-deploy          # Deploy only WordPress application configuration
```

#### **WordPress Application Management**
```bash
./deploy.sh wp-deploy          # Deploy WordPress application (runs entrypoint.sh)
./deploy.sh wp-stop            # Stop WordPress application
./deploy.sh wp-start           # Start WordPress application
./deploy.sh wp-status          # Check WordPress application status
./deploy.sh wp-logs            # View WordPress application logs
./deploy.sh wp-backup          # Create WordPress backup
```

#### **Compute Resource Management**
```bash
./deploy.sh wp-infra-stop      # Stop VM instances (save ~$6/month)
./deploy.sh wp-infra-start     # Start VM instances back up
./deploy.sh wp-infra-status    # Check status of all components
```

#### **Cost Optimization & Resource Control**
```bash
./deploy.sh wp-winddown        # Stop ALL resources (VM + Cloud SQL) - save ~$15/month
./deploy.sh wp-windup          # Start all resources back up
./deploy.sh wp-windstatus      # Check winddown status
./deploy.sh wp-cost-estimate   # Estimate monthly cost savings
```

#### **HTTPS Setup (Initial Configuration)**
```bash
./deploy.sh wp-https-setup     # Automated HTTPS setup with Let's Encrypt (one-time)
```

### **🔧 operations.sh Commands**

#### **Monitoring & Status**
```bash
./operations.sh status          # Check overall infrastructure status
./operations.sh app-status      # Check WordPress application status
./operations.sh app-logs        # View WordPress application logs
./operations.sh db-status       # Check database status and details
```

#### **Application Management**
```bash
./operations.sh app-start       # Start WordPress application
./operations.sh app-stop        # Stop WordPress application
./operations.sh app-restart     # Restart WordPress application
./operations.sh app-backup      # Create WordPress backup
./operations.sh app-restore     # Restore WordPress from backup
```

#### **Database Management**
```bash
./operations.sh db-restart      # Restart Cloud SQL database
./operations.sh db-status       # Check database status and details
```

#### **Docker Image Management**
```bash
./operations.sh list-images     # Show current Docker images in registry
./operations.sh show-images     # Same as list-images (alias)
./operations.sh preview-cleanup # Preview what would be deleted (safe)
./operations.sh cleanup-images  # Clean up old Docker images (reduce storage costs)
./operations.sh cleanup-docker  # Same as cleanup-images (alias)
```

#### **Cost Optimization**
```bash
./operations.sh compute-stop    # Stop VM instances (save ~$6/month)
./operations.sh compute-start   # Start VM instances back up
./operations.sh winddown        # Stop ALL resources (VM + Cloud SQL) - save ~$15/month
./operations.sh windup          # Start all resources back up
./operations.sh windstatus      # Check winddown status
./operations.sh cost-estimate   # Estimate monthly cost savings
```

#### **HTTPS Monitoring & Renewal**
```bash
./operations.sh https-status    # Check HTTPS configuration status
./operations.sh https-test      # Test HTTPS connectivity and SSL certificates
./operations.sh https-renew     # Manually renew SSL certificates
./operations.sh https-logs      # View HTTPS setup and configuration logs
```

## 🔄 **Command Migration Summary**

### **Moved from deploy.sh to operations.sh**
- **Docker management**: `list-images`, `show-images`, `preview-cleanup`, `cleanup-images`
- **Application operations**: `app-start`, `app-stop`, `app-restart`, `app-backup`, `app-restore`
- **Cost optimization**: `compute-stop`, `compute-start`, `winddown`, `windup`, `windstatus`, `cost-estimate`
- **HTTPS operations**: `https-status`, `https-test`, `https-renew`, `https-logs`
- **Database operations**: `db-restart`, `db-status`

### **Remained in deploy.sh**
- **Infrastructure**: `init`, `plan`, `apply`, `destroy`, `status`, `show`, `graph`
- **Deployment**: `wp-infra-deploy`, `wp-db-deploy`, `wp-deploy`
- **Application deployment**: `wp-start`, `wp-stop`, `wp-status`, `wp-logs`, `wp-backup`
- **Resource management**: `wp-infra-start`, `wp-infra-stop`, `wp-infra-status`
- **Cost control**: `wp-winddown`, `wp-windup`, `wp-windstatus`, `wp-cost-estimate`
- **HTTPS setup**: `wp-https-setup` (initial configuration only)

## 📋 **Common Workflows**

### **Initial Deployment (deploy.sh)**
```bash
# 1. Check and initialize
./deploy.sh check
./deploy.sh init

# 2. Plan and deploy infrastructure
./deploy.sh plan
./deploy.sh apply

# 3. Deploy WordPress
./deploy.sh wp-deploy

# 4. Setup HTTPS
./deploy.sh wp-https-setup

# 5. Generate infrastructure graphs
./deploy.sh graph
```

### **Daily Operations (operations.sh)**
```bash
# 1. Check status
./operations.sh status
./operations.sh app-status
./operations.sh db-status

# 2. View logs if needed
./operations.sh app-logs

# 3. Perform maintenance
./operations.sh preview-cleanup
./operations.sh cleanup-images

# 4. Check HTTPS
./operations.sh https-status
./operations.sh https-test
```

### **Cost Optimization (operations.sh)**
```bash
# Stop resources to save costs
./operations.sh compute-stop    # Save ~$6/month
./operations.sh winddown        # Save ~$15/month

# Start resources back up
./operations.sh compute-start
./operations.sh windup
```

### **Database Management (operations.sh)**
```bash
# Check database status
./operations.sh db-status

# Restart database if needed
./operations.sh db-restart
```

## 🚨 **Important Notes**

### **Script Dependencies**
- **`deploy.sh`** requires Terraform to be initialized
- **`operations.sh`** can be run independently
- Both scripts assume you're in the `prod-deploy` directory

### **Command Organization**
- **Deployment commands** → Use `deploy.sh`
- **Operational commands** → Use `operations.sh`
- **HTTPS setup** → Use `deploy.sh wp-https-setup` (one-time)
- **HTTPS monitoring** → Use `operations.sh https-*` commands

### **Safety Features**
- **`operations.sh`** includes enhanced safety for Docker cleanup
- **Preview mode** available for cleanup operations
- **Latest tag protection** prevents accidental deletion of production images
- **Confirmation prompts** for destructive operations

## 🔍 **Getting Help**

### **Command Help**
```bash
./deploy.sh help               # Show all deployment commands
./deploy.sh help | grep wp-    # Show only WordPress commands
./operations.sh help            # Show all operational commands
./operations.sh help | grep app # Show only application commands
./operations.sh help | grep db  # Show only database commands
./operations.sh help | grep https # Show only HTTPS commands
```

### **Command Validation**
```bash
./deploy.sh check              # Validate prerequisites
./deploy.sh status             # Check current deployment status
./operations.sh status          # Check operational status
```

## 📚 **Related Documentation**

- **[Script Separation Guide](SCRIPT_SEPARATION_GUIDE.md)** - Understanding the split
- **[WordPress Commands Reference](WORDPRESS_COMMANDS_REFERENCE.md)** - Detailed deploy.sh commands
- **[Main Documentation Index](README.md)** - Complete documentation overview
- **[Execution Guide](EXECUTION_GUIDE.md)** - Step-by-step deployment process

---

**Need help?** Start with `./deploy.sh help` for deployment commands or `./operations.sh help` for operational commands.
