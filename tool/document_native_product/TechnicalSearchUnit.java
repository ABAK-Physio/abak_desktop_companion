import java.nio.charset.StandardCharsets;

/** Offline request restrictions. No card, files, socket or runtime session. */
public class TechnicalSearchUnit {
  static void check(String xml) throws Exception {
    DmpNativeBridge.checkSearch(xml.getBytes(StandardCharsets.UTF_8));
  }
  static void reject(String xml) throws Exception {
    try { check(xml); } catch (Exception expected) { return; }
    throw new AssertionError("Unsafe query accepted");
  }
  public static void main(String[] args) throws Exception {
    String xml = "<s:Envelope xmlns:s='"+DmpNativeBridge.SOAP_NS+"' xmlns:w='"+DmpNativeBridge.WSA_NS+"'><s:Header>"
      +"<w:To>"+DmpNativeBridge.SEARCH_ENDPOINT+"</w:To><w:Action>"+DmpNativeBridge.SEARCH_ACTION+"</w:Action></s:Header><s:Body>"
      +"<AdhocQueryRequest xmlns='"+DmpNativeBridge.QUERY_NS+"'><ResponseOption returnType='ObjectRef' returnComposedObjects='true'/>"
      +"<rim:AdhocQuery xmlns:rim='"+DmpNativeBridge.RIM_NS+"' id='urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4'>"
      +"<rim:Slot name='$XDSDocumentEntryUniqueId'><rim:ValueList><rim:Value>('2.25.123')</rim:Value></rim:ValueList></rim:Slot>"
      +"</rim:AdhocQuery></AdhocQueryRequest></s:Body></s:Envelope>";
    check(xml);
    reject(xml.replace("ObjectRef", "LeafClass"));
    reject(xml.replace("2.25.123", "2.25.123','2.25.456"));
    reject(xml.replace("$XDSDocumentEntryUniqueId", "$XDSDocumentEntryPatientId"));
    reject(xml.replace("/registry", "/repository"));
    reject(xml.replace("RegistryStoredQuery", "ProvideAndRegisterDocumentSet-b"));
    reject(xml.replace("</s:Body>", "<Extra/></s:Body>"));
    System.out.println("TechnicalSearchUnit: 7 checks passed (offline)");
  }
}
