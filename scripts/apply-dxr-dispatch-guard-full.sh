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

if contains src/opengl/gl_d3d12raylight.cpp "gRaygenMode" && contains src/renderer/tr_init.cpp "r_dxrDispatchMode"; then
  echo "DXR Dispatch Guard already detected; nothing to apply."
  exit 0
fi

if contains src/opengl/gl_d3d12raylight.cpp "glRaytracingSetSafetyOptions" && contains src/renderer/tr_init.cpp "r_dxrSafeMode" && contains src/opengl/gl_d3d12raylight.cpp "r_dxrNoDispatch is 1"; then
  echo "Existing DXR Safe Mode stack detected; applying only patch 07."
  patches=(patches/07-dxr-dispatch-raygen-guard.patch)
else
  echo "Base tree detected; applying full DXR stack 00-07."
  patches=(
    patches/00-build-fix-Com_Printf.patch
    patches/02-dxr-stable-mode.patch
    patches/03-pvs-decompressvis-x64.patch
    patches/04-dxr-visibility-debug.patch
    patches/05-dxr-sun-dynamic-performance.patch
    patches/06-dxr-device-removed-safe-mode.patch
    patches/07-dxr-dispatch-raygen-guard.patch
  )
fi

for p in "${patches[@]}"; do
  apply_maybe "$p"
done

echo "DXR DispatchRays Isolation / Raygen Guard stack is ready."
