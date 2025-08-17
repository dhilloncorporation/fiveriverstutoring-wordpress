# 🌐 WordPress Deployment Guide - Five Rivers Tutoring (Modular Architecture)

## 📋 **Overview**

This guide covers the WordPress-specific deployment process using the new **modular Terraform architecture**. WordPress is deployed as a separate module that depends on compute and database resources.

## 🏗️ **WordPress Module Architecture**

### **Module Dependencies**
```
WordPress Module
       ↓
   Depends on:
   ├── Shared Module (monitoring, logging)
   ├── Database Module (Cloud SQL, users)
   └── Compute Module (VM, disk, IP)
```

### **What WordPress Module Manages**
- **Application Configuration**: Dynamic WordPress config generation
- **Security Keys**: Randomly generated WordPress salts and keys
- **Health Checks**: Application deployment verification
- **Container Configuration**: WordPress container settings

---

## 🚀 **WordPress Deployment Process**

### **Prerequisites**

Before deploying WordPress, ensure these are ready:
- ✅ **Shared Module**: Monitoring and logging infrastructure
- ✅ **Database Module**: Cloud SQL instance and users
- ✅ **Compute Module**: VM instance with persistent disk
- ✅ **Docker Image**: `fiverivers-tutoring:latest` built and pushed

### **Step 1: Build and Push Docker Image**

#### **1.1: Build Local Image**
```bash
cd docker
./build-image.sh
```

**Expected Output:**
```
🏗️ Building Five Rivers Tutoring Docker Image...
[INFO] Building Docker image: fiverivers-tutoring:latest
[INFO] ✅ Docker image built successfully!
```

#### **1.2: Push to GCP Container Registry**
```bash
# Tag for GCP
docker tag fiverivers-tutoring:latest gcr.io/storied-channel-467012-r6/fiverivers-tutoring:latest

# Push to GCP
docker push gcr.io/storied-channel-467012-r6/fiverivers-tutoring:latest
```

### **Step 2: Deploy WordPress Module**

#### **2.1: Deploy WordPress Application**
```bash
cd ../prod-deploy
./deploy.sh wordpress-deploy
```

**Expected Output:**
```
================================
Deploying WordPress Application
================================
[INFO] This will deploy WordPress configuration and application...
[INFO] WordPress application deployed successfully!
```

#### **2.2: Verify WordPress Deployment**
```bash
./deploy.sh component-status
```

**Expected Output:**
```
[INFO] WordPress: Application deployed successfully
```

---

## 🔧 **WordPress Configuration Details**

### **Dynamic Configuration Generation**

The WordPress module automatically generates:
- **`wordpress-config.php`**: Database connection and WordPress settings
- **Security Keys**: Randomly generated WordPress salts
- **Environment Variables**: Container environment configuration

### **Configuration Sources**

| Setting | Source | File |
|---------|--------|------|
| **Database Host** | `wordpress.tfvars` | `wordpress_db_host` |
| **Database Name** | `wordpress.tfvars` | `wordpress_db_name` |
| **Database User** | `wordpress.tfvars` | `wordpress_db_user` |
| **Database Password** | `wordpress.tfvars` | `wordpress_db_password` |
| **Domain** | `wordpress.tfvars` | `wordpress_domain` |

### **Container Configuration**

```terraform
# WordPress container runs on Container-Optimized OS
# Automatic startup via gce-container-declaration metadata
# Persistent storage mounted at /var/www/html/wp-content
# Health checks verify application availability
```

---

## 🌐 **Accessing Your WordPress Site**

### **Public Access**
- **Website URL**: `http://[YOUR_STATIC_IP]`
- **Admin Panel**: `http://[YOUR_STATIC_IP]/wp-admin`
- **Static IP**: Available in Terraform outputs

### **Get Your IP Address**
```bash
./deploy.sh show
```

**Look for:**
```
wordpress_static_ip = "35.189.11.218"
wordpress_external_ip = "34.40.187.227"
```

---

## 🔍 **WordPress Health Monitoring**

### **Health Check Commands**

#### **Check Application Status**
```bash
./deploy.sh wordpress-status
```

**Expected Output:**
```
================================
Checking WordPress Status
================================
[INFO] VM Status: RUNNING
[INFO] IP Address: [YOUR_IP_ADDRESS]
[INFO] ✅ WordPress is accessible at http://[YOUR_IP_ADDRESS]
```

#### **View Application Logs**
```bash
./deploy.sh wordpress-logs
```

**Expected Output:**
```
================================
Viewing WordPress Logs
================================
[INFO] Fetching WordPress container logs...
[WordPress container logs will be displayed]
```

#### **Check Component Status**
```bash
./deploy.sh component-status
```

---

## 🚨 **WordPress Troubleshooting**

### **Common Issues & Solutions**

#### **Issue 1: WordPress Not Accessible**
```bash
# Check VM status
./deploy.sh compute-status

# Check container logs
./deploy.sh wordpress-logs

# Verify IP address
./deploy.sh show
```

#### **Issue 2: Database Connection Failed**
```bash
# Check database status
./deploy.sh database-deploy

# Verify database users
gcloud sql users list --instance=jamr-websites-db-prod

# Test database connection
gcloud sql connect jamr-websites-db-prod --user=root
```

#### **Issue 3: Container Not Starting**
```bash
# Check VM metadata
gcloud compute instances describe jamr-websites-prod-wordpress --zone=australia-southeast1-a

# Restart VM if needed
./deploy.sh compute-start
```

#### **Issue 4: Configuration Issues**
```bash
# Redeploy WordPress configuration
./deploy.sh wordpress-deploy

# Check generated config
terraform output -json | jq '.wordpress_config_file.value'
```

---

## 🔄 **WordPress Updates & Maintenance**

### **Update WordPress Application**

#### **Option 1: Redeploy Module**
```bash
./deploy.sh wordpress-deploy
```

#### **Option 2: Update Docker Image**
```bash
# Build new image
cd docker
./build-image.sh

# Push to GCP
docker push gcr.io/storied-channel-467012-r6/fiverivers-tutoring:latest

# Redeploy WordPress
cd ../prod-deploy
./deploy.sh wordpress-deploy
```

### **WordPress Content Management**

- **Content Storage**: Persistent disk mounted at `/var/www/html/wp-content`
- **Backup Policy**: Daily automated backups via compute module
- **Content Migration**: Use WordPress import/export or direct file copy

---

## 💰 **WordPress Cost Management**

### **Running Costs**
- **WordPress Module**: Minimal cost (configuration only)
- **Main Costs**: Compute (VM) + Database (Cloud SQL)
- **Total**: ~$43/month for complete infrastructure

### **Cost Optimization**
```bash
# Stop all resources (including WordPress)
./deploy.sh winddown

# Start all resources back up
./deploy.sh windup

# Check cost savings
./deploy.sh cost-estimate
```

---

## 📊 **WordPress Performance Monitoring**

### **Available Metrics**
- **VM Performance**: CPU, memory, disk usage
- **Container Health**: Application availability
- **Database Performance**: Connection pool, query performance
- **Network**: Bandwidth, latency

### **Monitoring Commands**
```bash
# Check uptime monitoring
./deploy.sh show | grep uptime

# View resource utilization
gcloud compute instances describe jamr-websites-prod-wordpress --zone=australia-southeast1-a
```

---

## 🔐 **WordPress Security Features**

### **Security Measures**
- ✅ **Container Isolation**: WordPress runs in isolated container
- ✅ **Persistent Storage**: Content stored on encrypted persistent disk
- ✅ **Database Security**: Separate users with minimal privileges
- ✅ **Network Security**: Uses existing JAMR-managed VPC
- ✅ **Automatic Updates**: Container restarts on failure

### **Security Best Practices**
- **Regular Updates**: Keep WordPress core and plugins updated
- **User Management**: Use strong passwords for admin accounts
- **Backup Strategy**: Daily automated backups via compute module
- **Monitoring**: Uptime checks and resource monitoring

---

## 📝 **Post-Deployment Checklist**

- [ ] **WordPress accessible** at public IP
- [ ] **Admin panel working** at `/wp-admin`
- [ ] **Database connection** successful
- [ ] **Content displaying** correctly
- [ ] **Health checks passing**
- [ ] **Monitoring active**
- **Documentation updated** with IP address

---

## 🚀 **Quick WordPress Commands**

```bash
# Deploy WordPress
./deploy.sh wordpress-deploy

# Check status
./deploy.sh wordpress-status

# View logs
./deploy.sh wordpress-logs

# Check all components
./deploy.sh component-status

# Show outputs (IP addresses)
./deploy.sh show
```

---

**🎯 Your WordPress site will be live and accessible from anywhere on the internet!**

---

**Last Updated**: December 2024  
**Version**: 3.0.0 (Modular Architecture)  
**Maintainer**: DevOps Team
