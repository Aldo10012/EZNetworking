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

        try await performConnect(sut, simulating: .didOpenWithProtocol("test"))

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

        do {
            try await performConnect(sut, simulating: .didCompleteWithError(DummyError.error))
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

        try await performConnect(sut, simulating: .didOpenWithProtocol("test"))

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

        try await performConnect(sut, simulating: .didOpenWithProtocol("test"))
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

        try await performConnect(sut, simulating: .didOpenWithProtocol("test"))

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

        try await performConnect(sut, simulating: .didOpenWithProtocol("test"), sleepNanoseconds: 1000)

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

        try await performConnect(sut, simulating: .didOpenWithProtocol("initial connect"), sleepNanoseconds: 1000)

        try await sut.disconnect()

        try await performConnect(sut, simulating: .didOpenWithProtocol("reconnect"), sleepNanoseconds: 1000)

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

        try await performConnect(sut, simulating: .didOpenWithProtocol("test"))

        await sut.terminate()

        _ = await stateTask.result

        #expect(receivedStates == expectedStates)
        #expect(stateEventStreamEnded == true)
    }
}

// MARK: Helpers

/// The interceptor event to fire in order to unblock `WebSocket.connect()`, which
/// suspends inside `waitForConnection()` until the interceptor reports an outcome.
fileprivate enum ConnectSimulation {
    case didOpenWithProtocol(String?)
    case didCompleteWithError(any Error)
    case didCloseWithCloseCode(URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketStateEventsTests {
    /// Starts `sut.connect()`, waits for it to reach the suspension point inside
    /// `waitForConnection()`, fires the given interceptor event to unblock it, then
    /// awaits the result. Throws whatever `connect()` throws.
    fileprivate func performConnect(
        _ sut: WebSocket,
        simulating simulation: ConnectSimulation,
        sleepNanoseconds: UInt64 = 100
    ) async throws {
        let task = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: sleepNanoseconds)
        switch simulation {
        case .didOpenWithProtocol(let proto):
            wsInterceptor.simulateOpenWithProtocol(proto)
        case .didCompleteWithError(let error):
            wsInterceptor.simulateDidCompleteWithError(error: error)
        case .didCloseWithCloseCode(let code, let reason):
            wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: code, reason: reason)
        }

        try await task.value
    }

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
