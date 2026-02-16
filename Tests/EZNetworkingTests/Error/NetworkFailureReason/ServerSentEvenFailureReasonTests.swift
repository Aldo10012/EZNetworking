@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEvenFailureReason")
struct ServerSentEvenFailureReasonTests {
    // MARK: - Equality

    @Test("test Verifies basic cases without associated values")
    func basicEquality() {
        #expect(ServerSentEvenFailureReason.notConnected == .notConnected)
        #expect(ServerSentEvenFailureReason.stillConnecting == .stillConnecting)
        #expect(ServerSentEvenFailureReason.alreadyConnected == .alreadyConnected)
        #expect(ServerSentEvenFailureReason.invalidResponse == .invalidResponse)
        #expect(ServerSentEvenFailureReason.unexpectedDisconnection == .unexpectedDisconnection)
        #expect(ServerSentEvenFailureReason.maxReconnectAttemptsReached == .maxReconnectAttemptsReached)

        // Cross-case inequality
        #expect(ServerSentEvenFailureReason.notConnected != .stillConnecting)
    }

    @Test("test Verifies invalidStatusCode equality and inequality")
    func statusCodeEquality() {
        #expect(ServerSentEvenFailureReason.invalidHTTPResponse(HTTPResponse(statusCode: 404)) == .invalidHTTPResponse(HTTPResponse(statusCode: 404)))
        #expect(ServerSentEvenFailureReason.invalidHTTPResponse(HTTPResponse(statusCode: 500)) != .invalidHTTPResponse(HTTPResponse(statusCode: 501)))
    }

    @Test("test Verifies connectionFailed equality by bridging to NSError")
    func connectionFailedEquality() {
        let error1 = NSError(domain: "test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "test", code: 1, userInfo: nil)
        let differentError = NSError(domain: "test", code: 2, userInfo: nil)

        #expect(ServerSentEvenFailureReason.connectionFailed(underlying: error1) == .connectionFailed(underlying: error2))
        #expect(ServerSentEvenFailureReason.connectionFailed(underlying: error1) != .connectionFailed(underlying: differentError))
    }

    @Test("test Verifies inequality across different enum cases", arguments: [
        (ServerSentEvenFailureReason.notConnected, ServerSentEvenFailureReason.invalidResponse),
        (ServerSentEvenFailureReason.invalidHTTPResponse(HTTPResponse(statusCode: 200)), ServerSentEvenFailureReason.notConnected),
        (ServerSentEvenFailureReason.stillConnecting, ServerSentEvenFailureReason.unexpectedDisconnection)
    ])
    func mismatchedCases(lhs: ServerSentEvenFailureReason, rhs: ServerSentEvenFailureReason) {
        #expect(lhs != rhs)
    }

    // MARK: - Pattern Matching Tests

    @Test("test Pattern matching all error cases")
    func patternMatchingAllErrorCases() {
        let errors: [ServerSentEvenFailureReason] = [
            .notConnected,
            .alreadyConnected,
            .stillConnecting,
            .connectionFailed(underlying: NSError(domain: "test", code: 1)),
            .maxReconnectAttemptsReached,
            .invalidResponse,
            .invalidHTTPResponse(HTTPResponse(statusCode: 404)),
            .unexpectedDisconnection
        ]

        for error in errors {
            switch error {
            case .notConnected, .alreadyConnected, .stillConnecting, .connectionFailed, .maxReconnectAttemptsReached,
                 .invalidResponse, .invalidHTTPResponse, .unexpectedDisconnection:
                #expect(Bool(true))
            }
        }
    }

    // MARK: - Edge Cases

    @Test("test Multiple status codes")
    func multipleStatusCodes() {
        let statusCodes = [400, 401, 403, 404, 500, 502, 503]

        for code in statusCodes {
            let error: ServerSentEvenFailureReason = .invalidHTTPResponse(HTTPResponse(statusCode: code))

            if case let .invalidHTTPResponse(receivedCode) = error {
                #expect(receivedCode.statusCode == code)
            } else {
                Issue.record("Expected invalidStatusCode error for code \(code)")
            }
        }
    }

}
