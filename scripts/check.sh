#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash -n scripts/*.sh

if command -v xmllint >/dev/null 2>&1; then
  xmllint --noout Resources/Info.plist
elif command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY'
import plistlib

with open("Resources/Info.plist", "rb") as plist_file:
    plistlib.load(plist_file)
PY
else
  echo "Skipping plist validation: neither xmllint nor python3 is installed."
fi

if command -v swift >/dev/null 2>&1; then
  swift test
else
  echo "Skipping Swift tests: swift is not installed."
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  scripts/build-macos-app.sh
else
  echo "Skipping macOS app packaging: host is not macOS."
fi
