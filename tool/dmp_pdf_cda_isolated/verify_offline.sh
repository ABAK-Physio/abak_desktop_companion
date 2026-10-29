#!/bin/zsh
set -eu
# Explicit paths only: synthetic fixtures, copied CDA resources, NEW output,
# Poppler directory, Python with lxml/Pillow. No downloads or real application.
[[ $# -eq 5 || $# -eq 7 ]] || { print 'Requis : fixtures synthétiques, ressources CDA, sortie neuve, Poppler, Python'; exit 2; }
[[ ! -e "$3" ]] || { print 'Répertoire de sortie neuf requis'; exit 2; }
extra=()
if [[ $# -eq 7 ]]; then extra=("$6" "$7"); fi
exec /usr/bin/sandbox-exec -p '(version 1)(allow default)(deny network*)' "$5" "${0:A:h}/verify.py" "$1" "$2" "$3" "$4" "${extra[@]}"
