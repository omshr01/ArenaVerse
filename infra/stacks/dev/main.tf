terraform {
  backend "gcs" {
    bucket = "arenaverse-tf-state-bucket01"
    prefix = "stacks/dev"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "arenaverse-dev"
  region  = "northamerica-northeast1"
}