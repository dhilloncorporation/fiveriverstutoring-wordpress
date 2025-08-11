# 🚀 Five Rivers Tutoring - Production Deployment Execution Order

This document provides the complete execution order for deploying your WordPress site to production (Google Cloud Platform).

## 📋 Prerequisites

Before starting, ensure you have:
- ✅ **GCloud CLI** installed and authenticated
- ✅ **Terraform** installed
- ✅ **Docker** installed locally
- ✅ **Git** repository with your code
- ✅ **GCP Project** created with billing enabled

## 🎯 Deployment Phases

### **Phase 1: Infrastructure Setup** 🏗️
**Purpose**: Create GCP infrastructure (VM, networking, storage)

### **Phase 2: Database Migration** 🗄️
**Purpose**: Set up and populate production database

### **Phase 3: Content Deployment** 📦
**Purpose**: Deploy WordPress content and configuration

### **Phase 4: Application Deployment** 🚀
**Purpose**: Deploy WordPress application to GCP VM

---

## 📝 Detailed Execution Order

### **Phase 1: Infrastructure Setup**

#### Step 1.1: Initialize GCloud
```bash
# Navigate to production deployment folder
cd prod-deploy

# Initialize GCloud (if not done before)
gcloud init
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_GCP_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable monitoring.googleapis.com
```

#### Step 1.2: Deploy Infrastructure with Terraform
```bash
# Navigate to Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=production.tfvars -out=production-plan.tfplan

# Review the plan
terraform show production-plan.tfplan

# Apply infrastructure
terraform apply production-plan.tfplan

# Get VM IP address
VM_IP=$(terraform output -raw wordpress_vm_ip)
ZONE=$(terraform output -raw wordpress_zone)

echo "VM IP: $VM_IP"
echo "Zone: $ZONE"
```

**Expected Output:**
- ✅ GCP VM instance created
- ✅ Static IP assigned
- ✅ Persistent disk attached
- ✅ Network configured
- ✅ VM IP address obtained

---

### **Phase 2: Database Migration**

#### Step 2.1: Set up Production Database Configuration
```bash
# Navigate to database migration folder
cd ../databasemigration

# Copy example configuration
cp env.production.example env.production

# Edit production configuration
nano env.production
```

**Update these values in `env.production`:**
```bash
WORDPRESS_DB_HOST=YOUR_GCP_DB_HOST
WORDPRESS_DB_PASSWORD=YOUR_SECURE_PASSWORD
PRODUCTION_DOMAIN=YOUR_PRODUCTION_DOMAIN
GCP_PROJECT_ID=YOUR_GCP_PROJECT_ID
```

#### Step 2.2: Deploy Database to Production
```bash
# Deploy from staging to production (RECOMMENDED)
./production-deploy.sh staging-to-production

# OR deploy directly from develop
./production-deploy.sh develop-to-production

# Verify database deployment
./production-deploy.sh verify-production
```

**Expected Output:**
- ✅ Production database created
- ✅ Data migrated from staging/develop
- ✅ URLs updated to production domain
- ✅ Database verification successful

---

### **Phase 3: Content Migration**

#### Step 3.1: Copy WordPress Content to GCP VM
```bash
# Navigate to content migration folder
cd ../content-migration

# Copy wp-content to VM persistent disk
./copy-content-to-persistent-disk.sh $VM_IP $ZONE $USER
```

**Expected Output:**
- ✅ wp-content copied to VM
- ✅ Permissions set correctly
- ✅ Docker Compose restarted

---

### **Phase 4: Application Deployment**

#### Step 4.1: Deploy WordPress Application
```bash
# Navigate to deployment folder
cd ../deployment

# Deploy WordPress with Docker Compose
./deploy-on-vm.sh
```

**Expected Output:**
- ✅ Docker Compose file copied to VM
- ✅ WordPress container started
- ✅ Application accessible at VM IP

---

## 🔄 Complete Workflow Commands

### **One-Command Deployment (After Setup)**
```bash
# Complete deployment workflow
cd gcp-deploy

# 1. Deploy infrastructure
cd terraform && terraform apply -var-file=production.tfvars && cd ..

# 2. Get VM details
VM_IP=$(cd terraform && terraform output -raw wordpress_vm_ip && cd ..)
ZONE=$(cd terraform && terraform output -raw wordpress_zone && cd ..)

# 3. Deploy database
cd databasemigration && ./production-deploy.sh staging-to-production && cd ..

# 4. Deploy content
cd content-migration && ./copy-content-to-persistent-disk.sh $VM_IP $ZONE $USER && cd ..

# 5. Deploy application
cd deployment && ./deploy-on-vm.sh && cd ..

echo "🎉 Deployment Complete! Visit: http://$VM_IP:8081"
```

---

## 🛠️ Maintenance Operations

### **Database Operations**
```bash
cd gcp-deploy/databasemigration

# Backup production database
./production-deploy.sh backup-production

# Restore from backup
./production-deploy.sh restore-production backup_file.sql

# Verify database status
./production-deploy.sh verify-production
```

### **Content Updates**
```bash
cd gcp-deploy/content-migration

# Update wp-content on VM
./copy-content-to-persistent-disk.sh $VM_IP $ZONE $USER
```

### **Application Updates**
```bash
cd gcp-deploy/deployment

# Redeploy application
./deploy-on-vm.sh
```

---

## 🚨 Troubleshooting

### **Common Issues & Solutions**

#### Infrastructure Issues
```bash
# Check Terraform state
cd terraform
terraform state list
terraform show

# Destroy and recreate (if needed)
terraform destroy -var-file=production.tfvars
terraform apply -var-file=production.tfvars
```

#### Database Issues
```bash
cd databasemigration

# Check database connectivity
mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -e "SELECT 1;"

# Reset database
./production-deploy.sh develop-to-production
```

#### VM Issues
```bash
# Check VM status
gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE

# SSH into VM
gcloud compute ssh $USER@$VM_IP --zone=$ZONE

# Check Docker containers
sudo docker ps
sudo docker logs fiverivers-wp-prod
```

---

## 📊 Verification Checklist

After deployment, verify:

### **Infrastructure** ✅
- [ ] VM instance running
- [ ] Static IP assigned
- [ ] Persistent disk attached
- [ ] Network configured

### **Database** ✅
- [ ] Production database exists
- [ ] Data migrated successfully
- [ ] URLs updated correctly
- [ ] Database accessible

### **Content** ✅
- [ ] wp-content copied to VM
- [ ] Permissions set correctly
- [ ] Files accessible

### **Application** ✅
- [ ] WordPress container running
- [ ] Application accessible
- [ ] No errors in logs
- [ ] Site loads correctly

---

## 🔗 File Locations

### **Infrastructure**
- `terraform/` - Terraform configuration files
- `terraform/production.tfvars` - Production variables

### **Database Migration**
- `databasemigration/env.production` - Production database config
- `databasemigration/production-deploy.sh` - Database deployment script

### **Content Migration**
- `content-migration/copy-content-to-persistent-disk.sh` - Content copy script

### **Application Deployment**
- `deployment/docker-compose.prod.yml` - Production Docker config
- `deployment/deploy-on-vm.sh` - VM deployment script

### **Configuration**
- `config/wordpress-production-config.php` - WordPress config template

### **Documentation**
- `docs/README.md` - General documentation
- `docs/gcloudcommand.sh` - GCloud command reference

---

## ⚡ Quick Reference

### **First-Time Setup**
1. `gcloud init && gcloud auth login`
2. `cd terraform && terraform apply -var-file=production.tfvars`
3. `cd ../databasemigration && ./production-deploy.sh setup-production`
4. `cd ../content-migration && ./copy-content-to-persistent-disk.sh $VM_IP $ZONE $USER`
5. `cd ../deployment && ./deploy-on-vm.sh`

### **Regular Updates**
1. `cd databasemigration && ./production-deploy.sh staging-to-production`
2. `cd ../content-migration && ./copy-content-to-persistent-disk.sh $VM_IP $ZONE $USER`
3. `cd ../deployment && ./deploy-on-vm.sh`

### **Emergency Rollback**
1. `cd databasemigration && ./production-deploy.sh backup-production`
2. `cd databasemigration && ./production-deploy.sh restore-production backup_file.sql`
3. `cd ../deployment && ./deploy-on-vm.sh`

---

**🎯 Remember**: Always test in staging before deploying to production! 