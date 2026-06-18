#!/usr/bin/env bash
#
# Build an installable (unsigned) IPA for QalbCare so it can be sideloaded onto
# an iPhone WITHOUT the App Store (e.g. via AltStore or Sideloadly, which re-sign
# it with your own Apple ID).
#
# REQUIREMENTS: run this on macOS with Xcode + Flutter installed. iOS binaries
# cannot be built on Linux/Windows.
#
# Usage:
#   ./scripts/build_ipa.sh
#
set -euo pipefail

# Move to the repo root regardless of where the script is called from.
cd "$(dirname "$0")/.."

APP_NAME="QalbCare"
OUT_DIR="build/ipa"

echo "==> flutter pub get"
flutter pub get

echo "==> Installing CocoaPods dependencies"
( cd ios && pod install )

echo "==> Building unsigned iOS release (this can take a few minutes)"
flutter build ios --release --no-codesign

APP_PATH="build/ios/iphoneos/Runner.app"
if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: $APP_PATH was not produced. The build likely failed above." >&2
  exit 1
fi

echo "==> Packaging $APP_NAME.ipa"
rm -rf "$OUT_DIR/Payload" "$OUT_DIR/$APP_NAME.ipa"
mkdir -p "$OUT_DIR/Payload"
cp -R "$APP_PATH" "$OUT_DIR/Payload/"
( cd "$OUT_DIR" && zip -qr "$APP_NAME.ipa" Payload && rm -rf Payload )

echo ""
echo "================================================================"
echo " Done:  $OUT_DIR/$APP_NAME.ipa"
echo ""
echo " Install it on your iPhone with one of:"
echo "   - Sideloadly  (https://sideloadly.io)"
echo "   - AltStore    (https://altstore.io)"
echo " Both sign the app with your Apple ID and push it to the phone."
echo " A free Apple ID works but the app expires after 7 days and must"
echo " be re-installed; a paid Developer account lasts a year."
echo "================================================================"
