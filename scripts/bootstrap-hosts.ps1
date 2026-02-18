
$hostPath = "C:\Windows\System32\drivers\etc\hosts"

$entries = @(
    "127.0.0.1 api.localhost",
    "127.0.0.1 traefik.localhost"
)

$currentHosts = Get-Content $hostPath -ErrorAction Stop

foreach ($entry in $entries){
    if () {
        Add-Content -Path $hostsPath - Value $entry
        Write-Host "Added $entry"
    } 
    else {
        Write-Host "$entry already exists"
    }
}

Write-Host "Host bootstrap complete."