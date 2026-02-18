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

  networks_advanced {
    name = docker_network.net.name
  }

  env = [
    "DATABASE_URL=${local.dsn}",
  ]

  # IMPORTANT: no direct port exposure; Traefik routes to the internal port 8000
  # ports {
  #   internal = 8000
  #   external = var.api_port
  # }

  labels = {
    "traefik.enable" = "true"

    # Router: https://api.localhost/*
    "traefik.http.routers.api.rule"        = "Host(`api.localhost`) && PathPrefix(`/`)"
    "traefik.http.routers.api.entrypoints" = "websecure"
    "traefik.http.routers.api.tls"         = "true"

    # Attach middlewares (security headers + rate limit)
    "traefik.http.routers.api.middlewares" = "sec-headers@docker,rate-limit@docker"

    # Service: internal port of FastAPI container
    "traefik.http.services.api.loadbalancer.server.port" = "8000"

    # ---- Middlewares definitions ----

    # Security headers baseline
    "traefik.http.middlewares.sec-headers.headers.stsSeconds"            = "31536000"
    "traefik.http.middlewares.sec-headers.headers.stsIncludeSubdomains"  = "true"
    "traefik.http.middlewares.sec-headers.headers.stsPreload"            = "true"
    "traefik.http.middlewares.sec-headers.headers.frameDeny"             = "true"
    "traefik.http.middlewares.sec-headers.headers.contentTypeNosniff"    = "true"
    "traefik.http.middlewares.sec-headers.headers.browserXssFilter"      = "true"
    "traefik.http.middlewares.sec-headers.headers.referrerPolicy"        = "no-referrer"

    # Basic rate limiting
    "traefik.http.middlewares.rate-limit.ratelimit.average" = "50"
    "traefik.http.middlewares.rate-limit.ratelimit.burst"   = "100"
  }

  depends_on = [
    docker_container.postgres,
    docker_container.traefik
  ]
}

resource "docker_container" "traefik" {
 name  = "${var.name}-traefik"
  image = docker_image.traefik.image_id

  networks_advanced {
    name = docker_network.net.name
  }

  # HTTP :80 (redirige vers HTTPS)
  ports {
    internal = 80
    external = 80
  }

  # HTTPS :443
  ports {
    internal = 443
    external = 443
  }

  command = [
    # Dashboard enabled but NOT insecure
    "--api.dashboard=true",
    "--api.insecure=false",

    # Providers
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",

    # Dynamic config file (TLS certs)
    "--providers.file.directory=/etc/traefik/dynamic",
    "--providers.file.watch=true",

    # EntryPoints
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",

    # Redirect HTTP -> HTTPS
    "--entrypoints.web.http.redirections.entrypoint.to=websecure",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
  ]

  # Allow Traefik to read Docker labels
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  # TLS certs (self-signed) mounted into Traefik
  volumes {
    host_path      = "${path.module}/certs"
    container_path = "/etc/traefik/certs"
  }

  # Dynamic config (contains TLS cert mapping)
  volumes {
    host_path      = "${path.module}/traefik"
    container_path = "/etc/traefik/dynamic"
  }

  # Expose Traefik dashboard at https://traefik.localhost
  labels = {
    "traefik.enable" = "true"

    "traefik.http.routers.traefik.rule"        = "Host(`traefik.localhost`)"
    "traefik.http.routers.traefik.entrypoints" = "websecure"
    "traefik.http.routers.traefik.tls"         = "true"
    "traefik.http.routers.traefik.service"     = "api@internal"
  }
}