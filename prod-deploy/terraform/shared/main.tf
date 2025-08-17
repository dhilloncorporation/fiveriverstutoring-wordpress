# Shared Infrastructure Module
# This module contains resources shared across compute, wordpress, and database modules

# =============================================================================
# SHARED NETWORKING RESOURCES
# =============================================================================

# VPC Network (if not already created by JAMR)
# Note: This assumes the VPC already exists from jamr-gcp-foundations.tf
# If you need to create it here, uncomment the resource below

# resource "google_compute_network" "vpc" {
#   name                    = var.vpc_name
#   auto_create_subnetworks = false
#   project                 = var.gcp_project_id
# }

# Subnet (if not already created by JAMR)
# resource "google_compute_subnetwork" "web_subnet" {
#   name          = var.web_subnet_name
#   ip_cidr_range = "10.0.1.0/24"
#   region        = var.gcp_region
#   network       = var.vpc_name
#   project       = var.gcp_project_id
# }

# =============================================================================
# SHARED SECURITY RESOURCES
# =============================================================================

# Firewall rules for web access (commented out until VPC exists)
# resource "google_compute_firewall" "web_access" {
#   name    = "${var.resource_prefix}-web-access"
#   network = var.vpc_name
#   project = var.gcp_project_id
# 
#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }
# 
#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["web-server"]
# }

# Firewall rules for SSH access (enabled for Cloud IAP)
resource "google_compute_firewall" "ssh_access" {
  name    = "${var.resource_prefix}-ssh-access"
  network = var.vpc_name
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # Cloud IAP IP range
  target_tags   = ["web-server", "wordpress"]
}

# =============================================================================
# SHARED MONITORING RESOURCES
# =============================================================================

# Cloud Monitoring workspace (using monitoring group instead)
resource "google_monitoring_group" "wordpress_monitoring" {
  display_name = "${var.resource_prefix}-monitoring"
  filter       = "resource.metadata.name=\"${var.resource_prefix}-wordpress\""
  project      = var.gcp_project_id
}

# =============================================================================
# SHARED LOGGING RESOURCES
# =============================================================================

# Cloud Logging sink for WordPress logs (commented out until storage bucket exists)
# resource "google_logging_project_sink" "wordpress_logs" {
#   name        = "${var.resource_prefix}-wordpress-logs"
#   destination = "storage.googleapis.com/${var.resource_prefix}-logs"
#   filter      = "resource.type=gce_instance AND resource.labels.instance_name:wordpress"
#   project     = var.gcp_project_id
# }
