@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.disconnect()")
final class WebSocketDisconnectTests: WebSocketTestCase {
    // MARK: .disconnect()

    @Test("test calling .disconnect() does call WebSocketTask.cancel()")
    func callingDisconnectDoesCallWebSocketTaskCancel() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        try await sut.disconnect()

        #expect(wsTask.didCallCancel == true)
        #expect(wsTask.didCancelWithCloseCode == .normalClosure)
        #expect(wsTask.didCancelWithReason == nil)
    }

    @Test("test calling .disconnect() throws if did not call .connect() first")
    func callingDisconnectFailsIfNotConnected() async throws {
        let sut = getSut()

        var disconnectDidThrow = false
        do {
            try await sut.disconnect()
            Issue.record("Unexpectedly disconnected without error")
        } catch {
            disconnectDidThrow = true
        }
        #expect(disconnectDidThrow)
    }
}
