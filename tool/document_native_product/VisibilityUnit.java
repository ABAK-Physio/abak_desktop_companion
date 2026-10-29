import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
/** Synthetic metadata, certificates and in-memory channels only. */
public class VisibilityUnit {
  static byte[] bytes(String s){return s.getBytes(StandardCharsets.UTF_8);}
  static void send(AuthenticationReuseUnit.Fixture f,String id,String op,String xml)throws Exception {
    String action=op.equals("visibilityupdate")?DmpNativeBridge.DELETE_ACTION:DmpNativeBridge.SEARCH_ACTION;
    f.runtime.call(op,Map.of("id",id,"body",Base64.getEncoder().encodeToString(bytes(xml)),"contentType","application/soap+xml; charset=UTF-8; action=\""+action+"\""));
  }
  public static void main(String[] args)throws Exception {
    String update=Files.readString(Path.of(args[0],"update.xml")), before=Files.readString(Path.of(args[0],"before.xml"));
    String newId=DmpNativeBridge.checkVisibility(bytes(update),bytes(before));
    AuthenticationReuseUnit.check(newId.startsWith("urn:uuid:"),"valid metadata-only patient visibility update");
    for(String bad:List.of(update.replace("abcdef","changed"),update.replace("INVISIBLE_REPRESENTANTS_LEGAUX","VISIBLE"),update.replace("11506-3","9999"),update.replace("name=\"PreviousVersion\"","name=\"NotPreviousVersion\""),update.replace("services/registry","services/repository"),update.replace("<rim:RegistryObjectList>","<rim:RegistryObjectList><rim:ExtrinsicObject/>"))) {
      AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkVisibility(bytes(bad),bytes(before)),"unrelated metadata or target mutation blocked");
    }
    AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkVisibility(bytes(update),null),"fresh server metadata required");
    Path dir=Path.of(args[1]);NativeTestBridge.certs=dir;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[2]);
    String query="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:w=\"http://www.w3.org/2005/08/addressing\"><s:Header><w:To>"+DmpNativeBridge.SEARCH_ENDPOINT+"</w:To><w:Action>"+DmpNativeBridge.SEARCH_ACTION+"</w:Action></s:Header><s:Body><AdhocQueryRequest xmlns=\"urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0\" xmlns:rim=\"urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0\"><ResponseOption returnType=\"LeafClass\" returnComposedObjects=\"true\"/><rim:AdhocQuery id=\"urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4\"><rim:Slot name=\"$XDSDocumentEntryEntryUUID\"><rim:ValueList><rim:Value>('urn:uuid:11111111-2222-4333-8444-555555555555')</rim:Value></rim:ValueList></rim:Slot></rim:AdhocQuery></AdhocQueryRequest></s:Body></s:Envelope>";
    for(String scenario:List.of("valid","beforeTd","beforeMetadata","normal","replacement","depublication","expired")) {
      try(var f=new AuthenticationReuseUnit.Fixture(dir)) {
        if(scenario.equals("normal")){f.fields.remove("accessOnly");f.fields.remove("reuseAuthentication");}
        if(scenario.equals("replacement"))f.fields.put("replacementUniqueId","2.25.123");
        if(scenario.equals("depublication")){f.fields.remove("reuseAuthentication");f.fields.put("depublicationUniqueId","2.25.123");}
        String id=f.open().get("id");if(!scenario.equals("beforeTd"))f.td(id);
        if(scenario.equals("expired"))f.clock.instant=f.clock.instant.plusSeconds(121);
        if(scenario.equals("valid")) {
          send(f,id,"visibilitymetadata",query);
          // MemoryChannel intentionally returns no server XML. Supply synthetic response.
          f.runtime.visibilityMetadata=bytes(before);
          send(f,id,"visibilityupdate",update);
          AuthenticationReuseUnit.rejects(()->send(f,id,"visibilityupdate",update),"update cannot be repeated");
          send(f,id,"visibilitymetadata",query.replace("urn:uuid:11111111-2222-4333-8444-555555555555",newId));
          AuthenticationReuseUnit.rejects(()->send(f,id,"visibilitymetadata",query),"no extra query after verification");
          AuthenticationReuseUnit.check(!f.runtime.signed&&!f.runtime.depositUsed,"visibility never signs or deposits a document");
        } else if(scenario.equals("beforeMetadata")) AuthenticationReuseUnit.rejects(()->send(f,id,"visibilityupdate",update),"cannot update without fresh metadata");
        else AuthenticationReuseUnit.rejects(()->send(f,id,"visibilitymetadata",query),scenario+" rejected");
      }
    }
  }
}
