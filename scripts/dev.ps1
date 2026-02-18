
$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$tfDir = Join-Path $root "infra/envs/local"
$certDir = Join-Path $root "infra/modules/docker_fastapi_platform/certs"
$cnf = Join-Path $certDir "openssl.cnf"

Write-Host "==> [1/4] Hosts entries (requires Admin)"
powershell -ExecutionPolicy Bypass -File (Join-Path $root "scripts\bootstrap-hosts.ps1")

Write-Host "==> [2/4] TLS certs"
New-Item -ItemType Directory -Force -Path $certDir | Out-Null

$crt = Join-Path $certDir "localhost.crt"
$key = Join-Path $certDir "localhost.key"

if (!(Test-Path $crt) -or !(Test-Path $key)) {
    openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes `
      -keyout $key `
      -out $crt `
      -config $cnf `
      -extensions req_ext
} else {
    Write-Host "Certs already exist."
}

Write-Host "==> [3/4] Terraform apply"
Set-Location $tfDir
terraform init
terraform apply -auto-approve

Write-Host "==> [4/4] Done
Write-Host "✅ https://api.localhost/docs"
Write-Host "✅ https://api.localhost/health"
Write-Host "✅ https://traefik.localhost"