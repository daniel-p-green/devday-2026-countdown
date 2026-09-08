#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
output="${1:-$PWD/Exports}"
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
xcodebuild -project DevDay2026.xcodeproj -scheme DevDayMac -configuration Debug -derivedDataPath "$build/build" CODE_SIGNING_ALLOWED=NO build > "$build/build.log" 2>&1 || { cat "$build/build.log"; exit 1; }
cp -R "$build/build/Build/Products/Debug/DevDayMac.app" "$build/Render.app"
swiftc -parse-as-library Shared/Countdown.swift Shared/CalendarFace.swift Scripts/RenderCards.swift -o "$build/Render.app/Contents/MacOS/DevDayMac"
"$build/Render.app/Contents/MacOS/DevDayMac" "$output"
