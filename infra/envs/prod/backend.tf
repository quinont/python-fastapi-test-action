terraform {
  backend "gcs" {
    bucket = "TU-BUCKET-DE-ESTADO-AQUI"
    prefix = "terraform/state/prod"
  }
}
