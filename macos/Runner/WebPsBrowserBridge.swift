import Cocoa
import FlutterMacOS
import Security

// Wire contract also declared in WebPsBrowser/main.swift.
@objc(AbakWebPsBrowserService) protocol AbakWebPsBrowserService {
  func run(_ request: Data, reply: @escaping (Data) -> Void)
}

/// The signed XPC service owns Firefox: sandboxed Runner cannot pass launch argv.
final class WebPsBrowserBridge {
  static let shared = WebPsBrowserBridge()
  private static let service = "fr.abakphysio.webpsbrowser"
  private var channel: FlutterMethodChannel?
  private var connection: NSXPCConnection?
  private var pending = [UUID: FlutterResult]()

  private func signingTeam() -> String? {
    var code: SecCode?, staticCode: SecStaticCode?, information: CFDictionary?
    guard SecCodeCopySelf([], &code) == errSecSuccess, let code,
          SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess, let staticCode,
          SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &information) == errSecSuccess else { return nil }
    return (information as? [String: Any])?[kSecCodeInfoTeamIdentifier as String] as? String
  }

  func register(_ messenger: FlutterBinaryMessenger) {
    let c = FlutterMethodChannel(name: "abak/webps_browser", binaryMessenger: messenger)
    channel = c
    c.setMethodCallHandler { [weak self] call, reply in
      guard let self else { return }
      guard ["status", "open", "close"].contains(call.method) else {
        reply(FlutterMethodNotImplemented); return
      }
      self.send(call.method, call.arguments as? [String: Any] ?? [:], reply)
    }
  }

  private func failure(_ message: String) -> FlutterError {
    FlutterError(code: "WEBPS_BROWSER", message: message, details: nil)
  }

  private func connected() -> NSXPCConnection? {
    if let connection { return connection }
    guard #available(macOS 13.0, *), let team = signingTeam(),
          team.range(of: "^[A-Z0-9]{10}$", options: .regularExpression) != nil else { return nil }
    let c = NSXPCConnection(serviceName: Self.service)
    c.remoteObjectInterface = NSXPCInterface(with: AbakWebPsBrowserService.self)
    c.setCodeSigningRequirement("anchor apple generic and identifier \"\(Self.service)\" and certificate leaf[subject.OU] = \"\(team)\"")
    let disconnected = { [weak self, weak c] in
      DispatchQueue.main.async {
        guard let self, let c, self.connection === c else { return }
        self.connection = nil
        c.invalidate()
        let callbacks = Array(self.pending.values)
        self.pending.removeAll()
        for callback in callbacks {
          callback(self.failure("Service Firefox interrompu. Quittez Firefox puis fermez l’accès Web-PS dans Companion."))
        }
      }
    }
    c.interruptionHandler = disconnected
    c.invalidationHandler = disconnected
    connection = c
    c.resume()
    return c
  }

  private func send(_ method: String, _ args: [String: Any], _ reply: @escaping FlutterResult) {
    guard let c = connected(),
          let data = try? JSONSerialization.data(withJSONObject: ["method": method, "args": args]),
          data.count <= 8192 else {
      reply(failure("Service Firefox signé indisponible. Recompilez Companion avec son service Web-PS.")); return
    }
    let token = UUID()
    pending[token] = reply
    func finish(_ value: Any?) {
      DispatchQueue.main.async { self.pending.removeValue(forKey: token)?(value) }
    }
    guard let remote = c.remoteObjectProxyWithErrorHandler({ _ in
      finish(self.failure("Service Firefox inaccessible. Quittez Firefox puis fermez l’accès Web-PS."))
    }) as? AbakWebPsBrowserService else {
      finish(failure("Service Firefox inaccessible.")); return
    }
    remote.run(data) { response in
      guard response.count <= 8192,
            let answer = (try? JSONSerialization.jsonObject(with: response)) as? [String: Any] else {
        finish(self.failure("Réponse du service Firefox illisible.")); return
      }
      if let message = answer["error"] as? String { finish(self.failure(message)) }
      else { finish(answer) }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
      guard self.pending[token] != nil else { return }
      finish(self.failure("Ouverture ou fermeture Firefox non confirmée. Quittez Firefox puis fermez l’accès Web-PS."))
      c.invalidate()
    }
  }

  func terminateOwnedBrowser() {
    // Invalidation asks the service to terminate only the instance it owns.
    connection?.invalidate()
  }
}
