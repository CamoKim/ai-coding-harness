function Write-State([string]$State, [string]$Component, [string]$Detail) {
    Write-Output "$State $Component $Detail"
}

function Assert-Component([string]$Component) {
    if ($Component -ne 'core') {
        Write-State 'UNSUPPORTED' 'component' $Component
        exit 2
    }
}

function Get-CommandState([string]$Name) {
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-State 'READY' $Name 'available'
        return $true
    }
    Write-State 'MISSING' $Name 'not found'
    return $false
}
