@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketEngine.connect()")
final class WebSocketEngineTests_connect {
    
    @Test("test calling .connect does call .webSocketTaskInspectable()")
    func testCallingConnectDoesCallWebSocketTaskInspectable() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocketEngine(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
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
        let sut = WebSocketEngine(urlRequest: webSocketRequest, urlSession: urlSession, sessionDelegate: session)
        
        do {
            try await sut.connect()
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
        #expect(wsTask.didCallResume)
    }
    
}

@Suite("Test WebSocketEngine.disconnect()")
final class WebSocketEngineTests_disconnect {
    
}

@Suite("Test WebSocketEngine.send()")
final class WebSocketEngineTests_send {
    
}

@Suite("Test WebSocketEngine.messages()")
final class WebSocketEngineTests_messages {
    
}

@Suite("Test WebSocketEngine.stateChanges()")
final class WebSocketEngineTests_stateChanges {
    
}
