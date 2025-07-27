#!/bin/bash

# Deploy WordPress on GCP VM using Docker Compose
# This script copies your production Docker Compose file to the VM and starts the WordPress container.
# It automatically uses the correct GCP zone from terraform.tfvars.

set -e  # Exit on error

# --- Get zone from terraform.tfvars ---
# Reads the 'zone' value from your Terraform variables file so all gcloud commands use the correct zone.
tfvars_file="$(dirname "$0")/terraform/terraform.tfvars"
ZONE=$(grep '^zone' "$tfvars_file" | awk -F'=' '{print $2}' | tr -d '" ')

# --- Get VM IP from Terraform output ---
# Uses Terraform output to get the public IP of the deployed VM.
echo "Fetching VM IP from Terraform output..."
cd $(dirname "$0")/terraform
VM_IP=$(terraform output -raw wordpress_vm_ip)
cd ../..

if [ -z "$VM_IP" ]; then
  echo "Could not get VM IP from Terraform output. Make sure you have applied Terraform and the VM is running."
  exit 1
fi

echo "VM IP: $VM_IP"
echo "Zone: $ZONE"

# --- Copy Docker Compose file to VM ---
# Copies your production Docker Compose file to the VM's home directory as 'docker-compose.yml'.
# This ensures the VM will use the latest version of your compose file.
echo "Copying docker-compose.prod.yml to VM..."
gcloud compute scp gcp-deploy/docker-compose.prod.yml $USER@$VM_IP:~/docker-compose.yml --zone=$ZONE

# --- Deploy with Docker Compose on VM ---
# SSH into the VM and run Docker Compose to start the WordPress container.
# Uses the official WordPress image and your bind-mounted wp-content directory.

echo "Deploying WordPress with Docker Compose..."
gcloud compute ssh $USER@$VM_IP --zone=$ZONE --command '
  sudo docker-compose -f ~/docker-compose.yml up -d
'

# --- Success message ---
echo "✅ WordPress deployment complete!"
echo "🌐 Visit: http://$VM_IP" 