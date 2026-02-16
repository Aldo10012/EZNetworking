@testable import EZNetworking
import Foundation
import Testing

@Suite("SSEError Tests")
struct SSEErrorTests {
    // MARK: - Equality

    @Test("test Verifies basic cases without associated values")
    func basicEquality() {
        #expect(SSEError.notConnected == .notConnected)
        #expect(SSEError.stillConnecting == .stillConnecting)
        #expect(SSEError.alreadyConnected == .alreadyConnected)
        #expect(SSEError.invalidResponse == .invalidResponse)
        #expect(SSEError.unexpectedDisconnection == .unexpectedDisconnection)
        #expect(SSEError.maxReconnectAttemptsReached == .maxReconnectAttemptsReached)

        // Cross-case inequality
        #expect(SSEError.notConnected != .stillConnecting)
    }

    @Test("test Verifies invalidStatusCode equality and inequality")
    func statusCodeEquality() {
        #expect(SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 404)) == .invalidHTTPResponse(HTTPResponse(statusCode: 404)))
        #expect(SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 500)) != .invalidHTTPResponse(HTTPResponse(statusCode: 501)))
    }

    @Test("test Verifies connectionFailed equality by bridging to NSError")
    func connectionFailedEquality() {
        let error1 = NSError(domain: "test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "test", code: 1, userInfo: nil)
        let differentError = NSError(domain: "test", code: 2, userInfo: nil)

        #expect(SSEError.connectionFailed(underlying: error1) == .connectionFailed(underlying: error2))
        #expect(SSEError.connectionFailed(underlying: error1) != .connectionFailed(underlying: differentError))
    }

    @Test("test Verifies inequality across different enum cases", arguments: [
        (SSEError.notConnected, SSEError.invalidResponse),
        (SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 200)), SSEError.notConnected),
        (SSEError.stillConnecting, SSEError.unexpectedDisconnection)
    ])
    func mismatchedCases(lhs: SSEError, rhs: SSEError) {
        #expect(lhs != rhs)
    }

    // MARK: - Error Protocol Conformance

    @Test("test Error protocol conformance")
    func errorProtocolConformance() {
        let error: SSEError = .notConnected
        let anyError: Error = error

        #expect(anyError is SSEError)
    }

    // MARK: - Pattern Matching Tests

    @Test("test Pattern matching all error cases")
    func patternMatchingAllErrorCases() {
        let errors: [SSEError] = [
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
            let error: SSEError = .invalidHTTPResponse(HTTPResponse(statusCode: code))

            if case let .invalidHTTPResponse(receivedCode) = error {
                #expect(receivedCode.statusCode == code)
            } else {
                Issue.record("Expected invalidStatusCode error for code \(code)")
            }
        }
    }

}
