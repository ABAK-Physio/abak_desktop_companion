#!/usr/bin/env zsh
set -euo pipefail

BUILD_ARGS=()
LAUNCH_APP=1
for option in "$@"; do
  case "$option" in
    --no-launch) LAUNCH_APP=0 ;;
    --no-pub) BUILD_ARGS+=(--no-pub) ;;
    *) echo "Option inconnue : $option" >&2; exit 2 ;;
  esac
done

# Se placer à la racine du projet
cd "$(dirname "$0")/../.."

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠 ABAK Desktop Companion"
echo "🏠 Release locale macOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🔨 Build Flutter Release"

# Ces réglages ne s'appliquent qu'à cette compilation locale.
FLUTTER_XCODE_ASSETCATALOG_COMPILER_APPICON_NAME=AppIconLocal \
FLUTTER_XCODE_ABAK_APP_DISPLAY_NAME="ABAK Companion — Local" \
flutter build macos --release --dart-define=ENV=local_release "${BUILD_ARGS[@]}"

APP_PATH="build/macos/Build/Products/Release/abak_desktop_companion.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "❌ Application Release introuvable :"
  echo "$APP_PATH"
  exit 1
fi

echo ""
# Copie autonome : une compilation de distribution ou flutter clean
# ne doit pas remplacer l'application utilisée par le raccourci local.
LOCAL_APP_PATH="$HOME/Applications/ABAK Companion Local.app"
STAGING_ROOT="$HOME/Applications/.abak-companion-local"
mkdir -p "$STAGING_ROOT"
STAGING_DIR="$(mktemp -d "$STAGING_ROOT/install.XXXXXX")"
trap 'rm -rf "$STAGING_DIR"' EXIT

ditto "$APP_PATH" "$STAGING_DIR/new.app"
codesign --verify --deep --strict "$STAGING_DIR/new.app"

if [[ -e "$LOCAL_APP_PATH" ]]; then
  mv "$LOCAL_APP_PATH" "$STAGING_DIR/previous.app"
fi
if ! mv "$STAGING_DIR/new.app" "$LOCAL_APP_PATH"; then
  if [[ -e "$STAGING_DIR/previous.app" ]]; then
    if ! mv "$STAGING_DIR/previous.app" "$LOCAL_APP_PATH"; then
      trap - EXIT
      echo "❌ Copie précédente conservée dans : $STAGING_DIR/previous.app" >&2
    fi
  fi
  exit 1
fi

echo "✅ RELEASE LOCALE TERMINÉE"
echo ""
echo "Application :"
echo "$LOCAL_APP_PATH"
echo ""
echo "⚠️ Cette version utilise l'environnement Release macOS"
echo "   et donc la base de données du conteneur sandbox Release."

echo ""
if (( LAUNCH_APP )); then
  echo "🚀 Lancement de la Release locale"
  open "$LOCAL_APP_PATH"
fi
