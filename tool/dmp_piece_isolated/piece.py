"""Synthetic attachment -> frozen PDF -> qualified identity -> native PDF/CDA.
No production database defaults, transport, CPS or identity writes.
"""
from pathlib import Path
import sys, stat, subprocess
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'dmp_identity_isolated'))
from identity import *
LIMIT=20*1024*1024
SOURCE_KIND='episode-document-synthetic-1'

class PieceReader(IdentityReader):
    def __init__(self,root,database,verifier=None,hook=None):
        super().__init__(root,database,verifier)
        self.hook=hook
    def file(self,name):
        if not isinstance(name,str) or not name:raise Blocked('Chemin PDF absent')
        path=Path(name)
        if '..' in path.parts or not path.is_absolute():raise Blocked('Chemin PDF interdit')
        try:parts=path.relative_to(self.root).parts
        except ValueError:raise Blocked('PDF hors stockage synthétique')
        if not parts or path.suffix.lower()!='.pdf':raise Blocked('Pièce PDF requise')
        # Traverse using directory descriptors: changing a symlink cannot redirect a read.
        fd=os.open(self.root,os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW)
        try:
            for part in parts[:-1]:
                nxt=os.open(part,os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW,dir_fd=fd);os.close(fd);fd=nxt
            f=os.open(parts[-1],os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK,dir_fd=fd)
            try:
                before=os.fstat(f)
                if not stat.S_ISREG(before.st_mode) or not 0<before.st_size<=LIMIT:raise Blocked('PDF vide, trop volumineux ou non régulier')
                with os.fdopen(os.dup(f),'rb') as stream:data=stream.read(LIMIT+1)
                after=os.fstat(f)
                if (before.st_ino,before.st_size,before.st_mtime_ns,before.st_ctime_ns)!=(after.st_ino,after.st_size,after.st_mtime_ns,after.st_ctime_ns) or len(data)!=before.st_size:raise Blocked('PDF modifié pendant lecture')
            finally:os.close(f)
        finally:os.close(fd)
        if not data.startswith(b'%PDF-') or not data.rstrip().endswith(b'%%EOF'):raise Blocked('Contenu PDF invalide ou tronqué')
        return data
    def document(self,one,document):
        d=one('SELECT * FROM episode_documents WHERE document_id=?',(document,))
        if d['mime_type']!='application/pdf':raise Blocked('Type PDF explicite requis')
        data=self.file(d['file_path']);self.frozen=data
        # Include the complete row, including nulls through an explicit representation.
        row={k:({'null':True} if v is None else v) for k,v in d.items()}
        result={'archived_at':d['archived_at'],'sourceKind':SOURCE_KIND,'row':row,'pdfSha':digest(data),'pdfSize':len(data)}
        return result,d['case_id']
    def read(self,patient,episode,document):
        first=super().read(patient,episode,document)
        if self.hook:self.hook()
        second=super().read(patient,episode,document)
        if first!=second:raise Blocked('Pièce ou identité modifiée pendant capture')
        return second

class PieceWorkflow(IdentityWorkflow):
    """Only new synthetic stores; no legacy receipt or clinical approval inheritance."""
    def current(self,s):
        m,_=snapshot(self.root/s['capture']);c=m['pdfContext']
        i=self.reader.read(c['patient'],c['episode'],c['document'])
        if i!=s['identity'] or s['binding']!=key([SOURCE_KIND,m['version'],i['version'],s['captureEpoch']]):raise Blocked('Pièce ou identité modifiée : nouvelle confirmation requise')
        self.match(m,i)
        return m,i
    @staticmethod
    def match(m,i):
        d=i['payload']['document']
        if d.get('sourceKind')!=SOURCE_KIND or m['pdfSha']!=d['pdfSha'] or m['sourceRevision']!=i['version']:raise Blocked('PDF et pièce non corrélés')
    def stage(self,source,expected_request=None):
        with self.lock():
            s=self.read()
            if expected_request is not None and s.get('selectionRequest')!=expected_request:raise Blocked('Import tardif : sélection remplacée')
            s['history'].append({'binding':s['binding'],'status':s['status'],'event':'nouvelle_capture_piece'})
            s.pop('token',None);s.pop('tokenBinding',None)
            s.update(approved=False,status='non_verifie',identity={},binding='',capture='');self.save(s)
            m,_=snapshot(source);c=m['pdfContext'];i=self.reader.read(c['patient'],c['episode'],c['document']);self.match(m,i)
            name='snapshot-isole-'+uuid.uuid4().hex;shutil.copytree(source,self.root/name)
            epoch=uuid.uuid4().hex
            s.update(capture=name,identity=i,captureEpoch=epoch,binding=key([SOURCE_KIND,m['version'],i['version'],epoch]),message='Pièce et identité cohérentes. Revue versionnée requise.')
            self.save(s)
            try:self.current(s)
            except Exception:
                s.update(approved=False,status='bloque');self.save(s);raise
            return s['binding']
    def approve(self,binding,confirmed):
        try:return super().approve(binding,confirmed)
        except Exception:
            self.recover();raise
    def begin(self):
        try:return super().begin()
        except Exception:
            self.recover();raise

class PieceImport:
    """Calls the actual Dart FinalPdfBench on a bounded frozen copy only.
    Review flags are explicit caller attestations, never derived from a title.
    """
    def __init__(self,workflow,dart,poppler,repo):
        self.flow=workflow;self.dart=str(dart);self.poppler=str(poppler);self.repo=Path(repo)
    def export(self,data,identity,pdf_context,cda_context,review=None):
        expected={'patient','episode','document','author','type','visibility'}
        context_keys={'patient','author','structure','title','date','confidentiality','type','class','id','setId','version'}
        if set(pdf_context)!=expected or set(cda_context)!=context_keys or any(not isinstance(v,str) or not v.strip() for v in [*pdf_context.values(),*cda_context.values()]):raise Blocked('Contexte documentaire explicite incomplet')
        if cda_context['patient']!=pdf_context['patient'] or cda_context['author']!=pdf_context['author']:raise Blocked('Contexte documentaire incohérent')
        if digest(data)!=identity['payload']['document']['pdfSha']:raise Blocked('Copie PDF différente')
        root=self.flow.root/('import-'+uuid.uuid4().hex);root.mkdir();f=root/'piece.pdf';f.write_bytes(data)
        dest=root/('snapshot-isole-'+uuid.uuid4().hex)
        spec={'parent':str(root),'pdf':str(f),'destination':str(dest),'revision':identity['version'],'pdfContext':pdf_context,'context':cda_context,'review':review or {},'poppler':self.poppler}
        write_json(root/'spec.json',spec)
        cp=subprocess.run([self.dart,'--packages='+str(self.repo/'.dart_tool/package_config.json'),str(self.repo/'tool/dmp_piece_isolated/export.dart'),str(root/'spec.json')],cwd=self.repo,capture_output=True,text=True,timeout=60)
        (root/'execution.txt').write_text(cp.stdout+cp.stderr)
        if cp.returncode:raise Blocked('Import ou revue PDF refusés : '+cp.stderr[-1200:])
        snapshot(dest);return dest
    def capture(self,pdf_context,cda_context):
        # Revoke first; a failed capture must not leave a previous approval active.
        with self.flow.lock():
            s=self.flow.read();s['history'].append({'event':'nouvelle_piece','binding':s['binding'],'status':s['status']})
            request=uuid.uuid4().hex
            s.update(selectionRequest=request,approved=False,status='non_verifie',capture='',binding='',identity={});s.pop('token',None);s.pop('tokenBinding',None);self.flow.save(s)
        c=pdf_context;r=self.flow.reader
        i=r.read(c['patient'],c['episode'],c['document']);data=r.frozen
        dest=self.export(data,i,c,cda_context)
        if r.read(c['patient'],c['episode'],c['document'])!=i:raise Blocked('Source changée pendant import')
        return self.flow.stage(dest,expected_request=request)
    def confirm(self,binding,*,pages,clinical,patient,context_confirmed):
        with self.flow.lock():
            s=self.flow.read();m,i=self.flow.current(s)
            if binding!=s['binding'] or context_confirmed is not True:raise Blocked('Confirmation versionnée du contexte requise')
            s.update(approved=False,status='non_verifie');s.pop('token',None);s.pop('tokenBinding',None);self.flow.save(s)
        _,data=snapshot(self.flow.root/s['capture'])
        dest=self.export(data,i,m['pdfContext'],m['cdaContext'],{'pages':pages,'clinical':clinical,'patient':patient,'confirmed':context_confirmed})
        # Recheck source and selection after the external inspector has completed.
        with self.flow.lock():
            current=self.flow.read();self.flow.current(current)
            if current['capture']!=s['capture'] or current['binding']!=binding:raise Blocked('Revue tardive non applicable')
            updated,_=snapshot(dest)
            if updated['version']!=m['version'] or not updated['clinical']:raise Blocked('Revue PDF non applicable')
            # Install an immutable new capture in the existing lineage, no version inheritance.
            name='snapshot-isole-'+uuid.uuid4().hex;shutil.copytree(dest,self.flow.root/name)
            current.update(capture=name,approved=True,status='validee');self.flow.save(current)
        return binding
