import XCTest
@testable import EZNetworking

final class URLResponseValidatorTests: XCTestCase {

    let sut = ResponseValidatorImpl()
    
    private struct SomeUnknownError: Error {}

    // MARK: - test validateNoError()
    
    func test_validateNoError_givenNilError_NoThrow() throws {
        XCTAssertNoThrow(try sut.validateNoError(nil))
    }
    
    func test_validateNoError_givenURLError_Throws() throws {
        XCTAssertThrowsError(try sut.validateNoError(URLError(.notConnectedToInternet))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.urlError(URLError(.notConnectedToInternet)))
        }
    }
    
    func test_validateNoError_givenClientError_Throws() throws {
        XCTAssertThrowsError(try sut.validateNoError(SomeUnknownError())) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.requestFailed(SomeUnknownError())))
        }
    }
    
    // MARK: - test validateData()

    func test_validateData_givenData_NoThrow() throws {
        XCTAssertNoThrow(try sut.validateData(MockData.mockPersonJsonData))
    }
    
    func test_validateData_givenNilData_Throws() throws {
        XCTAssertThrowsError(try sut.validateData(nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noData))
        }
    }
    
    // MARK: - test validateUrl()
    
    func test_validateUrl_givenData_NoThrow() throws {
        XCTAssertNoThrow(try sut.validateUrl(URL(string: "https://www.example.com")!))
    }
    
    func test_validateUrl_givenNilData_Throws() throws {
        XCTAssertThrowsError(try sut.validateUrl(nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noURL))
        }
    }
    
    // MARK: - test validateStatus()
    
    func test_validateStatus_givenNilResponse_Throws() throws {
        XCTAssertThrowsError(try sut.validateStatus(from: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noResponse))
        }
    }

    func test_validateStatus_givenURLResponse_Throws() throws {
        XCTAssertThrowsError(try sut.validateStatus(from: URLResponse())) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noHTTPURLResponse))
        }
    }
    
    // MARK: 1xx status code
    
    func test_validateStatus_givenHTTPURLResponseStatusCode100_Throws() throws {
        XCTAssertThrowsError(try sut.validateStatus(from: createHttpUrlResponse(statusCode: 100))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.information(.continueStatus, [:]))
        }
    }
    
    // MARK: 2xx status code
    
    func test_validateStatus_givenHTTPURLResponseStatusCode200_NoThrow() throws {
        XCTAssertNoThrow(try sut.validateStatus(from: createHttpUrlResponse(statusCode: 200)))
    }
    
    // MARK: 3xx status code

    func test_validateStatus_givenHTTPURLResponseStatusCode300_Throws() throws {
        XCTAssertThrowsError(try sut.validateStatus(from: createHttpUrlResponse(statusCode: 300))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.redirect(.multipleChoices, [:]))
        }
    }
    
    func test_validateStatus_givenHTTPURLResponseStatusCode304_NoThrow() throws {
        XCTAssertNoThrow(try sut.validateStatus(from: createHttpUrlResponse(statusCode: 304)))
    }
    
    // MARK: 4xx status code

    func test_validateStatus_givenHTTPURLResponseStatusCode400_Throws() throws {
        XCTAssertThrowsError(try sut.validateStatus(from: createHttpUrlResponse(statusCode: 400))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    // MARK: 5xx status code
    
    func test_validateStatus_givenHTTPURLResponseStatusCode500_Throws() throws {
        XCTAssertThrowsError(try sut.validateStatus(from: createHttpUrlResponse(statusCode: 500))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.httpServerError(.internalServerError, [:]))
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
