#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/infra/envs/local"
CERT_DIR="$ROOT_DIR/infra/modules/docker_fastapi_platform/certs"

echo "==> [1/4] Hosts entries"
bash "$ROOT_DIR/scripts/bootstrap-hosts.sh"

echo "==> [2/4] TLS certs (SAN: localhost , api.localhost , traefik.localhost)"
mkdir -p "$CERT_DIR"
if [[ ! -f "$CERT_DIR/localhost.key" || ! -f "$CERT_DIR/localhost.crt" ]]; then
    openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
        -keyout "$CERT_DIR/localhost.key" \
        -out "$CERT_DIR/localhost.crt" \
        -config "$CERT_DIR/openssl.cnf" \
        -extensions req_ext
else 
    echo "Certs already exist."
fi

echo "==> [3/4] Terraform apply"
cd "TF_DIR"
terraform init
terraform apply -auto-approve


echo "==> [4/4] Done"
echo "✅ https://api.localhost/docs"
echo "✅ https://api.localhost/health"
echo "✅ https://traefik.localhost"