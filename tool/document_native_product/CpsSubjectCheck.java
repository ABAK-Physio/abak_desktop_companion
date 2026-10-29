import java.nio.file.*;
import java.security.cert.*;
import javax.security.auth.x500.X500Principal;

/** Offline regression: public certificates only, no card or network. */
public class CpsSubjectCheck {
  static void expect(String dn,String value)throws Exception {
    if(!value.equals(DmpNativeBridge.cn(new X500Principal(dn))))throw new AssertionError("CN extraction");
  }
  static void reject(String dn)throws Exception {
    try { DmpNativeBridge.cn(new X500Principal(dn)); }
    catch(DmpNativeBridge.Fault e) {
      if("CPS_IDENTITY".equals(e.code))return;
      throw e;
    }
    throw new AssertionError("Ambiguous or missing CN accepted");
  }
  public static void main(String[]args)throws Exception {
    expect("CN=12345678,C=FR","12345678");
    expect("2.5.4.4=TEST+CN=12345678+2.5.4.42=TEST,C=FR","12345678");
    expect("2.5.4.42=TEST+CN=12345678+2.5.4.4=TEST,C=FR","12345678");
    reject("2.5.4.4=TEST+2.5.4.42=TEST,C=FR");
    reject("CN=12345678,CN=87654321,C=FR");
    reject("CN=12345678+CN=87654321,C=FR");
    for(int i=0;i<args.length;i+=2) {
      try(var input=Files.newInputStream(Path.of(args[i]))) {
        var cert=(X509Certificate)CertificateFactory.getInstance("X.509").generateCertificate(input);
        if(!args[i+1].equals(DmpNativeBridge.cn(cert)))throw new AssertionError("Public certificate CN");
      }
    }
    System.out.println("CN: 6 cas synthétiques et "+args.length/2+" certificats publics conformes.");
  }
}
