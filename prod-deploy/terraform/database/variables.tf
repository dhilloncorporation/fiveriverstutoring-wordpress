# Database Module Variables
# Variables specific to database configuration

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "wordpress_db_instance" {
  description = "Cloud SQL instance name for WordPress database"
  type        = string
}

variable "wordpress_db_name" {
  description = "WordPress database name"
  type        = string
}

variable "wordpress_db_host" {
  description = "WordPress database host"
  type        = string
}

variable "wordpress_db_user" {
  description = "WordPress database user"
  type        = string
}

variable "wordpress_db_password" {
  description = "WordPress database password"
  type        = string
  sensitive   = true
}

variable "wordpress_db_admin_user" {
  description = "WordPress database admin user"
  type        = string
}

variable "wordpress_db_admin_password" {
  description = "WordPress database admin password"
  type        = string
  sensitive   = true
}

variable "wordpress_db_root_password" {
  description = "Database root password for privilege operations"
  type        = string
  sensitive   = true
}
