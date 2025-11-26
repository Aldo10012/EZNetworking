@testable import EZNetworking
import Foundation
import Testing

// MARK: Test .connect()

@Suite("Test WebSocketEngine .connect()")
final class WebSocketEngineTests_connect {
        
    @Test("test calling .connect() calls .didCallWebSocketTaskInspectable")
    func testCallingConnectcallsDidCallWebSocketTaskInterceptable() async throws {
        let urlSession = MockWebSockerURLSession()
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: nil)
        
        try await sut.connect(with: webSocketUrl, protocols: [])
        #expect(urlSession.didCallWebSocketTaskInspectable == true)
    }
    
    @Test("test calling .connect() a second time throws WebSocketError.alreadyConnected")
    func testCallingConnectTwiceThrowsAlreadyConnected() async throws {
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

// MARK: Test .disconnect()

@Suite("Test WebSocketEngine .disconnect()")
final class WebSocketEngineTests_disconnect {
    
}

// MARK: Test .connectionStateStream

@Suite("Test WebSocketEngine .connectionStateStream")
final class WebSocketEngineTests_connectionStateStream {
    
    @Test("connectionStateStream yields expected states")
    func testConnectionStateStreamYieldsExpectedStates() async throws {
        let urlSession = MockWebSockerURLSession()
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: nil)

        var receivedConnectionState = [WebSocketConnectionState]()
        let expected: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test"),
            .disconnected
        ]

        // Start listening to the stream concurrently
        let streamTask = Task {
            for await state in await sut.connectionStateStream {
                receivedConnectionState.append(state)
            }
        }

        try await sut.connect(with: webSocketUrl, protocols: [])
        await sut.disconnect(with: .goingAway, reason: nil)
        
        _ = await streamTask.value
        
        #expect(receivedConnectionState == expected)
    }
}

private let webSocketUrl = URL(string: "ws://127.0.0.1:8080/example")!
