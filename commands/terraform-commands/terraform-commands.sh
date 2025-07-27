# Initialize gcloud
gcloud init
gcloud auth application-default login

# Login to your Google account
gcloud auth login



# Set your project
gcloud config set project valueladder-websites

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com



# Deploy
cd gcp-deploy/terraform
terraform init
terraform plan
terraform apply


terraform plan -var-file=production.tfvars
terraform apply -var-file=production.tfvars

# Step 1: Create the plan file
terraform plan -out=valueladder-plan.tfplan

# Step 2: Review the plan (optional)
terraform show valueladder-plan.tfplan

# Step 3: Apply the exact plan
terraform apply valueladder-plan.tfplan