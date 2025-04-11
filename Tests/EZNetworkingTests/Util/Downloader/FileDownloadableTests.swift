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
        let validator = MockURLResponseValidator()
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, validator: validator, requestDecoder: decoder)
        
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
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.forbidden, [:]))
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, validator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            XCTFail("unexpected error")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpClientError(.forbidden, [:]))
        }
    }
    
    func testDownloadFileFailsWhenStatusCodeIsNot200() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 400),
            error: nil
        )
        let validator = ResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, validator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            XCTFail("unexpected error")
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    func testDownloadFileFailsWhenErrorIsNotNil() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.internalError(.unknown)
        )
        let validator = ResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = FileDownloader(urlSession: urlSession, validator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            XCTFail("unexpected error")
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.internalError(.unknown))
        }
    }
    
    func testDownloadFileDownloadProgressCanBeTracked() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = ResponseValidatorImpl()
        let decoder = RequestDecoder()
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        let sut = FileDownloader(urlSession: urlSession, validator: validator, requestDecoder: decoder, sessionDelegate: delegate)

        var didTrackProgress = false
        do {
            _ = try await sut.downloadFile(with: testURL, progress: { _ in
                didTrackProgress = true
            })
            XCTAssertTrue(didTrackProgress)
        } catch {
            XCTFail()
        }
    }

    // MARK: test callbacks
    
    func testDownloadFileTaskSuccess() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 validator: MockURLResponseValidator(),
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
                                 validator: MockURLResponseValidator(),
                                 requestDecoder: RequestDecoder())
        
        let task = sut.downloadFileTask(url: testURL) { _ in }
        task.cancel()
        let downloadTask = try XCTUnwrap(task as? MockURLSessionDownloadTask)
        XCTAssertTrue(downloadTask.didCancel)
    }
    
    func testDownloadFileFailsIfValidatorThrowsAnyError() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.conflict, [:]))
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 validator: validator,
                                 requestDecoder: RequestDecoder())
        
        let exp = XCTestExpectation()
        sut.downloadFileTask(url: testURL) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpClientError(.conflict, [:]))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDownloadFileTaskDownloadProgressCanBeTracked() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(
            url: testURL,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        
        let sut = FileDownloader(urlSession: urlSession,
                                 validator: MockURLResponseValidator(),
                                 requestDecoder: RequestDecoder(),
                                 sessionDelegate: delegate)
        
        let exp = XCTestExpectation()
        var didTrackProgress = false

        _ = sut.downloadFileTask(url: testURL, progress: { progress in
            didTrackProgress = true
        }) { result in
            defer { exp.fulfill() }
            switch result {
            case .success: XCTAssertTrue(true)
            case .failure: XCTFail()
            }
        }
        wait(for: [exp], timeout: 0.1)
        XCTAssertTrue(didTrackProgress)
    }

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
