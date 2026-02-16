@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketErrorTests")
final class WebSocketErrorTests {
    @Test("test WebSocketError basic cases are Equatable", arguments: zip(WebSocketErrorList, WebSocketErrorList))
    func basicCasesAreEquatable(inputA: WebSocketFailureReason, inputB: WebSocketFailureReason) {
        #expect(inputA == inputB)
    }

    @Test("test different basic cases are not equal")
    func differentBasicCasesAreNotEqual() {
        #expect(WebSocketFailureReason.notConnected != WebSocketFailureReason.alreadyConnected)
        #expect(WebSocketFailureReason.alreadyConnected != WebSocketFailureReason.stillConnecting)
    }

    @Test("test unexpectedDisconnection equality and description")
    func unexpectedDisconnectionEqualityAndDescription() {
        let lhs = WebSocketFailureReason.unexpectedDisconnection(code: .normalClosure, reason: "bye")
        let rhs = WebSocketFailureReason.unexpectedDisconnection(code: .normalClosure, reason: "bye")
        let other = WebSocketFailureReason.unexpectedDisconnection(code: .goingAway, reason: "bye")

        #expect(lhs == rhs)
        #expect(lhs != other)

        // description should contain code raw value and reason
        guard case let .unexpectedDisconnection(code, reason) = lhs else {
            #expect(Bool(false))
            return
        }
        let expected = "WebSocket disconnected unexpectedly with code \(code.rawValue): \(reason ?? "No  provided")"
        #expect(lhs.errorDescription == expected)
        #expect(lhs.description == expected)
    }

    @Test("test unexpectedDisconnection equality and description with no reason provided")
    func unexpectedDisconnectionEqualityAndDescriptionWithNoReasonProvided() {
        let err = WebSocketFailureReason.unexpectedDisconnection(code: .normalClosure, reason: nil)

        guard case let .unexpectedDisconnection(code, _) = err else {
            #expect(Bool(false))
            return
        }

        let expected = "WebSocket disconnected unexpectedly with code \(code.rawValue): No reason provided"
        #expect(err.errorDescription == expected)
        #expect(err.description == expected)
    }

    @Test("test underlying error equality compares by type for various cases")
    func underlyingErrorEqualityByType() {
        let urlErr1 = URLError(.timedOut)
        let urlErr2 = URLError(.timedOut)

        #expect(WebSocketFailureReason.connectionFailed(underlying: urlErr1) == .connectionFailed(underlying: urlErr2))
        #expect(WebSocketFailureReason.sendFailed(underlying: urlErr1) == .sendFailed(underlying: urlErr2))
        #expect(WebSocketFailureReason.receiveFailed(underlying: urlErr1) == .receiveFailed(underlying: urlErr2))
        #expect(WebSocketFailureReason.pingFailed(underlying: urlErr1) == .pingFailed(underlying: urlErr2))
    }

    @Test("test underlying error equality compares fails if underlying error difers")
    func underlyingErrorEqualityByTypeFailsIfErrorDiffers() {
        let urlErr = URLError(.timedOut)
        let nsErr = NSError(domain: "test", code: 1, userInfo: nil)

        #expect(WebSocketFailureReason.connectionFailed(underlying: urlErr) != .connectionFailed(underlying: nsErr))
    }

    @Test("test localized descriptions for a selection of cases")
    func localizedDescriptions() {
        #expect(WebSocketFailureReason.notConnected.errorDescription == "WebSocket is not connected")
        #expect(WebSocketFailureReason.stillConnecting.errorDescription == "WebSocket is still connecting")
        #expect(WebSocketFailureReason.alreadyConnected.errorDescription == "WebSocket is already connected")
        #expect(WebSocketFailureReason.pongTimeout.errorDescription == "WebSocket pong response timed out")
    }

    @Test("LocalizedError - dynamic descriptions")
    func localizedErrorDynamicDescriptions() {
        let err = NSError(domain: "Test", code: -1)
        let msg = err.localizedDescription

        #expect(WebSocketFailureReason.connectionFailed(underlying: err).errorDescription == "WebSocket connection failed: \(msg)")
        #expect(WebSocketFailureReason.sendFailed(underlying: err).errorDescription == "Failed to send WebSocket message: \(msg)")
        #expect(WebSocketFailureReason.receiveFailed(underlying: err).errorDescription == "Failed to receive WebSocket message: \(msg)")
        #expect(WebSocketFailureReason.pingFailed(underlying: err).errorDescription == "WebSocket ping failed: \(msg)")
    }

    private static let WebSocketErrorList: [WebSocketFailureReason] = [
        .notConnected,
        .stillConnecting,
        .alreadyConnected,
        .pongTimeout,
        .forcedDisconnection
    ]
}
