#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
cd "$ROOT"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist)
APP_DIR="$ROOT/.build/Brio.app"
DIST_DIR="$ROOT/dist"
STAGE_DIR="$ROOT/.build/dmg"
DMG_PATH="$DIST_DIR/Brio-$VERSION.dmg"
SIGNING_IDENTITY="${BRIO_CODESIGN_IDENTITY:--}"

BRIO_CONFIGURATION=release BRIO_CODESIGN_IDENTITY="$SIGNING_IDENTITY" zsh "$ROOT/Scripts/build-app.sh"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR" "$DIST_DIR"
ditto "$APP_DIR" "$STAGE_DIR/Brio.app"
ln -s /Applications "$STAGE_DIR/Applications"

rm -f "$DMG_PATH" "$DMG_PATH.sha256"
hdiutil create -volname "Brio $VERSION" -srcfolder "$STAGE_DIR" -ov -format UDZO "$DMG_PATH"
shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"
print -r -- "$DMG_PATH"
