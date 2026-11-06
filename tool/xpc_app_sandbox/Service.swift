import Foundation
import Darwin

final class Probe: NSObject, AbakSandboxMigrationProbe {
    func inspect(_ request: Data, reply: @escaping (Data) -> Void) {
        do {
            guard let args = try JSONSerialization.jsonObject(with: request) as? [String: String],
                  Set(args.keys) == ["syntheticRoot"], let path = args["syntheticRoot"],
                  path.range(of: "^/private/tmp/abak-xpc-migration-[a-f0-9]{32}$", options: .regularExpression) != nil,
                  Bundle.main.bundleIdentifier?.hasPrefix("fr.abakphysio.sandboxprobe.") == true
            else { throw NSError(domain: "SyntheticOnly", code: 1) }
            let fm = FileManager.default
            let home = URL(fileURLWithPath: NSHomeDirectory())
            let base = home.appendingPathComponent("Library/Application Support/migration-" + UUID().uuidString)
            let work = base.appendingPathComponent("work")
            try fm.createDirectory(at: work, withIntermediateDirectories: true)
            defer { try? fm.removeItem(at: base) }
            let foreign = URL(fileURLWithPath: path).appendingPathComponent("caller")
            var answer: [String: Any] = ["service": probes(work: work, outsideWork: base, foreign: foreign),
                                        "container": home.path, "syntheticOnly": true]
            guard let child = Bundle.main.url(forResource: "SandboxChild", withExtension: nil) else {
                throw NSError(domain: "ChildMissing", code: 1)
            }
            let process = Process(), stdout = Pipe(), stderr = Pipe()
            process.executableURL = child
            process.arguments = [work.path, base.path, foreign.path]
            process.environment = ["PATH": "/usr/bin:/bin", "TMPDIR": work.path]
            process.standardOutput = stdout; process.standardError = stderr
            try process.run()
            let bytes = stdout.fileHandleForReading.readDataToEndOfFile()
            let errors = stderr.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            answer["childExit"] = process.terminationStatus
            answer["childError"] = String(decoding: errors, as: UTF8.self)
            if !bytes.isEmpty { answer["child"] = try JSONSerialization.jsonObject(with: bytes) }
            reply(try JSONSerialization.data(withJSONObject: answer))
        } catch {
            reply(try! JSONSerialization.data(withJSONObject: ["error": error.localizedDescription]))
        }
    }
}
final class Delegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        guard #available(macOS 13.0, *), connection.effectiveUserIdentifier == geteuid(),
              let requirement = Bundle.main.object(forInfoDictionaryKey: "ABAKHostRequirement") as? String else { return false }
        connection.setCodeSigningRequirement(requirement)
        connection.exportedInterface = NSXPCInterface(with: AbakSandboxMigrationProbe.self)
        connection.exportedObject = Probe()
        connection.resume(); return true
    }
}
@main struct Service {
    static func main() {
        let delegate = Delegate(), listener = NSXPCListener.service()
        listener.delegate = delegate; listener.resume(); RunLoop.current.run()
    }
}
