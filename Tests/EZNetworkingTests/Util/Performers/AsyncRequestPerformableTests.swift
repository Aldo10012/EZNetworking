import XCTest
@testable import EZNetworking

final class AsyncRequestPerformableTests: XCTestCase {
    
    // MARK: Unit test for perform request with Async Await and Request protocol and return Decodable

    func test_PerformAsync_Success() async throws {
        let sut = createAsyncRequestPerformer()
        let person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        XCTAssertEqual(person.name, "John")
        XCTAssertEqual(person.age, 30)
    }
    
    func test_PerformAsync_StatusCode300_Success() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.redirect(.multipleChoices, [:]))
        }
    }
    
    func test_PerformAsync_StatusCode200_WhenCachStrategyIsNetworkOnly_Success() async throws {
        let request = MockRequest(cacheStrategy: .networkOnly)
        let etagManager = MockETagManager()
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 200),
            etagManager: etagManager
        )
        
        _ = try await sut.perform(request: request, decodeTo: Person.self)
        
        XCTAssertFalse(etagManager.didGetETag)
        XCTAssertFalse(etagManager.didUpdateETag)
    }
    
    func test_PerformAsync_StatusCode200_WhenCachStrategyIsValidateWithETag_Success() async throws {
        let request = MockRequest(cacheStrategy: .validateWithETag)
        let etagManager = MockETagManager()
        let cacheManager = MockURLCacheManager()
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 200),
            cacheManager: cacheManager,
            etagManager: etagManager
        )
        
        _ = try await sut.perform(request: request, decodeTo: Person.self)
        
        XCTAssertTrue(etagManager.didGetETag)
        XCTAssertTrue(etagManager.didUpdateETag)
        XCTAssertFalse(cacheManager.didGetCachedResponse)
    }
    
    func test_PerformAsync_StatusCode304_WhenCachStrategyIsValidateWithETag_Success() async throws {
        let request = MockRequest(cacheStrategy: .validateWithETag)
        let cacheManager = MockURLCacheManager()
        let etagManager = MockETagManager()
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 304),
            cacheManager: cacheManager,
            etagManager: etagManager
        )
        _ = try await sut.perform(request: request, decodeTo: Person.self)
        
        XCTAssertTrue(etagManager.didGetETag)
        XCTAssertFalse(etagManager.didUpdateETag)
        XCTAssertTrue(cacheManager.didGetCachedResponse)
    }
    
    func test_PerformAsync_WhenStatusCodeIsNot200_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    func test_PerformAsync_WhenThereIsError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.badRequest, [:]))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    func test_PerformAsync_WhenThereIsHTTPError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.forbidden, [:]))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.forbidden, [:]))
        }
    }
    
    func test_PerformAsync_WhenThereIsURLError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    func test_PerformAsync_WhenDataCannotBeDecodedToType_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.internalError(.couldNotParse))
        }
    }
    
    func test_PerformAsync_WhenDataIsNil_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.internalError(.unknown))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request Protocol and return Decodable

    func test_PerformAsync_WithoutResponse_Success() async throws {
        let sut = createAsyncRequestPerformer()
        await XCTAssertNoThrowAsync(try await sut.perform(request: MockRequest()))
    }
    
    func test_PerformAsync_WithoutResponse_WhenStatusCode300_Success() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.redirect(.multipleChoices, [:]))
        }    }
    
    func test_PerformAsync_WithoutResponse_WhenStatusCodeIsNot200_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenThereIsError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.badRequest, [:]))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest, [:]))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenThereIsHTTPError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.forbidden, [:]))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.forbidden, [:]))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenThereIsURLError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenDataCannotBeDecodedToTypeEvenThoughDataWillNotBeDecoded_Succeeds() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData)
        )
        _ = try await sut.perform(request: MockRequest())
    }
    
    func test_PerformAsync_WithoutResponse_WhenDataIsNil_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.internalError(.unknown))
        }
    }
}

private func createAsyncRequestPerformer(
    urlSession: URLSessionTaskProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder(),
    cacheManager: URLCacheManager = MockURLCacheManager(),
    etagManager: ETagManager = MockETagManager()
) -> AsyncRequestPerformer {
    return AsyncRequestPerformer(urlSession: urlSession, validator: validator, requestDecoder: requestDecoder, cacheManager: cacheManager, etagManager: etagManager)
}

private func createMockURLSession(
    data: Data? = mockPersonJsonData,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockURLSession {
    return MockURLSession(
        data: data,
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

private struct MockRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: Data? { nil }
    var cacheStrategy: CacheStrategy = .networkOnly
    var additionalHeaders: [HTTPHeader]?
}

private struct MockRequestWithNilBuild: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: Data? { nil }
    var urlRequest: URLRequest? { nil }
    var additionalHeaders: [HTTPHeader]?
}

private class MockURLCacheManager: URLCacheManager {
    func clearAllCache() { }
    func clearCache(for request: URLRequest) { }
    
    var didGetCachedResponse = false
    func getCachedResponse(for request: URLRequest) throws -> CachedURLResponse {
        didGetCachedResponse = true
        return CachedURLResponse(response: buildResponse(statusCode: 304),
                                 data: mockPersonJsonData)
    }
}

private class MockETagManager: ETagManager {
    func addETagHeader(to request: URLRequest, for key: String) -> URLRequest {
        return URLRequest(url: URL(string: "https://www.example.com")!)
    }
    
    var didUpdateETag = false
    func updateETag(from response: URLResponseHeaders, for key: String) {
        didUpdateETag = true
    }
    
    func setETag(_ etag: String, for key: String) {}
    
    var didGetETag = false
    func getETag(for key: String) -> String? {
        didGetETag = true
        return "some_etag"
    }
    
    func removeETag(for key: String) {}
    func clearAllETags() {}
}
