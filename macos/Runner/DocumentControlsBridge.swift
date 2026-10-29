import Foundation
import FlutterMacOS
import Security

final class AbakDocumentControlsBridge {
    static let shared = AbakDocumentControlsBridge()
    static let service = "fr.abakphysio.documentcontrols"
    private var connections = [UUID:NSXPCConnection]()
    private func signingTeam() -> String? {
        var code: SecCode?, staticCode: SecStaticCode?, information: CFDictionary?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code,
              SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess, let staticCode,
              SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue:kSecCSSigningInformation), &information) == errSecSuccess else { return nil }
        return (information as? [String:Any])?[kSecCodeInfoTeamIdentifier as String] as? String
    }
    func register(with messenger:FlutterBinaryMessenger) {
        let channel=FlutterMethodChannel(name:"abak/document_controls",binaryMessenger:messenger)
        channel.setMethodCallHandler { call,result in
            guard call.method == "run" else { result(FlutterMethodNotImplemented); return }
            guard #available(macOS 13.0,*), let request=call.arguments as? [String:Any],
                  let team=self.signingTeam(),
                  team.range(of:"^[A-Z0-9]{10}$",options:.regularExpression) != nil else {
                result(FlutterError(code:"CONTROLS_UNAVAILABLE",message:"Service de contrôle signé indisponible (macOS 13 minimum).",details:nil)); return
            }
            do {
                let payload=try JSONSerialization.data(withJSONObject:request)
                guard payload.count < 65536 else { throw NSError(domain:"ABAK",code:1) }
                let connection=NSXPCConnection(serviceName:Self.service)
                connection.remoteObjectInterface=NSXPCInterface(with:AbakDocumentControlService.self)
                connection.setCodeSigningRequirement("anchor apple generic and identifier \"\(Self.service)\" and certificate leaf[subject.OU] = \"\(team)\"")
                let token=UUID()
                self.connections[token]=connection
                var finished=false
                func finish(_ value:Any?) {
                    DispatchQueue.main.async {
                        guard !finished else { return }; finished=true
                        self.connections.removeValue(forKey:token)
                        connection.invalidate()
                        result(value)
                    }
                }
                connection.interruptionHandler={ finish(FlutterError(code:"CONTROLS_INTERRUPTED",message:"Service de contrôle interrompu.",details:nil)) }
                connection.invalidationHandler={ finish(FlutterError(code:"CONTROLS_DISCONNECTED",message:"Service de contrôle déconnecté.",details:nil)) }
                connection.resume()
                guard let remote=connection.remoteObjectProxyWithErrorHandler({ error in
                    finish(FlutterError(code:"CONTROLS_LAUNCH",message:error.localizedDescription,details:nil))
                }) as? AbakDocumentControlService else {
                    finish(FlutterError(code:"CONTROLS_LAUNCH",message:"Service signé inaccessible.",details:nil));return
                }
                remote.run(payload) { data in
                    do {
                        guard data.count <= 64*1024*1024, let answer=try JSONSerialization.jsonObject(with:data) as? [String:Any] else { throw NSError(domain:"ABAK",code:2) }
                        finish(answer)
                    } catch { finish(FlutterError(code:"CONTROLS_RESPONSE",message:"Rapport du service illisible.",details:nil)) }
                }
                DispatchQueue.main.asyncAfter(deadline:.now()+300) {
                    finish(FlutterError(code:"CONTROLS_TIMEOUT",message:"Délai du contrôle dépassé.",details:nil))
                }
            } catch { result(FlutterError(code:"CONTROLS_REQUEST",message:"Demande de contrôle invalide.",details:nil)) }
        }
    }
}
