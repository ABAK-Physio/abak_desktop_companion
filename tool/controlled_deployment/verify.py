import contextlib
import fcntl
import json
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time

import recovery as r
import maintenance_only

out = Path(os.environ['DEPLOY_OUTPUT']).resolve()
repo = Path(os.environ['DEPLOY_REPO']).resolve()
frameworks = Path(os.environ['DEPLOY_FRAMEWORKS']).resolve()
tester = Path(os.environ['DEPLOY_TESTER']).resolve()
dill = out / 'verify.dill'
root = Path(tempfile.mkdtemp(prefix='abak-maintenance-', dir=out)).resolve()
(root / 'SYNTHETIC-ONLY').write_text(r.MARKER)
for name in ['app', 'support', 'preferences', 'documents']:
    (root / 'active' / name).mkdir(parents=True)
(root / 'active/app/Info.json').write_text('{"version":"1.1.0","build":"9","surrogate":true}')
(root / 'active/preferences/preferences.json').write_text(json.dumps({'version':'1.1.0','build':'9', 'macos_last_successful_launch_v1':{'version':'1.1.0','build':'9'},'bookmark':'SYNTHETIC-BOOKMARK'}))
(root / 'active/documents/report.docx').write_bytes(b'SYNTHETIC DOCUMENT SOURCE SURROGATE')
checks, runs = [], []


def check(value, label):
    if not value: raise AssertionError(label)
    checks.append(label)
    print('PASS ' + label, flush=True)


def refuses(action, label):
    try: action()
    except Exception: check(True, label)
    else: raise AssertionError('Not rejected: ' + label)


def command(phase):
    return [str(tester), '--disable-vm-service', '--run-forever',
            '--flutter-assets-dir=' + str(frameworks / 'App.framework/Resources/flutter_assets'), str(dill)]


def environment(phase):
    return dict(os.environ, DEPLOY_ROOT=str(root), DEPLOY_PHASE=phase, TMPDIR=str(out / 'tmp'))


def run(phase):
    log = out / (f'{len(runs):02d}-' + phase + '.log')
    with log.open('w') as stream:
        result = subprocess.run(command(phase), cwd=frameworks, env=environment(phase),
                                stdout=stream, stderr=subprocess.STDOUT, timeout=90)
    if result.returncode:
        raise RuntimeError(f'{phase}: exit {result.returncode}\n' + log.read_text()[-12000:])
    report = json.loads((root / (phase + '.json')).read_text())
    runs.append(report)
    check(report['passed'], 'Phase Dart réussie : ' + phase)


try:
    run('seed')
    original = r.inventory(root / 'active')
    state = r.database_state(root / 'active')
    checkpoint = r.checkpoint(root, 'before-upgrade')
    check(r.inventory(checkpoint / 'generation') == original, 'Point de repli complet : app substitut, base, PDF/preuve, préférences et document source')
    refuses(lambda:r.checkpoint(root,'before-upgrade'), 'Point de repli existant non écrasé')
    launch=maintenance_only.prepare(frameworks.parents[1],root)
    check(launch[0]=='/usr/bin/sandbox-exec' and '(deny network*)' in launch[2],
          'Lanceur synthétique vérifie la signature et impose la sandbox hors réseau')
    check(launch[-2:]==['--abak-maintenance','--abak-maintenance-root='+str(root)],
          'Lanceur construit uniquement les arguments de maintenance, sans lancement normal')
    check(r.inventory(root/'active')==original,'Préparation du lanceur sans ouverture de la candidate ni modification des données')
    run('inspect')
    check(r.inventory(root / 'active') == original, 'Démarrage maintenance ne change aucun fichier de la génération')
    run('migration-failure')
    check(r.database_state(root / 'active') == state, 'Migration interrompue conserve données et schéma')
    run('migrate')
    run('reopen')
    upgraded = r.database_state(root / 'active')
    check(upgraded['schema']==37 and all(upgraded['tables'].get(k)==v for k,v in state['tables'].items()), 'Migration réelle 36→37 conserve toutes les tables métier et leurs contenus')
    (root / 'active/app/Info.json').write_text('{"version":"1.1.1","build":"10","surrogate":true}')
    prefs = json.loads((root / 'active/preferences/preferences.json').read_text())
    prefs.update(version='1.1.1', build='10', macos_last_successful_launch_v1={'version':'1.1.1','build':'10'})
    (root / 'active/preferences/preferences.json').write_text(json.dumps(prefs))
    upgraded_files = r.inventory(root / 'active')
    changed_pdf=root/'active/support/episode_document_versions/frozen.pdf'
    saved_pdf=changed_pdf.read_bytes(); changed_pdf.write_bytes(b'NEW CLINICAL PDF')
    refuses(lambda:r.prepare_rollback(root,'before-upgrade'),'PDF modifié sans changement SQL interdit le retour automatique')
    check(changed_pdf.read_bytes()==b'NEW CLINICAL PDF','PDF modifié conservé après refus')
    changed_pdf.write_bytes(saved_pdf)
    added_proof=root/'active/documents/new-proof.json'; added_proof.write_text('{}')
    refuses(lambda:r.prepare_rollback(root,'before-upgrade'),'Nouvelle preuve hors base interdit le retour automatique')
    added_proof.unlink()
    for phase in ['before_preserve', 'after_preserve', 'after_activate']:
        preview=r.prepare_rollback(root,'before-upgrade')
        def fail(point):
            if point==phase: raise OSError('Panne synthétique : '+point)
        refuses(lambda:r.rollback(root,preview,fault=fail),'Panne de retour arrière prise en compte : '+phase)
        check(r.inventory(root/'active')==upgraded_files, 'Compensation complète de la panne : '+phase)
        check(r.inventory(checkpoint/'generation')==original,'Repli durable intact après panne : '+phase)
    preview=r.prepare_rollback(root,'before-upgrade')
    altered=root/'active/preferences/preferences.json'
    saved=altered.read_bytes(); altered.write_text('{}')
    refuses(lambda:r.rollback(root,preview),'Changement après prévisualisation refuse le retour arrière')
    altered.write_bytes(saved)
    damaged=checkpoint/'generation/support/episode_document_versions/frozen.pdf'
    saved=damaged.read_bytes(); damaged.write_bytes(b'TAMPERED')
    refuses(lambda:r.prepare_rollback(root,'before-upgrade'),'Altération du PDF sauvegardé détectée avant bascule')
    damaged.write_bytes(saved)
    # Abrupt process exit after the active generation is preserved: replay the
    # durable intent from a new process, without relying on Python exception code.
    preview=r.prepare_rollback(root,'before-upgrade')
    code='import json,os,sys;from pathlib import Path;import recovery as r\nr.rollback(Path(sys.argv[1]),json.loads(sys.argv[2]),fault=lambda p: os._exit(79) if p=="after_preserve" else None)'
    result=subprocess.run([sys.executable,'-c',code,str(root),json.dumps(preview)],cwd=Path(__file__).parent)
    check(result.returncode==79 and (root/'rollback.pending.json').exists() and not (root/'active').exists(),'Arrêt brutal laisse un journal durable et la génération conservée')
    r.recover(root)
    check(r.inventory(root/'active')==upgraded_files,'Nouveau processus récupère complètement le retour interrompu')
    outcome=r.rollback(root,r.prepare_rollback(root,'before-upgrade'))
    check(r.inventory(root/'active')==original,'Retour réussi : ancienne application substitut, base 36, préférences, PDF et preuves identiques')
    check(r.inventory(Path(outcome['preserved']))==upgraded_files,'Génération 37 conservée après retour réussi, pas effacée')
    run('restored')
    run('journal')
    check(r.database_state(root/'active')==state,'Après nouveau processus : identité, retenue, tentative et compteur inchangés')
    # Cross-process ownership, including abrupt termination. Only this test's
    # child is terminated; never discover or kill unrelated Java/app processes.
    log=out/'lock-child.log'
    with log.open('w') as stream:
        child=subprocess.Popen(command('hold'),cwd=frameworks,env=environment('hold'),stdin=subprocess.PIPE,stdout=stream,stderr=subprocess.STDOUT)
        try:
            deadline=time.monotonic()+15
            while 'LOCK_READY' not in log.read_text():
                if child.poll() is not None or time.monotonic()>deadline: raise RuntimeError(log.read_text())
                time.sleep(.05)
            refuses(lambda:r.checkpoint(root,'while-running'),'Outillage de sauvegarde bloqué par une instance Dart active')
            child.kill(); child.wait(timeout=10)
        finally:
            if child.poll() is None: child.kill(); child.wait(timeout=10)
            child.stdin.close()
    with r.locked(root): check(True,'Le système libère le verrou après arrêt brutal, sans suppression du fichier')
    r.checkpoint(root,'after-restoration')
    check((root/'checkpoints/before-upgrade/manifest.json').is_file(),'Repli initial toujours présent après nouvelle sauvegarde')
    # Rejections run on additional synthetic cases; never edit the durable repli.
    case=Path(tempfile.mkdtemp(prefix='abak-maintenance-',dir=out)).resolve()
    (case/'SYNTHETIC-ONLY').write_text(r.MARKER)
    shutil.copytree(root/'active',case/'active')
    r.checkpoint(case,'before')
    with contextlib.closing(sqlite3.connect(case/'active'/r.DB)) as cx:
        cx.execute("INSERT INTO patients(patient_id,last_name,first_name,birth_date,created_at) VALUES('SYN-NEW','SYNTHETIQUE','Ajout','1980-01-01',3)")
        cx.commit()
    refuses(lambda:r.prepare_rollback(case,'before'),'Nouvelle saisie métier interdit le retour automatique destructeur')
    check(r.database_state(case/'active')['tables']['patients']['rows']==2,'Nouvelle saisie conservée après refus')
    absent=Path(tempfile.mkdtemp(prefix='abak-maintenance-',dir=out)).resolve()
    refuses(lambda:r.checkpoint(absent,'invalid'),'Racine sans marqueur refusée')
    link=out/'linked-root'; link.symlink_to(root,target_is_directory=True)
    refuses(lambda:r.checkpoint(link,'invalid'),'Racine via lien symbolique refusée')
    nested=root/'active/documents/link'; nested.symlink_to(root/'SYNTHETIC-ONLY')
    refuses(lambda:r.checkpoint(root,'invalid-link'),'Lien dans une génération refusé')
    nested.unlink()
    side=Path(str(root/'active'/r.DB)+'-wal'); side.write_bytes(b'UNCERTAIN')
    refuses(lambda:r.checkpoint(root,'invalid-wal'),'Sauvegarde refuse un WAL non vide sans le supprimer')
    check(side.read_bytes()==b'UNCERTAIN','Auxiliaire incertain intact'); side.unlink()
    report={'passed':True,'root':str(root),'checks':checks,'dartRuns':runs,
            'assertions':len(checks)+sum(len(x['checks']) for x in runs),
            'applicationSurrogate':True,'installed':False,'networkUsed':False,'CPSUsed':False,
            'userDatabaseOpened':False,'INSiModified':False,'realLotsModified':False}
    (out/'result.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(f"Réussite : {report['assertions']} assertions ; zéro installation.")
except Exception as error:
    (out/'failure.json').write_text(json.dumps({'error':str(error),'root':str(root),'checks':checks},ensure_ascii=False,indent=2))
    raise
