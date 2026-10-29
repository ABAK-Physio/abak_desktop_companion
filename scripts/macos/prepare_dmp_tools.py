"""Build private Java + veraPDF resources from explicit, pinned local inputs.
No download, global installation, or change to user settings.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import zipfile

repo = Path(__file__).resolve().parents[2]

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def manifest(root):
    return {p.relative_to(root).as_posix(): digest(p) for p in sorted(root.rglob('*')) if p.is_file() and p.name != 'manifest.json'}

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--java-home', type=Path, required=True)
    ap.add_argument('--vera-jar', type=Path, required=True)
    ap.add_argument('--arch', choices=['arm64', 'x86_64'], required=True)
    args = ap.parse_args()
    lock = json.loads((repo/'scripts/macos/dmp_tools.lock.json').read_text())[args.arch]
    for key, path in [('java', args.java_home/'bin/java'), ('release', args.java_home/'release'), ('vera', args.vera_jar)]:
        if digest(path) != lock[key]: raise SystemExit('Input differs from pinned '+key)
    actual = subprocess.check_output(['/usr/bin/lipo', '-archs', str(args.java_home/'bin/java')], text=True).split()
    if args.arch not in actual: raise SystemExit('Wrong Java architecture')
    root = repo/'.dart_tool/dmp-tools'/args.arch
    if root.exists(): raise SystemExit('Output already exists; choose a fresh preparation after inspecting the existing cache')
    root.mkdir(parents=True)
    try:
        subprocess.run([str(args.java_home/'bin/jlink'), '--add-modules', 'java.base,java.desktop,java.logging,java.xml,java.management,java.naming,jdk.compiler,jdk.zipfs,jdk.crypto.cryptoki,jdk.crypto.ec', '--strip-debug', '--no-header-files', '--no-man-pages', '--output', str(root/'java')], check=True)
        # jlink legal notices can contain symlinks; distribute plain copies.
        for path in list((root/'java').rglob('*')):
            if path.is_symlink():
                data = path.read_bytes(); path.unlink(); path.write_bytes(data)
        (root/'vera').mkdir()
        shutil.copy2(args.vera_jar, root/'vera/cli.jar')
        notices = root/'licenses'; notices.mkdir()
        shutil.copy2(repo/'scripts/macos/licenses/veraPDF-LICENSE.MPL', notices/'veraPDF-LICENSE.MPL')
        with zipfile.ZipFile(args.vera_jar) as archive:
            for i, name in enumerate(archive.namelist()):
                if not name.endswith(('/', '.class')) and any(x in Path(name).name.lower() for x in ['license', 'notice', 'copying']):
                    (notices/f'{i}-{Path(name).name}').write_bytes(archive.read(name))
        (root/'NOTICE.txt').write_text('ABAK private PDF/A tools\nveraPDF CLI 1.30.3, unmodified, MPL 2.0 option.\nSources and license: https://github.com/veraPDF/veraPDF-apps/tree/v1.30.3\nhttps://site.verapdf.org/develop/\nEclipse Temurin OpenJDK 17 private jlink runtime, GPLv2 with Classpath Exception.\nLicense notices included under java/legal.\nCorresponding sources: https://github.com/adoptium/temurin17-binaries/releases\nRuntime release metadata included under java/release.\nNo system Java installation.\n')
        (root/'manifest.json').write_text(json.dumps({'protocol':1,'profile':'PDF/A-1b','arch':args.arch,'files':manifest(root)}, indent=2))
        print(root)
    except BaseException:
        shutil.rmtree(root)
        raise
