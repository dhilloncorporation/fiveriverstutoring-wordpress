# Compute Module Variables
# Variables specific to compute resources

variable "gcp_project_id" {
  description = "GCP Project ID"
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

variable "resource_prefix" {
  description = "Resource naming prefix"
  type        = string
}

variable "web_subnet_name" {
  description = "Web subnet name"
  type        = string
}

variable "wordpress_image" {
  description = "WordPress Docker image"
  type        = string
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

variable "wordpress_db_host" {
  description = "WordPress database host"
  type        = string
}

variable "wordpress_db_name" {
  description = "WordPress database name"
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
