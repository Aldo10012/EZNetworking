import XCTest
@testable import EZNetworking

final class URLResponseValidatorTests: XCTestCase {
    
    // MARK: - test validate()

    func testValidateOKResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        do {
            _ = try validator.validate(data: Data(), urlResponse: response, error: nil)
            XCTAssert(true)
        } catch {
            XCTFail("Unexpected error)")
        }
    }
    
    func testValidateErrorResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validate(data: Data(), urlResponse: response, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.notFound)
        }
    }
    
    func testValidateNonHTTPURLResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = URLResponse(url: URL(string: "https://example.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        
        do {
            _ = try validator.validate(data: Data(), urlResponse: response, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noHTTPURLResponse)
        }
    }
    
    func testValidateFailsWhenDataIsNil() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validate(data: nil, urlResponse: response, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noData)
        }
    }
    
    func testValidateFailsWhenURLResponseIsNil() throws {
        let validator = URLResponseValidatorImpl()
        do {
            _ = try validator.validate(data: Data(), urlResponse: nil, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noResponse)
        }
    }
    
    func testValidateFailsWhenErrorIsNotNil() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validate(data: Data(), urlResponse: response, error: NetworkingError.badGateway)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.requestFailed(NetworkingError.badGateway))
        }
    }
    
    func testValidateFailsWhenNotConnectedToInternet() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validate(data: Data(), urlResponse: response, error:  URLError(.notConnectedToInternet))
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.requestFailed(URLError(.notConnectedToInternet)))
        }
    }

    // MARK: - test validateDownloadTask()

    func testValidateDownloadTaskOKResponse() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validateDownloadTask(url: url, urlResponse: response, error: nil)
            XCTAssertTrue(true)
        } catch let error as NetworkingError {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testValidateDownloadTaskFailsWhenUrlIsNil() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validateDownloadTask(url: nil, urlResponse: response, error: nil)
            XCTFail("Unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noURL)
        }
    }
    
    func testValidateDownloadTaskFailsWhenUrlResponseIsNil() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        
        do {
            _ = try validator.validateDownloadTask(url: url, urlResponse: nil, error: nil)
            XCTFail("Unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noResponse)
        }
    }
    
    func testValidateDownloadTaskFailsWhenErrorIsNotNil() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validateDownloadTask(url: url, urlResponse: response, error: NetworkingError.unknown)
            XCTFail("Unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.requestFailed(NetworkingError.unknown))
        }
    }
    
    func testValidateDownloadTaskFailsWhenNotConnectedToInternet() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validateDownloadTask(url: url, urlResponse: response, error: URLError(.notConnectedToInternet))
            XCTFail("Unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.requestFailed(URLError(.notConnectedToInternet)))
        }
    }
    
    func testValidateDownloadTaskFailsWhenResposneIsNotHTTPURLResponse() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        do {
            _ = try validator.validateDownloadTask(url: url, urlResponse: response, error: nil)
            XCTFail("Unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noHTTPURLResponse)
        }
    }
    
    func testValidateDownloadTaskFailsWhenResponseStatusCodeIsNot200() throws {
        let validator = URLResponseValidatorImpl()
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!
        
        do {
            _ = try validator.validateDownloadTask(url: url, urlResponse: response, error: nil)
            XCTFail("Unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.badRequest)
        }
    }
}
