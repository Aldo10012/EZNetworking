@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformer with RetryPolicy")
struct RequestPerformerWithRetryPolicyTests {
    @Test("test perform(request:_) attempts only once if retryPolicy is .none")
    func performsOnlyOnceIfRetryPolicyIsNone() async throws {
        let mockSession = createMockURLSession(error: URLError(.notConnectedToInternet))
        let sut = createRequestPerformer(urlSession: mockSession, retryPolicy: .none)

        _ = try? await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        #expect(mockSession.numberOfRequestsMade == 1)
    }

    @Test("test perform(request:_) attempts only once if retryPolicy.enabled is false")
    func performsOnlyOnceIfRetryPolicyEnabledIsFalse() async throws {
        let retryPolicy = RetryPolicy(enabled: false)
        let mockSession = createMockURLSession(error: URLError(.notConnectedToInternet))
        let sut = createRequestPerformer(urlSession: mockSession, retryPolicy: retryPolicy)

        _ = try? await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        #expect(mockSession.numberOfRequestsMade == 1)
    }

    @Test("test perform(request:_) retries up to maxAttempts times on persistent failure")
    func retriesUpToMaxAttemptsOnPersistentFailure() async throws {
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 3, initialDelay: 0.01, maxDelay: 0.01)
        let mockSession = createMockURLSession(error: URLError(.notConnectedToInternet))
        let sut = createRequestPerformer(urlSession: mockSession, retryPolicy: retryPolicy)

        _ = try? await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        #expect(mockSession.numberOfRequestsMade == 3)
    }

    @Test("test perform(request:_) throws the last error once maxAttempts is reached")
    func throwsLastErrorOnceMaxAttemptsReached() async throws {
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 2, initialDelay: 0.01, maxDelay: 0.01)
        let mockSession = createMockURLSession(error: URLError(.notConnectedToInternet))
        let sut = createRequestPerformer(urlSession: mockSession, retryPolicy: retryPolicy)

        await #expect(throws: NetworkingError.requestFailed(reason: .urlError(underlying: URLError(.notConnectedToInternet)))) {
            try await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        }
    }

    @Test("test perform(request:_) with no error attempts only once even with retryPolicy set")
    func performsOnlyOnceIfNoErrorEvenWithRetryPolicySetUp() async throws {
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 3, initialDelay: 0.01, maxDelay: 0.01)
        let mockSession = createMockURLSession()
        let sut = createRequestPerformer(urlSession: mockSession, retryPolicy: retryPolicy)

        _ = try await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        #expect(mockSession.numberOfRequestsMade == 1)
    }

    @Test("test perform(request:_) always makes the initial attempt even when maxAttempts is 0")
    func performsInitialAttemptEvenWhenMaxAttemptsIsZero() async throws {
        let retryPolicy = RetryPolicy(enabled: true, maxAttempts: 0, initialDelay: 0.01, maxDelay: 0.01)
        let mockSession = createMockURLSession(error: URLError(.notConnectedToInternet))
        let sut = createRequestPerformer(urlSession: mockSession, retryPolicy: retryPolicy)

        _ = try? await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        #expect(mockSession.numberOfRequestsMade == 1)
    }
}

// MARK: - helpers

private func createRequestPerformer(
    urlSession: URLSessionProtocol = createMockURLSession(),
    validator: ResponseValidator = DefaultResponseValidator(),
    retryPolicy: RetryPolicy = .none,
    decoder: JSONDecoder = JSONDecoder()
) -> RequestPerformer {
    RequestPerformer(
        session: MockSession(urlSession: urlSession),
        validator: validator,
        retryPolicy: retryPolicy,
        decoder: decoder
    )
}

private func createMockURLSession(
    data: Data? = MockData.mockPersonJsonData,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockRequestPerformerURLSession {
    MockRequestPerformerURLSession(
        data: data,
        urlResponse: buildResponse(statusCode: statusCode),
        error: error
    )
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
    )!
}

private struct MockRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrl: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: HTTPBody? { nil }
}
