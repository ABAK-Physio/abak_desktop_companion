// ABAK local CDA checks. Java 17+, Saxon HE supplied by the selected references.
// Executed by the product adapter in a network-denied, job-write-only sandbox.
import java.io.*;
import java.nio.file.*;
import javax.xml.XMLConstants;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.*;
import javax.xml.validation.*;
import org.xml.sax.*;

class CdaCheck {
  static Path refs, job;
  static Source safe(Path path) throws Exception {
    SAXParserFactory f = SAXParserFactory.newInstance(); f.setNamespaceAware(true);
    f.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
    f.setFeature("http://xml.org/sax/features/external-general-entities", false);
    f.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
    XMLReader r = f.newSAXParser().getXMLReader();
    return new SAXSource(r, new InputSource(path.toUri().toString()));
  }
  static void transform(Path source, Path style, Path target) throws Exception {
    TransformerFactory f = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", CdaCheck.class.getClassLoader());
    URIResolver resolver = (href, base) -> {
      try {
        Path p = Paths.get(href.isEmpty() ? new java.net.URI(base) : new java.net.URI(base).resolve(href.replace(" ", "%20"))).toRealPath();
        if (!p.startsWith(refs)) throw new IOException("Référence hors du dossier local");
        return safe(p);
      } catch (Exception e) { throw new TransformerException(e); }
    };
    ErrorListener errors=new ErrorListener() {
      public void warning(TransformerException e) { System.err.println(e.getMessage()); }
      public void error(TransformerException e) throws TransformerException { throw e; }
      public void fatalError(TransformerException e) throws TransformerException { throw e; }
    };
    f.setErrorListener(errors); f.setURIResolver(resolver);
    Transformer t = f.newTransformer(safe(style)); t.setURIResolver(resolver); t.setErrorListener(errors);
    t.transform(safe(source), new StreamResult(target.toFile()));
  }
  public static void main(String[] args) throws Exception {
    refs=Paths.get(args[0]).toRealPath(); job=Paths.get(args[1]).toRealPath();
    // The XSD bundle may reference only local files; input DTDs are prohibited.
    SchemaFactory f=SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
    f.setProperty(XMLConstants.ACCESS_EXTERNAL_DTD, "");
    f.setResourceResolver((type, ns, publicId, systemId, baseURI) -> {
      try {
        org.w3c.dom.ls.DOMImplementationLS impl=(org.w3c.dom.ls.DOMImplementationLS)DocumentBuilderFactory.newInstance().newDocumentBuilder().getDOMImplementation().getFeature("LS","3.0");
        org.w3c.dom.ls.LSInput input=impl.createLSInput();
        // Same policy as the prior no-load-DTD schema reader: schema declarations
        // are interpreted as XML Schema, never via an external DTD. Input CDA
        // documents use safe() above, which rejects the DOCTYPE entirely.
        if (XMLConstants.XML_DTD_NS_URI.equals(type)) {
          input.setCharacterStream(new StringReader("")); return input;
        }
        Path resource=Paths.get(new java.net.URI(baseURI).resolve(systemId)).toRealPath();
        if (!resource.startsWith(refs)) throw new IOException("Schéma hors des références locales");
        input.setByteStream(Files.newInputStream(resource)); input.setSystemId(resource.toUri().toString());
        input.setBaseURI(resource.getParent().toUri().toString()); return input;
      } catch (Exception e) { throw new IllegalArgumentException(e); }
    });
    f.setProperty(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "file");
    Schema schema=f.newSchema(refs.resolve("infrastructure/cda/CDA_extended.xsd").toFile());
    boolean valid=true;
    try { schema.newValidator().validate(safe(job.resolve("document.xml"))); }
    catch (SAXParseException e) { valid=false; Files.writeString(job.resolve("xsd-error.txt"),e.getMessage()); }
    Files.writeString(job.resolve("xsd.xml"), "<xsd completed=\"true\" valid=\""+valid+"\"/>");
    String[] profiles={"structurationMinimale/ASIP-STRUCT-MIN-StrucMin", "IHE", "CI-SIS_ModelesDeContenusCDA", "CI-SIS_Modeles_ANS", "terminologies/schematron/terminologie"};
    String[] engines={"iso_dsdl_include", "iso_abstract_expand", "iso_svrl_for_xslt2"};
    for (int n=0;n<profiles.length;n++) {
      Path source=refs.resolve("schematrons/profils/"+profiles[n]+".sch");
      for (int i=0;i<engines.length;i++) {
        // Keep the relative location: document() and schema includes use it.
        Path dest=source.resolveSibling("abak-"+n+"-"+i+".xsl");
        transform(source,refs.resolve("schematrons/moteur/"+engines[i]+".xsl"),dest); source=dest;
      }
      transform(job.resolve("document.xml"),source,job.resolve("profile-"+n+".xml"));
    }
    Files.writeString(job.resolve("completed.txt"),"ABAK-CDA-1");
  }
}
