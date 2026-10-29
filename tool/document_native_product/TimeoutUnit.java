import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
/** Deterministic failures injected in memory: no socket or CPS. */
public class TimeoutUnit {
  static int count;
  static void check(boolean ok){if(!ok)throw new AssertionError();count++;}
  static void failure(String expected,DmpNativeBridge.TimedAction action)throws Exception {
    try{action.run();throw new AssertionError("timeout missing");}
    catch(DmpNativeBridge.Fault e){check(e.code.equals(expected));check(!e.getMessage().contains("SECRET"));}
  }
  static InputStream stalled(String prefix){
    byte[] bytes=prefix.getBytes(StandardCharsets.US_ASCII);
    return new InputStream(){int at;public int read()throws IOException {
      if(at<bytes.length)return bytes[at++];throw new SocketTimeoutException("SECRET");
    }};
  }
  public static void main(String[] args)throws Exception {
    for(String code:new String[]{"TCP_CONNECT_TIMEOUT","TLS_HANDSHAKE_TIMEOUT"})
      failure(code,()->DmpNativeBridge.timed(code,()->{throw new SocketTimeoutException("SECRET");}));
    failure("HTTP_STATUS_TIMEOUT",()->DmpNativeBridge.readHttp(stalled("")));
    failure("HTTP_HEADERS_TIMEOUT",()->DmpNativeBridge.readHttp(stalled("HTTP/1.1 200 OK\r\n")));
    failure("HTTP_BODY_TIMEOUT",()->DmpNativeBridge.readHttp(stalled("HTTP/1.1 200 OK\r\nContent-Length: 3\r\n\r\na")));
    failure("HTTP_BODY_TIMEOUT",()->DmpNativeBridge.readHttp(stalled("HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n3\r\na")));
    String type="application/soap+xml; charset=UTF-8; action=\""+DmpNativeBridge.SEARCH_ACTION+"\"";
    check(DmpNativeBridge.responseTimeout(URI.create(DmpNativeBridge.SEARCH_ENDPOINT),type)==45000);
    check(DmpNativeBridge.responseTimeout(URI.create(DmpNativeBridge.SEARCH_ENDPOINT),type.replace(DmpNativeBridge.SEARCH_ACTION,DmpNativeBridge.DELETE_ACTION))==15000);
    check(DmpNativeBridge.responseTimeout(URI.create("https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/patients"),type)==15000);
    System.out.println(count+" timeout checks passed; no network or CPS");
  }
}
