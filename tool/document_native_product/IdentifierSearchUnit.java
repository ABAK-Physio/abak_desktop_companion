import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
/** Read-only GetDocuments tests using synthetic XML and in-memory channels. */
public class IdentifierSearchUnit {
  static byte[] bytes(String s){return s.getBytes(StandardCharsets.UTF_8);}
  public static void main(String[] args)throws Exception {
    String q=Files.readString(Path.of(args[0]));
    DmpNativeBridge.checkFindDocuments(bytes(q));
    AuthenticationReuseUnit.check(true,"LeafClass GetDocuments identifiers accepted");
    for(String bad:List.of(q.replace("2.25.456","2.25.123"),q.replace("2.25.456","2.25.4','2.25.5','2.25.6','2.25.7"),q.replace("2.25.456","not-an-oid"),q.replace("$XDSDocumentEntryUniqueId","$Unknown"),q.replace("LeafClass","ObjectRef"),q.replace("services/registry","services/repository")))
      AuthenticationReuseUnit.rejects(()->DmpNativeBridge.checkFindDocuments(bytes(bad)),"invalid identifier query rejected");
    Path certs=Path.of(args[1]);NativeTestBridge.certs=certs;NativeTestBridge.scenario="accepted";NativeTestBridge.trace=Path.of(args[2]);
    try(var f=new AuthenticationReuseUnit.Fixture(certs)) {
      String id=f.open().get("id");f.td(id);
      VisibilityUnit.send(f,id,"finddocuments",q);
      AuthenticationReuseUnit.rejects(()->VisibilityUnit.send(f,id,"finddocuments",q),"no automatic repeated query");
      AuthenticationReuseUnit.rejects(()->f.runtime.call("deposit",Map.of("id",id)),"query does not authorize a deposit");
    }
  }
}
