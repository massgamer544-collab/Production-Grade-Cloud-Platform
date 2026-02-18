  #!/usr/bin/env bash

  set -euo pipefail

  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  echo "==> Terraform fmt"
  cd "$ROOT_DIR/infra"
  terraform fmt -recusrive 

  echo "==> Terraform validate (no backend)"
  cd "$ROOT_DIR/infra/envs/local"
  terraform init -backend=false
  terraform validate

  echo "==> API tests (pytest)"
  cd "$ROOT_DIR/services/api"
  python -m pip install --upgrade pip >/dev/null
  pip install -r requirements.txt >/dev/null
  pytest -q

  echo "✅ check complete"