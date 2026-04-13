@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketFailureReason")
final class WebSocketFailureReasonTests {
    @Test("test WebSocketFailureReason equatability", arguments: zip(WebSocketErrorList, WebSocketErrorList))
    func basicCasesAreEquatable(inputA: WebSocketFailureReason, inputB: WebSocketFailureReason) {
        #expect(inputA == inputB)
    }

    @Test("test .connectionFailed(underlying:_) non equality")
    func connectionFailedNonEquality() {
        let reasonA = WebSocketFailureReason.connectionFailed(underlying: URLError(.notConnectedToInternet))
        let reasonB = WebSocketFailureReason.connectionFailed(underlying: URLError(.networkConnectionLost))
        #expect(reasonA != reasonB)
    }

    @Test("test .sendFailed(underlying:_) non equality")
    func sendFailedNonEquality() {
        let reasonA = WebSocketFailureReason.sendFailed(underlying: URLError(.notConnectedToInternet))
        let reasonB = WebSocketFailureReason.sendFailed(underlying: URLError(.networkConnectionLost))
        #expect(reasonA != reasonB)
    }

    @Test("test .receiveFailed(underlying:_) non equality")
    func sendReceiveNonEquality() {
        let reasonA = WebSocketFailureReason.receiveFailed(underlying: URLError(.notConnectedToInternet))
        let reasonB = WebSocketFailureReason.receiveFailed(underlying: URLError(.networkConnectionLost))
        #expect(reasonA != reasonB)
    }

    @Test("test .pingFailed(underlying:_) non equality")
    func sendPingNonEquality() {
        let reasonA = WebSocketFailureReason.pingFailed(underlying: URLError(.notConnectedToInternet))
        let reasonB = WebSocketFailureReason.pingFailed(underlying: URLError(.networkConnectionLost))
        #expect(reasonA != reasonB)
    }

    @Test("test .unexpectedDisconnection(underlying:_) non equality")
    func unexpectedDisconnectionNonEquality() {
        let reasonA = WebSocketFailureReason.unexpectedDisconnection(code: .goingAway, reason: nil)
        let reasonB = WebSocketFailureReason.unexpectedDisconnection(code: .messageTooBig, reason: nil)
        #expect(reasonA != reasonB)
    }

    private static let WebSocketErrorList: [WebSocketFailureReason] = [
        .notConnected,
        .stillConnecting,
        .alreadyConnected,
        .connectionFailed(underlying: URLError(.notConnectedToInternet)),
        .sendFailed(underlying: URLError(.unknown)),
        .receiveFailed(underlying: URLError(.unknown)),
        .pingFailed(underlying: URLError(.unknown)),
        .unexpectedDisconnection(code: .goingAway, reason: nil),
        .pongTimeout,
        .forcedDisconnection
    ]
}
