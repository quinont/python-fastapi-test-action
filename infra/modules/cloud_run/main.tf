variable "project_id" { type = string }
variable "region" { type = string }
variable "service_name" { type = string }
variable "dummy_image" {
  default = "us-docker.pkg.dev/cloudrun/container/hello:latest"
}
variable "db_connection_name" {
  type    = string
  default = ""
}
variable "service_account_email" {
  type    = string
  default = ""
}

resource "google_cloud_run_v2_service" "service" {
  project  = var.project_id
  location = var.region
  name     = var.service_name

  template {
    service_account = var.service_account_email != "" ? var.service_account_email : null

    containers {
      image = var.dummy_image

      dynamic "volume_mounts" {
        for_each = var.db_connection_name != "" ? [1] : []
        content {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
    }

    dynamic "volumes" {
      for_each = var.db_connection_name != "" ? [1] : []
      content {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [var.db_connection_name]
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = google_cloud_run_v2_service.service.project
  location = google_cloud_run_v2_service.service.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = google_cloud_run_v2_service.service.uri
}
