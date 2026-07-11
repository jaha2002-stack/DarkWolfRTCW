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

  echo "Patch does not apply cleanly and is not already applied: $patch" >&2
  git apply --check "$patch"
  return 1
}

if contains src/renderer/tr_init.cpp r_dxrSunEnable \
   && contains src/opengl/gl_d3d12raylight.cpp maxActiveLights \
   && contains src/opengl/gl_d3d12raylight.cpp sunShadowStrength; then
  echo "Existing Sun/Dynamic/Performance stack detected; applying only patch 06."
  patches=(patches/06-dxr-device-removed-safe-mode.patch)
else
  echo "Base tree detected; applying full stack 00-06."
  patches=(
    patches/00-build-fix-Com_Printf.patch
    patches/02-dxr-stable-mode.patch
    patches/03-pvs-decompressvis-x64.patch
    patches/04-dxr-visibility-debug.patch
    patches/05-dxr-sun-dynamic-performance.patch
    patches/06-dxr-device-removed-safe-mode.patch
  )
fi

for p in "${patches[@]}"; do
  apply_maybe "$p"
done

echo "DXR Safe Mode / Device Removed hotfix stack is ready."
