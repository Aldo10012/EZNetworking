import Foundation

public protocol URLSessionDownloadTaskProtocol: AnyObject, Sendable {
    func resume()
    func cancel()
    func cancelByProducingResumeData() async -> Data?
}

extension URLSessionDownloadTask: URLSessionDownloadTaskProtocol {}
