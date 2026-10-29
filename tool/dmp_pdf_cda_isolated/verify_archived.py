"""Read-only archive replay. Never starts veraPDF, Java, Poppler or network."""
from pathlib import Path
import copy,json,sys
from bench import interpret_verapdf,parse_xml,digest,E

archive,out=map(Path,sys.argv[1:])
if out.exists():raise SystemExit('Sortie neuve requise')
out.mkdir(parents=True)
before={p:digest(p.read_bytes()) for p in archive.rglob('*') if p.is_file()}
results=[]
def test(name,data,xml,code,status,kind=None,profile=None,path=None):
    result=interpret_verapdf(data,xml,code,profile,path)
    assert result['status']==status,(name,result)
    if kind:assert result['kind']==kind,(name,result)
    results.append(dict(test=name,result='PASS',evidence=result))
for entry in json.loads((archive/'Execution.json').read_text()):
    if '--flavour' not in entry['commande']:continue
    path=Path(entry['commande'][-1]);profile=entry['commande'][-2]
    data=path.read_bytes();xml=(archive/entry['rapport']).read_bytes()
    status='non_verifie' if path.stem in ('chiffre','tronque') else 'refuse'
    kind={'chiffre':'document_chiffre','tronque':'document_illisible'}.get(path.stem,'non_conformite')
    test(entry['rapport'],data,xml,entry['code_sortie'],status,kind,profile,path)

path=archive.resolve()/'copies/rapport_final.pdf'; data=path.read_bytes()
negative=parse_xml((archive/'rapport_final-1b.stdout').read_bytes())
def changed(fn):
    root=copy.deepcopy(negative);fn(root);return E.tostring(root)
def reject(name,xml,code=1,profile='1b',path_arg=path):
    test(name,data,xml,code,'non_verifie',profile=profile,path=path_arg)
# Positive verdict is fabricated solely for parser contracts, NOT PDF evidence.
positive=copy.deepcopy(negative)
v=positive.find('.//validationReport');v.set('isCompliant','true')
d=v.find('details');d.set('failedRules','0');d.set('failedChecks','0')
for child in list(d): d.remove(child)
b=positive.find('batchSummary/validationReports');b.set('compliant','1');b.set('nonCompliant','0')
px=E.tostring(positive)
test('contrat_positif_fabrique',data,px,0,'conforme',profile='1b',path=path)
reject('code_1_avec_verdict_positif',px)
reject('code_0_avec_refus',E.tostring(negative),0)
for code in [2,7,8,-9,124]:reject('code_execution_'+str(code),E.tostring(negative),code)
for name,xml in [('vide',b''),('xml_tronque',b'<report>'),('sans_bilan',changed(lambda r:r.remove(r.find('batchSummary')))),('sans_details',changed(lambda r:r.find('.//validationReport').remove(r.find('.//details')))),('sans_etat_final',changed(lambda r:r.find('.//validationReport').attrib.pop('jobEndStatus'))),('interrompu',changed(lambda r:r.find('.//validationReport').set('jobEndStatus','aborted'))),('bilan_positif_contradictoire',changed(lambda r:r.find('batchSummary/validationReports').set('compliant','1'))),('compteur_negatif',changed(lambda r:r.find('.//details').set('failedRules','-1'))),('refus_sans_defaut',changed(lambda r:r.find('.//details').set('failedRules','0'))),('plusieurs_jobs',changed(lambda r:r.find('jobs').append(copy.deepcopy(r.find('jobs/job'))))),('exception',changed(lambda r:E.SubElement(r.find('jobs/job'),'taskException'))),('memoire',changed(lambda r:r.find('batchSummary').set('outOfMemory','1'))),('autre_profil',changed(lambda r:r.find('.//validationReport').set('profileName','PDF/A-2b validation profile'))),('taille_incoherente',changed(lambda r:r.find('.//item').set('size','0'))),('profil_1a_inattendu',changed(lambda r:r.find('.//validationReport').set('profileName','PDF/A-1a validation profile')))]:reject(name,xml)
reject('chemin_incoherent',E.tostring(negative),path_arg='/fichier-different.pdf')
reject('DTD_entite',b'<!DOCTYPE report [<!ENTITY x SYSTEM "file:///NOT-TO-READ">]><report>&x;</report>')
# Once completed, each profile has its own explicit correlation.
bad_positive=copy.deepcopy(positive)
E.SubElement(bad_positive.find('.//details'),'rule',status='failed')
reject('positif_avec_regle_en_echec',E.tostring(bad_positive),code=0)
test('contrat_positif_1a',data,px.replace(b'PDF/A-1b',b'PDF/A-1a'),0,'conforme',profile='1a',path=path)
for p,sha in before.items():assert digest(p.read_bytes())==sha
(out/'Resultats.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
(out/'Synthese.json').write_text(json.dumps(dict(passed=len(results),archived=12,mutatedContracts=len(results)-12,archiveUnchanged=True,validatorRuns=0),indent=2)+'\n')
print(f'{len(results)}/{len(results)} contrôles réussis ; 12 rapports archivés, {len(results)-12} contrats fabriqués ; archives inchangées ; aucune exécution de validateur.')
