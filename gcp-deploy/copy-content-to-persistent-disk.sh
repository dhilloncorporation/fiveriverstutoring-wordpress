#!/bin/bash

# Script to copy local wp-content to GCP VM persistent disk and set permissions
# Usage: bash gcp-deploy/copy-content-to-persistent-disk.sh <VM_IP> <GCP_ZONE> [USER]
# Example: bash gcp-deploy/copy-content-to-persistent-disk.sh 34.123.45.67 australia-southeast1-a ravin

set -e

# Check if on master branch
git_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$git_branch" != "master" ]; then
  echo "❌ You are on branch '$git_branch'. Please switch to 'master' before running this script."
  exit 1
fi

echo "You are on the 'master' branch."
echo "About to copy your local wp-content to the GCP VM persistent disk."
echo "This will overwrite any existing content on the VM's persistent disk!"
echo ""
echo "Local source:   fiverivers_wordpress/wp-content/"
echo "Remote target:  /home/<USER>/fiverivers_wordpress/wp-content on VM ($1)"
echo ""
read -p "Are you sure you want to continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted by user."
  exit 1
fi

VM_IP="$1"
ZONE="$2"
USER="${3:-$USER}"

if [ -z "$VM_IP" ] || [ -z "$ZONE" ]; then
  echo "Usage: $0 <VM_IP> <GCP_ZONE> [USER]"
  exit 1
fi

LOCAL_WP_CONTENT="fiverivers_wordpress/wp-content/"
REMOTE_WP_CONTENT="/home/$USER/fiverivers_wordpress/wp-content"

# Copy local wp-content to the VM's persistent disk
echo "Copying local wp-content to VM persistent disk..."
gcloud compute scp --recurse "$LOCAL_WP_CONTENT" "$USER@$VM_IP:$REMOTE_WP_CONTENT" --zone="$ZONE"

echo "Setting permissions and restarting Docker Compose on VM..."
gcloud compute ssh "$USER@$VM_IP" --zone="$ZONE" --command '
  sudo chown -R www-data:www-data ~/fiverivers_wordpress/wp-content && \
  sudo chmod -R 755 ~/fiverivers_wordpress/wp-content && \
  sudo docker-compose -f ~/docker-compose.yml restart
'

echo "✅ Content copied and permissions set. WordPress should now use the updated content from the persistent disk." 