@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEventManager")
struct ServerSentEventManagerTests {

    @Test("test connect does not throw")
    func testConnectDoesNotThrow() async throws {
        let request = SSERequest(url: "https://example.com/sse")
        let manager = ServerSentEventManager(request: request)

        try await manager.connect()
        #expect(Bool(true))
    }

    @Test("Test connect throws when already connecting")
    func testConnectThrowsWhenAlreadyConnecting() async throws {
        let request = SSERequest(url: "https://example.com/sse")
        let manager = ServerSentEventManager(request: request)

        try await manager.connect()
        do {
            try await manager.connect()
            Issue.record("Expected to throw, but did not throw")
        } catch let err as SSEError {
            #expect(err == .alreadyConnected)
        } catch {
            Issue.record("Expected SSEError")
        }
    }
}
