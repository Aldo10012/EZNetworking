@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.stateEvents()")
final class WebSocketStateEventsTests {
    var pingConfig: PingConfig!
    var wsTask: MockURLSessionWebSocketTask!
    var urlSession: MockWebSockerURLSession!
    var wsInterceptor: MockWebSocketTaskInterceptor!
    var delegate: SessionDelegate!
    var session: MockSession!

    // MARK: - setup

    init() {
        self.setup(pingConfig: PingConfig(pingInterval: .seconds(1), maxPingFailures: 1))
        self.setupSession(withTask: MockURLSessionWebSocketTask())
    }

    func setup(pingConfig: PingConfig) {
        self.pingConfig = pingConfig
    }

    func setupSession(withTask wsTask: MockURLSessionWebSocketTask) {
        self.wsTask = wsTask
        self.urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        self.wsInterceptor = MockWebSocketTaskInterceptor()
        self.delegate = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        self.session = MockSession(urlSession: urlSession, delegate: delegate)
    }

    func getSut() -> WebSocket {
        return WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: session)
    }

    // MARK: - teardown

    deinit {
        self.wsTask = nil
        self.urlSession = nil
        self.wsInterceptor = nil
        self.delegate = nil
        self.session = nil
    }

    // MARK: .stateEvents()

    @Test("test stateEvents when connecting")
    func stateEventsWhenConnecting() async throws {
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test")
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value
        _ = await stateTask.value

        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting fails due to error")
    func stateEventsWhenConnectingFailsDueToError() async throws {
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .disconnected(.failedToConnect(
                reason: WebSocketFailureReason.connectionFailed(underlying: DummyError.error)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectTask = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCompleteWithError(error: DummyError.error)

        do {
            try await connectTask.value
            Issue.record("Expected connection to fail")
        } catch {
            // Expected to fail
        }

        _ = await stateTask.value

        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting then later connection is lost")
    func stateEventsWhenConnectingThenLaterConnectionIsLost() async throws {
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                reason: WebSocketFailureReason.unexpectedDisconnection(code: .internalServerError, reason: nil)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: .internalServerError, reason: nil)

        _ = await stateTask.value

        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting then disconnect")
    func stateEventsWhenConnectingThenDisconnecting() async throws {
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.manuallyDisconnected)
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value
        try await sut.disconnect()

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting and ping-pong fails")
    func stateEventsWhenConnectingThenPingPongError() async throws {
        setup(pingConfig: PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3))
        setupSession(withTask: MockURLSessionWebSocketTask(pingThrowsError: true))
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                reason: WebSocketFailureReason.pingFailed(underlying: MockURLSessionWebSocketTaskError.pingError)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value

        try await Task.sleep(nanoseconds: 100)

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting and receive message fails")
    func stateEventsWhenConnectingReceiveMessageFails() async throws {
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                reason: WebSocketFailureReason.receiveFailed(underlying: MockURLSessionWebSocketTaskError.failedToReceiveMessage)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = try await connectionTask.value

        try await Task.sleep(nanoseconds: 1000)
        wsTask.simulateReceiveMessageError()

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents stream persists connecting then disconnect then reconnecting")
    func stateEventsStreamPersistsAfterConnectingDisconnectingAndReconnecting() async throws {
        let sut = getSut()

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "initial connect"),
            .disconnected(.manuallyDisconnected),
            .connecting,
            .connected(protocol: "reconnect")
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)
        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol("initial connect")
        _ = try await connectionTask.value

        try await sut.disconnect()

        let reconnectionTask = try createConnectTaskExpectingThrow(sut)
        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol("reconnect")
        _ = try await reconnectionTask.value

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents stream ends on WebSocket.terminate()")
    func stateEventsEndsOnWebSocketTerminate() async throws {
        let sut = getSut()

        var receivedStates = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.terminated)
        ]
        var stateEventStreamEnded = false
        let stateTask = Task {
            for await state in await sut.stateEvents {
                receivedStates.append(state)
            }
            stateEventStreamEnded = true
        }

        let connectionTask = try createConnectTaskExpectingThrow(sut)
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = try await connectionTask.value

        await sut.terminate()

        _ = await stateTask.result

        #expect(receivedStates == expectedStates)
        #expect(stateEventStreamEnded == true)
    }
}

// MARK: Helpers
extension WebSocketStateEventsTests {
    func createConnectTaskExpectingThrow(_ sut: WebSocket) throws -> Task<Void, Error> {
        Task {
            do {
                try await sut.connect()
            } catch {
                throw error
            }
        }
    }
}

private enum DummyError: Error {
    case error
}
