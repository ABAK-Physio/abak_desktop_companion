import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
/** Synthetic identities and memory channels only. */
public class SubmissionSearchUnit {
  static Map<String,String> queries=new HashMap<>();
  static void send(AuthenticationReuseUnit.Fixture f,String id,String stage)throws Exception {
    f.runtime.call("submissionsearch",Map.of("id",id,"stage",stage,"body",Base64.getEncoder().encodeToString(queries.get(stage).getBytes(StandardCharsets.UTF_8)),"contentType","application/soap+xml; charset=UTF-8; action=\""+DmpNativeBridge.SEARCH_ACTION+"\""));
  }
  public static void main(String[] args)throws Exception {
    Path dir=Path.of(args[0]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[1]);
    for(String stage:List.of("submissions","associations","documents")) {
      String xml=Files.readString(Path.of("/private/tmp/abak-sub-"+stage+".xml"));queries.put(stage,xml);
      DmpNativeBridge.checkSubmissionSearch(xml.getBytes(StandardCharsets.UTF_8),stage);
      AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkSubmissionSearch(xml.replace("LeafClass","ObjectRef").getBytes(StandardCharsets.UTF_8),stage),"wrong return type");
    }
    for(String invalid:List.of(queries.get("submissions").replace("$XDSSubmissionSetSubmissionTimeFrom","$XDSDocumentEntryCreationTimeFrom"),queries.get("submissions").replace("1.4.10","1.4.9"),queries.get("submissions").replace("StatusType:Approved","StatusType:Deleted"))) {
      AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkSubmissionSearch(invalid.getBytes(StandardCharsets.UTF_8),"submissions"),"wrong deposit criteria");
    }
    String quotedDates=queries.get("submissions").replaceAll(">([0-9]{14})<", ">'$1'<");
    AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkSubmissionSearch(quotedDates.getBytes(StandardCharsets.UTF_8),"submissions"),"quoted dates rejected (recorded DV1 rejection)");
    for(String scenario:List.of("access","beforeTd","normal","replacement","depublication","afterAuth","expired","afterFind")) {
      try(var f=new AuthenticationReuseUnit.Fixture(dir)) {
        if(scenario.equals("normal")){f.fields.remove("accessOnly");f.fields.remove("reuseAuthentication");}
        if(scenario.equals("replacement"))f.fields.put("replacementUniqueId","2.25.123");
        if(scenario.equals("depublication")){f.fields.remove("reuseAuthentication");f.fields.put("depublicationUniqueId","2.25.123");}
        String id=f.open().get("id");
        if(!scenario.equals("beforeTd"))f.td(id);
        if(scenario.equals("afterAuth"))f.runtime.authorizationUsed=true;
        if(scenario.equals("afterFind"))f.runtime.searchUsed=true;
        if(scenario.equals("expired"))f.clock.instant=f.clock.instant.plusSeconds(121);
        if(scenario.equals("access")) {
          AuthenticationReuseUnit.rejects(()->send(f,id,"documents"),"cannot skip first stages");
          send(f,id,"submissions");
          AuthenticationReuseUnit.rejects(()->send(f,id,"submissions"),"no second initial search");
          AuthenticationReuseUnit.rejects(()->send(f,id,"documents"),"cannot skip associations");
          send(f,id,"associations");send(f,id,"associations");send(f,id,"documents");send(f,id,"documents");
          AuthenticationReuseUnit.rejects(()->send(f,id,"associations"),"cannot return to earlier stage");
          AuthenticationReuseUnit.check(f.channels.size()==7,"five read-only registry exchanges");
          AuthenticationReuseUnit.check(!f.runtime.signed&&!f.runtime.depositUsed&&!f.runtime.authorizationUsed,"no sign/deposit/authorization");
          AuthenticationReuseUnit.rejects(()->f.runtime.call("sign",Map.of("id",id)),"cannot sign");
        } else {
          AuthenticationReuseUnit.rejects(()->send(f,id,"submissions"),scenario+" blocked");
          AuthenticationReuseUnit.check(f.channels.size()==2,"no extra connection");
        }
      }
    }
    System.out.println("Submission search checks passed; card calls=0; network calls=0");
  }
}
