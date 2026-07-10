#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
if git apply --check patches/04-dxr-visibility-debug.patch; then
  git apply --whitespace=nowarn patches/04-dxr-visibility-debug.patch
  echo "Applied DXR visibility/debug patch."
  exit 0
fi
if git apply --reverse --check patches/04-dxr-visibility-debug.patch; then
  echo "Patch already appears to be applied."
  exit 0
fi
echo "Patch cannot be applied cleanly." >&2
exit 1
