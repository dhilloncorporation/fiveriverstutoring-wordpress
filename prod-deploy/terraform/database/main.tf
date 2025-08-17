# Database Module
# This module manages Cloud SQL database, users, and privileges

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get the WordPress VM instance details for network access
data "google_compute_instance" "wordpress_vm" {
  name     = "jamr-websites-prod-wordpress"
  zone     = "australia-southeast1-a"
  project  = "storied-channel-467012-r6"
}

# Get the existing Cloud SQL instance
data "google_sql_database_instance" "existing_db" {
  name = var.wordpress_db_instance
}

# =============================================================================
# DATABASE CREATION
# =============================================================================

# Create the production database
resource "google_sql_database" "wordpress_production_db" {
  name     = var.wordpress_db_name
  instance = var.wordpress_db_instance
  project  = var.gcp_project_id
}

# =============================================================================
# USER CREATION
# =============================================================================

# Create admin user for production management
resource "google_sql_user" "wordpress_admin" {
  name     = var.wordpress_db_admin_user
  instance = var.wordpress_db_instance
  password = var.wordpress_db_admin_password
  project  = var.gcp_project_id
  host     = "%"  # Allow connections from any host
}

# Create application user for WordPress connections
resource "google_sql_user" "wordpress_app" {
  name     = var.wordpress_db_user
  instance = var.wordpress_db_instance
  password = var.wordpress_db_password
  project  = var.gcp_project_id
  host     = "%"  # Allow connections from any host
}

# =============================================================================
# CLOUD SQL AUTHORIZED NETWORKS
# =============================================================================

# Use null_resource to modify existing Cloud SQL instance's authorized networks
resource "null_resource" "configure_cloudsql_networks" {
  # This will run every time the WordPress VM IP changes
  triggers = {
    wordpress_vm_ip = data.google_compute_instance.wordpress_vm.network_interface[0].access_config[0].nat_ip
    instance_name   = data.google_sql_database_instance.existing_db.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Configuring Cloud SQL authorized networks for WordPress VM access..."
      echo "Instance: ${data.google_sql_database_instance.existing_db.name}"
      echo "WordPress VM IP: ${data.google_compute_instance.wordpress_vm.network_interface[0].access_config[0].nat_ip}"
      
      # Add WordPress VM's external IP to authorized networks
      gcloud sql instances patch ${data.google_sql_database_instance.existing_db.name} \
        --project=${data.google_sql_database_instance.existing_db.project} \
        --authorized-networks=14.137.217.165/32,${data.google_compute_instance.wordpress_vm.network_interface[0].access_config[0].nat_ip}/32 \
        --quiet
      
      echo "✅ Cloud SQL authorized networks configured successfully!"
    EOT
  }
}

# =============================================================================
# NOTE: Privilege grants are handled manually or via Cloud SQL Admin API
# The users above are created with basic access, additional privileges
# can be granted manually if needed for specific database operations.
# =============================================================================