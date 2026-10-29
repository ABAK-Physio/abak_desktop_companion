import java.nio.file.*;
import java.time.*;
import java.util.*;

/** Synthetic identities and memory-only channels; no card, socket or DV1. */
public class AuthenticationReuseUnit {
  static final class ClockControl extends Clock {
    Instant instant = NativeTestBridge.CLOCK.instant();
    public ZoneId getZone(){return ZoneOffset.UTC;}
    public Clock withZone(ZoneId zone){return this;}
    public Instant instant(){return instant;}
  }
  static final class MemoryChannel implements DmpNativeBridge.Channel {
    boolean closed,used; final String id=UUID.randomUUID().toString();
    public Map<String,String> evidence(){return Map.of("channel",id,"cipher",DmpNativeBridge.CIPHERS[0],"peer","synthetic");}
    public boolean current(){return !closed;}
    public void close(){closed=true;}
    public DmpNativeBridge.Reply exchange(byte[] body,String type)throws Exception {
      DmpNativeBridge.need(!closed&&!used,"SESSION");used=true;
      return new DmpNativeBridge.Reply(200,"",new byte[]{1});
    }
  }
  static final class Fixture implements AutoCloseable {
    ClockControl clock=new ClockControl();
    List<MemoryChannel> channels=new ArrayList<>();
    NativeTestBridge.SoftwareIdentity identity;
    int logins=0;
    Map<String,String> fields=new HashMap<>();
    final DmpNativeBridge.Runtime runtime;
    Fixture(Path dir)throws Exception {
      identity=new NativeTestBridge.SoftwareIdentity("sign");
      fields.putAll(Map.of("tdEndpoint","https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients",
        "depositEndpoint","https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository",
        "trustPath",dir.resolve("trust.pem").toString(),"trustHash",DmpNativeBridge.sha(Files.readAllBytes(dir.resolve("trust.pem"))),
        "authHash",DmpNativeBridge.sha(identity.auth().getEncoded()),"signHash",DmpNativeBridge.sha(identity.signing().getEncoded()),
        "professional",DmpNativeBridge.cn(identity.auth()),"accessOnly","true","reuseAuthentication","true"));
      runtime=new DmpNativeBridge.Runtime((cfg,pin)->{logins++;return identity;},(url,i,t)->{
        var channel=new MemoryChannel();channels.add(channel);return channel;
      },clock);
    }
    Map<String,String> open()throws Exception {
      var initial=new HashMap<>(fields);initial.put("pin","1234");
      return runtime.call("open",initial);
    }
    void td(String id)throws Exception {
      runtime.call("td",Map.of("id",id,"body","AQ==","contentType","application/soap+xml; charset=UTF-8; action=\"urn:hl7-org:v3:PRPA_IN201307UV02\""));
    }
    public void close()throws Exception {runtime.close();}
  }
  static void check(boolean ok,String label){if(!ok)throw new AssertionError(label);System.out.println("PASS "+label);}
  interface Attempt {void run()throws Exception;}
  static void rejects(Attempt a,String label)throws Exception {try{a.run();}catch(Exception e){check(true,label);return;}throw new AssertionError(label);}
  public static void main(String[] args)throws Exception {
    Path dir=Path.of(args[0]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";
    NativeTestBridge.trace=Path.of(args[1]);
    try(var f=new Fixture(dir)){
      var first=f.open();String firstId=first.get("id");f.td(firstId);
      rejects(()->f.td(firstId),"one-shot transaction preserved");
      f.runtime.call("park",Map.of("id",firstId));
      check(f.channels.stream().allMatch(c->c.closed),"all TLS channels closed at park");
      check(!f.identity.closed,"authenticated identity retained");
      rejects(()->f.td(firstId),"no transaction allowed while parked");
      f.runtime.call("authenticationcheck",Map.of());
      check(f.channels.size()==2,"presence check opens no network channel");
      f.clock.instant=f.clock.instant.plusSeconds(300);
      var next=f.runtime.call("resume",new HashMap<>(f.fields));
      check(f.logins==1,"second transaction needs no PIN/login");
      check(!next.get("id").equals(firstId)&&!next.get("tdChannel").equals(first.get("tdChannel")),"fresh transaction and channels");
      check(next.get("authenticationExpiresAt").equals(first.get("authenticationExpiresAt")),"reuse does not extend authentication deadline");
      check(Duration.between(Instant.parse(next.get("issuedAt")),Instant.parse(next.get("expiresAt"))).getSeconds()==120,"transaction limit remains two minutes");
      rejects(()->f.td(firstId),"previous transaction ID rejected");
      f.td(next.get("id"));
      rejects(()->f.runtime.call("sign",Map.of("id",next.get("id"))),"reuse cannot enable signing");
      f.runtime.call("park",Map.of("id",next.get("id")));
      f.close();check(f.identity.closed,"closing logs out retained card");
    }
    try(var f=new Fixture(dir)){
      var result=f.open();f.runtime.call("park",Map.of("id",result.get("id")));
      var changed=new HashMap<>(f.fields);changed.put("professional","99999999999");
      rejects(()->f.runtime.call("resume",changed),"different practitioner rejected");
      check(f.identity.closed,"failed resume closes card");
    }
    try(var f=new Fixture(dir)){
      var result=f.open();f.runtime.call("park",Map.of("id",result.get("id")));
      f.identity.close();
      rejects(()->f.runtime.call("resume",new HashMap<>(f.fields)),"withdrawn card rejected before fresh TLS");
      check(f.channels.size()==2,"no network after card withdrawal");
    }
    try(var f=new Fixture(dir)){
      var result=f.open();f.runtime.call("park",Map.of("id",result.get("id")));
      f.clock.instant=f.clock.instant.plusSeconds(3600);
      rejects(()->f.runtime.call("resume",new HashMap<>(f.fields)),"authentication expires after one hour");
      check(f.channels.size()==2,"no network on expiry");
    }
    try(var f=new Fixture(dir)){
      f.fields.remove("reuseAuthentication");var result=f.open();
      rejects(()->f.runtime.call("park",Map.of("id",result.get("id"))),"legacy transaction cannot be retained");
    }
    try(var f=new Fixture(dir)){
      f.fields.put("accessOnly","false");f.fields.remove("reuseAuthentication");
      var opened=f.open();String id=opened.get("id");f.td(id);
      byte[] body="synthetic SignedInfo".getBytes(java.nio.charset.StandardCharsets.UTF_8);
      var request=Map.of("id",id,"signHash",f.fields.get("signHash"),"body",Base64.getEncoder().encodeToString(body));
      var signed=f.runtime.call("sign",request);
      var verifier=java.security.Signature.getInstance("SHA1withRSA");
      verifier.initVerify(f.identity.signing().getPublicKey());verifier.update(body);
      check(verifier.verify(Base64.getDecoder().decode(signed.get("signature"))),"TD0.2 then contentCommitment-only signing succeeds");
      check(!f.channels.get(1).used,"signing does not submit a deposit");
      rejects(()->f.runtime.call("sign",request),"second signature is refused");
    }
    System.out.println("Authentication reuse checks passed; card calls=0; network calls=0");
  }
}
