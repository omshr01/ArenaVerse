terraform {
  backend "gcs" {
    bucket = "arenaverse-tf-state-bucket01"
    prefix = "bootstrap"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}