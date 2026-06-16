#!/usr/bin/env zsh
set -euo pipefail

BUILD_NAME=${1:-"1.0.0"}
BUILD_NUMBER=${2:-"1"}

TEAM_ID="LP84QVHHSV"
SIGN_IDENTITY="Developer ID Application: Abak Metrics (LP84QVHHSV)"
KEYCHAIN_PROFILE="ABAK_Notary"

DATE=$(date +%F)

APP_NAME="abak_desktop_companion"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"

ZIP_UNSIGNED="build/${APP_NAME}_${BUILD_NAME}_unsigned.zip"
ZIP_FINAL="build/${APP_NAME}_${BUILD_NAME}_macOS.zip"

DEBUG_INFO_DIR="build/debug-info/macos/${DATE}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 ABAK Desktop Companion"
echo "🆕 Version : ${BUILD_NAME} (${BUILD_NUMBER})"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "${DEBUG_INFO_DIR}"

echo ""
echo "🔨 Build Flutter"

flutter clean
flutter pub get

flutter build macos --release \
  --obfuscate \
  --split-debug-info="${DEBUG_INFO_DIR}" \
  --tree-shake-icons \
  --build-name="${BUILD_NAME}" \
  --build-number="${BUILD_NUMBER}" \
  --dart-define=ENV=production

echo ""
echo "✍️ Signature"

codesign \
  --force \
  --deep \
  --options runtime \
  --sign "${SIGN_IDENTITY}" \
  "${APP_PATH}"

echo ""
echo "✅ Vérification signature"

codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  "${APP_PATH}"

echo ""
echo "📦 Création ZIP"

rm -f "${ZIP_UNSIGNED}"

ditto \
  -c \
  -k \
  --keepParent \
  "${APP_PATH}" \
  "${ZIP_UNSIGNED}"

echo ""
echo "☁️ Soumission à Apple"

xcrun notarytool submit \
  "${ZIP_UNSIGNED}" \
  --keychain-profile "${KEYCHAIN_PROFILE}" \
  --wait

echo ""
echo "📎 Stapling"

xcrun stapler staple "${APP_PATH}"

echo ""
echo "📦 ZIP final"

rm -f "${ZIP_FINAL}"

ditto \
  -c \
  -k \
  --keepParent \
  "${APP_PATH}" \
  "${ZIP_FINAL}"

echo ""
echo "🎉 TERMINÉ"
echo ""
echo "Application :"
echo "${APP_PATH}"
echo ""
echo "ZIP à distribuer :"
echo "${ZIP_FINAL}"