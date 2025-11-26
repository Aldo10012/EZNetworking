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
    
    
    @Test("connectionStateStream yields expected states",
        .disabled("keeps getting stuck in observing conneciton state stream") // TODO: fix
    )
    func testConnectionStateStreamYieldsExpectedStates() async throws {
        let urlSession = MockWebSockerURLSession()
        let sut = WebSocketEngine(urlSession: urlSession, sessionDelegate: nil)

        var receivedConnectionState = [WebSocketConnectionState]()
        let expected: [WebSocketConnectionState] = [
            .connecting,
            .connected(protocol: "test")
        ]

        let streamTask = Task {
            var iterator = await sut.connectionStateStream.makeAsyncIterator()
            while let state = await iterator.next(), receivedConnectionState.count < expected.count {
                receivedConnectionState.append(state)
            }
        }

        try await sut.connect(with: webSocketUrl, protocols: [])

        // Wait for the stream to yield the expected number of states
        _ = try await streamTask.value

        #expect(expected == receivedConnectionState)
    }
}

private let webSocketUrl = URL(string: "ws://127.0.0.1:8080/example")!
