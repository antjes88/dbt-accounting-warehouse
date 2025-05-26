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

data "google_artifact_registry_repository" "my_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "cloud-run-jobs"
}

resource "google_cloud_run_v2_job" "dbt_job" {
  name     = "daily-dbt-run-job"
  location = var.region

  template {
    template {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.my_repo.repository_id}/${var.image_name}:${var.image_tag}"

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

data "google_monitoring_notification_channel" "basic" {
  display_name = "Personal email for alerting purposes"
}

resource "google_monitoring_alert_policy" "job_failed" {
  project               = var.project_id
  display_name          = "Cloud Run Job Failed: ${google_cloud_run_v2_job.dbt_job.name}"
  combiner              = "OR"
  severity              = "ERROR"
  notification_channels = [data.google_monitoring_notification_channel.basic.id]

  conditions {
    display_name = "Failed Execution of ${google_cloud_run_v2_job.dbt_job.name}"

    condition_threshold {
      filter = format(
        "metric.type=\"run.googleapis.com/job/completed_task_attempt_count\" resource.type=\"cloud_run_job\" resource.label.\"job_name\"=\"%s\" resource.label.\"location\"=\"%s\" metric.label.\"result\"=\"failed\"",
        google_cloud_run_v2_job.dbt_job.name,
        google_cloud_run_v2_job.dbt_job.location
      )

      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      trigger {
        count = 1
      }

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    content   = <<-EOT
      The job `${google_cloud_run_v2_job.dbt_job.name}` has failed at least once in the last minute.

      🔍 [View Logs in Cloud Logging](https://console.cloud.google.com/run/jobs/details/${var.region}/${google_cloud_run_v2_job.dbt_job.name}/logs)
      EOT
    mime_type = "text/markdown"
  }
}
