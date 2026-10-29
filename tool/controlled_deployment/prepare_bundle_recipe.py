"""Assemble local archived resources and full compiled application in a synthetic kit."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import xml.etree.ElementTree as ET
import base64

import recovery as r
import native_recipe as native
import bundle_recovery as bundle

ap = argparse.ArgumentParser()
ap.add_argument('--project', type=Path, required=True)
args = ap.parse_args()
project = args.project
repo = Path(__file__).resolve().parents[2]
out = project/'output/recette-native-bundle'
root = out/'abak-maintenance-bundle-1'
root.mkdir()
(root/'SYNTHETIC-ONLY').write_text(r.MARKER)
candidate = out/'candidate-13/Companion-candidate.app'
seed = root/'seed'
native.create(candidate, seed, bundle_resources=True)
subprocess.run(['/usr/bin/ditto', '--rsrc', '--extattr', '--acl', str(candidate), str(seed/'Companion-candidate.app')], check=True)
if native.files(candidate) != native.files(seed/'Companion-candidate.app'):
    raise ValueError('Candidate complète non identique')
bundle.signature(seed/'Companion-candidate.app')
resources = seed/'resources'
resources.mkdir()
java = Path('/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home')
vera = Path.home()/'verapdf'
references = project/'output/preparation-identite-qualifiee/execution-finale/references'
for source, name in [(java, 'java'), (vera, 'verapdf')]:
    subprocess.run(['/usr/bin/ditto', '--rsrc', '--extattr', '--acl', str(source), str(resources/name)], check=True)
shutil.copytree(references, resources/'cda', ignore=shutil.ignore_patterns('.git', '.github', '*.bench-*', 'abak-*', 'unified-configuration.json'))
fixtures = seed/'fixtures'
fixtures.mkdir()
for source, name in [('temoin-pdfa1b.pdf', 'document.pdf'), ('temoin-cda.xml', 'document.xml')]:
    shutil.copy2(repo/'tool/dmp_pdf_cda_isolated/fixtures'/source, fixtures/name)
xml = ET.fromstring((fixtures/'document.xml').read_bytes())
embedded = xml.find('.//{urn:hl7-org:v3}nonXMLBody/{urn:hl7-org:v3}text')
if embedded is None or base64.b64decode(embedded.text) != (fixtures/'document.pdf').read_bytes():
    raise ValueError('Témoins PDF/CDA non identiques')
data = seed/'active'
data.mkdir()
prior = project/'output/recette-native-maintenance/abak-maintenance-native-1/active'
for name in ['support', 'documents']:
    shutil.copytree(prior/name, data/name)
r.database_state(data)
def tree(path):
    return {str(p.relative_to(path)):r.sha(p) for p in sorted(path.rglob('*')) if p.is_file()}
descriptor = {
    'format':'ABAK-DURABLE-RESOURCES-RECIPE-1',
    'label':'Ressources archivées — recette native isolée',
    'paths':{'java':'resources/java/bin/java', 'vera':'resources/verapdf/bin/cli-1.30.3.jar', 'references':'resources/cda'},
    'runtime':tree(resources/'java'), 'libraries':tree(resources/'verapdf/bin'), 'references':tree(resources/'cda'),
    'helper':r.sha(repo/'assets/document_controls/CdaCheck.java'),
    'fixtures':tree(fixtures),
    'provenance':{'java':str(java), 'verapdf':str(vera), 'cda':str(references),
                  'excludedFromCdaCopy':['.git','.github','*.bench-*','abak-*','unified-configuration.json'],
                  'originalConfigurationReused':False},
}
r.durable_json(seed/'resources.json', descriptor)
# Explicit synthetic metadata tests native ditto beyond file contents.
subprocess.run(['/usr/bin/xattr', '-w', 'care.abak.recipe', 'synthetic-only', str(fixtures/'document.pdf')], check=True)
subprocess.run(['/bin/chmod', '+a', 'everyone allow read', str(fixtures/'document.pdf')], check=True)
r.durable_json(out/'prepared.json', {'root':str(root), 'candidate':bundle.signature(candidate),
              'recipe':bundle.signature(seed/bundle.APP), 'database':r.database_state(data),
              'resourceCounts':{k:len(descriptor[k]) for k in ['runtime','libraries','references']},
              'syntheticOnly':True})
print('Kit synthétique complet préparé :', root)
