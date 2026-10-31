"""Verify private PDF/A tools in a signed distribution without launching Companion."""
import json
import os
from pathlib import Path
import plistlib
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

from sign_distribution_tools import inventory


def main():
    app = Path(sys.argv[1]).resolve()
    root = app / 'Contents/Resources/DmpTools/arm64'
    info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
    assert info['CFBundleIdentifier'] == 'fr.abakphysio.abakdesktopcompanion', 'Local build cannot be distributed'
    assert info['LSMinimumSystemVersion'] == '13.0'
    executable = app / 'Contents/MacOS' / info['CFBundleExecutable']
    assert subprocess.check_output(['lipo', '-archs', str(executable)], text=True).strip() == 'arm64'
    manifest = json.loads((root / 'manifest.json').read_text())
    assert manifest['files'] == inventory(root), 'Private tools integrity mismatch'
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
    results = {}
    with tempfile.TemporaryDirectory(prefix='abak-distribution-check-') as tmp:
        # Ignore the developer's Java, preferences and environment. No networking.
        env = {'PATH': '/usr/bin:/bin', 'HOME': tmp, 'TMPDIR': tmp, 'JAVA_HOME': '/nonexistent'}
        command = ['/usr/bin/sandbox-exec', '-p', '(version 1)(allow default)(deny network*)', str(root / 'java/bin/java')]
        java = subprocess.run(command + ['-version'], env=env, cwd=tmp, capture_output=True, text=True, check=True)
        results['java'] = java.stderr.strip()
        for name, compliant in [('positif_pdf.pdf', True), ('sans_xmp_pdf.pdf', False)]:
            pdf = app / 'Contents/Frameworks/App.framework/Resources/flutter_assets/assets/dmp_local/pdf_cda_native' / name
            result = subprocess.run(command + ['-cp', str(root / 'vera/cli.jar'), 'org.verapdf.apps.GreenfieldCliWrapper',
                                               '--format', 'xml', '--flavour', '1b', str(pdf)],
                                    env=env, cwd=tmp, capture_output=True, text=True, timeout=60)
            reports = [e for e in ET.fromstring(result.stdout).iter() if e.tag.endswith('validationReport')]
            assert len(reports) == 1 and reports[0].get('isCompliant') == str(compliant).lower(), name
            assert result.returncode == (0 if compliant else 1), name
            results[name] = {'isCompliant': compliant, 'exitCode': result.returncode}
    results.update(version=info['CFBundleShortVersionString'], build=info['CFBundleVersion'],
                   architecture='arm64', minimumMacOS='13.0', manifestFiles=len(manifest['files']),
                   installed=False, applicationLaunched=False)
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    main()
