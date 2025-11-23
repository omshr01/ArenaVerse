variable "bootstrap_project_id" {
  description = "Existing project to use for Terraform operations (bootstrap)"
  type        = string
}

variable "default_region" {
  description = "Default region for org-level operations"
  type        = string
  default     = "northamerica-northeast1"
}

variable "billing_account_id" {
  description = "Billing account ID for new projects (e.g. 012345-6789AB-CDEF01)"
  type        = string
}