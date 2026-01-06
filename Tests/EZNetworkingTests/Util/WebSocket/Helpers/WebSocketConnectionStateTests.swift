@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketConnectionState")
final class WebSocketConnectionStateTests {
    @Test("basic equality for simple states")
    func testBasicEquality() {
        #expect(WebSocketConnectionState.notConnected == .notConnected)
        #expect(WebSocketConnectionState.connecting == .connecting)
        #expect(WebSocketConnectionState.connecting == .connecting)
    }

    @Test("connected state equality with protocol values")
    func testConnectedEquality() {
        #expect(WebSocketConnectionState.connected(protocol: nil) == .connected(protocol: nil))
        #expect(WebSocketConnectionState.connected(protocol: "chat") == .connected(protocol: "chat"))
        #expect(WebSocketConnectionState.connected(protocol: "chat") != .connected(protocol: "video"))
        #expect(WebSocketConnectionState.connected(protocol: nil) != .connected(protocol: "chat"))
    }
    
    @Test("disconnected state equality with protocol values")
    func testDisconnectEquality() {
        let manuallyDisconnected = WebSocketConnectionState.disconnected(.manuallyDisconnected)
        let connectionLostA = WebSocketConnectionState.disconnected(.connectionLost(error: .alreadyConnected))
        let connectionLostB = WebSocketConnectionState.disconnected(.connectionLost(error: .stillConnecting))
        let failedToConnectA = WebSocketConnectionState.disconnected(.failedToConnect(error: .alreadyConnected))
        let failedToConnectB = WebSocketConnectionState.disconnected(.failedToConnect(error: .stillConnecting))

        #expect(manuallyDisconnected == manuallyDisconnected)
        #expect(connectionLostA == connectionLostA)
        #expect(connectionLostB == connectionLostB)
        #expect(failedToConnectA == failedToConnectA)
        #expect(failedToConnectB == failedToConnectB)
        
        #expect(connectionLostA != connectionLostB)
        #expect(failedToConnectA != failedToConnectB)

        #expect(manuallyDisconnected != connectionLostA)
        #expect(connectionLostA != failedToConnectA)
        #expect(failedToConnectA != manuallyDisconnected)
    }
}
