import EZNetworking
import Foundation

class MockSSEURLSession: URLSessionProtocol {
    var response: URLResponse
    var error: Error?

    var continuation: AsyncThrowingStream<UInt8, Error>.Continuation?
    var capturedRequests: [URLRequest] = []
    var numberOfRequestsMade = 0

    init(response: URLResponse = HTTPURLResponse(), error: Error? = nil) {
        self.response = response
        self.error = error
    }

    func bytes(for request: URLRequest) async throws -> (AsyncThrowingStream<UInt8, Error>, URLResponse) {
        numberOfRequestsMade += 1
        capturedRequests.append(request)

        if let error { throw error }

        let stream = AsyncThrowingStream<UInt8, Error> { continuation in
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

    func simulateStreamEnded(error: Error?) {
        if let error {
            continuation?.finish(throwing: error)
        } else {
            continuation?.finish()
        }
    }
}

// MARK: unused methods

extension MockSSEURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
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

    func downloadTaskInspectable(with url: URL) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }

    func downloadTaskInspectable(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }
}
