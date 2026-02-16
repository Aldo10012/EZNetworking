@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLResponseValidator")
final class URLResponseValidatorTests {
    let sut = DefaultResponseValidator()

    private struct SomeUnknownError: Error {}

    // MARK: - test validateStatus()

    @Test("test validateStatus givenURLResponse Throws")
    func validateStatus_givenURLResponse_Throws() throws {
        #expect(throws: NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse).self) {
            try sut.validateStatus(from: URLResponse())
        }
    }

    // MARK: 1xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode100 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode100_Throws() throws {
        #expect(throws: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 100))).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 100))
        }
    }

    // MARK: 2xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode200 NoThrow")
    func validateStatus_givenHTTPURLResponseStatusCode200_NoThrow() throws {
        #expect(throws: Never.self) { try sut.validateStatus(from: createHttpUrlResponse(statusCode: 200)) }
    }

    // MARK: 3xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode300 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode300_Throws() throws {
        #expect(throws: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 300))).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 300))
        }
    }

    @Test("test validateStatus givenHTTPURLResponseStatusCode304 does not Throws")
    func validateStatus_givenHTTPURLResponseStatusCode304_NoThrows() throws {
        #expect(throws: Never.self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 304))
        }
    }

    // MARK: 4xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode400 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode400_Throws() throws {
        #expect(throws: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 400))).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 400))
        }
    }

    // MARK: 5xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode500 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode500_Throws() throws {
        #expect(throws: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 500))).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 500))
        }
    }

    // MARK: headerFields

    @Test("test HTTPResponse.headerFields")
    func validateHTTPResponseHeaderFields() {
        do {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 400, headerFields: ["foo": "bar"]))
        } catch let NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: response)) {
            #expect(response.headers == ["foo": "bar"])
        } catch {
            Issue.record("Expected NetworkingError.responseValidationFailed")
        }
    }

    // MARK: expected headers

    @Test("test validate passes when not expecting any HTTPHeaders and receives no headers")
    func validatePassesWhenNotExpectingAnyHTTPHeadersAndReceivesNoHeaders() {
        let validator = DefaultResponseValidator(expectedHttpHeaders: nil)
        #expect(throws: Never.self) {
            try validator.validateStatus(from: createHttpUrlResponse(statusCode: 200, headerFields: nil))
        }
    }

    @Test("test validate passes when not expecting any HTTPHeaders and receives headers")
    func validatePassesWhenNotExpectingAnyHTTPHeadersAndReceivesHeaders() {
        let validator = DefaultResponseValidator(expectedHttpHeaders: nil)
        #expect(throws: Never.self) {
            try validator.validateStatus(from: createHttpUrlResponse(statusCode: 200, headerFields: ["Content-Type": "application/json"]))
        }
    }

    @Test("test validate throws when expecting HTTPHeaders and receives no headers")
    func validateThrowsWhenExpectingHTTPHeadersAndReceivesNoHeaders() {
        let validator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.json)])
        #expect(throws: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 200, headers: [:])))) {
            try validator.validateStatus(from: createHttpUrlResponse(statusCode: 200, headerFields: nil))
        }
    }

    @Test("test validate passes when expecting HTTPHeaders and receives same headers")
    func validatePassesWhenExpectingHTTPHeadersAndReceivesSameHeaders() {
        let validator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.json)])
        #expect(throws: Never.self) {
            try validator.validateStatus(from: createHttpUrlResponse(statusCode: 200, headerFields: ["Content-Type": "application/json"]))
        }
    }

    @Test("test validate throws when expecting HTTPHeaders and receives different headers")
    func validateThrowsWhenExpectingHTTPHeadersAndReceivesDifferentHeaders() {
        let validator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.plain)])
        #expect(throws: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 200, headers: ["Content-Type": "application/json"])))) {
            try validator.validateStatus(from: createHttpUrlResponse(statusCode: 200, headerFields: ["Content-Type": "application/json"]))
        }
    }

}

// MARK: - Test Helpers

extension URLResponseValidatorTests {
    func createHttpUrlResponse(statusCode: Int, headerFields: [String: String]? = nil) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)!
    }

    var url: URL {
        URL(string: "https://example.com")!
    }
}
