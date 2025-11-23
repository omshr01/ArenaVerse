variable "project_id" {
  description = "GCP project to use for bootstrap (where the state bucket lives)"
  type        = string
}

variable "region" {
  description = "Default region for bootstrap actions"
  type        = string
  default     = "northamerica-northeast1"
}