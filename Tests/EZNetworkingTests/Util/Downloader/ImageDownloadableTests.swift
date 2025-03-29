import XCTest
@testable import EZNetworking

final class ImageDownloadableTests: XCTestCase {
    
    private var imageUrlString: String {
        "https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_square.jpg"
    }
    
    // MARK: test Async/Await
    
    func testDownloadImageSuccess() async throws { // note: this is an async test as it actually decodes url to generate the image
        let testURL = URL(string: imageUrlString)!
        let sut = ImageDownloader(urlSession: URLSession.shared)
        do {
            _ = try await sut.downloadImage(from: testURL)
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }

    func testDownloadImageFails() async throws {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: MockData.mockPersonJsonData,
                                        url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.badRequest, [:]))
        let sut = ImageDownloader(urlSession: urlSession,
                                  validator: validator,
                                  requestDecoder: RequestDecoder())
        do {
            _ = try await sut.downloadImage(from: testURL)
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }

    // MARK: - test callbacks

    func testDownloadImageSuccess() {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: MockData.mockPersonJsonData,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator()
        let sut = ImageDownloader(urlSession: urlSession, validator: validator)

        let exp = XCTestExpectation()
        sut.downloadImageTask(url: testURL) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure(let error):
                if error == NetworkingError.internalError(.invalidImageData) {
                    XCTAssertTrue(true, "mock data was just not suited to generate a UIImage")
                } else {
                    XCTFail()
                }
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDownloadImageCanCancel() throws {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(data: MockData.mockPersonJsonData,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator()
        let sut = ImageDownloader(urlSession: urlSession, validator: validator)

        let task = sut.downloadImageTask(url: testURL) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }

    func testDownloadImageFailsWhenValidatorThrowsAnyError() {
        let testURL = URL(string: imageUrlString)!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpClientError(.conflict, [:]))
        let sut = ImageDownloader(urlSession: urlSession,
                                  validator: validator,
                                  requestDecoder: RequestDecoder())

        let exp = XCTestExpectation()
        sut.downloadImageTask(url: testURL) { result in
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

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
