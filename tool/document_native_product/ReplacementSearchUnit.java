import java.nio.file.*;
import java.util.*;
import java.nio.charset.StandardCharsets;

/** Synthetic identity, memory channels only: never connects to DV1 or a card. */
public class ReplacementSearchUnit {
  static String query(String target) {
    return "<s:Envelope xmlns:s='"+DmpNativeBridge.SOAP_NS+"' xmlns:w='"+DmpNativeBridge.WSA_NS+"'><s:Header><w:To>"+DmpNativeBridge.SEARCH_ENDPOINT+"</w:To><w:Action>"+DmpNativeBridge.SEARCH_ACTION+"</w:Action></s:Header><s:Body><AdhocQueryRequest xmlns='"+DmpNativeBridge.QUERY_NS+"'><ResponseOption returnType='ObjectRef' returnComposedObjects='true'/><rim:AdhocQuery xmlns:rim='"+DmpNativeBridge.RIM_NS+"' id='urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4'><rim:Slot name='$XDSDocumentEntryUniqueId'><rim:ValueList><rim:Value>('"+target+"')</rim:Value></rim:ValueList></rim:Slot></rim:AdhocQuery></AdhocQueryRequest></s:Body></s:Envelope>";
  }
  static void search(AuthenticationReuseUnit.Fixture f,String id,String target)throws Exception {
    f.runtime.call("search",Map.of("id",id,"body",Base64.getEncoder().encodeToString(query(target).getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\""+DmpNativeBridge.SEARCH_ACTION+"\""));
  }
  public static void main(String[] args)throws Exception {
    Path dir=Path.of(args[0]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[1]);
    for(String scenario:List.of("replacement","normal","wrongTarget","beforeTd","afterSign","afterDeposit","expired","access")) {
      try(var f=new AuthenticationReuseUnit.Fixture(dir)) {
        if(!scenario.equals("access")){f.fields.remove("accessOnly");f.fields.remove("reuseAuthentication");}
        if(!scenario.equals("normal")&&!scenario.equals("access"))f.fields.put("replacementUniqueId","2.25.123");
        String id=f.open().get("id");
        if(!scenario.equals("beforeTd"))f.td(id);
        if(scenario.equals("afterSign"))f.runtime.signed=true;
        if(scenario.equals("afterDeposit"))f.runtime.depositUsed=true;
        if(scenario.equals("expired"))f.clock.instant=f.clock.instant.plusSeconds(121);
        if(scenario.equals("replacement")||scenario.equals("access")) {
          search(f,id,"2.25.123");
          AuthenticationReuseUnit.check(f.channels.size()==3,"one search channel: "+scenario);
          AuthenticationReuseUnit.check(!f.runtime.signed&&!f.runtime.depositUsed,"search does not sign or deposit");
          AuthenticationReuseUnit.rejects(()->search(f,id,"2.25.123"),"no repeated search: "+scenario);
        } else {
          AuthenticationReuseUnit.rejects(()->search(f,id,scenario.equals("wrongTarget")?"2.25.999":"2.25.123"),scenario+" rejected");
          AuthenticationReuseUnit.check(f.channels.size()==2,"no search channel on rejection");
        }
      }
    }
  }
}
