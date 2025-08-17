# Database Module
# This module manages Cloud SQL database, users, and privileges

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
# NOTE: Privilege grants are handled manually or via Cloud SQL Admin API
# The users above are created with basic access, additional privileges
# can be granted manually if needed for specific database operations.
# =============================================================================