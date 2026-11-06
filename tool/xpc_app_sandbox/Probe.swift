import Foundation
import Darwin

func writeProbe(_ path: String) -> [String: Any] {
    let fd = open(path, O_CREAT | O_EXCL | O_WRONLY | O_NOFOLLOW, 0o600)
    let code = errno
    if fd >= 0 { close(fd); unlink(path) }
    return ["allowed": fd >= 0, "errno": fd >= 0 ? 0 : code]
}
func readProbe(_ path: String) -> [String: Any] {
    let fd = open(path, O_RDONLY | O_NOFOLLOW)
    let code = errno
    if fd >= 0 { close(fd) }
    return ["allowed": fd >= 0, "errno": fd >= 0 ? 0 : code]
}
func networkProbe() -> [String: Any] {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    if fd < 0 { return ["allowed": false, "errno": errno] }
    defer { close(fd) }
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = UInt16(9).bigEndian
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
    let result = withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    let code = errno
    return ["allowed": result == 0, "errno": result == 0 ? 0 : code,
            "policyDenied": result != 0 && (code == EPERM || code == EACCES)]
}
func probes(work: URL, outsideWork: URL, foreign: URL) -> [String: Any] {
    return ["callerRead": readProbe(foreign.appendingPathComponent("synthetic-input.txt").path),
            "privateWorkWrite": writeProbe(work.appendingPathComponent(UUID().uuidString).path),
            "outsideWorkWrite": writeProbe(outsideWork.appendingPathComponent(UUID().uuidString).path),
            "callerWrite": writeProbe(foreign.appendingPathComponent(UUID().uuidString).path),
            "network": networkProbe()]
}
