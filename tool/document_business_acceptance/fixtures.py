from pathlib import Path
import sys
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import simpleSplit
from pypdf import PdfReader,PdfWriter
from pypdf.generic import DictionaryObject,NameObject,TextStringObject,NumberObject,ArrayObject,DecodedStreamObject
from xml.sax.saxutils import escape
root=Path(sys.argv[1]); root.mkdir(parents=True,exist_ok=True)
variant=sys.argv[2] if len(sys.argv)>2 else 'rapport' 
font=Path('/Applications/LibreOffice.app/Contents/Resources/fonts/truetype/DejaVuSans.ttf')
pdfmetrics.registerFont(TTFont('Embedded',str(font)))
raw=root/(variant+'-intermediaire.pdf')
c=canvas.Canvas(str(raw),pagesize=(595.28,841.89),pdfVersion=(1,4),pageCompression=1)
y=785
paragraphs=[(12,'DOCUMENT SYNTHETIQUE - NE PAS ENVOYER'),(21,'Rapport clinique SYNTHETIQUE'),(11,'Banc local PDF/CDA - 17 octobre 2026'),(11,'Patient fictif : SYN-P - Patient SYNTHETIQUE'),(11,'Naissance fictive : 01/01/1980'),(11,'Auteur : Kine SYNTHETIQUE | Structure : SYN-CAB'),(11,'Episode fictif : SYN-E'),(15,'Observation simulée'),(11,'Dans cet exercice fictif, le patient décrit une gêne du genou lors de la montée des escaliers. La flexion mesurée pour le test est de 110 degrés. La douleur fictive est cotée à 3 sur 10.'),(15,'Evolution simulée'),(11,"Après les séances fictives, la flexion est de 120 degrés et la douleur de 1 sur 10. La montée d'un étage est décrite comme plus aisée. Ces valeurs servent uniquement à vérifier la conservation du contenu clinique dans le PDF."),(15,'Conclusion du jeu de test'),(11,'Evolution favorable simulée. Aucun soin réel, aucune prescription et aucune donnée de patient réel ne sont associés à ce document.'),(11,'Identité déclarée qualifiée uniquement dans la base synthétique. Aucune signature CPS. Document réservé aux validations techniques hors réseau.')]
if variant=='modifie':
 paragraphs=[(n,txt.replace('120 degrés','125 degrés')) for n,txt in paragraphs]
if variant=='blanc': paragraphs=[]
for size,text in paragraphs:
 c.setFont('Embedded',size);c.setFillColorRGB(.08,.18,.23)
 for line in simpleSplit(text,'Embedded',size,475):
  c.drawString(60,y,line);y-=size*1.45
 y-=12
assert y>50,y
c.showPage();c.save()
w=PdfWriter();w.clone_document_from_reader(PdfReader(raw));w.pdf_header='%PDF-1.4'
w.metadata=None
w.add_metadata({'/Title':'Rapport clinique SYNTHETIQUE'})
icc=DecodedStreamObject();icc.set_data(Path('/System/Library/ColorSync/Profiles/sRGB Profile.icc').read_bytes());icc[NameObject('/N')]=NumberObject(3)
icc[NameObject('/Alternate')]=NameObject('/DeviceRGB')
intent=DictionaryObject({NameObject('/Type'):NameObject('/OutputIntent'),NameObject('/S'):NameObject('/GTS_PDFA1'),NameObject('/OutputConditionIdentifier'):TextStringObject('sRGB IEC61966-2.1'),NameObject('/Info'):TextStringObject('sRGB IEC61966-2.1'),NameObject('/DestOutputProfile'):w._add_object(icc)})
w.root_object[NameObject('/OutputIntents')]=ArrayObject([w._add_object(intent)])
xmp='''<?xpacket begin="\ufeff" id="W5M0MpCehiHzreSzNTczkc9d"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/"><rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"><rdf:Description rdf:about="" xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/" pdfaid:part="1" pdfaid:conformance="B"/><rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title><rdf:Alt><rdf:li xml:lang="x-default">Rapport clinique SYNTHETIQUE</rdf:li></rdf:Alt></dc:title></rdf:Description></rdf:RDF></x:xmpmeta>
<?xpacket end="w"?>'''
m=DecodedStreamObject();m.set_data(xmp.encode());m[NameObject('/Type')]=NameObject('/Metadata');m[NameObject('/Subtype')]=NameObject('/XML');w.root_object[NameObject('/Metadata')]=w._add_object(m)
w.generate_file_identifiers();w.write(root/(variant+'.pdf')); raw.unlink()
