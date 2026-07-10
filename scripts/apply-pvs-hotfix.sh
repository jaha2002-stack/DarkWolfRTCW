#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PATCH_PATH="$REPO_ROOT/patches/03-pvs-decompressvis-x64.patch"

if [ ! -f "$PATCH_PATH" ]; then
  echo "Patch file not found: $PATCH_PATH" >&2
  exit 1
fi

cd "$REPO_ROOT"

if git apply --check "$PATCH_PATH"; then
  git apply --whitespace=nowarn "$PATCH_PATH"
  echo "Applied patch: $PATCH_PATH"
  exit 0
fi

if git apply --reverse --check "$PATCH_PATH"; then
  echo "Patch already appears to be applied: $PATCH_PATH"
  exit 0
fi

echo "Patch cannot be applied cleanly: $PATCH_PATH" >&2
exit 1
