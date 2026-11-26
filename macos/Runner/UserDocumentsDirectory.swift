import Foundation
import Darwin

/// Resolve a recommendation only. This grants no filesystem authorization.
/// Foundation home-directory APIs may resolve to the App Sandbox container.
enum UserDocumentsDirectory {
  static func resolve(accountHome: () throws -> String = accountHomeDirectory) throws -> URL {
    let home = try accountHome()
    guard home.hasPrefix("/"), home != "/", !home.contains("\0") else {
      throw NSError(domain: "AbakDirectoryAccess", code: 2)
    }
    return URL(fileURLWithPath: home, isDirectory: true)
        .appendingPathComponent("Documents", isDirectory: true)
  }

  private static func accountHomeDirectory() throws -> String {
    // Query the current UID, never HOME, a username literal or a container path.
    let suggested = sysconf(_SC_GETPW_R_SIZE_MAX)
    var size = suggested > 0 ? Int(suggested) : 16384
    while size <= 1048576 {
      var entry = passwd()
      var result: UnsafeMutablePointer<passwd>?
      var buffer = [CChar](repeating: 0, count: size)
      let status = getpwuid_r(getuid(), &entry, &buffer, buffer.count, &result)
      if status == ERANGE {
        size *= 2
        continue
      }
      guard status == 0, result != nil, let home = entry.pw_dir else {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(status == 0 ? ENOENT : status))
      }
      return String(cString: home)
    }
    throw NSError(domain: NSPOSIXErrorDomain, code: Int(ERANGE))
  }
}
