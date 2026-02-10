@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEventManager")
struct ServerSentEventManagerTests {

    @Test("test connect does not throw")
    func connectDoesNotThrow() async throws {
        let request = SSERequest(url: "https://example.com/sse")
        let manager = createSSEManager(request: request)

        await #expect(throws: Never.self) {
            try await manager.connect()
        }
    }

    @Test("test connect while connecting throws")
    func connectWileConnectedThrows() async throws {
        let request = SSERequest(url: "https://example.com/sse")
        let manager = createSSEManager(request: request)

        try await manager.connect()

        await #expect(throws: SSEError.alreadyConnected) {
            try await manager.connect()
        }
    }
}

// MARK: Helpers

private func createSSEManager(
    request: SSERequest,
    urlSession: URLSessionProtocol = createMockURLSession()
) -> ServerSentEventManager {
    ServerSentEventManager(request: request, session: MockSession(urlSession: urlSession))
}

private func createMockURLSession(
    urlResponse: URLResponse = buildResponse(statusCode: 200),
    error: Error? = nil
) -> MockSSEURLSession {
    MockSSEURLSession(response: urlResponse, error: error)
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: ["Content-Type": "text/event-stream"]
    )!
}
