#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

contains() {
  local file="$1"
  local needle="$2"
  [[ -f "$file" ]] && grep -Fq "$needle" "$file"
}

apply_maybe() {
  local patch="$1"
  echo "Checking $patch"
  if git apply --check "$patch" >/dev/null 2>&1; then
    echo "Applying $patch"
    git apply "$patch"
    return 0
  fi
  if git apply --reverse --check "$patch" >/dev/null 2>&1; then
    echo "Already applied: $patch"
    return 0
  fi
  echo "Patch does not apply cleanly and is not already applied: $patch"
  git apply --check "$patch"
  exit 1
}

if contains src/opengl/gl_d3d12raylight.cpp "DXR TRUE RT M1" && contains src/opengl/gl_d3d12raylight.cpp "ComputeTrueRTReflectionGI"; then
  echo "DXR TrueRT Rewrite M1 patch already detected; nothing to apply."
  exit 0
fi

if contains src/opengl/gl_d3d12raylight.cpp "DXR FINAL HQ SMOOTH" && contains src/renderer/tr_init.cpp 'r_dxrDispatchWidth", "160"'; then
  echo "Existing Final HighQuality stack detected; applying only patch 12."
  patches=(patches/12-dxr-truert-reflection-gi-visible-composite.patch)
elif contains src/opengl/gl_d3d12raylight.cpp "Playable TDR-safe composite" && contains src/renderer/tr_init.cpp 'r_dxrLegacyBlend", "0.90"'; then
  echo "Existing Playable TDR-safe stack detected; applying patches 11-12."
  patches=(
    patches/11-dxr-final-hq-smooth-safe-presets.patch
    patches/12-dxr-truert-reflection-gi-visible-composite.patch
  )
elif contains src/opengl/gl_d3d12raylight.cpp "DXR TDRSAFE" && contains src/renderer/tr_init.cpp "r_dxrFreezeScene"; then
  echo "Existing TDR-safe runtime stack detected; applying patches 10-12."
  patches=(
    patches/10-dxr-playable-detail-composite-defaults.patch
    patches/11-dxr-final-hq-smooth-safe-presets.patch
    patches/12-dxr-truert-reflection-gi-visible-composite.patch
  )
elif contains src/opengl/gl_d3d12raylight.cpp "DXR HALFRES" && contains src/renderer/tr_init.cpp "r_dxrRenderScale"; then
  echo "Existing HalfRes stack detected; applying patches 09-12."
  patches=(
    patches/09-dxr-tdr-safe-runtime-freeze.patch
    patches/10-dxr-playable-detail-composite-defaults.patch
    patches/11-dxr-final-hq-smooth-safe-presets.patch
    patches/12-dxr-truert-reflection-gi-visible-composite.patch
  )
elif contains src/opengl/gl_d3d12raylight.cpp "gRaygenMode" && contains src/renderer/tr_init.cpp "r_dxrDispatchMode"; then
  echo "Existing Dispatch Guard stack detected; applying patches 08-12."
  patches=(
    patches/08-dxr-halfres-performance-cache.patch
    patches/09-dxr-tdr-safe-runtime-freeze.patch
    patches/10-dxr-playable-detail-composite-defaults.patch
    patches/11-dxr-final-hq-smooth-safe-presets.patch
    patches/12-dxr-truert-reflection-gi-visible-composite.patch
  )
elif contains src/opengl/gl_d3d12raylight.cpp "glRaytracingSetSafetyOptions" && contains src/renderer/tr_init.cpp "r_dxrSafeMode"; then
  echo "Existing Safe Mode stack detected; applying patches 07-12."
  patches=(
    patches/07-dxr-dispatch-raygen-guard.patch
    patches/08-dxr-halfres-performance-cache.patch
    patches/09-dxr-tdr-safe-runtime-freeze.patch
    patches/10-dxr-playable-detail-composite-defaults.patch
    patches/11-dxr-final-hq-smooth-safe-presets.patch
    patches/12-dxr-truert-reflection-gi-visible-composite.patch
  )
else
  echo "Base tree detected; applying full DXR TrueRT Rewrite M1 stack 00-12."
  patches=(
    patches/00-build-fix-Com_Printf.patch
    patches/02-dxr-stable-mode.patch
    patches/03-pvs-decompressvis-x64.patch
    patches/04-dxr-visibility-debug.patch
    patches/05-dxr-sun-dynamic-performance.patch
    patches/06-dxr-device-removed-safe-mode.patch
    patches/07-dxr-dispatch-raygen-guard.patch
    patches/08-dxr-halfres-performance-cache.patch
    patches/09-dxr-tdr-safe-runtime-freeze.patch
    patches/10-dxr-playable-detail-composite-defaults.patch
    patches/11-dxr-final-hq-smooth-safe-presets.patch
    patches/12-dxr-truert-reflection-gi-visible-composite.patch
  )
fi

for p in "${patches[@]}"; do
  apply_maybe "$p"
done

echo "DXR TrueRT Rewrite M1 stack is ready."
