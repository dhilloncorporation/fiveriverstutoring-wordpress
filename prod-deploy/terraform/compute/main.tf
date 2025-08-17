# Compute Module
# This module manages VM instances, persistent disks, and compute resources
# 
# NOTE: This configuration uses direct Cloud SQL connections instead of Cloud SQL Proxy
# for simplicity and better performance. The firewall rules in the shared module
# allow the WordPress VM to connect directly to Cloud SQL on port 3306.

# =============================================================================
# COMPUTE INSTANCES
# =============================================================================

# Static IP for WordPress VM
resource "google_compute_address" "wordpress_static_ip" {
  name         = "${var.resource_prefix}-wordpress-static-ip"
  region       = var.gcp_region
  description  = "Static IP for WordPress VM"
  project      = var.gcp_project_id
}

# WordPress VM instance
resource "google_compute_instance" "wordpress" {
  name         = "${var.resource_prefix}-wordpress"
  machine_type = "e2-micro"  # $6/month instead of $15/month (e2-small) - Perfect for WordPress sites
  zone         = var.gcp_zone
  project      = var.gcp_project_id

  # Use Container-Optimized OS for automatic WordPress container startup
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = 20  # GB
      type  = "pd-standard"
    }
  }

  # Attach the persistent disk for WordPress content
  attached_disk {
    source = google_compute_disk.wp_content.self_link
    device_name = "wp-content"
  }

  # Network interface with static IP
  network_interface {
    subnetwork = var.web_subnet_name
    access_config {
      nat_ip = google_compute_address.wordpress_static_ip.address
    }
  }

  # Metadata for automatic WordPress container startup
  metadata = {
    gce-container-declaration = yamlencode({
      spec = {
        containers = [{
          image = var.wordpress_image
          name  = "wordpress"
          ports = [{
            containerPort = var.wordpress_container_port
            hostPort      = var.wordpress_host_port
          }]
          env = [
            {
              name  = "WORDPRESS_DB_HOST"
              value = var.wordpress_db_host  # Use direct Cloud SQL IP
            },
            {
              name  = "WORDPRESS_DB_NAME"
              value = var.wordpress_db_name
            },
            {
              name  = "WORDPRESS_DB_USER"
              value = var.wordpress_db_user
            },
            {
              name  = "WORDPRESS_DB_PASSWORD"
              value = var.wordpress_db_password
            }
          ]
          volumeMounts = [{
            name      = "wp-content"
            mountPath = var.wordpress_content_mount_path
          }]
          # Simple WordPress startup - no Cloud SQL Proxy needed
          command = ["/usr/local/bin/entrypoint.sh"]
          args = ["apache2-foreground"]
        }]
        volumes = [{
          name = "wp-content"
          hostPath = {
            path = var.wordpress_content_host_path
          }
        }]
      }
    })
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  # Service account with proper scopes for GCR access
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",  # GCR access
      "https://www.googleapis.com/auth/logging.write",         # Cloud Logging
      "https://www.googleapis.com/auth/monitoring.write",      # Cloud Monitoring
      "https://www.googleapis.com/auth/compute"                # Compute access
      # Removed sqlservice.admin scope - no longer needed without Cloud SQL Proxy
    ]
  }

  # Tags for firewall rules
  tags = ["web-server", "wordpress"]

  # Scheduling for cost optimization
  scheduling {
    preemptible = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  # Allow Terraform to stop the VM for updates
  allow_stopping_for_update = true

  depends_on = [
    google_compute_disk.wp_content
  ]
}

# =============================================================================
# STORAGE RESOURCES
# =============================================================================

# Persistent disk for WordPress content
resource "google_compute_disk" "wp_content" {
  name  = "${var.resource_prefix}-wp-content"
  type  = "pd-ssd"
  zone  = var.gcp_zone
  size  = 50  # GB for WordPress content
  project = var.gcp_project_id
}

# =============================================================================
# NETWORKING RESOURCES
# =============================================================================

# Note: Static IP is now defined above in the compute instances section
# as google_compute_address.wordpress_static_ip

# =============================================================================
# MONITORING AND BACKUP
# =============================================================================

# Uptime monitoring for WordPress
resource "google_monitoring_uptime_check_config" "wordpress" {
  display_name = "${var.resource_prefix}-wordpress-uptime"
  timeout      = "10s"
  
  http_check {
    port = 80
    path = "/"
  }
  
  monitored_resource {
    type = "uptime_url"
    labels = {
      host = google_compute_address.wordpress_static_ip.address
    }
  }
}

# Daily backup policy for the persistent disk
resource "google_compute_resource_policy" "daily_backup" {
  name   = "${var.resource_prefix}-daily-backup-policy"
  region = var.gcp_region
  
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "02:00"
      }
    }
    
    retention_policy {
      max_retention_days = 7
    }
  }
}

# Attach backup policy to the persistent disk
resource "google_compute_disk_resource_policy_attachment" "backup" {
  name = google_compute_resource_policy.daily_backup.name
  disk = google_compute_disk.wp_content.name
  zone = var.gcp_zone
}
