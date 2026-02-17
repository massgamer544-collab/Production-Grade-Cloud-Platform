terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  net_name  = "${var.name}-net"
  pg_name   = "${var.name}-postgres"
  api_name  = "${var.name}-api"

  # Network-scoped hostname for Postgres
  pg_host = local.pg_name

  dsn = "postgresql://${var.postgres_user}:${var.postgres_password}@${local.pg_host}:5432/${var.postgres_db}"
}

resource "docker_network" "net" {
  name = local.net_name
}

resource "docker_image" "postgres" {
  name = "postgres:16-alpine"
}

resource "docker_container" "postgres" {
  name  = local.pg_name
  image = docker_image.postgres.image_id

  networks_advanced {
    name = docker_network.net.name
  }

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}",
  ]

  # Optional: persist data locally (safe for demos)
  # mounts {
  #   type   = "volume"
  #   target = "/var/lib/postgresql/data"
  #   source = "${var.name}-pgdata"
  # }

  ports {
    internal = 5432
    external = 5432
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.postgres_user} -d ${var.postgres_db} || exit 1"]
    interval = "10s"
    timeout  = "3s"
    retries  = 10
  }
}

resource "docker_image" "fastapi" {
  name = "${var.name}-fastapi:latest"

  build {
    context    = "${path.module}/../../../services/api"
    dockerfile = "Dockerfile"
  }
}


resource "docker_container" "api" {
  name  = local.api_name
  image = docker_image.fastapi.image_id

  networks_advanced { name = docker_network.net.name }

  env = ["DATABASE_URL=${local.dsn}"]

  ports {
    internal = 8000
    external = var.api_port
  }

  depends_on = [docker_container.postgres]
}
