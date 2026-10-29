"""Embed the signed, narrowly scoped Web-PS Firefox launcher XPC service."""
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import tempfile

repo=Path(__file__).resolve().parents[2]
env=os.environ
identity=env.get('EXPANDED_CODE_SIGN_IDENTITY','')
team=env.get('DEVELOPMENT_TEAM','')
host=env.get('PRODUCT_BUNDLE_IDENTIFIER','')
if not identity or not re.fullmatch('[A-Z0-9]{10}',team) or not re.fullmatch('[A-Za-z0-9.-]+',host):
    raise SystemExit('Service Web-PS : signature et identité explicites requises')
app=Path(env['TARGET_BUILD_DIR'])/env['FULL_PRODUCT_NAME']
service=app/'Contents/XPCServices/AbakWebPsBrowser.xpc'
source=repo/'macos/WebPsBrowser'
if service.exists(): shutil.rmtree(service)
(service/'Contents/MacOS').mkdir(parents=True)
(service/'Contents/Resources').mkdir()
info={'CFBundleIdentifier':'fr.abakphysio.webpsbrowser','CFBundleName':'AbakWebPsBrowser',
      'CFBundleExecutable':'AbakWebPsBrowser','CFBundlePackageType':'XPC!',
      'CFBundleVersion':'1','CFBundleShortVersionString':'1.0','LSMinimumSystemVersion':'13.0',
      # NSRunningApplication/NSWorkspace update their cached lifecycle state only
      # when the main NSRunLoop runs. dispatch_main leaves isTerminated stale.
      'XPCService':{'ServiceType':'Application','RunLoopType':'NSRunLoop','JoinExistingSession':True},
      'ABAKHostIdentifier':host,
      'ABAKHostRequirement':f'anchor apple generic and identifier "{host}" and certificate leaf[subject.OU] = "{team}"'}
(service/'Contents/Info.plist').write_bytes(plistlib.dumps(info))
with tempfile.TemporaryDirectory(prefix='abak-controls-build-',dir=env['DERIVED_FILE_DIR']) as temp:
    parts=[]
    for arch in env.get('ARCHS','arm64 x86_64').split():
        if arch not in ['arm64','x86_64']: raise ValueError('Architecture inconnue')
        binary=Path(temp)/arch
        target=arch+'-apple-macos13.0'
        subprocess.run(['/usr/bin/xcrun','swiftc','-O','-target',target,str(source/'BrowserController.swift'),str(source/'main.swift'),'-o',str(binary)],check=True)
        parts.append(str(binary))
    subprocess.run(['/usr/bin/lipo','-create',*parts,'-output',str(service/'Contents/MacOS/AbakWebPsBrowser')],check=True)
subprocess.run(['/usr/bin/codesign','--force','--sign',identity,'--options','runtime','--timestamp=none',str(service)],check=True)
subprocess.run(['/usr/bin/codesign','--verify','--strict',str(service)],check=True)

