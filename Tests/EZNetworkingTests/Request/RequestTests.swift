import XCTest
@testable import EZNetworking

final class RequestTests: XCTestCase {
    
    func testRequestHttpMethod() {
        XCTAssertEqual(MockRequest().httpMethod, .GET)
    }
    
    func testRequestBaseUrlString() {
        XCTAssertEqual(MockRequest().baseUrlString, "https://www.example.com")
    }
    
    func testRequestParameters() throws {
        let sut = MockRequest()
        let parameters = try XCTUnwrap(sut.parameters)
        XCTAssertEqual(parameters.count, 3)

        let firstParam = try XCTUnwrap(parameters[0])
        XCTAssertEqual(firstParam.key, "key_1")
        XCTAssertEqual(firstParam.key, "key_1")

        let secondParam = try XCTUnwrap(parameters[1])
        XCTAssertEqual(secondParam.key, "key_2")
        XCTAssertEqual(secondParam.key, "key_2")
        
        let thirdParam = try XCTUnwrap(parameters[2])
        XCTAssertEqual(thirdParam.key, "key_3")
        XCTAssertEqual(thirdParam.key, "key_3")
    }
    
    func testRequestHeaders() throws {
        let sut = MockRequest()
        let headers = try XCTUnwrap(sut.headers)
        XCTAssertEqual(headers.count, 3)

        let firstHeader = try XCTUnwrap(headers[0])
        XCTAssertEqual(firstHeader.key, "Accept")
        XCTAssertEqual(firstHeader.value, "application/json")
        
        let secondHeader = try XCTUnwrap(headers[1])
        XCTAssertEqual(secondHeader.key, "Content-Type")
        XCTAssertEqual(secondHeader.value, "application/json")
        
        let thirdHeader = try XCTUnwrap(headers[2])
        XCTAssertEqual(thirdHeader.key, "Authorization")
        XCTAssertEqual(thirdHeader.value, "Bearer api_key")
    }
    
    func testRequestTimeoutInterval() {
        XCTAssertEqual(MockRequest().timeoutInterval, 60)
    }
    
    func testRequestBuildMethod() throws {
        let request = MockRequest()
        let sut = try XCTUnwrap(request.urlRequest)
        
        XCTAssertEqual(sut.url?.absoluteString, "https://www.example.com?key_1=value_1&key_2=value_2&key_3=value_3")
        XCTAssertEqual(sut.httpMethod, "GET")
        XCTAssertEqual(sut.httpBody, "{\"name\": \"John\"}".data(using: .utf8))
        XCTAssertEqual(sut.timeoutInterval, 60)
        XCTAssertEqual(sut.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(sut.value(forHTTPHeaderField: "Authorization"), "Bearer api_key")
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
    
    var body: Data? {
        "{\"name\": \"John\"}".data(using: .utf8)
    }
}
