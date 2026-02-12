@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SSEResponseValidator")
final class SSEResponseValidatorTests {
    // MARK: - Helper Methods

    /// Creates a mock HTTPURLResponse with the given status code and headers
    private func makeMockResponse(
        statusCode: Int,
        headers: [String: String] = [:]
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com/events")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }

    /// Creates a non-HTTP URLResponse for testing invalid response type
    private func makeNonHTTPResponse() -> URLResponse {
        URLResponse(
            url: URL(string: "https://example.com/events")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }

    // MARK: - Success Cases (2xx with correct Content-Type)

    @Test("Validates 200 OK with text/event-stream")
    func validates200WithCorrectContentType() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Validates 200 OK with text/event-stream and charset")
    func validates200WithContentTypeAndCharset() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "text/event-stream; charset=utf-8"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Validates 201 Created with text/event-stream")
    func validates201WithCorrectContentType() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 201,
            headers: ["Content-Type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Validates 202 Accepted with text/event-stream")
    func validates202WithCorrectContentType() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 202,
            headers: ["Content-Type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Validates 204 No Content with text/event-stream")
    func validates204WithCorrectContentType() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 204,
            headers: ["Content-Type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Validates 206 Partial Content with text/event-stream")
    func validates206WithCorrectContentType() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 206,
            headers: ["Content-Type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Content-Type is case-insensitive in header key")
    func contentTypeHeaderIsCaseInsensitive() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["content-type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Content-Type value is case-insensitive")
    func contentTypeValueIsCaseInsensitive() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "TEXT/EVENT-STREAM"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Content-Type with mixed case")
    func contentTypeWithMixedCase() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "Text/Event-Stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    // MARK: - Invalid Response Type

    @Test("Throws invalidResponse for non-HTTP response")
    func throwsInvalidResponseForNonHTTP() {
        let validator = SSEResponseValidator()
        let response = makeNonHTTPResponse()

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("InvalidResponse error has correct type")
    func invalidResponseErrorHasCorrectType() {
        let validator = SSEResponseValidator()
        let response = makeNonHTTPResponse()

        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected error to be thrown")
        } catch let error as SSEError {
            if case .invalidResponse = error {
                #expect(Bool(true))
            } else {
                Issue.record("Expected .invalidResponse error, got: \(error)")
            }
        } catch {
            Issue.record("Expected SSEError, got: \(error)")
        }
    }

    // MARK: - Invalid Status Code (non-2xx)

    @Test("Throws invalidHTTPResponse for 1xx status code")
    func throwsInvalidHTTPResponseFor1xx() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 100,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 3xx redirect")
    func throwsInvalidHTTPResponseFor3xx() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 301,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 400 Bad Request")
    func throwsInvalidHTTPResponseFor400() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 400,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 401 Unauthorized")
    func throwsInvalidHTTPResponseFor401() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 401,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 403 Forbidden")
    func throwsInvalidHTTPResponseFor403() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 403,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 404 Not Found")
    func throwsInvalidHTTPResponseFor404() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 404,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 500 Internal Server Error")
    func throwsInvalidHTTPResponseFor500() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 500,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 502 Bad Gateway")
    func throwsInvalidHTTPResponseFor502() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 502,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for 503 Service Unavailable")
    func throwsInvalidHTTPResponseFor503() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 503,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("InvalidHTTPResponse error contains response details for bad status")
    func invalidHTTPResponseErrorContainsResponseDetailsForBadStatus() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 404,
            headers: ["Content-Type": "text/event-stream"]
        )

        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected error to be thrown")
        } catch let error as SSEError {
            if case let .invalidHTTPResponse(httpResponse) = error {
                #expect(httpResponse.statusCode == 404)
                #expect(httpResponse.headers["Content-Type"] == "text/event-stream")
            } else {
                Issue.record("Expected .invalidHTTPResponse error, got: \(error)")
            }
        } catch {
            Issue.record("Expected SSEError, got: \(error)")
        }
    }

    // MARK: - Invalid Content-Type

    @Test("Throws invalidHTTPResponse for missing Content-Type")
    func throwsInvalidHTTPResponseForMissingContentType() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: [:]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for wrong Content-Type")
    func throwsInvalidHTTPResponseForWrongContentType() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for text/plain")
    func throwsInvalidHTTPResponseForTextPlain() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "text/plain"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for text/html")
    func throwsInvalidHTTPResponseForTextHTML() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "text/html"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Throws invalidHTTPResponse for application/xml")
    func throwsInvalidHTTPResponseForApplicationXML() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "application/xml"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("InvalidHTTPResponse error contains response details for bad Content-Type")
    func invalidHTTPResponseErrorContainsResponseDetailsForBadContentType() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )

        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected error to be thrown")
        } catch let error as SSEError {
            if case let .invalidHTTPResponse(httpResponse) = error {
                #expect(httpResponse.statusCode == 200)
                #expect(httpResponse.headers["Content-Type"] == "application/json")
            } else {
                Issue.record("Expected .invalidHTTPResponse error, got: \(error)")
            }
        } catch {
            Issue.record("Expected SSEError, got: \(error)")
        }
    }

    // MARK: - Edge Cases

    @Test("Validates with empty headers except Content-Type")
    func validatesWithEmptyHeadersExceptContentType() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "text/event-stream"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Validates with many additional headers")
    func validatesWithManyAdditionalHeaders() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: [
                "Content-Type": "text/event-stream",
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
                "X-Custom-Header": "value",
                "Authorization": "Bearer token"
            ]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Content-Type with extra whitespace")
    func contentTypeWithExtraWhitespace() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "  text/event-stream  "]
        )

        // Should not throw (contains check works with whitespace)
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Content-Type with parameters")
    func contentTypeWithParameters() throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "text/event-stream; charset=utf-8; boundary=something"]
        )

        // Should not throw
        try validator.validateStatus(from: response)

        #expect(Bool(true))
    }

    @Test("Boundary case - 199 status code fails")
    func boundary199StatusCodeFails() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 199,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Boundary case - 300 status code fails")
    func boundary300StatusCodeFails() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 300,
            headers: ["Content-Type": "text/event-stream"]
        )

        #expect(throws: SSEError.self) {
            try validator.validateStatus(from: response)
        }
    }

    // MARK: - Error Message Tests

    @Test("Error message for bad status code mentions expected 2xx")
    func errorMessageForBadStatusCodeMentionsExpected2xx() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 404,
            headers: ["Content-Type": "text/event-stream"]
        )

        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected error to be thrown")
        } catch let error as SSEError {
            let description = error.errorDescription ?? ""
            #expect(description.contains("404"))
            #expect(description.lowercased().contains("2xx"))
        } catch {
            Issue.record("Expected SSEError, got: \(error)")
        }
    }

    @Test("Error message for bad Content-Type mentions expected text/event-stream")
    func errorMessageForBadContentTypeMentionsExpected() {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )

        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected error to be thrown")
        } catch let error as SSEError {
            let description = error.errorDescription ?? ""
            #expect(description.contains("application/json"))
            #expect(description.contains("text/event-stream"))
        } catch {
            Issue.record("Expected SSEError, got: \(error)")
        }
    }
}
