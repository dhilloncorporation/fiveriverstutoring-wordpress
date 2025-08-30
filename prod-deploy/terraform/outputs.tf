# Main Terraform Outputs
# This file consolidates outputs from all modules

# =============================================================================
# SHARED INFRASTRUCTURE OUTPUTS
# =============================================================================

output "vpc_name" {
  value       = module.shared.vpc_name
  description = "VPC network name"
}

output "web_subnet_name" {
  value       = module.shared.web_subnet_name
  description = "Web subnet name"
}

output "monitoring_workspace" {
  value       = module.shared.monitoring_workspace
  description = "Cloud Monitoring workspace name"
}

output "logging_sink" {
  value       = module.shared.logging_sink
  description = "Cloud Logging sink name"
}

# =============================================================================
# DATABASE OUTPUTS
# =============================================================================

output "wordpress_database_name" {
  value       = module.database.database_name
  description = "WordPress database name"
}

output "wordpress_admin_user" {
  value       = module.database.admin_user_name
  description = "WordPress admin user name"
}

output "wordpress_app_user" {
  value       = module.database.app_user_name
  description = "WordPress application user name"
}

output "app_user_privileges_granted" {
  value       = module.database.app_user_privileges_granted
  description = "Status of app user privileges"
}

output "admin_user_privileges_granted" {
  value       = module.database.admin_user_privileges_granted
  description = "Status of admin user privileges"
}

output "database_instance" {
  value       = var.wordpress_db_instance
  description = "Cloud SQL instance name"
}

output "authorized_networks_configured" {
  value       = module.database.authorized_networks_configured
  description = "Status of Cloud SQL authorized networks configuration"
}

output "wordpress_vm_ip" {
  value       = module.database.wordpress_vm_ip
  description = "Current WordPress VM external IP for database access"
}

# =============================================================================
# COMPUTE OUTPUTS
# =============================================================================

output "wordpress_instance_name" {
  value       = module.compute.wordpress_instance_name
  description = "WordPress VM instance name"
}

output "wordpress_instance_zone" {
  value       = module.compute.wordpress_instance_zone
  description = "WordPress VM instance zone"
}

output "wordpress_external_ip" {
  value       = module.compute.wordpress_external_ip
  description = "WordPress VM external IP address"
}

output "wordpress_static_ip" {
  value       = module.compute.wordpress_static_ip
  description = "WordPress static IP address (STABLE - Never changes)"
}

output "wordpress_content_disk" {
  value       = module.compute.wordpress_content_disk
  description = "WordPress content disk name"
}

output "wordpress_content_disk_size" {
  value       = module.compute.wordpress_content_disk_size
  description = "WordPress content disk size in GB"
}

output "wordpress_uptime_check" {
  value       = module.compute.wordpress_uptime_check
  description = "WordPress uptime monitoring check name"
}

# =============================================================================
# HTTPS OUTPUTS
# =============================================================================

output "https_status" {
  value       = module.https.https_status
  description = "HTTPS configuration status"
}

output "domain_name" {
  value       = module.https.domain_name
  description = "Domain name configured for HTTPS"
}

output "dns_nameservers" {
  value       = module.https.dns_nameservers
  description = "DNS nameservers for domain configuration"
}

output "cloud_dns_zone" {
  value       = module.https.cloud_dns_zone
  description = "Cloud DNS zone name"
}

output "https_firewall" {
  value       = module.https.firewall_https
  description = "HTTPS firewall rule name"
}

# =============================================================================
# WORDPRESS APPLICATION OUTPUTS
# =============================================================================

output "wordpress_config_file" {
  value       = module.wordpress.wordpress_config_file
  description = "WordPress configuration file path"
}

output "wordpress_deployment_status" {
  value       = module.wordpress.wordpress_deployment_status
  description = "WordPress deployment status"
}

output "wordpress_domain" {
  value       = module.wordpress.wordpress_domain
  description = "WordPress domain name"
}

output "wordpress_image" {
  value       = module.wordpress.wordpress_image
  description = "WordPress Docker image"
}

output "wordpress_health_check_status" {
  value       = module.wordpress.wordpress_health_check_status
  description = "WordPress health check status"
}

# =============================================================================
# SUMMARY OUTPUTS
# =============================================================================

output "deployment_summary" {
  value = {
    infrastructure = "Complete modular infrastructure deployed"
    database      = "Cloud SQL database with users and privileges configured"
    compute       = "WordPress VM with persistent storage and monitoring"
    wordpress     = "WordPress application with security keys and configuration"
    domain        = var.wordpress_domain
    static_ip     = module.compute.wordpress_static_ip
    database_host = module.database.wordpress_database_host
  }
  description = "Complete deployment summary"
} 