param(
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"
$Root = Join-Path $PSScriptRoot "local-feed"

if (-not (Test-Path -LiteralPath $Root)) {
    throw "local-feed folder not found. Run: python .\tools\make_packages_index.py"
}

$ips = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Select-Object -ExpandProperty IPAddress

Write-Host "Serving NeoFit local feed from:"
Write-Host "  $Root"
Write-Host ""
Write-Host "Router install command examples:"
foreach ($ip in $ips) {
    Write-Host "  BASE_URL=http://$ip`:$Port sh -c `"`$(wget -O- http://$ip`:$Port/install-neofit-local.sh)`""
}
Write-Host ""
Write-Host "Press Ctrl+C to stop the server."

python -m http.server $Port --directory $Root
