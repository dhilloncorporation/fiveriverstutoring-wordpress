# Outputs Module - Useful output values

# Output the public IP address
output "wordpress_ip" {
  description = "Public IP address of the WordPress instance"
  value       = google_compute_address.wordpress_ip.address
}

# Output the instance name
output "wordpress_instance_name" {
  description = "Name of the WordPress instance"
  value       = google_compute_instance.wordpress.name
}

# Output the instance zone
output "wordpress_instance_zone" {
  description = "Zone of the WordPress instance"
  value       = google_compute_instance.wordpress.zone
}

# Output the VPC name
output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.vpc.name
}

# Output the subnet name
output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
} 