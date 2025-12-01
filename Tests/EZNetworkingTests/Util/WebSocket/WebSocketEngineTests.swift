@testable import EZNetworking
import Foundation
import Testing

// MARK: .connect()

@Suite("Test WebSocketEngine.connect()")
final class WebSocketEngineTests_connect {
    
    @Test("test calling .connect succeeds")
    func testCallingConnectDoesNotThrow() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var didConnect = false
        
        let task = Task {
            do {
                try await sut.connect()
                didConnect = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        
        try await Task.sleep(nanoseconds: 100)  // 0.000,000,1 second
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        #expect(didConnect)
    }
    
    @Test("test calling .connect throws error if WebSocketTaskInterceptor didCompleteWithError")
    func testCallingConnectThrowsErrorIfInterceptorDidCompleteWithError() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    
    // MARK: ping pong
    
    @Test("test calling .connect does call URLSessionWebSocketTask.sendPing()")
    func testCallingConnectDoesCallURLSessionWebSocketTaskSendPing() async throws {
        let pingConfig = PingConfig(pingInterval: UInt64(0.0000000001), maxPingFailures: 0)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    
    @Test("test calling .connect does call URLSessionWebSocketTask.sendPing() and fails after 3 attempts")
    func testCallingConnectDoesCallURLSessionWebSocketTaskSendPingAndFailsAfter3Atempts() async throws {
        let pingConfig = PingConfig(pingInterval: UInt64(0.0000000001), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
    
}

// MARK: .disconnect()

@Suite("Test WebSocketEngine.disconnect()")
final class WebSocketEngineTests_disconnect {
    
    @Test("test calling .disconnect() does call WebSocketTask.resume()")
    func testCallingDisconnectDoesCallWebSocketTaskResume() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var didDisconnect = false
        let task = Task {
            do {
                try await sut.connect()
                await sut.disconnect(closeCode: .goingAway, reason: nil)
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
}

// MARK: .send()

@Suite("Test WebSocketEngine.send()")
final class WebSocketEngineTests_send {
    
    @Test("test string message successfully send after connection is made")
    func testSendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(sendThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
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
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(receiveMessage: "mock message")
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
                
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
                for try await message in sut.messages().prefix(1) {
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
        
        try await Task.sleep(nanoseconds: 100)
        await receiveMessagesTask.value

        #expect(receivedMessages == ["mock message"])
    }
    
    @Test("test receiveing message failure")
    func testReceivingMessageFailure() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(receiveThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
                
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
        
        var err: WebSocketError?
        let receiveMessagesTask = Task {
            do {
                for try await _ in sut.messages().prefix(1) {
                    Issue.record("Expected message to fail")
                }
            } catch let wsError as WebSocketError {
                err = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }
        
        try await Task.sleep(nanoseconds: 100)
        await receiveMessagesTask.value

        #expect(err == WebSocketError.receiveFailed(underlying: MockURLSessionWebSocketTaskError.failedToReceiveMessage))
    }
    
}

// MARK: .stateChanges()

@Suite("Test WebSocketEngine.stateChanges()")
final class WebSocketEngineTests_stateChanges {
    
    @Test("stateChanges emits .connecting and .connected when connect succeeds")
    func testStateChangesEmitsConnectingAndConnectedWhenConnectSucceeds() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(receiveMessage: "mock message")
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test")
        ]
        
        // Start listening to the stream concurrently
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }
        
        let connectionTask = Task {
            try await sut.connect()
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = await stateTask.value
        _ = try await connectionTask.value

        #expect(receivedState == expectedStates)
    }
    
    @Test("stateChanges emits .connecting and .failed when connect fails")
    func testStateChangesEmitsConnectingAndFailedWhenConnectFails() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedStates = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .failed(error: .connectionFailed(underlying: DummyError.error))
        ]
        
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedStates.append(state)
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
        
        try await Task.sleep(nanoseconds: 100_000_000)
        wsInterceptor.simulateDidCompleteWithError(error: DummyError.error)
        
        await connectTask.value
        await stateTask.value
        
        #expect(receivedStates ==  expectedStates)
    }
    
    @Test("stateChanges emits .connecting and .failed when connection closes during handshake")
    func testStateChangesEmitsFailedWhenConnectionClosesEarly() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)

        
        var receivedStates = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .failed(error: .unexpectedDisconnection(code: .abnormalClosure, reason: "Server rejected"))
        ]
        
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedStates.append(state)
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
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        wsInterceptor.simulateDidCloseWithCloseCode(
            didCloseWith: .abnormalClosure,
            reason: "Server rejected".data(using: .utf8)
        )
        
        await connectTask.value
        await stateTask.value
        
        // Assert
        #expect(receivedStates == expectedStates)
        
    }
    
    @Test("stateChanges emits .connecting and .connected and .disconnected when connecting then disconnecting")
    func testStateChangesEmitsConnectingAndConnectedWhenConnectedThenDisconnected() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(receiveMessage: "mock message")
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected
        ]
        
        // Start listening to the stream concurrently
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }
        
        let connectionTask = Task {
            try await sut.connect()
            await sut.disconnect(closeCode: .goingAway, reason: nil)
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = try await connectionTask.value
        _ = await stateTask.value
        
        #expect(receivedState == expectedStates)
    }
    
    @Test("stateChanges emits states for multiple connect-disconnect cycles")
    func testStateChangesForMultipleConnectDisconnectCycles() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(receiveMessage: "mock message")
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            // first connect-disconnect cycle
            .connecting,
            .connected(protocol: "test-1"),
            .disconnected,
            // second connect-disconnect cycle
            .connecting,
            .connected(protocol: "test-2"),
            .disconnected
        ]
        
        // Start listening to the stream concurrently
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }
        
        let firstConnectTask = Task {
            try await sut.connect()
            await sut.disconnect(closeCode: .goingAway, reason: nil)
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test-1")
        
        _ = try await firstConnectTask.value
        
        // simulate reconnect
        
        let secondConnectTask = Task {
            try await sut.connect()
            await sut.disconnect(closeCode: .goingAway, reason: nil)
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test-2")
        
        _ = try await secondConnectTask.value
        
        _ = await stateTask.value
        #expect(receivedState == expectedStates)
    }
    
    @Test("stateChanges emits .connectinoLost state when ping fails")
    func testStateChangesEmitsConnectionLostWhenPingFails() async throws {
        let pingConfig = PingConfig(pingInterval: UInt64(0.0000000001), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .connectionLost(reason: .keepAliveFailure(consecutiveFailures: 3))
        ]
        
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }
        
        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        await connectTask.value
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        _ = await stateTask.value
        #expect(wsTask.pingFailureCount == 3)
        #expect(receivedState == expectedStates)
    }
    
    @Test("test stateChanges emits .connectionLost when message fails to receive message")
    func testStateChangesEmitsConnectionLostWhenMessagesFailsToReceiveMessage() async throws {
        let pingConfig = PingConfig(pingInterval: 1, maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(receiveThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, pingConfig: pingConfig, urlSession: urlSession, sessionDelegate: session)
        
        var receivedState = [WebSocketConnectionState]()
        let expectedStates: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .connectionLost(
                reason: WebSocketError.receiveFailed(
                    underlying: MockURLSessionWebSocketTaskError.failedToReceiveMessage
                )
            )
        ]
                
        // Start listening to the stream concurrently
        let stateTask = Task {
            for await state in sut.stateChanges.prefix(expectedStates.count) {
                receivedState.append(state)
            }
        }
        
        let connectionTask = Task {
            try await sut.connect()
        }
        
        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = try await connectionTask.value

        let receiveMessagesTask = Task {
            do {
                for try await _ in sut.messages().prefix(1) {
                    Issue.record("Expected message to fail")
                }
            } catch {
                // expected to throw error
            }
        }
        
        _ = await receiveMessagesTask.value
        _ = await stateTask.value
        
        #expect(receivedState == expectedStates)
    }
}

private enum DummyError: Error {
    case error
}
