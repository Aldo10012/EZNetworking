import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable async await")
final class FileDownloadable_AsyncAwait_Tests {

    // MARK: SUCCESS

    @Test("test .downloadFile() Success")
    func testDownloadFileSuccess() async throws {
        let sut = createFileDownloader()
        
        do {
            let localURL = try await sut.downloadFile(with: testURL)
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
        } catch {
            Issue.record()
        }
    }
    
    // MARK: ERROR - status code

    @Test("test .downloadFile() Fails When StatusCode Is Not 200")
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

    // MARK: ERROR - validation

    @Test("test .downloadFile() Fails When Validator Throws AnyError")
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
    
    // MARK: ERROR - urlSession
    
    @Test("test .downloadFile() Fails When urlSession Error Is Not Nil")
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

    // MARK: Tracking

    @Test("test .downloadFile() Download Progress Can Be Tracked")
    func testDownloadFileDownloadProgressCanBeTracked() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didTrackProgress = false
        
        do {
            _ = try await sut.downloadFile(with: testURL, progress: { value in
                didTrackProgress = true
            })
            #expect(didTrackProgress)
        } catch {
            Issue.record()
        }
    }

    @Test("test .downloadFile() Download Progress Tracking Happens Before Return")
    func testDownloadFileDownloadProgressTrackingHapensBeforeReturn() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didTrackProgressBeforeReturn: Bool? = nil
        
        do {
            _ = try await sut.downloadFile(with: testURL, progress: { value in
                if didTrackProgressBeforeReturn == nil {
                    didTrackProgressBeforeReturn = true
                }
            })
            
            if didTrackProgressBeforeReturn == nil {
                didTrackProgressBeforeReturn = false
            }
            
            #expect(didTrackProgressBeforeReturn == true)
        } catch {
            Issue.record()
        }
    }

    @Test("test .downloadFile() Download Progress Tracking Order")
    func testDownloadFileDownloadProgressTrackingOrder() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]
        
        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var capturedTracking = [Double]()
        
        do {
            _ = try await sut.downloadFile(with: testURL, progress: { value in
                capturedTracking.append(value)
            })
            #expect(capturedTracking.count == 4)
            #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
        } catch {
            Issue.record()
        }
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
    url: URL = testURL,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockURLSession {
    return MockURLSession(
        url: url,
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
