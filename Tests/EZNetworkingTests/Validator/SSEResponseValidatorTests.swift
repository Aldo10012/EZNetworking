@testable import EZNetworking
import Foundation
import Testing

// swiftlint:disable type_body_length
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

    static let statusCodeList2xx = [200, 201, 202, 203, 204, 206]
    static let statusCodeListNon2xx = [100, 300, 301, 400, 403, 404, 500, 502]
    static let invalidContentTypeList = [
        "application/json",
        "text/plain",
        "text/html",
        "application/xml"
    ]

    // MARK: - Success Cases (2xx with correct Content-Type)

    @Test("Validates 2xx status codes with text/event-stream", arguments: statusCodeList2xx)
    func validates2xxStatusCodesWithCorrectContentType(statusCode: Int) throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: statusCode,
            headers: ["Content-Type": "text/event-stream"]
        )
        #expect(throws: Never.self) {
            try validator.validateStatus(from: response)
        }
    }

    @Test("Validates 2xx status codes with text/event-stream and charset", arguments: statusCodeList2xx)
    func validates2xxStatusCodesWithCorrectContentTypeAndCharset(statusCode: Int) throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: statusCode,
            headers: ["Content-Type": "text/event-stream; charset=utf-8"]
        )
        #expect(throws: Never.self) {
            try validator.validateStatus(from: response)
        }
    }

    // MARK: - Invalid Response Type

    @Test("Throws invalidResponse for non-HTTP response")
    func throwsInvalidResponseForNonHTTP() {
        let validator = SSEResponseValidator()
        let response = makeNonHTTPResponse()

        #expect(throws: NetworkingError.serverSentEventFailed(reason: .invalidResponse)) {
            try validator.validateStatus(from: response)
        }
    }

    // MARK: - Invalid Status Code (non-2xx)

    @Test("throws for non 2xx status codes with text/event-stream", arguments: statusCodeListNon2xx)
    func throwsForNon2xxStatusCodesWithCorrectContentType(statusCode: Int) throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: statusCode,
            headers: ["Content-Type": "text/event-stream"]
        )
        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected to throw")
        } catch let NetworkingError.serverSentEventFailed(reason: reason) {
            let expectedResponse = HTTPResponse(statusCode: statusCode, headers: ["Content-Type": "text/event-stream"])
            #expect(reason == .invalidHTTPResponse(expectedResponse))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    // MARK: - Invalid Content-Type

    @Test("Validates 2xx status codes without text/event-stream", arguments: invalidContentTypeList)
    func validates2xxStatusCodesWithIncorrectContentType(contentType: String) throws {
        let validator = SSEResponseValidator()
        let response = makeMockResponse(
            statusCode: 200,
            headers: ["Content-Type": contentType]
        )
        do {
            try validator.validateStatus(from: response)
            Issue.record("Expected to throw")
        } catch let NetworkingError.serverSentEventFailed(reason: reason) {
            let expectedResponse = HTTPResponse(statusCode: 200, headers: ["Content-Type": contentType])
            #expect(reason == .invalidHTTPResponse(expectedResponse))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    // MARK: - Edge Cases

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
}

// swiftlint:enable type_body_length
