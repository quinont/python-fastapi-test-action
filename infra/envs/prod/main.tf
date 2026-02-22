module "db_credentials" {
  source          = "../../modules/db_credentials"
  username_prefix = "appuser"
}

module "cloudrun_sa" {
  source       = "../../modules/service_account"
  project_id   = var.project_id
  account_id   = "cr-prod-sa"
  display_name = "Cloud Run Prod Service Account"
  roles = [
    "roles/cloudsql.client"
  ]
}

module "cloud_sql" {
  source              = "../../modules/cloud_sql"
  project_id          = var.project_id
  region              = var.region
  instance_name       = "db-prod-instance"
  database_version    = "POSTGRES_15"
  tier                = "db-f1-micro" # Deberia ser mas grande para prod, pero es solo para pruebas nuestro presupuesto nos lo agradecera :)
  db_password         = module.db_credentials.password
  db_username         = module.db_credentials.username
  deletion_protection = true
  init_script_path    = abspath("${path.module}/../../../server/db/init.sh")
}

module "cloud_run" {
  source                = "../../modules/cloud_run"
  project_id            = var.project_id
  region                = var.region
  service_name          = "python-fastapi-test-action"
  db_connection_name    = module.cloud_sql.connection_name
  service_account_email = module.cloudrun_sa.email
}

module "secret_manager" {
  source      = "../../modules/secret_manager"
  project_id  = var.project_id
  secret_id   = "DATABASE_URL"
  secret_data = "postgresql://${module.db_credentials.username}:${module.db_credentials.password}@${module.cloud_sql.public_ip_address}:5432/bookstore"
}
