@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformable callback methods")
final class RequestPerformableCallbacksTests {
    private let duration: UInt64 = 1_000_000_000

    // MARK: - SUCCESS RESPONSE

    @Test("test performTask(request:_, decodeTo:_) with valid inputs does decode Person")
    func performTaskAndDecode_withValidInputs_doesDecodePerson() async {
        let sut = createRequestPerformer()
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case let .success(person):
                #expect(person.name == "John")
                #expect(person.age == 30)
            case .failure:
                Issue.record()
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) with valid inputs does return success result")
    func performTask_withValidInputs_doesSucceed() async {
        let sut = createRequestPerformer()
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                #expect(Bool(true))
            case .failure:
                Issue.record()
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    // MARK: - ERROR RESPONSE

    @Test("test performTask(request:_) fails when status code is 3xx")
    func performTask_throwsErrorWhen_statusCodeIs300() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 300)))
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) fails when status code is 4xx")
    func performTask_throwsErrorWhen_statusCodeIs400() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) fails when status code is 5xx")
    func performTask_throwsErrorWhen_statusCodeIs500() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 500)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 500)))
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    // MARK: URLSession has error

    @Test("test performTask(request:_) fails when urlsession throws URL error")
    func performTask_throwsErrorWhen_urlSessionThrowsURLError() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.urlError(URLError(.networkConnectionLost)))
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) fails when urlsession throws unknown error")
    func performTask_throwsErrorWhen_urlSessionThrowsUnknownError() async {
        enum UnknownError: Error {
            case error
        }
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: UnknownError.error)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.requestFailed(UnknownError.error)))
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    // MARK: data deocding errors

    @Test("test performTask(request:_, decode:_) fails when data does not match decodeTo type")
    func performTask_throwsErrorWhen_dataDoesNotMatchDecodeToType() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )

        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.couldNotParse))
            }
        }
        try? await Task.sleep(nanoseconds: duration)
        #expect(didExecute == true)
    }

    // MARK: Cancellation

    @Test("test performTask(request:_, decodeTo:_) does not call completion after cancellation")
    func performTask_cancelsTaskOnCancel() async {
        let sut = createRequestPerformer()
        var didExecute = false
        let dataTask = sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { _ in
            didExecute = true
        }
        dataTask?.cancel()
        // Wait a short time to ensure cancellation propagates
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(didExecute == false)
    }
}

// MARK: helpers

private func createRequestPerformer(
    urlSession: URLSessionProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> RequestPerformer {
    RequestPerformer(urlSession: urlSession, validator: validator, requestDecoder: requestDecoder)
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
