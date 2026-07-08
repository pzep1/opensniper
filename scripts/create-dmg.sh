#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This packaging script must run on macOS."
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="OpenSniper"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/Resources/Info.plist")"
APP_DIR="$ROOT_DIR/dist/$APP_NAME.app"
DMG_ROOT="$ROOT_DIR/dist/dmg-root"
DMG_PATH="$ROOT_DIR/dist/$APP_NAME-$VERSION-macOS.dmg"
CHECKSUM_PATH="$DMG_PATH.sha256"

"$ROOT_DIR/scripts/build-macos-app.sh" >/dev/null

rm -rf "$DMG_ROOT" "$DMG_PATH" "$CHECKSUM_PATH"
mkdir -p "$DMG_ROOT"

cp -R "$APP_DIR" "$DMG_ROOT/$APP_NAME.app"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_ROOT" \
  -format UDZO \
  -ov \
  "$DMG_PATH" >/dev/null

rm -rf "$DMG_ROOT"

hdiutil verify "$DMG_PATH" >/dev/null

shasum -a 256 "$DMG_PATH" > "$CHECKSUM_PATH"

echo "$DMG_PATH"
echo "$CHECKSUM_PATH"
