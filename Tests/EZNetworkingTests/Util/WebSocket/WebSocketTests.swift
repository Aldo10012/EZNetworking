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

// MARK: .disconnect()

@Suite("Test WebSocketEngine.disconnect()")
final class WebSocketEngineTests_disconnect {
    
}

// MARK: .send()

@Suite("Test WebSocketEngine.send()")
final class WebSocketEngineTests_send {
    
}

// MARK: .messages()

@Suite("Test WebSocketEngine.messages()")
final class WebSocketEngineTests_messages {
    
}

// MARK: .stateChanges()

@Suite("Test WebSocketEngine.stateChanges()")
final class WebSocketEngineTests_stateChanges {
    
}

private enum DummyError: Error {
    case error
}
