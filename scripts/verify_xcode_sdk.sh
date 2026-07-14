#!/usr/bin/env bash
# Apple requires iOS 26+ SDK (Xcode 26+) since 2026-04-28 for App Store uploads.
set -euo pipefail

MIN_SDK_MAJOR=26

xcodebuild -version
SDK_VER="$(xcrun --sdk iphoneos --show-sdk-version)"
SDK_MAJOR="${SDK_VER%%.*}"

echo "iphoneos SDK: $SDK_VER (need >= ${MIN_SDK_MAJOR}.0)"

if [ "$SDK_MAJOR" -lt "$MIN_SDK_MAJOR" ]; then
  echo "ERROR: App Store requires Xcode ${MIN_SDK_MAJOR}+. Update codemagic.yaml: xcode: 26.6"
  exit 1
fi

echo "SDK requirement OK"
