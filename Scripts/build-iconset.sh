#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
SOURCE="${1:-$ROOT/Resources/IconDesign/Brio-Ink-1024.png}"
ICONSET="$ROOT/.build/AppIcon.iconset"
ICNS="$ROOT/Resources/AppIcon.icns"

if [[ ! -f "$SOURCE" ]]; then
    print -u2 "error: icon source not found at $SOURCE"
    exit 1
fi

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$SOURCE" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    sips -z "$((size * 2))" "$((size * 2))" "$SOURCE" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o "$ICNS"
print -r -- "$ICNS"
