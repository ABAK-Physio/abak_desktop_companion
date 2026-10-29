#!/bin/bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"
output="${1:?Evidence output directory required}"
candidate="${2:?Built uninstalled candidate app required}"
flutter="${FLUTTER_ROOT:-/Users/jeanclaudebrucher/development/flutter}"
[[ "$output" = /* && ! -e "$output" && "$candidate" = /* ]] || exit 2
mkdir -p "$output/tmp"
cd "$repo"
profile='(version 1)(allow default)(deny network*)(deny file-read* (subpath "/usr/local/lib/libcps3_pkcs11_osx.dylib") (regex #"/Users/[^/]+/Library/(Containers|Group Containers)(/|$)"))(deny file-write* (subpath "/Applications") (regex #"/Users/[^/]+/Applications(/|$)"))'
/usr/bin/sandbox-exec -p "$profile" "$flutter/bin/cache/dart-sdk/bin/dartaotruntime" "$flutter/bin/cache/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot" --sdk-root "$flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk" --target=flutter --packages=.dart_tool/package_config.json --output-dill="$output/verify.dill" tool/controlled_deployment/verify.dart > "$output/compile.log" 2>&1
export DEPLOY_REPO="$repo" DEPLOY_OUTPUT="$output" DEPLOY_FRAMEWORKS="$candidate/Contents/Frameworks" DEPLOY_TESTER="$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester"
/usr/bin/sandbox-exec -p "$profile" /usr/bin/python3 tool/controlled_deployment/verify.py > "$output/verification.log" 2>&1
cat "$output/result.json"
