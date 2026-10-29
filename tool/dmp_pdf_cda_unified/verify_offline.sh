#!/bin/zsh
set -euo pipefail
[[ $# -eq 2 ]] || { print 'Usage : verify_offline.sh CONFIGURATION_JSON PYTHON_LOCAL'; exit 2; }
cd "${0:A:h}/../.."
exec /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$2" tool/dmp_pdf_cda_unified/verify.py "$1"
