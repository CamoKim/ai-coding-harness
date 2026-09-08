param([ValidateSet('core')] [string]$Component = 'core')

. (Join-Path $PSScriptRoot 'lib/common.ps1')
Assert-Component $Component
& (Join-Path $PSScriptRoot 'doctor.ps1') -Component $Component
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-State 'READY' 'preflight' 'no changes made; install missing tools through their official instructions'
