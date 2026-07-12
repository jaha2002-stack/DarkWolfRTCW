#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
git apply --check patches/09-build-skip-radiant-mfc.patch
git apply patches/09-build-skip-radiant-mfc.patch
echo "Applied 09-build-skip-radiant-mfc.patch"
