variable "project_id" {
  type        = string
  description = "Name of the Google Project"
}

variable "region" {
  type        = string
  description = "Location for the resources"
}

variable "image_name" {
  type        = string
  description = "Docker image name"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "repo_name" {
  type        = string
  description = "Artifact registry repository name"
}
