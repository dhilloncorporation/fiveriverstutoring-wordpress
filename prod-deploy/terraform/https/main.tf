# HTTPS Module for WordPress
# This module handles SSL/TLS certificates and HTTPS configuration

# =============================================================================
# LET'S ENCRYPT CERTIFICATE MANAGEMENT
# =============================================================================

# Cloud DNS zone for domain management
resource "google_dns_managed_zone" "wordpress_zone" {
  count       = var.enable_lets_encrypt ? 1 : 0
  name        = "${var.resource_prefix}-wordpress-zone"
  dns_name    = "${var.domain_name}."
  description = "DNS zone for WordPress HTTPS setup"
  project     = var.gcp_project_id
}

# DNS record pointing domain to VM IP
resource "google_dns_record_set" "wordpress_a" {
  count        = var.enable_lets_encrypt ? 1 : 0
  name         = "${var.domain_name}."
  managed_zone = google_dns_managed_zone.wordpress_zone[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.wordpress_vm_ip]
  project      = var.gcp_project_id
}

# DNS record for www subdomain
resource "google_dns_record_set" "wordpress_www" {
  count        = var.enable_lets_encrypt ? 1 : 0
  name         = "www.${var.domain_name}."
  managed_zone = google_dns_managed_zone.wordpress_zone[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.wordpress_vm_ip]
  project      = var.gcp_project_id
}

# =============================================================================
# FIREWALL RULES FOR HTTPS
# =============================================================================

# Allow HTTPS traffic (port 443)
resource "google_compute_firewall" "https" {
  name    = "${var.resource_prefix}-https"
  network = var.vpc_name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server", "wordpress"]
}

# Allow HTTP traffic (port 80) for Let's Encrypt verification
resource "google_compute_firewall" "http_lets_encrypt" {
  count   = var.enable_lets_encrypt ? 1 : 0
  name    = "${var.resource_prefix}-http-lets-encrypt"
  network = var.vpc_name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server", "wordpress"]
}

# =============================================================================
# STARTUP SCRIPT FOR AUTOMATIC HTTPS SETUP
# =============================================================================

# Startup script that automatically configures HTTPS
resource "google_compute_instance_template" "wordpress_https" {
  count        = var.enable_lets_encrypt ? 1 : 0
  name         = "${var.resource_prefix}-wordpress-https-template"
  description  = "WordPress VM template with automatic HTTPS setup"
  project      = var.gcp_project_id

  machine_type = "e2-micro"

  # Use Container-Optimized OS
  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
  }

  # Startup script for automatic HTTPS setup
  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      
      # Wait for system to be ready
      sleep 30
      
      # Install required packages
      apt-get update
      apt-get install -y certbot python3-certbot-apache apache2
      
      # Configure Apache for WordPress
      cat > /etc/apache2/sites-available/wordpress.conf << 'APACHE_EOF'
      <VirtualHost *:80>
          ServerName ${var.domain_name}
          ServerAlias www.${var.domain_name}
          DocumentRoot /var/www/html
          
          <Directory /var/www/html>
              AllowOverride All
              Require all granted
          </Directory>
          
          ErrorLog /var/log/apache2/wordpress_error.log
          CustomLog /var/log/apache2/wordpress_access.log combined
      </VirtualHost>
      APACHE_EOF
      
      # Enable WordPress site
      a2ensite wordpress
      a2enmod rewrite
      systemctl restart apache2
      
      # Get Let's Encrypt certificate
      certbot --apache \
        --non-interactive \
        --agree-tos \
        --email ${var.admin_email} \
        --domains ${var.domain_name},www.${var.domain_name}
      
      # Set up automatic renewal
      echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
      
      # Restart Apache with SSL
      systemctl restart apache2
      
      echo "HTTPS setup completed for ${var.domain_name}"
    EOF
  }

  network_interface {
    subnetwork = var.web_subnet_name
    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["web-server", "wordpress", "https"]
}

# =============================================================================
# END OF RESOURCES
# =============================================================================
# Note: Outputs are defined in outputs.tf to avoid duplication
