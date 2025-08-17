# WordPress Commands Reference - deploy.sh

## Overview
This document provides a comprehensive reference for all the WordPress-prefixed commands available in `deploy.sh`. These commands are organized by functionality and provide clear, descriptive names for WordPress-specific operations.

## 🎯 **Command Categories**

### **🔧 Prerequisites & Setup**
```bash
./deploy.sh check              # Check prerequisites (gcloud, terraform, auth)
./deploy.sh init               # Initialize Terraform
./deploy.sh plan               # Plan infrastructure deployment
./deploy.sh show               # Show Terraform outputs and status
./deploy.sh status             # Show deployment status
```

### **🚀 Infrastructure Deployment**
```bash
./deploy.sh apply              # Deploy ALL infrastructure (compute + database + networking)
./deploy.sh destroy            # Destroy all infrastructure (⚠️ DESTRUCTIVE)
./deploy.sh graph              # Generate infrastructure visualization graph
```

### **🏗️ Component-Specific Deployment**
```bash
./deploy.sh wp-infra-deploy    # Deploy only compute resources (VM, disks, networking)
./deploy.sh wp-db-deploy       # Deploy only database resources (Cloud SQL, users)
./deploy.sh wp-deploy          # Deploy only WordPress application configuration
```

### **🌐 WordPress Application Management**
```bash
./deploy.sh wp-deploy          # Deploy WordPress application (runs entrypoint.sh)
./deploy.sh wp-stop            # Stop WordPress application
./deploy.sh wp-start           # Start WordPress application
./deploy.sh wp-status          # Check WordPress application status
./deploy.sh wp-logs            # View WordPress application logs
./deploy.sh wp-backup          # Create WordPress backup
```

### **💻 Compute Resource Management**
```bash
./deploy.sh wp-infra-stop      # Stop VM instances (save ~$6/month)
./deploy.sh wp-infra-start     # Start VM instances back up
./deploy.sh wp-infra-status    # Check status of all components
```

### **💰 Cost Optimization & Resource Control**
```bash
./deploy.sh wp-winddown        # Stop ALL resources (VM + Cloud SQL) - save ~$15/month
./deploy.sh wp-windup          # Start all resources back up
./deploy.sh wp-windstatus      # Check winddown status
./deploy.sh wp-cost-estimate   # Estimate monthly cost savings
```

### **🔒 HTTPS & Security Management**
```bash
./deploy.sh wp-https-setup     # Automated HTTPS setup with Let's Encrypt
./deploy.sh wp-https-status    # Check HTTPS configuration status
./deploy.sh wp-https-test      # Test HTTPS connectivity and SSL certificates
./deploy.sh wp-https-renew     # Manually renew SSL certificates
./deploy.sh wp-https-logs      # View HTTPS setup and configuration logs
```

## 📋 **Command Aliases & Backward Compatibility**

### **WordPress Application Commands**
- `wp-deploy` = `deploy-app` = `deploy-wordpress`
- `wp-stop` = `app-stop` = `stop-app` = `wordpress-stop`
- `wp-start` = `app-start` = `start-app` = `wordpress-start`
- `wp-logs` = `app-logs` = `wordpress-logs`
- `wp-status` = `app-status` = `wordpress-status`
- `wp-backup` = `app-backup` = `wordpress-backup`

### **Infrastructure Commands**
- `wp-infra-deploy` = `compute-deploy`
- `wp-db-deploy` = `database-deploy`
- `wp-infra-stop` = `compute-stop`
- `wp-infra-start` = `compute-start`
- `wp-infra-status` = `component-status`

### **Cost Optimization Commands**
- `wp-winddown` = `winddown`
- `wp-windup` = `windup`
- `wp-windstatus` = `windstatus`
- `wp-cost-estimate` = `cost-estimate`

### **HTTPS Commands**
- `wp-https-setup` = `https-setup`
- `wp-https-status` = `https-status`
- `wp-https-test` = `https-test`
- `wp-https-renew` = `https-renew`
- `wp-https-logs` = `https-logs`

## 🔄 **Common Workflows with New Commands**

### **Initial Deployment**
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
```

### **Component Updates**
```bash
# Update only compute resources
./deploy.sh wp-infra-deploy

# Update only database
./deploy.sh wp-db-deploy

# Update only WordPress app
./deploy.sh wp-deploy
```

### **Cost Optimization**
```bash
# Stop VM to save costs
./deploy.sh wp-infra-stop

# Stop all resources
./deploy.sh wp-winddown

# Start everything back up
./deploy.sh wp-windup
```

### **Maintenance & Monitoring**
```bash
# Check infrastructure status
./deploy.sh status

# Check WordPress status
./deploy.sh wp-status

# View WordPress logs
./deploy.sh wp-logs

# Check HTTPS status
./deploy.sh wp-https-status
```

## 🚨 **Important Notes**

### **Command Dependencies**
- **Infrastructure commands** require Terraform to be initialized
- **WordPress commands** require infrastructure to be deployed
- **HTTPS commands** require domain configuration

### **Safety Features**
- **Destructive commands** (like `destroy`) require confirmation
- **Cost optimization commands** show estimated savings
- **Status commands** provide detailed information before actions

### **Best Practices**
1. **Always use `check`** before running other commands
2. **Use `plan`** to review changes before applying
3. **Start with infrastructure** before deploying WordPress
4. **Use component-specific commands** for targeted updates
5. **Monitor with status commands** before making changes

## 📚 **Related Documentation**

- **[Script Separation Guide](SCRIPT_SEPARATION_GUIDE.md)** - Understanding deploy.sh vs operations.sh
- **[Execution Guide](EXECUTION_GUIDE.md)** - Step-by-step deployment process
- **[WordPress Deployment Guide](WORDPRESS_DEPLOYMENT_GUIDE.md)** - WordPress-specific deployment
- **[HTTPS Setup Guide](HTTPS_SETUP_GUIDE.md)** - SSL configuration details

## 🔍 **Getting Help**

### **Command Help**
```bash
./deploy.sh help               # Show all available commands
./deploy.sh help | grep wp-    # Show only WordPress commands
```

### **Command Validation**
```bash
./deploy.sh check              # Validate prerequisites
./deploy.sh status             # Check current deployment status
```

### **Troubleshooting**
- **Unknown command**: Use `./deploy.sh help`
- **Permission errors**: Run `gcloud auth login`
- **Terraform errors**: Run `./deploy.sh init`
- **Deployment issues**: Check `./deploy.sh status`

---

**Need help?** Start with `./deploy.sh help` to see all available commands, or check the specific guides for detailed instructions.
