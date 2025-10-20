@testable import EZNetworking
import Foundation
import Testing

@Suite("Test Request")
final class RequestTests {
    
    @Test("test Request .httpMethod")
    func testRequestHttpMethod() {
        #expect(MockRequest().httpMethod == .GET)
    }
    
    @Test("test Request .baseUrlString")
    func testRequestBaseUrlString() {
        #expect(MockRequest().baseUrlString == "https://www.example.com")
    }
    
    @Test("test Request .parameters")
    func testRequestParameters() throws {
        let sut = MockRequest()
        let parameters = try #require(sut.parameters)
        #expect(parameters.count == 3)

        let firstParam = try #require(parameters[0])
        #expect(firstParam.key == "key_1")
        #expect(firstParam.key == "key_1")

        let secondParam = try #require(parameters[1])
        #expect(secondParam.key == "key_2")
        #expect(secondParam.key == "key_2")
        
        let thirdParam = try #require(parameters[2])
        #expect(thirdParam.key == "key_3")
        #expect(thirdParam.key == "key_3")
    }
    
    @Test("test Request .headers")
    func testRequestHeaders() throws {
        let sut = MockRequest()
        let headers = try #require(sut.headers)
        #expect(headers.count == 3)

        let firstHeader = try #require(headers[0])
        #expect(firstHeader.key == "Accept")
        #expect(firstHeader.value == "application/json")
        
        let secondHeader = try #require(headers[1])
        #expect(secondHeader.key == "Content-Type")
        #expect(secondHeader.value == "application/json")
        
        let thirdHeader = try #require(headers[2])
        #expect(thirdHeader.key == "Authorization")
        #expect(thirdHeader.value == "Bearer api_key")
    }
    
    @Test("test Request .timeoutInterval")
    func testRequestTimeoutInterval() {
        #expect(MockRequest().timeoutInterval == 60)
    }
    
    @Test("test Request .urlRequest")
    func testRequestBuildMethod() throws {
        let request = MockRequest()
        let sut = try #require(request.urlRequest)
        
        #expect(sut.url?.absoluteString == "https://www.example.com?key_1=value_1&key_2=value_2&key_3=value_3")
        #expect(sut.httpMethod == "GET")
        #expect(sut.httpBody == "{\"name\": \"John\"}".data(using: .utf8))
        #expect(sut.timeoutInterval == 60)
        #expect(sut.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(sut.value(forHTTPHeaderField: "Authorization") == "Bearer api_key")
    }
    
    @Test("test Request .cachePolicy")
    func testRequestCachePolicy() throws {
        let request = MockRequest(cachePolicy: .returnCacheDataElseLoad)
        let sut = try #require(request.urlRequest)
        #expect(sut.cachePolicy == .returnCacheDataElseLoad)
    }
    
}

private struct MockRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    
    var baseUrlString: String { "https://www.example.com" }
    
    var parameters: [HTTPParameter]? {
        [
            .init(key: "key_1", value: "value_1"),
            .init(key: "key_2", value: "value_2"),
            .init(key: "key_3", value: "value_3")
        ]
    }
    
    var headers: [HTTPHeader]? {
        [
            .accept(.json),
            .contentType(.json),
            .authorization(.bearer("api_key"))
        ]
    }
    
    var body: EZNetworking.HTTPBody? {
        .fromJsonString("{\"name\": \"John\"}")
    }
    
    var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
}
