[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-GitChecked {
    param([string[]]$Arguments)
    $output = & git @Arguments 2>&1
    $code = $LASTEXITCODE
    return [pscustomobject]@{ Code = $code; Output = ($output -join [Environment]::NewLine) }
}

$patchPath = Join-Path $RepoRoot 'patches/04-dxr-visibility-debug.patch'
if (!(Test-Path -LiteralPath $patchPath)) {
    throw "Patch file not found: $patchPath"
}

Push-Location $RepoRoot
try {
    $check = Invoke-GitChecked @('apply', '--check', $patchPath)
    if ($check.Code -eq 0) {
        $apply = Invoke-GitChecked @('apply', '--whitespace=nowarn', $patchPath)
        if ($apply.Code -ne 0) {
            throw "git apply failed:`n$($apply.Output)"
        }
        Write-Host "Applied patch: $patchPath"
        exit 0
    }

    $reverseCheck = Invoke-GitChecked @('apply', '--reverse', '--check', $patchPath)
    if ($reverseCheck.Code -eq 0) {
        Write-Host "Patch already appears to be applied: $patchPath"
        exit 0
    }

    throw "Patch cannot be applied cleanly.`n`nForward check:`n$($check.Output)`n`nReverse check:`n$($reverseCheck.Output)"
}
finally {
    Pop-Location
}
