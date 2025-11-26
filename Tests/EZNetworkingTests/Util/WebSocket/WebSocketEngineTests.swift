@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketEngine .connect()")
final class WebSocketEngineTests_connect {
    
    // MARK: Test .connect()

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
    
    // MARK: Test .disconnect()
    
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

    // MARK: Test .connectionStateStream
    
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
}

// MARK: - helpers

private let webSocketUrl = URL(string: "ws://127.0.0.1:8080/example")!

private class MockWebSocketTaskInterceptor: WebSocketTaskInterceptor {
    private let session = URLSession.shared
    private lazy var task: URLSessionWebSocketTask = {
        session.webSocketTask(with: webSocketUrl, protocols: [])
    }()
    
    var onEvent: ((WebSocketTaskEvent) -> Void)?

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        onEvent?(.didOpenWithProtocol(protocolStr: `protocol`))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: any Error) {
        onEvent?(.didOpenWithError(error: error))
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        onEvent?(.didClose(code: closeCode, reason: reason))
    }
    
    // simulate methods
    
    func simulateOpenWithProtocol(_ proto: String?) {
        urlSession(session, webSocketTask: task, didOpenWithProtocol: proto)
    }
    
    func simulateDidCompleteWithError(error: any Error) {
        urlSession(session, task: task, didCompleteWithError: error)
    }
    
    func simulateDidCloseWithCloseCode(didCloseWith: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        urlSession(session, webSocketTask: task, didCloseWith: didCloseWith, reason: reason)
    }
}
