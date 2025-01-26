import XCTest
@testable import EZNetworking

final class RequestFactoryTests: XCTestCase {
    
    func testBuildURLRequestWithValidParameters() {
        let builder = RequestFactoryImpl()
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
        let body = "{\"name\": \"John\"}".data(using: .utf8)
        let timeoutInterval: TimeInterval = 30
        
        let request = builder.build(httpMethod: httpMethod,
                                    baseUrlString: urlString,
                                    parameters: parameters,
                                    headers: headers,
                                    body: body,
                                    timeoutInterval: timeoutInterval)
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request.baseUrlString, "https://example.com/api")
        XCTAssertEqual(request.httpMethod, httpMethod)
        XCTAssertEqual(request.parameters, parameters)
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request.headers, headers)
    }
    
    func testBuildURLRequestWithNoParametersAndHeaders() {
        let builder = RequestFactoryImpl()
        let urlString = "https://example.com/api"
        let httpMethod = HTTPMethod.PUT
        
        let request = builder.build(httpMethod: httpMethod,
                                    baseUrlString: urlString,
                                    parameters: nil,
                                    headers: nil,
                                    body: nil,
                                    timeoutInterval: 60)
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request.baseUrlString, "https://example.com/api")
        XCTAssertEqual(request.httpMethod, httpMethod)
        XCTAssertNil(request.parameters)
        XCTAssertNil(request.body)
        XCTAssertEqual(request.timeoutInterval, 60)
        XCTAssertNil(request.headers)
    }
    
}
