#!/bin/bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"
output="${1:?New absolute evidence directory}"
source="${2:?Archived synthetic ABAK DOCX}"
office="${3:?Official verified LibreOffice.app copy}"
refs="${4:?Archived CDA references directory}"
flutter="/Users/jeanclaudebrucher/development/flutter"
frameworks="/Users/jeanclaudebrucher/Applications/ABAK Companion Local.app/Contents/Frameworks"
cd "$repo"
offline() { /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)(deny file-read* (literal "/usr/local/lib/libcps3_pkcs11_osx.dylib"))(deny iokit-open)' "$@"; }
offline /usr/bin/python3 tool/docx_pdf_product/prepare.py "$output" "$source" > "${output}.prepare.log" 2>&1
offline /usr/bin/xcrun swiftc tool/document_business_acceptance/render.swift -o "$output/render"
offline "$flutter/bin/cache/dart-sdk/bin/dartaotruntime" "$flutter/bin/cache/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot" --sdk-root "$flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk" --target=flutter --packages=.dart_tool/package_config.json --output-dill="$output/verify.dill" tool/docx_pdf_product/verify.dart > "$output/compile.log" 2>&1
export DOCX_OUTPUT="$output" DOCX_REPO="$repo" DOCX_OFFICE="$office" DOCX_REFERENCES="$refs"
cd "$frameworks"
offline "$flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester" --disable-vm-service --run-forever "--flutter-assets-dir=$frameworks/App.framework/Resources/flutter_assets" "$output/verify.dill" > "$output/verification.log" 2>&1
