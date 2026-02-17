variable "name" {
  type    = string
  default = "platform-lab"
}

variable "api_port" {
  type    = number
  default = 8000
}

variable "postgres_user" {
  type    = string
  default = "app"
}

variable "postgres_password" {
  type    = string
  default = "app_password"
}

variable "postgres_db" {
  type    = string
  default = "appdb"
}
