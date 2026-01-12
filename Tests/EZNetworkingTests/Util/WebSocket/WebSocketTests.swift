import Foundation
import Testing
@testable import EZNetworking

// MARK: .connect()

@Suite("Test WebSocketEngine.connect()")
final class WebSocketEngineTests_connect {
    @Test("test calling .connect succeeds")
    func callingConnectDoesNotThrow() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, urlSession: urlSession, sessionDelegate: session)

        var didConnect = false

        let task = Task {
            do {
                try await sut.connect()
                didConnect = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(didConnect)
    }

    @Test("test calling .connect throws error if WebSocketTaskInterceptor didCompleteWithError")
    func callingConnectThrowsErrorIfInterceptorDidCompleteWithError() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, urlSession: urlSession, sessionDelegate: session)

        var errorThrown: WebSocketError?

        let task = Task {
            do {
                try await sut.connect()
                Issue.record("Unexpected success")
            } catch let wsError as WebSocketError {
                errorThrown = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCompleteWithError(error: DummyError.error)
        await task.value

        #expect(errorThrown == WebSocketError.connectionFailed(underlying: DummyError.error))
    }

    @Test("test calling .connect throws error if WebSocketTaskInterceptor didClsoeWithCode")
    func callingConnectThrowsErrorIfInterceptorDidCloseWithCode() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, urlSession: urlSession, sessionDelegate: session)

        var errorThrown: WebSocketError?

        let task = Task {
            do {
                try await sut.connect()
                Issue.record("Unexpected success")
            } catch let wsError as WebSocketError {
                errorThrown = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: .internalServerError, reason: nil)
        await task.value

        #expect(errorThrown == WebSocketError.unexpectedDisconnection(code: .internalServerError, reason: nil))
    }

    @Test("test calling .connect does call .webSocketTaskInspectable()")
    func callingConnectDoesCallWebSocketTaskInspectable() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, urlSession: urlSession, sessionDelegate: session)

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(urlSession.didCallWebSocketTaskInspectable)
    }

    @Test("test calling .connect does call URLSessionWebSocketTask.resume()")
    func callingConnectDoesCallURLSessionWebSocketTaskResume() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, urlSession: urlSession, sessionDelegate: session)

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(wsTask.didCallResume)
    }
}

// MARK: .connect() + ping pong

@Suite("Test WebSocketEngine.connect()")
final class WebSocketEngineTests_connect_pingPong {
    @Test("test calling .connect does call URLSessionWebSocketTask.sendPing()")
    func callingConnectDoesCallURLSessionWebSocketTaskSendPing() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 0)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        try await Task.sleep(nanoseconds: 100)

        #expect(wsTask.didCallSendPing)
    }

    @Test("test calling .connect fails if ping does not receive pong after 3 failed attempts")
    func callingConnectFailsIfPingDoesNotReceivePongAfter3FailedAttempts() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(wsTask.pingFailureCount == 3)
    }

    @Test("test captured error from calling .connect if ping does not receive pong")
    func capturedErrorFromCallingConnectIfPingDoesNotReceivePong() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(wsTask.pingError as? MockURLSessionWebSocketTaskError == MockURLSessionWebSocketTaskError.pingError)
    }
}

// MARK: .disconnect()

@Suite("Test WebSocketEngine.disconnect()")
final class WebSocketEngineTests_disconnect {
    @Test("test calling .disconnect() does call WebSocketTask.cancel()")
    func callingDisconnectDoesCallWebSocketTaskCancel() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var didDisconnect = false
        let task = Task {
            do {
                try await sut.connect()
                try await sut.disconnect()
                didDisconnect = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(didDisconnect)
        #expect(wsTask.didCallCancel == true)
        #expect(wsTask.didCancelWithCloseCode == .normalClosure)
        #expect(wsTask.didCancelWithReason == nil)
    }

    @Test("test calling .disconnect() throws if did not call .connect() first")
    func callingDisconnectFailsIfNotConnected() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var disconnectDidThrow = false
        do {
            try await sut.disconnect()
            Issue.record("Unexpectedly disconnected without error")
        } catch {
            disconnectDidThrow = true
        }
        #expect(disconnectDidThrow)
    }
}

// MARK: .send()

@Suite("Test WebSocketEngine.send()")
final class WebSocketEngineTests_send {
    @Test("test string message successfully send after connection is made")
    func sendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var didSend = false

        let task = Task {
            do {
                try await sut.connect()
                try await sut.send(.string("test send"))
                didSend = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        #expect(didSend)
    }

    @Test("test string message fails if send without connecting first")
    func sendingMessageFailsIfSentWithoutConnectingFirst() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var capturedError: WebSocketError?
        let task = Task {
            do {
                try await sut.send(.string("test send"))
                Issue.record("Should no tbe able to send without calling .connect() first")
            } catch let wsError as WebSocketError {
                capturedError = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await task.value
        #expect(capturedError == .notConnected)
    }

    @Test("test string message fails if send() throws error")
    func sendingMessageFailsIfSendThrowsError() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(sendThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var capturedError: WebSocketError?
        let task = Task {
            do {
                try await sut.connect()
                try await sut.send(.string("test send"))
                Issue.record("Expected .send() to fail")
            } catch let wsError as WebSocketError {
                capturedError = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        #expect(capturedError == .sendFailed(underlying: MockURLSessionWebSocketTaskError.failedToSendMessage))
    }
}

// MARK: .messages()

@Suite("Test WebSocketEngine.messages()")
final class WebSocketEngineTests_messages {
    @Test("test receiveing messagess")
    func receivingMessages() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await connectTask.value

        var receivedMessages = [String]()
        let receiveMessagesTask = Task {
            for await message in await sut.messages.prefix(1) {
                switch message {
                case let .string(msg):
                    receivedMessages.append(msg)
                default:
                    Issue.record("Expected string message")
                }
            }
        }

        try await Task.sleep(nanoseconds: 100_000)

        wsTask.simulateReceiveMessage(.string("mock message"))

        await receiveMessagesTask.value

        #expect(receivedMessages == ["mock message"])
        try await sut.disconnect()
    }

    @Test("test receiveing multiple messagess")
    func receivingMultipleMessages() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await connectTask.value

        var receivedMessages = [String]()
        let receiveMessagesTask = Task {
            for await message in await sut.messages.prefix(2) {
                switch message {
                case let .string(msg):
                    receivedMessages.append(msg)
                default:
                    Issue.record("Expected string message")
                }
            }
        }

        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("mock message 1"))

        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("mock message 2"))

        await receiveMessagesTask.value

        #expect(receivedMessages == ["mock message 1", "mock message 2"])
    }

    @Test("test receive message failure")
    func receiveMessageFailure() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await connectTask.value

        var messageReceived = false
        Task {
            for await _ in await sut.messages {
                messageReceived = true
            }
        }

        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessageError()

        #expect(!messageReceived)
    }

    @Test("test messages stream persists after disconnect then reconnect")
    func messagesStreamPersistsAfterDisconnectThenReconnect() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        // connect
        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        try await Task.sleep(nanoseconds: 10000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await connectTask.value

        // listen to messages
        var messagesReceived = [String]()
        let receiveMessagesTask = Task {
            for await message in await sut.messages.prefix(2) {
                switch message {
                case let .string(msg):
                    messagesReceived.append(msg)
                default:
                    Issue.record("Expected string message")
                }
            }
        }

        // send first message
        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("message 1"))

        // disconnect
        try await sut.disconnect()

        // reconnect
        let reconnectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        try await Task.sleep(nanoseconds: 10000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await reconnectTask.value

        // send second message
        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("message 2"))

        await receiveMessagesTask.value
        #expect(messagesReceived == ["message 1", "message 2"])
    }

    @Test("test messages stream ends on WebSocket.terminate()")
    func messagessStreamEndsOnWebSocketTerminate() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        // connect
        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await connectTask.value

        // listen to messages
        var messagesStreamEnded = false

        let messageTask = Task {
            for await _ in await sut.messages {
                // no need to handle messages received for this test
            }
            messagesStreamEnded = true
        }

        try await Task.sleep(nanoseconds: 100_000)
        await sut.terminate()

        _ = await messageTask.value
        #expect(messagesStreamEnded)
    }
}

// MARK: .stateChanges()

@Suite("Test WebSocketEngine.stateChanges()")
final class WebSocketEngineTests_stateChanges {
    @Test("test stateEvents when connecting")
    func stateEventsWhenConnecting() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .disconnected(.failedToConnect(
                error: WebSocketError.connectionFailed(underlying: DummyError.error)
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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketError.unexpectedDisconnection(code: .internalServerError, reason: nil)
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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketError.pingFailed(underlying: MockURLSessionWebSocketTaskError.pingError)
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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketError.receiveFailed(underlying: MockURLSessionWebSocketTaskError.failedToReceiveMessage)
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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

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
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

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
