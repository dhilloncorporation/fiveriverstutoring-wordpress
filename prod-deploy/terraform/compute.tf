# Compute Module - VM Instance and IP Address

# Reserve a static public IP for the WordPress VM
resource "google_compute_address" "wordpress_ip" {
  name   = "valueladder-wordpress-static-ip"
  region = var.region
}

# Main WordPress VM instance
resource "google_compute_instance" "wordpress" {
  name         = "valueladder-wordpress"
  machine_type = "f1-micro"  # Changed to f1-micro (1 vCPU, 0.6GB RAM) - cheapest option
  zone         = var.zone

  # Boot disk (OS disk)
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10  # Reduced from 20GB to 10GB
    }
  }

  # Network interface with static public IP
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      nat_ip = google_compute_address.wordpress_ip.address
    }
  }

  tags = ["http-server", "https-server"]  # Used by firewall rule

  # Attach the persistent disk for wp-content
  attached_disk {
    source      = google_compute_disk.wp_content.id
    device_name = "valueladder-wp-content-disk"
  }

  # Startup script: install Docker, mount disk, set permissions
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    mkdir -p /home/$USER/valueladder_wordpress/wp-content
    mount /dev/disk/by-id/google-valueladder-wp-content-disk /home/$USER/valueladder_wordpress/wp-content || true
    echo "/dev/disk/by-id/google-valueladder-wp-content-disk /home/$USER/valueladder_wordpress/wp-content ext4 defaults 0 2" >> /etc/fstab
    chmod 777 /home/$USER/valueladder_wordpress/wp-content
  EOT
} 