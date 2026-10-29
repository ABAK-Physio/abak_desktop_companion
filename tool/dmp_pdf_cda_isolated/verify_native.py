"""Native synthetic regression suite. Use run_native_offline.sh, never real PDFs."""
from bench import *
from pypdf import PdfReader,PdfWriter
from pypdf.generic import NameObject,DecodedStreamObject,ArrayObject,DictionaryObject,TextStringObject
import sys,uuid,copy

def main():
    references,out,validator,poppler=Path(sys.argv[1]),Path(sys.argv[2]),sys.argv[3],Path(sys.argv[4])
    if out.exists():raise SystemExit('Sortie neuve requise')
    fixture=Path(__file__).resolve().parent/'fixtures'
    manifest=json.loads((fixture/'manifest.json').read_text())
    assert manifest['scope']==MARKER
    for name,sha in manifest['files'].items():assert digest((fixture/name).read_bytes())==sha
    out.mkdir(parents=True);out=out.resolve()
    for name in ['variants','reports','stores','cda']: (out/name).mkdir()
    profile=out/'java-profile';profile.mkdir()
    os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(profile)
    shutil.copytree(references,out/'references')
    source=fixture/'temoin-pdfa1b.pdf';pdf=source.read_bytes()
    template=(fixture/'temoin-cda.xml').read_bytes()
    def doc(data,remove_patient=False):
        root=parse_xml(template)
        root.find('c:component/c:nonXMLBody/c:text',NS).text=base64.b64encode(data).decode()
        if remove_patient:root.remove(root.find('c:recordTarget',NS))
        return E.tostring(root,xml_declaration=True,encoding='UTF-8')
    root=parse_xml(template)
    ctx=dict(patient='SIM-A',author='SIM-KINE',structure='SIM-CABINET',title='Rapport clinique SYNTHETIQUE',date='20261017120000+0200',confidentiality='N',type='11506-3',id=root.find('c:id',NS).get('root'),setId=root.find('c:setId',NS).get('root'),version='1',**{'class':'11'})
    meta=dict(ctx,formatCode=FMT)
    # All mutation writers start from the immutable positive fixture.
    def variant(name,change):
        w=PdfWriter();w.clone_document_from_reader(PdfReader(source));change(w)
        w.generate_file_identifiers();path=out/'variants'/(name+'.pdf');w.write(path);return path
    def no_font(w):
        removed=0
        for page in w.pages:
            for font in page['/Resources']['/Font'].values():
                f=font.get_object();desc=f.get('/FontDescriptor')
                if desc:
                    desc=desc.get_object()
                    for key in ['/FontFile','/FontFile2','/FontFile3']:
                        if key in desc:del desc[key];removed+=1
        assert removed>0
    def contents(w,data):
        stream=DecodedStreamObject();stream.set_data(data)
        w.pages[0][NameObject('/Contents')]=w._add_object(stream)
    def header(w):
        fonts=w.pages[0]['/Resources']['/Font']
        font=next(k for k,v in fonts.items() if v.get_object().get('/FontDescriptor'))
        contents(w,('BT '+font+' 12 Tf 60 780 Td (SYNTHETIQUE - EN-TETE SEUL) Tj ET\n').encode())
    def changed_content(w):
        stream=DecodedStreamObject();stream.set_data(b'q 0 0 0 rg 60 40 12 12 re f Q\n')
        old=w.pages[0].raw_get('/Contents');parts=list(old.get_object()) if isinstance(old.get_object(),ArrayObject) else [old]
        w.pages[0][NameObject('/Contents')]=ArrayObject(parts+[w._add_object(stream)])
    variants={
        'sans_xmp':variant('sans_xmp',lambda w:w.root_object.pop('/Metadata')),
        'sans_profil_couleur':variant('sans_profil_couleur',lambda w:w.root_object.pop('/OutputIntents')),
        'police_non_incorporee':variant('police_non_incorporee',no_font),
        'action_javascript':variant('action_javascript',lambda w:w.root_object.__setitem__(NameObject('/OpenAction'),DictionaryObject({NameObject('/S'):NameObject('/JavaScript'),NameObject('/JS'):TextStringObject('/* SYNTHETIQUE : aucune action */')}))),
        'chiffre':variant('chiffre',lambda w:w.encrypt('SYNTHETIQUE')),
        'blanc':variant('blanc',lambda w:contents(w,b'')),
        'entete':variant('entete',header),
        'contenu_modifie':variant('contenu_modifie',changed_content)}
    truncated=out/'variants/tronque.pdf';truncated.write_bytes(pdf[:400]);variants['tronque']=truncated
    positive=out/'variants/positif.pdf';positive.write_bytes(pdf)
    variants['positif']=positive
    hashes={n:digest(p.read_bytes()) for n,p in variants.items()}
    write_json(out/'Variants.json',hashes)
    pdf_reports={}
    for name,path in variants.items():
        dest=out/'reports'/name;dest.mkdir()
        pdf_reports[name]=validate_pdfa(path,validator,dest)
        write_json(dest/'interpretation.json',pdf_reports[name])
        print('PDF',name,pdf_reports[name]['status'],flush=True)
    native=CdaValidator(out/'references',shutil.which('java'),out/'cda')
    cda_reports={}
    for name in ['positif','blanc','entete','contenu_modifie']:
        cda_reports[name]=native.validate(doc(variants[name].read_bytes()),name)
        assert cda_reports[name]['status']=='conforme',cda_reports[name]
    bad_xml=doc(pdf,True);bad_cda=native.validate(bad_xml,'sans_patient')
    assert bad_cda['status']=='refuse' and not bad_cda['xsd']
    results=[]
    def reopen(b):
        command=[sys.executable,str(Path(__file__).resolve()),'--reopen',str(b.root)]
        cp=run(command);assert cp.returncode==0,cp.stderr
        state=json.loads(cp.stdout)
        assert state==b.state,'Journal différent après réouverture'
        assert state['held'] and state['calls']==0
        return state
    def fresh(name='positif',review=True):
        b=Bench.create(out/'stores');b.load(variants[name].read_bytes(),ctx,poppler)
        if review:b.review(True,True,[1])
        return b
    def check(name,fn):
        fn();results.append({'id':name,'result':'PASS'});write_json(out/'Resultats.json',results);print('TEST',name,'PASS',flush=True)
    def denied(action):
        try:action()
        except ValueError:return
        raise AssertionError('Blocage attendu absent')
    def positive_test():
        assert pdf_reports['positif']['status']=='conforme'
        b=fresh();assert b.evaluate(doc(pdf),meta,pdf_reports['positif'],cda_reports['positif'])=='controles_techniques_conformes'
        reopen(b)
    check('N01_positif_natif_et_persistance',positive_test)
    for index,(name,clause) in enumerate([('sans_xmp','6.7.2'),('sans_profil_couleur','6.2.3.3'),('police_non_incorporee','6.3.4'),('action_javascript','6.6.1')],2):
        def negative(name=name,clause=clause):
            data=variants[name].read_bytes();xml=doc(data);r=pdf_reports[name]
            assert r['status']=='refuse' and r['kind']=='non_conformite',r
            report=parse_xml((out/'reports'/name/'verapdf.xml').read_bytes())
            assert any(n.get('clause')==clause for n in report.findall('.//rule'))
            b=fresh(name)
            # No CDA conformity invented for negative PDFs: PDF refusal alone blocks.
            assert b.evaluate(xml,meta,r,evidence(xml,'non_verifie',reason='CDA non évalué pour PDF refusé'))=='refuse'
            reopen(b)
        check(f'N{index:02}_{name}_refus_natif',negative)
    for index,name in enumerate(['chiffre','tronque'],6):
        def unreadable(name=name):
            assert pdf_reports[name]['status']=='non_verifie'
            b=Bench.create(out/'stores');denied(lambda:b.load(variants[name].read_bytes(),ctx,poppler))
            assert b.state['current'] is None and b.state['approved'] is None and b.state['error']
            reopen(b)
        check(f'N{index:02}_{name}_import_bloque',unreadable)
    def blank():
        assert pdf_reports['blanc']['status']=='conforme'
        b=fresh('blanc',False);denied(lambda:b.review(True,True,[1]))
        assert b.state['approved'] is None
        assert b.evaluate(doc(b.pdf()),meta,pdf_reports['blanc'],cda_reports['blanc'])=='refuse'
        reopen(b)
    check('N08_blanc_conforme_PDFA_mais_bloque',blank)
    def heading():
        assert pdf_reports['entete']['status']=='conforme'
        b=fresh('entete',False);denied(lambda:b.review(False,True,[1]))
        assert b.evaluate(doc(b.pdf()),meta,pdf_reports['entete'],cda_reports['entete'])=='refuse'
        reopen(b)
    check('N09_entete_revue_clinique_negative',heading)
    def modified():
        assert pdf_reports['contenu_modifie']['status']=='conforme'
        b=fresh();b.load(variants['contenu_modifie'].read_bytes(),ctx,poppler)
        assert b.state['approved'] is None
        assert b.evaluate(doc(b.pdf()),meta,pdf_reports['contenu_modifie'],cda_reports['contenu_modifie'])=='refuse'
        reopen(b)
    check('N10_modification_annule_validation',modified)
    def stale():
        b=fresh('contenu_modifie')
        assert b.evaluate(doc(b.pdf()),meta,pdf_reports['positif'],cda_reports['positif'])=='refuse'
        assert 'Rapport non corrélé aux octets' in b.state['current']['errors'];reopen(b)
    check('N11_anciens_rapports_bloques',stale)
    def cda_negative():
        b=fresh();assert b.evaluate(bad_xml,meta,pdf_reports['positif'],bad_cda)=='refuse';reopen(b)
    check('N12_CDA_sans_patient_refuse_nativement',cda_negative)
    def different_payload():
        b=fresh();xml=doc(variants['contenu_modifie'].read_bytes())
        assert b.evaluate(xml,meta,pdf_reports['positif'],cda_reports['contenu_modifie'])=='refuse';reopen(b)
    check('N13_PDF_encapsule_different',different_payload)
    def corrupted_copy():
        b=fresh();(b.root/digest(pdf)/'document.pdf').write_bytes(pdf+b'\n% alteration')
        assert b.evaluate(doc(pdf),meta,pdf_reports['positif'],cda_reports['positif'])=='refuse';reopen(b)
    check('N14_copie_figee_alteree',corrupted_copy)
    def unknown():
        b=fresh();r=interpret_verapdf(pdf,b'<report>',1)
        assert b.evaluate(doc(pdf),meta,r,cda_reports['positif'])=='non_verifie';reopen(b)
    check('N15_rapport_tronque_non_verifie',unknown)
    for name,path in variants.items():assert digest(path.read_bytes())==hashes[name]
    for name,sha in manifest['files'].items():assert digest((fixture/name).read_bytes())==sha
    write_json(out/'Synthese.json',dict(passed=len(results),pdfNativeReports=len(pdf_reports),cdaNativeReports=len(cda_reports)+1,stores=len(list((out/'stores').iterdir())),calls=0,held=True,reopenSeparateProcess=True,fixturesUnchanged=True))
    print('Terminé :',len(results),'contrôles natifs et persistance',flush=True)

if __name__=='__main__':
    if sys.argv[1]=='--reopen':print(json.dumps(Bench(sys.argv[2]).state))
    else:main()
