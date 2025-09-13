import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable call backs")
final class FileDownloadable_CallBacks_Tests {

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
