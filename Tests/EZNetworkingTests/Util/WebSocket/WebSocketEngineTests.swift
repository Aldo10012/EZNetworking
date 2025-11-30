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
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        
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
    
}

// MARK: .stateChanges()

@Suite("Test WebSocketEngine.stateChanges()")
final class WebSocketEngineTests_stateChanges {
    
}

private enum DummyError: Error {
    case error
}
