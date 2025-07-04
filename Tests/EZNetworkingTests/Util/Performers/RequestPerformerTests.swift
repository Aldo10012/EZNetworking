@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestPerformer")
final class RequestPerformerTests {

    // MARK: Unit tests for perform using Completion Handler with Request Protocol

    @Test("test PerformTask CanCancel")
    func test_PerformTask_CanCancel() throws {
        let sut = createRequestPerformer()
        
        let task = sut.performTask(request: MockRequest(), decodeTo: Person.self) { _ in }
        task?.cancel()
        let dataTask = try #require(task as? MockURLSessionDataTask)
        #expect(dataTask.didCancel == true)
    }
    
    @Test("test PerformTask DoesDecodePerson")
    func test_PerformTask_DoesDecodePerson() {
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
    
    @Test("test PerformTask WhenStatusCode300 Faile")
    func test_PerformTask_WhenStatusCode300_Faile() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.redirect(.multipleChoices, [:]))
            }
        }
        #expect(didExecute == true)
    }
    
    @Test("test PerformTask WhenStatusCodeIs400 Data")
    func test_PerformTask_WhenStatusCodeIs400_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpClientError(.badRequest, [:]))
            }
        }
        #expect(didExecute == true)
    }
    
    @Test("test PerformTask WhenDataIsInvalid Fails")
    func test_PerformTask_WhenDataIsInvalid_Fails() {
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
    
    @Test("test PerformTask WhenDataIsNil Fails")
    func test_PerformTask_WhenDataIsNil_Fails() {
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
    
    @Test("test PerformTask WhenURLSessionHasError Data")
    func test_PerformTask_WhenURLSessionHasError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.internalError(.unknown))
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.internalError(.requestFailed(NetworkingError.internalError(.unknown))))
            }
        }
        #expect(didExecute == true)
    }
    
    @Test("test PerformTask WhenURLSessionHasURLError Data")
    func test_PerformTask_WhenURLSessionHasURLError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
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
    
    // MARK: Unit tests for perform using Completion Handler and Requesst Protocol without Decodable response
    
    @Test("test PerformTask WithoutDecodable CanCancel")
    func test_PerformTask_WithoutDecodable_CanCancel() throws {
        let sut = createRequestPerformer()
        let task = sut.performTask(request: MockRequest()) { _ in }
        task?.cancel()
        let dataTask = try #require(task as? MockURLSessionDataTask)
        #expect(dataTask.didCancel == true)
    }
    
    @Test("test PerformTask WithoutDecodable DoesPass")
    func test_PerformTask_WithoutDecodable_DoesPass() {
        let sut = createRequestPerformer()
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
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
    
    @Test("test PerformTask WithoutDecodable WhenStatusCode300 Fails")
    func test_PerformTask_WithoutDecodable_WhenStatusCode300_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.redirect(.multipleChoices, [:]))
            }
        }
        #expect(didExecute == true)
    }
    
    @Test("test PerformTask WithoutDecodable WhenStatusCodeIs400 Fails")
    func test_PerformTask_WithoutDecodable_WhenStatusCodeIs400_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpClientError(.badRequest, [:]))
            }
        }
        #expect(didExecute == true)
    }
    
    @Test("test PerformTask WithoutDecodable WhenDataIsInvalid Fails")
    func test_PerformTask_WithoutDecodable_WhenDataIsInvalid_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                #expect(true)
            case .failure(let error):
                Issue.record()
            }
        }
        #expect(didExecute == true)
    }
    
    @Test("test PerformTask WithoutDecodable WhenDataIsNil Fails")
    func test_PerformTask_WithoutDecodable_WhenDataIsNil_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
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
    
    @Test("test PerformTask WithoutDecodable WhenURLSessionHasURLError Data")
    func test_PerformTask_WithoutDecodable_WhenURLSessionHasURLError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
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
}

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
