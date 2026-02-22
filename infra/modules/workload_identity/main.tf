variable "project_id" { type = string }
variable "pool_id" { type = string }
variable "provider_id" { type = string }
variable "github_repo" {
  type        = string
  description = "GitHub repository formatted as owner/repo (e.g., esteban/python-fastapi-test-action)"
}
variable "service_account_email" { type = string }

resource "google_iam_workload_identity_pool" "pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "wi_user" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repo}"
}
