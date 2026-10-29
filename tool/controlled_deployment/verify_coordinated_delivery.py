"""Read-only final audit of the coordinated synthetic acceptance evidence."""
import argparse
import datetime
import json
from pathlib import Path
import bundle_recovery as b
import coordinated_recovery as c
import native_recipe as n
import recovery as r

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('output', type=Path)
out = ap.parse_args().output
root = out/'abak-maintenance-coordinated-1'
project_output = out.parent
checks = []
def check(value, label):
    if not value: raise AssertionError(label)
    checks.append(label)
def read(path): return json.loads(Path(path).read_text())
planfile = next(root.glob('coordinated-complete-*.json'))
plan = read(planfile)
pin = read(root/'plan-pin.json')['sha256']
check(r.sha(planfile) == pin, 'Plan durable inchangé jusqu’à la clôture')
check(not (root/c.PENDING).exists(), 'Retour terminé après reçu natif validé')
check(c.generation(root/'active') == plan['target'], 'Bundle signé, ressources, base, PDF et preuves restaurés exactement')
check(c.generation(root/plan['preserved']) == plan['before'], 'Génération récente conservée exactement')
check(b.verify(root,'snapshot',plan['archiveHash'])[1]['signature'] == plan['target']['signature'], 'Sauvegarde complète toujours authentifiée et signée')
check(r.database_state(root/'active') == plan['target']['database'], 'Base restaurée au schéma 36 sans migration automatique')
for path, label in [
    (root/'migrate.json', 'Migration réelle synthétique 36 vers 37'),
    (out/'abak-maintenance-journal-restored/journal.json', 'Retenue et indéterminé conservés, renvoi refusé après retour'),
    (out/'abak-maintenance-startup-guards/result.json', '14 gardes de démarrage et verrou'),
    (root/'coordinated-tests.json', '15 refus, interruptions et reprises'),
    (out/'native-guards.json', 'Gardes natives produit et recette, code 78'),
    (out/'restricted-preferences-path.json', 'Aucun chemin arbitraire de préférences accepté')]:
    check(read(path)['passed'], label)
counts = {}
for phase in ['seed','upgrade','blocked','recover','verify']:
    report = read(root/f'observations/{phase}.json')
    counts[phase] = len(report['checks'])
    check(report['passed'] and read(root/f'exit-{phase}.json')['exit'] == 0, 'Processus natif conforme et fermé : '+phase)
interrupted = read(root/'observations/interruption.json')
counts['interruption'] = len(interrupted['checks'])
check(interrupted['passed'] and read(root/'exit-restore-crash.json')['exit'] == 86, 'Interruption réelle après synchronisation native et avant reçu')
check('Reprise idempotente' in (root/'observations/recover.json').read_text(), 'Aucune deuxième restauration des préférences à la reprise')
candidate = out/'candidate-19/Companion-candidate.app'
check(n.files(candidate) == read(candidate.parent/'candidate-files.json'), 'Candidate complète compilée non modifiée et non installée')
check(b.signature(candidate)['build'] == '19', 'Signature stricte candidate 1.1.1+19 vérifiée')
check((candidate.parent/'pubspec.before').read_bytes() == Path('pubspec.yaml').read_bytes(), 'Configuration de dépendances restaurée après compilation')
baseline = read(project_output/'configuration-installation-controlee/Application_installee_SHA256.json')
expected = {e['path']: e for e in baseline['entries']}
actual = n.files(Path(baseline['root']))
check(set(expected) == set(actual) and all(
    actual[k].get('link') == v['symlink'] if 'symlink' in v else actual[k].get('sha256') == v['sha256']
    for k,v in expected.items()), '164 entrées de l’application installée inchangées')
check(r.sha('/usr/local/lib/libcps3_pkcs11_osx.dylib') == '2805958a32e38b590b218eae400ff12403c0cee764c287cbdf9a45680bb9eb24', 'Cryptolib inchangée, empreinte lue sans chargement')
check(read(out/'process-check.json')['remaining'] == [], 'Aucun processus de recette ni validateur natif restant')
check('No issues found!' in (out/'analysis.log').read_text(), 'Analyse Dart sans anomalie')
entries = plan['target']['entries']
report = {'passed':True,'checks':checks,'nativeChecks':counts,'nativeTotal':sum(counts.values()),
          'generationEntries':{k:sum(e['kind']==k for e in entries.values()) for k in ['file','link','directory']},
          'identity':plan['identity'],'planHash':pin,'snapshotHash':plan['archiveHash'],
          'installed':False,'networkAccess':False,'cpsCalls':0,
          'scope':'synthetic only, same Mac and identity; version20 metadata only, same code',
          'timestamp':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(out/'Verification_livraison.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
files = ['lib/main.dart','lib/core/maintenance/maintenance_session.dart','lib/core/maintenance/maintenance_screen.dart',
         'lib/core/maintenance/coordinated_recipe.dart','macos/Runner/MainFlutterWindow.swift']
files += ['tool/controlled_deployment/'+f for f in ['native_recipe.py','bundle_recovery.py','coordinated_recovery.py',
          'run_coordinated_phase.py','verify_coordinated.py','verify_coordinated_startup.dart','verify_coordinated_delivery.py']]
(out/'Sources.json').write_text(json.dumps({f:r.sha(f) for f in files},indent=2)+'\n')
print(json.dumps({'passed':True,'checks':len(checks),'nativeChecks':report['nativeTotal'],'entries':report['generationEntries']}))
