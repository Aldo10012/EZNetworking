import Testing
@testable import EZNetworking

@Suite("Test HTTPMethod")
final class HTTPMethodTests {
    // MARK: - Individual Method Tests

    @Test("test HTTPMethod.GET raw value")
    func hTTPMethodGetRawValue() {
        #expect(HTTPMethod.GET.rawValue == "GET")
    }

    @Test("test HTTPMethod.POST raw value")
    func hTTPMethodPOSTRawValue() {
        #expect(HTTPMethod.POST.rawValue == "POST")
    }

    @Test("test HTTPMethod.PUT raw value")
    func hTTPMethodPUTRawValue() {
        #expect(HTTPMethod.PUT.rawValue == "PUT")
    }

    @Test("test HTTPMethod.DELETE raw value")
    func hTTPMethodDELETERawValue() {
        #expect(HTTPMethod.DELETE.rawValue == "DELETE")
    }

    @Test("test HTTPMethod.PATCH raw value")
    func hTTPMethodPATCHRawValue() {
        #expect(HTTPMethod.PATCH.rawValue == "PATCH")
    }

    @Test("test HTTPMethod.HEAD raw value")
    func hTTPMethodHEADRawValue() {
        #expect(HTTPMethod.HEAD.rawValue == "HEAD")
    }

    @Test("test HTTPMethod.OPTIONS raw value")
    func hTTPMethodOPTIONSRawValue() {
        #expect(HTTPMethod.OPTIONS.rawValue == "OPTIONS")
    }

    @Test("test HTTPMethod.TRACE raw value")
    func hTTPMethodTRACERawValue() {
        #expect(HTTPMethod.TRACE.rawValue == "TRACE")
    }

    @Test("test HTTPMethod.CONNECT raw value")
    func hTTPMethodCONNECTRawValue() {
        #expect(HTTPMethod.CONNECT.rawValue == "CONNECT")
    }

    // MARK: - Comprehensive Tests

    @Test("test all HTTP methods have correct raw values")
    func allHTTPMethodsHaveCorrectRawValues() {
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
    func allHTTPMethodsAreUppercase() {
        for method in HTTPMethod.allCases {
            #expect(method.rawValue == method.rawValue.uppercased(), "HTTPMethod.\(method) should be uppercase")
        }
    }

    @Test("test all HTTP methods are non-empty")
    func allHTTPMethodsAreNonEmpty() {
        for method in HTTPMethod.allCases {
            #expect(!method.rawValue.isEmpty, "HTTPMethod.\(method) should have non-empty raw value")
        }
    }

    @Test("test HTTP methods are unique")
    func hTTPMethodsAreUnique() {
        let rawValues = HTTPMethod.allCases.map(\.rawValue)
        let uniqueValues = Set(rawValues)

        #expect(rawValues.count == uniqueValues.count, "All HTTP methods should have unique raw values")
    }

    // MARK: - CaseIterable Tests

    @Test("test CaseIterable conformance")
    func caseIterableConformance() {
        let allMethods = HTTPMethod.allCases
        #expect(allMethods.count == 9, "Should have 9 HTTP methods")

        // Test that all expected methods are present
        let expectedMethods: Set<HTTPMethod> = [.GET, .POST, .PUT, .DELETE, .PATCH, .HEAD, .OPTIONS, .TRACE, .CONNECT]
        let actualMethods = Set(allMethods)

        #expect(actualMethods == expectedMethods, "All expected HTTP methods should be present")
    }

    // MARK: - HTTP Method Categories Tests

    @Test("test safe HTTP methods")
    func safeHTTPMethods() {
        let safeMethods: [HTTPMethod] = [.GET, .HEAD, .OPTIONS, .TRACE]

        for method in safeMethods {
            #expect(isSafeMethod(method), "\(method) should be considered a safe HTTP method")
        }
    }

    @Test("test idempotent HTTP methods")
    func idempotentHTTPMethods() {
        let idempotentMethods: [HTTPMethod] = [.GET, .PUT, .DELETE, .HEAD, .OPTIONS, .TRACE]

        for method in idempotentMethods {
            #expect(isIdempotentMethod(method), "\(method) should be considered an idempotent HTTP method")
        }
    }

    @Test("test methods that allow request body")
    func methodsThatAllowRequestBody() {
        let bodyAllowedMethods: [HTTPMethod] = [.POST, .PUT, .PATCH, .DELETE]

        for method in bodyAllowedMethods {
            #expect(allowsRequestBody(method), "\(method) should allow request body")
        }
    }

    @Test("test methods that typically don't allow request body")
    func methodsThatDontAllowRequestBody() {
        let noBodyMethods: [HTTPMethod] = [.GET, .HEAD, .OPTIONS, .TRACE, .CONNECT]

        for method in noBodyMethods {
            #expect(!allowsRequestBody(method), "\(method) should typically not allow request body")
        }
    }

    // MARK: - Helper Methods

    private func isSafeMethod(_ method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .HEAD, .OPTIONS, .TRACE:
            true
        case .POST, .PUT, .DELETE, .PATCH, .CONNECT:
            false
        }
    }

    private func isIdempotentMethod(_ method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .PUT, .DELETE, .HEAD, .OPTIONS, .TRACE:
            true
        case .POST, .PATCH, .CONNECT:
            false
        }
    }

    private func allowsRequestBody(_ method: HTTPMethod) -> Bool {
        switch method {
        case .POST, .PUT, .PATCH, .DELETE:
            true
        case .GET, .HEAD, .OPTIONS, .TRACE, .CONNECT:
            false
        }
    }
}
