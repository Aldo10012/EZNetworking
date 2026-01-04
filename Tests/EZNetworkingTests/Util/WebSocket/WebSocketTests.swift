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
        do {
            try await sut.connect()
            didConnect = true
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
        #expect(didConnect)
    }
    
    @Test("test calling .connect does call .webSocketTaskInspectable()")
    func testCallingConnectDoesCallWebSocketTaskInspectable() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
        do {
            try await sut.connect()
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
                
        #expect(urlSession.didCallWebSocketTaskInspectable)
    }
    
    @Test("test calling .connect does call URLSessionWebSocketTask.resume()")
    func testCallingConnectDoesCallURLSessionWebSocketTaskResume() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
        do {
            try await sut.connect()
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
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
