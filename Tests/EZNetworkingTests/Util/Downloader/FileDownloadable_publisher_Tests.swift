import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable publishers")
final class FileDownloadable_publisher_Tests {

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
