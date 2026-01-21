import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformable publisher methods")
final class RequestPerformablepublisherTests {
    private let duration: UInt64 = 1_000_000_000
    private var cancellables = Set<AnyCancellable>()

    // MARK: - SUCCESS

    @Test("test performPublisher(request:_, decodeTo:_) with valid inputs decodes Person")
    func performPublisher_withValidInputs_doesDecodePerson() async {
        let sut = createRequestPerformer()
        var didDecodePerson = false

        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            }, receiveValue: { person in
                #expect(person.name == "John")
                #expect(person.age == 30)
                didDecodePerson = true
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didDecodePerson == true)
    }

    // MARK: - ERROR RESPONSE

    // MARK: http status code error tests

    @Test("test performPublisher(request:_, decodeTo:_) fails when status code is 3xx")
    func performPublisher_throwsErrorWhen_statusCodeIs300() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        var didComplete = false
        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.httpError(HTTPError(statusCode: 300)))
                    didComplete = true
                case .finished: Issue.record()
                }
            }, receiveValue: { _ in
                Issue.record()
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didComplete == true)
    }

    @Test("test performPublisher(request:_, decodeTo:_) fails when status code is 4xx")
    func performPublisher_throwsErrorWhen_statusCodeIs400() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        var didComplete = false
        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
                    didComplete = true
                case .finished: Issue.record()
                }
            }, receiveValue: { _ in
                Issue.record()
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didComplete == true)
    }

    @Test("test performPublisher(request:_, decodeTo:_) fails when status code is 5xx")
    func performPublisher_throwsErrorWhen_statusCodeIs500() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 500)
        )
        var didComplete = false
        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.httpError(HTTPError(statusCode: 500)))
                    didComplete = true
                case .finished: Issue.record()
                }
            }, receiveValue: { _ in
                Issue.record()
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didComplete == true)
    }

    // MARK: URLSession has error

    @Test("test performPublisher(request:_, decodeTo:_) fails when urlsession throws URL error")
    func performPublisher_throwsErrorWhen_urlSessionThrowsURLError() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        var didComplete = false
        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.urlError(URLError(.networkConnectionLost)))
                    didComplete = true
                case .finished: Issue.record()
                }
            }, receiveValue: { _ in
                Issue.record()
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didComplete == true)
    }

    @Test("test performPublisher(request:_, decodeTo:_) fails when urlsession throws unknown error")
    func performPublisher_throwsErrorWhen_urlSessionThrowsUnknownError() async {
        enum UnknownError: Error {
            case error
        }
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: UnknownError.error)
        )
        var didComplete = false
        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.internalError(.requestFailed(UnknownError.error)))
                    didComplete = true
                case .finished: Issue.record()
                }
            }, receiveValue: { _ in
                Issue.record()
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didComplete == true)
    }

    // MARK: data deocding errors

    @Test("test performPublisher(request:_, decodeTo:_) fails when data does not match decodeTo type")
    func performPublisher_throwsErrorWhen_dataDoesNotMatchDecodeToType() async {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        var didComplete = false
        sut.performPublisher(request: MockRequest(), decodeTo: Person.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.internalError(.couldNotParse))
                    didComplete = true
                case .finished: Issue.record()
                }
            }, receiveValue: { _ in
                Issue.record()
            })
            .store(in: &cancellables)

        try? await Task.sleep(nanoseconds: duration)
        #expect(didComplete == true)
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
