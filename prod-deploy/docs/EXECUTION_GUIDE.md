# 🚀 WordPress Deployment Guide - Five Rivers Tutoring

## 🎯 **Choose Your Scenario**

### **Scenario 1: First-Time Deployment** (New Infrastructure)
### **Scenario 2: Update Existing Deployment** (Code/Config Changes)
### **Scenario 3: Troubleshoot Issues** (Fix Problems)
### **Scenario 4: Cost Optimization** (Save Money)

---

## 🚀 **Scenario 1: First-Time Deployment**

### **Prerequisites Check** (2 minutes)
```bash
cd prod-deploy
./deploy.sh check
```

### **Deploy Everything** (15 minutes)
```bash
# Option A: Deploy all at once
./deploy.sh apply

# Option B: Deploy step by step
./deploy.sh shared-deploy      # Creates monitoring groups and logging infrastructure
./deploy.sh database-deploy    # Sets up Cloud SQL database, users, and privileges
./deploy.sh compute-deploy     # Deploys VM instance, persistent disk, and static IP
./deploy.sh wordpress-deploy   # Configures WordPress application and security keys


### **Verify Success** (2 minutes)
```bash
./deploy.sh component-status
./deploy.sh show  # Get your IP address
```

**Result**: Your website is live at `http://[YOUR_IP_ADDRESS]`

---

## 🔄 **Scenario 2: Update Existing Deployment**

### **Update WordPress Code** (5 minutes)
```bash
cd docker
./build-image.sh
docker push gcr.io/storied-channel-467012-r6/fiverivers-tutoring:latest

cd ../prod-deploy
./deploy.sh wordpress-deploy
```

### **Update Infrastructure** (5 minutes)
```bash
./deploy.sh plan
./deploy.sh apply
```

### **Verify Changes** (1 minute)
```bash
./deploy.sh component-status
```

**Result**: Your site is updated with zero downtime

---

## 🚨 **Scenario 3: Troubleshoot Issues**

### **Check What's Broken**
```bash
./deploy.sh component-status
```

### **Common Fixes**

#### **WordPress Not Accessible**
```bash
./deploy.sh wordpress-status
./deploy.sh wordpress-logs
./deploy.sh compute-start  # If VM is stopped
```

#### **Database Connection Failed**
```bash
./deploy.sh database-deploy
gcloud sql users list --instance=jamr-websites-db-prod
```

#### **VM Not Starting**
```bash
./deploy.sh compute-start
./deploy.sh compute-status
```

### **Reset Everything** (Nuclear Option)
```bash
./deploy.sh destroy
./deploy.sh apply
```

**Result**: Issues resolved, system back online

---

## 💰 **Scenario 4: Cost Optimization**

### **Stop Everything** (Save ~$13/month)
```bash
./deploy.sh winddown
```

### **Start When Needed**
```bash
./deploy.sh windup
```

### **Check Costs & Savings**
```bash
./deploy.sh cost-estimate    # Shows running costs + potential savings
```

**Result**: Maximum cost savings when not using

---

## 📋 **Quick Reference Commands**

### **Status & Monitoring**
```bash
./deploy.sh component-status    # Check all components
./deploy.sh wordpress-status    # Check WordPress
./deploy.sh show               # Get IP addresses
./deploy.sh wordpress-logs     # View logs
```

### **Start/Stop Components**
```bash
./deploy.sh compute-stop       # Stop VM (save money)
./deploy.sh compute-start      # Start VM
./deploy.sh winddown           # Stop everything
./deploy.sh windup             # Start everything
```

### **Deploy Specific Components**
```bash
./deploy.sh shared-deploy      # Monitoring/logging
./deploy.sh database-deploy    # Database
./deploy.sh compute-deploy     # VM/storage
./deploy.sh wordpress-deploy   # WordPress app
```

---

## ⚡ **5-Minute Quick Start**

```bash
cd prod-deploy
./deploy.sh check              # Verify prerequisites
./deploy.sh apply              # Deploy everything
./deploy.sh show               # Get your IP
```

**Access your site**: `http://[IP_ADDRESS]`

---

## 🚨 **Emergency Commands**

### **Something's Broken**
```bash
./deploy.sh component-status   # See what's wrong
./deploy.sh wordpress-logs     # Check logs
./deploy.sh compute-start      # Restart VM
```

### **Complete Reset**
```bash
./deploy.sh destroy            # Remove everything
./deploy.sh apply              # Start fresh
```

---

## 💡 **Pro Tips**

- **Always check status first**: `./deploy.sh component-status`
- **Use winddown for cost savings**: Saves ~$13/month when stopped
- **Deploy components individually** for faster troubleshooting
- **Check logs before panicking**: `./deploy.sh wordpress-logs`

---

**🎯 Pick your scenario and follow the steps. Your WordPress site will be live in minutes!**

---

**Last Updated**: December 2024  
**Version**: 3.0.0 (Crisp & Scenario-Based)  
**Maintainer**: DevOps Team
