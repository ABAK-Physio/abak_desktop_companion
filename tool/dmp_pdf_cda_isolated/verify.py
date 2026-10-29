"""18 scenario groups: real local parsing + injected validator failures.

No fake report is labelled as a real PDF/A or CI-SIS certificate.
"""
from bench import *
import sys
import copy
import uuid


def main():
    fixtures, references, destination, poppler = map(Path, sys.argv[1:5])
    if destination.exists():
        raise SystemExit('Répertoire de résultats neuf requis')
    destination.mkdir(parents=True)
    out = destination.resolve()
    cases = out/'stockages'; cases.mkdir()
    resources = out/'references'
    shutil.copytree(references, resources, symlinks=False)
    java = shutil.which('java')
    validator = sys.argv[5] if len(sys.argv) > 5 else shutil.which('verapdf')
    write_json(out/'outils.json', dict(java=java, verapdf=validator, poppler=str(poppler),
        pdfaProfile='1b candidat de banc, niveau applicable à confirmer', network='Interdit par sandbox-exec'))
    pdf = (Path(sys.argv[6]) if len(sys.argv) > 6 else fixtures/'rapport_final.pdf').read_bytes()
    ctx = dict(patient='SIM-A', author='SIM-KINE', structure='SIM-CABINET',
               title='Rapport clinique SYNTHETIQUE', date='20261017120000+0200',
               confidentiality='N', type='11506-3', **{'class':'11'},
               id=str(uuid.uuid4()).upper(), setId=str(uuid.uuid4()).upper(), version='1')
    meta = dict(ctx, formatCode=FMT)
    def document(data=pdf, c=None):
        c = c or ctx
        root = E.Element('{urn:hl7-org:v3}ClinicalDocument', nsmap={None:'urn:hl7-org:v3'})
        def add(parent, name, text=None, **attrs):
            node = E.SubElement(parent, '{urn:hl7-org:v3}'+name, **attrs)
            node.text = text
            return node
        add(root,'realmCode',code='FR')
        add(root,'typeId',root='2.16.840.1.113883.1.3',extension='POCD_HD000040')
        add(root,'templateId',root='1.2.250.1.213.1.1.1.1')
        add(root,'templateId',root='2.16.840.1.113883.2.8.2.1')
        add(root,'templateId',root='1.3.6.1.4.1.19376.1.2.20')
        add(root,'id',root=c['id'])
        add(root,'code',code=c['type'],codeSystem='2.16.840.1.113883.6.1',displayName='CR ou fiche de suivi de soins par auxiliaire médical')
        add(root,'title',c['title'])
        add(root,'effectiveTime',value=c['date'])
        add(root,'confidentialityCode',code=c['confidentiality'],codeSystem='2.16.840.1.113883.5.25',displayName='Normal')
        add(root,'languageCode',code='fr-FR')
        add(root,'setId',root=c['setId']); add(root,'versionNumber',value=c['version'])
        patient = add(add(root,'recordTarget'),'patientRole')
        add(patient,'id',root='2.25.123456789',extension=c['patient'])
        person = add(patient,'patient'); name = add(person,'name')
        add(name,'given','Fictif'); add(name,'family','SYNTHETIQUE',qualifier='BR')
        add(person,'administrativeGenderCode',code='M',codeSystem='2.16.840.1.113883.5.1')
        add(person,'birthTime',value='19870101')
        author = add(root,'author'); add(author,'time',value=c['date'])
        assigned = add(author,'assignedAuthor')
        add(assigned,'id',root='2.25.123456789',extension=c['author'])
        name=add(add(assigned,'assignedPerson'),'name'); add(name,'family','KINE SYNTHETIQUE')
        org=add(add(add(root,'custodian'),'assignedCustodian'),'representedCustodianOrganization')
        add(org,'id',root='1.2.250.1.71.4.2.2',extension=c['structure'])
        add(org,'name','CABINET SYNTHETIQUE')
        legal=add(root,'legalAuthenticator')
        add(legal,'time',value=c['date']);add(legal,'signatureCode',code='S')
        entity=add(legal,'assignedEntity');add(entity,'id',root='2.25.123456789',extension=c['author'])
        person=add(entity,'assignedPerson');name=add(person,'name');add(name,'family','KINE SYNTHETIQUE')
        event=add(add(root,'documentationOf'),'serviceEvent',classCode='ACT')
        add(event,'code',nullFlavor='NA')
        time=add(event,'effectiveTime');add(time,'low',value=c['date']);add(time,'high',value=c['date'])
        performer=add(event,'performer',typeCode='PRF');entity=add(performer,'assignedEntity')
        add(entity,'id',root='2.25.123456789',extension=c['author'])
        person=add(entity,'assignedPerson');name=add(person,'name');add(name,'family','KINE SYNTHETIQUE')
        org=add(entity,'representedOrganization')
        add(org,'id',root='1.2.250.1.71.4.2.2',extension=c['structure'])
        add(org,'name','CABINET SYNTHETIQUE')
        add(org,'standardIndustryClassCode',code='AMBULATOIRE',codeSystem='1.2.250.1.213.1.1.4.9',displayName='Ambulatoire')
        encounter=add(add(root,'componentOf'),'encompassingEncounter')
        add(encounter,'id',root='2.25.123456789',extension='SIM-EPISODE')
        time=add(encounter,'effectiveTime');add(time,'low',value=c['date'])
        facility=add(add(encounter,'location'),'healthCareFacility')
        add(facility,'code',code='SA07',codeSystem='1.2.250.1.71.4.2.4',displayName='Cabinet individuel')
        place=add(facility,'location')
        add(place,'name','CABINET SYNTHETIQUE')
        body=add(add(root,'component'),'nonXMLBody')
        add(body,'text',base64.b64encode(data).decode(),mediaType='application/pdf',representation='B64')
        return E.tostring(root,xml_declaration=True,encoding='UTF-8')
    xml=document()
    (out/'cda-synthetique.xml').write_bytes(xml)
    native_dir=out/'validation-cda'; native_dir.mkdir()
    native=CdaValidator(resources, java, native_dir)
    print('Contrôles CDA natifs en cours',flush=True)
    real_cda=native.validate(xml,'temoin-synthetique')
    pdf_dir=out/'validation-pdfa'; pdf_dir.mkdir()
    (pdf_dir/'document.pdf').write_bytes(pdf)
    real_pdf=validate_pdfa(pdf_dir/'document.pdf',validator,pdf_dir)
    write_json(pdf_dir/'resultat.json',real_pdf)
    results=[]
    def fresh(data=pdf, c=None, review=True):
        b=Bench.create(cases); b.load(data,c or ctx,poppler)
        if review: b.review(True,True,list(range(1,b.state['current']['inspection']['pages']+1)))
        return b
    def simulated(data, status='conforme'):
        return evidence(data,status,simulated=True,source='Service injecté du banc, aucune certification')
    def check(b, x=xml, m=None, pr=None, cr=None):
        return b.evaluate(x,m or meta,pr or simulated(b.pdf()),cr or simulated(x))
    def blocked(action):
        try: action()
        except (ValueError,E.XMLSyntaxError): return
        raise AssertionError('Blocage attendu absent')
    def record(id, action, scope):
        try:
            details=action()
            results.append(dict(id=id,result='PASS',scope=scope,details=details))
        except Exception as exc:
            results.append(dict(id=id,result='FAIL',scope=scope,error=repr(exc)))
        write_json(out/'Resultats_18.json',results)
        print(id,results[-1]['result'],flush=True)
    def require(value, expected):
        assert value == expected,(value,expected)

    def pdf01():
        b=fresh(); require(check(b),'simulation_conforme')
        b=fresh(); status=check(b,pr=real_pdf,cr=real_cda)
        assert status != 'controles_techniques_conformes' or (real_pdf['status']==real_cda['status']=='conforme')
        return {'realPdfA':real_pdf,'realCdaStatus':real_cda['status'],
                'positiveConformityDemonstrated':real_pdf['status']==real_cda['status']=='conforme'}
    record('PDF-01',pdf01,'Décision positive simulée ; contrôle natif documenté séparément')
    def pdf02():
        b=fresh(); require(check(b,pr=simulated(pdf,'refuse')),'refuse')
        return 'PDF lisible réellement ; verdict PDF/A négatif injecté'
    record('PDF-02',pdf02,'Simulation du verdict PDF/A')
    def pdf03():
        b=fresh((fixtures/'page_blanche.pdf').read_bytes(),review=False)
        assert b.state['current']['inspection']['allWhite']
        blocked(lambda:b.review(True,True,[1]))
        b=fresh((fixtures/'entete_seul.pdf').read_bytes(),review=False)
        blocked(lambda:b.review(False,True,[1]))
        assert b.state['approved'] is None
    record('PDF-03',pdf03,'PDF et rendu réels ; revue clinique explicite négative pour en-tête')
    def pdf04():
        for name in ['tronque.pdf','chiffre.pdf','faux_pdf.pdf','zero_octet.pdf','corrompu.pdf']:
            b=Bench.create(cases)
            blocked(lambda:b.load((fixtures/name).read_bytes(),ctx,poppler))
            assert Bench(b.root).state['approved'] is None
    record('PDF-04',pdf04,'Cinq fichiers synthétiques effectivement analysés par Poppler')
    def pdf05():
        for reason in ['polices','couleurs','XMP','fonction interdite']:
            b=fresh(); r=simulated(pdf,'refuse');r['reason']=reason
            require(check(b,pr=r),'refuse')
    record('PDF-05',pdf05,'Quatre rapports négatifs injectés ; défauts PDF/A non certifiés nativement')
    def pdf06():
        b=fresh(); (b.root/digest(pdf)/'document.pdf').write_bytes(pdf+b'\n% changed')
        require(check(b),'refuse')
        b=fresh(); b.load((fixtures/'rapport_modifie.pdf').read_bytes(),ctx,poppler)
        assert b.state['approved'] is None
        require(check(b,x=document(b.pdf())),'refuse')
    record('PDF-06',pdf06,'Altération réelle des copies isolées et réimport')
    def pdf07():
        for report,code in [(b'',0),(b'<report/>',0),(b'<report>',0),(b'<report/>',1)]:
            parsed=interpret_verapdf(pdf,report,code)
            require(parsed['status'],'non_verifie'); require(check(fresh(),pr=parsed),'non_verifie')
        require(validate_pdfa(pdf_dir/'document.pdf',None,pdf_dir)['status'],'non_verifie')
        require(check(fresh(),pr=evidence(b'different','conforme')),'refuse')
        for compliant, failed, expected in [('true','0','conforme'),('false','1','refuse'),('true','1','non_verifie')]:
            report=f'<report><jobs><job><item size="{len(pdf)}"><name>synthetic.pdf</name></item><validationReport jobEndStatus="normal" profileName="PDF/A-1b validation profile" isCompliant="{compliant}"><details passedRules="1" failedRules="{failed}" passedChecks="1" failedChecks="{failed}"/></validationReport></job></jobs><batchSummary totalJobs="1" failedToParse="0" encrypted="0" outOfMemory="0" veraExceptions="0"><validationReports compliant="{int(compliant=="true")}" nonCompliant="{int(compliant=="false")}" failedJobs="0">1</validationReports></batchSummary></report>'.encode()
            require(interpret_verapdf(pdf,report,0 if compliant=='true' else 1)['status'],expected)
    record('PDF-07',pdf07,'Absence réelle et rapports incomplets/non corrélés injectés')
    def cda01():
        assert cda_checks(xml,pdf,ctx,meta)==[]
        assert real_cda['xsd'] is True,real_cda.get('xsdErrors')
        assert len(real_cda['profiles'])==5,real_cda.get('reason')
        b=fresh(); status=check(b,cr=real_cda)
        assert status in ['refuse','simulation_conforme']
        return {'xsd':real_cda['xsd'],'nativeProfiles':real_cda['profiles'],
                'fullCdaConformity':real_cda['status']=='conforme'}
    record('CDA-01',cda01,'XSD et cinq profils réellement exécutés ; identité synthétique non qualifiée')
    def cda02():
        attacks=[b'<ClinicalDocument',b'<!DOCTYPE a [<!ENTITY x SYSTEM "file:///NOT-TO-READ">]><a>&x;</a>',
                 '<!DOCTYPE a [<!ENTITY x SYSTEM "https://example.invalid/">]><a>&x;</a>'.encode('utf-16')]
        for attack in attacks:
            blocked(lambda:parse_xml(attack)); require(check(fresh(),x=attack),'refuse')
    record('CDA-02',cda02,'XML mal formé et entités locales/distantes, dont UTF-16, rejetés avant transformateur')
    def cda03():
        tree=parse_xml(xml); tree.remove(tree.find('c:recordTarget',NS))
        bad=E.tostring(tree); report=native.validate(bad,'recordTarget-absent')
        assert report['xsd'] is False
        require(check(fresh(),x=bad,cr=report),'refuse')
    record('CDA-03',cda03,'Retrait réel de recordTarget, contrôle XSD et schematrons')
    def cda04():
        for value in ['!!!',base64.b64encode(b'other PDF').decode()]:
            tree=parse_xml(xml); tree.find('c:component/c:nonXMLBody/c:text',NS).text=value
            require(check(fresh(),x=E.tostring(tree)),'refuse')
    record('CDA-04',cda04,'Décodage réel strict et comparaison des octets')
    def cda05():
        tree=parse_xml(xml);tree.find('c:component/c:nonXMLBody/c:text',NS).set('mediaType','text/plain')
        require(check(fresh(),x=E.tostring(tree)),'refuse')
        require(check(fresh(),m=dict(meta,formatCode='other')),'refuse')
    record('CDA-05',cda05,'Cohérence MIME/format selon association locale')
    def cda06():
        for key in ['patient','author','structure']:
            changed=dict(ctx);changed[key]='SIM-OTHER'
            require(check(fresh(),x=document(c=changed)),'refuse')
        b=fresh();b.state['current']['context']['patient']='SIM-OTHER'
        require(check(b),'refuse')
    record('CDA-06',cda06,'Cohérence synthétique et liaison de l’accord au contexte')
    def cda07():
        for key in ['title','date','confidentiality','type','class']:
            m=dict(meta); m[key]='INCOHERENT'
            require(check(fresh(),m=m),'refuse')
    record('CDA-07',cda07,'Comparaison des métadonnées ; nomenclatures natives dans CDA-01')
    def cda08():
        for key in ['id','setId','version']:
            m=dict(meta);m[key]='INVALID'
            require(check(fresh(),m=m),'refuse')
        b=fresh();check(b)
        changed=(fixtures/'rapport_modifie.pdf').read_bytes()
        b.load(changed,ctx,poppler);b.review(True,True,list(range(1,b.state['current']['inspection']['pages']+1)))
        require(check(b,x=document(changed)),'refuse')
    record('CDA-08',cda08,'Identifiants/version et collision durable dans un même stockage')
    def cda09():
        for reason in ['moteur absent','dépendance absente','nomenclature absente']:
            r=evidence(xml,'non_verifie',reason=reason)
            require(check(fresh(),cr=r),'non_verifie')
        missing=out/'ressources-absentes'; missing_out=out/'validation-manquante';missing_out.mkdir()
        r=CdaValidator(missing,java,missing_out).validate(xml,'controle')
        require(r['status'],'non_verifie')
        require(check(fresh(),cr=r),'non_verifie')
    record('CDA-09',cda09,'Dépendance réellement absente et erreurs de service injectées')
    def etat01():
        for verdict in ['refuse','non_verifie']:
            b=fresh();require(check(b,pr=simulated(pdf,verdict)),verdict)
            cp=run([sys.executable,str(Path(__file__).resolve()),'--reopen',str(b.root)])
            assert cp.returncode==0,cp.stderr
            state=json.loads(cp.stdout)
            assert state['held'] and state['calls']==0 and state['current']['status']==verdict
            assert state['current']['pdfReport']['status']==verdict
    record('ETAT-01',etat01,'Réouverture par processus distinct : état, motif, retenue et compteur')
    def etat02():
        b=fresh();old_pdf=simulated(pdf);old_cda=simulated(xml)
        b.load((fixtures/'rapport_modifie.pdf').read_bytes(),ctx,poppler)
        assert Bench(b.root).state['approved'] is None
        require(check(b,x=document(b.pdf()),pr=old_pdf,cr=old_cda),'refuse')
        b=fresh(); changed=document()+b'\n'
        require(check(b,x=changed,cr=old_cda),'refuse')
    record('ETAT-02',etat02,'Modification réelle du PDF et CDA ; rapports antérieurs inutilisables')
    states=list(cases.glob('*/journal.json'))
    assert all(json.loads(p.read_text())['calls']==0 for p in states)
    # An independent baseline still succeeds after mutation cases: failures
    # must not pass simply because tests polluted shared context.
    require(check(fresh()),'simulation_conforme')
    states=list(cases.glob('*/journal.json'))
    summary=dict(scenarios=len(results),passed=sum(r['result']=='PASS' for r in results),
                 isolatedStores=len(states),calls=0,pdfAReal=real_pdf['status'],cdaReal=real_cda['status'],
                 conformityDemonstrated=real_pdf['status']==real_cda['status']=='conforme')
    write_json(out/'Synthese.json',summary)
    print(json.dumps(summary,ensure_ascii=False),flush=True)
    return 0 if summary['passed']==18 else 1


if __name__=='__main__':
    if len(sys.argv)==3 and sys.argv[1]=='--reopen':
        print(json.dumps(Bench(Path(sys.argv[2])).state))
    else:
        raise SystemExit(main())
