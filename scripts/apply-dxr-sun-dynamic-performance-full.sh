#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for p in \
  patches/00-build-fix-Com_Printf.patch \
  patches/02-dxr-stable-mode.patch \
  patches/03-pvs-decompressvis-x64.patch \
  patches/04-dxr-visibility-debug.patch \
  patches/05-dxr-sun-dynamic-performance.patch
do
  echo "Checking $p"
  git apply --check "$p"
  echo "Applying $p"
  git apply "$p"
done
echo "All DXR sun/dynamic/performance patches applied."
