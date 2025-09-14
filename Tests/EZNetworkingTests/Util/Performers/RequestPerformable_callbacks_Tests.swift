@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformable callback methods")
final class RequestPerformable_callbacks_Tests {

    // MARK: - SUCCESS RESPONSE

    @Test("test performTask(request:_, decodeTo:_) with valid inputs does decode Person")
    func performTaskAndDecode_withValidInputs_doesDecodePerson() {
        let sut = createRequestPerformer()
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success(let person):
                #expect(person.name == "John")
                #expect(person.age == 30)
            case .failure:
                Issue.record()
            }
        }
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) with valid inputs does return success result")
    func performTask_withValidInputs_doesSucceed() {
        let sut = createRequestPerformer()
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                #expect(true)
            case .failure:
                Issue.record()
            }
        }
        #expect(didExecute == true)
    }

    // MARK: DataTask cancellation

    @Test("test performTask(request:_, decodeTo:_) .cancel() does cancel DataTask")
    func performTaskAndDecode_cancel_doesCancelDataTask() throws {
        let sut = createRequestPerformer()
        
        let task = sut.performTask(request: MockRequest(), decodeTo: Person.self) { _ in }
        task?.cancel()
        let dataTask = try #require(task as? MockURLSessionDataTask)
        #expect(dataTask.didCancel == true)
    }

    @Test("test performTask(request:_) .cancel() does cancel DataTask")
    func performTask_cancel_doesCancelDataTask() throws {
        let sut = createRequestPerformer()
        let task = sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { _ in }
        task?.cancel()
        let dataTask = try #require(task as? MockURLSessionDataTask)
        #expect(dataTask.didCancel == true)
    }
    
    // MARK: - ERROR RESPONSE

    @Test("test performTask(request:_) fails when status code is 3xx")
    func performTask_throwsErrorWhen_statusCodeIs300() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 300)))
            }
        }
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) fails when status code is 4xx")
    func performTask_throwsErrorWhen_statusCodeIs400() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
            }
        }
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) fails when status code is 5xx")
    func performTask_throwsErrorWhen_statusCodeIs500() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 500)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 500)))
            }
        }
        #expect(didExecute == true)
    }

    // MARK: URLSession has error

    @Test("test performTask(request:_) fails when urlsession throws URL error")
    func performTask_throwsErrorWhen_urlSessionThrowsURLError() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: EmptyResponse.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.urlError(URLError(.networkConnectionLost)))
            }
        }
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_) fails when urlsession throws unknown error")
    func performTask_throwsErrorWhen_urlSessionThrowsUnknownError() {
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
            case .failure(let error):
                #expect(error == NetworkingError.internalError(.requestFailed(UnknownError.error)))
            }
        }
        #expect(didExecute == true)
    }

    // MARK: data deocding errors

    @Test("test performTask(request:_, decode:_) fails when data is nil")
    func performTask_throwsErrorWhen_dataIsNil() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.internalError(.noData))
            }
        }
        #expect(didExecute == true)
    }

    @Test("test performTask(request:_, decode:_) fails when data does not match decodeTo type")
    func performTask_throwsErrorWhen_dataDoesNotMatchDecodeToType() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.internalError(.couldNotParse))
            }
        }
        #expect(didExecute == true)
    }
}

// MARK: helpers

private func createRequestPerformer(
    urlSession: URLSessionTaskProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> RequestPerformer {
    return RequestPerformer(urlSession: urlSession, validator: validator, requestDecoder: requestDecoder)
}

private func createMockURLSession(
    data: Data? = MockData.mockPersonJsonData,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockRequestPerformerURLSession {
    return MockRequestPerformerURLSession(
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
    var body: HTTPBody? { nil }
}

private struct MockRequestWithNilBuild: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: HTTPBody? { nil }
    var urlRequest: URLRequest? { nil }
}
