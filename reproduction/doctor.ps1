param([ValidateSet('core')] [string]$Component = 'core')

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/common.ps1')
Assert-Component $Component

$failures = 0
if (-not (Get-CommandState 'git')) { $failures++ }
if (-not (Get-CommandState 'codex')) { $failures++ }
Write-State 'MANUAL' 'codex-login' 'complete account login and authorization yourself'
Write-State 'MANUAL' 'superpowers-plugin' 'install or authorize the plugin through Codex'
if ($failures -ne 0) { exit 1 }
