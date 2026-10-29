import Foundation
import Security
// Test host for the unchanged product XPC protocol. Only synthetic requests.
@main struct Recipe {
static func main() {
let connection=NSXPCConnection(serviceName:"fr.abakphysio.documentcontrols")
connection.remoteObjectInterface=NSXPCInterface(with:AbakDocumentControlService.self)
if #available(macOS 13.0,*) {
    connection.setCodeSigningRequirement("anchor apple generic and identifier \"fr.abakphysio.documentcontrols\" and certificate leaf[subject.OU] = \"LP84QVHHSV\"")
} else { exit(78) }
nonisolated func failed(_ s:String) { FileHandle.standardError.write(Data(s.utf8)); exit(1) }
connection.interruptionHandler={ failed("XPC interrompu") }
connection.invalidationHandler={ failed("XPC déconnecté") }
connection.resume()
guard CommandLine.arguments.count == 3,
      let remote=connection.remoteObjectProxyWithErrorHandler({ failed($0.localizedDescription) }) as? AbakDocumentControlService,
      let data=try? Data(contentsOf:URL(fileURLWithPath:CommandLine.arguments[1])) else { exit(64) }
remote.run(data) { answer in
    do { try answer.write(to:URL(fileURLWithPath:CommandLine.arguments[2]),options:.atomic); exit(0) }
    catch { failed(error.localizedDescription) }
}
DispatchQueue.global().asyncAfter(deadline:.now()+290) { failed("Délai XPC dépassé") }
RunLoop.current.run()
}
}
