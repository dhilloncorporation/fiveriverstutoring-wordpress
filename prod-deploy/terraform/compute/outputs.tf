# Compute Module Outputs
# Outputs that can be used by other modules

output "wordpress_instance_name" {
  value       = google_compute_instance.wordpress.name
  description = "WordPress VM instance name"
}

output "wordpress_instance_zone" {
  value       = google_compute_instance.wordpress.zone
  description = "WordPress VM instance zone"
}

output "wordpress_external_ip" {
  value       = try(google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip, "Not configured yet")
  description = "WordPress VM external IP address"
}

output "wordpress_static_ip" {
  value       = google_compute_address.wordpress_static_ip.address
  description = "WordPress static IP address"
}

output "wordpress_content_disk" {
  value       = google_compute_disk.wp_content.name
  description = "WordPress content disk name"
}

output "wordpress_content_disk_size" {
  value       = google_compute_disk.wp_content.size
  description = "WordPress content disk size in GB"
}

output "wordpress_uptime_check" {
  value       = google_monitoring_uptime_check_config.wordpress.name
  description = "WordPress uptime monitoring check name"
}

output "wordpress_backup_policy" {
  value       = google_compute_resource_policy.daily_backup.name
  description = "WordPress daily backup policy name"
}

output "wordpress_instance_status" {
  value       = "RUNNING"  # Default status, actual status will be available after deployment
  description = "WordPress VM instance status"
}
