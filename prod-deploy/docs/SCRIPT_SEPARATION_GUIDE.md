# Script Separation Guide - deploy.sh vs operations.sh

## Overview
We've separated the monolithic `deploy.sh` script into two focused, maintainable scripts:

1. **`deploy.sh`** - Core deployment operations (Terraform, infrastructure)
2. **`operations.sh`** - Day-to-day operations (cleanup, monitoring, maintenance)

## 🎯 **When to Use Each Script**

### **`deploy.sh` - Infrastructure Deployment**
Use this script for:
- **Initial setup** and infrastructure deployment
- **Terraform operations** (init, plan, apply, destroy)
- **WordPress application deployment**
- **HTTPS setup** and configuration
- **Infrastructure planning** and management
- **Major changes** to your infrastructure

**Example commands:**
```bash
./deploy.sh init            # Initialize Terraform
./deploy.sh plan            # Review deployment plan
./deploy.sh apply           # Deploy infrastructure
./deploy.sh wp-deploy       # Deploy WordPress app
./deploy.sh wp-https-setup  # Setup HTTPS
```

### **`operations.sh` - Daily Operations**
Use this script for:
- **Application monitoring** and status checks
- **Docker image management** and cleanup
- **Cost optimization** (start/stop resources)
- **Application backup** and restore
- **HTTPS certificate management**
- **Routine maintenance** tasks

**Example commands:**
```bash
./operations.sh status          # Check infrastructure status
./operations.sh app-status      # Check WordPress status
./operations.sh preview-cleanup # Preview Docker cleanup (safe)
./operations.sh cleanup-images  # Clean up old Docker images
./operations.sh compute-stop    # Stop VM to save costs
./operations.sh winddown        # Stop all resources
```

## 🔄 **Migration from Old deploy.sh**

### **What Stayed in deploy.sh**
- `init` - Initialize Terraform
- `plan` - Plan deployment
- `apply` - Deploy infrastructure
- `destroy` - Destroy infrastructure
- `wp-deploy` - Deploy WordPress application
- `wp-https-setup` - Setup HTTPS (initial configuration only)
- `check` - Check prerequisites
- `graph` - Generate infrastructure graphs
- `wp-infra-deploy` - Deploy compute resources
- `wp-db-deploy` - Deploy database resources
- `wp-start/stop/status/logs/backup` - WordPress application management
- `wp-infra-start/stop/status` - Compute resource management
- `wp-winddown/windup/windstatus` - Cost optimization
- `wp-cost-estimate` - Cost estimation

### **What Moved to operations.sh**
- `list-images` → `./operations.sh list-images`
- `show-images` → `./operations.sh show-images`
- `preview-cleanup` → `./operations.sh preview-cleanup`
- `cleanup-images` → `./operations.sh cleanup-images`
- `cleanup-docker` → `./operations.sh cleanup-docker`
- `status` → `./operations.sh status`
- `app-status` → `./operations.sh app-status`
- `app-logs` → `./operations.sh app-logs`
- `app-start` → `./operations.sh app-start`
- `app-stop` → `./operations.sh app-stop`
- `app-restart` → `./operations.sh app-restart`
- `app-backup` → `./operations.sh app-backup`
- `app-restore` → `./operations.sh app-restore`
- `compute-stop` → `./operations.sh compute-stop`
- `compute-start` → `./operations.sh compute-start`
- `winddown` → `./operations.sh winddown`
- `windup` → `./operations.sh windup`
- `windstatus` → `./operations.sh windstatus`
- `cost-estimate` → `./operations.sh cost-estimate`
- **All operational HTTPS commands** → `./operations.sh https-status, https-test, https-renew, https-logs`
- **Database management** → `./operations.sh db-restart, db-status`

## 📋 **Common Workflows**

### **Initial Deployment**
```bash
# 1. Deploy infrastructure
./deploy.sh init
./deploy.sh plan
./deploy.sh apply

# 2. Deploy WordPress
./deploy.sh deploy-wordpress

# 3. Setup HTTPS
./deploy.sh https-setup
```

### **Daily Operations**
```bash
# 1. Check status
./operations.sh status
./operations.sh app-status

# 2. View logs if needed
./operations.sh app-logs

# 3. Perform maintenance
./operations.sh preview-cleanup
./operations.sh cleanup-images
```

### **Cost Optimization**
```bash
# Stop resources to save costs
./operations.sh compute-stop    # Save ~$6/month
./operations.sh winddown        # Save ~$15/month

# Start resources back up
./operations.sh compute-start
./operations.sh windup
```

### **Troubleshooting**
```bash
# Check infrastructure
./operations.sh status

# Check application
./operations.sh app-status
./operations.sh app-logs

# Check HTTPS
./operations.sh https-status
./operations.sh https-test
```

## 🚨 **Important Notes**

### **Script Dependencies**
- **`operations.sh`** can be run independently
- **`deploy.sh`** requires Terraform to be initialized
- Both scripts assume you're in the `prod-deploy` directory

### **Safety Features**
- **`operations.sh`** includes all the safety improvements for Docker cleanup
- **Preview mode** is available for cleanup operations
- **Latest tag protection** prevents accidental deletion of production images

### **Help and Documentation**
- **`./deploy.sh help`** - Shows deployment commands
- **`./operations.sh help`** - Shows operational commands
- **`docs/README.md`** - Complete documentation index

## 🔧 **Customization**

### **Adding New Commands**
- **Infrastructure commands** → Add to `deploy.sh`
- **Operational commands** → Add to `operations.sh`
- **Shared utilities** → Consider creating a separate `utils.sh`

### **Script Organization**
```
prod-deploy/
├── deploy.sh                    # Infrastructure deployment
├── operations.sh                # Daily operations
├── utils.sh                     # Shared utilities (future)
└── docs/                        # Documentation
```

## 📚 **Related Documentation**

- **[Main Documentation Index](README.md)** - Complete documentation overview
- **[Docker Cleanup Guide](DOCKER_CLEANUP_IMPROVEMENTS.md)** - Safe cleanup operations
- **[Firewall Configuration](FIREWALL_FIX_SUMMARY.md)** - Network setup guide
- **[HTTPS Setup Guide](HTTPS_SETUP_GUIDE.md)** - SSL configuration

## 🎉 **Benefits of Separation**

1. **Focused Responsibility**: Each script has a clear, single purpose
2. **Easier Maintenance**: Smaller, focused scripts are easier to understand and modify
3. **Better Organization**: Logical separation of concerns
4. **Improved Safety**: Operational functions include enhanced safety features
5. **Easier Testing**: Can test operational functions without affecting infrastructure
6. **Better Documentation**: Clear separation makes it easier to document each area

---

**Need help?** Use `./deploy.sh help` for deployment commands or `./operations.sh help` for operational commands.