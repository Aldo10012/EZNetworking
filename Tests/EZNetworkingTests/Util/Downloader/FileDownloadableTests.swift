import XCTest
@testable import EZNetworking

final class FileDownloadableTests: XCTestCase {

    // MARK: test Async/Await

    func testDownloadFileSuccess() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            let localURL = try await sut.downloadFile(with: testURL)
            XCTAssertEqual(localURL.absoluteString, "file:///tmp/test.pdf")
        } catch {
            XCTFail()
        }
    }
    
    func testDownloadFileFailsWhenValidatorThrowsAnyError() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            XCTFail("unexpected error")
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testDownloadFileFailsWhenStatusCodeIsNot200() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 400),
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            XCTFail("unexpected error")
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testDownloadFileFailsWhenErrorIsNotNil() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.unknown
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            XCTFail("unexpected error")
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.unknown)
        }
    }
    
    // MARK: test callbacks
    
    func testDownloadFileSuccess() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 urlResponseValidator: MockURLResponseValidator(),
                                 requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadFileTask(url: testURL) { result in
            didExecute = true
            switch result {
            case .success(let localURL):
                XCTAssertEqual(localURL.absoluteString, "file:///tmp/test.pdf")
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testDownloadFileFailsIfValidatorThrowsAnyError() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.conflict))
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 urlResponseValidator: validator,
                                 requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadFileTask(url: testURL) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.conflict))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
