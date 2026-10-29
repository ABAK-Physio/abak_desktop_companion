import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/** Full runtime sequence, synthetic identity and memory-only channels. */
public class DepublicationUnit {
 static final String TARGET="urn:uuid:11111111-2222-3333-4444-555555555555";
 static final class Channel implements DmpNativeBridge.Channel {
  final boolean registry;
  final AuthenticationReuseUnit.MemoryChannel delegate=new AuthenticationReuseUnit.MemoryChannel();
  public Map<String,String> evidence(){return delegate.evidence();}
  public boolean current(){return delegate.current();}
  public void close(){delegate.close();}
  Channel(boolean registry){this.registry=registry;}
  public DmpNativeBridge.Reply exchange(byte[] body,String type)throws Exception {
   delegate.exchange(body,type);
   String response=type.contains("RegistryStoredQuery")?
    "<s:Envelope xmlns:s='"+DmpNativeBridge.SOAP_NS+"'><s:Body><AdhocQueryResponse xmlns='"+DmpNativeBridge.QUERY_NS+"' status='urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success'><rim:RegistryObjectList xmlns:rim='"+DmpNativeBridge.RIM_NS+"'><rim:ObjectRef id='"+TARGET+"'/></rim:RegistryObjectList></AdhocQueryResponse></s:Body></s:Envelope>":"ok";
   return new DmpNativeBridge.Reply(200,"",response.getBytes(StandardCharsets.UTF_8));
  }
 }
 static Map<String,String> call(String id,String request) {
  return Map.of("id",id,"body",Base64.getEncoder().encodeToString(request.getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\""+DmpNativeBridge.DELETE_ACTION+"\"");
 }
 public static void main(String[] args)throws Exception {
  Path certs=Path.of(args[0]);NativeTestBridge.certs=certs;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[2]);
  String request=Files.readString(Path.of(args[1]));
  DmpNativeBridge.checkDeletion(request.getBytes(StandardCharsets.UTF_8),TARGET);
  for(String bad:List.of(request.replace("StatusType:Deleted","StatusType:Approved"),request.replace(TARGET,"urn:uuid:99999999-2222-3333-4444-555555555555"),request.replace("OriginalStatus","OtherStatus"),request.replace("UpdateAvailabilityStatus","RPLC"))) {
   AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkDeletion(bad.getBytes(StandardCharsets.UTF_8),TARGET),"unsafe update rejected");
  }
  for(String scenario:List.of("success","noCapability","noSearch","repeat","wrongTarget","expired")) {
   try(var fixture=new AuthenticationReuseUnit.Fixture(certs)) {
    var fields=new HashMap<>(fixture.fields);fields.remove("reuseAuthentication");fields.put("pin","1234");
    if(!scenario.equals("noCapability"))fields.put("depublicationUniqueId","2.25.123");
    var channels=new ArrayList<Channel>();
    try(var runtime=new DmpNativeBridge.Runtime((f,p)->fixture.identity,(url,i,t)->{var ch=new Channel(url.toString().endsWith("registry"));channels.add(ch);return ch;},fixture.clock)) {
     String id=runtime.call("open",fields).get("id");
     runtime.call("td",Map.of("id",id,"body","AQ==","contentType","application/soap+xml; charset=UTF-8; action=\"urn:hl7-org:v3:PRPA_IN201307UV02\""));
     if(!scenario.equals("noSearch"))runtime.call("search",Map.of("id",id,"body",Base64.getEncoder().encodeToString(ReplacementSearchUnit.query("2.25.123").getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\""+DmpNativeBridge.SEARCH_ACTION+"\""));
     if(scenario.equals("expired"))fixture.clock.instant=fixture.clock.instant.plusSeconds(121);
     if(scenario.equals("success")||scenario.equals("repeat")) {
      runtime.call("depublish",call(id,request));
      AuthenticationReuseUnit.check(channels.size()==4&&!runtime.signed&&!runtime.depositUsed,"one update, no signature or deposit");
      if(scenario.equals("repeat"))AuthenticationReuseUnit.rejects(()->runtime.call("depublish",call(id,request)),"repeat blocked");
     } else {
      int before=channels.size();
      AuthenticationReuseUnit.rejects(()->runtime.call("depublish",call(id,scenario.equals("wrongTarget")?request.replace(TARGET,"urn:uuid:99999999-2222-3333-4444-555555555555"):request)),scenario+" blocked");
      AuthenticationReuseUnit.check(channels.size()==before,"no update channel on rejection");
     }
    }
   }
  }
 }
}
