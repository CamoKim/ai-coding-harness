param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('enable', 'status', 'remove')]
    [string]$Action,
    [Parameter(Position = 1, Mandatory = $true)]
    [string]$ProjectId,
    [Parameter(Position = 2)]
    [string]$Repository
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-ProjectId([string]$Value) {
    if ($Value -notmatch '^[A-Za-z0-9][A-Za-z0-9_-]*$') {
        throw 'project identifier must contain only letters, numbers, underscores, or hyphens'
    }
}

function Get-TaskName([string]$Value) { "Graphify-Watch-$Value" }

function Get-ConfigPath([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) { throw 'LOCALAPPDATA is unavailable' }
    Join-Path (Join-Path $env:LOCALAPPDATA 'graphify-watch/projects') "$Value.env"
}

function Assert-Repository([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value) -or -not (Test-Path -LiteralPath $Value -PathType Container)) {
        throw 'repository is not a Git repository'
    }
    $InsideWorkTree = & git -C $Value rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $InsideWorkTree -ne 'true') { throw 'repository is not a Git repository' }
    (Resolve-Path -LiteralPath $Value).Path
}

function Get-GraphifyPath {
    $Command = Get-Command graphify -CommandType Application -ErrorAction SilentlyContinue
    if (-not $Command -or [string]::IsNullOrWhiteSpace($Command.Path)) { throw 'graphify is not available as an executable' }
    $Command.Path
}

Assert-ProjectId $ProjectId
$TaskName = Get-TaskName $ProjectId

switch ($Action) {
    'enable' {
        if ([string]::IsNullOrWhiteSpace($Repository)) { throw 'enable requires an identifier and repository' }
        $Repository = Assert-Repository $Repository
        $GraphifyPath = Get-GraphifyPath
        $ConfigPath = Get-ConfigPath $ProjectId
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ConfigPath) | Out-Null
        Set-Content -LiteralPath $ConfigPath -Value "GRAPHIFY_PROJECT=$Repository" -NoNewline
        $TaskCommand = "`"$GraphifyPath`" watch `"$Repository`""
        & schtasks /Create /TN $TaskName /TR $TaskCommand /SC ONLOGON /RL LIMITED /F
        if ($LASTEXITCODE -ne 0) { throw "failed to register task $TaskName" }
    }
    'status' {
        & schtasks /Query /TN $TaskName
        if ($LASTEXITCODE -ne 0) { throw "failed to query task $TaskName" }
    }
    'remove' {
        & schtasks /Delete /TN $TaskName /F
        if ($LASTEXITCODE -ne 0) { throw "failed to remove task $TaskName" }
        Remove-Item -LiteralPath (Get-ConfigPath $ProjectId) -Force -ErrorAction SilentlyContinue
    }
}
