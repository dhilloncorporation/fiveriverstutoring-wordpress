# Terraform GCP Deployment for WordPress

This directory contains Terraform configuration to provision a Google Cloud Platform (GCP) environment for a portable, secure WordPress deployment using Docker and a persistent disk for wp-content.

## Files
- `provider.tf`: Configures the GCP provider and project/region/zone variables.
- `variables.tf`: Defines variables for project, region, and zone.
- `main.tf`: Provisions the persistent disk, static public IP, firewall rules, and VM instance with Docker and the disk attached.
- `outputs.tf`: Outputs the public IP and resource names after apply.

## Usage

1. **Initialize Terraform**
   ```sh
   cd gcp-deploy/terraform
   terraform init
   ```

2. **Set your project ID**
   You can set variables via CLI or a `terraform.tfvars` file:
   ```sh
   terraform apply -var="project=YOUR_GCP_PROJECT_ID"
   ```
   Or create a `terraform.tfvars` file:
   ```hcl
   project = "YOUR_GCP_PROJECT_ID"
   region  = "australia-southeast1"
   zone    = "australia-southeast1-a"
   ```

3. **Apply the configuration**
   ```sh
   terraform apply
   ```
   Review the plan and type `yes` to confirm.

4. **After apply**
   - The outputs will show your VM's public IP and resource names.
   - SSH into the VM, copy your Docker Compose files, and deploy your WordPress container.



## Common Terraform Commands

- **Create or Update Infrastructure (Apply):**
  ```sh
  terraform init
  terraform apply -var="project=YOUR_GCP_PROJECT_ID"
  ```
  This will create or update all resources as defined in the Terraform configuration.

- **Update Infrastructure After Changes:**
  If you modify any `.tf` files or variables, simply run:
  ```sh
  terraform apply -var="project=YOUR_GCP_PROJECT_ID"
  ```
  Terraform will show you a plan of changes and prompt for approval.

- **Delete All Resources (Destroy):**
  To remove all resources created by this Terraform configuration:
  ```sh
  terraform destroy -var="project=YOUR_GCP_PROJECT_ID"
  ```
  This will tear down the VM, disk, firewall, and all other managed resources.

**Tip:** Always review the plan output before confirming any apply or destroy operation.






## Notes
- The persistent disk is mounted at `/home/$USER/fiverivers_wordpress/wp-content` and should be mapped to `/var/www/html/wp-content` in your Docker Compose.
- The VM is provisioned with Docker installed and ready.
- Only HTTP, HTTPS, and SSH ports are open by default.
- You can further automate deployment by adding provisioners or using a configuration management tool. 