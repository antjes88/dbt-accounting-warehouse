variable "project_id" {
  type        = string
  description = "Name of the Google Project"
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "Location for the resources"
}
