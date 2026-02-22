variable "username_prefix" {
  type    = string
  default = "appuser"
}

resource "random_id" "user_suffix" {
  byte_length = 2
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

output "username" {
  value = "${var.username_prefix}_${random_id.user_suffix.hex}"
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}
