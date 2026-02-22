variable "project_id" { type = string }
variable "secret_id" { type = string }

variable "secret_data" {
  type      = string
  sensitive = true
  default   = ""
}

resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  count       = var.secret_data != "" ? 1 : 0
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_data
}

output "id" {
  value = google_secret_manager_secret.secret.id
}
