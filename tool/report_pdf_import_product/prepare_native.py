"""Prepare a signed, uninstalled, sandboxed synthetic report-PDF recipe.
No network, smartcard or microphone entitlement. Does not launch the app.
"""
import argparse
import json
from pathlib import Path
import plistlib
import shutil
import subprocess
import uuid

repo = Path(__file__).resolve().parents[2]
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--candidate', type=Path, required=True)
ap.add_argument('--output', type=Path, required=True)
ap.add_argument('--references', type=Path, required=True)
a = ap.parse_args()
manifest = json.loads((a.candidate.parent/'manifest.json').read_text())
if manifest.get('status') != 'COMPILED_NOT_INSTALLED' or not manifest.get('reportPdfRecipeOnly'):
    raise ValueError('Signed recipe entry point required')
if a.output.exists() or a.output.parent.resolve() != a.output.parent:
    raise ValueError('Fresh output with canonical parent required')
subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(a.candidate)], check=True)
a.output.mkdir()
identifier = 'fr.abakphysio.reportpdf.recipe.' + uuid.uuid4().hex
app = a.output/'ABAK PDF Recipe.app'
subprocess.run(['/usr/bin/ditto', str(a.candidate), str(app)], check=True)
info_path = app/'Contents/Info.plist'
info = plistlib.loads(info_path.read_bytes())
info.update(CFBundleIdentifier=identifier, CFBundleDisplayName='ABAK — Recette PDF sans dépôt')
info_path.write_bytes(plistlib.dumps(info))
identity = 'Apple Development: Jean-Calude Brucher (62JVW4B29K)'
service = app/'Contents/XPCServices/AbakDocumentControls.xpc'
f = service/'Contents/Info.plist'
p = plistlib.loads(f.read_bytes())
p['ABAKHostRequirement'] = f'anchor apple generic and identifier "{identifier}" and certificate leaf[subject.OU] = "LP84QVHHSV"'
f.write_bytes(plistlib.dumps(p))
subprocess.run(['/usr/bin/codesign', '--force', '--sign', identity, '--options', 'runtime', '--timestamp=none', str(service)], check=True)
entitlements = {
    'com.apple.security.app-sandbox': True,
    'com.apple.security.files.user-selected.read-write': True,
    'com.apple.security.files.bookmarks.app-scope': True,
    'com.apple.security.cs.disable-library-validation': True,
    'com.apple.security.print': True,
}
ent = a.output/'recipe.entitlements'
ent.write_bytes(plistlib.dumps(entitlements))
subprocess.run(['/usr/bin/codesign', '--force', '--sign', identity, '--options', 'runtime', '--timestamp=none', '--entitlements', str(ent), str(app)], check=True)
subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(app)], check=True)
root = a.output/'synthetic'
root.mkdir()
(root/'SYNTHETIC-ONLY').write_text('ABAK-REPORT-PDF-RECIPE-1\n')
shutil.copy2(repo/'assets/dmp_local/pdf_cda_native/positif_pdf.pdf', root/'conforme.pdf')
shutil.copy2(repo/'assets/dmp_local/pdf_cda_native/sans_xmp_pdf.pdf', root/'ordinaire.pdf')
(root/'tools.json').write_text(json.dumps({
    'java': '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
    'vera': str(Path.home()/'verapdf/bin/cli-1.30.3.jar'),
    'references': str(a.references), 'label': 'Références CDA archivées — recette synthétique',
}))
(a.output/'recipe.json').write_text(json.dumps({'identity': identifier, 'app': str(app), 'root': str(root), 'entitlements': entitlements, 'installed': False, 'deposit': False}, indent=2))
print(app)
