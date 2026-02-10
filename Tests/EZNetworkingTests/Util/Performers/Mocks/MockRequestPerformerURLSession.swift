import EZNetworking
import Foundation

class MockRequestPerformerURLSession: URLSessionProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var sessionDelegate: SessionDelegate?

    init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error {
            throw error
        }
        guard let data, let urlResponse else {
            fatalError("Could not configure return for MockRequestPerformURLSession.data(for:_)")
        }
        return (data, urlResponse)
    }
}

// MARK: unused methods

extension MockRequestPerformerURLSession {
    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol {
        fatalError("Should not be using in this mock")
    }

    func bytes(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (URLSession.AsyncBytes, URLResponse) {
        fatalError("Should not be using in this mock")
    }
}
