#!/bin/bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"
flutter="${FLUTTER_ROOT:-/Users/jeanclaudebrucher/development/flutter}"
output="${1:?Absolute evidence directory required}"
certs="${2:?Synthetic native certificate directory required}"
refs="${3:?Archived CDA references required}"
frameworks="${ABAK_TEST_FRAMEWORKS:-/Users/jeanclaudebrucher/Applications/ABAK Companion Local.app/Contents/Frameworks}"
python="/Users/jeanclaudebrucher/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
[[ "$output" = /* && ! -e "$output/result.json" ]] || exit 2
mkdir -p "$output/fixtures" "$output/classes" "$output/tmp" "$output/swift-cache"
cd "$repo"
offline() { /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$@"; }
for kind in rapport modifie blanc; do offline "$python" tool/document_business_acceptance/fixtures.py "$output/fixtures" "$kind"; done
offline /usr/bin/xcrun swiftc -module-cache-path "$output/swift-cache" tool/document_business_acceptance/render.swift -o "$output/render"
offline /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/javac -d "$output/classes" assets/dmp_native/DmpNativeBridge.java tool/document_native_product/NativeTestBridge.java > "$output/java-compile.log" 2>&1
offline "$flutter/bin/cache/dart-sdk/bin/dartaotruntime" "$flutter/bin/cache/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot" --sdk-root "$flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk" --target=flutter --packages=.dart_tool/package_config.json --output-dill="$output/verify.dill" tool/document_business_acceptance/verify.dart > "$output/compile.log" 2>&1
export CHAIN_TEST_REPO="$repo" WIRE_CERTIFICATES="$certs" CONTROLS_TEST_REFS="$refs" ACCEPTANCE_OUTPUT="$output" TMPDIR="$output/tmp"
cd "$frameworks"
offline "$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester" --disable-vm-service --run-forever "--flutter-assets-dir=$frameworks/App.framework/Resources/flutter_assets" "$output/verify.dill" > "$output/verification.log" 2>&1
ACCEPTANCE_PHASE=restore_missing offline "$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester" --disable-vm-service --run-forever "--flutter-assets-dir=$frameworks/App.framework/Resources/flutter_assets" "$output/verify.dill" > "$output/restore-missing.log" 2>&1
ACCEPTANCE_PHASE=reopen offline "$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester" --disable-vm-service --run-forever "--flutter-assets-dir=$frameworks/App.framework/Resources/flutter_assets" "$output/verify.dill" > "$output/restart.log" 2>&1
