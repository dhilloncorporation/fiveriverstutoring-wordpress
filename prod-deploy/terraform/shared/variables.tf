# Shared Module Variables
# Variables used across compute, wordpress, and database modules

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "web_subnet_name" {
  description = "Web subnet name"
  type        = string
}

variable "resource_prefix" {
  description = "Resource naming prefix"
  type        = string
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
}

variable "application_name" {
  description = "Application name"
  type        = string
}
