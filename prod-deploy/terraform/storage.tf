# Storage Module - Disks and Storage Resources

# Persistent disk for WordPress content (wp-content)
resource "google_compute_disk" "wp_content" {
  name  = "valueladder-wp-content-disk"
  type  = "pd-standard"
  zone  = var.zone
  size  = 20  # Reduced from 50GB to 20GB
} 