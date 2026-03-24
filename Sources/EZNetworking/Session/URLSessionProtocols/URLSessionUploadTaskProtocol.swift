import Foundation

public protocol URLSessionUploadTaskProtocol: AnyObject, Sendable {
    func resume()
    func cancel()

    func cancelByProducingResumeData() async -> Data?
}

extension URLSessionUploadTask: URLSessionUploadTaskProtocol {}
