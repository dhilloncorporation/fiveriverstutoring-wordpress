# Main Terraform Variables
# This file consolidates all variables needed by the main configuration and modules

# =============================================================================
# GCP PROJECT CONFIGURATION
# =============================================================================

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_project_name" {
  description = "GCP Project Name"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
}

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
}

variable "resource_prefix" {
  description = "Resource naming prefix"
  type        = string
}

# =============================================================================
# NETWORKING CONFIGURATION
# =============================================================================

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "web_subnet_name" {
  description = "Web subnet name"
  type        = string
}

# =============================================================================
# WORDPRESS CONFIGURATION
# =============================================================================

variable "wordpress_image" {
  description = "WordPress Docker image"
  type        = string
}

variable "wordpress_domain" {
  description = "WordPress domain name"
  type        = string
  default     = "fiverivertutoring.com"
}

variable "wordpress_container_port" {
  description = "WordPress container port"
  type        = number
  default     = 80
}

variable "wordpress_host_port" {
  description = "WordPress host port"
  type        = number
  default     = 80
}

variable "wordpress_content_mount_path" {
  description = "WordPress content mount path in container"
  type        = string
  default     = "/var/www/html/wp-content"
}

variable "wordpress_content_host_path" {
  description = "WordPress content host path"
  type        = string
  default     = "/mnt/disks/wp-content"
}

# =============================================================================
# HTTPS CONFIGURATION
# =============================================================================

variable "domain_name" {
  description = "Domain name for HTTPS setup (e.g., fiverivertutoring.com)"
  type        = string
  default     = "fiverivertutoring.com"
}

variable "enable_lets_encrypt" {
  description = "Enable Let's Encrypt HTTPS setup"
  type        = bool
  default     = true
}

variable "admin_email" {
  description = "Admin email for Let's Encrypt certificate"
  type        = string
  default     = "admin@fiverivertutoring.com"
}

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

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
