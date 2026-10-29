#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/../.."
# Deny network AND writes to installed applications and every user container.
# No installer is reachable from this entry; signing uses existing local material.
export ABAK_BUILD_SANDBOX=network-and-install-denied
exec /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)(deny file-write* (subpath "/Applications") (regex #"/Users/[^/]+/Applications(/|$)") (regex #"/Users/[^/]+/Library/(Containers|Group Containers)(/|$)"))' /usr/bin/python3 scripts/macos/compile_local_only.py "$@"
