# 🆓 FREE HTTPS Setup Guide - Let's Encrypt with Terraform

## 📋 **What We Just Added:**

### **New Files Created:**
- `prod-deploy/terraform/https/main.tf` - HTTPS module with Let's Encrypt
- `prod-deploy/terraform/https/variables.tf` - HTTPS module variables
- `prod-deploy/terraform/https/outputs.tf` - HTTPS module outputs

### **Files Modified:**
- `prod-deploy/terraform/main.tf` - Added HTTPS module call
- `prod-deploy/terraform/variables.tf` - Added HTTPS variables
- `prod-deploy/terraform/wordpress.tfvars` - Added domain configuration
- `prod-deploy/terraform/outputs.tf` - Added HTTPS outputs

## 🚀 **Step-by-Step Deployment:**

### **Step 1: Update Your Domain**
```bash
# Edit prod-deploy/terraform/wordpress.tfvars
# Replace with your actual domain:
domain_name = "yourdomain.com"  # ← YOUR DOMAIN HERE
admin_email = "your-email@yourdomain.com"  # ← YOUR EMAIL HERE
```

### **Step 2: Deploy HTTPS Infrastructure**
```bash
cd prod-deploy/terraform

# Plan the deployment
terraform plan -var-file="wordpress.tfvars"

# Apply the changes
terraform apply -var-file="wordpress.tfvars"
```

### **Step 3: Get DNS Nameservers**
```bash
# After deployment, get your DNS nameservers:
terraform output dns_nameservers
```

### **Step 4: Update Your Domain's DNS**
1. Go to your domain provider (WordPress, GoDaddy, etc.)
2. Change nameservers to Google's DNS (from terraform output)
3. Wait 5-10 minutes for propagation

### **Step 5: Verify HTTPS**
```bash
# Check HTTPS status
terraform output https_status

# Visit your site: https://yourdomain.com
```

## 💰 **Cost Breakdown:**

| Component | Cost | Status |
|-----------|------|---------|
| **Domain** | $0 | ✅ Already owned |
| **GCP DNS Zone** | $0.40/month | New cost |
| **Let's Encrypt SSL** | $0 | Forever free |
| **VM Resources** | $6/month | Existing cost |
| **Total Additional** | **~$0.40/month** | Just DNS zone |

## 🔧 **What Happens Automatically:**

1. **Terraform Creates:**
   - Cloud DNS zone for your domain
   - Firewall rules for ports 80 & 443
   - DNS records pointing to your VM

2. **VM Startup Script:**
   - Installs Apache + Certbot
   - Configures WordPress site
   - Gets Let's Encrypt certificate
   - Sets up auto-renewal
   - Enables HTTPS

3. **Let's Encrypt:**
   - Validates domain ownership
   - Issues SSL certificate
   - Auto-renews every 90 days

## ⚠️ **Important Notes:**

- **Domain Required**: Must have a real domain (not just IP)
- **DNS Control**: Need access to change nameservers
- **Public Access**: VM must be accessible from internet
- **Auto-renewal**: Requires VM to be running

## 🎯 **Expected Results:**

✅ **Fully Automated HTTPS** - No manual SSH required  
✅ **Industry Standard SSL** - Let's Encrypt certificates  
✅ **Auto-renewing** - Never expires unexpectedly  
✅ **Production Ready** - Secure for real users  
✅ **Cost Effective** - Only $0.40/month additional  

## 🆘 **Troubleshooting:**

### **If HTTPS doesn't work:**
1. Check DNS propagation (wait 10-15 minutes)
2. Verify firewall rules are applied
3. Check VM is running and accessible
4. Review terraform outputs for errors

### **If certificate fails:**
1. Ensure domain resolves to VM IP
2. Check port 80 is open for validation
3. Verify admin email is correct
4. Check Let's Encrypt rate limits

## 🎉 **You're Done!**

After following these steps, you'll have:
- **Professional HTTPS** for your WordPress site
- **Automatic certificate renewal**
- **Secure user connections**
- **All managed by Terraform**

**Total additional cost: Less than $5/year!** 🚀
