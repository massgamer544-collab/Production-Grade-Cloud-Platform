module "platform" {
  source = "../../modules/docker_fastapi_platform"

  name     = "prod-grade-platform"
  api_port = 8000

  # You can change these later (or wire them from tfvars)
  postgres_user     = "app"
  postgres_password = "app_password"
  postgres_db       = "appdb"
}
