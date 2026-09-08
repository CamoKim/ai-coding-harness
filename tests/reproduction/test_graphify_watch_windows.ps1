$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Adapter = Join-Path $Root 'reproduction/graphify-watch/windows.ps1'

if (-not (Test-Path -LiteralPath $Adapter)) { throw 'Windows Graphify watcher adapter is missing' }

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-graphify-watch-windows-" + [guid]::NewGuid())
$Source = Join-Path $TempRoot 'source'
$Repo = Join-Path $TempRoot 'repo'
New-Item -ItemType Directory -Force -Path $Source | Out-Null
& git -C $Source init --quiet
& git -C $Source -c user.name=Harness -c user.email=harness@example.invalid commit --allow-empty --quiet -m initial
& git -C $Source worktree add --quiet $Repo
$FakeBin = Join-Path $TempRoot 'bin'
New-Item -ItemType Directory -Force -Path $FakeBin | Out-Null
Set-Content -LiteralPath (Join-Path $FakeBin 'graphify.cmd') -Value '@exit /b 0' -NoNewline
$PreviousLocalAppData = $env:LOCALAPPDATA
$PreviousPath = $env:PATH
$env:LOCALAPPDATA = Join-Path $TempRoot 'localappdata'
$env:PATH = "$FakeBin;$env:PATH"
$script:ScheduledTasks = [System.Collections.Generic.List[string]]::new()

function schtasks {
    param([Parameter(ValueFromRemainingArguments = $true)] [string[]]$Arguments)
    $script:ScheduledTasks.Add(($Arguments -join ' '))
    $global:LASTEXITCODE = 0
}

try {
    $invalidAccepted = $false
    try {
        & $Adapter enable 'bad/id' $Repo | Out-Null
        $invalidAccepted = $true
    } catch { }
    if ($invalidAccepted) { throw 'invalid identifier was accepted' }
    if ($script:ScheduledTasks.Count -ne 0) { throw 'invalid identifier invoked schtasks' }

    $Bogus = Join-Path $TempRoot 'bogus'
    New-Item -ItemType Directory -Force -Path (Join-Path $Bogus '.git') | Out-Null
    $bogusAccepted = $false
    try {
        & $Adapter enable bogus $Bogus | Out-Null
        $bogusAccepted = $true
    } catch { }
    if ($bogusAccepted) { throw 'repository validation accepted fake Git metadata' }

    & $Adapter enable demo $Repo
    if (($script:ScheduledTasks -join "`n") -notmatch '/Create /TN Graphify-Watch-demo ') {
        throw 'enable does not target the exact task'
    }

    & $Adapter remove demo
    if (($script:ScheduledTasks -join "`n") -notmatch '/Delete /TN Graphify-Watch-demo /F') {
        throw 'remove does not target the exact task'
    }
} finally {
    $env:LOCALAPPDATA = $PreviousLocalAppData
    $env:PATH = $PreviousPath
    Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'PASS: Windows Graphify watcher adapter'
