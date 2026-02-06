@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLResponseValidator")
final class URLResponseValidatorTests {
    let sut = ResponseValidatorImpl()

    private struct SomeUnknownError: Error {}

    // MARK: 1xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode100 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode100_Throws() throws {
        do {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 100))
            Issue.record("Unexpected success")
        } catch let error as NetworkingError {
            if case .responseValidationFailure(reason: .badHTTPResponse(underlying: let httpError)) = error {
                #expect(httpError.statusCode == 100)
            } else {
                Issue.record("Expected .responseValidationFailure(reason: .badHTTPResponse(_))")
            }
        } catch {
            Issue.record("Expected Networking Error")
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
        do {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 300))
            Issue.record("Unexpected success")
        } catch let error as NetworkingError {
            if case .responseValidationFailure(reason: .badHTTPResponse(underlying: let httpError)) = error {
                #expect(httpError.statusCode == 300)
            } else {
                Issue.record("Expected .responseValidationFailure(reason: .badHTTPResponse(_))")
            }
        } catch {
            Issue.record("Expected Networking Error")
        }
    }

    // MARK: 4xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode400 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode400_Throws() throws {
        do {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 400))
            Issue.record("Unexpected success")
        } catch let error as NetworkingError {
            if case .responseValidationFailure(reason: .badHTTPResponse(underlying: let httpError)) = error {
                #expect(httpError.statusCode == 400)
            } else {
                Issue.record("Expected .responseValidationFailure(reason: .badHTTPResponse(_))")
            }
        } catch {
            Issue.record("Expected Networking Error")
        }
    }

    // MARK: 5xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode500 Throws")
    func validateStatus_givenHTTPURLResponseStatusCode500_Throws() throws {
        do {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 500))
            Issue.record("Unexpected success")
        } catch let error as NetworkingError {
            if case .responseValidationFailure(reason: .badHTTPResponse(underlying: let httpError)) = error {
                #expect(httpError.statusCode == 500)
            } else {
                Issue.record("Expected .responseValidationFailure(reason: .badHTTPResponse(_))")
            }
        } catch {
            Issue.record("Expected Networking Error")
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
