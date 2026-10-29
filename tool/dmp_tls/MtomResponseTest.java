import java.nio.file.*;
public class MtomResponseTest {
 public static void main(String[] args)throws Exception{
  Path p=Path.of(args[0]);var q=DmpTd21Deposit.parseBytes(Files.readAllBytes(p.resolve("requete-soap.xml")));
  String h=Files.readString(p.resolve("http.txt"));byte[] b=Files.readAllBytes(p.resolve("reponse.xml"));
  var r=new DmpTd21Deposit.HttpResponse(200,h,b);
  String result=DmpTd21Deposit.describe(r,q);
  if(!result.contains("DMPInvalidSignature")||!result.contains("rejeté"))throw new AssertionError(result);
  String text=new String(b,java.nio.charset.StandardCharsets.UTF_8);
  String success=text.replace("ResponseStatusType:Failure","ResponseStatusType:Success").replaceAll("<ns2:RegistryErrorList>.*?</ns2:RegistryErrorList>","");
  if(!DmpTd21Deposit.describe(new DmpTd21Deposit.HttpResponse(200,h,success.getBytes(java.nio.charset.StandardCharsets.UTF_8)),q).contains("confirmé par DV1"))throw new AssertionError("Success MTOM");
  String missing=h.replace("root.message@cxf.apache.org","missing");
  try{DmpTd21Deposit.soapBody(new DmpTd21Deposit.HttpResponse(200,missing,b));throw new AssertionError("missing root accepted");}catch(IllegalStateException expected){}
  try{DmpTd21Deposit.soapBody(new DmpTd21Deposit.HttpResponse(200,h,java.util.Arrays.copyOf(b,b.length-20)));throw new AssertionError("truncated accepted");}catch(IllegalStateException expected){}
  System.out.println("MTOM : rejet réel DV1, succès simulé, racine absente et troncature vérifiés hors ligne.");
 }
}
