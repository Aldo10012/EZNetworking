import Foundation

public protocol URLSessionUploadTaskProtocol: AnyObject, Sendable {
    func resume()
    func cancel()

    @available(iOS 17.0, macOS 14.0, *)
    func cancelByProducingResumeData() async -> Data?
}

extension URLSessionUploadTask: URLSessionUploadTaskProtocol {}
