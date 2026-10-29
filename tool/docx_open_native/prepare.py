from pathlib import Path
import argparse, plistlib, zipfile, subprocess, json
parser = argparse.ArgumentParser(description='Prepare synthetic native DOCX opener smoke test; no launch or install.')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = args.output
if not root.is_absolute() or root.exists():
 raise ValueError('A fresh absolute output directory is required')
root.mkdir(parents=True)
repo = Path(__file__).resolve().parents[2]
s=(repo/'macos/Runner/MainFlutterWindow.swift').read_text()
body=s.split('      case "openDocx":',1)[1].split('      case "chooseDirectory":',1)[0]
source='''import Cocoa
func FlutterError(code: String, message: String?, details: Any?) -> String { code + ": " + (message ?? "") }
final class Delegate: NSObject, NSApplicationDelegate {
 var window: NSWindow!
 var label: NSTextField!
 func applicationDidFinishLaunching(_ notification: Notification) {
  window = NSWindow(contentRect: NSRect(x: 0,y: 0,width: 650,height: 200), styleMask: [.titled,.closable], backing: .buffered, defer: false)
  window.title = "ABAK — Test ouverture DOCX synthétique"
  label = NSTextField(labelWithString: "Test du code natif Companion, données synthétiques uniquement.")
  label.frame = NSRect(x:20,y:110,width:610,height:60)
  window.contentView!.addSubview(label)
  let button = NSButton(title: "Choisir le DOCX synthétique", target:self, action:#selector(choose))
  button.frame = NSRect(x:20,y:30,width:400,height:50)
  window.contentView!.addSubview(button)
  window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps:true)
 }
 @objc func choose() {
  let panel = NSOpenPanel(); panel.canChooseFiles=true; panel.canChooseDirectories=false
  panel.directoryURL=URL(fileURLWithPath:"/private/tmp/abak-docx-open-smoke-20261021")
  guard panel.runModal() == .OK, let url=panel.url else { return }
  let args: [String:Any] = ["path":url.path]
  let result: (Any?) -> Void = { value in self.label.stringValue = value == nil ? "SUCCÈS : document transmis à l’application par défaut." : String(describing:value!) }
  do {
'''+body+'''
  } catch { result(error.localizedDescription) }
 }
}
let app=NSApplication.shared
let delegate=Delegate()
app.delegate=delegate
app.setActivationPolicy(.regular)
app.run()
'''
source = source.replace('\"/private/tmp/abak-docx-open-smoke-20261021\"', json.dumps(str(root)))
(root/'main.swift').write_text(source)
app=root/'ABAK DOCX Test.app'
(app/'Contents/MacOS').mkdir(parents=True)
(app/'Contents/Info.plist').write_bytes(plistlib.dumps({'CFBundleIdentifier':'fr.abakphysio.docx.open.smoke20261021','CFBundleExecutable':'test','CFBundleName':'ABAK DOCX Test','CFBundlePackageType':'APPL'}))
(root/'entitlements.plist').write_bytes(plistlib.dumps({'com.apple.security.app-sandbox':True,'com.apple.security.files.user-selected.read-write':True}))
p=root/'Rapport synthétique.docx'
with zipfile.ZipFile(p,'w') as z:
 z.writestr('[Content_Types].xml','''<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>''')
 z.writestr('_rels/.rels','''<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>''')
 z.writestr('word/document.xml','''<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>ABAK — TEST SYNTHETIQUE OUVERTURE DOCX. Aucun patient réel.</w:t></w:r></w:p></w:body></w:document>''')
subprocess.run(['xattr','-w','com.apple.quarantine','0082;6ad513cf;abak_desktop_companion;',str(p)],check=True)

# An additional synthetic fixture reproduces a Finder per-file association.
libre = root/'Rapport LibreOffice.docx'
libre.write_bytes(p.read_bytes())
association = plistlib.dumps({'version':0, 'path':'/Applications/LibreOffice.app', 'bundleidentifier':'org.libreoffice.script'}, fmt=plistlib.FMT_BINARY).hex()
subprocess.run(['xattr','-wx','com.apple.LaunchServices.OpenWith',association,str(libre)],check=True)
subprocess.run(['xattr','-w','com.apple.quarantine','0082;6ad513cf;abak_desktop_companion;',str(libre)],check=True)
print(root)
