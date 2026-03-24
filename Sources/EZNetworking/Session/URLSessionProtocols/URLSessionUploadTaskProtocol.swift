import Foundation

public protocol URLSessionUploadTaskProtocol: AnyObject, Sendable {
    func resume()
    func cancel()

    @available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
    func cancelByProducingResumeData() async -> Data?
}

extension URLSessionUploadTask: URLSessionUploadTaskProtocol {}
