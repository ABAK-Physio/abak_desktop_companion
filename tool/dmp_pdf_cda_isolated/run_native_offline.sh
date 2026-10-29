#!/bin/zsh
set -eu
# Resources, NEW output, explicit veraPDF executable, Poppler, Python.
[[ $# -eq 5 ]] || exit 2
[[ ! -e "$2" ]] || { print 'Sortie neuve requise'; exit 2; }
exec /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$5" "${0:A:h}/verify_native.py" "$1" "$2" "$3" "$4"
