variable "project_id" { type = string }
variable "account_id" { type = string }
variable "display_name" { type = string }
variable "roles" {
  type    = list(string)
  default = []
}

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.sa.email}"
}

output "email" {
  value = google_service_account.sa.email
}

output "name" {
  value = google_service_account.sa.name
}
