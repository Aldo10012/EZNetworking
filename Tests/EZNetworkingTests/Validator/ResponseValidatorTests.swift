@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLResponseValidator")
final class URLResponseValidatorTests {

    let sut = ResponseValidatorImpl()
    
    private struct SomeUnknownError: Error {}

    // MARK: - test validateNoError()
    
    @Test("test validateNoError givenNilError NoThrow")
    func test_validateNoError_givenNilError_NoThrow() throws {
        #expect(throws: Never.self) { try sut.validateNoError(nil) }
    }
    
    @Test("test validateNoError givenURLError Throws")
    func test_validateNoError_givenURLError_Throws() throws {
        #expect(throws: NetworkingError.urlError(URLError(.notConnectedToInternet)).self) {
            try sut.validateNoError(URLError(.notConnectedToInternet))
        }
    }
    
    @Test("test validateNoError givenClientError Throws")
    func test_validateNoError_givenClientError_Throws() throws {
        #expect(throws: NetworkingError.internalError(.requestFailed(SomeUnknownError())).self) {
            try sut.validateNoError(SomeUnknownError())
        }
    }
    
    // MARK: - test validateData()

    @Test("test validateData givenData NoThrow")
    func test_validateData_givenData_NoThrow() throws {
        #expect(throws: Never.self) { try sut.validateData(MockData.mockPersonJsonData) }
    }
    
    @Test("test validateData givenNilData Throws")
    func test_validateData_givenNilData_Throws() throws {
        #expect(throws: NetworkingError.internalError(.noData).self) {
            try sut.validateData(nil)
        }
    }
    
    // MARK: - test validateUrl()
    
    @Test("test validateUrl givenData NoThrow")
    func test_validateUrl_givenData_NoThrow() throws {
        #expect(throws: Never.self) { try sut.validateUrl(URL(string: "https://www.example.com")!) }
    }
    
    @Test("test validateUrl givenNilData Throws")
    func test_validateUrl_givenNilData_Throws() throws {
        #expect(throws: NetworkingError.internalError(.noURL).self) {
            try sut.validateUrl(nil)
        }
    }
    
    // MARK: - test validateStatus()
    
    @Test("test validateStatus givenNilResponse Throws")
    func test_validateStatus_givenNilResponse_Throws() throws {
        #expect(throws: NetworkingError.internalError(.noResponse).self) {
            try sut.validateStatus(from: nil)
        }
    }

    @Test("test validateStatus givenURLResponse Throws")
    func test_validateStatus_givenURLResponse_Throws() throws {
        #expect(throws: NetworkingError.internalError(.noHTTPURLResponse).self) {
            try sut.validateStatus(from: URLResponse())
        }
    }
    
    // MARK: 1xx status code
    
    @Test("test validateStatus givenHTTPURLResponseStatusCode100 Throws")
    func test_validateStatus_givenHTTPURLResponseStatusCode100_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 100)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 100))
        }
    }
    
    // MARK: 2xx status code
    
    @Test("test validateStatus givenHTTPURLResponseStatusCode200 NoThrow")
    func test_validateStatus_givenHTTPURLResponseStatusCode200_NoThrow() throws {
        #expect(throws: Never.self) { try sut.validateStatus(from: createHttpUrlResponse(statusCode: 200)) }
    }
    
    // MARK: 3xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode300 Throws")
    func test_validateStatus_givenHTTPURLResponseStatusCode300_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 300)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 300))
        }
    }
    
    // MARK: 4xx status code

    @Test("test validateStatus givenHTTPURLResponseStatusCode400 Throws")
    func test_validateStatus_givenHTTPURLResponseStatusCode400_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 400)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 400))
        }
    }
    
    // MARK: 5xx status code
    
    @Test("test validateStatus givenHTTPURLResponseStatusCode500 Throws")
    func test_validateStatus_givenHTTPURLResponseStatusCode500_Throws() throws {
        #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 500)).self) {
            try sut.validateStatus(from: createHttpUrlResponse(statusCode: 500))
        }
    }
}

// MARK: - Test Helpers

extension URLResponseValidatorTests {
    func createHttpUrlResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    var url: URL {
        return URL(string: "https://example.com")!
    }
}
