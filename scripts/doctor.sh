#!/usr/bin/env bash
set -euo pipefail

ok() { echo "✅ $1"; }
bad()  { echo "❌ $1"; }
info() { echo "ℹ️  $1"; }

missing=()

cmd_exist() { command -v "$1" >/dev/null 2>&1; }

echo "=== Doctor Report (Unix) ==="
echo

# git 
if cmd_exist git; then ok "git detected $(git --version)"; else bad "git missing"; missing+=("git"); fi

# docker
if cmd_exist docker; then
    ok "docker detected: $(docker --version)"
    if docker info >/dev/null 2>&1; then ok "docker engine reachable"; else bad "docker engine not reachable (is daemon running?)"; missing+=("docker-engine"); fi
else
    bad "docker missing"; missing+=("docker")
fi 

# Terraform
if cmd_exist terraform; then ok "terraform detected: $(terraform version | head -n 1)"; else bad "terraform missing"; missing+=("terraform"); fi 

# OpenSSL
if cmd_exist openssl; then ok "openssl detected: $(openssl version)"; else bad "openssl missing"; missing+=("openssl"); fi

# python / pip
if cmd_exists python3; then ok "python detected: $(python3 --version)"; else bad "python3 missing"; missing+=("python3"); fi
if cmd_exists pip3; then ok "pip detected: $(pip3 --version)"; else bad "pip3 missing"; missing+=("pip3"); fi

echo
if [ ${#missing[@]} -gt 0 ]; then
  bad "Missing requirements: ${missing[*]}"
  exit 1
else
  ok "All requirements satisfied."
  exit 0
fi