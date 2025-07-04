@testable import EZNetworking
import Testing

@Suite("Test HTTPMethod")
final class HTTPMethodTests {

    @Test("test HTTPMethod.GET raw value")
    func testHTTPMethodGetRawValue() {
        #expect(HTTPMethod.GET.rawValue == "GET")
    }

    @Test("test HTTPMethod.POST raw value")
    func testHTTPMethodPOSTRawValue() {
        #expect(HTTPMethod.POST.rawValue == "POST")
    }

    @Test("test HTTPMethod.PUT raw value")
    func testHTTPMethodPUTRawValue() {
        #expect(HTTPMethod.PUT.rawValue == "PUT")
    }

    @Test("test HTTPMethod.DELETE raw value")
    func testHTTPMethodDELETERawValue() {
        #expect(HTTPMethod.DELETE.rawValue == "DELETE")
    }
}
