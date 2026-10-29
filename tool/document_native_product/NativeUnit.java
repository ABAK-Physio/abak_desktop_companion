import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.net.URI;
import java.util.*;
import javax.net.ssl.*;

/** Offline boundary checks, independent of Flutter and with no real card. */
public class NativeUnit {
  static List<String> checks=new ArrayList<>();
  interface Run {void run()throws Exception;}
  static void check(boolean ok,String name){if(!ok)throw new AssertionError(name);checks.add(name);}
  static void refuses(Run fn,String name)throws Exception {boolean refused=false;try{fn.run();}catch(Exception e){refused=true;}check(refused,name);}
  static DmpNativeBridge.Reply http(String input)throws Exception{return DmpNativeBridge.readHttp(new ByteArrayInputStream(input.getBytes(StandardCharsets.ISO_8859_1)));}
  public static void main(String[] args)throws Exception {
    Path dir=Path.of(args[0]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[1]+".trace");
    var trust=new DmpNativeBridge.Trust(dir.resolve("trust.pem"),DmpNativeBridge.sha(Files.readAllBytes(dir.resolve("trust.pem"))),NativeTestBridge.CLOCK);
    try(var identity=new NativeTestBridge.SoftwareIdentity("sign")){
      trust.chain(identity.auth());trust.chain(identity.signing());check(true,"PKIX local : authentification et signature valides");
      var signing=identity.signing();
      check(signing.getCriticalExtensionOIDs().contains("2.5.29.15")&&!signing.getKeyUsage()[0]&&signing.getKeyUsage()[1],"certificat de signature critique Non Repudiation seul");
      refuses(()->java.security.Signature.getInstance("SHA1withRSA").initVerify(signing),"régression reproduite : initVerify(certificat) refuse cet usage");
      byte[] signedMessage="synthetic document signature".getBytes(StandardCharsets.UTF_8);
      byte[] signature=identity.signature(signedMessage);
      DmpNativeBridge.verify(signing,signedMessage,signature,"SHA1withRSA");
      check(true,"signature Non Repudiation vérifiée avec la clé publique");
      refuses(()->DmpNativeBridge.verify(signing,new byte[]{1},signature,"SHA1withRSA"),"contenu modifié refusé");
      refuses(()->DmpNativeBridge.verify(identity.auth(),signedMessage,signature,"SHA1withRSA"),"signature sous une autre clé refusée");
      refuses(()->DmpNativeBridge.verify(signing,signedMessage,new byte[1],"SHA1withRSA"),"signature tronquée refusée");
      try(var noUsage=new NativeTestBridge.SoftwareIdentity("no_signature")){
        refuses(()->DmpNativeBridge.verify(noUsage.signing(),signedMessage,noUsage.signature(signedMessage),"SHA1withRSA"),"certificat sans usage de signature refusé malgré une signature correcte");
      }
      var pipe=new NativeTestBridge.Pipe(identity,trust,"server");
      check(pipe.key.requested&&pipe.client.getSession().getProtocol().equals("TLSv1.2"),"TLS mutuel réel JSSE en mémoire");
      check(DmpNativeBridge.sha(pipe.server.getSession().getPeerCertificates()[0].getEncoded()).equals(DmpNativeBridge.sha(identity.auth().getEncoded())),"serveur simulé : certificat client authentifié");
      byte[] message=new byte[1024*1024];new Random(7).nextBytes(message);
      check(Arrays.equals(message,pipe.transfer(pipe.client,pipe.server,message)),"1 Mio chiffré et déchiffré sans socket");
      refuses(()->new NativeTestBridge.Pipe(identity,trust,"wronghost"),"nom serveur différent refusé par JSSE");
      for(String kind:List.of("expired","future","revoked"))try(var bad=new NativeTestBridge.SoftwareIdentity(kind)){
        refuses(()->trust.chain(bad.signing()),"PKIX certificat "+kind+" refusé");}
    }
    for(String kind:List.of("stale","bad_crl"))refuses(()->new DmpNativeBridge.Trust(dir.resolve(kind+".pem"),DmpNativeBridge.sha(Files.readAllBytes(dir.resolve(kind+".pem"))),NativeTestBridge.CLOCK),"CRL "+kind+" refusée");
    refuses(()->new DmpNativeBridge.Trust(dir.resolve("trust.pem"),"0".repeat(64),NativeTestBridge.CLOCK),"bundle remplacé refusé");
    for(String url:List.of("http://synthetic.invalid/a","https://u:p@synthetic.invalid/a","https://synthetic.invalid/a?redirect=x","https://synthetic.invalid/"+"#fragment"))refuses(()->DmpNativeBridge.Runtime.endpoint(url),"adresse ambiguë refusée : "+url);
    var params=DmpNativeBridge.parameters("synthetic.invalid");
    check(params.getEndpointIdentificationAlgorithm().equals("HTTPS")&&Arrays.equals(params.getProtocols(),new String[]{"TLSv1.2"})&&params.getCipherSuites().length==2,"TLS : hostname, protocole et suites imposés");
    check(new String(http("HTTP/1.1 200 OK\r\nContent-Length: 3\r\n\r\nabc").body()).equals("abc"),"HTTP Content-Length exact");
    check(new String(http("HTTP/1.1 100 Continue\r\n\r\nHTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n3\r\nabc\r\n0\r\n\r\n").body()).equals("abc"),"HTTP 100 puis chunked");
    for(String bad:List.of(
      "HTTP/1.1 200 OK\r\nContent-Length: 9\r\n\r\na",
      "HTTP/1.1 200 OK\r\nContent-Length: 3\r\nContent-Length: 4\r\n\r\nabc",
      "HTTP/1.1 200 OK\r\nContent-Length: 3\r\nTransfer-Encoding: chunked\r\n\r\nabc",
      "HTTP/1.1 200 OK\r\nContent-Encoding: gzip\r\n\r\n",
      "HTTP/1.1 200 OK\r\nContent-Length: 9999999\r\n\r\n",
      "HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n3\r\nab",
      "HTTP/1.1 200 OK\r\n folded: value\r\n\r\n",
      "HTTP/1.1 101 Upgrade\r\n\r\n"))refuses(()->http(bad),"HTTP ambigu/tronqué refusé "+checks.size());
    check(http("HTTP/1.1 302 Found\r\nLocation: https://other.invalid/\r\nContent-Length: 0\r\n\r\n").status()==302,"redirection conservée comme refus, jamais suivie");
    check(DmpNativeBridge.classify(new java.net.SocketTimeoutException("PIN SECRET")).equals("TLS_TIMEOUT"),"erreur brute remplacée par code fixe");
    check(DmpNativeBridge.classify(new java.security.InvalidKeyException("Wrong key usage")).equals("CPS_CRYPTO_FAILURE"),"usage cryptographique erroné non classé TLS");
    check(DmpNativeBridge.classify(new java.security.SignatureException("invalid length")).equals("CPS_CRYPTO_FAILURE"),"signature invalide non classée TLS");
    check(DmpNativeBridge.classify(new java.security.SignatureException("provider",new java.security.ProviderException("CKR_KEY_FUNCTION_NOT_PERMITTED"))).equals("CPS_KEY_USAGE"),"code CPS spécifique conservé");
    var tlsFailure=new SSLHandshakeException("TLS failure");tlsFailure.initCause(new java.security.InvalidKeyException("server key"));
    check(DmpNativeBridge.classify(tlsFailure).equals("TLS_TRUST"),"erreur de handshake reste TLS");
    check(DmpNativeBridge.classify(new java.security.cert.CertPathBuilderException("untrusted")).equals("TLS_TRUST"),"chaîne non fiable reste refusée TLS");
    Files.writeString(Path.of(args[1]),"{\"count\":"+checks.size()+",\"checks\":["+String.join(",",checks.stream().map(s->"\""+s.replace("\"","\\\"")+"\"").toList())+"],\"networkCalls\":0,\"cpsCalls\":0}");
    System.out.println(checks.size()+" contrôles natifs réussis");
  }
}
