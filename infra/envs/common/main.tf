module "project_services" {
  source     = "../../modules/project_services"
  project_id = var.project_id
  services = [
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ]
}

module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = "main-repo"
  depends_on    = [module.project_services]
}

module "service_account_github" {
  source       = "../../modules/service_account"
  project_id   = var.project_id
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/run.admin"
  ]
  depends_on = [module.project_services]
}

module "workload_identity" {
  source                = "../../modules/workload_identity"
  project_id            = var.project_id
  pool_id               = "github-pool"
  provider_id           = "github-provider"
  github_repo           = var.github_repo
  service_account_email = module.service_account_github.email
  depends_on            = [module.project_services]
}
