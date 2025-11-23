variable "project_id" {
  description = "Unique GCP project ID (e.g. arenaverse-dev)"
  type        = string
}

variable "name" {
  description = "Human-readable project name"
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID (e.g. 012345-6789AB-CDEF01)"
  type        = string
}