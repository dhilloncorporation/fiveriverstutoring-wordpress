# GCP WordPress Deployment: Step-by-Step Guide

This directory contains everything you need to deploy a portable, secure WordPress site on Google Cloud Platform using Terraform and Docker Compose.

---

## Directory Contents

- **docker-compose.prod.yml**  
  Production Docker Compose file for WordPress. Maps persistent disk to `/var/www/html/wp-content`.

- **deploy-on-vm.sh**  
  Script to copy `docker-compose.prod.yml` to the VM and deploy WordPress using Docker Compose, mapping the persistent disk.

- **terraform/**  
  Contains all Terraform configuration files for provisioning your GCP infrastructure (VM, disk, IP, firewall).

- **create-vm-and-disk.sh**  
  (Legacy) Script for manual VM/disk creation. Not needed if using Terraform.

---

## Deployment Steps

1. **Provision Infrastructure with Terraform**
   ```sh
   cd terraform
   terraform init
   terraform apply -var="project=YOUR_GCP_PROJECT_ID"
   # Note the public IP output
   ```
   _This creates the VM, persistent disk, static IP, and firewall rules._

2. **Deploy WordPress on the VM**
   ```sh
   cd ..
   bash deploy-on-vm.sh
   ```
   _This copies your compose file and runs Docker Compose on the VM using the official WordPress image._

3. **(Optional) Security Hardening**
   If you have a `security-hardening.sh` script, copy and run it on the VM for extra protection:
   ```sh
   gcloud compute scp gcp-deploy/security-hardening.sh $USER@VM_IP:~/ --zone=us-central1-a
   gcloud compute ssh $USER@VM_IP --zone=us-central1-a --command 'bash ~/security-hardening.sh'
   ```

4. **Visit Your Site**
   - Open your browser and go to the public IP output by Terraform (e.g., `http://YOUR_VM_IP`).
   - Complete the WordPress installation wizard.

---

## Notes
- You can ignore or delete `create-vm-and-disk.sh` if using Terraform.
- For customizations (VM size, disk, region, etc.), edit the files in `terraform/` and re-apply.
- For Docker/WordPress changes, update your `docker-compose.prod.yml` and the bind-mounted `wp-content` directory.

---

## Best Practices
- Keep secrets out of version control
- Regularly update Docker images and WordPress plugins/themes
- Set up backups for persistent disk and database
- Monitor resource usage and logs
- Use HTTPS (Let’s Encrypt or Google-managed SSL) 

---

## **How It Works in Your Setup**

### **In Terraform (`main.tf`):**
- The persistent disk is attached and mounted at:
  ```
  /mnt/wp-content
  ```
  (This is set in the `metadata_startup_script` of your VM resource.)

### **In Docker Compose (`docker-compose.prod.yml`):**
- You should map the persistent disk mount (`/mnt/wp-content`) to the WordPress container’s content directory:
  ```yaml
  volumes:
    - /mnt/wp-content:/var/www/html/wp-content
  ```

---

## **Why This Matters**
- This ensures that all uploads, media, and user-generated content in WordPress are stored on the persistent disk, surviving container or VM restarts.

---

## **Checklist**

- **Terraform:**  
  VM startup script mounts the disk at `/mnt/wp-content`.

- **Docker Compose:**  
  Maps `/mnt/wp-content` (host) to `/var/www/html/wp-content` (container).

---

## **How to Check**

1. **In Terraform (`main.tf`):**
   ```hcl
   metadata_startup_script = <<-EOT
     ...
     mkdir -p /mnt/wp-content
     mount /dev/disk/by-id/google-wp-content-disk /mnt/wp-content || true
     ...
   EOT
   ```

2. **In Docker Compose (`docker-compose.prod.yml`):**
   ```yaml
   volumes:
     - /mnt/wp-content:/var/www/html/wp-content
   ```

---

**If both are set as above, your persistent path is correct and consistent!**

If you want me to check your actual `docker-compose.prod.yml` or Terraform file, just let me know! 