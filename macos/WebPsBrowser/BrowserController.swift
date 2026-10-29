import Cocoa

/// Owns only a fresh Firefox instance/profile launched by Companion.
/// Never automates the user's personal profile or reports TLS authentication.
final class WebPsBrowserController {
  typealias Reply = ([String: Any]) -> Void
  private var application: NSRunningApplication?
  private var opening = false
  private var cancellation = false
  private let files = FileManager.default
  private lazy var root = files.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    .appendingPathComponent(Bundle.main.object(forInfoDictionaryKey: "ABAKHostIdentifier") as! String, isDirectory: true)
    .appendingPathComponent("ABAK-WebPS-Firefox", isDirectory: true)
  private var marker: URL { root.appendingPathComponent("active-session") }
  private var profile: URL { root.appendingPathComponent("profile", isDirectory: true) }

  func handle(_ method: String, _ args: [String: Any], _ reply: @escaping Reply) {
    switch method {
    case "status": reply(status())
    case "close": close(reply)
    case "open": open(args, reply)
    default: error("Commande Web-PS inconnue.", reply)
    }
  }

  private func error(_ message: String, _ reply: Reply) {
    reply(["error": message])
  }

  private func status() -> [String: Any] {
    if let app = application, app.isTerminated {
      application = nil
      if !opening { try? cleanup() }
    }
    return ["active": opening || application != nil || files.fileExists(atPath: marker.path),
            "opening": opening]
  }

  private func cleanup() throws {
    if files.fileExists(atPath: profile.path) { try files.removeItem(at: profile) }
    if files.fileExists(atPath: marker.path) { try files.removeItem(at: marker) }
  }

  // Confirm the actual argv before claiming ownership of a Firefox instance.
  // A launch callback alone can otherwise report a personal-profile launch.
  static func hasDedicatedArguments(_ arguments: [String], profile: String, address: String) -> Bool {
    guard arguments.contains("--no-remote"),
          let p = arguments.firstIndex(of: "--profile"), p + 1 < arguments.count,
          let w = arguments.firstIndex(of: "--new-window"), w + 1 < arguments.count else { return false }
    return arguments[p + 1] == profile && arguments[w + 1] == address
  }

  private func launchArguments(_ pid: pid_t) -> [String]? {
    var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
    var size = 0
    guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 4, size < 1024 * 1024 else { return nil }
    var bytes = [UInt8](repeating: 0, count: size)
    let result = bytes.withUnsafeMutableBytes { sysctl(&mib, 3, $0.baseAddress, &size, nil, 0) }
    guard result == 0 else { return nil }
    let count = bytes.withUnsafeBytes { $0.loadUnaligned(as: Int32.self) }
    guard count > 0, count < 4096 else { return nil }
    var cursor = 4
    // Executable path, then NUL padding, then argc strings. Never read environment.
    while cursor < size && bytes[cursor] != 0 { cursor += 1 }
    while cursor < size && bytes[cursor] == 0 { cursor += 1 }
    var values = [String]()
    for _ in 0..<count {
      let start = cursor
      while cursor < size && bytes[cursor] != 0 { cursor += 1 }
      guard cursor < size else { return nil }
      values.append(String(decoding: bytes[start..<cursor], as: UTF8.self))
      cursor += 1
    }
    return values
  }

  private func open(_ args: [String: Any], _ reply: @escaping Reply) {
    guard status()["active"] as? Bool == false else {
      error("Fermez d’abord l’accès Web-PS précédent.", reply); return
    }
    guard args["browser"] as? String == "org.mozilla.firefox",
          args["confirmed"] as? Bool == true,
          let address = args["url"] as? String, let url = URL(string: address),
          url.scheme == "https", url.host == "wps-cps.dev1.dmp.gouv.fr",
          url.user == nil, url.password == nil, url.port == nil,
          url.query == nil, url.fragment == nil,
          (url.path == "/AccesDirect/TableauDeBord" ||
           url.path.range(of: "^/AccesDirect/DossierPatient/[12][0-9]{14}/1\\.2\\.250\\.1\\.213\\.1\\.4\\.10$", options: .regularExpression) != nil)
    else { error("Accès Web-PS DV1 ou navigateur non pris en charge.", reply); return }
    guard let browser = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "org.mozilla.firefox") else {
      error("Firefox n’est pas installé.", reply); return
    }
    guard NSRunningApplication.runningApplications(withBundleIdentifier: "org.mozilla.firefox").isEmpty else {
      error("Quittez Firefox avant cet essai. Companion ouvrira une instance réservée au DMP.", reply); return
    }
    guard files.fileExists(atPath: "/usr/local/lib/libcps3_pkcs11_osx.dylib") else {
      error("Installez la Cryptolib CPS pour Firefox avant cet essai.", reply); return
    }
    do {
      try files.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
      try cleanup()
      try files.createDirectory(at: profile, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
      // NSS external-module configuration, only in our disposable profile.
      try "library=/usr/local/lib/libcps3_pkcs11_osx.dylib\nname=ANS CPS\n\n".write(
        to: profile.appendingPathComponent("pkcs11.txt"), atomically: true, encoding: .utf8)
      try """
      user_pref("security.osclientcerts.autoload", false);
      user_pref("security.default_personal_cert", "Ask Every Time");
      user_pref("browser.shell.checkDefaultBrowser", false);
      user_pref("browser.startup.page", 0);
      user_pref("browser.sessionstore.resume_from_crash", false);
      user_pref("signon.rememberSignons", false);
      user_pref("browser.aboutwelcome.enabled", false);
      user_pref("browser.startup.homepage_override.mstone", "ignore");
      """.write(to: profile.appendingPathComponent("user.js"), atomically: true, encoding: .utf8)
      try Data("pending".utf8).write(to: marker, options: .atomic)
    } catch { self.error("Impossible de préparer la fenêtre Firefox du DMP.", reply); return }
    opening = true
    cancellation = false
    let config = NSWorkspace.OpenConfiguration()
    config.createsNewApplicationInstance = true
    config.arguments = ["--no-remote", "--profile", profile.path, "--new-window", address]
    NSWorkspace.shared.openApplication(at: browser, configuration: config) { app, failure in
      DispatchQueue.main.async {
        self.opening = false
        guard let app = app, failure == nil, app.bundleIdentifier == "org.mozilla.firefox" else {
          // Leave marker on an uncertain launch; never retry or assume no window exists.
          self.error("Ouverture Firefox non confirmée. Quittez Firefox puis fermez l’accès dans Companion.", reply)
          return
        }
        guard let arguments = self.launchArguments(app.processIdentifier),
              Self.hasDedicatedArguments(arguments, profile: self.profile.path, address: address) else {
          self.error("Firefox n’a pas confirmé le profil DMP et son adresse. Quittez Firefox puis fermez l’accès dans Companion.", reply)
          return
        }
        self.application = app
        if self.cancellation { _ = app.terminate() }
        reply(self.status())
      }
    }
  }

  private func close(_ reply: @escaping Reply) {
    cancellation = true
    waitForClose(reply, remaining: 100)
  }

  private func waitForClose(_ reply: @escaping Reply, remaining: Int) {
    if !opening {
      if let app = application, !app.isTerminated {
        _ = app.terminate()
      } else if application != nil || NSRunningApplication.runningApplications(withBundleIdentifier: "org.mozilla.firefox").isEmpty {
        application = nil
        do { try cleanup(); reply(["active": false, "opening": false]) }
        catch { self.error("Fermeture non confirmée : impossible de nettoyer le profil DMP.", reply) }
        return
      }
    }
    guard remaining > 0 else {
      error("Quittez la fenêtre Firefox du DMP puis cliquez à nouveau sur Fermer l’accès Web-PS.", reply); return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.waitForClose(reply, remaining: remaining - 1)
    }
  }

  func terminateOwnedBrowser() { cancellation = true; _ = application?.terminate() }
}
