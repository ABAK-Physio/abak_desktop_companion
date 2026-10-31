#!/usr/bin/env zsh
# Ceci est le script à utiliser pour créer la version macOs de Companion
# Modifier le numéro de la VERSION BUILD_NAME et le numéro de la release BUILD_Number
set -euo pipefail

# Acquire before preparation; nested scripts inherit the same kernel lock.
if ! /usr/bin/python3 "${0:A:h}/macos_build_lock.py" --held; then
  exec /usr/bin/python3 "${0:A:h}/macos_build_lock.py" /bin/zsh "$0" "$@"
fi

# Se placer à la racine du projet.
SCRIPT_DIR="${0:A:h}"
cd "${SCRIPT_DIR}/../.."

# Accepter soit aucun argument, soit VERSION et BUILD.
if (( $# != 0 && $# != 2 )); then
  echo "Usage : $0 [VERSION BUILD]"
  exit 1
fi

if (( $# == 2 )); then
  BUILD_NAME="$1"
  BUILD_NUMBER="$2"
else
  PACKAGE_VERSION=$(sed -nE \
    's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+)[[:space:]]*$/\1/p' \
    pubspec.yaml)

  BUILD_NAME="${PACKAGE_VERSION%+*}"
  BUILD_NUMBER="${PACKAGE_VERSION##*+}"
fi

# Refuser une version absente ou incorrecte.
if ! [[ "$BUILD_NAME" =~ '^[0-9]+\.[0-9]+\.[0-9]+$' ]] || \
   ! [[ "$BUILD_NUMBER" =~ '^[1-9][0-9]*$' ]]; then
  echo "❌ Version invalide : VERSION doit être x.y.z et BUILD un entier positif."
  exit 1
fi

CONFIG_FILE="build_macos.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "❌ Fichier de configuration manquant : ${CONFIG_FILE}"
  echo "Crée ce fichier à la racine du projet avec :"
  echo "  TEAM_ID"
  echo "  SIGN_IDENTITY"
  echo "  INSTALLER_SIGN_IDENTITY"
  echo "  KEYCHAIN_PROFILE"
  exit 1
fi

source "${CONFIG_FILE}"

# Vérifier la configuration avant de commencer.
: "${TEAM_ID:?TEAM_ID absent ou vide dans build_macos.env}"
: "${SIGN_IDENTITY:?SIGN_IDENTITY absent ou vide dans build_macos.env}"
: "${INSTALLER_SIGN_IDENTITY:?INSTALLER_SIGN_IDENTITY absent ou vide dans build_macos.env}"
: "${KEYCHAIN_PROFILE:?KEYCHAIN_PROFILE absent ou vide dans build_macos.env}"

if [[ "${SIGN_IDENTITY}" != "Developer ID Application: "* ]]; then
  echo "❌ SIGN_IDENTITY doit désigner un certificat Developer ID Application."
  exit 1
fi

if [[ "${INSTALLER_SIGN_IDENTITY}" != "Developer ID Installer: "* ]]; then
  echo "❌ INSTALLER_SIGN_IDENTITY doit désigner un certificat Developer ID Installer."
  exit 1
fi

# Every run owns a new directory. Never clean the working tree or old evidence.
ARTIFACT_DIR="$(pwd)/build/distributions/${BUILD_NAME}_${BUILD_NUMBER}_arm64_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$(dirname "$ARTIFACT_DIR")"
mkdir "$ARTIFACT_DIR"

APP_NAME="abak_desktop_companion"
APP_ARTIFACT_NAME="ABAK_Desktop_Companion"

APP_PATH="${ARTIFACT_DIR}/source/build/macos/Build/Products/Release/${APP_NAME}.app"
ENTITLEMENTS_PATH="macos/Runner/Release.entitlements"

# Configuration de l’installateur macOS.
PKG_COMPONENT_PLIST="scripts/macos/installer/component.plist"
PKG_IDENTIFIER="fr.abakphysio.abakdesktopcompanion.installer"
PKG_FINAL="${ARTIFACT_DIR}/${APP_ARTIFACT_NAME}_${BUILD_NAME}_${BUILD_NUMBER}_macOS_arm64.pkg"

# Vérifier la configuration avant toute compilation.
if [[ ! -f "${PKG_COMPONENT_PLIST}" ]]; then
  echo "❌ Configuration de l’installateur absente : ${PKG_COMPONENT_PLIST}"
  exit 1
fi

/usr/bin/plutil -lint "${PKG_COMPONENT_PLIST}"

# Vérifier les fichiers nécessaires à l’assistant d’installation.
for required_file in \
  "scripts/macos/installer/distribution.xml" \
  "scripts/macos/installer/resources/welcome.html" \
  "scripts/macos/installer/scripts/preinstall" \
  "scripts/macos/installer/desktop-shortcut-scripts/postinstall"; do
  if [[ ! -s "${required_file}" ]]; then
    echo "❌ Fichier absent ou vide : ${required_file}"
    exit 1
  fi
done

/usr/bin/xmllint --noout \
  "scripts/macos/installer/distribution.xml"

/bin/sh -n \
  "scripts/macos/installer/scripts/preinstall"

/bin/sh -n \
  "scripts/macos/installer/desktop-shortcut-scripts/postinstall"

ZIP_UNSIGNED="${ARTIFACT_DIR}/notarization-input.zip"
ZIP_FINAL="${ARTIFACT_DIR}/${APP_ARTIFACT_NAME}_${BUILD_NAME}_${BUILD_NUMBER}_macOS_arm64.zip"

DEBUG_INFO_DIR="${ARTIFACT_DIR}/debug-info"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 ABAK Desktop Companion"
echo "🆕 Version : ${BUILD_NAME} (${BUILD_NUMBER})"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "${DEBUG_INFO_DIR}"

echo ""
echo "🔨 Build Flutter"

# Isolated source copy; no installation, launch, source mutation or downloads.
/usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)(deny file-write* (subpath "/Applications") (regex #"/Users/[^/]+/Applications(/|$)") (regex #"/Users/[^/]+/Library/(Containers|Group Containers)(/|$)"))' \
  /usr/bin/python3 scripts/macos/prepare_distribution.py \
  --output "$ARTIFACT_DIR" --version "$BUILD_NAME" --build "$BUILD_NUMBER"

  # Vérifier la version de l’application avant signature.
  APP_INFO_PLIST="${APP_PATH}/Contents/Info.plist"

  ACTUAL_VERSION=$(/usr/libexec/PlistBuddy \
    -c "Print :CFBundleShortVersionString" \
    "${APP_INFO_PLIST}")

  ACTUAL_BUILD=$(/usr/libexec/PlistBuddy \
    -c "Print :CFBundleVersion" \
    "${APP_INFO_PLIST}")

  if [[ "${ACTUAL_VERSION}" != "${BUILD_NAME}" || \
        "${ACTUAL_BUILD}" != "${BUILD_NUMBER}" ]]; then
    echo "❌ La version de l’application ne correspond pas à la version demandée."
    echo "Attendu : ${BUILD_NAME} (${BUILD_NUMBER})"
    echo "Obtenu  : ${ACTUAL_VERSION} (${ACTUAL_BUILD})"
    exit 1
  fi

  echo "✅ Version vérifiée : ${ACTUAL_VERSION} (${ACTUAL_BUILD})"

echo ""
echo "✍️ Signature"
/usr/bin/python3 scripts/macos/sign_distribution_tools.py "$APP_PATH" "$SIGN_IDENTITY"

codesign \
  --force \
  --deep \
  --preserve-metadata=entitlements \
  --options runtime \
  --timestamp \
  --sign "${SIGN_IDENTITY}" \
  "${APP_PATH}"

# Signing changes Java bytes: renew the integrity manifest before sealing the app.
/usr/bin/python3 scripts/macos/sign_distribution_tools.py "$APP_PATH" --refresh

# Apply the release permissions to the main app only, not its frameworks.
codesign \
  --force \
  --options runtime \
  --timestamp \
  --entitlements "${ENTITLEMENTS_PATH}" \
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

# Stop before distribution if signing has lost required permissions.
SIGNED_ENTITLEMENTS=$(mktemp)
trap 'rm -f "${SIGNED_ENTITLEMENTS}"' EXIT
codesign --display --entitlements - --xml "${APP_PATH}" > "${SIGNED_ENTITLEMENTS}"
for entitlement in \
  com.apple.security.app-sandbox \
  com.apple.security.device.audio-input \
  com.apple.security.network.client \
  com.apple.security.network.server \
  com.apple.security.files.user-selected.read-write \
  com.apple.security.files.bookmarks.app-scope \
  com.apple.security.smartcard; do
  if [[ "$(/usr/libexec/PlistBuddy -c "Print :${entitlement}" "${SIGNED_ENTITLEMENTS}")" != "true" ]]; then
    echo "❌ Autorisation absente de la signature : ${entitlement}"
    exit 1
  fi
done

echo ""
echo "📦 Création ZIP"
# Exercise only bundled Java/veraPDF with synthetic fixtures, never Companion.
/usr/bin/python3 scripts/macos/verify_distribution.py "$APP_PATH" > "$ARTIFACT_DIR/tools-verification.json"

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
  --wait --output-format json > "${ARTIFACT_DIR}/app-notary.json"
/usr/bin/python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d); sys.exit(0 if d.get("status")=="Accepted" else 1)' "${ARTIFACT_DIR}/app-notary.json"

echo ""
echo "📎 Stapling"

xcrun stapler staple "${APP_PATH}"

echo ""
echo "📦 Création du PKG signé"

# Vérifier le ticket Apple de l’application.
xcrun stapler validate "${APP_PATH}"
spctl --assess --type execute --verbose=2 "$APP_PATH"
# The distributable ZIP contains the stapled app, unlike the submission ZIP.
ditto -c -k --keepParent "$APP_PATH" "$ZIP_FINAL"

# Préparer uniquement l’application destinée à /Applications.
# Le nettoyage est limité à ce dossier temporaire.

(
  PKG_STAGE=$(mktemp -d "${TMPDIR:-/tmp}/abak-pkg.XXXXXX")
  trap 'rm -rf "${PKG_STAGE}"' EXIT

  # Séparer l’application à installer des scripts d’installation.
  PKG_PAYLOAD="${PKG_STAGE}/payload"
  PKG_SCRIPTS="${PKG_STAGE}/scripts"

  mkdir -p "${PKG_PAYLOAD}/Applications" "${PKG_SCRIPTS}"

  ditto \
    "${APP_PATH}" \
    "${PKG_PAYLOAD}/Applications/${APP_NAME}.app"

  # Intégrer le contrôle préalable et le rendre exécutable.
  /usr/bin/install -m 755 \
    "scripts/macos/installer/scripts/preinstall" \
    "${PKG_SCRIPTS}/preinstall"

  /bin/sh -n "${PKG_SCRIPTS}/preinstall"

  codesign \
    --verify \
    --deep \
    --strict \
    --verbose=2 \
    "${PKG_PAYLOAD}/Applications/${APP_NAME}.app"

  # Créer le composant contenant l’application et son contrôle préalable.
  # Le numéro de build doit augmenter à chaque livraison.
  pkgbuild \
    --root "${PKG_PAYLOAD}" \
    --scripts "${PKG_SCRIPTS}" \
    --component-plist "${PKG_COMPONENT_PLIST}" \
    --identifier "${PKG_IDENTIFIER}" \
    --version "${BUILD_NUMBER}" \
    --install-location "/" \
    --ownership recommended \
    "${PKG_STAGE}/Companion-component.pkg"

  # Composant facultatif, sans copie supplémentaire de l’application.
  SHORTCUT_SCRIPTS="${PKG_STAGE}/desktop-shortcut-scripts"
  mkdir -p "${SHORTCUT_SCRIPTS}"
  /usr/bin/install -m 755 \
    "scripts/macos/installer/desktop-shortcut-scripts/postinstall" \
    "${SHORTCUT_SCRIPTS}/postinstall"

  pkgbuild \
    --nopayload \
    --scripts "${SHORTCUT_SCRIPTS}" \
    --identifier "fr.abakphysio.abakdesktopcompanion.desktop-shortcut" \
    --version "${BUILD_NUMBER}" \
    "${PKG_STAGE}/Companion-desktop-shortcut.pkg"

  # Assembler l’assistant avec son accueil et signer le PKG final.
  productbuild \
    --distribution "scripts/macos/installer/distribution.xml" \
    --resources "scripts/macos/installer/resources" \
    --package-path "${PKG_STAGE}" \
    --sign "${INSTALLER_SIGN_IDENTITY}" \
    --timestamp \
    "${PKG_FINAL}"
)

echo ""
echo "✅ Vérification de la signature du PKG"

pkgutil --check-signature "${PKG_FINAL}"

echo ""
echo "☁️ Soumission du PKG à Apple"

xcrun notarytool submit \
  "${PKG_FINAL}" \
  --keychain-profile "${KEYCHAIN_PROFILE}" \
  --wait --output-format json > "${ARTIFACT_DIR}/pkg-notary.json"
/usr/bin/python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d); sys.exit(0 if d.get("status")=="Accepted" else 1)' "${ARTIFACT_DIR}/pkg-notary.json"

echo ""
echo "📎 Ticket Apple du PKG"

xcrun stapler staple "${PKG_FINAL}"
xcrun stapler validate "${PKG_FINAL}"

echo ""
echo "✅ Vérification Gatekeeper du PKG"

spctl --assess --type install --verbose=2 "${PKG_FINAL}"

echo ""
echo "🎉 FABRICATION TERMINÉE"
echo ""
echo "Installateur à tester avant distribution :"
echo "${PKG_FINAL}"

(
  cd "$ARTIFACT_DIR"
  /usr/bin/shasum -a 256 "${ZIP_FINAL:t}" "${PKG_FINAL:t}" > SHA256SUMS.txt
)
echo "$ZIP_FINAL"
echo "Apple Silicon, macOS 13 minimum. Aucune installation effectuée."
