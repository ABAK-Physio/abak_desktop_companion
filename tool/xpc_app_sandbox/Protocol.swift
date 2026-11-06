import Foundation
@objc(AbakSandboxMigrationProbe)
protocol AbakSandboxMigrationProbe {
    func inspect(_ request: Data, reply: @escaping (Data) -> Void)
}
