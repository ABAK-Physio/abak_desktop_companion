import Foundation
@main struct Host {
    static func main() throws {
        guard CommandLine.arguments.count == 3,
              let identifier = Bundle.main.object(forInfoDictionaryKey: "ProbeService") as? String,
              let team = Bundle.main.object(forInfoDictionaryKey: "ProbeTeam") as? String else { exit(64) }
        let connection = NSXPCConnection(serviceName: identifier)
        connection.remoteObjectInterface = NSXPCInterface(with: AbakSandboxMigrationProbe.self)
        if #available(macOS 13.0, *) {
            connection.setCodeSigningRequirement("anchor apple generic and identifier \"" + identifier + "\" and certificate leaf[subject.OU] = \"" + team + "\"")
        } else { exit(78) }
        connection.interruptionHandler = { exit(71) }
        connection.invalidationHandler = { exit(72) }
        connection.resume()
        guard let remote = connection.remoteObjectProxyWithErrorHandler({ error in
            FileHandle.standardError.write(Data(error.localizedDescription.utf8)); exit(73)
        }) as? AbakSandboxMigrationProbe else { exit(74) }
        let request = try JSONSerialization.data(withJSONObject: ["syntheticRoot": CommandLine.arguments[1]])
        remote.inspect(request) { answer in
            do { try answer.write(to: URL(fileURLWithPath: CommandLine.arguments[2])); exit(0) }
            catch { exit(75) }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 30) { exit(76) }
        RunLoop.current.run()
    }
}
