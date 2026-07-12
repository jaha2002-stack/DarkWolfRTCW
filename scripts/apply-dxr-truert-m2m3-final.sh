#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"
contains() { [[ -f "$1" ]] && grep -Fq "$2" "$1"; }
apply_maybe() {
  local p="$1"
  echo "Checking $p"
  if git apply --check "$p" 2>/dev/null; then
    echo "Applying $p"
    git apply "$p"
  elif git apply --reverse --check "$p" 2>/dev/null; then
    echo "Already applied: $p"
  else
    echo "Patch does not apply cleanly and is not already applied: $p" >&2
    exit 1
  fi
}
if contains src/opengl/gl_d3d12raylight.cpp "DXR TrueRT M2/M3 Visual Restore" && contains src/opengl/gl_d3d12raylight.cpp "TraceRadianceMaterial"; then
  echo "DXR TrueRT M2/M3 patch already detected; nothing to apply."
  exit 0
fi
if contains src/opengl/gl_d3d12raylight.cpp "DXR TRUE RT M1" && contains src/opengl/gl_d3d12raylight.cpp "ComputeTrueRTReflectionGI"; then
  patches=(patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "DXR FINAL HQ SMOOTH" && contains src/renderer/tr_init.cpp "r_dxrDispatchWidth\", \"160"; then
  patches=(patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "Playable TDR-safe composite" && contains src/renderer/tr_init.cpp "r_dxrLegacyBlend\", \"0.90"; then
  patches=(patches/11-dxr-final-hq-smooth-safe-presets.patch patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "DXR TDRSAFE" && contains src/renderer/tr_init.cpp "r_dxrFreezeScene"; then
  patches=(patches/10-dxr-playable-detail-composite-defaults.patch patches/11-dxr-final-hq-smooth-safe-presets.patch patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "DXR HALFRES" && contains src/renderer/tr_init.cpp "r_dxrRenderScale"; then
  patches=(patches/09-dxr-tdr-safe-runtime-freeze.patch patches/10-dxr-playable-detail-composite-defaults.patch patches/11-dxr-final-hq-smooth-safe-presets.patch patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "gRaygenMode" && contains src/renderer/tr_init.cpp "r_dxrDispatchMode"; then
  patches=(patches/08-dxr-halfres-performance-cache.patch patches/09-dxr-tdr-safe-runtime-freeze.patch patches/10-dxr-playable-detail-composite-defaults.patch patches/11-dxr-final-hq-smooth-safe-presets.patch patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "glRaytracingSetSafetyOptions" && contains src/renderer/tr_init.cpp "r_dxrSafeMode"; then
  patches=(patches/07-dxr-dispatch-raygen-guard.patch patches/08-dxr-halfres-performance-cache.patch patches/09-dxr-tdr-safe-runtime-freeze.patch patches/10-dxr-playable-detail-composite-defaults.patch patches/11-dxr-final-hq-smooth-safe-presets.patch patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
else
  patches=(patches/00-build-fix-Com_Printf.patch patches/02-dxr-stable-mode.patch patches/03-pvs-decompressvis-x64.patch patches/04-dxr-visibility-debug.patch patches/05-dxr-sun-dynamic-performance.patch patches/06-dxr-device-removed-safe-mode.patch patches/07-dxr-dispatch-raygen-guard.patch patches/08-dxr-halfres-performance-cache.patch patches/09-dxr-tdr-safe-runtime-freeze.patch patches/10-dxr-playable-detail-composite-defaults.patch patches/11-dxr-final-hq-smooth-safe-presets.patch patches/12-dxr-truert-reflection-gi-visible-composite.patch patches/13-dxr-truert-m2m3-material-temporal-visual-restore.patch)
fi
for p in "${patches[@]}"; do apply_maybe "$p"; done
echo "DXR TrueRT M2/M3 Final Visual Restore stack is ready."
