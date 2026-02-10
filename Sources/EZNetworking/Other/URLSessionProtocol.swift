import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)

    func download(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse)

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse)

    func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol

    func bytes(for request: URLRequest) async throws -> (AsyncStream<UInt8>, URLResponse)
}

extension URLSession: URLSessionProtocol {
    public func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol {
        let task: URLSessionWebSocketTask = webSocketTask(with: request)
        return task as URLSessionWebSocketTaskProtocol
    }

    public func bytes(for request: URLRequest) async throws -> (AsyncStream<UInt8>, URLResponse) {
        let (bytes, response) = try await self.bytes(for: request, delegate: nil)

        let stream = AsyncStream<UInt8> { continuation in
            let task = Task {
                do {
                    for try await byte in bytes {
                        continuation.yield(byte)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
            // Ensure the task is cancelled if the stream is cancelled
            continuation.onTermination = { _ in task.cancel() }
        }

        return (stream, response)
    }
}
