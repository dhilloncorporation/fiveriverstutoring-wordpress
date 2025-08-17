# WordPress Module Outputs
# Outputs that can be used by other modules

output "wordpress_config_file" {
  value       = local_file.wordpress_config.filename
  description = "WordPress configuration file path"
}

output "wordpress_deployment_status" {
  value       = "WordPress deployment completed successfully"
  description = "WordPress deployment status"
}

output "wordpress_security_keys" {
  value = {
    auth_key = random_password.wordpress_auth_key.result
    secure_auth_key = random_password.wordpress_secure_auth_key.result
    logged_in_key = random_password.wordpress_logged_in_key.result
    nonce_key = random_password.wordpress_nonce_key.result
    auth_salt = random_password.wordpress_auth_salt.result
    secure_auth_salt = random_password.wordpress_secure_auth_salt.result
    logged_in_salt = random_password.wordpress_logged_in_salt.result
    nonce_salt = random_password.wordpress_nonce_salt.result
  }
  description = "WordPress security keys and salts"
  sensitive   = true
}

output "wordpress_domain" {
  value       = var.wordpress_domain
  description = "WordPress domain name"
}

output "wordpress_image" {
  value       = var.wordpress_image
  description = "WordPress Docker image"
}

output "wordpress_health_check_status" {
  value       = "WordPress health check completed"
  description = "WordPress health check status"
}
