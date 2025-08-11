# Production Security Configuration for ValueLadder

# Enhanced Firewall Rules
resource "google_compute_firewall" "https" {
  name    = "valueladder-allow-https"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

# Restrict SSH access to specific IPs (optional)
resource "google_compute_firewall" "ssh_restricted" {
  name    = "valueladder-allow-ssh-restricted"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Replace with your office/home IP addresses
  source_ranges = ["YOUR_IP_ADDRESS/32", "ANOTHER_IP_ADDRESS/32"]
  target_tags   = ["ssh-server"]
}

# Health check firewall rule
resource "google_compute_firewall" "health_check" {
  name    = "valueladder-allow-health-check"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["health-check"]
}

# Cloud Monitoring
resource "google_monitoring_uptime_check_config" "wordpress" {
  display_name = "valueladder-wordpress-uptime"
  timeout = "10s"
  
  http_check {
    port = 443
    use_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host = google_compute_address.wordpress_ip.address
    }
  }
}

# Backup Configuration
resource "google_compute_resource_policy" "daily_backup" {
  name = "valueladder-daily-backup-policy"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "02:00"
      }
    }
  }
}

# Attach backup policy to disk
resource "google_compute_disk_resource_policy_attachment" "backup" {
  name = google_compute_resource_policy.daily_backup.name
  disk = google_compute_disk.wp_content.name
  zone = var.zone
} 