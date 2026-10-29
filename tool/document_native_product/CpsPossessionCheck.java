import java.security.*;
/** Offline: generated software keys only. Does not prove CPS compatibility. */
public class CpsPossessionCheck {
  public static void main(String[]args)throws Exception {
    var generator=KeyPairGenerator.getInstance("RSA");generator.initialize(2048);
    var a=generator.generateKeyPair();var b=generator.generateKeyPair();
    DmpNativeBridge.provePossession(a.getPrivate(),a.getPublic());
    boolean refused=false;
    try { DmpNativeBridge.provePossession(a.getPrivate(),b.getPublic()); }
    catch(DmpNativeBridge.Fault e){refused=e.code.equals("CPS_CERTIFICATE");}
    if(!refused)throw new AssertionError("Wrong public key accepted");
    if(!DmpNativeBridge.classify(new ProviderException("CKR_MECHANISM_INVALID")).equals("CPS_MECHANISM"))throw new AssertionError();
    if(!DmpNativeBridge.classify(new ProviderException("CKR_FUNCTION_FAILED")).equals("CPS_CRYPTO_FAILURE"))throw new AssertionError();
    System.out.println("Possession SHA-256 : clé correcte acceptée, clé différente refusée ; erreurs classées. Aucune carte ni connexion.");
  }
}
