# Production Deployment Execution Order

## 🚀 **Scripts Overview**

This document outlines the execution order and scenarios for the production deployment scripts.

### **Scripts Location:**
```
prod-deploy/
├── scripts/
│   ├── deploy.sh              # Main infrastructure deployment
│   ├── operations.sh          # Day-to-day operations & maintenance
│   ├── wordpress-management.sh # WordPress application management
│   └── execution-order.md     # This file
├── terraform/                 # Infrastructure as Code
├── properties/                # Configuration files
└── plans/                     # Terraform plans
```

## 📋 **Execution Order by Scenario**

### **Scenario 1: First-Time Setup (Greenfield)**
```bash
# 1. Initialize infrastructure
./deploy.sh init

# 2. Plan infrastructure
./deploy.sh plan

# 3. Deploy infrastructure
./deploy.sh apply

# 4. Deploy WordPress application
./deploy.sh wp-deploy
```

### **Scenario 2: Infrastructure Updates**
```bash
# 1. Plan changes
./deploy.sh plan

# 2. Apply infrastructure changes
./deploy.sh apply

# 3. WordPress continues running (no redeploy needed)
```

### **Scenario 2a: Using Existing Plan Files**
```bash
# 1. Check available plans
ls -la ../plans/

# 2. Apply existing plan (if available)
./deploy.sh apply ../plans/infrastructure-plan.tfplan

# 3. Or create new plan if needed
./deploy.sh plan
```

### **Scenario 3: Application Updates Only**
```bash
# 1. Build new Docker image locally
cd docker
./build-environments.sh production

# 2. Deploy WordPress with new image
cd ../prod-deploy/scripts
./deploy.sh wp-dep
```

### **Scenario 4: Emergency Recovery**
```bash
# 1. Check infrastructure status
./operations.sh status

# 2. Restart WordPress if needed
./operations.sh wp-restart

# 3. Check logs for issues
./operations.sh wp-logs
```

## 📋 **Plan File Management**

### **Available Plan Files:**
```bash
# Check existing plans
ls -la ../plans/

# Current available plan:
# - infrastructure-plan.tfplan (54KB) - Latest infrastructure plan
```

### **Using Existing Plans:**
```bash
# Apply existing plan (recommended for consistency)
./deploy.sh apply ../plans/infrastructure-plan.tfplan

# Create new plan (if infrastructure changes needed)
./deploy.sh plan

# View plan details
./deploy.sh show-plan ../plans/infrastructure-plan.tfplan
```

### **Plan File Best Practices:**
- **Use existing plans** when no infrastructure changes needed
- **Create new plans** when making infrastructure modifications
- **Keep plans organized** in the plans/ directory
- **Version control plans** for audit trails

## 🎯 **Script Responsibilities**

### **`deploy.sh` - Infrastructure Management**
- **Terraform initialization** and state management
- **Infrastructure planning** and deployment
- **HTTPS setup** and SSL certificate management
- **Infrastructure status** and monitoring

### **`operations.sh` - Day-to-Day Operations**
- **WordPress application** status and management
- **Cost optimization** (start/stop VMs)
- **Maintenance tasks** and cleanup
- **Troubleshooting** and debugging

### **`wordpress-management.sh` - Application Deployment**
- **Docker image transfer** to VM
- **Container management** (start/stop/restart)
- **Application configuration** and deployment
- **Database connection** management

## 🔄 **Common Workflows**

### **Daily Operations**
```bash
# Check everything is running
./operations.sh status

# View WordPress logs if needed
./operations.sh wp-logs

# Start/stop for cost optimization
./operations.sh winddown  # Stop at night
./operations.sh windup    # Start in morning
```

### **Weekly Maintenance**
```bash
# Check infrastructure health
./deploy.sh status

# Review costs and optimization
./operations.sh check-billing

# Clean up old Docker images
./operations.sh cleanup-images
```

### **Monthly Updates**
```bash
# Plan infrastructure changes
./deploy.sh plan

# Apply if needed
./deploy.sh apply

# Update WordPress application
./deploy.sh wp-deploy
```

## 🚨 **Emergency Procedures**

### **WordPress Down**
```bash
# 1. Check container status
./operations.sh wp-status

# 2. Restart if needed
./operations.sh wp-restart

# 3. Check logs
./operations.sh wp-logs

# 4. Redeploy if necessary
./deploy.sh wp-deploy
```

### **Infrastructure Issues**
```bash
# 1. Check VM status
./operations.sh status

# 2. Restart compute resources
./operations.sh compute-restart

# 3. Check Terraform state
./deploy.sh status

# 4. Reapply if needed
./deploy.sh apply
```

### **Database Issues**
```bash
# 1. Check database status
./operations.sh db-status

# 2. Restart database if needed
./operations.sh db-restart

# 3. Check WordPress database connection
./operations.sh wp-status
```

## 💡 **Best Practices**

### **Before Making Changes**
1. **Always plan first** - `./deploy.sh plan`
2. **Check current status** - `./operations.sh status`
3. **Verify prerequisites** - Ensure all services are running

### **During Deployment**
1. **Monitor logs** - Watch for errors in real-time
2. **Test functionality** - Verify WordPress is accessible
3. **Check metrics** - Monitor performance and resources

### **After Changes**
1. **Verify deployment** - Check all services are running
2. **Test functionality** - Ensure WordPress works correctly
3. **Update documentation** - Record any changes made

## 🔧 **Troubleshooting Guide**

### **Common Issues & Solutions**

#### **SSH Connection Problems**
```bash
# Use operations script
./operations.sh troubleshoot-ssh

# Check VM status
./operations.sh status
```

#### **Docker Image Issues**
```bash
# Check image status
./operations.sh debug-artifacts

# Clean up old images
./operations.sh cleanup-images
```

#### **WordPress Container Issues**
```bash
# Check container status
./operations.sh wp-status

# View logs
./operations.sh wp-logs

# Restart container
./operations.sh wp-restart
```

## 📊 **Monitoring & Alerts**

### **Key Metrics to Watch**
- **VM status** - Running/Stopped
- **Container health** - WordPress container status
- **Database connectivity** - WordPress database access
- **HTTPS status** - SSL certificate validity
- **Resource usage** - CPU, memory, disk

### **Automated Checks**
```bash
# Set up cron jobs for monitoring
0 */6 * * * cd /path/to/prod-deploy/scripts && ./operations.sh status
0 2 * * * cd /path/to/prod-deploy/scripts && ./operations.sh winddown
0 8 * * * cd /path/to/prod-deploy/scripts && ./operations.sh windup
```

## 🎉 **Summary**

### **Script Execution Priority:**
1. **`deploy.sh`** - Infrastructure foundation
2. **`wordpress-management.sh`** - Application deployment
3. **`operations.sh`** - Ongoing maintenance

### **Key Principles:**
- **Always plan before applying** infrastructure changes
- **Use the right script for the right task**
- **Monitor and verify after any changes**
- **Keep documentation updated**

### **Success Metrics:**
- ✅ **Infrastructure stable** and running
- ✅ **WordPress accessible** and functional
- ✅ **Costs optimized** and monitored
- ✅ **Maintenance automated** where possible

---

**Last Updated**: $(date)
**Version**: 1.0
**Maintainer**: DevOps Team
