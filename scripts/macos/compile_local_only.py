"""Build an identified local candidate OFFLINE. No install or launch operation.

Public entry: compile_macos_local_only.sh (mandatory sandbox boundary).
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[2]


def digest(p):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def tree(root):
    return {str(p.relative_to(root)): ({'link': str(p.readlink())} if p.is_symlink()
            else {'sha256': digest(p)}) for p in sorted(root.rglob('*'))
            if (p.is_file() or p.is_symlink()) and 'ephemeral' not in p.parts}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--output', type=Path, required=True)
    ap.add_argument('--version', required=True)
    ap.add_argument('--build', required=True)
    ap.add_argument('--preferences-recipe', action='store_true',
                    help='Compile only the isolated native preferences test entry point, not a distributable application')
    ap.add_argument('--report-pdf-recipe', action='store_true', help='Compile the isolated synthetic report PDF acceptance entry point')
    args = ap.parse_args()
    if args.report_pdf_recipe and args.preferences_recipe:
        ap.error('Choisir une seule recette')
    if not re.fullmatch(r'\d+\.\d+\.\d+', args.version) or not re.fullmatch(r'[1-9]\d*', args.build):
        ap.error('Version/build explicites requis')
    out = args.output
    if not out.is_absolute() or out.exists() or any(x in out.parts for x in ['Applications', 'Containers', 'Group Containers']):
        ap.error('Dossier de sortie neuf et absolu, hors installation/conteneurs requis')
    if out.parent.resolve() != out.parent or not out.parent.is_dir() or out.is_relative_to(REPO):
        ap.error('Parent existant canonique hors dépôt requis')
    text = (REPO / 'pubspec.yaml').read_text()
    current = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', text, re.M)
    # Rebuilding the exact version recorded in pubspec must preserve its build.
    # A different candidate still requires a newer build and no version downgrade.
    if not current:
        ap.error('Version/build de la source introuvables')
    same_as_source = (args.version, args.build) == current.groups()
    older_or_same_build = int(args.build) <= int(current[2])
    older_version = tuple(map(int, args.version.split('.'))) < tuple(map(int, current[1].split('.')))
    if not same_as_source and (older_or_same_build or older_version):
        ap.error('Reprendre la version/build de la source, ou choisir un build supérieur et une version non antérieure')
    if re.search(r'^hooks:', text, re.M):
        ap.error('Hooks préexistants : ne pas les remplacer implicitement')
    flutter = Path(os.environ.get('FLUTTER_ROOT', '/Users/jeanclaudebrucher/development/flutter'))
    if not (flutter / 'bin/flutter').is_file():
        ap.error('SDK Flutter local absent ; aucun téléchargement')
    if os.environ.get('ABAK_BUILD_SANDBOX') != 'network-and-install-denied':
        ap.error('Utiliser compile_macos_local_only.sh pour appliquer la sandbox')
    lock = (REPO / '.dart_tool/compile-only.lock').open('a+')
    fcntl.lockf(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    out.mkdir()
    source = {n: tree(REPO / n) for n in ['lib', 'assets', 'macos/Runner', 'macos/DocumentControls', 'macos/Runner.xcodeproj', 'macos/Runner.xcworkspace', 'macos/Flutter']}
    source['pubspec'] = {n: digest(REPO / n) for n in ['pubspec.yaml', 'pubspec.lock']}
    target = 'tool/controlled_deployment/preferences_recipe.dart' if args.preferences_recipe else 'lib/main.dart'
    if args.report_pdf_recipe:
        target = 'tool/report_pdf_import_product/native_recipe.dart'
    source['entryPoint'] = {'path': target, 'sha256': digest(REPO / target)}
    (out / 'sources.json').write_text(json.dumps(source, indent=2))
    manifest = {'status': 'BUILDING', 'version': args.version, 'build': args.build,
                'bundleIdentifier': 'fr.abakphysio.abakdesktopcompanion.local',
                'installed': False, 'launched': False, 'networkAllowed': False}
    manifest['preferencesRecipeOnly'] = args.preferences_recipe
    manifest['reportPdfRecipeOnly'] = args.report_pdf_recipe
    pub = REPO / 'pubspec.yaml'
    modified = None
    with tempfile.TemporaryDirectory(prefix='abak-build-only-') as temporary:
        temp = Path(temporary)
        try:
            subprocess.run(['/usr/bin/python3', 'scripts/macos/prepare_offline_sqlite.py'], cwd=REPO, check=True)
            modified = text + '\nhooks:\n  user_defines:\n    sqlite3:\n      source: test-sqlite3\n      directory: .dart_tool/abak_offline_sqlite/\n'
            (out / 'pubspec.before').write_text(text)
            pub.write_text(modified)
            wrapper = temp / 'xcrun'
            wrapper.write_text('#!/bin/zsh\nif [[ "${1:-}" == xcodebuild ]]; then\n shift\n exec /usr/bin/xcrun xcodebuild -IDEPackageSupportDisableManifestSandbox=YES "$@"\nfi\nexec /usr/bin/xcrun "$@"\n')
            wrapper.chmod(0o700)
            env = dict(os.environ, PATH=str(temp) + ':' + str(flutter / 'bin') + ':' + os.environ.get('PATH', ''),
                       FLUTTER_XCODE_PRODUCT_BUNDLE_IDENTIFIER=manifest['bundleIdentifier'],
                       FLUTTER_XCODE_ASSETCATALOG_COMPILER_APPICON_NAME='AppIconLocal',
                       FLUTTER_XCODE_ABAK_APP_DISPLAY_NAME='ABAK Companion — Local')
            with (out / 'build.log').open('w') as log:
                subprocess.run([str(flutter / 'bin/flutter'), 'build', 'macos', '--release', '--no-pub',
                                '--target=' + target,
                                '--dart-define=ENV=local_release', '--build-name=' + args.version,
                                '--build-number=' + args.build], cwd=REPO, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
            app = REPO / 'build/macos/Build/Products/Release/abak_desktop_companion.app'
            info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
            if (info.get('CFBundleIdentifier'), info.get('CFBundleShortVersionString'), info.get('CFBundleVersion')) != (manifest['bundleIdentifier'], args.version, args.build):
                raise ValueError('Identité/version de la candidate incorrecte')
            subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(app)], check=True)
            for name in ['lib', 'assets', 'macos/Runner', 'macos/DocumentControls', 'macos/Runner.xcodeproj', 'macos/Runner.xcworkspace', 'macos/Flutter']:
                if tree(REPO / name) != source[name]:
                    raise ValueError('Sources modifiées pendant le build : ' + name)
            if digest(REPO / 'pubspec.lock') != source['pubspec']['pubspec.lock']:
                raise ValueError('Dépendances modifiées pendant le build')
            if digest(REPO / target) != source['entryPoint']['sha256']:
                raise ValueError('Entrée modifiée pendant le build')
            if pub.read_text() != modified:
                raise ValueError('pubspec modifié ailleurs pendant le build')
            destination = out / 'Companion-candidate.app'
            subprocess.run(['/usr/bin/ditto', str(app), str(destination)], check=True)
            subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(destination)], check=True)
            files = tree(destination)
            (out / 'candidate-files.json').write_text(json.dumps(files, indent=2))
            manifest.update(status='COMPILED_NOT_INSTALLED', filesManifestSha256=digest(out / 'candidate-files.json'))
        except BaseException as error:
            manifest.update(status='FAILED_NOT_INSTALLED', error=str(error))
            raise
        finally:
            if modified is not None:
                if pub.read_text() == modified:
                    pub.write_text(text)
                else:
                    manifest.update(status='FAILED_NOT_INSTALLED', restoration='Concurrent pubspec modification; original preserved in pubspec.before')
            (out / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print('Candidate compilée dans ' + str(out) + ' ; aucune installation ni ouverture.')


if __name__ == '__main__':
    main()
