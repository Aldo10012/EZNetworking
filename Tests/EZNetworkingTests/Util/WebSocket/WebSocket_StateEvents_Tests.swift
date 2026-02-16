@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.stateEvents()")
final class WebSocketStateEventsTests {
    @Test("test stateEvents when connecting")
    func stateEventsWhenConnecting() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

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

        let connectionTask = Task {
            try await sut.connect()
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value
        _ = await stateTask.value

        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting fails due to error")
    func stateEventsWhenConnectingFailsDueToError() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .disconnected(.failedToConnect(
                error: WebSocketFailureReason.connectionFailed(underlying: DummyError.error)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectTask = Task {
            do {
                try await sut.connect()
                Issue.record("Expected connection to fail")
            } catch {
                // Expected to fail
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCompleteWithError(error: DummyError.error)

        _ = await connectTask.value
        _ = await stateTask.value

        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting then later connection is lost")
    func stateEventsWhenConnectingThenLaterConnectionIsLost() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketFailureReason.unexpectedDisconnection(code: .internalServerError, reason: nil)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = Task {
            try await sut.connect()
        }

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
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

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

        let connectionTask = Task {
            try await sut.connect()
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value
        try await sut.disconnect()

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting and ping-pong fails")
    func stateEventsWhenConnectingThenPingPongError() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketFailureReason.pingFailed(underlying: MockURLSessionWebSocketTaskError.pingError)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = Task {
            try await sut.connect()
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")

        _ = try await connectionTask.value

        try await Task.sleep(nanoseconds: 100)

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents when connecting and receive message fails")
    func stateEventsWhenConnectingReceiveMessageFails() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketFailureReason.receiveFailed(underlying: MockURLSessionWebSocketTaskError.failedToReceiveMessage)
            ))
        ]

        let stateTask = Task {
            for await state in await sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }

        let connectionTask = Task {
            try await sut.connect()
        }

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
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

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

        let connectionTask = Task {
            try await sut.connect()
        }
        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol("initial connect")
        _ = try await connectionTask.value

        try await sut.disconnect()

        let reconnectionTask = Task {
            try await sut.connect()
        }
        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol("reconnect")
        _ = try await reconnectionTask.value

        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }

    @Test("test stateEvents stream ends on WebSocket.terminate()")
    func stateEventsEndsOnWebSocketTerminate() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

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

        let connectionTask = Task {
            try await sut.connect()
        }
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = try await connectionTask.value

        await sut.terminate()

        _ = await stateTask.result

        #expect(receivedStates == expectedStates)
        #expect(stateEventStreamEnded == true)
    }
}

private enum DummyError: Error {
    case error
}
