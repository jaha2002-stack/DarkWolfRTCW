#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
git apply --check patches/02-dxr-stable-mode.patch
git apply --whitespace=nowarn patches/02-dxr-stable-mode.patch
echo "Applied stable DXR patch."
