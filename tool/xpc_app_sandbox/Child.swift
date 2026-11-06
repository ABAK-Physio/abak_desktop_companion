import Foundation
@main struct Child {
    static func main() throws {
        guard CommandLine.arguments.count == 4 else { exit(64) }
        let paths = CommandLine.arguments.dropFirst().map { URL(fileURLWithPath: $0) }
        let answer = probes(work: paths[0], outsideWork: paths[1], foreign: paths[2])
        FileHandle.standardOutput.write(try JSONSerialization.data(withJSONObject: answer))
    }
}
