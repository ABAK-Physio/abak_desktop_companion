import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
/** All channels and identities synthetic. No real network or card. */
public class FindDocumentsUnit {
  static String query;
  static void send(AuthenticationReuseUnit.Fixture f,String id,String xml)throws Exception {
    f.runtime.call("finddocuments",Map.of("id",id,"body",Base64.getEncoder().encodeToString(xml.getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\""+DmpNativeBridge.SEARCH_ACTION+"\""));
  }
  public static void main(String[] args)throws Exception {
    Path dir=Path.of(args[0]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[1]);
    query=Files.readString(Path.of(args[2]));
    DmpNativeBridge.checkFindDocuments(query.getBytes(StandardCharsets.UTF_8));
    for(String invalid:List.of(query.replace("LeafClass","ObjectRef"),query.replace("$XDSDocumentEntryPatientId","$XDSDocumentEntryUniqueId"),query.replace("StatusType:Approved","StatusType:Deleted"),query.replace("14d4debf-8f97-4251-9a74-a90016b0af0d","5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4"))) {
      AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkFindDocuments(invalid.getBytes(StandardCharsets.UTF_8)),"invalid query blocked");
    }
    for(String scenario:List.of("access","beforeTd","normal","replacement","depublication","afterAuth","expired")) {
      try(var f=new AuthenticationReuseUnit.Fixture(dir)) {
        if(scenario.equals("normal")){f.fields.remove("accessOnly");f.fields.remove("reuseAuthentication");}
        if(scenario.equals("replacement"))f.fields.put("replacementUniqueId","2.25.123");
        if(scenario.equals("depublication")){f.fields.remove("reuseAuthentication");f.fields.put("depublicationUniqueId","2.25.123");}
        String id=f.open().get("id");
        if(!scenario.equals("beforeTd"))f.td(id);
        if(scenario.equals("afterAuth"))f.runtime.authorizationUsed=true;
        if(scenario.equals("expired"))f.clock.instant=f.clock.instant.plusSeconds(121);
        if(scenario.equals("access")) {
          send(f,id,query);
          AuthenticationReuseUnit.check(f.channels.size()==3,"one read-only registry channel");
          AuthenticationReuseUnit.check(!f.runtime.signed&&!f.runtime.depositUsed,"no sign/deposit");
          AuthenticationReuseUnit.rejects(()->send(f,id,query),"one search per session");
        } else {
          AuthenticationReuseUnit.rejects(()->send(f,id,query),scenario+" blocked");
          AuthenticationReuseUnit.check(f.channels.size()==2,"no extra connection");
        }
      }
    }
  }
}
