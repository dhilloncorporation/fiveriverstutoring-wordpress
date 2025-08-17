# HTTPS Module Outputs
# This file defines all outputs from the HTTPS module

output "dns_nameservers" {
  description = "DNS nameservers for domain configuration"
  value       = var.enable_lets_encrypt ? google_dns_managed_zone.wordpress_zone[0].name_servers : []
}

output "domain_name" {
  description = "Domain name configured for HTTPS"
  value       = var.domain_name
}

output "https_status" {
  description = "HTTPS configuration status"
  value       = var.enable_lets_encrypt ? "Let's Encrypt configured" : "HTTPS not enabled"
}

output "cloud_dns_zone" {
  description = "Cloud DNS zone name"
  value       = var.enable_lets_encrypt ? google_dns_managed_zone.wordpress_zone[0].name : null
}

output "firewall_https" {
  description = "HTTPS firewall rule name"
  value       = google_compute_firewall.https.name
}

output "firewall_http_lets_encrypt" {
  description = "HTTP Let's Encrypt firewall rule name"
  value       = var.enable_lets_encrypt ? google_compute_firewall.http_lets_encrypt[0].name : null
}
