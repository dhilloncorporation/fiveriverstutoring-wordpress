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

# Use a more efficient approach for authorized networks
# Since we're working with an existing instance, we'll use a data source
# and only update when the WordPress VM IP actually changes

# Create a local value to track the current WordPress VM IP
locals {
  wordpress_vm_ip = data.google_compute_instance.wordpress_vm.network_interface[0].access_config[0].nat_ip
  static_ip        = "14.137.217.165/32"
}

# Use null_resource but with better triggers and conditional execution
resource "null_resource" "configure_cloudsql_networks" {
  # Only run when the WordPress VM IP actually changes
  triggers = {
    wordpress_vm_ip = local.wordpress_vm_ip
    # Add a hash of the authorized networks to detect changes
    authorized_networks_hash = md5("${local.static_ip},${local.wordpress_vm_ip}")
  }

  # Only execute if we're not in a plan-only mode
  provisioner "local-exec" {
    command = <<-EOT
      echo "Configuring Cloud SQL authorized networks for WordPress VM access..."
      echo "Instance: ${data.google_sql_database_instance.existing_db.name}"
      echo "WordPress VM IP: ${local.wordpress_vm_ip}"
      echo "Static IP: ${local.static_ip}"
      
      # Check if the current authorized networks already include our IPs
      CURRENT_NETWORKS=$(gcloud sql instances describe ${data.google_sql_database_instance.existing_db.name} \
        --project=${data.google_sql_database_instance.existing_db.project} \
        --format="value(settings.ipConfiguration.authorizedNetworks[].value)" | tr '\n' ',' | sed 's/,$//')
      
      if [[ "$CURRENT_NETWORKS" == *"${local.wordpress_vm_ip}"* ]] && [[ "$CURRENT_NETWORKS" == *"${local.static_ip}"* ]]; then
        echo "✅ Authorized networks already configured correctly - skipping update"
      else
        echo "🔄 Updating authorized networks..."
        # Add WordPress VM's external IP to authorized networks
        gcloud sql instances patch ${data.google_sql_database_instance.existing_db.name} \
          --project=${data.google_sql_database_instance.existing_db.project} \
          --authorized-networks=${local.static_ip},${local.wordpress_vm_ip} \
          --quiet
        echo "✅ Cloud SQL authorized networks updated successfully!"
      fi
    EOT
  }
}

# =============================================================================
# DATABASE PRIVILEGES
# =============================================================================

# Grant privileges to WordPress application user using improved null_resource
resource "null_resource" "grant_app_privileges" {
  depends_on = [
    google_sql_user.wordpress_app,
    google_sql_database.wordpress_production_db
  ]

  triggers = {
    user_name = var.wordpress_db_user
    db_name   = var.wordpress_db_name
    password  = var.wordpress_db_password
    # Add a hash to detect changes
    privileges_hash = md5("${var.wordpress_db_user}@${var.wordpress_db_name}:ALL_PRIVILEGES")
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Granting privileges to WordPress application user..."
      
      # Use gcloud sql connect with better error handling
      if gcloud sql connect ${var.wordpress_db_instance} \
        --user=root \
        --project=${var.gcp_project_id} \
        --quiet <<SQL
GRANT ALL PRIVILEGES ON ${var.wordpress_db_name}.* TO '${var.wordpress_db_user}'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR '${var.wordpress_db_user}'@'%';
SQL
      then
        echo "✅ WordPress app user privileges granted successfully!"
      else
        echo "❌ Failed to grant privileges to app user"
        echo "This might be due to Cloud SQL restrictions. Consider using Google Cloud Console:"
        echo "1. Go to Cloud SQL → ${var.wordpress_db_instance} → Users"
        echo "2. Select user '${var.wordpress_db_user}'"
        echo "3. Grant ALL PRIVILEGES on database '${var.wordpress_db_name}'"
        exit 1
      fi
    EOT
  }
}

# Grant privileges to WordPress admin user using improved null_resource
resource "null_resource" "grant_admin_privileges" {
  depends_on = [
    google_sql_user.wordpress_admin,
    google_sql_database.wordpress_production_db
  ]

  triggers = {
    user_name = var.wordpress_db_admin_user
    db_name   = var.wordpress_db_name
    password  = var.wordpress_db_admin_password
    # Add a hash to detect changes
    privileges_hash = md5("${var.wordpress_db_admin_user}@${var.wordpress_db_name}:ALL_PRIVILEGES")
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Granting privileges to WordPress admin user..."
      
      # Use gcloud sql connect with better error handling
      if gcloud sql connect ${var.wordpress_db_instance} \
        --user=root \
        --project=${var.gcp_project_id} \
        --quiet <<SQL
GRANT ALL PRIVILEGES ON ${var.wordpress_db_name}.* TO '${var.wordpress_db_admin_user}'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR '${var.wordpress_db_admin_user}'@'%';
SQL
      then
        echo "✅ WordPress admin user privileges granted successfully!"
      else
        echo "❌ Failed to grant privileges to admin user"
        echo "This might be due to Cloud SQL restrictions. Consider using Google Cloud Console:"
        echo "1. Go to Cloud SQL → ${var.wordpress_db_instance} → Users"
        echo "2. Select user '${var.wordpress_db_admin_user}'"
        echo "3. Grant ALL PRIVILEGES on database '${var.wordpress_db_name}'"
        exit 1
      fi
    EOT
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "database_name" {
  description = "Name of the created WordPress database"
  value       = google_sql_database.wordpress_production_db.name
}

output "app_user_name" {
  description = "Name of the WordPress application user"
  value       = google_sql_user.wordpress_app.name
}

output "admin_user_name" {
  description = "Name of the WordPress admin user"
  value       = google_sql_user.wordpress_admin.name
}

output "app_user_privileges_granted" {
  description = "Status of app user privileges"
  value       = null_resource.grant_app_privileges.id
}

output "admin_user_privileges_granted" {
  description = "Status of admin user privileges"
  value       = null_resource.grant_admin_privileges.id
}

output "authorized_networks_configured" {
  description = "Status of Cloud SQL authorized networks configuration"
  value       = null_resource.configure_cloudsql_networks.id
}

output "wordpress_vm_ip" {
  description = "Current WordPress VM external IP for database access"
  value       = local.wordpress_vm_ip
}