@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketErrorTests")
final class WebSocketErrorTests {
    @Test("test WebSocketError basic cases are Equatable", arguments: zip(WebSocketErrorList, WebSocketErrorList))
    func testBasicCasesAreEquatable(inputA: WebSocketError, inputB: WebSocketError) {
        #expect(inputA == inputB)
    }

    @Test("test different basic cases are not equal")
    func testDifferentBasicCasesAreNotEqual() {
        #expect(WebSocketError.notConnected != WebSocketError.alreadyConnected)
        #expect(WebSocketError.invalidURL != WebSocketError.invalidMessageFormat)
    }

    @Test("test unsupportedProtocol equality and inequality")
    func testUnsupportedProtocolEquality() {
        let a = WebSocketError.unsupportedProtocol("protoA")
        let b = WebSocketError.unsupportedProtocol("protoA")
        let c = WebSocketError.unsupportedProtocol("protoB")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("test keepAliveFailure equality by count")
    func testKeepAliveFailureEquality() {
        #expect(WebSocketError.keepAliveFailure(consecutiveFailures: 3) == .keepAliveFailure(consecutiveFailures: 3))
        #expect(WebSocketError.keepAliveFailure(consecutiveFailures: 2) != .keepAliveFailure(consecutiveFailures: 4))
    }

    @Test("test unexpectedDisconnection equality and description")
    func testUnexpectedDisconnectionEqualityAndDescription() {
        let lhs = WebSocketError.unexpectedDisconnection(code: .normalClosure, reason: "bye")
        let rhs = WebSocketError.unexpectedDisconnection(code: .normalClosure, reason: "bye")
        let other = WebSocketError.unexpectedDisconnection(code: .goingAway, reason: "bye")

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
    func testUnexpectedDisconnectionEqualityAndDescriptionWithNoReasonProvided() {
        let err = WebSocketError.unexpectedDisconnection(code: .normalClosure, reason: nil)
        
        guard case let .unexpectedDisconnection(code, _) = err else {
            #expect(Bool(false))
            return
        }
        
        let expected = "WebSocket disconnected unexpectedly with code \(code.rawValue): No reason provided"
        #expect(err.errorDescription == expected)
        #expect(err.description == expected)
    }

    @Test("test underlying error equality compares by type for various cases")
    func testUnderlyingErrorEqualityByType() {
        let urlErr1 = URLError(.timedOut)
        let urlErr2 = URLError(.timedOut)

        #expect(WebSocketError.connectionFailed(underlying: urlErr1) == .connectionFailed(underlying: urlErr2))
        #expect(WebSocketError.sendFailed(underlying: urlErr1) == .sendFailed(underlying: urlErr2))
        #expect(WebSocketError.receiveFailed(underlying: urlErr1) == .receiveFailed(underlying: urlErr2))
        #expect(WebSocketError.pingFailed(underlying: urlErr1) == .pingFailed(underlying: urlErr2))
    }
    
    @Test("test underlying error equality compares fails if underlying error difers")
    func testUnderlyingErrorEqualityByTypeFailsIfErrorDiffers() {
        let urlErr = URLError(.timedOut)
        let nsErr = NSError(domain: "test", code: 1, userInfo: nil)

        #expect(WebSocketError.connectionFailed(underlying: urlErr) != .connectionFailed(underlying: nsErr))
    }

    @Test("test localized descriptions for a selection of cases")
    func testLocalizedDescriptions() {
        #expect(WebSocketError.notConnected.errorDescription == "WebSocket is not connected")
        #expect(WebSocketError.invalidURL.errorDescription == "Invalid WebSocket URL")
        #expect(WebSocketError.invalidMessageFormat.errorDescription == "Invalid WebSocket message format")
        #expect(WebSocketError.messageEncodingFailed.errorDescription == "Failed to encode message for WebSocket")
        #expect(WebSocketError.messageDecodingFailed.errorDescription == "Failed to decode WebSocket message")
    }
    
    @Test("LocalizedError - dynamic descriptions")
    func testLocalizedErrorDynamicDescriptions() {
        let err = NSError(domain: "Test", code: -1)
        let msg = err.localizedDescription
        let protocolString = "bad-protocol"
        let count = 3

        #expect(WebSocketError.connectionFailed(underlying: err).errorDescription == "WebSocket connection failed: \(msg)")
        #expect(WebSocketError.sendFailed(underlying: err).errorDescription == "Failed to send WebSocket message: \(msg)")
        #expect(WebSocketError.receiveFailed(underlying: err).errorDescription == "Failed to receive WebSocket message: \(msg)")
        #expect(WebSocketError.pingFailed(underlying: err).errorDescription == "WebSocket ping failed: \(msg)")

        #expect(WebSocketError.unsupportedProtocol(protocolString).errorDescription == "Unsupported WebSocket protocol: \(protocolString)")
        #expect(WebSocketError.keepAliveFailure(consecutiveFailures: count).errorDescription == "WebSocket keep-alive failed after \(count) consecutive attempts")
    }

    private static let WebSocketErrorList: [WebSocketError] = [
        .notConnected,
        .alreadyConnected,
        .connectionTimeout,
        .invalidURL,
        .invalidMessageFormat,
        .messageEncodingFailed,
        .messageDecodingFailed,
        .pongTimeout,
        .forcedDisconnection,
        .taskNotInitialized,
        .taskCancelled,
        .streamAlreadyCreated,
        .streamNotAvailable,
    ]
}
