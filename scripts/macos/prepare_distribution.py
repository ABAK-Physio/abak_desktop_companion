"""Compile an arm64 distribution from an isolated copy, using local dependencies.

Invoked by build_macos_notarized.sh. Never install or launch the application.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess

REPO = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--build', required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    source = out / 'source'
    source.mkdir()  # Refuse to overwrite a previous candidate.
    files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=REPO).decode().split('\0')
    files += ['scripts/macos/' + name for name in ['prepare_distribution.py', 'sign_distribution_tools.py', 'verify_distribution.py', 'test_distribution_tools.py']]
    hashes = {}
    for name in sorted(set(files) - {''}):
        original = REPO / name
        if not original.is_file():
            raise RuntimeError('Tracked source missing: ' + name)
        target = source / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(original, target)
        hashes[name] = hashlib.sha256(original.read_bytes()).hexdigest()
    (out / 'sources.json').write_text(json.dumps(hashes, indent=2))
    # Preserve relative path dependencies without linking to mutable originals.
    dependency_hashes = {}
    for dependency in ['abak_shared', 'abak_vitale']:
        original_root = REPO.parent / dependency
        dependency_files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=original_root).decode().split('\0')
        dependency_hashes[dependency] = {}
        for name in filter(None, dependency_files):
            original = original_root / name
            target = out / dependency / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(original, target)
            dependency_hashes[dependency][name] = hashlib.sha256(original.read_bytes()).hexdigest()
    (out / 'dependency-sources.json').write_text(json.dumps(dependency_hashes, indent=2))
    # Resolve package-pinned SQLite from the existing cache, without downloading.
    subprocess.run(['/usr/bin/python3', 'scripts/macos/prepare_offline_sqlite.py'], cwd=REPO, check=True)
    (source / '.dart_tool').mkdir()
    for name in ['dmp-tools', 'abak_offline_sqlite']:
        shutil.copytree(REPO / '.dart_tool' / name, source / '.dart_tool' / name)
    pub = source / 'pubspec.yaml'
    text = pub.read_text()
    if '\nhooks:' in text:
        raise RuntimeError('Existing hooks must be reviewed before overriding them')
    pub.write_text(text + '\nhooks:\n  user_defines:\n    sqlite3:\n      source: test-sqlite3\n      directory: .dart_tool/abak_offline_sqlite/\n')
    wrappers = out / 'wrappers'
    wrappers.mkdir()
    wrapper = wrappers / 'xcrun'
    wrapper.write_text('#!/bin/zsh\nif [[ "${1:-}" == xcodebuild ]]; then\n shift\n exec /usr/bin/xcrun xcodebuild -IDEPackageSupportDisableManifestSandbox=YES "$@"\nfi\nexec /usr/bin/xcrun "$@"\n')
    wrapper.chmod(0o700)
    flutter = shutil.which('flutter')
    if flutter is None:
        raise RuntimeError('Flutter SDK not available')
    env = dict(os.environ, PATH=str(wrappers) + ':' + os.environ['PATH'],
               FLUTTER_SKIP_UPDATE_CHECK='true',
               FLUTTER_XCODE_ARCHS='arm64', FLUTTER_XCODE_ONLY_ACTIVE_ARCH='YES',
               FLUTTER_XCODE_MACOSX_DEPLOYMENT_TARGET='13.0',
               FLUTTER_XCODE_PRODUCT_BUNDLE_IDENTIFIER='fr.abakphysio.abakdesktopcompanion',
               FLUTTER_XCODE_ASSETCATALOG_COMPILER_APPICON_NAME='AppIcon',
               FLUTTER_XCODE_ABAK_APP_DISPLAY_NAME='ABAK Companion')
    with (out / 'build.log').open('w') as log:
        subprocess.run([flutter, 'pub', 'get', '--offline'], cwd=source, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
        if (source / 'pubspec.lock').read_bytes() != (REPO / 'pubspec.lock').read_bytes():
            raise RuntimeError('Offline resolution changed pinned dependencies')
        subprocess.run([flutter, 'build', 'macos', '--release', '--no-pub', '--obfuscate',
                        '--split-debug-info=' + str(out / 'debug-info'), '--tree-shake-icons',
                        '--build-name=' + args.version, '--build-number=' + args.build,
                        '--dart-define=ENV=production'], cwd=source, env=env,
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    app = source / 'build/macos/Build/Products/Release/abak_desktop_companion.app'
    info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
    expected = ('fr.abakphysio.abakdesktopcompanion', args.version, args.build, '13.0')
    actual = tuple(info.get(k) for k in ['CFBundleIdentifier', 'CFBundleShortVersionString', 'CFBundleVersion', 'LSMinimumSystemVersion'])
    if actual != expected:
        raise RuntimeError('Unexpected application identity/version/minimum OS: ' + str(actual))
    binary = app / 'Contents/MacOS' / info['CFBundleExecutable']
    if subprocess.check_output(['lipo', '-archs', str(binary)], text=True).strip() != 'arm64':
        raise RuntimeError('Distribution must be Apple Silicon only')
    if any(hashlib.sha256((REPO / n).read_bytes()).hexdigest() != h for n, h in hashes.items()):
        raise RuntimeError('Working source changed during compilation')
    print('Isolated Apple Silicon candidate: ' + str(app))


if __name__ == '__main__':
    main()
