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
        #expect(SSEError.invalidStatusCode(404) == .invalidStatusCode(404))
        #expect(SSEError.invalidStatusCode(404) != .invalidStatusCode(500))
    }

    @Test("Verifies invalidContentType equality including nil values")
    func testContentTypeEquality() {
        #expect(SSEError.invalidContentType("text/event-stream") == .invalidContentType("text/event-stream"))
        #expect(SSEError.invalidContentType(nil) == .invalidContentType(nil))
        #expect(SSEError.invalidContentType("application/json") != .invalidContentType("text/event-stream"))
        #expect(SSEError.invalidContentType("text/event-stream") != .invalidContentType(nil))
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
        (SSEError.invalidStatusCode(200), SSEError.invalidContentType("text")),
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
        let error: SSEError = .invalidStatusCode(500)

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("500") == true)
        #expect(error.errorDescription?.contains("200") == true)
    }

    @Test("Invalid content type error description with value")
    func invalidContentTypeErrorDescriptionWithValue() {
        let error: SSEError = .invalidContentType("text/html")

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("text/html") == true)
        #expect(error.errorDescription?.contains("text/event-stream") == true)
    }

    @Test("Invalid content type error description with nil")
    func invalidContentTypeErrorDescriptionWithNil() {
        let error: SSEError = .invalidContentType(nil)

        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("did not specify") == true)
        #expect(error.errorDescription?.contains("text/event-stream") == true)
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
        let error: SSEError = .invalidStatusCode(404)
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
            .invalidStatusCode(404),
            .invalidContentType("text/html"),
            .unexpectedDisconnection
        ]

        for error in errors {
            switch error {
            case .notConnected, .alreadyConnected, .stillConnecting,
                 .connectionFailed, .invalidResponse, .invalidStatusCode,
                 .invalidContentType, .unexpectedDisconnection:
                #expect(Bool(true))
            }
        }
    }

    // MARK: - Edge Cases

    @Test("Multiple status codes")
    func multipleStatusCodes() {
        let statusCodes = [400, 401, 403, 404, 500, 502, 503]

        for code in statusCodes {
            let error: SSEError = .invalidStatusCode(code)

            if case let .invalidStatusCode(receivedCode) = error {
                #expect(receivedCode == code)
            } else {
                Issue.record("Expected invalidStatusCode error for code \(code)")
            }
        }
    }

    @Test("Various content types")
    func variousContentTypes() {
        let contentTypes = [
            "application/json",
            "text/html",
            "text/plain",
            "application/xml"
        ]

        for contentType in contentTypes {
            let error: SSEError = .invalidContentType(contentType)

            if case let .invalidContentType(receivedType) = error {
                #expect(receivedType == contentType)
            } else {
                Issue.record("Expected invalidContentType error")
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
            .invalidStatusCode(404),
            .invalidContentType("text/html"),
            .invalidContentType(nil),
            .unexpectedDisconnection
        ]

        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }
}
