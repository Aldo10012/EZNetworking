@testable import EZNetworking
import Foundation
import Testing

@Suite("SSEError Tests")
struct SSEErrorTests {
    // MARK: - Equality

    @Test("Verifies basic cases without associated values")
    func testBasicEquality() {
        #expect(SSEError.notConnected == .notConnected)
        #expect(SSEError.stillConnecting == .stillConnecting)
        #expect(SSEError.alreadyConnected == .alreadyConnected)
        #expect(SSEError.invalidResponse == .invalidResponse)
        #expect(SSEError.unexpectedDisconnection == .unexpectedDisconnection)

        // Cross-case inequality
        #expect(SSEError.notConnected != .stillConnecting)
    }

    @Test("Verifies invalidStatusCode equality and inequality")
    func testStatusCodeEquality() {
        #expect(SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 404)) == .invalidHTTPResponse(HTTPResponse(statusCode: 404)))
        #expect(SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 500)) != .invalidHTTPResponse(HTTPResponse(statusCode: 501)))
    }

    @Test("Verifies connectionFailed equality by bridging to NSError")
    func testConnectionFailedEquality() {
        let error1 = NSError(domain: "test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "test", code: 1, userInfo: nil)
        let differentError = NSError(domain: "test", code: 2, userInfo: nil)

        #expect(SSEError.connectionFailed(underlying: error1) == .connectionFailed(underlying: error2))
        #expect(SSEError.connectionFailed(underlying: error1) != .connectionFailed(underlying: differentError))
    }

    @Test("Verifies inequality across different enum cases", arguments: [
        (SSEError.notConnected, SSEError.invalidResponse),
        (SSEError.invalidHTTPResponse(HTTPResponse(statusCode: 200)), SSEError.notConnected),
        (SSEError.stillConnecting, SSEError.unexpectedDisconnection)
    ])
    func testMismatchedCases(lhs: SSEError, rhs: SSEError) {
        #expect(lhs != rhs)
    }

    // MARK: - LocalizedError Tests

    @Test("Not connected error description")
    func notConnectedErrorDescription() {
        let error: SSEError = .notConnected

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("not currently established") == true)
    }

    @Test("Already connected error description")
    func alreadyConnectedErrorDescription() {
        let error: SSEError = .alreadyConnected

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("already established") == true)
    }

    @Test("Still connecting error description")
    func stillConnectingErrorDescription() {
        let error: SSEError = .stillConnecting

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("in progress") == true)
    }

    @Test("Connection failed error description")
    func connectionFailedErrorDescription() {
        let underlyingError = NSError(
            domain: "TestDomain",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Network unavailable"]
        )
        let error: SSEError = .connectionFailed(underlying: underlyingError)

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Failed to establish") == true)
        #expect(error.errorDescription?.contains("Network unavailable") == true)
    }

    @Test("Invalid response error description")
    func invalidResponseErrorDescription() {
        let error: SSEError = .invalidResponse

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("not a valid HTTP response") == true)
    }

    @Test("Invalid status code error description")
    func invalidStatusCodeErrorDescription() {
        let error: SSEError = .invalidHTTPResponse(HTTPResponse(statusCode: 500))

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("500") == true)
    }

    @Test("Unexpected disconnection error description")
    func unexpectedDisconnectionErrorDescription() {
        let error: SSEError = .unexpectedDisconnection

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("unexpectedly closed") == true)
    }

    // MARK: - Error Protocol Conformance

    @Test("Error protocol conformance")
    func errorProtocolConformance() {
        let error: SSEError = .notConnected
        let anyError: Error = error

        #expect(anyError is SSEError)
    }

    @Test("LocalizedError protocol conformance")
    func localizedErrorProtocolConformance() {
        let error: SSEError = .invalidHTTPResponse(HTTPResponse(statusCode: 404))
        let localizedError: LocalizedError = error

        #expect(localizedError.errorDescription != nil)
    }

    // MARK: - Pattern Matching Tests

    @Test("Pattern matching all error cases")
    func patternMatchingAllErrorCases() {
        let errors: [SSEError] = [
            .notConnected,
            .alreadyConnected,
            .stillConnecting,
            .connectionFailed(underlying: NSError(domain: "test", code: 1)),
            .invalidResponse,
            .invalidHTTPResponse(HTTPResponse(statusCode: 404)),
            .unexpectedDisconnection
        ]

        for error in errors {
            switch error {
            case .notConnected, .alreadyConnected, .stillConnecting, .connectionFailed,
                 .invalidResponse, .invalidHTTPResponse, .unexpectedDisconnection:
                #expect(Bool(true))
            }
        }
    }

    // MARK: - Edge Cases

    @Test("Multiple status codes")
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

    @Test("Error description is not empty")
    func errorDescriptionIsNotEmpty() {
        let errors: [SSEError] = [
            .notConnected,
            .alreadyConnected,
            .stillConnecting,
            .connectionFailed(underlying: NSError(domain: "test", code: 1)),
            .invalidResponse,
            .invalidHTTPResponse(HTTPResponse(statusCode: 404)),
            .unexpectedDisconnection
        ]

        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }
}
