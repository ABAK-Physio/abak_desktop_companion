"""Only the user-approved DOCX/PDF conversion recipe; no user data or install."""
from pathlib import Path
import os, plistlib, subprocess, sys, zipfile
repo=Path(__file__).resolve().parents[2]
out=Path(sys.argv[1]); out.mkdir(parents=True,exist_ok=False)
(out/'derived').mkdir(); (out/'fixtures').mkdir()
app=out/'DocxRecipe.app'; (app/'Contents/MacOS').mkdir(parents=True)
host='fr.abakphysio.docx.recipe'
identity='Apple Development: Jean-Calude Brucher (62JVW4B29K)'
(app/'Contents/Info.plist').write_bytes(plistlib.dumps({
 'CFBundleIdentifier':host,'CFBundleExecutable':'DocxRecipe','CFBundlePackageType':'APPL',
 'CFBundleVersion':'1','LSUIElement':True,'LSMinimumSystemVersion':'13.0'}))
subprocess.run(['/usr/bin/xcrun','swiftc','-target','arm64-apple-macos13.0',
 str(repo/'macos/DocumentControls/Protocol.swift'),str(repo/'tool/docx_pdf_product/native_host.swift'),
 '-o',str(app/'Contents/MacOS/DocxRecipe')],check=True)
env={**os.environ,'EXPANDED_CODE_SIGN_IDENTITY':identity,'DEVELOPMENT_TEAM':'LP84QVHHSV',
 'PRODUCT_BUNDLE_IDENTIFIER':host,'TARGET_BUILD_DIR':str(out),'FULL_PRODUCT_NAME':app.name,
 'DERIVED_FILE_DIR':str(out/'derived'),'ARCHS':'arm64'}
subprocess.run(['/usr/bin/python3',str(repo/'scripts/macos/build_document_controls.py')],env=env,check=True)
subprocess.run(['/usr/bin/codesign','--force','--sign',identity,'--options','runtime','--timestamp=none',str(app)],check=True)
source=Path(sys.argv[2])
for name in ['rapport','modifie','vide']:
 with zipfile.ZipFile(source) as z, zipfile.ZipFile(out/'fixtures'/f'{name}.docx','w',zipfile.ZIP_DEFLATED) as w:
  for item in z.infolist():
   data=z.read(item)
   if item.filename=='word/document.xml':
    text=data.decode().replace('SIM-A','SYNTHETIQUE').replace('SYNTHETIQUE SYNTHETIQUE','SYNTHETIQUE Patient').replace('Texte du rapport','Amélioration fictive de la marche : distance de 100 mètres sans pause. Objectif : 150 mètres.')
    if name=='modifie': text=text.replace('100 mètres','120 mètres')
    if name=='vide': text='<?xml version="1.0"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p/></w:body></w:document>'
    data=text.encode()
   w.writestr(item,data)
print(out)
