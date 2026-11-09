#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
BUILD_DIR="$ROOT/.build"
APP_DIR="$BUILD_DIR/Brio.app"
CONFIGURATION="${BRIO_CONFIGURATION:-debug}"
SWIFT="$ROOT/Scripts/swift"

cd "$ROOT"
"$SWIFT" build -c "$CONFIGURATION" --disable-sandbox \
    --scratch-path "$BUILD_DIR" \
    --cache-path "$BUILD_DIR/swiftpm/cache" \
    --config-path "$BUILD_DIR/swiftpm/config" \
    --security-path "$BUILD_DIR/swiftpm/security"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
cp "$BUILD_DIR/$CONFIGURATION/Brio" "$APP_DIR/Contents/MacOS/Brio"
cp "$ROOT/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
SIGNING_IDENTITY="${BRIO_CODESIGN_IDENTITY:-Brio Development}"
codesign --force --sign "$SIGNING_IDENTITY" "$APP_DIR"
print -r -- "$APP_DIR"
