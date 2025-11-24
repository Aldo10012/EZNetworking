@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketConnectionState")
final class WebSocketConnectionStateTests {
	@Test("basic equality for simple states")
	func testBasicEquality() {
		#expect(WebSocketConnectionState.disconnected == .disconnected)
		#expect(WebSocketConnectionState.connecting == .connecting)
        #expect(WebSocketConnectionState.idle == .idle)
	}

	@Test("connected state equality with protocol values")
	func testConnectedEquality() {
		#expect(WebSocketConnectionState.connected(protocol: nil) == .connected(protocol: nil))
		#expect(WebSocketConnectionState.connected(protocol: "chat") == .connected(protocol: "chat"))
		#expect(WebSocketConnectionState.connected(protocol: "chat") != .connected(protocol: "video"))
		#expect(WebSocketConnectionState.connected(protocol: nil) != .connected(protocol: "chat"))
	}

	@Test("connectionLost and failed equality by underlying WebSocketError")
	func testErrorAssociatedEquality() {
		let err1 = WebSocketError.connectionFailed(underlying: URLError(.notConnectedToInternet))
		let err2 = WebSocketError.connectionFailed(underlying: URLError(.notConnectedToInternet))
		let other = WebSocketError.connectionFailed(underlying: NSError(domain: "x", code: 1))

		#expect(WebSocketConnectionState.connectionLost(reason: err1) == .connectionLost(reason: err2))
		#expect(WebSocketConnectionState.connectionLost(reason: err1) != .connectionLost(reason: other))

		#expect(WebSocketConnectionState.failed(error: err1) == .failed(error: err2))
		#expect(WebSocketConnectionState.failed(error: err1) != .failed(error: other))
	}

	@Test("different enum cases are not equal")
	func testDifferentCasesNotEqual() {
		#expect(WebSocketConnectionState.disconnected != .connecting)
		#expect(WebSocketConnectionState.disconnected != .connected(protocol: nil))
		#expect(WebSocketConnectionState.connecting != .connected(protocol: "p"))
		#expect(WebSocketConnectionState.connectionLost(reason: WebSocketError.taskCancelled) != .failed(error: WebSocketError.taskCancelled))
	}
}
