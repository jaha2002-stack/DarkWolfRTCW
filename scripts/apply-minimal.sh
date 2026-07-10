#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
git apply --check patches/01-dxr-minimal-visibility.patch
git apply --whitespace=nowarn patches/01-dxr-minimal-visibility.patch
echo "Applied minimal DXR patch."
