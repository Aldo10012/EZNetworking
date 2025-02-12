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
        let body = HTTPBody.jsonString("{\"name\": \"John\"}")
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
        XCTAssertEqual(request?.baseUrlString, "https://example.com/api")
        XCTAssertEqual(request?.httpMethod, httpMethod)
        XCTAssertEqual(request?.parameters, parameters)
        XCTAssertEqual(request?.body, body)
        XCTAssertEqual(request?.timeoutInterval, timeoutInterval)
        XCTAssertEqual(request?.headers, headers)
        XCTAssertEqual(request?.cachePolicy, .useProtocolCachePolicy)
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
        XCTAssertEqual(request?.baseUrlString, "https://example.com/api")
        XCTAssertEqual(request?.httpMethod, httpMethod)
        XCTAssertNil(request?.parameters)
        XCTAssertNil(request?.body)
        XCTAssertEqual(request?.timeoutInterval, 60)
        XCTAssertNil(request?.headers)
        XCTAssertEqual(request?.cachePolicy, .useProtocolCachePolicy)
    }

}
