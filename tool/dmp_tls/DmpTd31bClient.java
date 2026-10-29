import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.security.*;
import java.security.cert.*;
import java.time.Instant;
import java.util.*;
import javax.net.ssl.*;
import javax.xml.XMLConstants;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.*;

/** One TD0.2 request only; no document upload and no INSi. */
public final class DmpTd31bClient {
  static final String HOST="lps.dev1.dmp.gouv.fr";
  static final String AUTH_FP="1e04facfd63a8d3f60eb61233db5f763350716399f5639e5bd5bfff278423320";
  static final String ROOT_FP="2d9e22ca19f777c6b745257c723ecb8df3c35fa6f1f6ec36b83600c97346967f";
  static final String SAML="urn:oasis:names:tc:SAML:2.0:assertion";
  static String sha(byte[] b)throws Exception{return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(b));}
  static X509Certificate cert(Path p)throws Exception{try(InputStream s=Files.newInputStream(p)){return (X509Certificate)CertificateFactory.getInstance("X.509").generateCertificate(s);}}
  static void require(boolean ok,String message){if(!ok)throw new IllegalStateException(message);}
  static void checkAuth(X509Certificate c)throws Exception{
    c.checkValidity();require(sha(c.getEncoded()).equals(AUTH_FP),"La carte ne porte pas le certificat d'authentification de Michel attendu.");
    require(c.getExtendedKeyUsage()!=null&&c.getExtendedKeyUsage().contains("1.3.6.1.5.5.7.3.2"),"Usage TLS client absent.");
    require(c.getKeyUsage()!=null&&c.getKeyUsage()[0],"Usage digitalSignature absent.");
  }
  static Document parse(Path p)throws Exception{
    var f=DocumentBuilderFactory.newInstance();f.setNamespaceAware(true);
    f.setFeature("http://apache.org/xml/features/disallow-doctype-decl",true);
    f.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD,"");f.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA,"");
    return f.newDocumentBuilder().parse(p.toFile());
  }
  static Element one(Document d,String name){var list=d.getElementsByTagNameNS(SAML,name);require(list.getLength()==1,"Champ SAML absent ou dupliqué : "+name);return (Element)list.item(0);}
  static String attribute(Document d,String name){var l=d.getElementsByTagNameNS(SAML,"Attribute");String v=null;for(int i=0;i<l.getLength();i++){var e=(Element)l.item(i);if(e.getAttribute("Name").equals(name)){require(v==null,"Attribut dupliqué");v=e.getTextContent();}}return v;}
  static Document vihf(Path template,X509Certificate c,Instant authenticated,boolean mutualTlsVerified)throws Exception{
    require(mutualTlsVerified,"VIHF interdit avant authentification TLS mutuelle réussie.");checkAuth(c);
    require(authenticated!=null&&!authenticated.isAfter(Instant.now())&&authenticated.isAfter(Instant.now().minusSeconds(3600)),"Session CPS trop ancienne.");
    var d=parse(template);require(one(d,"NameID").getTextContent().equals("899700870597"),"Utilisateur VIHF inattendu.");
    require("499700870597009".equals(attribute(d,"Identifiant_Structure")),"Structure inattendue.");
    require("DIRECTE".equals(attribute(d,"Authentification_Mode")),"Mode inattendu.");
    require("3.0".equals(attribute(d,"VIHF_Version")),"Version VIHF inattendue.");
    require("SA07^1.2.250.1.71.4.2.4".equals(attribute(d,"Secteur_Activite")),"Secteur inattendu.");
    require("ABAK DESKTOP COMPANION".equals(attribute(d,"LPS_Nom")) && "1.0.2".equals(attribute(d,"LPS_Version")),"Logiciel inattendu.");
    var roles=d.getElementsByTagNameNS("urn:hl7-org:v3","Role");
    require(roles.getLength()==1 && ((Element)roles.item(0)).getAttribute("code").equals("70"),"Profession inattendue.");
    require("187012425258307^^^&1.2.250.1.213.1.4.10&ISO^NH".equals(attribute(d,"urn:oasis:names:tc:xacml:2.0:resource:resource-id")),"Patient inattendu.");
    var a=one(d,"Assertion");a.setAttribute("ID","_"+UUID.randomUUID());a.setAttribute("IssueInstant",Instant.now().toString());
    one(d,"Issuer").setTextContent(c.getSubjectX500Principal().getName("RFC2253"));
    one(d,"AuthnStatement").setAttribute("AuthnInstant",authenticated.toString());
    return d;
  }
  static SSLParameters parameters(){var p=new SSLParameters();p.setProtocols(new String[]{"TLSv1.2"});p.setCipherSuites(new String[]{"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"});p.setEndpointIdentificationAlgorithm("HTTPS");p.setServerNames(List.of(new SNIHostName(HOST)));return p;}
  static final class CardKey extends X509ExtendedKeyManager {
    final PrivateKey key;final X509Certificate[] chain;boolean requested;
    CardKey(PrivateKey k,X509Certificate[] c){key=k;chain=c.clone();}
    String pick(String[] types,Principal[] issuers){
      if(types==null||!Arrays.asList(types).contains("RSA"))return null;
      if(issuers!=null&&issuers.length>0&&Arrays.stream(issuers).noneMatch(i->Arrays.stream(chain).anyMatch(c->c.getIssuerX500Principal().equals(i))))return null;
      requested=true;return "michel-auth";
    }
    public String chooseClientAlias(String[] t,Principal[] i,Socket s){return pick(t,i);}
    public String chooseEngineClientAlias(String[] t,Principal[] i,SSLEngine s){return pick(t,i);}
    public String[] getClientAliases(String t,Principal[] i){return "RSA".equals(t)?new String[]{"michel-auth"}:null;}
    public String chooseServerAlias(String t,Principal[] i,Socket s){return null;}
    public String[] getServerAliases(String t,Principal[] i){return null;}
    public PrivateKey getPrivateKey(String a){return "michel-auth".equals(a)?key:null;}
    public X509Certificate[] getCertificateChain(String a){return "michel-auth".equals(a)?chain.clone():null;}
  }
  static TrustManagerFactory serverTrust(Path dir,KeyStore trust,Instant at)throws Exception {
    // Use signed local CRLs only. No OCSP/CRL URL fetch, no soft-fail.
    System.setProperty("com.sun.security.enableCRLDP","false");
    System.setProperty("com.sun.security.enableAIAcaIssuers","false");
    var cf=CertificateFactory.getInstance("X.509");
    Collection<? extends CRL> crls;
    try(var stream=Files.newInputStream(dir.resolve("server-crls.pem"))){crls=cf.generateCRLs(stream);}
    require(crls.size()==2,"Deux CRL serveur officielles sont nécessaires.");
    var root=cert(dir.resolve("ACR-EL.pem"));var intermediate=cert(dir.resolve("dv1-server-1.pem"));
    intermediate.checkValidity();intermediate.verify(root.getPublicKey());
    Set<Principal> issuers=new HashSet<>();
    for(var raw:crls){
      var crl=(X509CRL)raw;
      require(crl.getNextUpdate()!=null&&!at.isBefore(crl.getThisUpdate().toInstant())&&at.isBefore(crl.getNextUpdate().toInstant()),
          "CRL expirée ou non encore valide : renouveler les CRL officielles avant le test (aucune tentative PIN).");
      var issuer=crl.getIssuerX500Principal();require(issuers.add(issuer),"CRL dupliquée.");
      require(issuer.equals(root.getSubjectX500Principal())||issuer.equals(intermediate.getSubjectX500Principal()),"Émetteur CRL inattendu.");
      crl.verify(issuer.equals(root.getSubjectX500Principal())?root.getPublicKey():intermediate.getPublicKey());
    }
    var params=new PKIXBuilderParameters(trust,new X509CertSelector());params.setRevocationEnabled(true);
    params.addCertStore(CertStore.getInstance("Collection",new CollectionCertStoreParameters(crls)));
    var rc=(PKIXRevocationChecker)CertPathValidator.getInstance("PKIX").getRevocationChecker();
    rc.setOptions(Set.of(PKIXRevocationChecker.Option.PREFER_CRLS,PKIXRevocationChecker.Option.NO_FALLBACK));params.addCertPathChecker(rc);
    var tmf=TrustManagerFactory.getInstance("PKIX");tmf.init(new CertPathTrustManagerParameters(params));return tmf;
  }
  static void checkServerChain(Path dir, X509Certificate root)throws Exception {
    var cf=CertificateFactory.getInstance("X.509");
    var chain=cf.generateCertPath(List.of(cert(dir.resolve("dv1-server-0.pem")),cert(dir.resolve("dv1-server-1.pem"))));
    var params=new PKIXParameters(Set.of(new TrustAnchor(root,null)));params.setRevocationEnabled(true);
    try(var stream=Files.newInputStream(dir.resolve("server-crls.pem"))){
      params.addCertStore(CertStore.getInstance("Collection",new CollectionCertStoreParameters(cf.generateCRLs(stream))));
    }
    var validator=CertPathValidator.getInstance("PKIX");
    var rc=(PKIXRevocationChecker)validator.getRevocationChecker();
    rc.setOptions(Set.of(PKIXRevocationChecker.Option.PREFER_CRLS,PKIXRevocationChecker.Option.NO_FALLBACK));
    params.addCertPathChecker(rc);validator.validate(chain,params);
  }
  static void selfTest(Path dir)throws Exception{
    var c=cert(dir.resolve("certificat-authentification.der"));checkAuth(c);
    try{vihf(dir.resolve("vihf-modele.xml"),c,Instant.now(),false);throw new AssertionError("VIHF prématuré accepté");}catch(IllegalStateException expected){}
    try{vihf(dir.resolve("vihf-modele.xml"),c,Instant.now().minusSeconds(3601),true);throw new AssertionError("Session expirée acceptée");}catch(IllegalStateException expected){}
    var first=vihf(dir.resolve("vihf-modele.xml"),c,Instant.now(),true);var second=vihf(dir.resolve("vihf-modele.xml"),c,Instant.now(),true);
    require(!one(first,"Assertion").getAttribute("ID").equals(one(second,"Assertion").getAttribute("ID")),"ID SAML réutilisé");
    require(one(first,"Issuer").getTextContent().equals(c.getSubjectX500Principal().getName("RFC2253")),"Issuer incorrect");
    require(parameters().getEndpointIdentificationAlgorithm().equals("HTTPS"),"Hostname non contrôlé");
    try{checkAuth(cert(dir.resolve("certificat-signature.pem")));throw new AssertionError("Certificat signature accepté pour TLS");}catch(IllegalStateException expected){}
    require(sha(cert(dir.resolve("ACR-EL.pem")).getEncoded()).equals(ROOT_FP),"Racine inattendue");
    var store=KeyStore.getInstance("PKCS12");store.load(null,null);store.setCertificateEntry("root",cert(dir.resolve("ACR-EL.pem")));
    var tmf=serverTrust(dir,store,Instant.now());
    ((X509TrustManager)tmf.getTrustManagers()[0]).checkServerTrusted(new X509Certificate[]{cert(dir.resolve("dv1-server-0.pem")),cert(dir.resolve("dv1-server-1.pem"))},"ECDHE_RSA");
    try{serverTrust(dir,store,Instant.now().plusSeconds(60L*24*3600));throw new AssertionError("CRL expirées acceptées");}catch(IllegalStateException expected){}
    checkServerChain(dir,cert(dir.resolve("ACR-EL.pem")));
    try {checkServerChain(dir,cert(dir.resolve("ACR-EL-TEST.pem")));throw new AssertionError("Racine de test incorrecte acceptée pour DV1");}catch(CertPathValidatorException expected){}
    System.out.println("Contrôles hors ligne réussis : identité/usage du certificat, refus certificat signature, blocage VIHF avant TLS, expiration, unicité SAML, Issuer, hostname, racine serveur et chaîne PKIX/révocation DV1. Aucun accès réseau ni PIN.");
  }
  public static void main(String[] args)throws Exception{
    require(args.length==2&&(args[0].equals("--self-test")||args[0].equals("--connect")),"Usage : --self-test|--connect dossier-configuration");
    Path dir=Path.of(args[1]).toAbsolutePath();
    if(args[0].equals("--self-test")){selfTest(dir);testTd02(dir);testSearch(dir);return;}
    var console=System.console();require(console!=null,"Lancer depuis le raccourci Terminal pour saisir le PIN sans affichage.");
    if(!"RECHERCHER".equals(console.readLine("TD0.2 puis recherche du document R6, sans modification. Tapez RECHERCHER ou Entrée pour annuler : ")))return;
    Path lib=Path.of("/usr/local/lib/libcps3_pkcs11_osx.dylib");require(Files.isRegularFile(lib),"Cryptolib CPS absente.");
    var root=cert(dir.resolve("ACR-EL.pem"));root.checkValidity();require(sha(root.getEncoded()).equals(ROOT_FP),"Racine serveur IGC-Santé incorrecte.");
    var trust=KeyStore.getInstance("PKCS12");trust.load(null,null);trust.setCertificateEntry("ACR-EL",root);
    var tmf=serverTrust(dir,trust,Instant.now());
    String cfg="name=ABAK_DMP_MICHEL\nlibrary="+lib+"\nslotListIndex=0\ndisabledMechanisms={ CKM_SHA224_RSA_PKCS CKM_SHA256_RSA_PKCS CKM_SHA384_RSA_PKCS CKM_SHA512_RSA_PKCS }\n";
    Provider provider=Security.getProvider("SunPKCS11").configure("--"+cfg);Security.addProvider(provider);
    try {
      char[] pin=console.readPassword("CPS de Michel — PIN (une seule tentative, Entrée pour annuler) : ");
      if(pin==null||pin.length==0)return;
      KeyStore card=KeyStore.getInstance("PKCS11",provider);Instant authenticated;
      try{card.load(null,pin);authenticated=Instant.now();}finally{Arrays.fill(pin,'\0');}
      String alias=null;X509Certificate selected=null;
      for(var it=card.aliases();it.hasMoreElements();){String a=it.nextElement();var c=card.getCertificate(a);if(c instanceof X509Certificate x&&sha(x.getEncoded()).equals(AUTH_FP)){require(alias==null,"Certificat ambigu");alias=a;selected=x;}}
      require(alias!=null,"Insérez la CPS de Michel avec son certificat d'authentification attendu.");checkAuth(selected);
      PrivateKey key=(PrivateKey)card.getKey(alias,null);require(key!=null,"Clé d'authentification CPS inaccessible.");
      // Intermediate comes from the already verified official local material.
      var intermediate=cert(dir.resolve("ACI-FO-PP-TEST.pem"));selected.verify(intermediate.getPublicKey());
      var km=new CardKey(key,new X509Certificate[]{selected,intermediate});var ctx=SSLContext.getInstance("TLSv1.2");ctx.init(new KeyManager[]{km},tmf.getTrustManagers(),null);
      Path result=dir.resolve("resultats").resolve("td31b-"+UUID.randomUUID());Files.createDirectories(result);
      System.out.println("Résultats : "+result);
      try {
        exchange(ctx,km,selected,authenticated,dir,result,false);
        exchange(ctx,km,selected,authenticated,dir,result,true);
      } catch(Exception e){Files.writeString(result.resolve("erreur.txt"),e.toString()+"\nArrêt sans réessai, aucun dépôt ni modification.\n");throw e;}
    } finally {try{((AuthProvider)provider).logout();}catch(Exception ignored){}Security.removeProvider(provider.getName());}
  }
  static final String SOAP="http://www.w3.org/2003/05/soap-envelope", HL7="urn:hl7-org:v3", WSA="http://www.w3.org/2005/08/addressing";
  static final String ACTION="urn:hl7-org:v3:PRPA_IN201307UV02", ENDPOINT="https://"+HOST+"/si-dmp-server/v2/services/patients";
  static org.w3c.dom.NodeList nodes(Document d,String path)throws Exception{
    var x=javax.xml.xpath.XPathFactory.newInstance().newXPath();
    x.setNamespaceContext(new javax.xml.namespace.NamespaceContext(){
      public String getNamespaceURI(String p){return Map.of("s",SOAP,"h",HL7,"w",WSA,"a",SAML,"sec","http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd").getOrDefault(p,XMLConstants.NULL_NS_URI);}
      public String getPrefix(String s){throw new UnsupportedOperationException();}public Iterator<String> getPrefixes(String s){throw new UnsupportedOperationException();}
    });return (NodeList)x.evaluate(path,d,javax.xml.xpath.XPathConstants.NODESET);
  }
  static Element element(Document d,String path)throws Exception{var n=nodes(d,path);require(n.getLength()==1,"Champ XML absent ou dupliqué : "+path);return (Element)n.item(0);}
  static byte[] serialize(Document d)throws Exception{var f=TransformerFactory.newInstance();f.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD,"");f.setAttribute(XMLConstants.ACCESS_EXTERNAL_STYLESHEET,"");var t=f.newTransformer();t.setOutputProperty(OutputKeys.ENCODING,"UTF-8");var out=new ByteArrayOutputStream();t.transform(new DOMSource(d),new StreamResult(out));return out.toByteArray();}
  static Document parseBytes(byte[] bytes)throws Exception{var f=DocumentBuilderFactory.newInstance();f.setNamespaceAware(true);f.setFeature("http://apache.org/xml/features/disallow-doctype-decl",true);f.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD,"");f.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA,"");return f.newDocumentBuilder().parse(new ByteArrayInputStream(bytes));}
  static void guardRequest(Document d)throws Exception{
    require(element(d,"/s:Envelope/s:Header/w:Action").getTextContent().equals(ACTION),"Seule TD0.2 est permise.");
    require(element(d,"/s:Envelope/s:Header/w:To").getTextContent().equals(ENDPOINT),"Seul le service patients DV1 est permis.");
    var body=element(d,"/s:Envelope/s:Body");require(nodes(d,"/s:Envelope/s:Body/*").getLength()==1,"Une seule opération permise.");
    element(d,"/s:Envelope/s:Body/h:PRPA_IN201307UV02");
    require(element(d,"//h:controlActProcess/h:reasonCode").getAttribute("code").equals("TEST_EXST"),"Seul TEST_EXST est permis.");
    var id=element(d,"//h:parameterList/h:patientIdentifier/h:value");
    require(id.getAttribute("extension").equals("187012425258307")&&id.getAttribute("root").equals("1.2.250.1.213.1.4.10"),"Patient non autorisé.");
    require(nodes(d,"//*[local-name()='Document' or local-name()='Include' or local-name()='ClinicalDocument' or local-name()='ProvideAndRegisterDocumentSetRequest']").getLength()==0,"Pièce jointe ou dépôt interdit.");
    require(one(d,"NameID").getTextContent().equals("899700870597"),"Michel uniquement.");
    require("187012425258307^^^&1.2.250.1.213.1.4.10&ISO^NH".equals(attribute(d,"urn:oasis:names:tc:xacml:2.0:resource:resource-id")),"Patient VIHF incorrect.");
  }
  static Document makeRequest(Path dir,Document assertion)throws Exception{
    var d=parse(dir.resolve("td02-modele.xml"));guardRequest(d);
    var security=element(d,"/s:Envelope/s:Header/sec:Security");
    // Official TD0.2 example omits mustUnderstand on wsse:Security. Keep the VIHF.
    security.removeAttributeNS(SOAP,"mustUnderstand");
    while(security.hasChildNodes())security.removeChild(security.getFirstChild());security.appendChild(d.importNode(assertion.getDocumentElement(),true));
    element(d,"/s:Envelope/s:Header/w:MessageID").setTextContent("urn:uuid:"+UUID.randomUUID());
    element(d,"//h:PRPA_IN201307UV02/h:id").setAttribute("extension",UUID.randomUUID().toString());
    element(d,"//h:queryByParameter/h:queryId").setAttribute("extension",UUID.randomUUID().toString());
    element(d,"//h:PRPA_IN201307UV02/h:creationTime").setAttribute("value",java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss").withZone(java.time.ZoneOffset.UTC).format(Instant.now()));
    guardRequest(d);return d;
  }
  record HttpResponse(int status,String headers,byte[] body){}
  static final int LIMIT=2*1024*1024;
  static String line(InputStream in)throws IOException{var out=new ByteArrayOutputStream();for(int i=0;i<8192;i++){int c=in.read();if(c<0)throw new EOFException("HTTP incomplet");if(c==10){var s=out.toString(java.nio.charset.StandardCharsets.US_ASCII);if(!s.endsWith("\r"))throw new IOException("Fin de ligne HTTP invalide");return s.substring(0,s.length()-1);}out.write(c);}throw new IOException("Ligne HTTP trop longue");}
  static byte[] exact(InputStream in,int n)throws IOException{if(n<0||n>LIMIT)throw new IOException("Réponse trop grande");var b=in.readNBytes(n);if(b.length!=n)throw new EOFException("Réponse tronquée");return b;}
  static HttpResponse readHttp(InputStream raw)throws Exception{
    var in=new BufferedInputStream(raw);int interim=0;
    while(true){String status=line(in);require(status.matches("HTTP/1\\.[01] [0-9]{3}.*"),"Statut HTTP invalide");int code=Integer.parseInt(status.substring(9,12));StringBuilder h=new StringBuilder(status+"\n");Map<String,String> map=new HashMap<>();
      for(int count=0;;count++){require(count<100,"Trop d'en-têtes HTTP");String l=line(in);if(l.isEmpty())break;h.append(l).append('\n');require(h.length()<32768,"En-têtes trop longs");int colon=l.indexOf(':');require(colon>0,"En-tête HTTP invalide");String k=l.substring(0,colon).toLowerCase(Locale.ROOT),v=l.substring(colon+1).trim();if(k.equals("content-length")||k.equals("transfer-encoding"))require(!map.containsKey(k),"Encadrement HTTP ambigu");map.put(k,v);}
      if(code>=100&&code<200){require(code!=101&&++interim<=3,"Réponse intermédiaire inattendue");continue;}
      require(!map.containsKey("content-encoding")||map.get("content-encoding").equalsIgnoreCase("identity"),"Compression HTTP non prise en charge");
      var body=new ByteArrayOutputStream();
      if(map.containsKey("transfer-encoding")){
        require(!map.containsKey("content-length")&&map.get("transfer-encoding").equalsIgnoreCase("chunked"),"Encadrement HTTP non pris en charge");
        while(true){String l=line(in).split(";",2)[0].trim();long size=Long.parseLong(l,16);require(size>=0&&size<=LIMIT-body.size(),"Réponse trop grande");if(size==0){for(int i=0;;i++){require(i<100,"Trop de trailers");if(line(in).isEmpty())break;}break;}body.write(exact(in,(int)size));require(line(in).isEmpty(),"Chunk HTTP incorrect");}
      }else if(map.containsKey("content-length")){body.write(exact(in,Integer.parseInt(map.get("content-length"))));}
      else{byte[] buf=new byte[8192];for(int n;(n=in.read(buf))!=-1;){require(body.size()+n<=LIMIT,"Réponse trop grande");body.write(buf,0,n);}}
      return new HttpResponse(code,h.toString(),body.toByteArray());
    }
  }
  static boolean sameId(Element a,Element b){return a.getAttribute("root").equals(b.getAttribute("root"))&&a.getAttribute("extension").equals(b.getAttribute("extension"));}
  // Decode the SOAP root of a bounded multipart response, without network access.
  static String header(String block,String name){
    String found=null;
    for(String line:block.replaceAll("\\r?\\n[ \\t]+"," ").split("\\r?\\n")){
      int colon=line.indexOf(':');
      if(colon>0&&line.substring(0,colon).equalsIgnoreCase(name)){
        require(found==null,"En-tête dupliqué : "+name);found=line.substring(colon+1).trim();
      }
    }return found;
  }
  static String parameter(String value,String key){
    var pattern=java.util.regex.Pattern.compile("(?:^|;)\\s*"+key+"\\s*=\\s*(?:\"([^\"]*)\"|([^;\\s]+))",java.util.regex.Pattern.CASE_INSENSITIVE);
    var matcher=pattern.matcher(value);String found=null;
    while(matcher.find()){require(found==null,"Paramètre MIME dupliqué : "+key);found=matcher.group(1)!=null?matcher.group(1):matcher.group(2);}return found;
  }
  static byte[] soapBody(HttpResponse response){
    require(response.body().length<=LIMIT,"Réponse trop grande");
    String type=header(response.headers(),"content-type");
    if(type==null||!type.toLowerCase(Locale.ROOT).startsWith("multipart/related"))return response.body();
    String boundary=parameter(type,"boundary"),start=parameter(type,"start");
    require(boundary!=null&&!boundary.isEmpty()&&boundary.length()<=200&&!boundary.contains("\r")&&!boundary.contains("\n"),"Frontière MIME invalide");
    String body=new String(response.body(),java.nio.charset.StandardCharsets.ISO_8859_1);
    String marker="--"+boundary;
    int pos=body.startsWith(marker)?0:body.indexOf("\r\n"+marker)+2;
    require(pos>=0&&body.startsWith(marker,pos),"Frontière MIME absente");
    byte[] root=null;Set<String> ids=new HashSet<>();int count=0;
    while(true){
      require(body.startsWith(marker,pos),"Frontière MIME incorrecte");pos+=marker.length();
      if(body.startsWith("--",pos))break;
      require(body.startsWith("\r\n",pos)&&++count<=100,"Partie MIME invalide");pos+=2;
      int endHeaders=body.indexOf("\r\n\r\n",pos);require(endHeaders>=pos&&endHeaders-pos<32768,"En-têtes MIME invalides");
      String headers=body.substring(pos,endHeaders);int next=body.indexOf("\r\n"+marker,endHeaders+4);require(next>=0,"Réponse MIME tronquée");
      String id=header(headers,"content-id");if(id!=null)require(ids.add(id),"Content-ID dupliqué");
      if(start==null?count==1:start.equals(id)){
        require(root==null,"Racine SOAP dupliquée");
        String partType=header(headers,"content-type");require(partType!=null&&(partType.toLowerCase(Locale.ROOT).startsWith("application/xop+xml")||partType.toLowerCase(Locale.ROOT).startsWith("application/soap+xml")),"Type de racine SOAP inattendu");
        String encoding=header(headers,"content-transfer-encoding");
        require(encoding==null||encoding.equalsIgnoreCase("binary")||encoding.equalsIgnoreCase("8bit")||encoding.equalsIgnoreCase("7bit"),"Encodage MIME non pris en charge");
        root=body.substring(endHeaders+4,next).getBytes(java.nio.charset.StandardCharsets.ISO_8859_1);
      }pos=next+2;
    }
    require(root!=null,"Racine SOAP absente");return root;
  }


  static String describe(HttpResponse response,Document request)throws Exception{
    if(response.status()>=300&&response.status()<400)return "Redirection HTTP "+response.status()+" : arrêt, aucun suivi automatique. État du DMP non déterminé.";
    Document d;try{d=parseBytes(soapBody(response));}catch(Exception e){return "HTTP "+response.status()+" : réponse non XML exploitable. État du DMP non déterminé.";}
    if(nodes(d,"/s:Envelope/s:Body/s:Fault").getLength()>0)return "Erreur SOAP (HTTP "+response.status()+"). Consulter reponse.xml. État du DMP non déterminé.";
    require(response.status()>=200&&response.status()<300,"Erreur HTTP "+response.status()+" ; état DMP non déterminé.");
    require(element(d,"/s:Envelope/s:Header/w:RelatesTo").getTextContent().equals(element(request,"/s:Envelope/s:Header/w:MessageID").getTextContent()),"Réponse non corrélée à cette requête.");
    require(element(d,"/s:Envelope/s:Header/w:Action").getTextContent().equals("urn:hl7-org:v3:PRPA_IN201308UV02"),"Action réponse inattendue.");
    element(d,"/s:Envelope/s:Body/h:PRPA_IN201308UV02");
    require(sameId(element(d,"//h:acknowledgement/h:targetMessage/h:id"),element(request,"//h:PRPA_IN201307UV02/h:id")),"Identifiant message non corrélé.");
    if(!element(d,"//h:acknowledgement").getAttribute("typeCode").equals("AA"))return "Erreur applicative HL7. Consulter reponse.xml. État DMP non déterminé.";
    require(sameId(element(d,"//h:queryAck/h:queryId"),element(request,"//h:queryByParameter/h:queryId")),"Identifiant requête non corrélé.");
    String code=element(d,"//h:queryAck/h:queryResponseCode").getAttribute("code");
    if(code.equals("NF")){require(nodes(d,"//h:controlActProcess/h:subject").getLength()==0,"Réponse NF contradictoire");return "TD0.2 : aucun DMP trouvé (NF). Aucun dépôt effectué.";}
    if(!code.equals("OK"))return "Réponse HL7 "+code+" : état DMP non déterminé. Consulter reponse.xml.";
    var patients=nodes(d,"//h:registrationEvent/h:subject1/h:patient");require(patients.getLength()==1,"Patient réponse absent ou ambigu.");
    var ids=nodes(d,"//h:registrationEvent/h:subject1/h:patient/h:id[@root='1.2.250.1.213.1.4.10']");require(ids.getLength()==1&&((Element)ids.item(0)).getAttribute("extension").equals("187012425258307"),"Patient réponse différent.");
    String status=element(d,"//h:registrationEvent/h:subject1/h:patient/h:statusCode").getAttribute("code");
    String text="TD0.2 : DMP trouvé. Statut retourné : "+status+(status.equals("active")?" (actif).":" (à interpréter avant poursuite).");
    var auth=nodes(d,"//h:PRPA_IN201308UV02/h:attentionLine[h:keyWordText/@code='AUTORISATION']/h:value");if(auth.getLength()==1)text+="\nAutorisation de consultation : "+((Element)auth.item(0)).getAttribute("code")+" (distincte de l'alimentation).";
    return text+"\nAucun trait patientPerson affiché ; aucune autorisation modifiée.";
  }
  static void testTd02(Path dir)throws Exception{
    var a=vihf(dir.resolve("vihf-modele.xml"),cert(dir.resolve("certificat-authentification.der")),Instant.now(),true);var d=makeRequest(dir,a);guardRequest(d);
    require(!element(d,"/s:Envelope/s:Header/sec:Security").hasAttributeNS(SOAP,"mustUnderstand"),"Security mustUnderstand incompatible avec DV1");
    require(one(d,"Assertion").getAttribute("ID").equals(one(a,"Assertion").getAttribute("ID")),"VIHF altéré pendant assemblage");
    Files.write(dir.resolve("requete-test-hors-ligne.xml"),serialize(d));
    var bad=(Document)d.cloneNode(true);element(bad,"/s:Envelope/s:Header/w:Action").setTextContent("urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b");try{guardRequest(bad);throw new AssertionError("Dépôt accepté");}catch(IllegalStateException expected){}
    bad=(Document)d.cloneNode(true);element(bad,"//h:patientIdentifier/h:value").setAttribute("extension","autre");try{guardRequest(bad);throw new AssertionError("Autre patient accepté");}catch(IllegalStateException expected){}
    for(String input:List.of("HTTP/1.1 200 OK\r\nContent-Length: 3\r\n\r\nabc","HTTP/1.1 100 Continue\r\n\r\nHTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n3\r\nabc\r\n0\r\n\r\n")){require(new String(readHttp(new ByteArrayInputStream(input.getBytes())).body()).equals("abc"),"Décodage HTTP incorrect");}
    try{readHttp(new ByteArrayInputStream("HTTP/1.1 200 OK\r\nContent-Length: 9\r\n\r\na".getBytes()));throw new AssertionError("Troncature acceptée");}catch(EOFException expected){}
    var reply=parse(dir.resolve("reponse-exemple.xml"));
    element(reply,"/s:Envelope/s:Header/w:RelatesTo").setTextContent(element(d,"/s:Envelope/s:Header/w:MessageID").getTextContent());
    for(String[] pair:new String[][]{{"//h:acknowledgement/h:targetMessage/h:id","//h:PRPA_IN201307UV02/h:id"},{"//h:queryAck/h:queryId","//h:queryByParameter/h:queryId"}}){var dest=element(reply,pair[0]);var source=element(d,pair[1]);dest.setAttribute("root",source.getAttribute("root"));dest.setAttribute("extension",source.getAttribute("extension"));}
    element(reply,"//h:patient/h:id[@root='1.2.250.1.213.1.4.10']").setAttribute("extension","187012425258307");
    require(describe(new HttpResponse(200,"",serialize(reply)),d).contains("(actif)"),"DMP actif non identifié");
    var nf=(Document)reply.cloneNode(true);var subject=element(nf,"//h:controlActProcess/h:subject");subject.getParentNode().removeChild(subject);element(nf,"//h:queryResponseCode").setAttribute("code","NF");require(describe(new HttpResponse(200,"",serialize(nf)),d).contains("aucun DMP"),"NF non identifié");
    element(reply,"/s:Envelope/s:Header/w:RelatesTo").setTextContent("urn:uuid:autre");try{describe(new HttpResponse(200,"",serialize(reply)),d);throw new AssertionError("Réponse non corrélée acceptée");}catch(IllegalStateException expected){}
    require(describe(new HttpResponse(500,"","erreur".getBytes()),d).contains("non déterminé"),"Erreur assimilée à absence");
    System.out.println("Tests TD0.2 hors ligne réussis : requête bornée, refus dépôt/autre patient, HTTP length/chunked/tronqué, réponse active/NF, corrélation, erreur technique. Aucun envoi.");
  }
  static Element xmlOne(Document d,String ns,String name){var n=d.getElementsByTagNameNS(ns,name);require(n.getLength()==1,"Champ absent ou dupliqué : "+name);return (Element)n.item(0);}
  static final String QUERY="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0", RIM="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0", RS="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0";
  static final String SEARCH_ACTION="urn:ihe:iti:2007:RegistryStoredQuery", SEARCH_ENDPOINT="https://"+HOST+"/si-dmp-server/v2/services/registry";
  static final String UNIQUE_ID="2.25.319790098659318552794330109432267023866", GET_DOCUMENTS="urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4";
  static Document searchRequest(Path dir,Document assertion)throws Exception{
    var d=makeRequest(dir,assertion);
    element(d,"/s:Envelope/s:Header/w:Action").setTextContent(SEARCH_ACTION);
    element(d,"/s:Envelope/s:Header/w:To").setTextContent(SEARCH_ENDPOINT);
    var body=element(d,"/s:Envelope/s:Body");while(body.hasChildNodes())body.removeChild(body.getFirstChild());
    var query=d.createElementNS(QUERY,"q:AdhocQueryRequest");body.appendChild(query);
    var options=d.createElementNS(QUERY,"q:ResponseOption");options.setAttribute("returnComposedObjects","true");options.setAttribute("returnType","ObjectRef");query.appendChild(options);
    var adhoc=d.createElementNS(RIM,"rim:AdhocQuery");adhoc.setAttribute("id",GET_DOCUMENTS);query.appendChild(adhoc);
    var slot=d.createElementNS(RIM,"rim:Slot");slot.setAttribute("name","$XDSDocumentEntryUniqueId");adhoc.appendChild(slot);
    var list=d.createElementNS(RIM,"rim:ValueList");slot.appendChild(list);var value=d.createElementNS(RIM,"rim:Value");value.setTextContent("('"+UNIQUE_ID+"')");list.appendChild(value);
    guardSearch(d);return d;
  }
  static void guardSearch(Document d)throws Exception{
    require(element(d,"/s:Envelope/s:Header/w:Action").getTextContent().equals(SEARCH_ACTION),"Action TD3.1b requise");
    require(element(d,"/s:Envelope/s:Header/w:To").getTextContent().equals(SEARCH_ENDPOINT),"Registry DV1 uniquement");
    var body=element(d,"/s:Envelope/s:Body");require(nodes(d,"/s:Envelope/s:Body/*").getLength()==1,"Opération unique requise");
    var query=body.getFirstChild();require(query instanceof Element&&QUERY.equals(query.getNamespaceURI())&&"AdhocQueryRequest".equals(query.getLocalName()),"Recherche uniquement");
    require(xmlOne(d,QUERY,"ResponseOption").getAttribute("returnType").equals("ObjectRef"),"LeafClass interdit");
    require(xmlOne(d,RIM,"AdhocQuery").getAttribute("id").equals(GET_DOCUMENTS),"GetDocuments uniquement");
    var slots=d.getElementsByTagNameNS(RIM,"Slot");require(slots.getLength()==1,"Un seul paramètre de recherche");
    require(((Element)slots.item(0)).getAttribute("name").equals("$XDSDocumentEntryUniqueId"),"UniqueId uniquement");
    require(d.getElementsByTagNameNS(RIM,"Value").getLength()==1&&d.getElementsByTagNameNS(RIM,"Value").item(0).getTextContent().equals("('"+UNIQUE_ID+"')"),"Document R6 uniquement");
    require(one(d,"NameID").getTextContent().equals("899700870597"),"Michel uniquement");
    require(attribute(d,"urn:oasis:names:tc:xacml:2.0:resource:resource-id").equals("187012425258307^^^&1.2.250.1.213.1.4.10&ISO^NH"),"Patient inattendu");
  }
  static void requireActive(HttpResponse response,Document request)throws Exception{
    // describe validates HTTP, SOAP, patient and all correlation identifiers.
    String summary=describe(response,request);
    require(summary.startsWith("TD0.2 : DMP trouvé. Statut retourné : active (actif)."),"TD3.1b non envoyée : "+summary);
    var d=parseBytes(soapBody(response));
    var auth=nodes(d,"//h:PRPA_IN201308UV02/h:attentionLine[h:keyWordText/@code='AUTORISATION']/h:value");
    // Conservative test gate; a consultation authorization is not a general requirement of ObjectRef.
    if(auth.getLength()>0)require(auth.getLength()==1&&((Element)auth.item(0)).getAttribute("code").equals("VALIDE"),"État des droits différent du cas vérifié : analyse manuelle avant recherche. Aucune autorisation modifiée.");
  }
  static String searchResult(HttpResponse response,Document request)throws Exception{
    require(response.status()>=200&&response.status()<300,"Erreur HTTP, recherche non confirmée");
    var d=parseBytes(soapBody(response));
    require(element(d,"/s:Envelope/s:Header/w:RelatesTo").getTextContent().equals(element(request,"/s:Envelope/s:Header/w:MessageID").getTextContent()),"Réponse non corrélée");
    require(nodes(d,"/s:Envelope/s:Body/s:Fault").getLength()==0,"Erreur SOAP, recherche non confirmée");
    require(element(d,"/s:Envelope/s:Header/w:Action").getTextContent().equals(SEARCH_ACTION+"Response"),"Action réponse inattendue");
    var replies=d.getElementsByTagNameNS(QUERY,"AdhocQueryResponse");require(replies.getLength()==1,"Réponse XDS absente ou ambiguë");
    var reply=(Element)replies.item(0);var errors=d.getElementsByTagNameNS(RS,"RegistryError");StringBuilder details=new StringBuilder();
    for(int i=0;i<errors.getLength();i++){var e=(Element)errors.item(i);details.append(e.getAttribute("errorCode")).append(": ").append(e.getAttribute("codeContext")).append("\n");}
    require(reply.getAttribute("status").equals("urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success")&&errors.getLength()==0,"Recherche XDS non exploitable : "+details);
    var lists=reply.getElementsByTagNameNS(RIM,"RegistryObjectList");require(lists.getLength()==1,"Liste XDS absente ou ambiguë");
    List<String> ids=new ArrayList<>();
    for(var n=lists.item(0).getFirstChild();n!=null;n=n.getNextSibling())if(n instanceof Element e){
      require(RIM.equals(e.getNamespaceURI())&&e.getLocalName().equals("ObjectRef"),"Objet inattendu : ObjectRef uniquement");
      String id=e.getAttribute("id");require(id.matches("urn:uuid:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"),"entryUUID invalide");ids.add(id);
    }
    require(ids.size()==1,"Résultat vide ou ambigu ("+ids.size()+" références) : ne pas remplacer ni supprimer");return ids.get(0);
  }
  static void exchange(SSLContext ctx,CardKey km,X509Certificate selected,Instant authenticated,Path dir,Path result,boolean search)throws Exception{
    String step=search?"td31b":"td02";
    try(var sock=(SSLSocket)ctx.getSocketFactory().createSocket()){
      sock.setSSLParameters(parameters());sock.setSoTimeout(15000);sock.connect(new InetSocketAddress(HOST,443),10000);sock.startHandshake();
      var session=sock.getSession();try{
        var local=session.getLocalCertificates();require(km.requested&&local!=null&&local.length>0&&sha(local[0].getEncoded()).equals(AUTH_FP),"TLS Michel non confirmé");
        var assertion=vihf(dir.resolve("vihf-modele.xml"),selected,authenticated,true);
        var request=search?searchRequest(dir,assertion):makeRequest(dir,assertion);
        if(search)guardSearch(request);else guardRequest(request);
        byte[] xml=serialize(request);Files.write(result.resolve(step+"-requete.xml"),xml);Files.write(result.resolve(step+"-vihf.xml"),serialize(assertion));
        String action=search?SEARCH_ACTION:ACTION;String service=search?"registry":"patients";
        String headers="POST /si-dmp-server/v2/services/"+service+" HTTP/1.1\r\nHost: "+HOST+"\r\nContent-Type: application/soap+xml; charset=UTF-8; action=\""+action+"\"\r\nContent-Length: "+xml.length+"\r\nConnection: close\r\nAccept-Encoding: identity\r\n\r\n";
        Files.writeString(result.resolve(step+"-entetes.txt"),headers);
        sock.getOutputStream().write(headers.getBytes(java.nio.charset.StandardCharsets.US_ASCII));sock.getOutputStream().write(xml);sock.getOutputStream().flush();
        var response=readHttp(sock.getInputStream());Files.write(result.resolve(step+"-reponse-brute.bin"),response.body());Files.writeString(result.resolve(step+"-http.txt"),response.headers());
        Files.write(result.resolve(step+"-reponse.xml"),soapBody(response));
        if(search){String id=searchResult(response,request);Files.writeString(result.resolve("entryUUID.txt"),id+"\n");String report="TD3.1b réussie : "+UNIQUE_ID+" -> "+id+"\nÀ récupérer de nouveau juste avant une future modification. Aucun remplacement ni suppression effectué.\n";Files.writeString(result.resolve("rapport.txt"),report);System.out.println(report);}
        else{String report=describe(response,request);Files.writeString(result.resolve("td02-rapport.txt"),report);System.out.println(report);requireActive(response,request);}
      }finally{session.invalidate();}
    }
  }
  static void testSearch(Path dir)throws Exception{
    var assertion=vihf(dir.resolve("vihf-modele.xml"),cert(dir.resolve("certificat-authentification.der")),Instant.now(),true);
    var q=searchRequest(dir,assertion);Files.write(dir.resolve("TD31B-TEST-HORS-LIGNE.xml"),serialize(q));
    var bad=(Document)q.cloneNode(true);xmlOne(bad,QUERY,"ResponseOption").setAttribute("returnType","LeafClass");try{guardSearch(bad);throw new AssertionError("LeafClass accepté");}catch(IllegalStateException expected){}
    bad=(Document)q.cloneNode(true);bad.getElementsByTagNameNS(RIM,"Value").item(0).setTextContent("('autre')");try{guardSearch(bad);throw new AssertionError("Autre document accepté");}catch(IllegalStateException expected){}
    String mid=element(q,"/s:Envelope/s:Header/w:MessageID").getTextContent();
    String text="<s:Envelope xmlns:s='"+SOAP+"' xmlns:w='"+WSA+"'><s:Header><w:Action>"+SEARCH_ACTION+"Response</w:Action><w:RelatesTo>"+mid+"</w:RelatesTo></s:Header><s:Body><q:AdhocQueryResponse xmlns:q='"+QUERY+"' status='urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success'><r:RegistryObjectList xmlns:r='"+RIM+"'><r:ObjectRef id='urn:uuid:11111111-2222-3333-4444-555555555555'/></r:RegistryObjectList></q:AdhocQueryResponse></s:Body></s:Envelope>";
    require(searchResult(new HttpResponse(200,"",text.getBytes()),q).endsWith("555555555555"),"ObjectRef non reconnu");
    String mime="\r\n--test\r\nContent-Type: application/xop+xml\r\nContent-ID: <soap>\r\n\r\n"+text+"\r\n--test--";
    searchResult(new HttpResponse(200,"Content-Type: multipart/related; boundary=\"test\"; start=\"<soap>\"",mime.getBytes()),q);
    for(String invalid:List.of(text.replace(mid,"autre"),text.replace("ResponseStatusType:Success","ResponseStatusType:Failure"),text.replaceAll("<r:ObjectRef[^>]*/>",""),text.replace("</r:RegistryObjectList>","<r:ObjectRef id='urn:uuid:aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'/></r:RegistryObjectList>"))){try{searchResult(new HttpResponse(200,"",invalid.getBytes()),q);throw new AssertionError("Réponse invalide acceptée");}catch(IllegalStateException expected){}}
    // Reuse the official TD0.2 response with fresh correlation fields.
    var request=makeRequest(dir,assertion);var reply=parse(dir.resolve("reponse-exemple.xml"));
    element(reply,"/s:Envelope/s:Header/w:RelatesTo").setTextContent(element(request,"/s:Envelope/s:Header/w:MessageID").getTextContent());
    for(String[] pair:new String[][]{{"//h:acknowledgement/h:targetMessage/h:id","//h:PRPA_IN201307UV02/h:id"},{"//h:queryAck/h:queryId","//h:queryByParameter/h:queryId"}}){var dest=element(reply,pair[0]);var src=element(request,pair[1]);dest.setAttribute("root",src.getAttribute("root"));dest.setAttribute("extension",src.getAttribute("extension"));}
    element(reply,"//h:patient/h:id[@root='1.2.250.1.213.1.4.10']").setAttribute("extension","187012425258307");
    requireActive(new HttpResponse(200,"",serialize(reply)),request);
    element(reply,"//h:patient/h:statusCode").setAttribute("code","closed");try{requireActive(new HttpResponse(200,"",serialize(reply)),request);throw new AssertionError("DMP fermé accepté");}catch(IllegalStateException expected){}
    try{requireActive(new HttpResponse(500,"","erreur".getBytes()),request);throw new AssertionError("Erreur acceptée");}catch(IllegalStateException expected){}
    System.out.println("TD3.1b : tests hors ligne ObjectRef/XML/MTOM, corrélation, zéro/multiples résultats, refus LeafClass/autre document, arrêt après TD0.2 fermé/erreur réussis. Aucun envoi.");
  }

}
