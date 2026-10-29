"""Xcode build phase: compile/embed/sign the offline XPC validator service."""
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
    raise SystemExit('Service PDF/A-CDA : signature et identité explicites requises')
app=Path(env['TARGET_BUILD_DIR'])/env['FULL_PRODUCT_NAME']
service=app/'Contents/XPCServices/AbakDocumentControls.xpc'
source=repo/'macos/DocumentControls'
if service.exists(): shutil.rmtree(service)
(service/'Contents/MacOS').mkdir(parents=True)
(service/'Contents/Resources').mkdir()
info={'CFBundleIdentifier':'fr.abakphysio.documentcontrols','CFBundleName':'AbakDocumentControls',
      'CFBundleExecutable':'AbakDocumentControls','CFBundlePackageType':'XPC!',
      'CFBundleVersion':'1','CFBundleShortVersionString':'1.0','LSMinimumSystemVersion':'13.0',
      'XPCService':{'ServiceType':'Application','RunLoopType':'dispatch_main','JoinExistingSession':True},
      'ABAKHostRequirement':f'anchor apple generic and identifier "{host}" and certificate leaf[subject.OU] = "{team}"'}
(service/'Contents/Info.plist').write_bytes(plistlib.dumps(info))
shutil.copy2(repo/'assets/document_controls/CdaCheck.java',service/'Contents/Resources/CdaCheck.java')
with tempfile.TemporaryDirectory(prefix='abak-controls-build-',dir=env['DERIVED_FILE_DIR']) as temp:
    parts=[]
    for arch in env.get('ARCHS','arm64 x86_64').split():
        if arch not in ['arm64','x86_64']: raise ValueError('Architecture inconnue')
        obj=Path(temp)/(arch+'.o');binary=Path(temp)/arch
        target=arch+'-apple-macos13.0'
        subprocess.run(['/usr/bin/xcrun','clang','-target',target,'-c',str(source/'Sandbox.c'),'-o',str(obj)],check=True)
        subprocess.run(['/usr/bin/xcrun','swiftc','-O','-target',target,'-import-objc-header',str(source/'Sandbox.h'),str(source/'Protocol.swift'),str(source/'DocxConversion.swift'),str(source/'main.swift'),str(obj),'-o',str(binary)],check=True)
        parts.append(str(binary))
    subprocess.run(['/usr/bin/lipo','-create',*parts,'-output',str(service/'Contents/MacOS/AbakDocumentControls')],check=True)
subprocess.run(['/usr/bin/codesign','--force','--sign',identity,'--options','runtime','--timestamp=none',str(service)],check=True)
subprocess.run(['/usr/bin/codesign','--verify','--strict',str(service)],check=True)

# Private Java/veraPDF resources are part of the enclosing signed application.
subprocess.run(['/usr/bin/python3', str(repo/'scripts/macos/embed_dmp_tools.py')], check=True)

# Separate signed launcher; do not mix browser access with offline validation.
subprocess.run(['/usr/bin/python3', str(repo/'scripts/macos/build_webps_browser.py')], check=True)
