@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEventManager")
struct ServerSentEventManagerTests {
    private let sseRequest = SSERequest(url: "https://example.com/sse")

    // MARK: - .connect()

    @Test("test connect does not throw")
    func connectDoesNotThrow() async throws {
        let manager = createSSEManager(request: sseRequest)

        await #expect(throws: Never.self) {
            try await manager.connect()
        }
    }

    @Test("test connect throws when already connected")
    func connectThrowsWhenAlreadyConnected() async throws {
        let manager = createSSEManager(request: sseRequest)

        try await manager.connect()

        await #expect(throws: SSEError.alreadyConnected) {
            try await manager.connect()
        }
    }

    @Test("test connect throws when response is not 200")
    func connectThrowsWhenResponseIsNot200() async throws {
        let errorResponse = buildResponse(statusCode: 404)
        let mockSession = createMockURLSession(urlResponse: errorResponse)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)

        await #expect(throws: SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 404))) {
            try await manager.connect()
        }
    }

    @Test("test connect throws when urlSession has error")
    func testConnectThrowsWhenURLSessionHasError() async throws {
        let underlyingError = URLError(.notConnectedToInternet)
        let mockSession = createMockURLSession(error: underlyingError)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)

        await #expect(throws: SSEError.connectionFailed(underlying: URLError(.notConnectedToInternet))) {
            try await manager.connect()
        }
    }

    // MARK: - .disconnect()

    @Test("test disconnect throws if not connected")
    func disconnectThrowsIfNotConnected() async throws {
        let manager = createSSEManager(request: sseRequest)

        await #expect(throws: SSEError.notConnected) {
            try await manager.disconnect()
        }
    }

    @Test("test disconnect does throws if connected")
    func disconnectDoesNotThrowIfConnected() async throws {
        let manager = createSSEManager(request: sseRequest)
        try await manager.connect()

        await #expect(throws: Never.self) {
            try await manager.disconnect()
        }
    }

    @Test("test event id is saved and sent on next request after reconnect")
    func lastEventIDHeaderSentOnReconnection() async throws {
        let mockSession = createMockURLSession()
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)

        try await manager.connect()
        mockSession.simulateIncomingData("id: event-123\nevent: mock_event\ndata: Hello World\nretry: 100\n\n")

        try? await Task.sleep(for: .seconds(1))
        try await manager.disconnect()
        try? await Task.sleep(for: .seconds(1))
        try await manager.connect()

        let lastRequest = mockSession.capturedRequests.last
        #expect(lastRequest?.value(forHTTPHeaderField: "Last-Event-ID") == "event-123")
    }

    // MARK: - .stateEvents

    @Test("test streamed state events when connecting successfully")
    func streamedStateEventsWhenConnectingSuccessfully() async throws {
        let manager = createSSEManager(request: sseRequest)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(2) {
                states.append(state)
            }
        }

        try await manager.connect()
        await stateTask.value

        #expect(states.count == 2)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected
        ])
    }

    @Test("test streamed state events when connecting but respoinse is not 200")
    func streamedStateEventsWhenConnectingButResposneIsNot200() async throws {
        let errorResponse = buildResponse(statusCode: 404)
        let mockSession = createMockURLSession(urlResponse: errorResponse)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(2) {
                states.append(state)
            }
        }

        do {
            try await manager.connect()
            Issue.record("Expected .connect() to fail")
        } catch {
            // .connect() failed as expected
        }
        await stateTask.value

        #expect(states.count == 2)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.disconnected(.streamError(SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 404))))
        ])
    }

    @Test("test streamed state events when connecting but urlRespoinse has error")
    func streamedStateEventsWhenConnectingButURLResposneHasError() async throws {
        let underlyingError = URLError(.notConnectedToInternet)
        let mockSession = createMockURLSession(error: underlyingError)
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(2) {
                states.append(state)
            }
        }

        do {
            try await manager.connect()
            Issue.record("Expected .connect() to fail")
        } catch {
            // .connect() failed as expected
        }
        await stateTask.value

        #expect(states.count == 2)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.disconnected(.streamError(SSEError.connectionFailed(underlying: URLError(.notConnectedToInternet))))
        ])
    }

    @Test("test streamed state events when connecting then disconnecting")
    func streamedStateEventsWhenConnectingThenDisconnecting() async throws {
        let manager = createSSEManager(request: sseRequest)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(3) {
                states.append(state)
            }
        }

        try await manager.connect()
        try await manager.disconnect()
        await stateTask.value

        #expect(states.count == 3)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.manuallyDisconnected)
        ])
    }

    @Test("test streamed state events when connecting then terminated")
    func streamedStateEventsWhenConnectingThenTerminated() async throws {
        let manager = createSSEManager(request: sseRequest)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents {
                states.append(state)
            }
        }

        try await manager.connect()
        await manager.terminate()
        await stateTask.value

        #expect(states.count == 3)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.terminated)
        ])
    }

    @Test("test streamed state events when connecting then disconnecting then reconnecting")
    func streamedStateEventsWhenConnectingThenDisconnectingThenReconnecting() async throws {
        let manager = createSSEManager(request: sseRequest)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(5) {
                states.append(state)
            }
        }

        try await manager.connect()
        try await manager.disconnect()
        try await manager.connect()
        await stateTask.value

        #expect(states.count == 5)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.manuallyDisconnected),
            SSEConnectionState.connecting,
            SSEConnectionState.connected
        ])
    }

    @Test("test streamed state events cannot stream after .terminate() is called")
    func streamedStateEventsCannotStreamAfterTerminate() async throws {
        let manager = createSSEManager(request: sseRequest)
        var states: [SSEConnectionState] = []

        // Collect states in a background task
        let stateTask = Task {
            for await state in await manager.stateEvents {
                states.append(state)
            }
        }

        try await manager.connect()
        await manager.terminate()
        try await manager.connect()
        await stateTask.value

        #expect(states.count == 3)
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.terminated)
        ])
    }

    @Test("test streamed state vvents after stream finishes without error")
    func streamedStateEventsAfterStreamFinishesWithoutError() async throws {
        let mockSession = createMockURLSession()
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)
        var states: [SSEConnectionState] = []

        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(3) {
                states.append(state)
            }
        }

        try await manager.connect()
        mockSession.simulateStreamEnded(error: nil)

        await stateTask.value
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.streamEnded)
        ])
    }

    @Test("test streamed state vvents after stream finishes with error")
    func streamedStateEventsAfterStreamFinishesWithError() async throws {
        enum DummyError: Error {
            case error
        }
        let mockSession = createMockURLSession()
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)
        var states: [SSEConnectionState] = []

        let stateTask = Task {
            for await state in await manager.stateEvents.prefix(3) {
                states.append(state)
            }
        }

        try await manager.connect()
        mockSession.simulateStreamEnded(error: DummyError.error)

        await stateTask.value
        #expect(states == [
            SSEConnectionState.connecting,
            SSEConnectionState.connected,
            SSEConnectionState.disconnected(.streamError(DummyError.error))
        ])
    }

    // MARK: - Data & Parsing Tests

    @Test("test events stream after receiving single SSE message")
    func eventStreamsAfterReceivingSingleSSEMessage() async throws {
        let mockSession = createMockURLSession()
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)

        try await manager.connect()

        let eventTask = Task {
            var iterator = await manager.events.makeAsyncIterator()
            return await iterator.next()
        }

        mockSession.simulateIncomingData("id: 1\nevent: mock_event\ndata: Hello World\nretry: 100\n\n")

        let event = await eventTask.value
        #expect(event?.id == "1")
        #expect(event?.data == "Hello World")
        #expect(event?.event == "mock_event")
        #expect(event?.retry == 100)
    }

    @Test("test events stream ends after terminate")
    func eventStreamsEndsAfterTerminate() async throws {
        let mockSession = createMockURLSession()
        let manager = createSSEManager(request: sseRequest, urlSession: mockSession)

        try await manager.connect()

        var streamEnded = false
        let eventTask = Task {
            for await _ in await manager.events {
                // handle event
            }
            streamEnded = true
        }
        mockSession.simulateIncomingData("id: 1\nevent: mock_event\ndata: Hello World\nretry: 100\n\n")

        await manager.terminate()
        await eventTask.value

        #expect(streamEnded)
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
