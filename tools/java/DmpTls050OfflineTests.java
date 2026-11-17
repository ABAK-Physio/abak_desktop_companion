import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.security.cert.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.*;
import java.util.*;
import java.util.concurrent.*;
import javax.net.ssl.*;

/** Synthetic local certificates only. Never opens Cryptolib or a DV1 server. */
public class DmpTls050OfflineTests {
  static int checks;static Path fixtures;static String trustHash;
  static void check(boolean b,String text){if(!b)throw new AssertionError(text);checks++;}
  interface Action{void run()throws Exception;}
  static void blocked(Action action,String text)throws Exception{try{action.run();throw new AssertionError(text);}catch(Exception expected){checks++;}}
  static X509Certificate cert(String n)throws Exception{return (X509Certificate)CertificateFactory.getInstance("X.509").generateCertificate(new ByteArrayInputStream(Files.readAllBytes(fixtures.resolve(n+".der"))));}
  static PrivateKey key(String n)throws Exception{return KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(Files.readAllBytes(fixtures.resolve(n+".key"))));}
  static class Identity implements DmpNativeBridge.Identity {
    final X509Certificate a=cert("auth"),s=cert("sign");final PrivateKey k=key("auth");boolean closed;
    Identity()throws Exception{}
    public X509Certificate auth(){return a;}public X509Certificate signing(){return s;}public PrivateKey authKey(){return k;}
    public byte[] signature(byte[] b){throw new AssertionError("document signing forbidden");}
    public void current()throws Exception{DmpNativeBridge.provePossession(k,a.getPublicKey());}
    public void close(){closed=true;}
  }
  static class Channel implements DmpNativeBridge.Channel {
    int exchanges,closes;boolean failed;
    public Map<String,String> evidence(){return Map.of("channel","local-test","peer","0".repeat(64),"cipher",DmpNativeBridge.CIPHERS[0]);}
    public boolean current(){return closes==0;}
    public DmpNativeBridge.Reply exchange(byte[] b,String type)throws Exception {
      exchanges++;if(failed)throw new SocketTimeoutException("DO NOT LOG secret 123456");
      return new DmpNativeBridge.Reply(200,"HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n",new byte[0]);
    }
    public void close(){closes++;}
  }
  static Map<String,String> fields(int step)throws Exception{
    var f=new HashMap<String,String>();
    f.put("step",""+step);f.put("library","/synthetic/test-only");f.put("trustPath",fixtures.resolve("trust.pem").toString());
    f.put("trustHash",trustHash);f.put("authHash",DmpNativeBridge.sha(cert("auth").getEncoded()));f.put("signHash",DmpNativeBridge.sha(cert("sign").getEncoded()));
    f.put("professional","899700870597");f.put("pin","123456");return f;
  }
  static String request(String endpoint){return "<s:Envelope xmlns:s='"+DmpNativeBridge.SOAP_NS+"' xmlns:w='"+DmpNativeBridge.WSA_NS+"'><s:Header><w:To>"+endpoint+"</w:To><w:Action>urn:hl7-org:v3:PRPA_IN201307UV02</w:Action></s:Header><s:Body><PRPA_IN201307UV02 xmlns='urn:hl7-org:v3'><processingModeCode code='T'/><controlActProcess><reasonCode code='TEST_EXST'/><queryByParameter><parameterList><patientIdentifier><value root='1.2.250.1.213.1.4.10' extension='287019143596041'/></patientIdentifier></parameterList></queryByParameter></controlActProcess></PRPA_IN201307UV02></s:Body></s:Envelope>";}
  static Map<String,String> exchange(String id,String request){return Map.of("id",id,"body",Base64.getEncoder().encodeToString(request.getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\"urn:hl7-org:v3:PRPA_IN201307UV02\"");}
  static void flowTests()throws Exception{
    for(int step=1;step<=3;step++){
      var identity=new Identity();var channel=new Channel();int[] opens={0};char[][] pin={null};
      var runtime=new DmpNativeBridge.Runtime((f,p)->{pin[0]=p;return identity;},(u,i,t)->{opens[0]++;check(u.toString().equals(DmpNativeBridge.Runtime.tlsRecipeEndpoint(fstep(u))),"fixed endpoint");return channel;},Clock.systemUTC());
      var f=fields(step);var opened=runtime.call("tlsrecipeopen",f);
      check(opened.get("outcome").equals("tls_accepted"),"open accepted");check(opens[0]==1,"one TLS channel only");
      check(!f.containsKey("pin")&&new String(pin[0]).chars().allMatch(v->v==0),"PIN removed and cleared");
      for(String op:List.of("open","resume","td","deposit","sign","authorization","current"))blocked(()->runtime.call(op,Map.of()),"normal operations blocked");
      String good=request(opened.get("endpoint"));
      for(String bad:List.of(good.replace("287019143596041","277076322082910"),good.replace("TEST_EXST","UPDATE"),good.replace("processingModeCode code='T'","processingModeCode code='P'"),good.replace("PRPA_IN201307UV02","PRPA_IN201301UV02"),good.replace("<w:To>","<w:To>https://evil.invalid/"),"<!DOCTYPE foo [<!ENTITY x SYSTEM 'file:///etc/passwd'>]>"+good)){
        blocked(()->runtime.call("tlsrecipetd",exchange(opened.get("id"),bad)),"wrong SOAP blocked");
        check(channel.exchanges==0,"no incorrect request transmitted");
      }
      var response=runtime.call("tlsrecipetd",exchange(opened.get("id"),good));
      check(response.get("requestState").equals("completed")&&response.get("outcome").equals("http_received"),"exchange received");
      check(channel.exchanges==1&&channel.closes==1&&identity.closed,"one exchange and cleanup");
      blocked(()->runtime.call("tlsrecipetd",exchange(opened.get("id"),good)),"no duplicate exchange");
    }
    for(String bad:List.of("0","4","https://evil.invalid/","1\n","01")){
      int[] calls={0};var rt=new DmpNativeBridge.Runtime((f,p)->{calls[0]++;throw new AssertionError();},(u,i,t)->{calls[0]++;throw new AssertionError();},Clock.systemUTC());
      var f=fields(1);f.put("step",bad);var r=rt.call("tlsrecipeopen",f);
      check(r.get("outcome").equals("not_conclusive")&&calls[0]==0,"bad step before native activity");
    }
    var errors=new ArrayList<Exception>();
    var certFailure=new SSLHandshakeException("DO NOT LOG secret 123456");certFailure.initCause(new CertificateException("private provider text"));errors.add(certFailure);
    errors.add(new SSLHandshakeException("peer closed"));errors.add(new UnknownHostException("host"));
    errors.add(new SocketTimeoutException("timeout"));errors.add(new SSLProtocolException("protocol"));
    for(int i=0;i<errors.size();i++){
      final Exception e=errors.get(i);var identity=new Identity();var rt=new DmpNativeBridge.Runtime((f,p)->identity,(u,id,t)->{throw e;},Clock.systemUTC());
      var result=rt.call("tlsrecipeopen",fields(1));
      check(result.get("outcome").equals(i==0?"tls_rejected":"not_conclusive"),"certificate versus network classification");
      check(result.get("requestState").equals("not_started")&&identity.closed,"no SOAP after TLS failure and card closed");
      check(!result.get("diagnostic").contains("123456")&&!result.get("diagnostic").contains("private provider text"),"sanitized diagnostics");
    }
    var identity=new Identity();var partial=new Channel();partial.failed=true;
    var rt=new DmpNativeBridge.Runtime((f,p)->identity,(u,id,t)->partial,Clock.systemUTC());
    var opened=rt.call("tlsrecipeopen",fields(1));var r=rt.call("tlsrecipetd",exchange(opened.get("id"),request(opened.get("endpoint"))));
    check(r.get("requestState").equals("started_or_partial")&&r.get("tlsAccepted").equals("true")&&r.get("outcome").equals("not_conclusive"),"uncertain HTTP never implies no emission or certificate rejection");
    for(String mutation:List.of("trust","extra","certificate")){
      int[] calls={0};var badRt=new DmpNativeBridge.Runtime((f,p)->{calls[0]++;return new Identity();},(u,id,t)->{calls[0]++;return new Channel();},Clock.systemUTC());
      var f=fields(1);if(mutation.equals("trust"))f.put("trustHash","0".repeat(64));if(mutation.equals("extra"))f.put("endpoint","https://evil.invalid/");if(mutation.equals("certificate"))f.put("authHash","0".repeat(64));
      var result=badRt.call("tlsrecipeopen",f);check(result.get("outcome").equals("not_conclusive"),"modified config not a server certificate result");
      check(calls[0]<(mutation.equals("certificate")?2:1),"reject modified config before TLS");
    }
    var stale=fields(1);stale.put("trustPath",fixtures.resolve("stale.pem").toString());stale.put("trustHash",DmpNativeBridge.sha(Files.readAllBytes(fixtures.resolve("stale.pem"))));
    int[] calls={0};var staleRt=new DmpNativeBridge.Runtime((f,p)->{calls[0]++;throw new AssertionError();},(u,id,t)->{calls[0]++;throw new AssertionError();},Clock.systemUTC());
    r=staleRt.call("tlsrecipeopen",stale);check(r.get("stage").equals("TRUST")&&r.get("outcome").equals("not_conclusive")&&calls[0]==0,"expired CRL blocks before card and network");
  }
  static String fstep(URI u){return u.getHost().equals("dv1-dmp-lps.dmp.gouv.fr")?"2":u.getHost().contains("fake")?"3":"1";}
  static void realHandshake(String fixture,String host,boolean expected)throws Exception{
    var ks=KeyStore.getInstance("PKCS12");try(var in=Files.newInputStream(fixtures.resolve(fixture+".p12"))){ks.load(in,"local-test-only".toCharArray());}
    var keys=KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());keys.init(ks,"local-test-only".toCharArray());
    var trust=new DmpNativeBridge.Trust(fixtures.resolve("trust.pem"),trustHash,Clock.systemUTC());
    var ctx=SSLContext.getInstance("TLSv1.2");ctx.init(keys.getKeyManagers(),trust.managers(),null);
    try(var server=(SSLServerSocket)ctx.getServerSocketFactory().createServerSocket(0,1,InetAddress.getLoopbackAddress())){
      server.setNeedClientAuth(true);server.setEnabledProtocols(new String[]{"TLSv1.2"});server.setEnabledCipherSuites(DmpNativeBridge.CIPHERS);
      var executor=Executors.newSingleThreadExecutor();
      var future=executor.submit(()->{try(var accepted=(SSLSocket)server.accept()){accepted.setSoTimeout(5000);accepted.startHandshake();}catch(Exception ignored){}});
      var identity=new Identity();var km=new DmpNativeBridge.CardKey(identity,trust.chain(identity.auth()));
      var client=SSLContext.getInstance("TLSv1.2");client.init(new KeyManager[]{km},trust.managers(),null);
      boolean passed=false;
      try(var tcp=new Socket(InetAddress.getLoopbackAddress(),server.getLocalPort());var socket=(SSLSocket)client.getSocketFactory().createSocket(tcp,host,server.getLocalPort(),true)){
        socket.setSSLParameters(DmpNativeBridge.parameters(host));socket.setSoTimeout(5000);socket.startHandshake();
        var evidence=DmpNativeBridge.tlsEvidence(socket.getSession(),km.requested,identity);
        passed=evidence.get("peer").equals(DmpNativeBridge.sha(cert(fixture).getEncoded()));
      }catch(SSLException e){
        if(expected)throw e;
        check(DmpNativeBridge.Runtime.tlsRecipeCertificateFailure(e),"actual TLS rejection is a certificate failure");
        String code=DmpNativeBridge.classify(e);
        String wanted=switch(fixture){case "wrong_san" -> "TLS_HOSTNAME";case "expired" -> "TLS_EXPIRED";case "revoked" -> "TLS_REVOKED";default -> "TLS_TRUST";};
        check(code.equals(wanted),"actual TLS classification "+fixture+" / "+code);
      }
      finally{future.get(6,TimeUnit.SECONDS);executor.shutdownNow();}
      check(passed==expected,"real local TLS "+fixture+" / "+host);
    }
  }
  public static void main(String[] args)throws Exception{
    fixtures=Path.of(args[0]);trustHash=DmpNativeBridge.sha(Files.readAllBytes(fixtures.resolve("trust.pem")));
    flowTests();
    for(String fixture:List.of("cn_lps","cn_lps2"))for(String host:List.of("lps.dmp.gouv.fr","lps2.dmp.gouv.fr"))realHandshake(fixture,host,true);
    for(String fixture:List.of("wrong_san","alien","expired","revoked"))realHandshake(fixture,"lps2.dmp.gouv.fr",false);
    System.out.println("TLS050_OFFLINE_OK checks="+checks+" REAL_CPS=false DV1_NETWORK=false LOOPBACK_TLS=true");
  }
}
