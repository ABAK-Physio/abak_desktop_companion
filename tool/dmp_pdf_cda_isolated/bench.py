"""Offline synthetic-only PDF/CDA bench. No transport or patient repository.

PDF/A results are bound to bytes. Simulation evidence can never establish
real conformity. Run only via verify_offline.sh (OS network prohibition).
"""
from pathlib import Path
import base64
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
from lxml import etree as E
from PIL import Image

NS = {'c': 'urn:hl7-org:v3'}
FMT = 'urn:ihe:iti:xds-sd:pdf:2008'
PROFILES = ['structurationMinimale/ASIP-STRUCT-MIN-StrucMin', 'IHE',
            'CI-SIS_ModelesDeContenusCDA', 'CI-SIS_Modeles_ANS',
            'terminologies/schematron/terminologie']
MARKER = 'ABAK-PDF-CDA-SYNTHETIQUE-1'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def write_json(path, value):
    path = Path(path)
    temp = path.with_suffix('.new')
    with temp.open('w') as f:
        json.dump(value, f, ensure_ascii=False, indent=2)
        f.flush()
        os.fsync(f.fileno())
    os.replace(temp, path)
    fd = os.open(path.parent, os.O_RDONLY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def run(args, timeout=120):
    return subprocess.run(args, capture_output=True, text=True, timeout=timeout)


def parse_xml(data):
    # Also handles UTF-16/32: inspect the parsed doctype before evaluating any
    # schema/XSLT. The initial parser never resolves entities or loads a DTD.
    root = E.fromstring(data, E.XMLParser(no_network=True, resolve_entities=False,
                                        load_dtd=False, huge_tree=False))
    if root.getroottree().docinfo.doctype or any(isinstance(x, E._Entity) for x in root.iter()):
        raise ValueError('DTD ou entité interdite')
    return root


def evidence(data, status, simulated=False, **extra):
    return dict(sha256=digest(data), status=status, simulated=simulated, **extra)


def interpret_verapdf(data, report, returncode, expected_profile=None, expected_path=None):
    """Single-file veraPDF report: nonconformity is not execution failure.

    Accept only coherent completed reports (0/conformant, 1/nonconformant).
    Missing, contradictory, interrupted or failed jobs remain unverified.
    """
    kind = 'rapport_invalide'
    extra = dict(returncode=returncode, reportSha256=digest(report))
    try:
        root = parse_xml(report)
        jobs = root.findall('jobs/job')
        summaries = root.findall('batchSummary')
        if root.tag != 'report' or len(jobs) != 1 or len(summaries) != 1:
            raise ValueError('Rapport incomplet ou nombre de documents inattendu')
        job, summary = jobs[0], summaries[0]
        def number(node, key):
            value = node.get(key) if node is not None else None
            if value is None or not re.fullmatch(r'[0-9]+', value):
                raise ValueError('Compteur absent ou invalide : '+key)
            return int(value)
        if number(summary, 'totalJobs') != 1:
            raise ValueError('Nombre de documents incohérent')
        counters = {k:number(summary,k) for k in ['failedToParse','encrypted','outOfMemory','veraExceptions']}
        extra['batchSummary'] = counters
        item = job.find('item')
        names = job.findall('item/name')
        if len(job.findall('item')) != 1 or len(names) != 1 or not names[0].text:
            raise ValueError('Fichier du rapport absent ou ambigu')
        if number(item,'size') != len(data):
            raise ValueError('Taille du fichier non corrélée')
        if expected_path is not None and names[0].text != str(expected_path):
            raise ValueError('Fichier du rapport non corrélé')
        extra['item'] = names[0].text
        totals = summary.findall('validationReports')
        if len(totals) != 1:
            raise ValueError('Bilan des validations absent ou ambigu')
        counts = {k:number(totals[0],k) for k in ['compliant','nonCompliant','failedJobs']}
        if sum(counts.values()) != 1 or (totals[0].text or '').strip() != '1':
            raise ValueError('Bilan des validations incohérent')
        exceptions = [n for n in root.iter() if n.tag in ('exception','taskException')]
        if any(counters.values()) or counts['failedJobs'] or exceptions:
            kind = 'document_chiffre' if counters['encrypted'] else ('document_illisible' if counters['failedToParse'] else 'erreur_execution')
            raise ValueError('Validation non aboutie : '+kind)
        validations = job.findall('validationReport')
        if len(validations) != 1 or len(root.findall('.//validationReport')) != 1:
            raise ValueError('Verdict absent ou ambigu')
        validation = validations[0]
        profile = validation.get('profileName', '')
        match = re.fullmatch(r'PDF/A-(1[ab]) validation profile',profile)
        if not match or (expected_profile is not None and match[1] != expected_profile):
            raise ValueError('Profil PDF/A-1 inattendu')
        extra['profile'] = profile
        if validation.get('jobEndStatus') != 'normal':
            kind = 'erreur_execution'
            raise ValueError('Validation interrompue ou état final absent')
        compliant = validation.get('isCompliant')
        details = validation.findall('details')
        if len(details) != 1 or compliant not in ('true','false'):
            raise ValueError('Verdict ou détails incomplets')
        numbers = {k:number(details[0],k) for k in ['passedRules','failedRules','passedChecks','failedChecks']}
        extra['details'] = numbers
        positive = compliant == 'true'
        if (positive and (numbers['failedRules'] or numbers['failedChecks'])) or (not positive and (numbers['failedRules'] == 0 or numbers['failedChecks'] == 0)):
            raise ValueError('Verdict et détails contradictoires')
        if positive and details[0].findall(".//*[@status='failed']"):
            raise ValueError('Verdict positif avec défauts détaillés')
        if counts != dict(compliant=int(positive),nonCompliant=int(not positive),failedJobs=0):
            raise ValueError('Verdict et bilan contradictoires')
        if returncode != (0 if positive else 1):
            kind = 'erreur_execution'
            raise ValueError('Code de sortie incompatible avec le verdict')
        return evidence(data, 'conforme' if positive else 'refuse',
                        kind='conformite' if positive else 'non_conformite', **extra)
    except Exception as exc:
        return evidence(data, 'non_verifie', kind=kind, reason=str(exc), **extra)


def validate_pdfa(pdf, validator, destination):
    data = pdf.read_bytes()
    if not validator:
        return evidence(data, 'non_verifie', reason='Validateur PDF/A absent')
    try:
        # 1b is the bench's explicit candidate, not a claim of profile approval.
        cp = run([validator, '--format', 'xml', '--flavour', '1b', str(pdf)])
        (destination / 'verapdf.xml').write_text(cp.stdout)
        (destination / 'verapdf.stderr').write_text(cp.stderr)
        return interpret_verapdf(data, cp.stdout.encode(), cp.returncode, expected_profile="1b", expected_path=pdf)
    except Exception as exc:
        return evidence(data, 'non_verifie', reason=str(exc))


def inspect_pdf(pdf, dest, poppler):
    for name, args in [('pdfinfo', [str(pdf)]), ('pdftotext', [str(pdf), '-'])]:
        cp = run([str(poppler / name), *args])
        if cp.returncode or 'Syntax Error' in cp.stderr:
            raise ValueError('PDF illisible ou endommagé')
        if name == 'pdfinfo':
            if not re.search(r'Encrypted:\s+no', cp.stdout):
                raise ValueError('PDF chiffré')
            match = re.search(r'Pages:\s+(\d+)', cp.stdout)
            if not match or not 1 <= int(match[1]) <= 40:
                raise ValueError('Nombre de pages interdit')
            pages = int(match[1])
    cp = run([str(poppler/'pdftoppm'), '-gray', '-scale-to', '400', str(pdf), str(dest/'page')])
    images = sorted(dest.glob('page-*.pgm'))
    if cp.returncode or len(images) != pages:
        raise ValueError('Rendu incomplet')
    white = all(Image.open(p).getextrema() == (255, 255) for p in images)
    return dict(pages=pages, allWhite=white)


def cda_checks(xml, pdf, context, metadata):
    errors = []
    try:
        root = parse_xml(xml)
        if root.tag != '{urn:hl7-org:v3}ClinicalDocument':
            raise ValueError('Racine CDA absente')
        body = root.findall('c:component/c:nonXMLBody/c:text', NS)
        if len(body) != 1 or body[0].get('representation') != 'B64':
            raise ValueError('Un unique PDF B64 requis')
        text = body[0]
        if text.get('mediaType') != 'application/pdf' or metadata.get('formatCode') != FMT:
            errors.append('MIME/formatCode incohérent')
        payload = base64.b64decode(re.sub(r'\s', '', text.text or ''), validate=True)
        if payload != pdf:
            errors.append('PDF encapsulé différent de la copie figée')
        paths = {
            'patient': 'c:recordTarget/c:patientRole/c:id/@extension',
            'author': 'c:author/c:assignedAuthor/c:id/@extension',
            'structure': 'c:custodian/c:assignedCustodian/c:representedCustodianOrganization/c:id/@extension',
            'title': 'c:title/text()', 'date': 'c:effectiveTime/@value',
            'confidentiality': 'c:confidentialityCode/@code', 'type': 'c:code/@code',
            'id': 'c:id/@root', 'setId': 'c:setId/@root', 'version': 'c:versionNumber/@value'}
        for key, xpath in paths.items():
            values = root.xpath(xpath, namespaces=NS)
            expected = context.get(key)
            if not expected or values != [expected] or metadata.get(key) != expected:
                errors.append('Contexte/métadonnées incohérents : '+key)
        if metadata.get('class') != context.get('class'):
            errors.append('Classe incohérente')
    except Exception as exc:
        errors.append(str(exc))
    return errors


class CdaValidator:
    def __init__(self, resources, java, out):
        self.resources, self.java, self.out = Path(resources), java, Path(out)
        self.compiled = {}

    def transform(self, source, style, target):
        cp = run([self.java, '-cp', str(self.resources/'schematrons/moteur/saxon9he.jar'),
                  'net.sf.saxon.Transform', '-dtd:off', '-s:'+str(source),
                  '-xsl:'+str(style), '-o:'+str(target)])
        target.with_suffix(target.suffix+'.log').write_text(cp.stdout+'\n'+cp.stderr)
        if cp.returncode or not target.exists():
            raise ValueError('Échec Saxon : '+cp.stderr[-800:])

    def validate(self, xml, label):
        target = self.out/label
        target.mkdir()
        source = target/'document.xml'
        source.write_bytes(xml)
        result = evidence(xml, 'non_verifie', profiles={}, xsd=None)
        try:
            root = parse_xml(xml)
            schema = E.XMLSchema(E.parse(str(self.resources/'infrastructure/cda/CDA_extended.xsd'),
                                         E.XMLParser(no_network=True, resolve_entities=False)))
            result['xsd'] = schema.validate(root)
            result['xsdErrors'] = [str(e) for e in schema.error_log]
            for name in PROFILES:
                if name not in self.compiled:
                    src = self.resources/'schematrons/profils'/(name+'.sch')
                    for suffix, engine in [('included', 'iso_dsdl_include'),
                                           ('expanded', 'iso_abstract_expand'), ('compiled', 'iso_svrl_for_xslt2')]:
                        dest = src.parent/(src.stem+'.bench-'+suffix+'.xsl')
                        self.transform(src, self.resources/'schematrons/moteur'/(engine+'.xsl'), dest)
                        src = dest
                    self.compiled[name] = src
                svrl = target/(Path(name).name+'.svrl.xml')
                self.transform(source, self.compiled[name], svrl)
                report = parse_xml(svrl.read_bytes())
                ns = {'s': 'http://purl.oclc.org/dsdl/svrl'}
                if report.tag != '{http://purl.oclc.org/dsdl/svrl}schematron-output' or not report.findall('.//s:active-pattern', ns):
                    raise ValueError('Rapport SVRL incomplet')
                result['profiles'][name] = {tag: [dict(location=x.get('location'), role=x.get('role'),
                     text=' '.join(''.join(x.itertext()).split())) for x in report.findall('.//s:'+tag, ns)]
                     for tag in ['failed-assert', 'successful-report']}
            result['status'] = 'conforme' if result['xsd'] and all(not x['failed-assert'] for x in result['profiles'].values()) else 'refuse'
        except Exception as exc:
            result['reason'] = str(exc)
        write_json(target/'resultat.json', result)
        return result


class Bench:
    def __init__(self, root):
        self.root = Path(root)
        if self.root.is_symlink() or not self.root.name.startswith('pdf-cda-isole-'):
            raise ValueError('Stockage isolé requis')
        if (self.root/'scope').read_text() != MARKER:
            raise ValueError('Marqueur synthétique requis')
        if any(p.is_symlink() for p in self.root.rglob('*')):
            raise ValueError('Liens interdits')
        self.state = json.loads((self.root/'journal.json').read_text())

    @classmethod
    def create(cls, parent):
        root = Path(tempfile.mkdtemp(prefix='pdf-cda-isole-', dir=parent))
        (root/'scope').write_text(MARKER)
        write_json(root/'journal.json', dict(held=True, calls=0, approved=None, current=None, history=[]))
        return cls(root)

    def save(self):
        write_json(self.root/'journal.json', self.state)

    def load(self, data, context, poppler):
        if any(not context.get(k, '').startswith('SIM-') for k in ['patient', 'author', 'structure']):
            raise ValueError('Contexte synthétique requis')
        self.state.update(approved=None, current=None, held=True)
        self.save()
        dest = self.root/digest(data)
        dest.mkdir(exist_ok=True)
        pdf = dest/'document.pdf'
        pdf.write_bytes(data)
        try:
            inspection = inspect_pdf(pdf, dest, poppler)
            self.state['current'] = dict(hash=digest(data), context=json.loads(json.dumps(context)), inspection=inspection, status='non_verifie')
        except Exception as exc:
            self.state['error'] = str(exc)
            self.save()
            raise
        self.save()

    def review(self, clinical, patient, pages):
        c = self.state['current']
        if not c or c['inspection']['allWhite'] or not clinical or not patient or pages != list(range(1, c['inspection']['pages']+1)):
            raise ValueError('Revue clinique incomplète ou document blanc')
        if digest(self.pdf()) != c['hash']:
            raise ValueError('Copie figée altérée')
        self.state['approved'] = digest(json.dumps(c['context'], sort_keys=True).encode()+self.pdf())
        self.save()

    def pdf(self):
        return (self.root/self.state['current']['hash']/'document.pdf').read_bytes()

    def evaluate(self, xml, metadata, pdf_report, cda_report):
        c = self.state['current']
        pdf = self.pdf()
        errors = cda_checks(xml, pdf, c['context'], metadata)
        if digest(pdf) != c['hash']:
            errors.append('Copie figée altérée')
        expected = digest(json.dumps(c['context'], sort_keys=True).encode()+pdf)
        if self.state['approved'] != expected:
            errors.append('Nouvelle validation clinique requise')
        for data, report in [(pdf, pdf_report), (xml, cda_report)]:
            if report.get('sha256') != digest(data):
                errors.append('Rapport non corrélé aux octets')
        previous = [x for x in self.state['history'] if x['id'] == c['context']['id'] and x['pdf'] != c['hash']]
        if previous:
            errors.append('Identifiant documentaire réutilisé pour un contenu différent')
        statuses = [r.get('status', 'non_verifie') for r in [pdf_report, cda_report]]
        if errors or 'refuse' in statuses:
            status = 'refuse'
        elif statuses != ['conforme', 'conforme']:
            status = 'non_verifie'
        else:
            status = 'simulation_conforme' if pdf_report.get('simulated') or cda_report.get('simulated') else 'controles_techniques_conformes'
        c.update(status=status, errors=errors, pdfReport=pdf_report, cdaReport=cda_report, cdaHash=digest(xml))
        self.state['held'] = True  # Bench has no release or transport function.
        self.state['history'].append(dict(id=c['context']['id'], pdf=c['hash'], cda=digest(xml), status=status))
        self.save()
        return status
