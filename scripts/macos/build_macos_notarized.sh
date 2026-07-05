# Ceci est le script à utiliser pour créer la version macOs de Companion
# Modifier le numéro de la VERSION BUILD_NAME et le numéro de la release BUILD_Number
#!/usr/bin/env zsh
set -euo pipefail

BUILD_NAME=${1:-"1.0.0"}
BUILD_NUMBER=${2:-"1"}

CONFIG_FILE="build_macos.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "❌ Fichier de configuration manquant : ${CONFIG_FILE}"
  echo "Crée ce fichier à la racine du projet avec TEAM_ID, SIGN_IDENTITY et KEYCHAIN_PROFILE."
  exit 1
fi

source "${CONFIG_FILE}"

DATE=$(date +%F)

APP_NAME="abak_desktop_companion"
APP_ARTIFACT_NAME="ABAK_Desktop_Companion"

APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"

ZIP_UNSIGNED="build/${APP_ARTIFACT_NAME}_${BUILD_NAME}_macOS_unsigned.zip"
ZIP_FINAL="build/${APP_ARTIFACT_NAME}_${BUILD_NAME}_macOS.zip"

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