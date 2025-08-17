# HTTPS Module Variables
# This file defines all variables needed for the HTTPS module

variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "gcp_zone" {
  description = "Google Cloud zone"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "web_subnet_name" {
  description = "Name of the web subnet"
  type        = string
}

variable "domain_name" {
  description = "Domain name for HTTPS setup (e.g., fiverivertutoring.com)"
  type        = string
}

variable "wordpress_vm_ip" {
  description = "IP address of the WordPress VM"
  type        = string
}

variable "enable_lets_encrypt" {
  description = "Enable Let's Encrypt HTTPS setup"
  type        = bool
  default     = true
}

variable "admin_email" {
  description = "Admin email for Let's Encrypt certificate"
  type        = string
  default     = "admin@fiverivertutoring.com"
}
