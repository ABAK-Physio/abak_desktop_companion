#!/usr/bin/env zsh
set -euo pipefail

BUILD_NAME=${1:-"1.0.0"}
BUILD_NUMBER=${2:-"1"}

DATE=$(date +%F)
DEBUG_INFO_DIR="build/debug-info/macos/$DATE"

echo "📦 Compilation macOS Desktop Release avec obfuscation…"
echo "🆕 Version : $BUILD_NAME ($BUILD_NUMBER)"
echo "📂 Symboles : $DEBUG_INFO_DIR"

mkdir -p "$DEBUG_INFO_DIR"

flutter clean
flutter pub get

flutter build macos --release \
  --obfuscate \
  --split-debug-info="$DEBUG_INFO_DIR" \
  --strip \
  --tree-shake-icons \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER" \
  --dart-define=ENV=production

echo "✅ Build macOS terminé"
echo "📍 Application générée dans : build/macos/Build/Products/Release/"