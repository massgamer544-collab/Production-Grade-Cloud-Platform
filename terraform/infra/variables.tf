variable "project" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key_path" { type = string }

variable "ssh_source_cidr" {
  type    = string
  default = "*"
}
