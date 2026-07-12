[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Push-Location $RepoRoot
try {
    function Test-Contains([string]$Path, [string]$Needle) {
        if (-not (Test-Path -LiteralPath $Path)) { return $false }
        return (Select-String -LiteralPath $Path -SimpleMatch $Needle -Quiet)
    }

    function Apply-Maybe([string]$Patch) {
        Write-Host "Checking $Patch"
        & git apply --check $Patch 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Applying $Patch"
            & git apply $Patch
            if ($LASTEXITCODE -ne 0) { throw "git apply failed for $Patch" }
            return
        }

        & git apply --reverse --check $Patch 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Already applied: $Patch"
            return
        }

        throw "Patch does not apply cleanly and is not already applied: $Patch"
    }

    if ((Test-Contains 'src/opengl/gl_d3d12raylight.cpp' 'DXR FINAL HQ SMOOTH') -and (Test-Contains 'src/renderer/tr_init.cpp' 'r_dxrDispatchWidth", "160"')) {
        Write-Host 'DXR Final HighQuality Stable patch already detected; nothing to apply.'
        return
    }

    if ((Test-Contains 'src/opengl/gl_d3d12raylight.cpp' 'Playable TDR-safe composite') -and (Test-Contains 'src/renderer/tr_init.cpp' 'r_dxrLegacyBlend", "0.90"')) {
        Write-Host 'Existing Playable TDR-safe stack detected; applying only patch 11.'
        $patches = @('patches/11-dxr-final-hq-smooth-safe-presets.patch')
    }
    elseif ((Test-Contains 'src/opengl/gl_d3d12raylight.cpp' 'DXR TDRSAFE') -and (Test-Contains 'src/renderer/tr_init.cpp' 'r_dxrFreezeScene')) {
        Write-Host 'Existing TDR-safe runtime stack detected; applying patches 10-11.'
        $patches = @(
            'patches/10-dxr-playable-detail-composite-defaults.patch',
            'patches/11-dxr-final-hq-smooth-safe-presets.patch'
        )
    }
    elseif ((Test-Contains 'src/opengl/gl_d3d12raylight.cpp' 'DXR HALFRES') -and (Test-Contains 'src/renderer/tr_init.cpp' 'r_dxrRenderScale')) {
        Write-Host 'Existing HalfRes stack detected; applying patches 09-11.'
        $patches = @(
            'patches/09-dxr-tdr-safe-runtime-freeze.patch',
            'patches/10-dxr-playable-detail-composite-defaults.patch',
            'patches/11-dxr-final-hq-smooth-safe-presets.patch'
        )
    }
    elseif ((Test-Contains 'src/opengl/gl_d3d12raylight.cpp' 'gRaygenMode') -and (Test-Contains 'src/renderer/tr_init.cpp' 'r_dxrDispatchMode')) {
        Write-Host 'Existing Dispatch Guard stack detected; applying patches 08-11.'
        $patches = @(
            'patches/08-dxr-halfres-performance-cache.patch',
            'patches/09-dxr-tdr-safe-runtime-freeze.patch',
            'patches/10-dxr-playable-detail-composite-defaults.patch',
            'patches/11-dxr-final-hq-smooth-safe-presets.patch'
        )
    }
    elseif ((Test-Contains 'src/opengl/gl_d3d12raylight.cpp' 'glRaytracingSetSafetyOptions') -and (Test-Contains 'src/renderer/tr_init.cpp' 'r_dxrSafeMode')) {
        Write-Host 'Existing Safe Mode stack detected; applying patches 07-11.'
        $patches = @(
            'patches/07-dxr-dispatch-raygen-guard.patch',
            'patches/08-dxr-halfres-performance-cache.patch',
            'patches/09-dxr-tdr-safe-runtime-freeze.patch',
            'patches/10-dxr-playable-detail-composite-defaults.patch',
            'patches/11-dxr-final-hq-smooth-safe-presets.patch'
        )
    }
    else {
        Write-Host 'Base tree detected; applying full DXR final high-quality stack 00-11.'
        $patches = @(
            'patches/00-build-fix-Com_Printf.patch',
            'patches/02-dxr-stable-mode.patch',
            'patches/03-pvs-decompressvis-x64.patch',
            'patches/04-dxr-visibility-debug.patch',
            'patches/05-dxr-sun-dynamic-performance.patch',
            'patches/06-dxr-device-removed-safe-mode.patch',
            'patches/07-dxr-dispatch-raygen-guard.patch',
            'patches/08-dxr-halfres-performance-cache.patch',
            'patches/09-dxr-tdr-safe-runtime-freeze.patch',
            'patches/10-dxr-playable-detail-composite-defaults.patch',
            'patches/11-dxr-final-hq-smooth-safe-presets.patch'
        )
    }

    foreach ($p in $patches) { Apply-Maybe $p }
    Write-Host 'DXR Final HighQuality Stable stack is ready.'
}
finally {
    Pop-Location
}
