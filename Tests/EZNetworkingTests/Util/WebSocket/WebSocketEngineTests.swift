@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketEngine")
final class WebSocketEngineTests {
    
    // MARK: Test connection
    
    @Test("test calling .connect() calls .didCallWebSocketTaskInspectable")
    func testCallingConnectcallsDidCallWebSocketTaskInterceptable() async throws {
        let urlSession = MockWebSockerURLSession()
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: nil)
        
        try await sut.connect(with: webSocketUrl, protocols: [])
        #expect(urlSession.didCallWebSocketTaskInspectable == true)
    }
    
    @Test("test calling .connect() a second time throws WebSocketError.alreadyConnected")
    func fooCallingConnectTwiceThrowsAlreadyConnected() async throws {
        let urlSession = MockWebSockerURLSession()
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: nil)
        
        // first time connect succeeds
        try await sut.connect(with: webSocketUrl, protocols: [])
        
        // second time connect throws
        await #expect(throws: WebSocketError.alreadyConnected) {
            try await sut.connect(with: webSocketUrl, protocols: [])
        }
    }
}

private let webSocketUrl = URL(string: "ws://127.0.0.1:8080/example")!
