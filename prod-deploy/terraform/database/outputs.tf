# Database Module Outputs
# Outputs that can be used by other modules

output "wordpress_database_host" {
  value       = var.wordpress_db_host
  description = "WordPress database host"
}

output "wordpress_database_name" {
  value       = google_sql_database.wordpress_production_db.name
  description = "WordPress database name"
}

output "wordpress_admin_user" {
  value       = google_sql_user.wordpress_admin.name
  description = "WordPress admin user name"
}

output "wordpress_app_user" {
  value       = google_sql_user.wordpress_app.name
  description = "WordPress application user name"
}

output "database_setup_complete" {
  value       = "Complete production database setup has been created via Terraform"
  description = "Confirmation that the full database setup is complete"
}

output "database_instance" {
  value       = var.wordpress_db_instance
  description = "Cloud SQL instance name from wordpress.tfvars"
}

output "database_connection_string" {
  value       = "mysql://${google_sql_user.wordpress_app.name}:${var.wordpress_db_password}@${var.wordpress_db_host}:3306/${google_sql_database.wordpress_production_db.name}"
  description = "Database connection string for WordPress"
  sensitive   = true
}
