import XCTest
@testable import EZNetworking

final class HTTPMethodTests: XCTestCase {

    func testGETMethod() {
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
    }
    
    func testPOSTMethod() {
        XCTAssertEqual(HTTPMethod.POST.rawValue, "POST")
    }
    
    func testPUTMethod() {
        XCTAssertEqual(HTTPMethod.PUT.rawValue, "PUT")
    }
    
    func testDELETEMethod() {
        XCTAssertEqual(HTTPMethod.DELETE.rawValue, "DELETE")
    }
    
}
