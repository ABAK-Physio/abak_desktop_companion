"""Embed and sign pinned private PDF/A tools before the enclosing app is signed."""
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
cache = repo/'.dart_tool/dmp-tools'
app = Path(os.environ['TARGET_BUILD_DIR'])/os.environ['FULL_PRODUCT_NAME']
identity = os.environ['EXPANDED_CODE_SIGN_IDENTITY']
destination = app/'Contents/Resources/DmpTools'
if not list(cache.glob('*/manifest.json')):
    raise SystemExit('Prepare pinned DMP tools with scripts/macos/prepare_dmp_tools.py before compiling.')
if destination.exists(): shutil.rmtree(destination)
for source in sorted(cache.iterdir()):
    if source.name not in ['arm64', 'x86_64']: continue
    info = json.loads((source/'manifest.json').read_text())
    actual = {}
    for file in source.rglob('*'):
        if file.is_symlink(): raise SystemExit('Unexpected symlink in DMP package')
        if file.is_file() and file.name != 'manifest.json':
            actual[file.relative_to(source).as_posix()] = hashlib.sha256(file.read_bytes()).hexdigest()
    if info['files'] != actual: raise SystemExit('DMP package integrity failed')
    target = destination/source.name
    shutil.copytree(source, target)
    # A dedicated launcher carries the entitlement checked by macOS PC/SC.
    # Keep the PDF launcher unchanged and never re-sign the system JDK.
    release = (target/'java/release').read_text()
    if not all(module in release for module in ['jdk.crypto.cryptoki', 'jdk.crypto.ec']):
        raise SystemExit('Reprepare private DMP tools: CPS crypto modules are missing.')
    cps_launcher = target/'java/bin/java-cps'
    shutil.copy2(target/'java/bin/java', cps_launcher)
    with tempfile.TemporaryDirectory() as scratch:
        ent = Path(scratch)/'java.entitlements'
        ent.write_bytes(plistlib.dumps({'com.apple.security.cs.allow-jit':True,
            'com.apple.security.cs.allow-unsigned-executable-memory':True,
            'com.apple.security.cs.disable-library-validation':True}))
        cps_ent = Path(scratch)/'java-cps.entitlements'
        cps_rights = plistlib.loads(ent.read_bytes())
        cps_rights['com.apple.security.smartcard'] = True
        cps_ent.write_bytes(plistlib.dumps(cps_rights))
        # Libraries first, Java launcher last. Only Java gets runtime entitlements.
        binaries = []
        for file in (target/'java').rglob('*'):
            if file.is_file() and file.open('rb').read(4) in [b'\xcf\xfa\xed\xfe', b'\xce\xfa\xed\xfe', b'\xca\xfe\xba\xbe']:
                binaries.append(file)
        for file in sorted(binaries, key=lambda f: f.name == 'java'):
            cmd = ['/usr/bin/codesign','--force','--sign',identity,'--options','runtime','--timestamp=none']
            if file.name == 'java': cmd += ['--entitlements',str(ent)]
            if file == cps_launcher: cmd += ['--entitlements',str(cps_ent)]
            subprocess.run(cmd+[str(file)], check=True)
    info['files'] = {file.relative_to(target).as_posix():hashlib.sha256(file.read_bytes()).hexdigest()
        for file in sorted(target.rglob('*')) if file.is_file() and file.name != 'manifest.json'}
    (target/'manifest.json').write_text(json.dumps(info, indent=2))
