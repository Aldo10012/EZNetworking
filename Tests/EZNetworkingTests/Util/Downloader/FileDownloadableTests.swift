import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable")
final class FileDownloadableTests {
    
    // MARK: test Async/Await
    
    @Test("test DownloadFile Success")
    func testDownloadFileSuccess() async throws {
        let sut = createFileDownloader()
        
        do {
            let localURL = try await sut.downloadFile(with: testURL)
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
        } catch {
            Issue.record()
        }
    }
    
    @Test("test DownloadFile Fails When Validator Throws AnyError")
    func testDownloadFileFailsWhenValidatorThrowsAnyError() async throws {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.noData))
        )
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            Issue.record("unexpected error")
        } catch let error as NetworkingError {
            #expect(error == NetworkingError.internalError(.noData))
        }
    }
    
    @Test("test DownloadFile Fails When StatusCode Is Not 200")
    func testDownloadFileFailsWhenStatusCodeIsNot200() async throws {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(statusCode: 400),
            validator: ResponseValidatorImpl()
        )
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            Issue.record("unexpected error")
        } catch let error as NetworkingError{
            #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
        }
    }
    
    @Test("test DownloadFile Fails When Error Is Not Nil")
    func testDownloadFileFailsWhenErrorIsNotNil() async throws {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(error: NetworkingError.internalError(.unknown))
        )
        
        do {
            _ = try await sut.downloadFile(with: testURL)
            Issue.record("unexpected error")
        } catch let error as NetworkingError{
            #expect(error == NetworkingError.internalError(.requestFailed(NetworkingError.internalError(.unknown))))
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
        let sut = createFileDownloader()
        
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
        let sut = createFileDownloader()
        
        let task = sut.downloadFileTask(url: testURL, progress: nil) { _ in }
        task.cancel()
        let downloadTask = try #require(task as? MockURLSessionDownloadTask)
        #expect(downloadTask.didCancel)
    }
    
    @Test("test DownloadFile Fails If Validator Throws Any Error")
    func testDownloadFileFailsIfValidatorThrowsAnyError() {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.noData))
        )
        
        var didExecute = false
        sut.downloadFileTask(url: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.internalError(.noData))
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

    // MARK: test publisher
    private var cancellables = Set<AnyCancellable>()

    @Test("test DownloadFile Task Success")
    func testDownloadFilePublisherSuccess() {
        let sut = createFileDownloader()
        
        var didExecute = false
        sut.downloadPublisher(url: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { localURL in
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
                didExecute = true
            }
            .store(in: &cancellables)

        #expect(didExecute)
    }
    
    @Test("test DownloadFile Fails If Validator Throws Any Error")
    func testDownloadFilePublisherFailsIfValidatorThrowsAnyError() {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.noData))
        )
        
        var didExecute = false
        sut.downloadPublisher(url: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    #expect(error == NetworkingError.internalError(.noData))
                    didExecute = true
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        #expect(didExecute)
    }
    
    @Test("test DownloadFile Task Download Progress Can Be Tracked")
    func testDownloadFilePublisherTaskDownloadProgressCanBeTracked() {
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
    
        sut.downloadPublisher(url: testURL) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { localURL in
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            didExecute = true
        }
        .store(in: &cancellables)

        #expect(didExecute)
        #expect(didTrackProgress)
    }
}

// MARK: helpers

private let testURL = URL(string: "https://example.com/example.pdf")!

private func createFileDownloader(
    urlSession: URLSessionTaskProtocol = createMockURLSession(statusCode: 200),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> FileDownloader {
    return FileDownloader(
        urlSession: urlSession,
        validator: validator,
        requestDecoder: requestDecoder
    )
}

private func createMockURLSession(
    data: Data? = MockData.mockPersonJsonData,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockURLSession {
    return MockURLSession(
        url: testURL,
        urlResponse: buildResponse(statusCode: statusCode),
        error: error
    )
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "https://example.com")!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil)!
}
