#!/usr/bin/env bash
# Build a signed Android App Bundle (.aab) for Google Play upload.
#
# Prerequisites:
#   1. Create a keystore:
#      keytool -genkey -v -keystore ~/qalbcare-upload-key.jks \
#        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
#
#   2. Create android/key.properties (see key.properties.example):
#      storePassword=<password>
#      keyPassword=<password>
#      keyAlias=upload
#      storeFile=/path/to/qalbcare-upload-key.jks
#
# Usage:
#   ./scripts/build_aab.sh

set -euo pipefail

cd "$(dirname "$0")/.."

KEY_PROPS="android/key.properties"
if [ ! -f "$KEY_PROPS" ]; then
  echo "ERROR: $KEY_PROPS not found."
  echo "Copy android/key.properties.example and fill in your values."
  exit 1
fi

echo "Cleaning previous build..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Building release App Bundle..."
flutter build appbundle --release

AAB="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB" ]; then
  echo ""
  echo "Build successful!"
  echo "AAB location: $AAB"
  echo ""
  echo "Upload this file to Google Play Console:"
  echo "  https://play.google.com/console"
else
  echo "ERROR: AAB not found at expected path."
  exit 1
fi
