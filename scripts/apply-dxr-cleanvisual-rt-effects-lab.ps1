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
    $global:LASTEXITCODE = 0

    [pscustomobject]@{
        Code = $code
        Output = ($output -join [Environment]::NewLine)
    }
}

function Apply-PatchIfNeeded {
    param([string]$PatchPath)

    if (!(Test-Path -LiteralPath $PatchPath)) {
        throw "Patch file not found: $PatchPath"
    }

    $check = Invoke-GitChecked @('apply', '--check', $PatchPath)
    if ($check.Code -eq 0) {
        $apply = Invoke-GitChecked @('apply', '--whitespace=nowarn', $PatchPath)
        if ($apply.Code -ne 0) {
            throw "git apply failed for $PatchPath`n$($apply.Output)"
        }
        Write-Host "Applied patch: $PatchPath"
        return
    }

    $reverse = Invoke-GitChecked @('apply', '--reverse', '--check', $PatchPath)
    if ($reverse.Code -eq 0) {
        Write-Host "Patch already applied, skipping: $PatchPath"
        return
    }

    throw "Patch cannot be applied and is not already present: $PatchPath`nCHECK:`n$($check.Output)`nREVERSE CHECK:`n$($reverse.Output)"
}

Push-Location $RepoRoot
try {
    $raySource = Join-Path $RepoRoot 'src/opengl/gl_d3d12raylight.cpp'
    if (Test-Path -LiteralPath $raySource) {
        $rayText = [IO.File]::ReadAllText($raySource)
        $labAlreadyPresent = $rayText.Contains('GL_RAYTRACING_LAB_DESCRIPTORS_PER_PASS')
        $trueRtExperimentalPresent = $rayText.Contains('RadianceClosestHit') -or $rayText.Contains('GL_RAYTRACING_MAX_MATERIALS')
        if ($trueRtExperimentalPresent -and !$labAlreadyPresent) {
            throw 'An older TrueRT/M2M3 experimental renderer is present. Apply this kit to the stable Clean Visual Performance v2 branch, not on top of M1/M2/M3.'
        }
    }

    $baseApply = Join-Path $RepoRoot 'scripts/apply-dxr-clean-visual-performance.ps1'
    if (!(Test-Path -LiteralPath $baseApply)) {
        throw "Base Performance v2 apply script is missing: $baseApply"
    }

    Write-Host 'Applying/validating the Clean Visual Performance v2 baseline...'
    # The base script intentionally ends with 'exit 0'. Run it in a child
    # PowerShell process so it cannot terminate this Lab apply script before
    # patch 08 is processed.
    $pwshPath = (Get-Process -Id $PID).Path
    & $pwshPath -NoProfile -ExecutionPolicy Bypass -File $baseApply -RepoRoot $RepoRoot
    $baseCode = $LASTEXITCODE
    $global:LASTEXITCODE = 0
    if ($baseCode -ne 0) {
        throw "Base Performance v2 apply script failed with exit code $baseCode"
    }

    Write-Host 'Applying the isolated RT Effects Lab patch...'
    Apply-PatchIfNeeded -PatchPath (Join-Path $RepoRoot 'patches/08-dxr-cleanvisual-rt-effects-lab.patch')
}
finally {
    Pop-Location
}

Write-Host 'DXR CleanVisual RT Effects Lab patch stack applied successfully.'
$global:LASTEXITCODE = 0
exit 0
