@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLResponseValidator")
final class URLResponseValidatorTests {
    let sut = ResponseValidatorImpl()

    private struct SomeUnknownError: Error {}

    // MARK: - test validateStatus()

    @Test("test validateStatus givenURLResponse Throws")
    func validateStatus_givenURLResponse_Throws() throws {
        #expect(throws: NetworkingError.internalError(.noHTTPURLResponse).self) {
            try sut.validateStatus(from: URLResponse())
        }
    }

    // MARK: 1xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode100 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode100_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 100)).self) {
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
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 300)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 300))
        }
    }

    // MARK: 4xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode400 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode400_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 400)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 400))
        }
    }

    // MARK: 5xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode500 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode500_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 500)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 500))
        }
    }
}

// MARK: - Test Helpers

extension URLResponseValidatorTests {
    func createHttpUrlResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    var url: URL {
        URL(string: "https://example.com")!
    }
}
