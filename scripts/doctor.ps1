
$ErrorActionPreference = "Stop"

function Test-cmd($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Print-Ok($msg) { Write-Host "✅ $msg" -ForegroundColor green}
function Print-Bad($msg) { Write-Host "❌ $msg" -ForegroundColor Red}
function Print-Info($msg) { Write-Host "ℹ️ $msg" -ForegroundColor Yellow}

$missing = @()

Write-Host "==== Doctor Report (Windows) ===="
Write-Host ""

# Git
if(Test-cmd git) { Print-Ok "git setected: $(git --version)"}
else { Print-Bad "git missing"; $missing += "git"; Print-Info "Install Git for windows"}

# Docker 
if(Test-cmd docker) {
    try {
        $ver = docker --version
        Print-Ok "docker detected: $ver"
        docker info > $null 2>&1
        if($LASTEXITCODE -eq 0) { Print-Ok "docker engine reachable" }
        else { Print-Bad "docker engine not reachable (is Docker Desktop running?)"; $missing += "docker-engine" }
    } catch {
        Print-Bad "docker present but failed to run"; $missing += "docker"
    }
} else {
    Print-Bad "docker missing"; $missing += "docker"
    Print-Info "Install Docker Desktop"
}

# Terraform
if(Test-cmd terraform) {Print-Ok "terraform detected: $(terraform version | Select-Object -First 1)"}
else { Print-Bad "terraform missing"; $missing += "terraform"; Print-Info "Install Terraform from HashiCorp" }

#OpenSSL
if(Test-cmd openssl) { Print-Ok "openssl detected: $(openssl version)"}
else {
    Print-Bad "openssl missing"; $missing += "openssl"
    Print-Info "If you use Git Bash, OpenSSL is often included. Otherwise install OpenSSL."
}

# Python + pip
if(Test-cmd python) { Print-Ok "python detected: $(python --version)"}
elseif (Test-cmd py) { Print-Ok "py launcher detected: $(py --version)"; Print-Info "Using py is OK."}
else { Print-Bad "python missing"; $miising += "python";Print-Info "Install Python 3.11+"}

if (Test-cmd pip) { Print-Ok "pip detected: $(pip --version)" }
else {Print-Bad "pip missing"; $missing += "pip"; Print-Info "pip usually comes with python. Try python -m ensurepip"}

Write-Host ""
if($missing.Count -gt 0) {
    Print-Bad "Missing requirements: $($missing -join ', ')"
    exit 1
} else {
    Print-Ok "All requirements satisfied."
    exit 0
}