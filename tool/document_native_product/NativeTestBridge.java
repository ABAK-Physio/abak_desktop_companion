import java.io.*;
import java.net.*;
import java.nio.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.security.cert.*;
import java.time.*;
import java.util.*;
import java.util.regex.*;
import javax.net.ssl.*;
import javax.xml.XMLConstants;
import javax.xml.parsers.*;
import org.w3c.dom.*;

/** Test-only injection: software keys and JSSE engines exchanging memory buffers.
 * Never instantiates CardIdentity/SocketChannel. The OS sandbox denies network.
 */
public class NativeTestBridge {
  static final Clock CLOCK=Clock.fixed(Instant.parse("2026-10-17T12:00:00Z"),ZoneOffset.UTC);
  static Path certs,repo,trace;static String scenario;
  static void trace(String op)throws Exception {Files.writeString(trace,op+"\n",StandardOpenOption.CREATE,StandardOpenOption.APPEND);}
  static KeyStore store(String kind)throws Exception {
    var s=KeyStore.getInstance("PKCS12");try(var in=Files.newInputStream(certs.resolve(kind+".p12"))){s.load(in,"synthetic-only".toCharArray());}return s;
  }
  static final class SoftwareIdentity implements DmpNativeBridge.Identity {
    final KeyStore a,s;final String kind;boolean closed;int current;
    SoftwareIdentity(String kind)throws Exception {this.kind=kind;a=store("auth");s=store(kind);}
    public X509Certificate auth(){try{return (X509Certificate)a.getCertificate("auth");}catch(Exception e){throw new RuntimeException(e);}}
    public X509Certificate signing(){try{return (X509Certificate)s.getCertificate(kind);}catch(Exception e){throw new RuntimeException(e);}}
    public PrivateKey authKey(){try{return (PrivateKey)a.getKey("auth","synthetic-only".toCharArray());}catch(Exception e){throw new RuntimeException(e);}}
    public byte[] signature(byte[] b)throws Exception {trace("sign");if(scenario.equals("signature_failure"))throw new DmpNativeBridge.Fault("CPS_ABSENT");return DmpNativeBridge.sign((PrivateKey)s.getKey(kind,"synthetic-only".toCharArray()),b,"SHA1withRSA");}
    public void current()throws Exception {current++;trace("current");if(scenario.equals("card_removed")&&current>2)throw new DmpNativeBridge.Fault("CPS_ABSENT");DmpNativeBridge.need(!closed,"CPS_ABSENT");byte[] b={1,2,3};DmpNativeBridge.verify(auth(),b,DmpNativeBridge.sign(authKey(),b,"SHA1withRSA"),"SHA1withRSA");}
    public void close()throws Exception{closed=true;trace("identity_close");}
  }
  static final class Pipe {
    final SSLEngine client,server;final DmpNativeBridge.CardKey key;
    Pipe(DmpNativeBridge.Identity identity,DmpNativeBridge.Trust trust,String serverKind)throws Exception {
      key=new DmpNativeBridge.CardKey(identity,trust.chain(identity.auth()));
      var c=SSLContext.getInstance("TLSv1.2");c.init(new KeyManager[]{key},trust.managers(),null);
      client=c.createSSLEngine("synthetic.invalid",443);client.setUseClientMode(true);client.setSSLParameters(DmpNativeBridge.parameters("synthetic.invalid"));
      var km=KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());km.init(store(serverKind),"synthetic-only".toCharArray());
      var s=SSLContext.getInstance("TLSv1.2");s.init(km.getKeyManagers(),trust.managers(),null);
      server=s.createSSLEngine();server.setUseClientMode(false);server.setEnabledProtocols(new String[]{"TLSv1.2"});server.setEnabledCipherSuites(DmpNativeBridge.CIPHERS);server.setNeedClientAuth(true);
      client.beginHandshake();server.beginHandshake();
      var ci=ByteBuffer.allocate(131072);var si=ByteBuffer.allocate(131072);
      for(int i=0;i<1000;i++){
        boolean progress=step(client,ci,si)|step(server,si,ci);
        if(client.getHandshakeStatus()==SSLEngineResult.HandshakeStatus.NOT_HANDSHAKING&&server.getHandshakeStatus()==SSLEngineResult.HandshakeStatus.NOT_HANDSHAKING)return;
        DmpNativeBridge.need(progress,"TLS_PROTOCOL");
      }throw new DmpNativeBridge.Fault("TLS_TIMEOUT");
    }
    static boolean step(SSLEngine e,ByteBuffer input,ByteBuffer peer)throws Exception {
      switch(e.getHandshakeStatus()){
        case NEED_TASK -> {Runnable r;while((r=e.getDelegatedTask())!=null)r.run();return true;}
        case NEED_WRAP -> {var packet=ByteBuffer.allocate(65536);var r=e.wrap(ByteBuffer.allocate(0),packet);DmpNativeBridge.need(r.getStatus()==SSLEngineResult.Status.OK,"TLS_PROTOCOL");packet.flip();peer.put(packet);return true;}
        case NEED_UNWRAP -> {if(input.position()==0)return false;input.flip();var r=e.unwrap(input,ByteBuffer.allocate(65536));input.compact();DmpNativeBridge.need(r.getStatus()==SSLEngineResult.Status.OK||r.getStatus()==SSLEngineResult.Status.BUFFER_UNDERFLOW,"TLS_PROTOCOL");return r.bytesConsumed()>0;}
        default -> {return false;}
      }
    }
    byte[] transfer(SSLEngine from,SSLEngine to,byte[] body)throws Exception {
      var source=ByteBuffer.wrap(body);var result=new ByteArrayOutputStream();
      while(source.hasRemaining()){
        var packet=ByteBuffer.allocate(65536);var w=from.wrap(source,packet);DmpNativeBridge.need(w.getStatus()==SSLEngineResult.Status.OK&&w.bytesConsumed()>0,"TLS_PROTOCOL");packet.flip();
        while(packet.hasRemaining()){
          var clear=ByteBuffer.allocate(65536);var r=to.unwrap(packet,clear);DmpNativeBridge.need(r.getStatus()==SSLEngineResult.Status.OK&&r.bytesConsumed()>0,"TLS_PROTOCOL");clear.flip();byte[] bytes=new byte[clear.remaining()];clear.get(bytes);result.write(bytes);
        }
      }
      DmpNativeBridge.need(Arrays.equals(body,result.toByteArray()),"TLS_PROTOCOL");return result.toByteArray();
    }
  }
  static Document xml(byte[] b)throws Exception{
    var f=DocumentBuilderFactory.newInstance();f.setNamespaceAware(true);f.setFeature("http://apache.org/xml/features/disallow-doctype-decl",true);
    f.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD,"");f.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA,"");return f.newDocumentBuilder().parse(new ByteArrayInputStream(b));
  }
  static Element one(Document d,String local){return (Element)d.getElementsByTagNameNS("*",local).item(0);}
  static String message(String s){var m=Pattern.compile("<(?:\\w+:)?MessageID[^>]*>([^<]+)</").matcher(s);if(!m.find())throw new IllegalArgumentException();return m.group(1);}
  static final class MemoryChannel implements DmpNativeBridge.Channel {
    final Pipe pipe;final Map<String,String> evidence;final boolean td;boolean closed;
    MemoryChannel(URI endpoint,DmpNativeBridge.Identity i,DmpNativeBridge.Trust trust)throws Exception {
      td=endpoint.getPath().equals("/td02")||endpoint.getPath().equals("/si-dmp-server/v2/services/patients");trace(td?"tls_td":"tls_deposit");
      if(scenario.equals("tls_timeout"))throw new java.net.SocketTimeoutException();
      pipe=new Pipe(i,trust,scenario.equals("hostname")?"wronghost":"server");
      evidence=DmpNativeBridge.tlsEvidence(pipe.client.getSession(),pipe.key.requested,i);
    }
    public Map<String,String> evidence(){return evidence;}
    public boolean current(){return !closed;}
    public DmpNativeBridge.Reply exchange(byte[] bytes,String type)throws Exception {
      trace(td?"td":"deposit");byte[] received=pipe.transfer(pipe.client,pipe.server,bytes);
      if(scenario.equals("deposit_timeout")&&!td)throw new java.net.SocketTimeoutException();
      String headers;byte[] body;int status=200;
      if(td){
        Files.write(trace.resolveSibling(trace.getFileName()+"-td.xml"),received);
        var d=xml(received);String msg=one(d,"MessageID").getTextContent();
        Element query=one(d,"queryId"),v=one(d,"patientIdentifier");v=(Element)v.getElementsByTagNameNS("*","value").item(0);
        Element id=(Element)one(d,"PRPA_IN201307UV02").getElementsByTagNameNS("*","id").item(0);
        String result="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:w=\"http://www.w3.org/2005/08/addressing\"><s:Header><w:Action>urn:hl7-org:v3:PRPA_IN201308UV02</w:Action><w:RelatesTo>"+(scenario.equals("td_uncorrelated")?"wrong":msg)+"</w:RelatesTo></s:Header><s:Body><PRPA_IN201308UV02 xmlns=\"urn:hl7-org:v3\"><attentionLine><keyWordText code=\"AUTORISATION\"/><value code=\"VALIDE\"/></attentionLine><acknowledgement typeCode=\"AA\"><targetMessage><id root=\""+id.getAttribute("root")+"\" extension=\""+id.getAttribute("extension")+"\"/></targetMessage></acknowledgement><controlActProcess><queryAck><queryId root=\""+query.getAttribute("root")+"\" extension=\""+query.getAttribute("extension")+"\"/><queryResponseCode code=\"OK\"/></queryAck><subject><registrationEvent><subject1><patient><id root=\""+v.getAttribute("root")+"\" extension=\""+v.getAttribute("extension")+"\"/><statusCode code=\"active\"/></patient></subject1></registrationEvent></subject></controlActProcess></PRPA_IN201308UV02></s:Body></s:Envelope>";
        if(scenario.equals("td_soap"))result="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\"><s:Body><s:Fault/></s:Body></s:Envelope>";
        if(scenario.equals("td_503"))status=503;
        if(scenario.equals("td_redirect"))status=302;
        body=result.getBytes(StandardCharsets.UTF_8);type="application/soap+xml";
      }else{
        String kind=scenario.equals("signature_rejected")?"signature":scenario.equals("metadata_rejected")?"metadata":"accepted";
        Path base=repo.resolve("assets/dmp_local/deposit_replay/"+kind);
        String response=Files.readString(Path.of(base+"-response.bin"),StandardCharsets.ISO_8859_1);
        String old=message(Files.readString(Path.of(base+"-request.xml")));
        if(!scenario.equals("deposit_uncorrelated"))response=response.replace(old,message(new String(received,StandardCharsets.UTF_8)));
        body=response.getBytes(StandardCharsets.ISO_8859_1);
        String h=Files.readString(Path.of(base+"-headers.txt"));
        type=Arrays.stream(h.split("\\r?\\n")).filter(l->l.toLowerCase().startsWith("content-type:")).findFirst().orElseThrow().substring(13).trim();
        Files.write(trace.resolveSibling(trace.getFileName()+"-mime.bin"),received);
      }
      headers="HTTP/1.1 "+status+" TEST\r\nContent-Type: "+type+"\r\nContent-Length: "+body.length+"\r\n\r\n";
      var all=new ByteArrayOutputStream();all.write(headers.getBytes(StandardCharsets.US_ASCII));all.write(body);
      return DmpNativeBridge.readHttp(new ByteArrayInputStream(pipe.transfer(pipe.server,pipe.client,all.toByteArray())));
    }
    public void close()throws Exception{closed=true;pipe.client.closeOutbound();pipe.server.closeOutbound();trace(td?"td_close":"deposit_close");}
  }
  static DmpNativeBridge.Runtime runtime(){
    return new DmpNativeBridge.Runtime((cfg,pin)->{
      trace("identity_open");
      if(scenario.equals("pin_wrong"))throw new DmpNativeBridge.Fault("CPS_PIN");
      if(scenario.equals("pin_blocked"))throw new DmpNativeBridge.Fault("CPS_BLOCKED");
      if(scenario.equals("card_absent"))throw new DmpNativeBridge.Fault("CPS_ABSENT");
      return new SoftwareIdentity(Set.of("expired","future","revoked","wrong","no_usage").contains(scenario)?scenario:"sign");
    },MemoryChannel::new,CLOCK);
  }
  public static void main(String[] args)throws Exception {
    certs=Path.of(args[0]);repo=Path.of(args[1]);trace=Path.of(args[2]);scenario=args[3];
    DmpNativeBridge.serve(runtime(),System.in,System.out);
  }
}
