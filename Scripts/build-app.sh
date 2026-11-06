#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
BUILD_DIR="$ROOT/.build"
APP_DIR="$BUILD_DIR/Brio.app"

cd "$ROOT"
swift build
mkdir -p "$APP_DIR/Contents/MacOS"
cp "$BUILD_DIR/debug/Brio" "$APP_DIR/Contents/MacOS/Brio"
cp "$ROOT/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
SIGNING_IDENTITY="${BRIO_CODESIGN_IDENTITY:-Brio Development}"
codesign --force --deep --sign "$SIGNING_IDENTITY" "$APP_DIR"
print -r -- "$APP_DIR"
