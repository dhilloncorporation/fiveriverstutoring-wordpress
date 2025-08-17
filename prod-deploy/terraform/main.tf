# Main Terraform Configuration
# This file orchestrates all the separate modules

# =============================================================================
# PROVIDER CONFIGURATION
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# =============================================================================
# MODULE CALLS
# =============================================================================

# Shared infrastructure module
module "shared" {
  source = "./shared"
  
  gcp_project_id    = var.gcp_project_id
  gcp_region        = var.gcp_region
  gcp_zone          = var.gcp_zone
  vpc_name          = var.vpc_name
  web_subnet_name   = var.web_subnet_name
  resource_prefix   = var.resource_prefix
  environment       = var.environment
  application_name  = var.application_name
}

# Database module
module "database" {
  source = "./database"
  
  gcp_project_id              = var.gcp_project_id
  wordpress_db_instance       = var.wordpress_db_instance
  wordpress_db_name           = var.wordpress_db_name
  wordpress_db_host           = var.wordpress_db_host
  wordpress_db_user           = var.wordpress_db_user
  wordpress_db_password       = var.wordpress_db_password
  wordpress_db_admin_user     = var.wordpress_db_admin_user
  wordpress_db_admin_password = var.wordpress_db_admin_password
  wordpress_db_root_password  = var.wordpress_db_root_password
  
  depends_on = [module.shared]
}

# Compute module
module "compute" {
  source = "./compute"
  
  gcp_project_id                = var.gcp_project_id
  gcp_region                    = var.gcp_region
  gcp_zone                      = var.gcp_zone
  resource_prefix               = var.resource_prefix
  web_subnet_name              = var.web_subnet_name
  wordpress_image               = var.wordpress_image
  wordpress_container_port      = var.wordpress_container_port
  wordpress_host_port           = var.wordpress_host_port
  wordpress_content_mount_path  = var.wordpress_content_mount_path
  wordpress_content_host_path   = var.wordpress_content_host_path
  wordpress_db_host             = var.wordpress_db_host
  wordpress_db_name             = var.wordpress_db_name
  wordpress_db_user             = var.wordpress_db_user
  wordpress_db_password         = var.wordpress_db_password
  
  depends_on = [module.shared]  # Only depends on shared infrastructure
}

# WordPress module
module "wordpress" {
  source = "./wordpress"
  
  wordpress_image               = var.wordpress_image
  wordpress_db_host             = var.wordpress_db_host
  wordpress_db_name             = var.wordpress_db_name
  wordpress_db_user             = var.wordpress_db_user
  wordpress_db_password         = var.wordpress_db_password
  wordpress_domain              = var.wordpress_domain
  wordpress_container_port      = var.wordpress_container_port
  wordpress_host_port           = var.wordpress_host_port
  wordpress_content_mount_path  = var.wordpress_content_mount_path
  wordpress_content_host_path   = var.wordpress_content_host_path
  
  depends_on = [module.shared, module.compute]  # Only depends on shared and compute
}

# HTTPS Module for Let's Encrypt SSL
module "https" {
  source = "./https"
  
  gcp_project_id    = var.gcp_project_id
  gcp_zone          = var.gcp_zone
  resource_prefix   = var.resource_prefix
  vpc_name          = var.vpc_name
  web_subnet_name   = var.web_subnet_name
  domain_name       = var.domain_name
  wordpress_vm_ip   = module.compute.wordpress_static_ip
  enable_lets_encrypt = var.enable_lets_encrypt
  admin_email       = var.admin_email
  
  depends_on = [module.shared, module.compute]  # Depends on shared and compute
}
