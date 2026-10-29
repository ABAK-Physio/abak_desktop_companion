import Foundation
import Security
import CryptoKit
import Darwin

// A separately launched XPC service does not inherit the application's App Sandbox.
// Before accepting ANY connection it applies its own one-time Seatbelt policy.
// No request can change this policy, its write root or the executed command shape.
func quote(_ value: String) -> String {
    "\"" + value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
}
func fail(_ message: String) -> NSError { NSError(domain: "ABAK.DocumentControls", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
func regular(_ path: String, directory: Bool = false) throws -> URL {
    guard path.hasPrefix("/"), !path.contains("\0") else { throw fail("Chemin absolu requis") }
    guard let canonical = realpath(path, nil) else { throw fail("Ressource indisponible") }
    defer { free(canonical) }
    guard String(cString:canonical) == path else { throw fail("Lien ou chemin non canonique") }
    let url = URL(fileURLWithPath: path)
    let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey])
    guard values.isSymbolicLink != true, directory ? values.isDirectory == true : values.isRegularFile == true else { throw fail("Ressource régulière requise") }
    return url
}
func fileDigest(_ url: URL) throws -> String { SHA256.hash(data: try Data(contentsOf: url)).map { String(format:"%02x",$0) }.joined() }
let fm = FileManager.default
// A short, mode-0700 root also fits macOS Unix socket paths used by Office.
let template = "/private/tmp/ak-XXXXXX"
var chars = Array(template.utf8CString)
guard let made = mkdtemp(&chars) else { exit(78) }
// Foundation removes /private from /private/var. Seatbelt requires the actual
// filesystem spelling, so preserve POSIX realpath for the policy and all jobs.
guard let canonicalWork = realpath(made, nil) else { exit(78) }
let work = URL(fileURLWithPath: String(cString: canonicalWork))
free(canonicalWork)
let profile = "(version 1)(allow default)(deny network* (require-not (local unix-socket (subpath \(quote(work.path))))))(deny file-write* (require-all (require-not (subpath \(quote(work.path)))) (require-not (literal \"/dev/null\"))))(deny file-read* (literal \"/usr/local/lib/libcps3_pkcs11_osx.dylib\"))(deny iokit-open)"
guard profile.withCString({ abak_apply_sandbox($0) }) == 0,
      abak_policy_denies_network() == 1 else { exit(78) }
let policyHash = SHA256.hash(data: Data(profile.utf8)).map { String(format:"%02x",$0) }.joined()

final class Capture {
    var data = Data()
    var exceeded = false
    func read(_ handle: FileHandle, process: Process) {
        while true {
            let chunk = handle.readData(ofLength: 65536)
            if chunk.isEmpty { break }
            if data.count + chunk.count > 12 * 1024 * 1024 {
                exceeded = true
                if process.isRunning { kill(process.processIdentifier, SIGKILL) }
                break
            }
            data.append(chunk)
        }
    }
}
final class Worker: NSObject, AbakDocumentControlService {
    static let queue = DispatchQueue(label: "care.abak.document-controls")
    let lock = NSLock()
    var busy = false
    var child: Process?
    var cancelled = false
    func cancel() {
        lock.lock(); cancelled = true
        if let p = child, p.isRunning { kill(p.processIdentifier, SIGKILL) }
        lock.unlock()
    }
    func run(_ request: Data, reply: @escaping (Data) -> Void) {
        lock.lock()
        if busy || cancelled { lock.unlock(); reply(Self.error("Service occupé ou annulé")); return }
        busy = true; lock.unlock()
        Self.queue.async {
            defer { self.lock.lock(); self.busy = false; self.lock.unlock() }
            do { reply(try self.execute(request)) }
            catch { reply(Self.error(error.localizedDescription)) }
        }
    }
    static func error(_ message: String) -> Data {
        (try? JSONSerialization.data(withJSONObject: ["protocol":1,"error":message])) ?? Data()
    }
    func execute(_ request: Data) throws -> Data {
        lock.lock(); let stopped = cancelled; lock.unlock()
        guard !stopped else { throw fail("Contrôle annulé") }
        guard request.count < 65536,
              let value = try JSONSerialization.jsonObject(with: request) as? [String:Any],
              value["protocol"] as? Int == 1,
              let operation = value["operation"] as? String,
              ["pdfa","version","cda","docx"].contains(operation) else { throw fail("Protocole de contrôle invalide") }
        if operation == "docx" { return try convertDocx(value) }
        guard
              let javaPath = value["java"] as? String,
              let jobPath = value["job"] as? String else { throw fail("Protocole de contrôle invalide") }
        let expected: Set<String> = operation == "cda" ? ["protocol","operation","java","job"] : ["protocol","operation","java","job","jar"]
        guard Set(value.keys) == expected else { throw fail("Champ de lancement inattendu") }
        let java = try regular(javaPath)
        guard java.lastPathComponent == "java", java.deletingLastPathComponent().lastPathComponent == "bin", fm.isExecutableFile(atPath: java.path) else { throw fail("Exécutable Java configuré requis") }
        let job = try regular(jobPath,directory:true)
        let scratch = work.appendingPathComponent(UUID().uuidString, isDirectory:true)
        try fm.createDirectory(at:scratch,withIntermediateDirectories:false)
        defer { try? fm.removeItem(at:scratch) }
        // Effective write-boundary check: no write into the caller's job directory.
        let sentinel = job.appendingPathComponent(".abak-write-probe-"+UUID().uuidString)
        let fd = open(sentinel.path,O_CREAT|O_EXCL|O_WRONLY,0o600)
        if fd >= 0 { close(fd); try? fm.removeItem(at:sentinel); throw fail("Isolation des écritures absente") }
        guard errno == EPERM || errno == EACCES else { throw fail("Frontière d’écriture non vérifiée") }
        let inside = scratch.appendingPathComponent("write-probe")
        try Data("synthetic-isolation-check".utf8).write(to:inside,options:.withoutOverwriting)
        try fm.removeItem(at:inside)
        var arguments = ["-Duser.home="+scratch.path,"-Djava.io.tmpdir="+scratch.path]
        if operation == "cda" {
            let xml = try regular(job.appendingPathComponent("document.xml").path)
            guard (try xml.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? Int.max) <= 40*1024*1024 else { throw fail("CDA trop volumineux") }
            try fm.copyItem(at:xml,to:scratch.appendingPathComponent("document.xml"))
            let refs = try regular(job.appendingPathComponent("references").path,directory:true)
            let target = scratch.appendingPathComponent("references",isDirectory:true)
            try fm.createDirectory(at:target,withIntermediateDirectories:false)
            guard let enumerator = fm.enumerator(at:refs,includingPropertiesForKeys:[.isRegularFileKey,.isDirectoryKey,.isSymbolicLinkKey,.fileSizeKey],options:[]) else { throw fail("Références indisponibles") }
            var count = 0, size = 0
            for case let source as URL in enumerator {
                let attributes = try source.resourceValues(forKeys:[.isRegularFileKey,.isDirectoryKey,.isSymbolicLinkKey,.fileSizeKey])
                guard attributes.isSymbolicLink != true else { throw fail("Lien dans les références") }
                let relative = String(source.path.dropFirst(refs.path.count+1))
                let dest = target.appendingPathComponent(relative)
                if attributes.isDirectory == true { try fm.createDirectory(at:dest,withIntermediateDirectories:true) }
                else if attributes.isRegularFile == true {
                    count += 1; size += attributes.fileSize ?? 0
                    guard count <= 18000, size <= 800*1024*1024 else { throw fail("Références trop volumineuses") }
                    try fm.copyItem(at:source,to:dest)
                } else { throw fail("Référence non régulière") }
            }
            guard let bundled = Bundle.main.url(forResource:"CdaCheck",withExtension:"java") else { throw fail("Helper signé absent") }
            guard try fileDigest(bundled) == fileDigest(regular(job.appendingPathComponent("CdaCheck.java").path)) else { throw fail("Helper différent du composant signé") }
            arguments += ["--class-path",target.appendingPathComponent("schematrons/moteur/saxon9he.jar").path,bundled.path,target.path,scratch.path]
        } else {
            guard let jarPath = value["jar"] as? String else { throw fail("Archive veraPDF absente") }
            let jar = try regular(jarPath)
            guard jar.pathExtension == "jar" else { throw fail("Archive veraPDF requise") }
            arguments += ["-cp",jar.path,"org.verapdf.apps.GreenfieldCliWrapper"]
            if operation == "version" { arguments += ["--version"] }
            else {
                let pdf = try regular(job.appendingPathComponent("document.pdf").path)
                arguments += ["--format","xml","--flavour","1b",pdf.path]
            }
        }
        let process = Process()
        process.executableURL = java
        process.arguments = arguments
        process.currentDirectoryURL = scratch
        process.environment = ["PATH":"/usr/bin:/bin","TMPDIR":scratch.path]
        let stdout = Pipe(), stderr = Pipe()
        process.standardOutput=stdout; process.standardError=stderr
        lock.lock()
        if cancelled { lock.unlock(); throw fail("Contrôle annulé") }
        child=process
        do { try process.run() } catch { child=nil; lock.unlock(); throw error }
        lock.unlock()
        let group = DispatchGroup(), out = Capture(), err = Capture()
        group.enter(); DispatchQueue.global().async { out.read(stdout.fileHandleForReading,process:process); group.leave() }
        group.enter(); DispatchQueue.global().async { err.read(stderr.fileHandleForReading,process:process); group.leave() }
        let timer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
        timer.schedule(deadline:.now()+240)
        timer.setEventHandler { if process.isRunning { kill(process.processIdentifier,SIGKILL) } }
        timer.resume()
        process.waitUntilExit(); timer.cancel(); group.wait()
        lock.lock(); child=nil; let interrupted=cancelled; lock.unlock()
        guard !interrupted, !out.exceeded, !err.exceeded else { throw fail("Contrôle annulé ou rapport trop volumineux") }
        var files = [String:String]()
        if operation == "cda" {
            for name in ["completed.txt","xsd.xml","xsd-error.txt"] + (0..<5).map({"profile-\($0).xml"}) {
                let file=scratch.appendingPathComponent(name)
                if fm.fileExists(atPath:file.path) {
                    _ = try regular(file.path)
                    let data=try Data(contentsOf:file)
                    guard data.count <= 12*1024*1024 else { throw fail("Rapport CDA trop volumineux") }
                    files[name]=data.base64EncodedString()
                }
            }
        }
        return try JSONSerialization.data(withJSONObject:["protocol":1,"pid":Int(process.processIdentifier),"exitCode":Int(process.terminationStatus),"stdout":String(decoding:out.data,as:UTF8.self),"stderr":String(decoding:err.data,as:UTF8.self),"files":files,"isolation":["networkDenied":true,"callerJobWriteDenied":true,"privateWriteSucceeded":true,"policySha256":policyHash,"privateRoot":work.path,"servicePid":Int(getpid()),"serviceIdentifier":Bundle.main.bundleIdentifier ?? ""]])
    }
}
final class Delegate: NSObject, NSXPCListenerDelegate {
    let requirement: String
    init(requirement: String) { self.requirement = requirement }
    func listener(_ listener:NSXPCListener,shouldAcceptNewConnection connection:NSXPCConnection)->Bool {
        guard #available(macOS 13.0,*), connection.effectiveUserIdentifier == geteuid() else { return false }
        // service() is not an anonymous/Mach listener: authenticate each peer
        // connection before resume, when no incoming request can run yet.
        connection.setCodeSigningRequirement(requirement)
        let worker=Worker()
        connection.exportedInterface=NSXPCInterface(with:AbakDocumentControlService.self)
        connection.exportedObject=worker
        connection.invalidationHandler={ worker.cancel() }
        connection.interruptionHandler={ worker.cancel() }
        connection.resume()
        return true
    }
}
guard #available(macOS 13.0,*),
      let requirement=Bundle.main.object(forInfoDictionaryKey:"ABAKHostRequirement") as? String else { exit(78) }
let delegate=Delegate(requirement: requirement)
let listener=NSXPCListener.service()
listener.delegate=delegate
listener.resume()
