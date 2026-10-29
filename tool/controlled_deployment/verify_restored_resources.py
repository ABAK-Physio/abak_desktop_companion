"""Diagnostic CLI separate from Companion: real restored Java/veraPDF/CDA offline.

This does NOT certify launching these processes from macOS App Sandbox. Each
Java process gets exactly one network-denied, job-write-only Seatbelt profile.
"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import xml.etree.ElementTree as ET

import recovery as r

ap=argparse.ArgumentParser()
ap.add_argument('--output',type=Path,required=True)
args=ap.parse_args()
out=args.output
generation=out/'abak-maintenance-bundle-1/restored'
job=out/'restored-cli-checks'
job.mkdir()
descriptor=json.loads((generation/'resources.json').read_text())
paths={k:str(generation/v) for k,v in descriptor['paths'].items()}
shutil.copytree(paths['references'],job/'references')
for name in ['document.pdf','document.xml']:
    shutil.copy2(generation/'fixtures'/name,job/name)
helper=generation/'ABAK Maintenance Recipe.app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/document_controls/CdaCheck.java'
assert r.sha(helper)==descriptor['helper']
shutil.copy2(helper,job/'CdaCheck.java')
def quoted(path):
    return '"'+str(path).replace('\\','\\\\').replace('"','\\"')+'"'
profile='(version 1)(allow default)(deny network*)(deny file-write*)(allow file-write* (subpath '+quoted(job)+') (literal "/dev/null"))'
profile+='(deny file-read* (subpath "/usr/local/lib/libcps3_pkcs11_osx.dylib") (regex #"/Users/[^/]+/Library/(Containers|Group Containers)(/|$)"))'
# Deliberately forbid fallback to the original Java, veraPDF and CDA paths.
for source in descriptor['provenance'].values():
    if isinstance(source,str) and source.startswith('/'):
        profile+='(deny file-read* (subpath '+quoted(source)+'))'
(job/'isolation.sb').write_text(profile)
def run(arguments,name):
    command=['/usr/bin/sandbox-exec','-f',str(job/'isolation.sb'),paths['java'],
             '-Duser.home='+str(job),'-Djava.io.tmpdir='+str(job),*arguments]
    result=subprocess.run(command,cwd=job,env={'PATH':'/usr/bin:/bin','TMPDIR':str(job)},capture_output=True,timeout=240)
    (job/(name+'.stdout')).write_bytes(result.stdout)
    (job/(name+'.stderr')).write_bytes(result.stderr)
    (job/(name+'.json')).write_text(json.dumps({'command':command,'exitCode':result.returncode},indent=2))
    return result
pdf=run(['-cp',paths['vera'],'org.verapdf.apps.GreenfieldCliWrapper','--format','xml','--flavour','1b',str(job/'document.pdf')],'verapdf')
report=ET.fromstring(pdf.stdout)
validation=report.find('./jobs/job/validationReport')
assert pdf.returncode==0 and validation is not None and validation.get('isCompliant')=='true'
assert validation.get('profileName')=='PDF/A-1b validation profile' and validation.get('jobEndStatus')=='normal'
assert report.find('./jobs/job/item/name').text==str(job/'document.pdf')
assert report.find('./batchSummary').get('totalJobs')=='1'
assert report.find('./batchSummary/validationReports').get('compliant')=='1'
cda=run(['--class-path',str(job/'references/schematrons/moteur/saxon9he.jar'),str(job/'CdaCheck.java'),str(job/'references'),str(job)],'cda')
assert cda.returncode==0 and (job/'completed.txt').read_text()=='ABAK-CDA-1'
assert ET.parse(job/'xsd.xml').getroot().attrib=={'completed':'true','valid':'true'}
ns='{http://purl.oclc.org/dsdl/svrl}'
for index in range(5):
    xml=ET.parse(job/('profile-'+str(index)+'.xml')).getroot()
    assert xml.tag==ns+'schematron-output' and xml.findall('.//'+ns+'active-pattern')
    assert not xml.findall('.//'+ns+'failed-assert')
r.durable_json(job/'result.json',{'passed':True,'scope':'CLI séparée, pas le lancement depuis Companion',
               'pdfa':'conforme','cda':'conforme','xsd':True,'schematrons':5,
               'paths':paths,'originalPathsForbidden':True,'networkAllowed':False,'CPSUsed':False})
print('Ressources restaurées : PDF/A-1b, XSD et cinq schematrons conformes en CLI hors réseau.',flush=True)
