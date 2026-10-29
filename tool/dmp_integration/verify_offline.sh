#!/bin/zsh
set -eu
cd "$(dirname "$0")/../.."
FLUTTER_BIN=${FLUTTER_BIN:-/Users/jeanclaudebrucher/development/flutter/bin/flutter}
proof_dir=$(mktemp -d "${TMPDIR:-/tmp}/abak-dmp-integration-preuves.XXXXXX")
# Flutter's tester requires loopback IPC. All non-loopback networking is denied.
policy='(version 1)(allow default)(deny network*)(allow network-inbound (local ip "localhost:*"))(allow network-outbound (remote ip "localhost:*"))'
ABAK_INTEGRATION_EVIDENCE="$proof_dir/Resultats_32.json" \
  /usr/bin/sandbox-exec -p "$policy" "$FLUTTER_BIN" test --no-pub --reporter expanded \
  test/dmp_dossier_integration_test.dart > "$proof_dir/Tests.txt" 2>&1
printf 'Tests réussis. Preuves : %s\n' "$proof_dir"
