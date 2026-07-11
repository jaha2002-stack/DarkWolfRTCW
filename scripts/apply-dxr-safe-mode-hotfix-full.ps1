$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

function Test-FileContains {
    param([string]$Path, [string]$Needle)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $content = Get-Content -LiteralPath $Path -Raw
    return $content.Contains($Needle)
}

function Invoke-GitApplyMaybe {
    param([string]$Patch)

    Write-Host "Checking $Patch"
    & git apply --check $Patch *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Applying $Patch"
        & git apply $Patch
        if ($LASTEXITCODE -ne 0) { throw "git apply failed for $Patch" }
        return
    }

    & git apply --reverse --check $Patch *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Already applied: $Patch"
        return
    }

    Write-Host "Patch does not apply cleanly and is not already applied: $Patch"
    & git apply --check $Patch
    throw "Cannot apply $Patch"
}

$hasSunPerformanceStack =
    (Test-FileContains "src/renderer/tr_init.cpp" "r_dxrSunEnable") -and
    (Test-FileContains "src/opengl/gl_d3d12raylight.cpp" "maxActiveLights") -and
    (Test-FileContains "src/opengl/gl_d3d12raylight.cpp" "sunShadowStrength")

if ($hasSunPerformanceStack) {
    Write-Host "Existing Sun/Dynamic/Performance stack detected; applying only patch 06."
    $patches = @("patches/06-dxr-device-removed-safe-mode.patch")
}
else {
    Write-Host "Base tree detected; applying full stack 00-06."
    $patches = @(
      "patches/00-build-fix-Com_Printf.patch",
      "patches/02-dxr-stable-mode.patch",
      "patches/03-pvs-decompressvis-x64.patch",
      "patches/04-dxr-visibility-debug.patch",
      "patches/05-dxr-sun-dynamic-performance.patch",
      "patches/06-dxr-device-removed-safe-mode.patch"
    )
}

foreach ($patch in $patches) {
    Invoke-GitApplyMaybe $patch
}

Write-Host "DXR Safe Mode / Device Removed hotfix stack is ready."
