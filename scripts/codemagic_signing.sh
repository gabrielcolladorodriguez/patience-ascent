#!/usr/bin/env bash
# Patience Ascent — Codemagic code signing (tested flow, no brittle JSON parsing)
set -euo pipefail

: "${CM_BUILD_DIR:?CM_BUILD_DIR is required}"
: "${BUNDLE_ID:=com.patienceascent.app}"
: "${BUNDLE_RESOURCE_ID:=DVG85PSU28}"
: "${XCODE_PROJECT:=SolitaireRoyale.xcodeproj}"
: "${CERTIFICATE_PRIVATE_KEY:?CERTIFICATE_PRIVATE_KEY is required}"

keychain initialize

CERT_KEY_PATH="$CM_BUILD_DIR/cert_key.pem"
printf '%s\n' "$CERTIFICATE_PRIVATE_KEY" > "$CERT_KEY_PATH"
openssl rsa -in "$CERT_KEY_PATH" -check -noout

echo "==> Enable Game Center on App ID $BUNDLE_RESOURCE_ID"
if ! app-store-connect bundle-ids enable-capabilities "$BUNDLE_RESOURCE_ID" --capability "Game Center"; then
  echo "Game Center capability already enabled (or enable skipped)"
fi

echo "==> Fetch/create App Store signing files for $BUNDLE_ID"
app-store-connect fetch-signing-files "$BUNDLE_ID" \
  --type IOS_APP_STORE \
  --platform IOS \
  --create \
  --certificate-key=@file:"$CERT_KEY_PATH"

keychain add-certificates
xcode-project use-profiles --project "$CM_BUILD_DIR/$XCODE_PROJECT"
security find-identity -v -p codesigning

echo "==> Code signing setup complete"
