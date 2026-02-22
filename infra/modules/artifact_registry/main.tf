variable "project_id" { type = string }
variable "region" { type = string }
variable "repository_id" { type = string }

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
}

output "id" {
  value = google_artifact_registry_repository.repo.id
}
