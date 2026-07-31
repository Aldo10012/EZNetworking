@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEventManager with RetryPolicy")
struct ServerSentEventManagerWithRetryPolicyTests {
    private let sseRequest = SSERequest(url: "https://example.com/sse")

    @Test("test .connect() attempts connect only once if retryPolicy is .none")
    func connectsOnlyOnceIfretryPolicyIsNone() async throws {
        let underlyingError = URLError(.notConnectedToInternet)
        let mockSession = createMockURLSession(error: underlyingError)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession, retryPolicy: .none)

        try? await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 1)
    }

    @Test("test .connect() attempts connect only once if retryPolicy.enabled is false")
    func connectsOnlyOnceIfretryPolicyEnabledIsFalse() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: false, clock: clock)
        let underlyingError = URLError(.notConnectedToInternet)
        let mockSession = createMockURLSession(error: underlyingError)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession, retryPolicy: retryPolicy)

        try? await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 1)
        #expect(clock.sleptDurations.isEmpty)
    }

    @Test("test .connect() attempts connect 3 times if retryPolicy.maxAttempts is 3")
    func connectsThreeTimesIfretryPolicyMaxAttemptsIs3() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 3, clock: clock)
        let underlyingError = URLError(.notConnectedToInternet)
        let mockSession = createMockURLSession(error: underlyingError)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession, retryPolicy: retryPolicy)

        try? await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 3)
        // Exponential backoff before attempts 2 and 3: 1.0 * 2^0 = 1.0s, then 1.0 * 2^1 = 2.0s
        #expect(clock.sleptDurations == [.seconds(1.0), .seconds(2.0)])
    }

    @Test("test .connect() with no error attempts connect 1 time even with retryPolicy set")
    func connectsOnlyOnceIfNoErrorEvenWithretryPolicySetUp() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 3, clock: clock)
        let mockSession = createMockURLSession()
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession, retryPolicy: retryPolicy)

        try? await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 1)
        #expect(clock.sleptDurations.isEmpty)
    }

    @Test("test manual disconnect prevents automatic reconnection")
    func manualDisconnectPreventsAutomaticReconnection() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 5, clock: clock)
        let mockSession = createMockURLSession()
        let manager = createSSEManager(
            request: sseRequest,
            urlSession: mockSession,
            retryPolicy: retryPolicy
        )
        try await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 1)

        try await manager.disconnect()
        try? await Task.sleep(for: .seconds(0.5))

        #expect(mockSession.numberOfRequestsMade == 1)
        #expect(clock.sleptDurations.isEmpty)
    }

    @Test("test terminate prevents automatic reconnection")
    func terminatePreventsAutomaticReconnection() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 5, clock: clock)
        let mockSession = createMockURLSession()
        let manager = createSSEManager(
            request: sseRequest,
            urlSession: mockSession,
            retryPolicy: retryPolicy
        )
        try await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 1)

        await manager.terminate()
        try? await Task.sleep(for: .seconds(0.5))

        #expect(mockSession.numberOfRequestsMade == 1)
        #expect(clock.sleptDurations.isEmpty)
    }

    @Test("test maxAttempts zero means no retries")
    func maxAttemptsZeroMeansNoRetries() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(
            enabled: true,
            maxAttempts: 0,
            clock: clock
        )
        let underlyingError = URLError(.notConnectedToInternet)
        let mockSession = createMockURLSession(error: underlyingError)
        let manager = createSSEManager(
            request: sseRequest,
            urlSession: mockSession,
            retryPolicy: retryPolicy
        )
        try? await manager.connect()
        #expect(mockSession.numberOfRequestsMade == 0)
        #expect(clock.sleptDurations.isEmpty)
    }

    @Test("test reconnect attempt when stream ends without error")
    func reconnectAttemptWhenStreamEndsWithoutError() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 1, clock: clock)
        let mockSession = createMockURLSession()
        let manager = createSSEManager(
            request: sseRequest,
            urlSession: mockSession,
            retryPolicy: retryPolicy
        )

        var states: [SSEConnectionState] = []
        Task {
            for await state in await manager.stateEvents.prefix(5) {
                states.append(state)
            }
        }

        try await manager.connect()
        try? await Task.sleep(for: .milliseconds(500))

        #expect(mockSession.numberOfRequestsMade == 1)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected
        ])
        mockSession.simulateIncomingData("id: event-123\nevent: mock_event\ndata: Hello World\nretry: 100\n\n")
        try? await Task.sleep(for: .milliseconds(100))
        mockSession.simulateStreamEnded(error: nil)
        try? await Task.sleep(for: .milliseconds(500))

        #expect(mockSession.numberOfRequestsMade == 2)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.streamEnded),
            SSEConnectionState.connecting,
            SSEConnectionState.connected
        ])
        #expect(mockSession.capturedRequests.last?.value(forHTTPHeaderField: "Last-Event-ID") == "event-123")
        // The reconnect succeeds on its first attempt, so retryPolicy's backoff delay never gets used.
        #expect(clock.sleptDurations.isEmpty)
    }

    @Test("test ServerSentEventManager reconnects when stream ends with error")
    func reconnectAttemptWhenStreamEndsWithError() async throws {
        let clock = MockClock()
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 1, clock: clock)
        let mockSession = createMockURLSession()
        let manager = createSSEManager(
            request: sseRequest,
            urlSession: mockSession,
            retryPolicy: retryPolicy
        )
        var states: [SSEConnectionState] = []
        Task {
            for await state in await manager.stateEvents.prefix(5) {
                states.append(state)
            }
        }
        try await manager.connect()
        try? await Task.sleep(for: .milliseconds(500))

        #expect(mockSession.numberOfRequestsMade == 1)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected
        ])
        mockSession.simulateIncomingData("id: event-123\nevent: mock_event\ndata: Hello World\nretry: 100\n\n")
        try? await Task.sleep(for: .milliseconds(100))
        mockSession.simulateStreamEnded(error: URLError(.notConnectedToInternet))
        try? await Task.sleep(for: .milliseconds(500))

        #expect(mockSession.numberOfRequestsMade == 2)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.streamError(URLError(.notConnectedToInternet))),
            SSEConnectionState.connecting,
            SSEConnectionState.connected
        ])
        #expect(mockSession.capturedRequests.last?.value(forHTTPHeaderField: "Last-Event-ID") == "event-123")
        // The reconnect succeeds on its first attempt, so retryPolicy's backoff delay never gets used.
        #expect(clock.sleptDurations.isEmpty)
    }
}

// MARK: Helpers

private func createSSEManager(
    request: SSERequest,
    urlSession: URLSessionProtocol = createMockURLSession(),
    retryPolicy: RetryPolicy = .none
) -> ServerSentEventManager {
    ServerSentEventManager(request: request, session: MockSession(urlSession: urlSession), retryPolicy: retryPolicy)
}

private func createMockURLSession(
    urlResponse: URLResponse = buildResponse(statusCode: 200),
    error: Error? = nil
) -> MockSSEURLSession {
    MockSSEURLSession(response: urlResponse, error: error)
}

private func buildResponse(
    statusCode: Int,
    headerFields: [String: String] = ["Content-Type": "text/event-stream"]
) -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: headerFields
    )!
}
