#!/bin/zsh
# Build/install only. The outer sandbox denies all network access throughout.
# SwiftPM's manifest sandbox cannot be nested in sandbox-exec on this Mac.
# Scope its exception to xcodebuild child commands; never change Xcode defaults.
set -euo pipefail

# Acquire before preparation; nested scripts inherit the same kernel lock.
if ! /usr/bin/python3 "${0:A:h}/macos_build_lock.py" --held; then
  exec /usr/bin/python3 "${0:A:h}/macos_build_lock.py" /bin/zsh "$0" "$@"
fi
cd "$(dirname "$0")/../.."
WRAPPERS=$(mktemp -d /tmp/abak-offline-build.XXXXXX)
cleanup() {
  if [[ -f "$WRAPPERS/pubspec.original" ]]; then
    # Only restore our own temporary edit, never overwrite another edit.
    if cmp -s pubspec.yaml "$WRAPPERS/pubspec.offline"; then
      cp "$WRAPPERS/pubspec.original" pubspec.yaml
    else
      echo "pubspec modifié pendant la compilation : sauvegarde conservée dans $WRAPPERS" >&2
      return
    fi
  fi
  rm -rf "$WRAPPERS"
}
trap cleanup EXIT
python3 scripts/macos/prepare_offline_sqlite.py
if grep -q '^hooks:' pubspec.yaml; then
  echo 'Configuration hooks existante : adaptation manuelle requise, aucun remplacement.' >&2
  exit 1
fi
cp pubspec.yaml "$WRAPPERS/pubspec.original"
# This package-supported local source still enforces the official SHA256.
cat >> pubspec.yaml <<'HOOKS'

# Temporary offline build inputs, restored on exit.
hooks:
  user_defines:
    sqlite3:
      source: test-sqlite3
      directory: .dart_tool/abak_offline_sqlite/
HOOKS
cp pubspec.yaml "$WRAPPERS/pubspec.offline"
cat > "$WRAPPERS/xcrun" <<'WRAPPER'
#!/bin/zsh
set -euo pipefail
if [[ "${1:-}" == xcodebuild ]]; then
  shift
  exec /usr/bin/xcrun xcodebuild -IDEPackageSupportDisableManifestSandbox=YES "$@"
fi
exec /usr/bin/xcrun "$@"
WRAPPER
chmod +x "$WRAPPERS/xcrun"
export PATH="$WRAPPERS:$PATH"
exec_script=scripts/macos/build_macos_release_local.sh
/usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$exec_script" --no-pub --no-launch
