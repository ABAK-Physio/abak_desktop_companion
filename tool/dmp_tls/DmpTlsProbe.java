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

/** DMP-only diagnostic. TLS handshake only. No HTTP, SOAP transport or INSi. */
public final class DmpTlsProbe {
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
    if(args[0].equals("--self-test")){selfTest(dir);return;}
    var console=System.console();require(console!=null,"Lancer depuis le raccourci Terminal pour saisir le PIN sans affichage.");
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
      // This is the ONLY network connection to DMP: no HTTP request or application data.
      try(var sock=(SSLSocket)ctx.getSocketFactory().createSocket()){
        sock.setSSLParameters(parameters());sock.setSoTimeout(15000);sock.connect(new InetSocketAddress(HOST,443),10000);sock.startHandshake();
        var session=sock.getSession();var local=session.getLocalCertificates();require(km.requested&&local!=null&&local.length>0&&sha(local[0].getEncoded()).equals(AUTH_FP),"Authentification client TLS non confirmée.");
        var document=vihf(dir.resolve("vihf-modele.xml"),selected,authenticated,true);
        Path result=dir.resolve("resultats").resolve("session-"+UUID.randomUUID());Files.createDirectories(result);
        var tf=TransformerFactory.newInstance();tf.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD,"");tf.setAttribute(XMLConstants.ACCESS_EXTERNAL_STYLESHEET,"");
        var tr=tf.newTransformer();tr.setOutputProperty(OutputKeys.ENCODING,"UTF-8");tr.transform(new DOMSource(document),new StreamResult(result.resolve("vihf-apres-tls.xml").toFile()));
        Files.writeString(result.resolve("rapport.txt"),"TLS mutuel réussi avec Michel\nHôte : "+HOST+"\nProtocole : "+session.getProtocol()+"\nSuite : "+session.getCipherSuite()+"\nDate : "+Instant.now()+"\nAucun HTTP, SOAP, TD0.2 ou TD2.1 envoyé. Aucun dépôt.\nVIHF généré après TLS ; connexion fermée ensuite. Ce fichier est une preuve de génération, pas une session réutilisable.\n");
        session.invalidate();System.out.println("TLS mutuel réussi. VIHF généré : "+result+"\nAucun document envoyé. Connexion fermée.");
      }
    } finally {try{((AuthProvider)provider).logout();}catch(Exception ignored){}Security.removeProvider(provider.getName());}
  }
}
