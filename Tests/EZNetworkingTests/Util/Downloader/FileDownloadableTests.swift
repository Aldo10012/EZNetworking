@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable")
final class FileDownloadableTests {

    // MARK: test Async/Await

    @Test("test DownloadFile Success")
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
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
        } catch {
            Issue.record()
        }
    }
    
    @Test("test DownloadFile Fails When Validator Throws AnyError")
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
            Issue.record("unexpected error")
        } catch let error as NetworkingError {
            #expect(error == NetworkingError.httpClientError(.forbidden, [:]))
        }
    }
    
    @Test("test DownloadFile Fails When StatusCode Is Not 200")
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
            Issue.record("unexpected error")
        } catch let error as NetworkingError{
            #expect(error == NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    @Test("test DownloadFile Fails When Error Is Not Nil")
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
            Issue.record("unexpected error")
        } catch let error as NetworkingError{
            #expect(error == NetworkingError.internalError(.unknown))
        }
    }
    
    @Test("test DownloadFile Download Progress Can Be Tracked")
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
            #expect(didTrackProgress)
        } catch {
            Issue.record()
        }
    }

    // MARK: test callbacks
    
    @Test("test DownloadFile Task Success")
    func testDownloadFileTaskSuccess() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 validator: MockURLResponseValidator(),
                                 requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadFileTask(url: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success(let localURL):
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            case .failure:
                Issue.record()
            }
        }
        #expect(didExecute)
    }
    
    @Test("test DownloadFile Can Cancel")
    func testDownloadFileCanCancel() throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 validator: MockURLResponseValidator(),
                                 requestDecoder: RequestDecoder())
        
        let task = sut.downloadFileTask(url: testURL, progress: nil) { _ in }
        task.cancel()
        let downloadTask = try #require(task as? MockURLSessionDownloadTask)
        #expect(downloadTask.didCancel)
    }
    
    @Test("test DownloadFile Fails If Validator Throws Any Error")
    func testDownloadFileFailsIfValidatorThrowsAnyError() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.conflict, [:]))
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = FileDownloader(urlSession: urlSession,
                                 validator: validator,
                                 requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadFileTask(url: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpClientError(.conflict, [:]))
            }
        }
        #expect(didExecute)
    }
    
    @Test("test DownloadFile Task Download Progress Can Be Tracked")
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
        
        var didExecute = false
        var didTrackProgress = false

        _ = sut.downloadFileTask(url: testURL, progress: { progress in
            didTrackProgress = true
        }) { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        }
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
