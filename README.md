# 🚀 Production-Grade Developer Platform  
### Local-first • Cloud-ready • One-command bootstrap

![CI](../../actions/workflows/ci.yml/badge.svg)

A fully automated developer platform enabling **one-command environment provisioning** with infrastructure-as-code, TLS routing, automated quality gates, and production-inspired architecture.

Designed to mirror real-world platform engineering practices.

---

# ⚡ One Command Bootstrap

make dev 

# Bootstrap automatically : 

✅ hosts entries
✅ TLS certificates
✅ reverse proxy (Traefik)
✅ FastAPI service
✅ Postgres database
✅ Terraform infrastructure
✅ security middlewares
✅ CI validation

## 🌐 Access

After bootstrap:

👉 https://api.localhost/docs

👉 https://api.localhost/health

👉 https://traefik.localhost

## 🧠 Architecture

Client
   ↓
Traefik (TLS Gateway)
   ↓
FastAPI
   ↓
Postgres

## 🛠 Tech Stack

Platform :
-Terraform
-Docker
-Traefik (TLS reverse proxy)

Backend:
-FastAPI
-PostgreSQL

Quality & Security:
-pytest
-tflint
-checkov
-terraform validate
-CI pipeline

## Developer Experience
# Start environment
make dev

# Run checks
make check

# Destroy environment
make down

## 🖥 Windows Users

Run terminal as Administrator (required to modify hosts file).

Fallback:

Double-click:

scripts/dev.cmd

## 🔐 TLS Notes

Self-signed certificates are generated automatically.

Browser warnings are expected.


## ☁️ Cloud Platform (Azure)

This repository also includes a production-style Azure infrastructure built with Terraform.

Features:

Environment separation (dev / test)

Remote state ready

Network security groups

Virtual network + subnet

Linux VM

Consistent tagging strategy

## Requirements

Terraform >= 1.6

Azure CLI

Active Azure subscription

Quick Start (Azure)
cd infra

cp terraform.tfvars.example terraform.tfvars
cp backend-dev.tf.example backend-dev.tf

terraform init
terraform plan
terraform apply

SSH Access
ssh -i id_ed25519 azureuser@<PUBLIC_IP>

Destroy Infrastructure
terraform destroy

## 🧱 Design Decisions
Infrastructure as Code

Everything is defined declaratively to ensure repeatability.

Gateway-first Architecture

Services are never exposed directly — traffic flows through a reverse proxy.

Local-first Strategy

The platform is fully testable without cloud dependencies.

Cloud-ready

Architecture supports seamless transition to cloud environments.

Quality Gates

CI enforces formatting, validation, linting, security scanning, and tests.

## 📈 What This Demonstrates

This project highlights capabilities in:

Platform Engineering

DevOps practices

Infrastructure design

Secure defaults

Automation

Developer tooling

## 🚀 Future Enhancements

Observability stack (Grafana + Prometheus)

Redis + async workers

Auth service (Keycloak)

Multi-service routing

Kubernetes migration path

## 👤 Author

Built as part of an advanced platform engineering portfolio.