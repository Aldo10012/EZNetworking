@testable import EZNetworking
import Foundation
import Testing

// MARK: .connect()

@Suite("Test WebSocketEngine.connect()")
final class WebSocketEngineTests_connect {
    
    @Test("test calling .connect succeeds")
    func testCallingConnectDoesNotThrow() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingConnectThrowsErrorIfInterceptorDidCompleteWithError() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingConnectThrowsErrorIfInterceptorDidCloseWithCode() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingConnectDoesCallWebSocketTaskInspectable() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingConnectDoesCallURLSessionWebSocketTaskResume() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingConnectDoesCallURLSessionWebSocketTaskSendPing() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 0)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingConnectFailsIfPingDoesNotReceivePongAfter3FailedAttempts() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCapturedErrorFromCallingConnectIfPingDoesNotReceivePong() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testCallingDisconnectDoesCallWebSocketTaskCancel() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        #expect(wsTask.didCancelWithCloseCode == .goingAway)
        #expect(wsTask.didCancelWithReason == nil)
    }
    
    @Test("test calling .disconnect() throws if did not call .connect() first")
    func testCallingDisconnectFailsIfNotConnected() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testSendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testSendingMessageFailsIfSentWithoutConnectingFirst() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testSendingMessageFailsIfSendThrowsError() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(sendThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    func testReceivingMessages() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
            do {
                for try await message in sut.messages.prefix(1) {
                    switch message {
                    case .string(let msg):
                        receivedMessages.append(msg)
                    default:
                        Issue.record("Expected string message")
                    }
                }
            } catch {
                Issue.record(".messages() unexpectedly threw error: \(error)")
            }
        }
        
        try await Task.sleep(for: .nanoseconds(100_000))
        
        wsTask.simulateReceiveMessage(.string("mock message"))
        
        await receiveMessagesTask.value
        
        #expect(receivedMessages == ["mock message"])
        try await sut.disconnect()
    }
    
    @Test("test receiveing multiple messagess")
    func testReceivingMultipleMessages() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
            do {
                for try await message in sut.messages.prefix(2) {
                    switch message {
                    case .string(let msg):
                        receivedMessages.append(msg)
                    default:
                        Issue.record("Expected string message")
                    }
                }
            } catch {
                Issue.record(".messages() unexpectedly threw error: \(error)")
            }
        }
        
        try await Task.sleep(for: .nanoseconds(100_000))
        wsTask.simulateReceiveMessage(.string("mock message 1"))
        
        try await Task.sleep(for: .nanoseconds(100_000))
        wsTask.simulateReceiveMessage(.string("mock message 2"))
        
        await receiveMessagesTask.value
        
        #expect(receivedMessages == ["mock message 1", "mock message 2"])
        try await sut.disconnect()
    }
    
    @Test("test receive message failure")
    func testReceiveMessageFailure() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        
        var messagesDidThrow = false
        let receiveMessagesTask = Task {
            do {
                for try await _ in sut.messages.prefix(1) {
                    Issue.record("Expected messages to throw")
                }
            } catch {
                messagesDidThrow = true
            }
        }
        
        try await Task.sleep(for: .nanoseconds(100_000))
        wsTask.simulateReceiveMessageError()
        await receiveMessagesTask.value
        
        #expect(messagesDidThrow)
    }
}

// MARK: .stateChanges()

@Suite("Test WebSocketEngine.stateChanges()")
final class WebSocketEngineTests_stateChanges {
    
    @Test("test stateEvents when connecting")
    func testStateEventsWhenConnecting() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test")
        ]
        
        let stateTask = Task {
            for await state in sut.stateEvents.prefix(expectedStates.count) {
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
        try await sut.disconnect() // just to finish streams
    }
    
    @Test("test stateEvents when connecting fails due to error")
    func testStateEventsWhenConnectingFailsDueToError() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .disconnected(.failedToConnect(
                error: WebSocketError.connectionFailed(underlying: DummyError.error)
            ))
        ]
        
        let stateTask = Task {
            for await state in sut.stateEvents.prefix(expectedStates.count) {
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
    func testStateEventsWhenConnectingThenLaterConnectionIsLost() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketError.unexpectedDisconnection(code: .internalServerError, reason: nil)
            ))
        ]
        
        let stateTask = Task {
            for await state in sut.stateEvents.prefix(expectedStates.count) {
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
    func testStateEventsWhenConnectingThenDisconnecting() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.manuallyDisconnected)
        ]
        
        let stateTask = Task {
            for await state in sut.stateEvents.prefix(expectedStates.count) {
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
    func testStateEventsWhenConnectingThenPingPongError() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketError.pingFailed(underlying: MockURLSessionWebSocketTaskError.pingError)
            ))
        ]
        
        let stateTask = Task {
            for await state in sut.stateEvents.prefix(expectedStates.count) {
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
    func testStateEventsWhenConnectingReceiveMessageFails() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected(.connectionLost(
                error: WebSocketError.receiveFailed(underlying: MockURLSessionWebSocketTaskError.failedToReceiveMessage)
            ))
        ]
        
        let stateTask = Task {
            for await state in sut.stateEvents.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }
        
        let connectionTask = Task {
            try await sut.connect()
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = try await connectionTask.value
        
        try await Task.sleep(nanoseconds: 1_000)
        wsTask.simulateReceiveMessageError()
        
        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }
}

private enum DummyError: Error {
    case error
}
