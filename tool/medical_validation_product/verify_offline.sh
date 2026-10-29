#!/bin/bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"
flutter="${FLUTTER_ROOT:-/Users/jeanclaudebrucher/development/flutter}"
output="${1:?Provide an absolute output directory for synthetic evidence}"
frameworks="${ABAK_TEST_FRAMEWORKS:-/Users/jeanclaudebrucher/Applications/ABAK Companion Local.app/Contents/Frameworks}"
mkdir -p "$output"
cd "$repo"
/usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$flutter/bin/cache/dart-sdk/bin/dartaotruntime" "$flutter/bin/cache/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot" --sdk-root "$flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk" --target=flutter --packages=.dart_tool/package_config.json --output-dill="$output/verify.dill" tool/medical_validation_product/verify.dart > "$output/compile.log" 2>&1
cd "$frameworks"
MEDICAL_TEST_OUTPUT="$output" /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester" --disable-vm-service --run-forever "--flutter-assets-dir=$frameworks/App.framework/Resources/flutter_assets" "$output/verify.dill" > "$output/verification.log" 2>&1
MEDICAL_TEST_PHASE=reopen MEDICAL_TEST_OUTPUT="$output" /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester" --disable-vm-service --run-forever "--flutter-assets-dir=$frameworks/App.framework/Resources/flutter_assets" "$output/verify.dill" > "$output/restart.log" 2>&1
cat "$output/result.json"
cat "$output/restart.json"
