import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
/** Offline identity and memory channels only. */
public class ConsultationUnit {
  static void send(AuthenticationReuseUnit.Fixture f,String id,String op,String xml)throws Exception {
    String action=op.equals("retrieve")?DmpNativeBridge.RETRIEVE_ACTION:DmpNativeBridge.SEARCH_ACTION;
    f.runtime.call(op,Map.of("id",id,"body",Base64.getEncoder().encodeToString(xml.getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\""+action+"\""));
  }
  public static void main(String[] args)throws Exception {
    Path dir=Path.of(args[0]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[1]);
    String metadata=Files.readString(Path.of(args[2])), retrieve=Files.readString(Path.of(args[3]));
    DmpNativeBridge.checkRetrieve(retrieve.getBytes(StandardCharsets.UTF_8));
    for(String invalid:List.of(retrieve.replace("services/repository","services/registry"),retrieve.replace("RetrieveDocumentSetRequest","ProvideAndRegisterDocumentSetRequest"),retrieve.replace("<DocumentUniqueId>2.25.1</DocumentUniqueId>","<DocumentUniqueId>https://evil.invalid</DocumentUniqueId>"),retrieve.replace("</DocumentRequest>","</DocumentRequest><DocumentRequest/>"))) {
      AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkRetrieve(invalid.getBytes(StandardCharsets.UTF_8)),"invalid retrieve blocked");
    }
    for(String scenario:List.of("access","beforeTd","beforeMetadata","normal","replacement","depublication","afterAuth","expired")) {
      try(var f=new AuthenticationReuseUnit.Fixture(dir)) {
        if(scenario.equals("normal")){f.fields.remove("accessOnly");f.fields.remove("reuseAuthentication");}
        if(scenario.equals("replacement"))f.fields.put("replacementUniqueId","2.25.123");
        if(scenario.equals("depublication")){f.fields.remove("reuseAuthentication");f.fields.put("depublicationUniqueId","2.25.123");}
        String id=f.open().get("id");
        if(!scenario.equals("beforeTd"))f.td(id);
        if(scenario.equals("afterAuth"))f.runtime.authorizationUsed=true;
        if(scenario.equals("expired"))f.clock.instant=f.clock.instant.plusSeconds(121);
        if(scenario.equals("access")) {
          send(f,id,"consultmetadata",metadata);send(f,id,"retrieve",retrieve);
          AuthenticationReuseUnit.check(!f.runtime.signed&&!f.runtime.depositUsed,"retrieval never signs or deposits");
          AuthenticationReuseUnit.rejects(()->send(f,id,"retrieve",retrieve),"no automatic second retrieval");
          AuthenticationReuseUnit.rejects(()->send(f,id,"consultmetadata",metadata),"no batch consultation");
        } else if(scenario.equals("beforeMetadata")) {
          AuthenticationReuseUnit.rejects(()->send(f,id,"retrieve",retrieve),"metadata required");
        } else AuthenticationReuseUnit.rejects(()->send(f,id,"consultmetadata",metadata),scenario+" blocked");
      }
    }
  }
}
