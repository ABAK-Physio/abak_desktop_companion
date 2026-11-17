import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.time.*;
import java.util.*;
import javax.tools.ToolProvider;

/** Compile and test the supplied worker with JDK public APIs. No OPEN, card or network. */
public class DmpWindowsOfflineTests {
  static int checks;
  static void check(boolean value,String name) {
    if(!value)throw new AssertionError(name);
    checks++;
  }
  public static void main(String[] args)throws Exception {
    if(args.length!=1)throw new IllegalArgumentException("worker source required");
    Path classes=Files.createTempDirectory("abak-dv1-java-tests-");
    try {
      var compiler=ToolProvider.getSystemJavaCompiler();
      check(compiler!=null,"JDK source compiler");
      check(Runtime.version().feature()>=17,"Java 17 or newer");
      check("64".equals(System.getProperty("sun.arch.data.model")),"64-bit Java");
      check(Security.getProvider("SunPKCS11")!=null,"SunPKCS11 module available (not configured)");
      check(compiler.run(null,null,null,"-encoding","UTF-8","-d",classes.toString(),args[0])==0,"worker compiles");
      try(var loader=new URLClassLoader(new URL[]{classes.toUri().toURL()})){
        var worker=loader.loadClass("DmpNativeBridge");
        var library=worker.getDeclaredMethod("librarySetting",String.class,boolean.class);library.setAccessible(true);
        var config=worker.getDeclaredMethod("pkcs11Configuration",String.class,boolean.class);config.setAccessible(true);
        for(String path:List.of("C:\\Windows\\System32\\cps3_pkcs11_w64.dll","D:/Windows/System32/cps3_pkcs11_w64.dll","C:\\Program Files\\Santé\\cps.dll")){
          String result=(String)library.invoke(null,path,true);
          check(result.equals(path.replace('\\','/')),"Windows quoted path preserves spaces/unicode");
          String text=(String)config.invoke(null,path,true);
          check(text.contains("\nlibrary=\""+result+"\"\nslotListIndex=0\n"),"quoted PKCS11 library");
          check(text.contains("disabledMechanisms={ CKM_SHA224_RSA_PKCS CKM_SHA256_RSA_PKCS CKM_SHA384_RSA_PKCS CKM_SHA512_RSA_PKCS }"),"Mac mechanisms retained");
        }
        check(library.invoke(null,"/usr/local/lib/libcps3_pkcs11_osx.dylib",false).equals("/usr/local/lib/libcps3_pkcs11_osx.dylib"),"Mac path retained");
        var bad=new ArrayList<>(List.of("", "C:relative.dll", "\\Windows\\cps.dll", "\\\\server\\share\\cps.dll", "\\\\?\\C:\\cps.dll", "C:\\..\\cps.dll", "C:\\.\\cps.dll", "C:\\bad\".dll", "C:\\bad{.dll", "C:\\bad}.dll", "/usr/local/lib/cps.dylib"));
        for(char c:new char[]{0,9,10,13,31,127})bad.add("C:\\bad"+c+".dll");
        bad.add("C:\\"+"x".repeat(4096));
        for(String path:bad){
          boolean blocked=false;
          try{library.invoke(null,path,true);}catch(java.lang.reflect.InvocationTargetException e){blocked=true;}
          check(blocked,"unsafe Windows library rejected");
        }
        // Loading the worker and a CLOSE frame must never construct card/TLS factories.
        var runtimeClass=loader.loadClass("DmpNativeBridge$Runtime");
        var identityFactory=loader.loadClass("DmpNativeBridge$IdentityFactory");
        var channelFactory=loader.loadClass("DmpNativeBridge$ChannelFactory");
        int[] calls={0};
        var handler=(java.lang.reflect.InvocationHandler)(proxy,method,values)->{calls[0]++;throw new AssertionError("native/network factory called");};
        Object identities=java.lang.reflect.Proxy.newProxyInstance(loader,new Class[]{identityFactory},handler);
        Object channels=java.lang.reflect.Proxy.newProxyInstance(loader,new Class[]{channelFactory},handler);
        var constructor=runtimeClass.getDeclaredConstructor(identityFactory,channelFactory,Clock.class);constructor.setAccessible(true);
        Object runtime=constructor.newInstance(identities,channels,Clock.systemUTC());
        var serve=worker.getDeclaredMethod("serve",runtimeClass,InputStream.class,PrintStream.class);serve.setAccessible(true);
        var bytes=new ByteArrayOutputStream();
        serve.invoke(null,runtime,new ByteArrayInputStream("1\tclose\n".getBytes(StandardCharsets.UTF_8)),new PrintStream(bytes,true,StandardCharsets.UTF_8));
        check(bytes.toString(StandardCharsets.UTF_8).replace("\r\n","\n").equals("1\tOK\n"),"read-only close protocol");
        check(calls[0]==0,"no card login, signature or network");
      }
      System.out.println("ABAK_DV1_WINDOWS_OFFLINE_OK checks="+checks+" CARD_ACCESSED=false NETWORK_ACCESSED=false");
    } finally {
      try(var paths=Files.walk(classes)){for(Path p:paths.sorted(Comparator.reverseOrder()).toList())Files.deleteIfExists(p);}
    }
  }
}
