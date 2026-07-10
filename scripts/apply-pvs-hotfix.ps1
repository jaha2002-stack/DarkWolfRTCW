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

function Apply-PatchIfNeeded {
    param([string]$PatchPath)

    if (!(Test-Path -LiteralPath $PatchPath)) {
        throw "Patch file not found: $PatchPath"
    }

    Push-Location $RepoRoot
    try {
        $check = Invoke-GitChecked @('apply', '--check', $PatchPath)
        if ($check.Code -eq 0) {
            $apply = Invoke-GitChecked @('apply', '--whitespace=nowarn', $PatchPath)
            if ($apply.Code -ne 0) {
                throw "git apply failed:`n$($apply.Output)"
            }
            Write-Host "Applied patch: $PatchPath"
            return
        }

        $reverseCheck = Invoke-GitChecked @('apply', '--reverse', '--check', $PatchPath)
        if ($reverseCheck.Code -eq 0) {
            Write-Host "Patch already appears to be applied: $PatchPath"
            return
        }

        throw "Patch cannot be applied cleanly.`n`nForward check:`n$($check.Output)`n`nReverse check:`n$($reverseCheck.Output)"
    }
    finally {
        Pop-Location
    }
}

$patchPath = Join-Path $RepoRoot (Join-Path 'patches' '03-pvs-decompressvis-x64.patch')
Apply-PatchIfNeeded -PatchPath $patchPath
