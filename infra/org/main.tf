terraform {
  backend "gcs" {
    bucket = "arenaverse-tf-state-bucket01"
    prefix = "org"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.bootstrap_project_id
  region  = var.default_region
}

# -------- Projects --------

module "project_shared" {
  source             = "../modules/project"
  project_id         = "arenaverse-shared"
  name               = "ArenaVerse Shared Infra"
  billing_account_id = var.billing_account_id
}

module "project_dev" {
  source             = "../modules/project"
  project_id         = "arenaverse-dev"
  name               = "ArenaVerse Dev"
  billing_account_id = var.billing_account_id
}

module "project_staging" {
  source             = "../modules/project"
  project_id         = "arenaverse-staging"
  name               = "ArenaVerse Staging"
  billing_account_id = var.billing_account_id
}

module "project_prod" {
  source             = "../modules/project"
  project_id         = "arenaverse-prod"
  name               = "ArenaVerse Prod"
  billing_account_id = var.billing_account_id
}

# -------- Service Accounts --------

# tf-admin SA lives in shared project for infra management
resource "google_service_account" "tf_admin" {
  account_id   = "tf-admin"
  display_name = "Terraform Admin"
  project      = module.project_shared.project_id
}

# cicd SA lives in shared project for pipelines (you can separate later)
resource "google_service_account" "tf_cicd" {
  account_id   = "tf-cicd"
  display_name = "CI/CD Service Account"
  project      = module.project_shared.project_id
}

# -------- IAM Bindings for tf-admin --------
# For learning purposes, we give tf-admin broad rights on the new projects.
# NOTE: This is NOT production best practice.

resource "google_project_iam_member" "tf_admin_shared_owner" {
  project = module.project_shared.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.tf_admin.email}"
}

resource "google_project_iam_member" "tf_admin_dev_owner" {
  project = module.project_dev.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.tf_admin.email}"
}

resource "google_project_iam_member" "tf_admin_staging_owner" {
  project = module.project_staging.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.tf_admin.email}"
}

resource "google_project_iam_member" "tf_admin_prod_owner" {
  project = module.project_prod.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.tf_admin.email}"
}