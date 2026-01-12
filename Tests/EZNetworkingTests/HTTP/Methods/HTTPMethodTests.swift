@testable import EZNetworking
import Testing

@Suite("Test HTTPMethod")
final class HTTPMethodTests {

    // MARK: - Individual Method Tests

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

    @Test("test HTTPMethod.PATCH raw value")
    func testHTTPMethodPATCHRawValue() {
        #expect(HTTPMethod.PATCH.rawValue == "PATCH")
    }

    @Test("test HTTPMethod.HEAD raw value")
    func testHTTPMethodHEADRawValue() {
        #expect(HTTPMethod.HEAD.rawValue == "HEAD")
    }

    @Test("test HTTPMethod.OPTIONS raw value")
    func testHTTPMethodOPTIONSRawValue() {
        #expect(HTTPMethod.OPTIONS.rawValue == "OPTIONS")
    }

    @Test("test HTTPMethod.TRACE raw value")
    func testHTTPMethodTRACERawValue() {
        #expect(HTTPMethod.TRACE.rawValue == "TRACE")
    }

    @Test("test HTTPMethod.CONNECT raw value")
    func testHTTPMethodCONNECTRawValue() {
        #expect(HTTPMethod.CONNECT.rawValue == "CONNECT")
    }

    // MARK: - Comprehensive Tests

    @Test("test all HTTP methods have correct raw values")
    func testAllHTTPMethodsHaveCorrectRawValues() {
        let expectedValues: [HTTPMethod: String] = [
            .GET: "GET",
            .POST: "POST",
            .PUT: "PUT",
            .DELETE: "DELETE",
            .PATCH: "PATCH",
            .HEAD: "HEAD",
            .OPTIONS: "OPTIONS",
            .TRACE: "TRACE",
            .CONNECT: "CONNECT"
        ]

        for (method, expectedValue) in expectedValues {
            #expect(method.rawValue == expectedValue, "HTTPMethod.\(method) should have raw value '\(expectedValue)'")
        }
    }

    @Test("test all HTTP methods are uppercase")
    func testAllHTTPMethodsAreUppercase() {
        for method in HTTPMethod.allCases {
            #expect(method.rawValue == method.rawValue.uppercased(), "HTTPMethod.\(method) should be uppercase")
        }
    }

    @Test("test all HTTP methods are non-empty")
    func testAllHTTPMethodsAreNonEmpty() {
        for method in HTTPMethod.allCases {
            #expect(!method.rawValue.isEmpty, "HTTPMethod.\(method) should have non-empty raw value")
        }
    }

    @Test("test HTTP methods are unique")
    func testHTTPMethodsAreUnique() {
        let rawValues = HTTPMethod.allCases.map { $0.rawValue }
        let uniqueValues = Set(rawValues)

        #expect(rawValues.count == uniqueValues.count, "All HTTP methods should have unique raw values")
    }

    // MARK: - CaseIterable Tests

    @Test("test CaseIterable conformance")
    func testCaseIterableConformance() {
        let allMethods = HTTPMethod.allCases
        #expect(allMethods.count == 9, "Should have 9 HTTP methods")

        // Test that all expected methods are present
        let expectedMethods: Set<HTTPMethod> = [.GET, .POST, .PUT, .DELETE, .PATCH, .HEAD, .OPTIONS, .TRACE, .CONNECT]
        let actualMethods = Set(allMethods)

        #expect(actualMethods == expectedMethods, "All expected HTTP methods should be present")
    }

    // MARK: - HTTP Method Categories Tests

    @Test("test safe HTTP methods")
    func testSafeHTTPMethods() {
        let safeMethods: [HTTPMethod] = [.GET, .HEAD, .OPTIONS, .TRACE]

        for method in safeMethods {
            #expect(isSafeMethod(method), "\(method) should be considered a safe HTTP method")
        }
    }

    @Test("test idempotent HTTP methods")
    func testIdempotentHTTPMethods() {
        let idempotentMethods: [HTTPMethod] = [.GET, .PUT, .DELETE, .HEAD, .OPTIONS, .TRACE]

        for method in idempotentMethods {
            #expect(isIdempotentMethod(method), "\(method) should be considered an idempotent HTTP method")
        }
    }

    @Test("test methods that allow request body")
    func testMethodsThatAllowRequestBody() {
        let bodyAllowedMethods: [HTTPMethod] = [.POST, .PUT, .PATCH, .DELETE]

        for method in bodyAllowedMethods {
            #expect(allowsRequestBody(method), "\(method) should allow request body")
        }
    }

    @Test("test methods that typically don't allow request body")
    func testMethodsThatDontAllowRequestBody() {
        let noBodyMethods: [HTTPMethod] = [.GET, .HEAD, .OPTIONS, .TRACE, .CONNECT]

        for method in noBodyMethods {
            #expect(!allowsRequestBody(method), "\(method) should typically not allow request body")
        }
    }

    // MARK: - Helper Methods

    private func isSafeMethod(_ method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .HEAD, .OPTIONS, .TRACE:
            return true
        case .POST, .PUT, .DELETE, .PATCH, .CONNECT:
            return false
        }
    }

    private func isIdempotentMethod(_ method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .PUT, .DELETE, .HEAD, .OPTIONS, .TRACE:
            return true
        case .POST, .PATCH, .CONNECT:
            return false
        }
    }
    
    private func allowsRequestBody(_ method: HTTPMethod) -> Bool {
        switch method {
        case .POST, .PUT, .PATCH, .DELETE:
            return true
        case .GET, .HEAD, .OPTIONS, .TRACE, .CONNECT:
            return false
        }
    }
}
