import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)

    func download(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse)

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse)

    func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol

    func bytes(for request: URLRequest) async throws -> (AsyncThrowingStream<UInt8, Error>, URLResponse)

    func downloadTask(with url: URL) -> URLSessionDownloadTaskProtocol
    func downloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol
}

extension URLSession: URLSessionProtocol {
    public func downloadTask(with url: URL) -> URLSessionDownloadTaskProtocol {
        let task: URLSessionDownloadTask = downloadTask(with: url)
        return task as URLSessionDownloadTaskProtocol
    }

    public func downloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        let task: URLSessionDownloadTask = downloadTask(withResumeData: resumeData)
        return task as URLSessionDownloadTaskProtocol
    }

    public func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol {
        let task: URLSessionWebSocketTask = webSocketTask(with: request)
        return task as URLSessionWebSocketTaskProtocol
    }

    /// Wraps the native `URLSession.AsyncBytes` into an `AsyncThrowingStream<UInt8, Error>`.
    ///
    /// ### Why this wrapper exists:
    /// 1. **Testability**: `URLSession.AsyncBytes` has no public initializer. Returning `AsyncStream`
    ///    allows us to inject mock data in unit tests.
    /// 2. **Decoupling**: Abstracts the transport layer, allowing `ServerSentEventManager`
    ///    to remain agnostic of the underlying networking stack.
    /// 3. **Control**: Provides a `Continuation` to simulate fragmented packets or
    ///    disconnections.
    ///
    /// - Note: Cancelling the stream propagates cancellation to the underlying `URLSessionTask`.
    public func bytes(for request: URLRequest) async throws -> (AsyncThrowingStream<UInt8, Error>, URLResponse) {
        let (bytes, response) = try await self.bytes(for: request, delegate: nil)

        let stream = AsyncThrowingStream<UInt8, Error> { continuation in
            let task = Task {
                do {
                    for try await byte in bytes {
                        guard !Task.isCancelled else { return }
                        continuation.yield(byte)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            // Ensure the task is cancelled if the stream is cancelled
            continuation.onTermination = { _ in task.cancel() }
        }

        return (stream, response)
    }
}
