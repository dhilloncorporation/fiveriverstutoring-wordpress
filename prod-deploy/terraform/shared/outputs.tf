# Shared Module Outputs
# Outputs that can be used by other modules

output "vpc_name" {
  value       = var.vpc_name
  description = "VPC network name"
}

output "web_subnet_name" {
  value       = var.web_subnet_name
  description = "Web subnet name"
}

output "resource_prefix" {
  value       = var.resource_prefix
  description = "Resource naming prefix"
}

output "gcp_project_id" {
  value       = var.gcp_project_id
  description = "GCP Project ID"
}

output "gcp_region" {
  value       = var.gcp_region
  description = "GCP Region"
}

output "gcp_zone" {
  value       = var.gcp_zone
  description = "GCP Zone"
}

output "monitoring_workspace" {
  value       = google_monitoring_group.wordpress_monitoring.name
  description = "Cloud Monitoring group name"
}

output "logging_sink" {
  value       = "wordpress-logs-sink"  # Placeholder until storage bucket is created
  description = "Cloud Logging sink name (placeholder)"
}
