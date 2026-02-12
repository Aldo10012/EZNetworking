import EZNetworking
import Foundation

class MockSSEURLSession: URLSessionProtocol {
    var response: URLResponse
    var error: Error?

    var continuation: AsyncStream<UInt8>.Continuation?

    init(response: URLResponse = HTTPURLResponse(), error: Error? = nil) {
        self.response = response
        self.error = error
    }

    func bytes(for request: URLRequest) async throws -> (AsyncStream<UInt8>, URLResponse) {
        if let error { throw error }

        let stream = AsyncStream<UInt8> { continuation in
            self.continuation = continuation
        }

        return (stream, response)
    }

    // Call this in your Unit Test to simulate the server sending bytes
    func simulateIncomingData(_ string: String) {
        for byte in string.utf8 {
            continuation?.yield(byte)
        }
    }
}

// MARK: unused methods

extension MockSSEURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func webSocketTaskInspectable(with request: URLRequest) -> any URLSessionWebSocketTaskProtocol {
        fatalError("Should not be using in this mock")
    }
}
