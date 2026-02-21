import Foundation

public protocol URLSessionDownloadTaskProtocol: Sendable {
    func resume()
    func cancel()
    func cancelByProducingResumeData() async -> Data?
}

extension URLSessionDownloadTask: URLSessionDownloadTaskProtocol {
    public func cancelByProducingResumeData() async -> Data? {
        await withCheckedContinuation { continuation in
            cancel(byProducingResumeData: { data in
                continuation.resume(returning: data)
            })
        }
    }
}
