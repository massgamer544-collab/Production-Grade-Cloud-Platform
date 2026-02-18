
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")

Write-Host "==> Terraform fmt"
Set-Location (Join-Path $root "infra")
terraform fmt -recursive

Write-Host "==> Terraform validate (no backend)"
Set-Location (Join-Path $root "infra\envs\local")
terraform init -backend=false
terraform validate

Write-Host "==> API tests (pytest)"
Set-Location (Join-Path $root "services\api")
python -m pip install --upgrade pip | Out-Null
pip install -r requirements.txt | Out-Null
pytest -q

Write-Host "✅ check complete"