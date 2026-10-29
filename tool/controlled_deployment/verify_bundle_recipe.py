"""Adversarial offline tests of native snapshots; mutates only marked test data."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

import bundle_recovery as b
import native_recipe as n
import recovery as r

ap = argparse.ArgumentParser()
ap.add_argument('--output', type=Path, required=True)
args = ap.parse_args()
out = args.output
root = out/'abak-maintenance-bundle-1'
pin = (out/'snapshot-sha256.txt').read_text().strip()
seed = root/('seed-retired' if (root/'seed-retired').exists() else 'seed')
checks = []
def check(ok, label):
    if not ok:
        raise AssertionError(label)
    checks.append(label)
def refused(action, label):
    try:
        action()
    except (ValueError, FileNotFoundError, subprocess.CalledProcessError):
        check(True, label)
    else:
        raise AssertionError(label)
    check(not (root/'forbidden').exists(), label+' : aucune génération publiée')
source, manifest = b.verify(root, 'snapshot', pin)
payload = source/'payload'
restored = root/'restored'
check(b.inventory(restored) == manifest['entries'], 'Tous fichiers, liens, modes, ACL et attributs restaurés identiques')
check(b.signature(restored/b.APP) == manifest['signature'], 'Signature native inchangée après restauration sans nouvelle signature')
check(b.signature(restored/'Companion-candidate.app') == b.signature(seed/'Companion-candidate.app'), 'Signature de la candidate métier complète préservée')
check(n.files(restored/'Companion-candidate.app') == n.files(out/'candidate-13/Companion-candidate.app'), 'Candidate métier complète strictement identique à la compilation')
check(b.metadata(restored/'fixtures/document.pdf')['acl'] is not None, 'ACL synthétique réellement conservée')
check('care.abak.recipe' in b.metadata(restored/'fixtures/document.pdf')['xattrs'], 'Attribut étendu synthétique réellement conservé')
check(any(v['kind']=='link' for v in manifest['entries'].values()), 'Liens internes des frameworks réellement inclus')
check(r.database_state(restored/'active') == r.database_state(seed/'active'), 'Base synthétique restaurée intacte et même schéma')
refused(lambda: b.restore(root,'snapshot',pin,'restored'), 'Destination existante refusée')
refused(lambda: b.restore(root,'snapshot',pin,'../escape'), 'Destination sortante refusée')
refused(lambda: b.restore(root,'snapshot','0'*64,'forbidden'), 'Empreinte de manifeste incorrecte refusée')
manifest_file = source/'manifest.json'
original_manifest = manifest_file.read_bytes()
manifest_file.write_bytes(original_manifest+b' ')
try:
    refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), 'Manifeste altéré refusé')
finally:
    manifest_file.write_bytes(original_manifest)
target = payload/'fixtures/document.pdf'
data = target.read_bytes()
target.write_bytes(data+b'corruption')
try:
    refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), 'PDF durable corrompu refusé')
finally:
    target.write_bytes(data)
missing = payload/'fixtures/document.xml'
saved = missing.with_suffix('.absent')
missing.rename(saved)
try:
    refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), 'Ressource durable manquante refusée')
finally:
    saved.rename(missing)
extra = payload/'unexpected.txt'
extra.write_text('synthetic-only')
try:
    refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), 'Fichier ajouté à la sauvegarde refusé')
finally:
    extra.unlink()
java = payload/'resources/java/bin/java'
mode = java.stat().st_mode & 0o7777
java.chmod(mode & ~0o111)
try:
    refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), 'Droit exécutable Java perdu refusé')
finally:
    java.chmod(mode)
link = payload/'unsafe-link'
for value, label in [('/etc/hosts','Lien absolu'), ('../../seed/fixtures/document.pdf','Lien sortant'), ('unsafe-link','Lien circulaire')]:
    link.symlink_to(value)
    try:
        refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), label+' refusé')
    finally:
        link.unlink()
binary = payload/b.APP/'Contents/Resources/AppIcon.icns'
original = binary.read_bytes()
binary.write_bytes(original+b'corruption')
try:
    refused(lambda: b.signature(payload/b.APP), 'Signature native invalide détectée')
    refused(lambda: b.restore(root,'snapshot',pin,'forbidden'), 'Bundle signé altéré refusé avant restauration')
finally:
    binary.write_bytes(original)
def interrupted():
    raise ValueError('Interruption synthétique avant publication')
refused(lambda: b.restore(root,'snapshot',pin,'forbidden',before_commit=interrupted), 'Interruption après copie complète avant publication')
check(any(root.glob('.bundle-restore-*')), 'Copie interrompue reste identifiée comme partielle')
# Native entry will use an active directory restored from the coherent payload.
if not (root/'active').exists():
    shutil.copytree(restored/'active', root/'active')
else:
    check(r.inventory(root/'active') == r.inventory(restored/'active'), 'Données actives synthétiques toujours identiques')
with r.locked(root):
    script = "import sys;from pathlib import Path;sys.path.insert(0,sys.argv[1]);import bundle_recovery as b;b.restore(Path(sys.argv[2]),'snapshot',sys.argv[3],'forbidden')"
    result = subprocess.run([sys.executable,'-c',script,str(Path(__file__).parent.resolve()),str(root),pin],capture_output=True,text=True)
    check(result.returncode != 0 and 'BlockingIOError' in result.stderr, 'Restauration concurrente bloquée par le verrou interprocessus')
command = n.prepare(restored/b.APP,root)
check(command[-1]=='--abak-bundle-resources', 'Lanceur exige le mode ressources isolé')
check(n.entitlements(restored/b.APP) == n.ENTITLEMENTS, 'Droits réseau, CPS et micro absents de la copie exécutable')
refused(lambda: n.prepare(restored/'Companion-candidate.app',root), 'Lanceur refuse la candidate métier avec identité utilisateur')
check(b.verify(root,'snapshot',pin)[1] == manifest, 'Sauvegarde intacte après tous les essais négatifs')
check(b.inventory(restored) == manifest['entries'], 'Restauration intacte après tous les essais négatifs')
r.durable_json(out/'bundle-tests.json', {'passed':True, 'assertions':len(checks), 'checks':checks,
              'entries':len(manifest['entries']), 'files':sum(v['kind']=='file' for v in manifest['entries'].values()),
              'links':sum(v['kind']=='link' for v in manifest['entries'].values()), 'manifestSha256':pin})
r.durable_json(out/'active-before.json', r.inventory(root/'active'))
print(json.dumps({'passed':True,'assertions':len(checks)},ensure_ascii=False))
