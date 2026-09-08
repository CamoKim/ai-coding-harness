param([switch]$Apply, [ValidateSet('core')] [string]$Component = 'core')

. (Join-Path $PSScriptRoot 'lib/common.ps1')
Assert-Component $Component
& (Join-Path $PSScriptRoot 'doctor.ps1') -Component $Component
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($Apply) {
    Write-State 'MANUAL' 'installation' 'core installation adapters are not yet configured'
} else {
    Write-State 'READY' 'preflight' 'no changes made; pass -Apply only after reviewing an adapter'
}
