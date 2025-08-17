# 🚀 Five Rivers Tutoring - Production Deployment (Modular Architecture)

This directory contains the production deployment infrastructure for the Five Rivers Tutoring WordPress application on Google Cloud Platform (GCP) using a **modular Terraform architecture**.

## 🏗️ What This Deployment Does

This **modular Terraform deployment** creates a WordPress production environment by:
- **Provisioning compute resources** (VM, disk, IP, monitoring)
- **Setting up database infrastructure** (Cloud SQL, users, privileges)
- **Deploying WordPress application** (container, configuration, health checks)
- **Managing shared infrastructure** (monitoring, logging, security)

## 📁 Current Directory Structure

```
prod-deploy/
├── terraform/                    # Modular Terraform infrastructure
│   ├── main.tf                  # Main orchestration file
│   ├── variables.tf             # Root variables
│   ├── outputs.tf               # Root outputs
│   ├── shared/                  # Shared infrastructure module
│   │   ├── main.tf             # Monitoring, logging
│   │   ├── variables.tf        # Shared variables
│   │   └── outputs.tf          # Shared outputs
│   ├── database/                # Database module
│   │   ├── main.tf             # Cloud SQL, users
│   │   ├── variables.tf        # Database variables
│   │   └── outputs.tf          # Database outputs
│   ├── compute/                 # Compute module
│   │   ├── main.tf             # VM, disk, IP, monitoring
│   │   ├── variables.tf        # Compute variables
│   │   └── outputs.tf          # Compute outputs
│   ├── wordpress/               # WordPress module
│   │   ├── main.tf             # App deployment, config
│   │   ├── variables.tf        # WordPress variables
│   │   └── outputs.tf          # WordPress outputs
│   ├── plans/                   # Terraform plan files
│   ├── wordpress.tfvars         # WordPress configuration
│   └── terraform.tfvars         # GCP project configuration
├── properties/                   # Environment configuration
│   └── jamr-gcp-foundations.tf  # JAMR-managed infrastructure
├── databasemigration/            # Database scripts (reference)
├── scripts/                      # Deployment scripts
│   ├── deploy-wordpress.sh      # WordPress deployment
│   └── wordpress-management.sh  # WordPress management
├── deploy.sh                     # Main deployment script
└── README.md                     # This file
```

## 🚀 Quick Start Guide

### Prerequisites

1. **Terraform** (version >= 1.0.0) installed and in PATH
2. **Google Cloud CLI** (`gcloud`) authenticated and configured
3. **Access to GCP project** `storied-channel-467012-r6`

### Step 1: Verify Infrastructure Assumptions

This deployment uses these existing resources:
- **GCP Project**: `storied-channel-467012-r6`
- **Region**: `australia-southeast1`
- **Zone**: `australia-southeast1-a`
- **VPC**: `jamr-websites-vpc` (managed by JAMR)
- **Subnet**: `jamr-websites-vpc-web-subnet-prod`

### Step 2: Deploy Infrastructure

**Modular Deployment (Recommended):**
```bash
# Deploy shared infrastructure first
./deploy.sh shared-deploy

# Deploy database resources
./deploy.sh database-deploy

# Deploy compute resources
./deploy.sh compute-deploy

# Deploy WordPress application
./deploy.sh wordpress-deploy
```

**Complete Deployment:**
```bash
./deploy.sh apply
```

## 🎯 Available Commands

### Modular Deployment

```bash
# Component-specific deployments
./deploy.sh shared-deploy      # Shared infrastructure
./deploy.sh database-deploy    # Database resources
./deploy.sh compute-deploy     # Compute resources
./deploy.sh wordpress-deploy   # WordPress application

# Component management
./deploy.sh compute-stop       # Stop compute resources
./deploy.sh compute-start      # Start compute resources
./deploy.sh component-status   # Check all components
```

### Infrastructure Management

```bash
# Show what will be deployed
./deploy.sh plan

# Show current status
./deploy.sh status

# Initialize Terraform
./deploy.sh init

# Destroy all resources (⚠️ DANGEROUS)
./deploy.sh destroy
```

### Cost Optimization

```bash
# Stop all resources for cost savings
./deploy.sh winddown

# Start all resources back up
./deploy.sh windup

# Check winddown status
./deploy.sh windstatus

# Estimate cost savings
./deploy.sh cost-estimate
```

## 🔧 Configuration Details

### What's Hardcoded (Don't Change)

These values are built into the Terraform files:
- **Project ID**: `storied-channel-467012-r6`
- **Region**: `australia-southeast1`
- **Zone**: `australia-southeast1-a`
- **VPC**: `jamr-websites-vpc`
- **Subnet**: `jamr-websites-vpc-web-subnet-prod`
- **Resource Names**: All use `jamr-websites-prod-` prefix

### What You Can Configure

- **WordPress settings** (via `wordpress.tfvars`)
- **Database credentials** (via `wordpress.tfvars`)
- **GCP project settings** (via `terraform.tfvars`)

## 🏗️ Resources Created

### Shared Module
- **Monitoring Group**: WordPress resource monitoring
- **Logging Sink**: Centralized logging (when bucket exists)

### Database Module
- **Cloud SQL Database**: `fiverivertutoring_production_db`
- **Admin User**: `fiverivertutoring_admin`
- **App User**: `fiverivertutoring_app`

### Compute Module
- **VM Instance**: `jamr-websites-prod-wordpress` (Container-Optimized OS)
- **Static IP**: Public IP address for the VM
- **Persistent Disk**: 50GB disk for wp-content
- **Backup Policy**: Daily snapshot schedule
- **Uptime Monitoring**: HTTPS uptime check

### WordPress Module
- **Application Configuration**: Dynamic WordPress config
- **Security Keys**: Randomly generated WordPress keys
- **Health Checks**: Application deployment verification

## 🌐 Network & Security

- **Public Access**: VM runs with public IP for direct access
- **Network Security**: Uses existing JAMR-managed VPC and firewall
- **Encryption**: All disks encrypted at rest
- **Monitoring**: Uptime checks and daily backups

## 📊 Monitoring & Logging

- **Cloud Monitoring**: Resource utilization metrics
- **Uptime Checks**: HTTPS availability monitoring
- **Backup Policies**: Daily disk snapshots
- **Cloud Logging**: Centralized resource logs

## 🚨 Troubleshooting

### Common Issues

1. **Terraform State Locked**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Authentication Issues**
   ```bash
   gcloud auth login
   gcloud config set project storied-channel-467012-r6
   ```

3. **Resource Creation Fails**
   - Check GCP quotas and limits
   - Verify billing is enabled
   - Check IAM permissions

### Required GCP APIs

Ensure these are enabled:
- Compute Engine API
- Cloud SQL Admin API
- Cloud Monitoring API
- Cloud Resource Manager API

## 🔄 Deployment Workflow

```
Shared → Database → Compute → WordPress
  ↓         ↓         ↓         ↓
Monitoring  SQL      VM+Disk   App+Config
```

## 📝 Maintenance

### Regular Tasks
- **Backup Verification**: Test restore procedures monthly
- **Security Updates**: Keep Terraform updated
- **Cost Monitoring**: Review GCP billing
- **Performance Review**: Monitor VM metrics

### Updates
1. Modify appropriate `.tfvars` file with new values
2. Run `./deploy.sh plan` to review changes
3. Run `./deploy.sh apply` to apply updates
4. Test the updated environment

## 🤝 Contributing

When making changes:
1. **Update appropriate module** (shared, database, compute, wordpress)
2. **Update variables** in corresponding `variables.tf`
3. **Test in staging** before production
4. **Document changes** in this README
5. **Follow naming conventions** in the codebase

## 📞 Support

For issues:
1. Check troubleshooting section above
2. Review GCP Cloud Console
3. Check Terraform state: `terraform show`
4. Review Cloud Logging
5. Use component-specific commands for targeted troubleshooting

---

**Last Updated**: December 2024  
**Version**: 3.0.0 (Modular Architecture)  
**Maintainer**: DevOps Team
