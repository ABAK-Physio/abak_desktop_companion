#!/bin/zsh
set -eu
# Usage: verify_offline.sh FIXTURE_DIRECTORY NEW_RESULT_DIRECTORY DART POPPLER_BIN
# No dependency installation, no application startup, no real service.
cd "${0:A:h}/../.."
[[ $# -eq 4 ]] || { print 'Quatre arguments requis : fixtures, résultats neufs, Dart, Poppler.'; exit 2; }
[[ ! -e "$2" ]] || { print 'Choisir un répertoire de résultats neuf.'; exit 2; }
exec /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$3" tool/dmp_pdf_isolated/verify.dart "$1" "$2" "$4"
