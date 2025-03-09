import XCTest
@testable import EZNetworking

final class SessionDelegateURLSessionWebSocketDelegateTests: XCTestCase {
    
    func testSessionDelegateWebSocketDidOpenWithProtocol() {
        let webSocketInterceptor = MockWebSocketTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.webSocketTaskInterceptor = webSocketInterceptor
        
        let webSocketTask = mockURLSessionWebSocketTask
        let protocolString = "test-protocol"
        delegate.urlSession(.shared, webSocketTask: webSocketTask, didOpenWithProtocol: protocolString)
        
        XCTAssertTrue(webSocketInterceptor.didOpenWithProtocol)
        XCTAssertEqual(webSocketInterceptor.receivedProtocol, protocolString)
    }
    
    func testSessionDelegateWebSocketDidCloseWithCodeAndReason() {
        let webSocketInterceptor = MockWebSocketTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.webSocketTaskInterceptor = webSocketInterceptor
        
        let closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
        let reasonData = "Closed by server".data(using: .utf8)
        delegate.urlSession(.shared, webSocketTask: mockURLSessionWebSocketTask, didCloseWith: closeCode, reason: reasonData)
        
        XCTAssertTrue(webSocketInterceptor.didCloseWithCodeAndReason)
        XCTAssertEqual(webSocketInterceptor.receivedCloseCode, closeCode)
        XCTAssertEqual(webSocketInterceptor.receivedReason, reasonData)
    }
}

// MARK: mock class

private class MockWebSocketTaskInterceptor: WebSocketTaskInterceptor {
    var didOpenWithProtocol = false
    var didCloseWithCodeAndReason = false
    var receivedProtocol: String?
    var receivedCloseCode: URLSessionWebSocketTask.CloseCode?
    var receivedReason: Data?
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        didOpenWithProtocol = true
        receivedProtocol = `protocol`
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        didCloseWithCodeAndReason = true
        receivedCloseCode = closeCode
        receivedReason = reason
    }
}

// MARK: mock variables

private var mockURLSessionWebSocketTask: URLSessionWebSocketTask {
    URLSession.shared.webSocketTask(with: URL(string: "wss://www.example.com")!)
}

