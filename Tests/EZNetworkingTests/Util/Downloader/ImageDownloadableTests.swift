@testable import EZNetworking
import Testing
import UIKit

@Suite("Test ImageDownloadable")
final class ImageDownloadableTests {
    
    private var imageUrlString: String {
        "https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_square.jpg"
    }
    
    // MARK: test Async/Await
    
    @Test("test DownloadImage Success")
    func testDownloadImageSuccess() async throws {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: Data(),
                                        url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = SpyImageDownloader(urlSession: urlSession)
        do {
            _ = try await sut.downloadImage(from: testURL)
            #expect(true)
        } catch {
            Issue.record()
        }
    }

    @Test("test DownloadImage Fails")
    func testDownloadImageFails() async throws {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: Data(),
                                        url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.badRequest, [:]))
        let sut = ImageDownloader(urlSession: urlSession,
                                  validator: validator,
                                  requestDecoder: RequestDecoder())
        do {
            _ = try await sut.downloadImage(from: testURL)
            Issue.record()
        } catch let error as NetworkingError {
            #expect(error == NetworkingError.httpClientError(.badRequest, [:]))
        }
    }

    // MARK: - test callbacks

    @Test("test DownloadImageTask Success 1")
    func testDownloadImageTaskSuccess() {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: Data(),
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator()
        let sut = ImageDownloader(urlSession: urlSession, validator: validator)

        var didExecute = false
        sut.downloadImageTask(url: testURL) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                #expect(true)
            case .failure(let error):
                if error == NetworkingError.internalError(.invalidImageData) {
                    #expect(true)
                } else {
                    Issue.record()
                }
            }
        }
        #expect(didExecute)
    }
    
    @Test("test DownloadImageTask Can Cancel")
    func testDownloadImageTaskCanCancel() throws {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: Data(),
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator()
        let sut = ImageDownloader(urlSession: urlSession, validator: validator)

        let task = sut.downloadImageTask(url: testURL) { _ in }
        task.cancel()
        let dataTask = try #require(task as? MockURLSessionDataTask)
        #expect(dataTask.didCancel)
    }

    @Test("test DownloadImageTask Fails When Validator Throws Any Error")
    func testDownloadImageTaskFailsWhenValidatorThrowsAnyError() {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.conflict, [:]))
        let sut = ImageDownloader(urlSession: urlSession,
                                  validator: validator,
                                  requestDecoder: RequestDecoder())

        var didExecute = false
        sut.downloadImageTask(url: testURL) { result in
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

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: imageUrlString)!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}

private class SpyImageDownloader: ImageDownloader {
    override func getImage(from data: Data) throws -> UIImage {
        return UIImage(systemName: "circle")!
    }
}
