$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$patches = @(
  "patches/00-build-fix-Com_Printf.patch",
  "patches/02-dxr-stable-mode.patch",
  "patches/03-pvs-decompressvis-x64.patch",
  "patches/04-dxr-visibility-debug.patch",
  "patches/05-dxr-sun-dynamic-performance.patch"
)

foreach ($patch in $patches) {
  Write-Host "Checking $patch"
  git apply --check $patch
  Write-Host "Applying $patch"
  git apply $patch
}

Write-Host "All DXR sun/dynamic/performance patches applied."
