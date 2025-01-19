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
        
        let exp = XCTestExpectation()
        sut.downloadFileTask(url: testURL) { result in
            defer { exp.fulfill() }
            switch result {
            case .success(let localURL):
                XCTAssertEqual(localURL.absoluteString, "file:///tmp/test.pdf")
            case .failure:
                XCTFail()
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDownloadFileCanCancel() throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 urlResponseValidator: MockURLResponseValidator(),
                                 requestDecoder: RequestDecoder())
        
        let task = sut.downloadFileTask(url: testURL) { _ in }
        task.cancel()
        let downloadTask = try XCTUnwrap(task as? MockURLSessionDownloadTask)
        XCTAssertTrue(downloadTask.didCancel)
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
        
        let exp = XCTestExpectation()
        sut.downloadFileTask(url: testURL) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.conflict))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
