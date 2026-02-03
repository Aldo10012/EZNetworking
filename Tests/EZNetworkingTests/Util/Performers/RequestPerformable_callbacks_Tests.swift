@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformable callback methods")
final class RequestPerformableCallbacksTests {
    // MARK: - SUCCESS RESPONSE

    @Test("test performTask(request:_, decodeTo:_) with valid inputs does decode Person")
    func performTaskAndDecode_withValidInputs_doesDecodePerson() async {
        let sut = createRequestPerformer()
        let expectation = Expectation()

        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case let .success(person):
                #expect(person.name == "John")
                #expect(person.age == 30)
            case .failure:
                Issue.record()
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("test performTask(request:_) with valid inputs does return success result")
    func performTask_withValidInputs_doesSucceed() async {
        let sut = createRequestPerformer()
        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                #expect(Bool(true))
            case .failure:
                Issue.record()
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: - ERROR RESPONSE

    @Test("test performTask(request:_) fails when status code is 3xx")
    func performTask_throwsErrorWhen_statusCodeIs300() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 300)))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("test performTask(request:_) fails when status code is 4xx")
    func performTask_throwsErrorWhen_statusCodeIs400() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("test performTask(request:_) fails when status code is 5xx")
    func performTask_throwsErrorWhen_statusCodeIs500() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 500)
        )
        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 500)))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: URLSession has error

    @Test("test performTask(request:_) fails when urlsession throws URL error")
    func performTask_throwsErrorWhen_urlSessionThrowsURLError() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.urlError(URLError(.networkConnectionLost)))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("test performTask(request:_) fails when urlsession throws unknown error")
    func performTask_throwsErrorWhen_urlSessionThrowsUnknownError() async {
        enum UnknownError: Error {
            case error
        }
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: UnknownError.error)
        )
        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.requestFailed(UnknownError.error)))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: data deocding errors

    @Test("test performTask(request:_, decode:_) fails when data does not match decodeTo type")
    func performTask_throwsErrorWhen_dataDoesNotMatchDecodeToType() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )

        let expectation = Expectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                if case .internalError(.couldNotParse) = error {
                    #expect(Bool(true))
                } else {
                    Issue.record()
                }
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }
}

// MARK: helpers

private func createRequestPerformer(
    urlSession: URLSessionProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    decoder: JSONDecoder = EZJSONDecoder()
) -> RequestPerformer {
    RequestPerformer(session: MockSession(urlSession: urlSession), validator: validator, decoder: decoder)
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

private struct MockRequestWithNilBuild: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrl: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: HTTPBody? { nil }
    var urlRequest: URLRequest? { nil }
}


// TODO: move to another file

final class Expectation: Sendable {
    private let continuation: AsyncStream<Void>.Continuation
    private let stream: AsyncStream<Void>
    private let expectedFulfillmentCount: Int
    private let isInverted: Bool

    /// Creates a new expectation.
    ///
    /// - Parameters:
    ///   - expectedFulfillmentCount: The number of times `fulfill()` must be called. Default is 1.
    ///   - isInverted: If true, the expectation fails if fulfilled. Default is false.
    init(expectedFulfillmentCount: Int = 1, isInverted: Bool = false) {
        precondition(expectedFulfillmentCount > 0, "expectedFulfillmentCount must be greater than 0")

        self.expectedFulfillmentCount = expectedFulfillmentCount
        self.isInverted = isInverted

        var continuation: AsyncStream<Void>.Continuation!
        self.stream = AsyncStream<Void> { cont in
            continuation = cont
        }
        self.continuation = continuation
    }

    /// Marks the expectation as fulfilled.
    ///
    /// Call this method when the asynchronous operation you're testing completes.
    /// If `expectedFulfillmentCount` is greater than 1, you must call this method
    /// that many times for the expectation to be considered fulfilled.
    func fulfill() {
        continuation.yield()
    }

    /// Waits for the expectation to be fulfilled within the specified timeout.
    ///
    /// - Parameter timeout: The maximum time to wait for fulfillment.
    /// - Throws: If the expectation is not fulfilled within the timeout period.
    func fulfillment(within timeout: Duration) async {
        let timeoutTask = Task {
            try? await Task.sleep(for: timeout)
        }

        let fulfillmentTask = Task {
            var count = 0
            for await _ in stream {
                count += 1
                if count >= expectedFulfillmentCount {
                    break
                }
            }
            return count
        }

        let result = await fulfillmentTask.value
        timeoutTask.cancel()

        if isInverted {
            if result >= expectedFulfillmentCount {
                Issue.record("Inverted expectation was fulfilled")
            }
        } else {
            if result < expectedFulfillmentCount {
                Issue.record("Expectation was not fulfilled within \(timeout). Fulfilled \(result)/\(expectedFulfillmentCount) times.")
            }
        }
    }
}
