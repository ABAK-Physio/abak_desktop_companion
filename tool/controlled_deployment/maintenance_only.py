"""Launch an uninstalled candidate ONLY in maintenance on synthetic storage.

--describe verifies and prints the launch command without opening Companion.
No default storage or normal-launch fallback is available from this tool.
"""
import argparse
import json
from pathlib import Path
import plistlib
import subprocess

import recovery as r

PROFILE = '(version 1)(allow default)(deny network*)(deny file-read* (subpath "/usr/local/lib/libcps3_pkcs11_osx.dylib") (regex #"/Users/[^/]+/Library/(Containers|Group Containers)(/|$)"))(deny file-write* (subpath "/Applications") (regex #"/Users/[^/]+/Applications(/|$)"))'


def prepare(candidate, root):
    candidate, root = Path(candidate), Path(root)
    r.regular(candidate, True)
    if any(p in candidate.parts for p in ['Applications', 'Containers', 'Group Containers']):
        raise ValueError('Candidate non installée requise')
    with r.locked(root):
        r.database_state(root / 'active')
    manifest_path = candidate.parent / 'manifest.json'
    files_path = candidate.parent / 'candidate-files.json'
    r.regular(manifest_path); r.regular(files_path)
    manifest = json.loads(manifest_path.read_text())
    if (manifest['status'] != 'COMPILED_NOT_INSTALLED' or
            manifest['filesManifestSha256'] != r.sha(files_path)):
        raise ValueError('Compilation seule vérifiée requise')
    entries = {}
    for p in sorted(candidate.rglob('*')):
        if p.is_file() or p.is_symlink():
            entries[str(p.relative_to(candidate))] = (
                {'link': str(p.readlink())} if p.is_symlink() else {'sha256': r.sha(p)})
    if entries != json.loads(files_path.read_text()):
        raise ValueError('Candidate modifiée depuis la compilation')
    info = plistlib.loads((candidate / 'Contents/Info.plist').read_bytes())
    if (info['CFBundleIdentifier'], info['CFBundleShortVersionString'], info['CFBundleVersion']) != (
            'fr.abakphysio.abakdesktopcompanion.local', manifest['version'], manifest['build']):
        raise ValueError('Identité/version de la candidate incorrecte')
    executable = info['CFBundleExecutable']
    if Path(executable).name != executable:
        raise ValueError('Nom exécutable non simple')
    binary = candidate / 'Contents/MacOS' / executable
    r.regular(binary)
    subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(candidate)], check=True)
    return ['/usr/bin/sandbox-exec', '-p', PROFILE, str(binary), '--abak-maintenance',
            '--abak-maintenance-root=' + str(root)]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--describe', action='store_true')
    args = parser.parse_args()
    command = prepare(args.candidate, args.root)
    if args.describe:
        print(json.dumps({'launchExecuted': False, 'command': command}, ensure_ascii=False, indent=2))
    else:
        raise SystemExit('Lancement historique désactivé : App Sandbox refuse la sandbox imbriquée. '
                         'Utiliser native_recipe.py avec une copie de recette distincte ; aucun lancement effectué.')
