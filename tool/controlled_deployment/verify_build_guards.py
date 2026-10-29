"""Fault injection in a disposable fake repository; never edit the real pubspec."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

repo = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('compile_only', repo / 'scripts/macos/compile_local_only.py')
build = importlib.util.module_from_spec(spec)
spec.loader.exec_module(build)
checks = []


def check(value, label):
    if not value: raise AssertionError(label)
    checks.append(label)


with tempfile.TemporaryDirectory(prefix='abak-build-failure-') as tmp:
    root = Path(tmp).resolve()
    fake = root / 'repo'
    for name in ['.dart_tool', 'lib', 'assets', 'macos/Runner', 'macos/Runner.xcodeproj',
                 'macos/Runner.xcworkspace', 'macos/Flutter', 'scripts/macos']:
        (fake / name).mkdir(parents=True, exist_ok=True)
    original = 'name: synthetic\nversion: 1.1.0+9\n'
    (fake/'pubspec.yaml').write_text(original)
    (fake/'pubspec.lock').write_text('SYNTHETIC LOCK')
    (fake/'lib/main.dart').write_text('void main() {}\n')
    (fake/'scripts/macos/prepare_offline_sqlite.py').write_text('pass\n')
    sdk = root/'sdk'
    (sdk/'bin').mkdir(parents=True)
    flutter=sdk/'bin/flutter'
    flutter.write_text('#!/bin/sh\nexit 27\n'); flutter.chmod(0o700)
    build.REPO = fake
    os.environ.update(ABAK_BUILD_SANDBOX='network-and-install-denied', FLUTTER_ROOT=str(sdk))
    def invoke(output, version='1.1.1', number='10'):
        sys.argv=['compile', '--output',str(output),'--version',version,'--build',number]
        build.main()
    def refuses(output, label, **kwargs):
        try: invoke(output, **kwargs)
        except SystemExit as e: check(e.code != 0, label)
        else: raise AssertionError(label)
    refuses(root/'Applications/release','Destination installation refusée')
    refuses(root/'candidate','Numéro de build ancien refusé',number='9')
    refuses(root/'candidate','Version antérieure refusée',version='1.0.9')
    refuses(fake/'candidate','Sortie dans les sources refusée')
    try: invoke(root/'failed-build')
    except subprocess.CalledProcessError as e: check(e.returncode==27,'Échec de compilation injecté détecté')
    else: raise AssertionError('Expected compilation failure')
    check((fake/'pubspec.yaml').read_text()==original,'pubspec restauré après échec')
    check((fake/'pubspec.lock').read_text()=='SYNTHETIC LOCK','Verrou des dépendances conservé')
    status=json.loads((root/'failed-build/manifest.json').read_text())
    check(status['status']=='FAILED_NOT_INSTALLED' and not status['installed'] and not status['launched'],
          'Échec conservé explicitement sans installation ni lancement')
    check(not (root/'failed-build/Companion-candidate.app').exists(),'Aucune candidate présentée comme réussie après échec')
    refuses(root/'failed-build','Dossier de preuves existant non écrasé')
    os.environ.pop('ABAK_BUILD_SANDBOX')
    refuses(root/'unsandboxed','Entrée hors sandbox refusée')
print(json.dumps({'passed': True, 'checks': checks, 'assertions':len(checks)}, ensure_ascii=False,indent=2))
