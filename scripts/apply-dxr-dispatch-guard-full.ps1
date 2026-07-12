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

$hasDispatchGuard =
    (Test-FileContains "src/opengl/gl_d3d12raylight.cpp" "gRaygenMode") -and
    (Test-FileContains "src/renderer/tr_init.cpp" "r_dxrDispatchMode")

if ($hasDispatchGuard) {
    Write-Host "DXR Dispatch Guard already detected; nothing to apply."
    exit 0
}

$hasSafeMode =
    (Test-FileContains "src/opengl/gl_d3d12raylight.cpp" "glRaytracingSetSafetyOptions") -and
    (Test-FileContains "src/renderer/tr_init.cpp" "r_dxrSafeMode") -and
    (Test-FileContains "src/opengl/gl_d3d12raylight.cpp" "r_dxrNoDispatch is 1")

if ($hasSafeMode) {
    Write-Host "Existing DXR Safe Mode stack detected; applying only patch 07."
    $patches = @("patches/07-dxr-dispatch-raygen-guard.patch")
}
else {
    Write-Host "Base tree detected; applying full DXR stack 00-07."
    $patches = @(
      "patches/00-build-fix-Com_Printf.patch",
      "patches/02-dxr-stable-mode.patch",
      "patches/03-pvs-decompressvis-x64.patch",
      "patches/04-dxr-visibility-debug.patch",
      "patches/05-dxr-sun-dynamic-performance.patch",
      "patches/06-dxr-device-removed-safe-mode.patch",
      "patches/07-dxr-dispatch-raygen-guard.patch"
    )
}

foreach ($patch in $patches) {
    Invoke-GitApplyMaybe $patch
}

Write-Host "DXR DispatchRays Isolation / Raygen Guard stack is ready."
