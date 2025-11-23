terraform {

  backend "gcs" {
    bucket = "arenaverse-tf-state-bucket01"
    prefix = "stacks/shared"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "arenaverse-shared"
  region  = "northamerica-northeast1"
}

resource "google_project_service" "compute_api" {
  project = "arenaverse-shared"
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

# Use the network module to create the Shared VPC and subnets
module "shared_network" {
  source = "../../modules/network"

  project_id   = "arenaverse-shared"
  network_name = "arenaverse-shared-vpc"

  ca_region = "northamerica-northeast1"
  eu_region = "europe-west1"

  ca_cidr = "10.10.0.0/20"
  eu_cidr = "10.20.0.0/20"

  # replace with your real public IP /32 if you want SSH access
  ssh_source_cidr = "142.113.145.165/32"
}
