@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformable async/await methods")
final class RequestPerformableAsyncAwaitTests {
    // MARK: - SUCCESS RESPONSE

    @Test("test perform(request:_, decodeTo:_) with all valid inputs does not throw error")
    func perform_withValidInputs_doesNotThrowError() async throws {
        let sut = createRequestPerformer()
        await #expect(throws: Never.self) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }

    @Test("test perform(request:_, decodeTo:_) with all valid inputs decodes data")
    func perform_withValidInputs_doesDecodeData() async throws {
        let sut = createRequestPerformer()
        let person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        #expect(person.name == "John")
        #expect(person.age == 30)
    }

    @Test("test perform(request:_) with all valid inputs does not throw error")
    func perform_withoutDecoding_withValidInputs_doesNotThrowError() async throws {
        let sut = createRequestPerformer()
        await #expect(throws: Never.self) {
            try await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        }
    }

    // MARK: - ERROR RESPONSE

    // MARK: http status code error tests

    @Test("test perform(request:_) fails when status code is 3xx")
    func perform_throwsErrorWhen_statusCodeIs300() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 300))) {
            try await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        }
    }

    @Test("test perform(request:_) fails when status code is 4xx")
    func perform_throwsErrorWhen_statusCodeIs400() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 400))) {
            try await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        }
    }

    @Test("test perform(request:_) fails when status code is 5xx")
    func perform_throwsErrorWhen_statusCodeIs500() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 500)
        )
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 500))) {
            try await sut.perform(request: MockRequest(), decodeTo: EmptyResponse.self)
        }
    }

    // MARK: URLSession has error

    @Test("test perform(request:_) fails when URLSession throws HTTPClientError")
    func perform_throwsErrorWhen_urlSessionThrowsHTTPClientError() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 400))
        )
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 400)))) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }

    @Test("test perform(request:_) fails when URLSession throws HTTPServerError")
    func perform_throwsErrorWhen_urlSessionThrowsHTTPServerError() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500)))) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }

    @Test("test perform(request:_) fails when URLSession throws URLError")
    func perform_throwsErrorWhen_urlSessionThrowsURLError() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        await #expect(throws: NetworkingError.urlError(URLError(.networkConnectionLost))) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }

    @Test("test perform(request:_) fails when URLSession throws unknown error")
    func perform_throwsErrorWhen_urlSessionThrowsUnknownError() async throws {
        enum UnknownError: Error {
            case unknownError
        }
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: UnknownError.unknownError)
        )
        await #expect(throws: NetworkingError.internalError(.requestFailed(UnknownError.unknownError))) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }

    // MARK: data deocding errors

    @Test("test perform(request:_, decodeTo:_) fails when data is nil")
    func performAndDecode_throwsErrorWhen_dataIsNil() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        await #expect(throws: NetworkingError.internalError(.noData)) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }

    @Test("test perform(request:_, decodeTo:_) fails data does not match decodeTo type")
    func performAndDecode_throwsErrorWhen_dataDoesNotMatchDecodeToType() async throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        await #expect(throws: NetworkingError.internalError(.couldNotParse)) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
}

// MARK: - helpers

private func createRequestPerformer(
    urlSession: URLSessionProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    decoder: JSONDecoder = EZJSONDecoder()
) -> RequestPerformer {
    RequestPerformer(urlSession: urlSession, validator: validator, decoder: decoder)
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
