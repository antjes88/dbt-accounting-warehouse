terraform {
  required_version = ">= 1.0"
  backend "gcs" {
    bucket = "terraform-state-v8q0qvfi"
    prefix = "terraform/state/dbt-accounting-warehouse"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_service_account" "default" {
  account_id = "dbt-accounting-warehouse"
  project    = var.project_id
}


resource "google_cloud_run_v2_job" "dbt_job" {
  name     = "daily-dbt-run-job"
  location = var.region

  template {
    template {
      containers {
        image = "europe-west2-docker.pkg.dev/${var.project_id}/cloud-run-jobs/dbt-test:${var.image_tag}"

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }

      service_account = data.google_service_account.default.email
      timeout         = "600s"
      max_retries     = 0
    }
  }

}

resource "google_cloud_scheduler_job" "trigger_run_job" {
  name        = "trigger-daily-dbt-run-job"
  description = "Triggers the DBT run job on a schedule"
  schedule    = "15 0 * * *"
  time_zone   = "Europe/London"

  http_target {
    uri         = "https://${google_cloud_run_v2_job.dbt_job.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.dbt_job.name}:run"
    http_method = "POST"
    oauth_token {
      service_account_email = data.google_service_account.default.email
    }
    headers = {
      "Content-Type" = "application/json"
    }
  }
}
