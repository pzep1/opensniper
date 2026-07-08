#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This packaging script must run on macOS."
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-Release}"
case "$CONFIGURATION" in
  release) CONFIGURATION="Release" ;;
  debug) CONFIGURATION="Debug" ;;
esac
APP_NAME="OpenSniper"
APP_DIR="$ROOT_DIR/dist/$APP_NAME.app"
DERIVED_DATA_DIR="${DERIVED_DATA_DIR:-$ROOT_DIR/.build/xcode-macos-app}"
PRODUCT_APP="$DERIVED_DATA_DIR/Build/Products/$CONFIGURATION/$APP_NAME.app"

cd "$ROOT_DIR"

xcodebuild build \
  -quiet \
  -project "$ROOT_DIR/OpenSniper.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_DIR"

if [[ ! -d "$PRODUCT_APP" ]]; then
  echo "Expected Xcode product was not created: $PRODUCT_APP"
  exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$ROOT_DIR/dist"
ditto "$PRODUCT_APP" "$APP_DIR"
codesign --verify --deep --strict "$APP_DIR"

echo "$APP_DIR"
