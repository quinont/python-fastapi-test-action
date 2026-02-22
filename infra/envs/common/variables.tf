variable "project_id" {
  type        = string
  description = "ID del proyecto de Google Cloud"
  default     = "TU-PROYECTO-AQUI"
}
variable "region" {
  type        = string
  description = "Region de Google Cloud"
  default     = "us-central1"
}
variable "github_repo" {
  type        = string
  description = "owner/repo formato para GitHub Actions (ej. quinont/python-fastapi-test-action)"
}
