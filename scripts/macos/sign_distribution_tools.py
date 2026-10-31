"""Sign all private Java Mach-O files, then refresh the bundled integrity map.

Call with APP IDENTITY before signing the enclosing bundle, and with APP
--refresh after deep signing but before the final outer application signature.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

MACHO = {b'\xcf\xfa\xed\xfe', b'\xce\xfa\xed\xfe', b'\xca\xfe\xba\xbe', b'\xbe\xba\xfe\xca'}


def inventory(root):
    result = {}
    for file in sorted(root.rglob('*')):
        if file.is_symlink():
            raise ValueError('Symlink forbidden in bundled tools: ' + str(file))
        if file.is_file() and file.name != 'manifest.json':
            result[file.relative_to(root).as_posix()] = hashlib.sha256(file.read_bytes()).hexdigest()
    return result


def main():
    app, identity = Path(sys.argv[1]), sys.argv[2]
    root = app / 'Contents/Resources/DmpTools/arm64'
    manifest = root / 'manifest.json'
    info = json.loads(manifest.read_text())
    if info.get('protocol') != 1 or info.get('profile') != 'PDF/A-1b':
        raise ValueError('Unsupported tools manifest')
    current = inventory(root)
    required = {'java/bin/java', 'java/bin/java-cps', 'vera/cli.jar', 'NOTICE.txt'}
    if not required.issubset(current):
        raise ValueError('Incomplete private tools')
    pinned = json.loads((Path(__file__).parent / 'dmp_tools.lock.json').read_text())['arm64']['vera']
    if current['vera/cli.jar'] != pinned:
        raise ValueError('Unpinned veraPDF archive')
    if identity == '--refresh':
        # Only native code may change through signing, never licenses/JAR/resources.
        if current.keys() != info['files'].keys():
            raise ValueError('Tool file inventory changed during signing')
        for name, digest in current.items():
            with (root / name).open('rb') as stream:
                native = stream.read(4) in MACHO
            if digest != info['files'][name] and not native:
                raise ValueError('Non-native resource changed: ' + name)
        info['files'] = current
        manifest.write_text(json.dumps(info, indent=2) + '\n')
    else:
        if not identity.startswith('Developer ID Application: '):
            raise ValueError('Developer ID Application required')
        if current != info['files']:
            raise ValueError('Private tools failed integrity verification before signing')
        for file in sorted((root / 'java').rglob('*')):
            if not file.is_file():
                continue
            with file.open('rb') as stream:
                native = stream.read(4) in MACHO
            if native:
                subprocess.run(['/usr/bin/codesign', '--force', '--options', 'runtime',
                                '--timestamp', '--preserve-metadata=entitlements',
                                '--sign', identity, str(file)], check=True)


if __name__ == '__main__':
    main()
