# Production Deployment - Five Rivers Tutoring

## 🚀 **Production Environment Overview**

The production environment runs on **Google Cloud Platform (GCP)** using:
- **Compute Engine VM** for WordPress hosting
- **Cloud SQL** for MySQL database
- **Terraform** for infrastructure management
- **Docker** for application deployment
- **Direct image transfer** for reliable deployment

## 🏗️ **Infrastructure Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    Google Cloud Platform                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │              Terraform Infrastructure           │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │   Compute VM    │  │     Cloud SQL       │  │
        │  │  - WordPress    │  │   - MySQL 8.0       │  │
        │  │  - Docker       │  │   - Automated       │  │
        │  │  - Auto-scaling │  │   - Backups         │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │              Application Layer                   │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │  WordPress      │  │   Docker Compose    │  │
        │  │  - Production   │  │   - Volume mounts   │  │
        │  │  - Optimized    │  │   - Environment     │  │
        │  │  - Secure       │  │   - Networking      │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
```

## 🔧 **Deployment Strategy**

### **Single Dockerfile Approach**
- **One image**: `fiverivertutoring-wordpress:production`
- **Built locally**: Using `docker/dockerbuild-environments.sh production`
- **Direct transfer**: Image copied directly to VM (no GCR authentication issues)
- **Consistent**: Same image that works in staging

### **Deployment Process**
1. **Build production image** locally
2. **Save image to tar file** for transfer
3. **Copy to VM** using SCP
4. **Load image** on VM using `docker load`
5. **Run container** with proper configuration

## 🚀 **Quick Deployment**

### **1. Build Production Image**
```bash
cd docker
./dockerbuild-environments.sh production
```

### **2. Deploy to Production**
```bash
cd prod-deploy/scripts
./wordpress-management.sh deploy
```

### **3. Check Status**
```bash
./wordpress-management.sh status
```

## 📁 **Directory Structure**

```
prod-deploy/
├── deploy.sh                           # Main deployment script
├── docker-compose.production.yml       # Production Docker Compose
├── scripts/
│   ├── wordpress-management.sh        # WordPress deployment & management
│   ├── deploy-wordpress.sh            # Legacy deployment script
│   └── operations.sh                  # Production operations
├── terraform/                          # Infrastructure as Code
│   ├── main.tf                        # Main Terraform configuration
│   ├── compute/                       # VM configuration
│   ├── database/                      # Cloud SQL configuration
│   ├── wordpress/                     # WordPress-specific resources
│   └── wordpress.tfvars               # WordPress variables
├── properties/                         # Configuration files
│   └── fiverivertutoring-wordpress.properties
└── docs/                              # Additional documentation
```

## 🔑 **Key Scripts**

### **Main Deployment Script**
- **`deploy.sh`**: Orchestrates entire infrastructure deployment
- **Commands**: `init`, `plan`, `apply`, `wp-deploy`, `status`

### **WordPress Management**
- **`wordpress-management.sh`**: Handles WordPress deployment and management
- **Commands**: `deploy`, `start`, `stop`, `status`, `logs`, `backup`

### **Operations**
- **`operations.sh`**: Production maintenance and monitoring
- **Commands**: `cleanup-images`, `https-status`, `cost-estimate`

## 🐳 **Docker Deployment**

### **Production Docker Compose**
```yaml
services:
  fiverivers-wp:
    image: fiverivertutoring-wordpress:production
    container_name: fiverivers-wp-prod
    restart: always
    env_file:
      - fiverivertutoring-wordpress.properties
    ports:
      - "80:80"
    volumes:
      - fiverivers_uploads:/var/www/html/wp-content/uploads
      - fiverivers_cache:/var/www/html/wp-content/cache
```

### **Key Features**
- **No wp-content mount**: Uses image content (like staging)
- **Volume mounts**: Only uploads and cache for persistence
- **Production image**: Built with `ENVIRONMENT=production`
- **Auto-restart**: Container restarts automatically

## 🏗️ **Infrastructure Management**

### **Terraform Commands**
```bash
cd prod-deploy/terraform

# Initialize Terraform
terraform init

# Plan changes
terraform plan -var-file="wordpress.tfvars"

# Apply changes
terraform apply -var-file="wordpress.tfvars"

# Show current state
terraform show
```

### **Infrastructure Components**
- **Compute Engine VM**: WordPress hosting
- **Cloud SQL**: MySQL database
- **VPC Network**: Secure networking
- **Firewall Rules**: HTTP/HTTPS access
- **Load Balancer**: Traffic distribution (if needed)

## 🔐 **Security Features**

### **Network Security**
- **VPC**: Isolated network environment
- **Firewall**: Restricted access to necessary ports
- **IAM**: Service account with minimal permissions
- **HTTPS**: SSL/TLS encryption (configurable)

### **Application Security**
- **Production image**: Security hardened
- **PHP optimizations**: OPcache enabled
- **File permissions**: Proper ownership and access
- **Environment isolation**: Separate from development

## 📊 **Monitoring & Maintenance**

### **Health Checks**
```bash
# Check WordPress status
./wordpress-management.sh status

# View logs
./wordpress-management.sh logs

# Check VM status
gcloud compute instances describe jamr-websites-prod-wordpress --zone=australia-southeast1-a
```

### **Backup & Recovery**
```bash
# Create WordPress backup
./wordpress-management.sh backup

# Database backup (via Cloud SQL)
gcloud sql export sql jamr-websites-prod-db gs://backup-bucket/backup.sql
```

## 💰 **Cost Management**

### **Resource Optimization**
```bash
# Stop VM (save ~$6/month)
./deploy.sh compute-stop

# Stop everything (save ~$15/month)
./deploy.sh winddown

# Start resources
./deploy.sh windup
```

### **Cost Estimation**
```bash
# Estimate monthly costs
./deploy.sh cost-estimate

# Check current resource status
./deploy.sh component-status
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Deployment Failures**
```bash
# Check VM status
gcloud compute instances describe jamr-websites-prod-wordpress --zone=australia-southeast1-a

# Check container logs
./wordpress-management.sh logs

# Verify image transfer
docker images | grep fiverivertutoring-wordpress
```

#### **Database Connection Issues**
```bash
# Check Cloud SQL status
gcloud sql instances describe jamr-websites-prod-db

# Verify network access
gcloud sql instances patch jamr-websites-prod-db --authorized-networks=YOUR_IP
```

#### **WordPress Blank Page**
- **Cause**: Usually volume mount issues or missing content
- **Solution**: Ensure using Docker image content, not empty volumes
- **Check**: Verify `wp-content` directory in container

### **Debug Commands**
```bash
# SSH into VM
gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --tunnel-through-iap

# Check container status
docker ps -a

# Inspect container
docker inspect fiverivers-wp-prod

# Check WordPress files
docker exec -it fiverivers-wp-prod ls -la /var/www/html/wp-content
```

## 🔄 **Deployment Workflow**

### **Full Deployment Process**
1. **Infrastructure**: `./deploy.sh apply` (Terraform)
2. **Build Image**: `docker/dockerbuild-environments.sh production`
3. **Deploy WordPress**: `./wordpress-management.sh deploy`
4. **Verify**: `./wordpress-management.sh status`

### **Update Process**
1. **Make changes** in development
2. **Test in staging** environment
3. **Build new image** with changes
4. **Deploy to production** using same process

## 📚 **Related Documentation**

- [Main Project README](../README.md) - Project overview
- [Docker Architecture](../docker/README.md) - Image building strategy
- [Staging Deployment](../staging-deploy/README.md) - Staging environment
- [Development Guide](../develop-deploy/README.md) - Local development

## 🎯 **Best Practices**

1. **Always test in staging** before production deployment
2. **Use versioned images** for reproducible deployments
3. **Monitor resource usage** to optimize costs
4. **Regular backups** of both WordPress and database
5. **Security updates** for base images and dependencies
6. **Document changes** for team knowledge sharing

## 🎉 **Summary**

The production deployment provides:
- **Reliable infrastructure** managed by Terraform
- **Consistent deployments** using the same Docker image as staging
- **Cost optimization** with easy start/stop capabilities
- **Security hardening** for production workloads
- **Easy management** through automated scripts

**Production-ready WordPress deployment with enterprise-grade infrastructure!** 🚀
