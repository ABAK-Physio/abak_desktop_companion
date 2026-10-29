import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.security.cert.*;
import java.time.*;
import java.util.*;
import java.util.regex.*;
import javax.net.ssl.*;
import javax.naming.ldap.LdapName;

/** Reusable JDK17 worker. No endpoint, patient, PIN or identity hard-coded.
 * Constructing/loading this class opens neither network nor Cryptolib.
 * Only an explicit OPEN frame starts native operations. No retries/redirects.
 */
public class DmpNativeBridge {
  static final String SEARCH_ENDPOINT="https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/registry";
  static final String RETRIEVE_ENDPOINT="https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository";
  static final String RETRIEVE_ACTION="urn:ihe:iti:2007:RetrieveDocumentSet", XDS_NS="urn:ihe:iti:xds-b:2007";
  static void checkRetrieve(byte[] bytes)throws Exception {
    var root=safeXml(bytes);need("Envelope".equals(root.getLocalName())&&SOAP_NS.equals(root.getNamespaceURI())&&elements(root).size()==2,"CONFIGURATION");
    var h=child(root,SOAP_NS,"Header");
    need(RETRIEVE_ENDPOINT.equals(child(h,WSA_NS,"To").getTextContent())&&RETRIEVE_ACTION.equals(child(h,WSA_NS,"Action").getTextContent()),"CONFIGURATION");
    var b=child(root,SOAP_NS,"Body");need(elements(b).size()==1,"CONFIGURATION");
    var q=child(b,XDS_NS,"RetrieveDocumentSetRequest");need(elements(q).size()==1,"CONFIGURATION");
    var d=child(q,XDS_NS,"DocumentRequest");need(elements(d).size()==2,"CONFIGURATION");
    for(String name:List.of("RepositoryUniqueId","DocumentUniqueId")){
      var v=child(d,XDS_NS,name);need(elements(v).isEmpty()&&v.getTextContent().matches("[0-2](\\.[0-9]+)+"),"CONFIGURATION");
    }
  }
  static final String SEARCH_ACTION="urn:ihe:iti:2007:RegistryStoredQuery";
  static final String SOAP_NS="http://www.w3.org/2003/05/soap-envelope", WSA_NS="http://www.w3.org/2005/08/addressing";
  static final String QUERY_NS="urn:oasis:names:tc:ebxml-regrep:xsd:query:3.0", RIM_NS="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0";
  static java.util.List<org.w3c.dom.Element> elements(org.w3c.dom.Element parent) {
    var result=new java.util.ArrayList<org.w3c.dom.Element>();
    for(var n=parent.getFirstChild();n!=null;n=n.getNextSibling()) if(n instanceof org.w3c.dom.Element e)result.add(e);
    return result;
  }
  static org.w3c.dom.Element child(org.w3c.dom.Element p,String ns,String name)throws Exception {
    var matches=elements(p).stream().filter(e->ns.equals(e.getNamespaceURI())&&name.equals(e.getLocalName())).toList();
    need(matches.size()==1,"CONFIGURATION");return matches.get(0);
  }
  // Restrict this native operation to a single read-only ObjectRef query.
  static String checkSearch(byte[] bytes)throws Exception {
    need(bytes.length>0&&bytes.length<1024*1024,"HTTP");
    var f=javax.xml.parsers.DocumentBuilderFactory.newInstance();f.setNamespaceAware(true);
    f.setFeature("http://apache.org/xml/features/disallow-doctype-decl",true);
    f.setFeature("http://xml.org/sax/features/external-general-entities",false);
    f.setFeature("http://xml.org/sax/features/external-parameter-entities",false);
    f.setAttribute(javax.xml.XMLConstants.ACCESS_EXTERNAL_DTD,"");f.setAttribute(javax.xml.XMLConstants.ACCESS_EXTERNAL_SCHEMA,"");
    f.setXIncludeAware(false);f.setExpandEntityReferences(false);
    var root=f.newDocumentBuilder().parse(new ByteArrayInputStream(bytes)).getDocumentElement();
    need("Envelope".equals(root.getLocalName())&&SOAP_NS.equals(root.getNamespaceURI())&&elements(root).size()==2,"CONFIGURATION");
    var header=child(root,SOAP_NS,"Header");
    need(SEARCH_ENDPOINT.equals(child(header,WSA_NS,"To").getTextContent())&&SEARCH_ACTION.equals(child(header,WSA_NS,"Action").getTextContent()),"CONFIGURATION");
    var body=child(root,SOAP_NS,"Body");need(elements(body).size()==1,"CONFIGURATION");
    var query=child(body,QUERY_NS,"AdhocQueryRequest");need(elements(query).size()==2,"CONFIGURATION");
    var option=child(query,QUERY_NS,"ResponseOption");
    need("ObjectRef".equals(option.getAttribute("returnType"))&&"true".equals(option.getAttribute("returnComposedObjects"))&&elements(option).isEmpty(),"CONFIGURATION");
    var adhoc=child(query,RIM_NS,"AdhocQuery");
    need("urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4".equals(adhoc.getAttribute("id"))&&elements(adhoc).size()==1,"CONFIGURATION");
    var slot=child(adhoc,RIM_NS,"Slot");need("$XDSDocumentEntryUniqueId".equals(slot.getAttribute("name"))&&elements(slot).size()==1,"CONFIGURATION");
    var list=child(slot,RIM_NS,"ValueList");need(elements(list).size()==1,"CONFIGURATION");
    var value=child(list,RIM_NS,"Value");
    need(elements(value).isEmpty(),"CONFIGURATION");
    need(value.getTextContent().matches("\\('[0-2](\\.[0-9]+)+'\\)"),"CONFIGURATION");
    String text=value.getTextContent();return text.substring(2,text.length()-2);
  }
  // Separate allow-list: no mutation, no reuse in replacement/depublication.
  static void checkFindDocuments(byte[] bytes)throws Exception {
    var root=safeXml(bytes);
    need("Envelope".equals(root.getLocalName())&&SOAP_NS.equals(root.getNamespaceURI())&&elements(root).size()==2,"CONFIGURATION");
    var header=child(root,SOAP_NS,"Header");
    need(SEARCH_ENDPOINT.equals(child(header,WSA_NS,"To").getTextContent())&&SEARCH_ACTION.equals(child(header,WSA_NS,"Action").getTextContent()),"CONFIGURATION");
    var body=child(root,SOAP_NS,"Body");need(elements(body).size()==1,"CONFIGURATION");
    var query=child(body,QUERY_NS,"AdhocQueryRequest");need(elements(query).size()==2,"CONFIGURATION");
    var option=child(query,QUERY_NS,"ResponseOption");
    need("LeafClass".equals(option.getAttribute("returnType"))&&"true".equals(option.getAttribute("returnComposedObjects"))&&elements(option).isEmpty(),"CONFIGURATION");
    var adhoc=child(query,RIM_NS,"AdhocQuery");
    if("urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4".equals(adhoc.getAttribute("id"))) {
      need(elements(adhoc).size()==1,"CONFIGURATION");
      var slot=child(adhoc,RIM_NS,"Slot");need("$XDSDocumentEntryUniqueId".equals(slot.getAttribute("name"))&&elements(slot).size()==1,"CONFIGURATION");
      var list=child(slot,RIM_NS,"ValueList");need(elements(list).size()==1,"CONFIGURATION");
      var value=child(list,RIM_NS,"Value");need(elements(value).isEmpty(),"CONFIGURATION");
      String text=value.getTextContent();need(text.startsWith("('")&&text.endsWith("')"),"CONFIGURATION");
      var ids=Arrays.asList(text.substring(2,text.length()-2).split("','",-1));
      need(ids.size()<=4 && new HashSet<>(ids).size()==ids.size(),"CONFIGURATION");
      for(String id:ids)need(id.matches("[0-2](\\.[0-9]+)+"),"CONFIGURATION");
      return;
    }
    need("urn:uuid:14d4debf-8f97-4251-9a74-a90016b0af0d".equals(adhoc.getAttribute("id")),"CONFIGURATION");
    var values=new HashMap<String,String>();
    for(var slot:elements(adhoc)) {
      need(RIM_NS.equals(slot.getNamespaceURI())&&"Slot".equals(slot.getLocalName())&&elements(slot).size()==1,"CONFIGURATION");
      var list=child(slot,RIM_NS,"ValueList");need(elements(list).size()==1,"CONFIGURATION");
      var value=child(list,RIM_NS,"Value");need(elements(value).isEmpty()&&values.put(slot.getAttribute("name"),value.getTextContent())==null,"CONFIGURATION");
    }
    need(values.keySet().containsAll(Set.of("$XDSDocumentEntryPatientId","$XDSDocumentEntryStatus"))&&Set.of("$XDSDocumentEntryPatientId","$XDSDocumentEntryStatus","$XDSDocumentEntryTypeCode").containsAll(values.keySet()),"CONFIGURATION");
    need(values.get("$XDSDocumentEntryPatientId").matches("'[0-9]{15}\\^\\^\\^&1\\.2\\.250\\.1\\.213\\.1\\.4\\.10&ISO\\^NH'"),"CONFIGURATION");
    String status=values.get("$XDSDocumentEntryStatus");
    need(status.startsWith("('")&&status.endsWith("')"),"CONFIGURATION");
    var statuses=Arrays.asList(status.substring(2,status.length()-2).split("','",-1));
    need(statuses.contains("urn:oasis:names:tc:ebxml-regrep:StatusType:Approved")&&new HashSet<>(statuses).size()==statuses.size()&&
      Set.of("urn:oasis:names:tc:ebxml-regrep:StatusType:Approved","urn:asip:ci-sis:2010:StatusType:Archived","urn:oasis:names:tc:ebxml-regrep:StatusType:Deprecated").containsAll(statuses),"CONFIGURATION");
    if(values.containsKey("$XDSDocumentEntryTypeCode"))need(values.get("$XDSDocumentEntryTypeCode").matches("\\('[-A-Za-z0-9._]{1,64}\\^\\^[0-2](\\.[0-9]+)+'\\)"),"CONFIGURATION");
  }
  static void checkSubmissionSearch(byte[] bytes,String stage)throws Exception {
    var root=safeXml(bytes);
    need("Envelope".equals(root.getLocalName())&&SOAP_NS.equals(root.getNamespaceURI())&&elements(root).size()==2,"CONFIGURATION");
    var header=child(root,SOAP_NS,"Header");
    need(SEARCH_ENDPOINT.equals(child(header,WSA_NS,"To").getTextContent())&&SEARCH_ACTION.equals(child(header,WSA_NS,"Action").getTextContent()),"CONFIGURATION");
    var body=child(root,SOAP_NS,"Body");need(elements(body).size()==1,"CONFIGURATION");
    var query=child(body,QUERY_NS,"AdhocQueryRequest");need(elements(query).size()==2,"CONFIGURATION");
    var option=child(query,QUERY_NS,"ResponseOption");
    need("LeafClass".equals(option.getAttribute("returnType"))&&"true".equals(option.getAttribute("returnComposedObjects"))&&elements(option).isEmpty(),"CONFIGURATION");
    var adhoc=child(query,RIM_NS,"AdhocQuery");
    String expected=switch(stage){case "submissions" -> "urn:uuid:f26abbcb-ac74-4422-8a30-edb644bbc1a9";case "associations" -> "urn:uuid:a7ae438b-4bc2-4642-93e9-be891f7bb155";case "documents" -> "urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4";default -> "";};
    need(!expected.isEmpty()&&expected.equals(adhoc.getAttribute("id")),"CONFIGURATION");
    var values=new HashMap<String,String>();
    for(var slot:elements(adhoc)) {
      need(RIM_NS.equals(slot.getNamespaceURI())&&"Slot".equals(slot.getLocalName())&&elements(slot).size()==1,"CONFIGURATION");
      var list=child(slot,RIM_NS,"ValueList");need(elements(list).size()==1,"CONFIGURATION");
      var value=child(list,RIM_NS,"Value");need(elements(value).isEmpty()&&values.put(slot.getAttribute("name"),value.getTextContent())==null,"CONFIGURATION");
    }
    if("submissions".equals(stage)) {
      need(values.keySet().equals(Set.of("$XDSSubmissionSetPatientId","$XDSSubmissionSetStatus","$XDSSubmissionSetSubmissionTimeFrom","$XDSSubmissionSetSubmissionTimeTo")),"CONFIGURATION");
      need(values.get("$XDSSubmissionSetPatientId").matches("'[0-9]{15}\\^\\^\\^&1\\.2\\.250\\.1\\.213\\.1\\.4\\.10&ISO\\^NH'"),"CONFIGURATION");
      need("('urn:oasis:names:tc:ebxml-regrep:StatusType:Approved')".equals(values.get("$XDSSubmissionSetStatus")),"CONFIGURATION");
      String from=values.get("$XDSSubmissionSetSubmissionTimeFrom"),to=values.get("$XDSSubmissionSetSubmissionTimeTo");
      need(from.matches("[0-9]{14}")&&to.matches("[0-9]{14}")&&from.compareTo(to)<0,"CONFIGURATION");
      var format=java.time.format.DateTimeFormatter.ofPattern("uuuuMMddHHmmss").withResolverStyle(java.time.format.ResolverStyle.STRICT);
      java.time.LocalDateTime.parse(from,format);java.time.LocalDateTime.parse(to,format);
    } else {
      String key="associations".equals(stage)?"$uuid":"$XDSDocumentEntryEntryUUID";
      need(values.keySet().equals(Set.of(key)),"CONFIGURATION");
      String value=values.get(key);need(value.startsWith("('")&&value.endsWith("')"),"CONFIGURATION");
      var ids=Arrays.asList(value.substring(2,value.length()-2).split("','",-1));
      need(ids.size()<=("associations".equals(stage)?1000:88)&&new HashSet<>(ids).size()==ids.size(),"CONFIGURATION");
      for(String id:ids)need(id.matches("urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}"),"CONFIGURATION");
    }
  }
  static final String DELETE_ACTION="urn:ihe:iti:2010:UpdateDocumentSet";
  static org.w3c.dom.Element safeXml(byte[] bytes)throws Exception {
    need(bytes.length>0&&bytes.length<1024*1024,"HTTP");
    var f=javax.xml.parsers.DocumentBuilderFactory.newInstance();f.setNamespaceAware(true);
    f.setFeature("http://apache.org/xml/features/disallow-doctype-decl",true);
    f.setFeature("http://xml.org/sax/features/external-general-entities",false);
    f.setFeature("http://xml.org/sax/features/external-parameter-entities",false);
    f.setAttribute(javax.xml.XMLConstants.ACCESS_EXTERNAL_DTD,"");f.setAttribute(javax.xml.XMLConstants.ACCESS_EXTERNAL_SCHEMA,"");
    return f.newDocumentBuilder().parse(new ByteArrayInputStream(bytes)).getDocumentElement();
  }
  static String deletionTarget(Reply reply)throws Exception {
    need(reply.status==200,"HTTP");
    var env=safeXml(reply.body);
    var response=child(child(env,SOAP_NS,"Body"),QUERY_NS,"AdhocQueryResponse");
    need("urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success".equals(response.getAttribute("status")),"SESSION");
    var list=child(response,RIM_NS,"RegistryObjectList");need(elements(list).size()==1,"SESSION");
    var ref=child(list,RIM_NS,"ObjectRef");String id=ref.getAttribute("id");
    need(id.matches("urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}"),"SESSION");return id;
  }
  static void checkDeletion(byte[] bytes,String target)throws Exception {
    var env=safeXml(bytes);need(elements(env).size()==2,"CONFIGURATION");
    var header=child(env,SOAP_NS,"Header");
    need(SEARCH_ENDPOINT.equals(child(header,WSA_NS,"To").getTextContent())&&DELETE_ACTION.equals(child(header,WSA_NS,"Action").getTextContent()),"CONFIGURATION");
    var body=child(env,SOAP_NS,"Body");need(elements(body).size()==1,"CONFIGURATION");
    var submit=child(body,"urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0","SubmitObjectsRequest");need(elements(submit).size()==1,"CONFIGURATION");
    var list=child(submit,RIM_NS,"RegistryObjectList");need(elements(list).size()==3,"CONFIGURATION");
    var pack=child(list,RIM_NS,"RegistryPackage");var classification=child(list,RIM_NS,"Classification");
    need(!pack.getAttribute("id").isEmpty()&&pack.getAttribute("id").equals(classification.getAttribute("classifiedObject"))&&"urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd".equals(classification.getAttribute("classificationNode")),"CONFIGURATION");
    var association=child(list,RIM_NS,"Association");
    need(target!=null&&target.equals(association.getAttribute("targetObject"))&&pack.getAttribute("id").equals(association.getAttribute("sourceObject"))&&"urn:ihe:iti:2010:AssociationType:UpdateAvailabilityStatus".equals(association.getAttribute("associationType")),"CONFIGURATION");
    need(elements(association).size()==2,"CONFIGURATION");var names=new HashSet<String>();
    for(var slot:elements(association)) {
      need(RIM_NS.equals(slot.getNamespaceURI())&&"Slot".equals(slot.getLocalName())&&names.add(slot.getAttribute("name"))&&elements(slot).size()==1,"CONFIGURATION");
      var values=child(slot,RIM_NS,"ValueList");need(elements(values).size()==1,"CONFIGURATION");
      var value=child(values,RIM_NS,"Value");need(elements(value).isEmpty(),"CONFIGURATION");
      String expected=switch(slot.getAttribute("name")){case "OriginalStatus" -> "urn:oasis:names:tc:ebxml-regrep:StatusType:Approved";case "NewStatus" -> "urn:asip:ci-sis:2010:StatusType:Deleted";default -> "";};
      need(!expected.isEmpty()&&expected.equals(value.getTextContent()),"CONFIGURATION");
    }
  }
  // TD3.3b: compare the entire server metadata tree, allowing only the patient
  // visibility removal and ITI-57 technical identifiers/version handling.
  static String metadataCanonical(org.w3c.dom.Element e) {
    var out=new StringBuilder().append("{").append(e.getNamespaceURI()).append("}").append(e.getLocalName());
    var attrs=new TreeMap<String,String>();
    for(int i=0;i<e.getAttributes().getLength();i++) {
      var a=e.getAttributes().item(i);
      if(!javax.xml.XMLConstants.XMLNS_ATTRIBUTE_NS_URI.equals(a.getNamespaceURI()))
        attrs.put("{"+a.getNamespaceURI()+"}"+a.getLocalName(),a.getNodeValue());
    }
    out.append(attrs);
    for(var n=e.getFirstChild();n!=null;n=n.getNextSibling()) {
      if(n instanceof org.w3c.dom.Element c)out.append(metadataCanonical(c));
      else if(!n.getTextContent().trim().isEmpty())out.append(n.getTextContent());
    }
    return out.append(";").toString();
  }
  static final String CONFIDENTIALITY="urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f";
  static void normalizeMetadata(org.w3c.dom.Element e, boolean removeInvisible)throws Exception {
    String old=e.getAttribute("id");e.setAttribute("id","DOCUMENT");
    var all=new ArrayList<org.w3c.dom.Element>();
    var descendants=e.getElementsByTagNameNS(RIM_NS,"*");
    for(int i=0;i<descendants.getLength();i++)all.add((org.w3c.dom.Element)descendants.item(i));
    int removed=0;
    for(var c:all) {
      if("VersionInfo".equals(c.getLocalName())) {c.getParentNode().removeChild(c);continue;}
      if(removeInvisible&&"Classification".equals(c.getLocalName())&&CONFIDENTIALITY.equals(c.getAttribute("classificationScheme"))&&"INVISIBLE_PATIENT".equals(c.getAttribute("nodeRepresentation"))) {
        var slots=elements(c).stream().filter(x->"Slot".equals(x.getLocalName())&&"codingScheme".equals(x.getAttribute("name"))).toList();
        need(slots.size()==1&&"1.2.250.1.213.1.1.4.13".equals(child(child(slots.get(0),RIM_NS,"ValueList"),RIM_NS,"Value").getTextContent()),"CONFIGURATION");
        c.getParentNode().removeChild(c);removed++;continue;
      }
      if(c.hasAttribute("id"))c.setAttribute("id","ID");
      for(String a:List.of("classifiedObject","registryObject"))if(old.equals(c.getAttribute(a)))c.setAttribute(a,"DOCUMENT");
    }
    need(!removeInvisible||removed==1,"CONFIGURATION");
  }
  static String checkVisibility(byte[] request, byte[] metadata)throws Exception {
    need(metadata!=null,"SESSION");
    var old=child(child(child(safeXml(metadata),SOAP_NS,"Body"),QUERY_NS,"AdhocQueryResponse"),RIM_NS,"RegistryObjectList");
    need(elements(old).size()==1,"CONFIGURATION");
    var previous=child(old,RIM_NS,"ExtrinsicObject");
    String version=child(previous,RIM_NS,"VersionInfo").getAttribute("versionName");
    need(version.matches("[1-9][0-9]*"),"CONFIGURATION");
    String lid=previous.hasAttribute("lid")?previous.getAttribute("lid"):previous.getAttribute("id");
    var env=safeXml(request);var header=child(env,SOAP_NS,"Header");
    need(SEARCH_ENDPOINT.equals(child(header,WSA_NS,"To").getTextContent())&&DELETE_ACTION.equals(child(header,WSA_NS,"Action").getTextContent()),"CONFIGURATION");
    var body=child(env,SOAP_NS,"Body");need(elements(body).size()==1,"CONFIGURATION");
    var submit=child(body,"urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0","SubmitObjectsRequest");need(elements(submit).size()==1,"CONFIGURATION");
    var list=child(submit,RIM_NS,"RegistryObjectList");need(elements(list).size()==4,"CONFIGURATION");
    var updated=child(list,RIM_NS,"ExtrinsicObject");String id=updated.getAttribute("id");
    need(id.matches("urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}")&&!id.equals(previous.getAttribute("id"))&&lid.equals(updated.getAttribute("lid")),"CONFIGURATION");
    var pack=child(list,RIM_NS,"RegistryPackage");var cl=child(list,RIM_NS,"Classification");
    need(pack.getAttribute("id").equals(cl.getAttribute("classifiedObject"))&&"urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd".equals(cl.getAttribute("classificationNode")),"CONFIGURATION");
    var a=child(list,RIM_NS,"Association");
    need("urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember".equals(a.getAttribute("associationType"))&&pack.getAttribute("id").equals(a.getAttribute("sourceObject"))&&id.equals(a.getAttribute("targetObject")),"CONFIGURATION");
    var slots=new HashMap<String,String>();
    for(var c:elements(a)) {need("Slot".equals(c.getLocalName())&&elements(c).size()==1,"CONFIGURATION");var values=child(c,RIM_NS,"ValueList");need(elements(values).size()==1,"CONFIGURATION");need(slots.put(c.getAttribute("name"),child(values,RIM_NS,"Value").getTextContent())==null,"CONFIGURATION");}
    need(slots.equals(Map.of("PreviousVersion",version,"SubmissionSetStatus","Original","AssociationPropagation","yes")),"CONFIGURATION");
    previous.setAttribute("lid",lid);normalizeMetadata(previous,true);normalizeMetadata(updated,false);
    need(metadataCanonical(previous).equals(metadataCanonical(updated)),"CONFIGURATION");
    return id;
  }
  static final int MAX_BODY=16*1024*1024, MAX_REPLY=16*1024*1024, MAX_FRAME=24*1024*1024;
  static final String[] CIPHERS={"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"};
  static final Base64.Encoder B64=Base64.getEncoder();
  static final Base64.Decoder UN64=Base64.getDecoder();
  static final class Fault extends Exception { final String code; Fault(String c){super(c);code=c;} }
  static void need(boolean b,String c)throws Fault {if(!b)throw new Fault(c);}
  static String sha(byte[] b)throws Exception{return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(b));}
  static String cn(X509Certificate c)throws Exception {
    return cn(c.getSubjectX500Principal());
  }
  static String cn(javax.security.auth.x500.X500Principal subject)throws Exception {
    String result=null;
    // A CPS subject can group SN, CN and givenName in one multi-valued RDN.
    // Rdn.getType/getValue expose only one attribute, not necessarily CN.
    for(var r:new LdapName(subject.getName()).getRdns()) {
      var attribute=r.toAttributes().get("CN");
      if(attribute==null)continue;
      need(result==null&&attribute.size()==1,"CPS_IDENTITY");
      Object value=attribute.get();
      need(value instanceof String,"CPS_IDENTITY");
      result=(String)value;
    }
    need(result!=null&&!result.isEmpty(),"CPS_IDENTITY");
    return result;
  }
  static byte[] sign(PrivateKey key,byte[] data,String algorithm)throws Exception {
    Signature s=Signature.getInstance(algorithm);s.initSign(key);s.update(data);return s.sign();
  }
  static void verify(X509Certificate c,byte[] data,byte[] sig,String algorithm)throws Exception {
    // checkIdentity validates PKIX, revocation and the role-specific CPS usage.
    // initVerify(Certificate) requires digitalSignature even for a legitimate
    // contentCommitment-only signing certificate. Verify with its public key
    // after explicitly retaining the signature-usage requirement here.
    boolean[] usage=c.getKeyUsage();
    need(usage!=null&&((usage.length>0&&usage[0])||(usage.length>1&&usage[1])),"CPS_CERTIFICATE");
    Signature s=Signature.getInstance(algorithm);s.initVerify(c.getPublicKey());s.update(data);need(s.verify(sig),"CPS_CERTIFICATE");
  }
  /** Local possession check, independent of the document signature algorithm.
   * SHA256 is hashed by Java: CKM_SHA256_RSA_PKCS is disabled for this provider,
   * leaving the RSA operation on the card. No retry or algorithm fallback.
   */
  static void provePossession(PrivateKey key,PublicKey publicKey)throws Exception {
    byte[] challenge=new byte[32];new SecureRandom().nextBytes(challenge);
    byte[] proof=sign(key,challenge,"SHA256withRSA");
    Signature verifier=Signature.getInstance("SHA256withRSA");
    verifier.initVerify(publicKey);verifier.update(challenge);
    need(verifier.verify(proof),"CPS_CERTIFICATE");
  }
  interface Identity extends AutoCloseable {
    X509Certificate auth(); X509Certificate signing(); PrivateKey authKey();
    byte[] signature(byte[] bytes)throws Exception;
    void current()throws Exception;
    void close()throws Exception;
  }
  interface Channel extends AutoCloseable {
    Map<String,String> evidence(); Reply exchange(byte[] body,String type)throws Exception;
    boolean current(); void close()throws Exception;
  }
  record Reply(int status,String headers,byte[] body){
    Map<String,String> fields(){return Map.of("status",""+status,"headers",headers,"body",B64.encodeToString(body));}
  }
  interface IdentityFactory {Identity open(Map<String,String> cfg,char[] pin)throws Exception;}
  interface ChannelFactory {Channel open(URI endpoint,Identity identity,Trust trust)throws Exception;}

  /** Local-only PKIX inputs: no AIA, CRL or OCSP fetching; signed full CRLs.
   * Roots are self-signed CA certificates from the hash-pinned bundle only.
   */
  static final class Trust {
    final List<X509Certificate> certs=new ArrayList<>();
    final List<X509CRL> crls=new ArrayList<>();
    final Set<TrustAnchor> roots=new HashSet<>();
    final Clock clock; final String hash;
    Trust(Path path,String expected,Clock clock)throws Exception {
      this.clock=clock;
      System.setProperty("com.sun.security.enableCRLDP","false");
      System.setProperty("com.sun.security.enableAIAcaIssuers","false");
      byte[] bytes=Files.readAllBytes(path);need(bytes.length<=4*1024*1024,"CONFIGURATION");
      hash=sha(bytes);need(hash.equals(expected),"CONFIGURATION");
      var cf=CertificateFactory.getInstance("X.509");
      var matcher=Pattern.compile("-----BEGIN (CERTIFICATE|X509 CRL)-----[\\s\\S]*?-----END \\1-----").matcher(new String(bytes,StandardCharsets.US_ASCII));
      while(matcher.find()){
        var in=new ByteArrayInputStream(matcher.group().getBytes(StandardCharsets.US_ASCII));
        if(matcher.group(1).equals("CERTIFICATE"))certs.add((X509Certificate)cf.generateCertificate(in));
        else crls.add((X509CRL)cf.generateCRL(in));
      }
      need(!certs.isEmpty()&&!crls.isEmpty(),"CONFIGURATION");
      for(var c:certs){
        need(c.getBasicConstraints()>=0,"CONFIGURATION");
        c.checkValidity(Date.from(clock.instant()));
        if(c.getIssuerX500Principal().equals(c.getSubjectX500Principal())){
          c.verify(c.getPublicKey());roots.add(new TrustAnchor(c,null));
        }
      }
      need(!roots.isEmpty(),"TLS_TRUST");checkCrls();
    }
    void checkCrls()throws Exception {
      Set<String> issuers=new HashSet<>();
      for(var crl:crls){
        need(issuers.add(crl.getIssuerX500Principal().getName()),"TLS_CRL");
        need(crl.getNextUpdate()!=null&&!clock.instant().isBefore(crl.getThisUpdate().toInstant())&&clock.instant().isBefore(crl.getNextUpdate().toInstant()),"TLS_CRL");
        var issuer=certs.stream().filter(c->c.getSubjectX500Principal().equals(crl.getIssuerX500Principal())).findFirst().orElseThrow(()->new Fault("TLS_CRL"));
        need(issuer.getKeyUsage()!=null&&issuer.getKeyUsage()[6],"TLS_CRL");
        crl.verify(issuer.getPublicKey());
        need(crl.getExtensionValue("2.5.29.27")==null,"TLS_CRL"); // no unsupported delta CRLs
      }
    }
    PKIXBuilderParameters parameters(X509CertSelector target,Collection<X509Certificate> extra)throws Exception{
      checkCrls();
      var p=new PKIXBuilderParameters(roots,target);p.setDate(Date.from(clock.instant()));p.setRevocationEnabled(true);
      var all=new ArrayList<Object>();all.addAll(certs);all.addAll(crls);all.addAll(extra);
      p.addCertStore(CertStore.getInstance("Collection",new CollectionCertStoreParameters(all)));
      var rc=(PKIXRevocationChecker)CertPathValidator.getInstance("PKIX").getRevocationChecker();
      rc.setOptions(Set.of(PKIXRevocationChecker.Option.PREFER_CRLS,PKIXRevocationChecker.Option.NO_FALLBACK));p.addCertPathChecker(rc);
      return p;
    }
    X509Certificate[] chain(X509Certificate c)throws Exception{
      c.checkValidity(Date.from(clock.instant()));
      for(var crl:crls)if(crl.getIssuerX500Principal().equals(c.getIssuerX500Principal())) {
        need(!crl.isRevoked(c),"TLS_REVOKED");
      }
      var target=new X509CertSelector();target.setCertificate(c);
      var r=(PKIXCertPathBuilderResult)CertPathBuilder.getInstance("PKIX").build(parameters(target,List.of(c)));
      var list=new ArrayList<X509Certificate>();for(var x:r.getCertPath().getCertificates())list.add((X509Certificate)x);
      return list.toArray(X509Certificate[]::new);
    }
    TrustManager[] managers()throws Exception {
      var factory=TrustManagerFactory.getInstance("PKIX");
      factory.init(new CertPathTrustManagerParameters(parameters(new X509CertSelector(),List.of())));
      return factory.getTrustManagers();
    }
  }

  static final class CardIdentity implements Identity {
    final Provider provider; final KeyStore store; final X509Certificate auth,sign;
    final PrivateKey authKey,signKey; final String authAlias,signAlias;
    CardIdentity(Map<String,String> cfg,char[] pin)throws Exception {
      Provider p=null;
      try {
        String library=cfg.get("library");
        need(library!=null&&library.startsWith("/")&&!library.matches("(?s).*[\\r\\n\\\"{}].*")&&Files.isRegularFile(Path.of(library)),"CONFIGURATION");
        String config="name=ABAK_DMP_"+UUID.randomUUID().toString().replace("-","")+"\nlibrary=\""+library+"\"\nslotListIndex=0\ndisabledMechanisms={ CKM_SHA224_RSA_PKCS CKM_SHA256_RSA_PKCS CKM_SHA384_RSA_PKCS CKM_SHA512_RSA_PKCS }\n";
        p=Security.getProvider("SunPKCS11").configure("--"+config);Security.addProvider(p);
        store=KeyStore.getInstance("PKCS11",p);store.load(null,pin);
        authAlias=alias(store,cfg.get("authHash"));signAlias=alias(store,cfg.get("signHash"));
        need(!authAlias.equals(signAlias),"CPS_CERTIFICATE");
        auth=(X509Certificate)store.getCertificate(authAlias);sign=(X509Certificate)store.getCertificate(signAlias);
        authKey=(PrivateKey)store.getKey(authAlias,null);signKey=(PrivateKey)store.getKey(signAlias,null);
        need(authKey!=null&&signKey!=null,"CPS_CERTIFICATE");provider=p;
      } catch(Exception e){
        if(p!=null){try{((AuthProvider)p).logout();}finally{Security.removeProvider(p.getName());}}
        throw e;
      } finally {Arrays.fill(pin,'\0');}
    }
    static String alias(KeyStore store,String hash)throws Exception{
      String found=null;
      for(var it=store.aliases();it.hasMoreElements();){String a=it.nextElement();var c=store.getCertificate(a);
        if(c!=null&&sha(c.getEncoded()).equals(hash)){need(found==null,"CPS_CERTIFICATE");found=a;}}
      need(found!=null,"CPS_CERTIFICATE");return found;
    }
    public X509Certificate auth(){return auth;} public X509Certificate signing(){return sign;}
    public PrivateKey authKey(){return authKey;}
    public byte[] signature(byte[] b)throws Exception{return sign(signKey,b,"SHA1withRSA");}
    public void current()throws Exception{
      need(sha(store.getCertificate(authAlias).getEncoded()).equals(sha(auth.getEncoded()))&&sha(store.getCertificate(signAlias).getEncoded()).equals(sha(sign.getEncoded())),"CPS_CERTIFICATE");
      provePossession(authKey,auth.getPublicKey());
    }
    public void close()throws Exception {try{((AuthProvider)provider).logout();}finally{Security.removeProvider(provider.getName());}}
  }

  static SSLParameters parameters(String host){
    var p=new SSLParameters(CIPHERS,new String[]{"TLSv1.2"});
    p.setEndpointIdentificationAlgorithm("HTTPS");p.setServerNames(List.of(new SNIHostName(host)));return p;
  }
  static final class CardKey extends X509ExtendedKeyManager {
    final Identity identity;final X509Certificate[] chain;boolean requested;
    CardKey(Identity i,X509Certificate[] chain){identity=i;this.chain=chain.clone();}
    String pick(String[] types,Principal[] issuers){
      if(types==null||!Arrays.asList(types).contains("RSA"))return null;
      if(issuers!=null&&issuers.length>0&&Arrays.stream(issuers).noneMatch(i->Arrays.stream(chain).anyMatch(c->c.getIssuerX500Principal().equals(i))))return null;
      requested=true;return "cps-auth";
    }
    public String chooseClientAlias(String[] t,Principal[] i,Socket s){return pick(t,i);}
    public String chooseEngineClientAlias(String[] t,Principal[] i,SSLEngine s){return pick(t,i);}
    public String[] getClientAliases(String t,Principal[] i){return "RSA".equals(t)?new String[]{"cps-auth"}:null;}
    public String chooseServerAlias(String t,Principal[] i,Socket s){return null;}
    public String[] getServerAliases(String t,Principal[] i){return null;}
    public PrivateKey getPrivateKey(String a){return "cps-auth".equals(a)?identity.authKey():null;}
    public X509Certificate[] getCertificateChain(String a){return "cps-auth".equals(a)?chain.clone():null;}
  }
  static Map<String,String> tlsEvidence(SSLSession session,boolean requested,Identity identity)throws Exception{
    var local=session.getLocalCertificates();
    need(requested&&local!=null&&local.length>0&&sha(local[0].getEncoded()).equals(sha(identity.auth().getEncoded())),"CPS_CERTIFICATE");
    need(session.getProtocol().equals("TLSv1.2")&&Arrays.asList(CIPHERS).contains(session.getCipherSuite()),"TLS_PROTOCOL");
    return Map.of("channel",UUID.randomUUID().toString(),"peer",sha(session.getPeerCertificates()[0].getEncoded()),"cipher",session.getCipherSuite());
  }
  interface TimedAction {void run()throws Exception;}
  static void timed(String code,TimedAction action)throws Exception {
    try{action.run();}catch(SocketTimeoutException e){throw new Fault(code);}
  }
  static int responseTimeout(URI endpoint,String type){
    return SEARCH_ENDPOINT.equals(endpoint.toString()) &&
      type.equals("application/soap+xml; charset=UTF-8; action=\""+SEARCH_ACTION+"\"") ? 45000 : 15000;
  }
  static final class SocketChannel implements Channel {
    final SSLSocket socket;final URI endpoint;final Map<String,String> evidence;boolean used;
    SocketChannel(URI endpoint,Identity identity,Trust trust)throws Exception {
      this.endpoint=endpoint;var km=new CardKey(identity,trust.chain(identity.auth()));
      var ctx=SSLContext.getInstance("TLSv1.2");ctx.init(new KeyManager[]{km},trust.managers(),null);
      socket=(SSLSocket)ctx.getSocketFactory().createSocket();
      try {
        socket.setSSLParameters(parameters(endpoint.getHost()));socket.setSoTimeout(15000);
        timed("TCP_CONNECT_TIMEOUT", () -> socket.connect(new InetSocketAddress(endpoint.getHost(),endpoint.getPort()<0?443:endpoint.getPort()),10000));
        timed("TLS_HANDSHAKE_TIMEOUT", () -> socket.startHandshake());evidence=tlsEvidence(socket.getSession(),km.requested,identity);
      } catch(Exception e){socket.close();throw e;}
    }
    public Map<String,String> evidence(){return evidence;}
    public boolean current(){return !socket.isClosed()&&socket.isConnected();}
    public Reply exchange(byte[] body,String type)throws Exception{
      need(!used&&current(),"SESSION");used=true;
      need(body.length>0&&body.length<=MAX_BODY&&!type.matches("(?s).*[\\r\\n].*"),"HTTP");
      String host=endpoint.getHost()+(endpoint.getPort()>0?":"+endpoint.getPort():"");
      String head="POST "+endpoint.getRawPath()+" HTTP/1.1\r\nHost: "+host+"\r\nContent-Type: "+type+"\r\nContent-Length: "+body.length+"\r\nConnection: close\r\nAccept-Encoding: identity\r\n\r\n";
      var out=socket.getOutputStream();out.write(head.getBytes(StandardCharsets.US_ASCII));out.write(body);out.flush();
      socket.setSoTimeout(responseTimeout(endpoint,type));
      return readHttp(socket.getInputStream());
    }
    public void close()throws Exception{socket.close();}
  }
  static String line(InputStream in,int max)throws Exception {
    var out=new ByteArrayOutputStream();int b;
    while((b=in.read())!=-1){if(b==10){byte[] v=out.toByteArray();need(v.length>0&&v[v.length-1]==13,"HTTP");return new String(v,0,v.length-1,StandardCharsets.US_ASCII);}
      need(b<128&&b!=0&&out.size()<max,"HTTP");out.write(b);}
    throw new Fault("HTTP");
  }
  static Reply readHttp(InputStream in)throws Exception {
    String stage="HTTP_STATUS_TIMEOUT";
    try {
    for(int interim=0;interim<4;interim++){
      stage="HTTP_STATUS_TIMEOUT";String status=line(in,8192);need(status.matches("HTTP/1\\.[01] [1-5][0-9]{2}( .*)?"),"HTTP");int code=Integer.parseInt(status.substring(9,12));
      stage="HTTP_HEADERS_TIMEOUT";var head=new StringBuilder(status+"\r\n");var fields=new HashMap<String,String>();
      for(int i=0;;i++){String l=line(in,8192);head.append(l).append("\r\n");need(i<100&&head.length()<65536,"HTTP");if(l.isEmpty())break;
        int colon=l.indexOf(':');need(colon>0&&!Character.isWhitespace(l.charAt(0)),"HTTP");String k=l.substring(0,colon).toLowerCase(Locale.ROOT);need(k.matches("[a-z0-9-]+")&&!fields.containsKey(k),"HTTP");fields.put(k,l.substring(colon+1).trim());}
      if(code>=100&&code<200){need(code==100,"HTTP");continue;}
      need(!fields.containsKey("content-encoding")||fields.get("content-encoding").equals("identity"),"HTTP");
      need(!(fields.containsKey("content-length")&&fields.containsKey("transfer-encoding")),"HTTP");
      stage="HTTP_BODY_TIMEOUT";byte[] body;
      if(fields.containsKey("content-length")){
        String n=fields.get("content-length");need(n.matches("[0-9]{1,8}"),"HTTP");int len=Integer.parseInt(n);need(len<=MAX_REPLY,"HTTP");body=in.readNBytes(len);need(body.length==len,"HTTP");
      }else if(fields.containsKey("transfer-encoding")){
        need(fields.get("transfer-encoding").equalsIgnoreCase("chunked"),"HTTP");var buf=new ByteArrayOutputStream();
        while(true){String n=line(in,100);need(n.matches("[0-9a-fA-F]{1,7}"),"HTTP");int len=Integer.parseInt(n,16);need(len<=MAX_REPLY-buf.size(),"HTTP");
          if(len==0){need(line(in,8192).isEmpty(),"HTTP");break;}byte[] v=in.readNBytes(len);need(v.length==len&&line(in,2).isEmpty(),"HTTP");buf.write(v);}
        body=buf.toByteArray();
      }else{body=in.readNBytes(MAX_REPLY+1);need(body.length<=MAX_REPLY,"HTTP");}
      return new Reply(code,head.toString(),body);
    }throw new Fault("HTTP");
    }catch(SocketTimeoutException e){throw new Fault(stage);}
  }
  static final class Runtime implements AutoCloseable {
    final IdentityFactory identities;final ChannelFactory channels;final Clock clock;
    Identity identity;Trust trust;Channel td,deposit;Map<String,String> config;
    String deleteTarget;boolean deletionUsed;
    int submissionStage; boolean consultationMetadata, retrieveUsed;
    byte[] visibilityMetadata; int visibilityStage; String visibilityUpdatedId;
    String id;Instant issued,expires,authenticationExpires;boolean opened,tdUsed,signed,depositUsed,closed,authorizationUsed,authorizationRechecked,searchUsed,parked;
    Runtime(IdentityFactory i,ChannelFactory c,Clock clock){identities=i;channels=c;this.clock=clock;}
    static URI endpoint(String v)throws Exception {
      var u=new URI(v);need("https".equals(u.getScheme())&&u.getHost()!=null&&u.getRawPath()!=null&&!u.getRawPath().isEmpty()&&u.getUserInfo()==null&&u.getQuery()==null&&u.getFragment()==null&&(u.getPort()==-1||u.getPort()>0),"CONFIGURATION");return u;
    }
    Map<String,String> call(String op,Map<String,String> f)throws Exception {
      if(op.equals("close")){close();return Map.of();}
      if(op.equals("open"))return open(f);
      if(op.equals("resume"))return begin(f,true);
      if(op.equals("authenticationcheck")){
        need(parked,"SESSION");authenticationCurrent();return Map.of("professional",config.get("professional"));
      }
      if(op.equals("park")){
        need(opened&&!parked&&id.equals(f.get("id"))&&"true".equals(config.get("reuseAuthentication"))&&"true".equals(config.get("accessOnly")),"SESSION");
        current();closeChannels();parked=true;id=null;issued=null;expires=null;
        tdUsed=signed=depositUsed=authorizationUsed=authorizationRechecked=searchUsed=false;submissionStage=0;consultationMetadata=retrieveUsed=false;visibilityMetadata=null;visibilityStage=0;visibilityUpdatedId=null;
        return Map.of("authenticationExpiresAt",authenticationExpires.toString());
      }
      need(opened&&!parked&&!closed&&id.equals(f.get("id")),"SESSION");current();
      return switch(op){
        case "current" -> Map.of("id",id,"authHash",config.get("authHash"),"signHash",config.get("signHash"),"tdChannel",td.evidence().get("channel"),"depositChannel",deposit.evidence().get("channel"));
        case "td" -> {
          need(!tdUsed,"SESSION");tdUsed=true;byte[] b=UN64.decode(f.get("body"));need(b.length>0&&b.length<1024*1024,"HTTP");
          need(f.get("contentType").equals("application/soap+xml; charset=UTF-8; action=\"urn:hl7-org:v3:PRPA_IN201307UV02\""),"HTTP");
          yield td.exchange(b,f.get("contentType")).fields();
        }
        case "submissionsearch" -> {
          need("true".equals(config.get("accessOnly"))&&!config.containsKey("replacementUniqueId")&&!config.containsKey("depublicationUniqueId")&&tdUsed&&!authorizationUsed&&!signed&&!depositUsed,"SESSION");
          String stage=f.get("stage");int next="submissions".equals(stage)?1:"associations".equals(stage)?2:"documents".equals(stage)?3:0;
          need(next>0&&(submissionStage==0?(!searchUsed&&next==1):(next!=1&&next>=submissionStage&&next<=submissionStage+1)),"SESSION");
          // A malformed request consumes this session's search capability too.
          searchUsed=true;submissionStage=next;
          need(("application/soap+xml; charset=UTF-8; action=\""+SEARCH_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));checkSubmissionSearch(b,stage);
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {yield channel.exchange(b,f.get("contentType")).fields();}
        }
        case "visibilitymetadata" -> {
          need("true".equals(config.get("accessOnly"))&&!config.containsKey("replacementUniqueId")&&!config.containsKey("depublicationUniqueId")&&tdUsed&&!authorizationUsed&&!signed&&!depositUsed&&!retrieveUsed&&(visibilityStage==0?!searchUsed:visibilityStage==2),"SESSION");
          boolean after=visibilityStage==2;searchUsed=true;visibilityStage=after?3:1;
          need(("application/soap+xml; charset=UTF-8; action=\""+SEARCH_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));checkSubmissionSearch(b,"documents");
          var values=safeXml(b).getElementsByTagNameNS(RIM_NS,"Value");need(values.getLength()==1,"CONFIGURATION");
          String ids=values.item(0).getTextContent();need(ids.matches("\\('urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}'\\)"),"CONFIGURATION");
          need(!after||ids.equals("('"+visibilityUpdatedId+"')"),"CONFIGURATION");
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {
            var reply=channel.exchange(b,f.get("contentType"));
            if(!after&&reply.status==200)visibilityMetadata=reply.body.clone();yield reply.fields();
          }
        }
        case "visibilityupdate" -> {
          need("true".equals(config.get("accessOnly"))&&tdUsed&&visibilityStage==1&&visibilityMetadata!=null&&!authorizationUsed&&!signed&&!depositUsed&&!retrieveUsed,"SESSION");
          visibilityStage=2;
          need(("application/soap+xml; charset=UTF-8; action=\""+DELETE_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));visibilityUpdatedId=checkVisibility(b,visibilityMetadata);
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {yield channel.exchange(b,f.get("contentType")).fields();}
        }
        case "consultmetadata" -> {
          need("true".equals(config.get("accessOnly"))&&!config.containsKey("replacementUniqueId")&&!config.containsKey("depublicationUniqueId")&&tdUsed&&!searchUsed&&!authorizationUsed&&!signed&&!depositUsed,"SESSION");
          searchUsed=true;
          need(("application/soap+xml; charset=UTF-8; action=\""+SEARCH_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));checkSubmissionSearch(b,"documents");
          var values=safeXml(b).getElementsByTagNameNS(RIM_NS,"Value");
          need(values.getLength()==1&&values.item(0).getTextContent().matches("\\('urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}'\\)"),"CONFIGURATION");
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {
            var reply=channel.exchange(b,f.get("contentType"));consultationMetadata=reply.status==200;yield reply.fields();
          }
        }
        case "retrieve" -> {
          need("true".equals(config.get("accessOnly"))&&!config.containsKey("replacementUniqueId")&&!config.containsKey("depublicationUniqueId")&&tdUsed&&consultationMetadata&&!retrieveUsed&&!authorizationUsed&&!signed&&!depositUsed,"SESSION");
          retrieveUsed=true;
          need(("application/soap+xml; charset=UTF-8; action=\""+RETRIEVE_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));checkRetrieve(b);
          yield deposit.exchange(b,f.get("contentType")).fields();
        }
        case "finddocuments" -> {
          need("true".equals(config.get("accessOnly"))&&!config.containsKey("replacementUniqueId")&&!config.containsKey("depublicationUniqueId")&&tdUsed&&!searchUsed&&!authorizationUsed&&!signed&&!depositUsed,"SESSION");
          searchUsed=true;
          need(("application/soap+xml; charset=UTF-8; action=\""+SEARCH_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));checkFindDocuments(b);
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {yield channel.exchange(b,f.get("contentType")).fields();}
        }
        case "search" -> {
          need(("true".equals(config.get("accessOnly"))||config.containsKey("replacementUniqueId"))&&tdUsed&&!searchUsed&&!authorizationUsed&&!signed&&!depositUsed,"SESSION");
          searchUsed=true;
          need(("application/soap+xml; charset=UTF-8; action=\""+SEARCH_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));String target=checkSearch(b);
          if(config.containsKey("depublicationUniqueId"))need(target.equals(config.get("depublicationUniqueId")),"SESSION");
          if(config.containsKey("replacementUniqueId"))need(target.equals(config.get("replacementUniqueId")),"SESSION");
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {
            var reply=channel.exchange(b,f.get("contentType"));
            if(config.containsKey("depublicationUniqueId")){
              try{deleteTarget=deletionTarget(reply);}catch(Exception invalid){deleteTarget=null;}
            }
            yield reply.fields();
          }
        }
        case "depublish" -> {
          need("true".equals(config.get("accessOnly"))&&config.containsKey("depublicationUniqueId")&&tdUsed&&searchUsed&&deleteTarget!=null&&!deletionUsed&&!authorizationUsed&&!signed&&!depositUsed,"SESSION");
          deletionUsed=true;
          need(("application/soap+xml; charset=UTF-8; action=\""+DELETE_ACTION+"\"").equals(f.get("contentType")),"HTTP");
          byte[] b=UN64.decode(f.get("body"));checkDeletion(b,deleteTarget);
          try(Channel channel=channels.open(endpoint(SEARCH_ENDPOINT),identity,trust)) {
            yield channel.exchange(b,f.get("contentType")).fields();
          }
        }
        case "authorization", "authorizationrecheck" -> {
          need("true".equals(config.get("accessOnly"))&&tdUsed&&!searchUsed,"SESSION");
          need(!config.containsKey("depublicationUniqueId"),"SESSION");
          boolean update=op.equals("authorization");
          if(update){need(!authorizationUsed,"SESSION");authorizationUsed=true;}
          else{need(authorizationUsed&&!authorizationRechecked,"SESSION");authorizationRechecked=true;}
          String action=update?"urn:si-dmp-habilitations:HabilitationsEndPoint:setAuthorization":"urn:hl7-org:v3:PRPA_IN201307UV02";
          need(f.get("contentType").equals("application/soap+xml; charset=UTF-8; action=\""+action+"\""),"HTTP");
          byte[] b=UN64.decode(f.get("body"));need(b.length>0&&b.length<1024*1024,"HTTP");
          // A fresh mutual TLS channel: existing channels are deliberately single-use.
          URI target=endpoint(update?"https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/habilitations":config.get("tdEndpoint"));
          try(Channel channel=channels.open(target,identity,trust)) {
            yield channel.exchange(b,f.get("contentType")).fields();
          }
        }
        case "sign" -> {
          need(!"true".equals(config.get("accessOnly"))&&tdUsed&&!signed&&config.get("signHash").equals(f.get("signHash")),"SESSION");signed=true;
          byte[] b=UN64.decode(f.get("body"));need(b.length>0&&b.length<1024*1024,"CONFIGURATION");
          byte[] sig=identity.signature(b);verify(identity.signing(),b,sig,"SHA1withRSA");yield Map.of("signature",B64.encodeToString(sig));
        }
        case "deposit" -> {
          need(!"true".equals(config.get("accessOnly"))&&tdUsed&&signed&&!depositUsed,"SESSION");depositUsed=true;
          byte[] b=UN64.decode(f.get("body"));need(b.length>0&&b.length<=MAX_BODY&&f.get("contentType").startsWith("multipart/related;"),"HTTP");
          yield deposit.exchange(b,f.get("contentType")).fields();
        }
        default -> throw new Fault("CONFIGURATION");
      };
    }
    Map<String,String> open(Map<String,String> f)throws Exception {
      return begin(f,false);
    }
    Map<String,String> begin(Map<String,String> f,boolean reuse)throws Exception {
      need(!closed&&(reuse?parked:!opened),"SESSION");
      char[] pin=reuse?new char[0]:Objects.requireNonNull(f.remove("pin")).toCharArray();
      String stage="CONFIGURATION";
      try {
        if(reuse){need(config.equals(f),"CONFIGURATION");authenticationCurrent();}
        else {
          config=Map.copyOf(f);
          need(!"true".equals(f.get("reuseAuthentication"))||"true".equals(f.get("accessOnly")),"CONFIGURATION");
        }
        if(f.containsKey("depublicationUniqueId"))need("true".equals(f.get("accessOnly"))&&!"true".equals(f.get("reuseAuthentication"))&&f.get("depublicationUniqueId").matches("[0-2](\\.[0-9]+)+"),"CONFIGURATION");
        deleteTarget=null;deletionUsed=false;
        opened=true;parked=false;tdUsed=signed=depositUsed=authorizationUsed=authorizationRechecked=searchUsed=false;submissionStage=0;
        var tdEndpoint=endpoint(f.get("tdEndpoint"));var depositEndpoint=endpoint(f.get("depositEndpoint"));
        if("true".equals(f.get("accessOnly")))need(
          tdEndpoint.toString().equals("https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients")&&
          depositEndpoint.toString().equals("https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository"),"CONFIGURATION");
        need(!f.get("authHash").equals(f.get("signHash"))&&f.get("professional").matches("[0-9]{8,16}"),"CONFIGURATION");
        stage="TRUST";trust=new Trust(Path.of(f.get("trustPath")),f.get("trustHash"),clock);
        stage="CARD";
        if(!reuse){identity=identities.open(config,pin);authenticationExpires=clock.instant().plusSeconds(3600);}
        stage="CERTIFICATE";checkIdentity();
        stage="CHALLENGE";identity.current();
        stage="TD_TLS";td=channels.open(tdEndpoint,identity,trust);
        stage="REPOSITORY_TLS";deposit=channels.open(depositEndpoint,identity,trust);
        stage="RESULT";
        // VIHF AuthnInstant is issued only after BOTH mutual handshakes.
        issued=clock.instant();expires=issued.plusSeconds(120);id=UUID.randomUUID().toString();
        var result=new HashMap<String,String>();
        for(String k:List.of("authHash","signHash","professional","trustHash","tdEndpoint","depositEndpoint"))result.put(k,f.get(k));
        result.put("id",id);result.put("issuedAt",issued.toString());result.put("expiresAt",expires.toString());
        result.put("authenticationExpiresAt",authenticationExpires.toString());
        result.put("authDer",B64.encodeToString(identity.auth().getEncoded()));result.put("signDer",B64.encodeToString(identity.signing().getEncoded()));
        result.put("mutualTls","true");result.put("protocol","TLSv1.2");
        for(var e:Map.of("td",td,"deposit",deposit).entrySet())for(String key:List.of("channel","cipher","peer")){
          result.put(e.getKey()+Character.toUpperCase(key.charAt(0))+key.substring(1),e.getValue().evidence().get(key));}
        return result;
      } catch(Exception e){
        String code=classify(e);
        if(code.equals("NATIVE"))code="NATIVE_OPEN_"+stage+"_"+category(e);
        try{close();}catch(Exception suppressed){e.addSuppressed(suppressed);}
        throw new Fault(code);
      }
      finally {Arrays.fill(pin,'\0');}
    }
    void checkIdentity()throws Exception {
      var a=identity.auth();var s=identity.signing();
      need(sha(a.getEncoded()).equals(config.get("authHash"))&&sha(s.getEncoded()).equals(config.get("signHash")),"CPS_CERTIFICATE");
      need(config.get("professional").equals(cn(a))&&config.get("professional").equals(cn(s)),"CPS_IDENTITY");
      need(a.getKeyUsage()!=null&&a.getKeyUsage()[0]&&a.getExtendedKeyUsage()!=null&&a.getExtendedKeyUsage().contains("1.3.6.1.5.5.7.3.2")&&s.getKeyUsage()!=null&&s.getKeyUsage()[1],"CPS_CERTIFICATE");
      trust.chain(a);trust.chain(s);
    }
    void authenticationCurrent()throws Exception {
      need(!closed&&identity!=null&&"true".equals(config.get("reuseAuthentication"))&&
        !clock.instant().isBefore(authenticationExpires.minusSeconds(3600))&&clock.instant().isBefore(authenticationExpires),"SESSION");
      need(sha(Files.readAllBytes(Path.of(config.get("trustPath")))).equals(trust.hash),"CONFIGURATION");
      checkIdentity();identity.current();
    }
    void closeChannels()throws Exception {
      Exception failure=null;
      for(Channel c:new Channel[]{td,deposit})if(c!=null)try{c.close();}catch(Exception e){failure=e;}
      td=null;deposit=null;
      if(failure!=null)throw failure;
    }
    void current()throws Exception{
      if("true".equals(config.get("reuseAuthentication")))need(clock.instant().isBefore(authenticationExpires),"SESSION");
      need(!parked&&!closed&&clock.instant().compareTo(issued)>=0&&clock.instant().isBefore(expires)&&td.current()&&deposit.current(),"SESSION");
      need(sha(Files.readAllBytes(Path.of(config.get("trustPath")))).equals(trust.hash),"CONFIGURATION");
      checkIdentity();identity.current();
    }
    public void close()throws Exception {
      if(closed)return;closed=true;Exception failure=null;
      for(AutoCloseable c:new AutoCloseable[]{td,deposit,identity})if(c!=null)try{c.close();}catch(Exception e){failure=e;}
      if(failure!=null)throw new Fault("NATIVE");
    }
  }
  // Fixed categories only: never send exception text, stack traces, PIN or card data.
  static String category(Throwable error){
    if(error instanceof ProviderException)return "PROVIDER";
    if(error instanceof NullPointerException)return "MISSING_VALUE";
    if(error instanceof IllegalArgumentException)return "INVALID_VALUE";
    if(error instanceof IOException)return "IO";
    if(error instanceof UnsupportedOperationException)return "UNSUPPORTED";
    return "INTERNAL";
  }
  static String classify(Throwable error){
    for(Throwable e=error;e!=null;e=e.getCause()){
      if(e instanceof Fault f)return f.code;
      if(e instanceof CertificateExpiredException)return "TLS_EXPIRED";
      if(e instanceof CertificateNotYetValidException)return "TLS_FUTURE";
      if(e instanceof CertificateRevokedException)return "TLS_REVOKED";
      if(e instanceof CertPathValidatorException p&&p.getReason()==CertPathValidatorException.BasicReason.REVOKED)return "TLS_REVOKED";
      if(e instanceof SocketTimeoutException)return "TLS_TIMEOUT";
      if(e instanceof UnknownHostException||e instanceof ConnectException)return "TLS_UNAVAILABLE";
      String message=String.valueOf(e.getMessage());
      // Map provider errors to fixed text only; never return raw native errors.
      if(message.contains("CKR_MECHANISM_INVALID")||message.contains("CKR_MECHANISM_PARAM_INVALID"))return "CPS_MECHANISM";
      if(message.contains("CKR_FUNCTION_FAILED")||message.contains("CKR_DEVICE_ERROR"))return "CPS_CRYPTO_FAILURE";
      if(message.contains("CKR_KEY_FUNCTION_NOT_PERMITTED"))return "CPS_KEY_USAGE";
      if(message.contains("CKR_PIN_INCORRECT"))return "CPS_PIN";
      if(message.contains("CKR_PIN_LOCKED"))return "CPS_BLOCKED";
      if(message.contains("CKR_TOKEN_NOT_PRESENT")||message.contains("CKR_DEVICE_REMOVED"))return "CPS_ABSENT";
      if(message.contains("CKR_USER_ALREADY_LOGGED_IN")||message.contains("CKR_CRYPTOKI_ALREADY_INITIALIZED"))return "CPS_BUSY";
      if(message.contains("No subject alternative")||message.contains("No name matching"))return "TLS_HOSTNAME";
    }
    if(error instanceof SSLException)return "TLS_TRUST";
    for(Throwable e=error;e!=null;e=e.getCause()){
      if(e instanceof InvalidKeyException||e instanceof SignatureException)return "CPS_CRYPTO_FAILURE";
    }
    if(error instanceof GeneralSecurityException)return "TLS_TRUST";
    return "NATIVE";
  }
  static String frame(InputStream in)throws Exception {
    var b=new ByteArrayOutputStream();int c;
    while((c=in.read())!=-1){if(c==10)return b.toString(StandardCharsets.UTF_8);need(c!=13&&b.size()<MAX_FRAME,"CONFIGURATION");b.write(c);}
    need(b.size()==0,"CONFIGURATION");return null;
  }
  static void serve(Runtime runtime,InputStream input,PrintStream output)throws Exception{
    long previous=0;
    try {
      String line;
      while((line=frame(input))!=null){
        String[] parts=line.split("\t",-1);String request=parts[0];
        try {
          need(parts.length>=2&&request.matches("[0-9]{1,10}")&&Long.parseLong(request)==previous+1,"CONFIGURATION");previous=Long.parseLong(request);
          var f=new HashMap<String,String>();
          for(int i=2;i<parts.length;i++){int eq=parts[i].indexOf('=');need(eq>0,"CONFIGURATION");String k=parts[i].substring(0,eq);need(k.matches("[a-zA-Z]+")&&!f.containsKey(k),"CONFIGURATION");f.put(k,new String(UN64.decode(parts[i].substring(eq+1)),StandardCharsets.UTF_8));}
          String operation=parts[1];Arrays.fill(parts,null);line=null;
          var result=runtime.call(operation,f);StringBuilder response=new StringBuilder(request+"\tOK");
          for(var e:new TreeMap<>(result).entrySet())response.append('\t').append(e.getKey()).append('=').append(B64.encodeToString(e.getValue().getBytes(StandardCharsets.UTF_8)));
          output.println(response);output.flush();if(operation.equals("close"))break;
        }catch(Exception e){output.println(request+"\tERR_"+classify(e));output.flush();break;}
      }
    }finally{runtime.close();}
  }
  public static void main(String[] args)throws Exception{
    need(args.length==1&&args[0].equals("--serve"),"CONFIGURATION");
    serve(new Runtime(CardIdentity::new,SocketChannel::new,Clock.systemUTC()),System.in,System.out);
  }
}
