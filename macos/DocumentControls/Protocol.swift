import Foundation

@objc(AbakDocumentControlService)
protocol AbakDocumentControlService {
    func run(_ request: Data, reply: @escaping (Data) -> Void)
}
