$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Bootstrap = Join-Path $Root 'reproduction/bootstrap.ps1'
$Doctor = Join-Path $Root 'reproduction/doctor.ps1'

if (-not (Test-Path -LiteralPath $Bootstrap)) { throw 'bootstrap.ps1 is missing' }
if (-not (Test-Path -LiteralPath $Doctor)) { throw 'doctor.ps1 is missing' }

$doctorOutput = & $Doctor -Component core 2>&1
if ($LASTEXITCODE -ne 0) { throw "doctor failed: $doctorOutput" }
if ($doctorOutput -notmatch 'MANUAL codex-login') { throw 'doctor does not preserve manual login boundary' }

$bootstrapOutput = & $Bootstrap -Component core 2>&1
if ($LASTEXITCODE -ne 0) { throw "bootstrap failed: $bootstrapOutput" }
if ($bootstrapOutput -notmatch 'READY preflight') { throw 'bootstrap does not perform read-only preflight' }

$applyOutput = & pwsh -NoProfile -File $Bootstrap -Apply 2>&1
if ($LASTEXITCODE -eq 0) { throw 'bootstrap accepted the removed -Apply option' }
if ($applyOutput -match 'READY installation') { throw 'bootstrap attempted installation' }

Write-Output 'PASS: powershell core contract'
