variable "project_id" {
  description = "GCP project ID where the VPC will live (host project for Shared VPC)"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "ca_region" {
  description = "Region for CA subnet (e.g. northamerica-northeast1)"
  type        = string
}

variable "eu_region" {
  description = "Region for EU subnet (e.g. europe-west1)"
  type        = string
}

variable "ca_cidr" {
  description = "CIDR range for CA subnet"
  type        = string
}

variable "eu_cidr" {
  description = "CIDR range for EU subnet"
  type        = string
}

variable "ssh_source_cidr" {
  description = "CIDR allowed to SSH into bastion/nodes (e.g. your IP /32). If null, SSH rule is not created."
  type        = string
  default     = null
}
