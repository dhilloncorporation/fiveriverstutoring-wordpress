# Network Module - VPC, Subnet, Firewall

# Custom VPC for the WordPress deployment
resource "google_compute_network" "vpc" {
  name                    = "valueladder-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet for the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "valueladder-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = var.region
}

# Firewall rule to allow HTTP, HTTPS, and SSH traffic
resource "google_compute_firewall" "default" {
  name    = "valueladder-allow-http-https-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Open to all IPs (consider restricting SSH in production)
  target_tags   = ["http-server", "https-server"]
} 