@testable import EZNetworking
import Foundation
import Testing

// MARK: Test .connect()

@Suite("Test WebSocketEngine .connect()", .disabled())
final class WebSocketEngineTests_connect {
    
    @Test("test connection is established only after interceptor calls .onOpen")
    func test_connectionEstablished_onlyAfter_interceptorCallsOnOpen() async throws {
        let urlSession = MockWebSockerURLSession()
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        var didConnect = false
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                didConnect = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = await task.value
        #expect(didConnect == true)
    }
    
    @Test("test connection is not established only after interceptor calls .didCompleteWithError")
    func test_connectionNotEstablished_onlyAfter_interceptorCalls_didCompeteWithError() async throws {
        let urlSession = MockWebSockerURLSession()
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        var errorThrown: WebSocketError?
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                Issue.record("Expected connection to throw")
            } catch let wsError as WebSocketError {
                errorThrown = wsError
            }
        }
        
        wsInterceptor.simulateDidCompleteWithError(error: NSError(domain: "test", code: 0))
        _ = try await task.value
        
        #expect(errorThrown != nil )
        if case .connectionFailed(underlying: let underlying) = errorThrown {
            #expect(underlying as NSError == NSError(domain: "test", code: 0))
        } else {
            Issue.record("Expected to throw .unexpectedDisconnection")
        }
    }
    
    @Test("test connection is not established only after interceptor calls .didCloseWithCloseCode")
    func test_connectionNotEstablished_onlyAfter_interceptorCalls_didCloseWithCloseCoder() async throws {
        let urlSession = MockWebSockerURLSession()
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        var errorThrown: WebSocketError?
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                Issue.record("Expected connection to throw")
            } catch let wsError as WebSocketError{
                errorThrown = wsError
            }
        }
        
        wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: .goingAway, reason: nil)
        _ = try await task.value
        
        #expect(errorThrown != nil )
        if case .unexpectedDisconnection(code: let code, reason: let reason) = errorThrown {
            #expect(code == .goingAway)
            #expect(reason == nil)
        } else {
            Issue.record("Expected to throw .unexpectedDisconnection")
        }
    }
        
    @Test("test calling .connect() calls .didCallWebSocketTaskInspectable")
    func testCallingConnectcallsDidCallWebSocketTaskInterceptable() async throws {
        let urlSession = MockWebSockerURLSession()
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
            } catch {
                Issue.record(".connect() should not have thrown error")
            }
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = await task.value
        #expect(urlSession.didCallWebSocketTaskInspectable == true)
    }
    
    @Test("test calling .connect() a second time throws WebSocketError.alreadyConnected")
    func testCallingConnectTwiceThrowsAlreadyConnected() async throws {
        let urlSession = MockWebSockerURLSession()
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        var errorThrownOnSecondConnectAttempt: WebSocketError?
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                try await sut.connect(with: webSocketUrl, protocols: [])
                Issue.record("second time connecting should not have thrown")
            } catch let wsError as WebSocketError {
                errorThrownOnSecondConnectAttempt = wsError
            }
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = try await task.value
        #expect(errorThrownOnSecondConnectAttempt == WebSocketError.alreadyConnected)
    }
    
    @Test("test calling .connect() does call WebSocketTask.resume()")
    func testCallingConnectDoesCallWebSocketTaskResume() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = await task.value
        #expect(wsTask.didCallResume == true)
    }
    
}

// MARK: Test .disconnect()

@Suite("Test WebSocketEngine .disconnect()", .disabled())
final class WebSocketEngineTests_disconnect {
    
    @Test("test calling .disconnect() does call WebSocketTask.resume()")
    func testCallingDisconnectDoesCallWebSocketTaskResume() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        let task = Task {
            try await sut.connect(with: webSocketUrl, protocols: [])
            await sut.disconnect(with: .goingAway, reason: nil)
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = try await task.value
        
        #expect(wsTask.didCallCancel == true)
        #expect(wsTask.didCancelWithCloseCode == .goingAway)
        #expect(wsTask.didCancelWithReason == nil)
    }
    
}

// MARK: Test .send

@Suite("Test WebSocketEngine .send", .disabled())
final class WebSocketEngineTests_send {

    @Test("test string message successfully send after connection is made")
    func testSendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        var didSend = false
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                try await sut.send(.string("test send"))
                didSend = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = await task.value
        #expect(didSend == true)
    }
    
    @Test("test string message fails if send without connecting first")
    func testSendingMessageFailsIfSentWithoutConnectingFirst() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
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
        
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = await task.value
        #expect(capturedError == .notConnected)
    }
    
    @Test("test string message fails if send() throws error")
    func testSendingMessageFailsIfSendThrowsError() async throws {
        let wsTask = MockURLSessionWebSocketTask(sendThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)
        
        var capturedError: WebSocketError?
        let task = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                try await sut.send(.string("test send"))
                Issue.record("Should no tbe able to send without calling .connect() first")
            }  catch let wsError as WebSocketError {
                capturedError = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = await task.value
        #expect(capturedError == .sendFailed(underlying: NSError(domain: "MockURLSessionWebSocketTask.send error", code: 0)))
    }
}

// MARK: Test .connectionStateStream

@Suite("Test WebSocketEngine .connectionStateStream", .disabled())
final class WebSocketEngineTests_connectionStateStream {
    
    @Test("connectionStateStream yields expected states")
    func testConnectionStateStreamYieldsExpectedStates() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)

        var receivedConnectionState = [WebSocketConnectionState]()

        // Start listening to the stream concurrently
        let streamTask = Task {
            for await state in await sut.connectionStateStream {
                receivedConnectionState.append(state)
            }
        }

        let connectionTask = Task {
            try await sut.connect(with: webSocketUrl, protocols: [])
            await sut.disconnect(with: .goingAway, reason: nil)
        }
        
        wsInterceptor.simulateOpenWithProtocol("test")
        
        _ = await streamTask.value
        _ = try await connectionTask.value

        #expect(receivedConnectionState == [
            .connecting,
            .connected(protocol: "test"),
            .disconnected
        ])
    }
    
    @Test("connectionStateStream yields expected states when didCompleteWithError")
    func testConnectionStateStreamYieldsExpectedStatesWhenDidCompleteWithError() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)

        var receivedConnectionState = [WebSocketConnectionState]()

        // Start listening to the stream concurrently
        let streamTask = Task {
            for await state in await sut.connectionStateStream {
                receivedConnectionState.append(state)
            }
        }

        var errorThrown: WebSocketError?
        let connectionTask = Task {
            do {
                try await sut.connect(with: webSocketUrl, protocols: [])
                Issue.record("Expected to throw")
            } catch let wsError as WebSocketError {
                errorThrown = wsError
            }
        }
        
        let err = NSError(domain: "test", code: 0)
        wsInterceptor.simulateDidCompleteWithError(error: err)
        
        _ = await streamTask.value
        _ = try await connectionTask.value

        #expect(errorThrown == .connectionFailed(underlying: err))
        #expect(receivedConnectionState == [
            .connecting,
            .failed(error: .connectionFailed(underlying: err) )
        ])
    }
    
    @Test("connectionStateStream yields .connectionLost after ping failures")
    func testConnectionStateStreamYieldsConnectionLostAfterPingFailures() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        wsTask.shouldFailPing = true // Simulate ping always failing
        
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)

        var receivedConnectionState = [WebSocketConnectionState]()
        let streamTask = Task {
            for await state in await sut.connectionStateStream {
                receivedConnectionState.append(state)
                if case .connectionLost = state { break }
            }
        }

        let connectionTask = Task {
            try await sut.connect(with: webSocketUrl, protocols: [],
                                  pingPongIntervalSeconds: UInt64(0.01),
                                  pingPongMaximumConsecutiveFailures: 3)
        }
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = await streamTask.value
        _ = try await connectionTask.value

        
        #expect(receivedConnectionState == [
            .connecting,
            .connected(protocol: "test"),
            .connectionLost(reason: WebSocketError.keepAliveFailure(consecutiveFailures: 3))
        ])
    }

    @Test("connectionStateStream yields .disconnected after disconnect call")
    func testConnectionStateStreamYieldsDisconnectedAfterDisconnect() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: session)

        var receivedConnectionState = [WebSocketConnectionState]()
        let streamTask = Task {
            for await state in await sut.connectionStateStream {
                receivedConnectionState.append(state)
                if case .disconnected = state { break }
            }
        }

        let connectionTask = Task {
            try await sut.connect(with: webSocketUrl, protocols: [],
                                  pingPongIntervalSeconds: UInt64(0.01),
                                  pingPongMaximumConsecutiveFailures: 3)
            await sut.disconnect(with: .goingAway, reason: nil)
        }
        wsInterceptor.simulateOpenWithProtocol("test")
        _ = await streamTask.value
        _ = try await connectionTask.value

        #expect(receivedConnectionState == [
            .connecting,
            .connected(protocol: "test"),
            .disconnected
        ])        
    }
}
