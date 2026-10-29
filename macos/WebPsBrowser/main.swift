import Cocoa
import Security

// Wire contract also declared by the Runner client; keep its ObjC name stable.
@objc(AbakWebPsBrowserService) protocol AbakWebPsBrowserService {
  func run(_ request: Data, reply: @escaping (Data) -> Void)
}

final class Worker: NSObject, AbakWebPsBrowserService {
  let browser = WebPsBrowserController()
  func run(_ request: Data, reply: @escaping (Data) -> Void) {
    DispatchQueue.main.async {
      guard request.count <= 8192,
            let value = (try? JSONSerialization.jsonObject(with: request)) as? [String: Any],
            let method = value["method"] as? String,
            let args = value["args"] as? [String: Any],
            Set(value.keys) == ["method", "args"] else {
        reply(Data("{\"error\":\"Demande Web-PS invalide.\"}".utf8)); return
      }
      self.browser.handle(method, args) { answer in
        reply((try? JSONSerialization.data(withJSONObject: answer)) ?? Data())
      }
    }
  }
  func cancel() {
    DispatchQueue.main.async { self.browser.terminateOwnedBrowser() }
  }
}

final class Delegate: NSObject, NSXPCListenerDelegate {
  let requirement: String
  let worker = Worker()
  private let lock = NSLock()
  private var occupied = false
  init(_ requirement: String) { self.requirement = requirement }
  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
    guard #available(macOS 13.0, *), connection.effectiveUserIdentifier == geteuid() else { return false }
    lock.lock()
    defer { lock.unlock() }
    guard !occupied else { return false }
    occupied = true
    connection.setCodeSigningRequirement(requirement)
    connection.exportedInterface = NSXPCInterface(with: AbakWebPsBrowserService.self)
    connection.exportedObject = worker
    connection.interruptionHandler = { self.worker.cancel() }
    connection.invalidationHandler = {
      self.worker.cancel()
      self.lock.lock(); self.occupied = false; self.lock.unlock()
    }
    connection.resume()
    return true
  }
}

guard #available(macOS 13.0, *),
      let requirement = Bundle.main.object(forInfoDictionaryKey: "ABAKHostRequirement") as? String,
      let host = Bundle.main.object(forInfoDictionaryKey: "ABAKHostIdentifier") as? String,
      host.range(of: "^[A-Za-z0-9.-]+$", options: .regularExpression) != nil else { exit(78) }
let delegate = Delegate(requirement)
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
