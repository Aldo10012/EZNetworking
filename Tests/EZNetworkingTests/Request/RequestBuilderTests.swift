import XCTest
@testable import EZNetworking

final class RequestBuilderTests: XCTestCase {
    
    func testBuildURLRequestWithValidParameters() {
        let builder = RequestBuilderImpl()
        let urlString = "https://example.com/api"
        let httpMethod = HTTPMethod.POST
        let parameters: [HTTPParameter] = [
            HTTPParameter(key: "key1", value: "value1"),
            HTTPParameter(key: "key2", value: "value2")
        ]
        let headers: [HTTPHeader] = [
            HTTPHeader.contentType(.json),
            HTTPHeader.authorization(.bearer("token"))
        ]
        let body = "{\"name\": \"John\"}".data(using: .utf8)!
        let timeoutInterval: TimeInterval = 30
        
        let request = builder
            .setHttpMethod(httpMethod)
            .setBaseUrl(urlString)
            .setParameters(parameters)
            .setHeaders(headers)
            .setBody(body)
            .setTimeoutInterval(timeoutInterval)
            .build()
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.url?.absoluteString, "https://example.com/api?key1=value1&key2=value2")
        XCTAssertEqual(request?.httpMethod, httpMethod.rawValue)
        XCTAssertEqual(request?.httpBody, body)
        XCTAssertEqual(request?.timeoutInterval, timeoutInterval)
        
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }
    
    func testBuildURLRequestWithNoParametersAndHeaders() {
        let builder = RequestBuilderImpl()
        let urlString = "https://example.com/api"
        let httpMethod = HTTPMethod.PUT
        
        let request = builder
            .setHttpMethod(httpMethod)
            .setBaseUrl(urlString)
            .setTimeoutInterval(60)
            .build()
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.url?.absoluteString, urlString)
        XCTAssertEqual(request?.httpMethod, httpMethod.rawValue)
        XCTAssertNil(request?.httpBody)
        XCTAssertEqual(request?.timeoutInterval, 60)
    }

}
