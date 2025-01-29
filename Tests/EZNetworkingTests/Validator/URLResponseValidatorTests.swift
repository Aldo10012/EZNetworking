import XCTest
@testable import EZNetworking

final class URLResponseValidatorTests: XCTestCase {

    let sut = URLResponseValidatorImpl()

    // MARK: - test validate()

    func testValidateOKResponse() throws {
        XCTAssertNoThrow(try sut.validate(data: Data(), urlResponse: createUrlResponse(statusCode: 200), error: nil), "Unexpectedly threw error")
    }
    
    func testValidate300Status() throws {
        XCTAssertThrowsError(try sut.validate(data: Data(), urlResponse: createUrlResponse(statusCode: 300), error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.redirect(.multipleChoices))
        }
    }

    func testValidateErrorResponse() throws {
        XCTAssertThrowsError(try sut.validate(data: Data(), urlResponse: createUrlResponse(statusCode: 404), error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.httpClientError(.notFound))
        }
    }

    func testValidateNonHTTPURLResponse() throws {
        let response = URLResponse(url: URL(string: "https://example.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        XCTAssertThrowsError(try sut.validate(data: Data(), urlResponse: response, error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noHTTPURLResponse))
        }
    }

    func testValidateFailsWhenDataIsNil() throws {
        XCTAssertThrowsError(try sut.validate(data: nil, urlResponse: createUrlResponse(statusCode: 200), error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noData))
        }
    }

    func testValidateFailsWhenURLResponseIsNil() throws {
        XCTAssertThrowsError(try sut.validate(data: Data(), urlResponse: nil, error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noResponse))
        }
    }

    func testValidateFailsWhenErrorIsNotNil() throws {
        XCTAssertThrowsError(try sut.validate(data: Data(), urlResponse: createUrlResponse(statusCode: 200), error: NetworkingError.httpServerError(.badGateway))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.requestFailed(NetworkingError.httpServerError(.badGateway))))
        }
    }

    func testValidateFailsWhenNotConnectedToInternet() throws {
        XCTAssertThrowsError(try sut.validate(data: Data(), urlResponse: createUrlResponse(statusCode: 200), error: URLError(.notConnectedToInternet))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.urlError(URLError(.notConnectedToInternet)))
        }
    }

    // MARK: - test validateDownloadTask()

    func testValidateDownloadTaskOKResponse() throws {
        XCTAssertNoThrow(try sut.validateDownloadTask(url: url, urlResponse: createUrlResponse(statusCode: 200), error: nil), "Unexpectedly threw error")
    }

    func testValidateDownloadTaskFailsWhenUrlIsNil() throws {
        XCTAssertThrowsError(try sut.validateDownloadTask(url: nil, urlResponse: createUrlResponse(statusCode: 200), error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noURL))
        }
    }

    func testValidateDownloadTaskFailsWhenUrlResponseIsNil() throws {
        XCTAssertThrowsError(try sut.validateDownloadTask(url: url, urlResponse: nil, error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noResponse))
        }
    }

    func testValidateDownloadTaskFailsWhenErrorIsNotNil() throws {
        XCTAssertThrowsError(try sut.validateDownloadTask(url: url, urlResponse: createUrlResponse(statusCode: 200), error: NetworkingError.internalError(.unknown))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.requestFailed(NetworkingError.internalError(.unknown))))
        }
    }

    func testValidateDownloadTaskFailsWhenNotConnectedToInternet() throws {
        XCTAssertThrowsError(try sut.validateDownloadTask(url: url, urlResponse: createUrlResponse(statusCode: 200), error: URLError(.notConnectedToInternet))) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.urlError(URLError(.notConnectedToInternet)))
        }
    }

    func testValidateDownloadTaskFailsWhenResponseIsNotHTTPURLResponse() throws {
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        XCTAssertThrowsError(try sut.validateDownloadTask(url: url, urlResponse: response, error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.internalError(.noHTTPURLResponse))
        }
    }

    func testValidateDownloadTaskFailsWhenResponseStatusCodeIsNot200() throws {
        XCTAssertThrowsError(try sut.validateDownloadTask(url: url, urlResponse: createUrlResponse(statusCode: 400), error: nil)) { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.httpClientError(.badRequest))
        }
    }
}

// MARK: - Test Helpers

extension URLResponseValidatorTests {
    func createUrlResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    var url: URL {
        return URL(string: "https://example.com")!
    }
}
