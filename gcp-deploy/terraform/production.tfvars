# Production Configuration for ValueLadder
project = "valueladder-websites"
region  = "australia-southeast1"
zone    = "australia-southeast1-a"

# Production Instance Settings
machine_type = "e2-small"  # 2 vCPU, 2GB RAM for production
disk_size    = 50          # 50GB for production
boot_disk_size = 20        # 20GB boot disk

# Production Security Settings
enable_https = true
enable_monitoring = true
enable_backup = true

# Production Network Settings
vpc_cidr = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# Production Environment
environment = "production" 