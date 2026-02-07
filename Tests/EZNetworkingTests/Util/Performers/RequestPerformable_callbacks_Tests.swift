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
                #expect(error == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 300))))
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
                #expect(error == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 400))))
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
                #expect(error == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 500))))
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
                #expect(error == NetworkingError.requestFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
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
                if case .decodingFailed = error {
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
