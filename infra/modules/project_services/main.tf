variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "services" {
  type        = list(string)
  description = "List of APIs to enable"
  default = [
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "google_project_service" "services" {
  for_each           = toset(var.services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
