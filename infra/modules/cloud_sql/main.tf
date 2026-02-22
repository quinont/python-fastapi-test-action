variable "project_id" { type = string }
variable "region" { type = string }
variable "instance_name" { type = string }
variable "database_version" { default = "POSTGRES_15" }
variable "tier" { default = "db-f1-micro" }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "bookstore"
}

variable "db_username" {
  type = string
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "init_script_path" {
  type        = string
  description = "Path to an initialization script (e.g. server/db/init.sh) to run via local-exec."
  default     = ""
}

resource "google_sql_database_instance" "instance" {
  project          = var.project_id
  region           = var.region
  name             = var.instance_name
  database_version = var.database_version

  settings {
    tier = var.tier
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_user" "users" {
  project  = var.project_id
  name     = var.db_username
  instance = google_sql_database_instance.instance.name
  password = var.db_password
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

resource "null_resource" "db_init" {
  count = var.init_script_path != "" ? 1 : 0

  triggers = {
    script_hash = filemd5(var.init_script_path)
    instance_id = google_sql_database_instance.instance.id
  }

  provisioner "local-exec" {
    command = "bash $INIT_SCRIPT"
    environment = {
      INIT_SCRIPT                = var.init_script_path
      PGHOST                     = google_sql_database_instance.instance.public_ip_address
      PGPASSWORD                 = var.db_password
      POSTGRES_MASTER            = var.db_username
      WORKSHOP_POSTGRES_USER     = "user"
      WORKSHOP_POSTGRES_PASSWORD = var.db_password
      WORKSHOP_POSTGRES_DB       = var.db_name
    }
  }

  depends_on = [
    google_sql_database_instance.instance
  ]
}

output "connection_name" {
  value = google_sql_database_instance.instance.connection_name
}

output "public_ip_address" {
  value = google_sql_database_instance.instance.public_ip_address
}
