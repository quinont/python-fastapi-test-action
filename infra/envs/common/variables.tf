variable "project_id" { type = string }
variable "region" { default = "us-central1" }
variable "github_repo" {
  type        = string
  description = "owner/repo formato para GitHub Actions (ej. quinont/python-fastapi-test-action)"
}
