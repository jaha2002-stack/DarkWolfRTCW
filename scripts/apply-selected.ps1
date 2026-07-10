[CmdletBinding()]
param(
    [ValidateSet('minimal', 'stable', 'none')]
    [string]$Variant = 'stable',

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

if ($Variant -eq 'none') {
    Write-Host 'Patch step skipped because Variant=none.'
    exit 0
}

$patchName = switch ($Variant) {
    'minimal' { '01-dxr-minimal-visibility.patch' }
    'stable'  { '02-dxr-stable-mode.patch' }
}

$patchPath = Join-Path $RepoRoot (Join-Path 'patches' $patchName)
Apply-PatchIfNeeded -PatchPath $patchPath
