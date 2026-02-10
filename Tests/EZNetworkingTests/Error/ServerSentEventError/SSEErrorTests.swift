@testable import EZNetworking
import Foundation
import Testing

@Suite("SSEError Tests")
struct SSEErrorTests {
    
    // MARK: - Error Cases Tests
    
    @Test("Not connected error")
    func notConnectedError() {
        let error: SSEError = .notConnected
        
        if case .notConnected = error {
            #expect(Bool(true))
        } else {
            Issue.record("Expected notConnected error")
        }
    }
    
    @Test("Already connected error")
    func alreadyConnectedError() {
        let error: SSEError = .alreadyConnected
        
        if case .alreadyConnected = error {
            #expect(Bool(true))
        } else {
            Issue.record("Expected alreadyConnected error")
        }
    }
    
    @Test("Still connecting error")
    func stillConnectingError() {
        let error: SSEError = .stillConnecting
        
        if case .stillConnecting = error {
            #expect(Bool(true))
        } else {
            Issue.record("Expected stillConnecting error")
        }
    }
    
    @Test("Connection failed error")
    func connectionFailedError() {
        let underlyingError = NSError(domain: "test", code: 42, userInfo: nil)
        let error: SSEError = .connectionFailed(underlying: underlyingError)
        
        if case .connectionFailed(let underlying) = error {
            #expect((underlying as NSError).code == 42)
        } else {
            Issue.record("Expected connectionFailed error")
        }
    }
    
    @Test("Invalid response error")
    func invalidResponseError() {
        let error: SSEError = .invalidResponse
        
        if case .invalidResponse = error {
            #expect(Bool(true))
        } else {
            Issue.record("Expected invalidResponse error")
        }
    }
    
    @Test("Invalid status code error")
    func invalidStatusCodeError() {
        let error: SSEError = .invalidStatusCode(404)
        
        if case .invalidStatusCode(let code) = error {
            #expect(code == 404)
        } else {
            Issue.record("Expected invalidStatusCode error")
        }
    }
    
    @Test("Invalid content type error with value")
    func invalidContentTypeErrorWithValue() {
        let error: SSEError = .invalidContentType("application/json")
        
        if case .invalidContentType(let contentType) = error {
            #expect(contentType == "application/json")
        } else {
            Issue.record("Expected invalidContentType error")
        }
    }
    
    @Test("Invalid content type error with nil")
    func invalidContentTypeErrorWithNil() {
        let error: SSEError = .invalidContentType(nil)
        
        if case .invalidContentType(let contentType) = error {
            #expect(contentType == nil)
        } else {
            Issue.record("Expected invalidContentType error")
        }
    }
    
    @Test("Unexpected disconnection error")
    func unexpectedDisconnectionError() {
        let error: SSEError = .unexpectedDisconnection
        
        if case .unexpectedDisconnection = error {
            #expect(Bool(true))
        } else {
            Issue.record("Expected unexpectedDisconnection error")
        }
    }
    
    // MARK: - LocalizedError Tests
    
    @Test("Not connected error description")
    func notConnectedErrorDescription() {
        let error: SSEError = .notConnected
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("not currently established") == true)
    }
    
    @Test("Already connected error description")
    func alreadyConnectedErrorDescription() {
        let error: SSEError = .alreadyConnected
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("already established") == true)
    }
    
    @Test("Still connecting error description")
    func stillConnectingErrorDescription() {
        let error: SSEError = .stillConnecting
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("in progress") == true)
    }
    
    @Test("Connection failed error description")
    func connectionFailedErrorDescription() {
        let underlyingError = NSError(
            domain: "TestDomain",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Network unavailable"]
        )
        let error: SSEError = .connectionFailed(underlying: underlyingError)
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("Failed to establish") == true)
        #expect(error.errorDescription?.contains("Network unavailable") == true)
    }
    
    @Test("Invalid response error description")
    func invalidResponseErrorDescription() {
        let error: SSEError = .invalidResponse
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("not a valid HTTP response") == true)
    }
    
    @Test("Invalid status code error description")
    func invalidStatusCodeErrorDescription() {
        let error: SSEError = .invalidStatusCode(500)
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("500") == true)
        #expect(error.errorDescription?.contains("200") == true)
    }
    
    @Test("Invalid content type error description with value")
    func invalidContentTypeErrorDescriptionWithValue() {
        let error: SSEError = .invalidContentType("text/html")
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("text/html") == true)
        #expect(error.errorDescription?.contains("text/event-stream") == true)
    }
    
    @Test("Invalid content type error description with nil")
    func invalidContentTypeErrorDescriptionWithNil() {
        let error: SSEError = .invalidContentType(nil)
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("did not specify") == true)
        #expect(error.errorDescription?.contains("text/event-stream") == true)
    }
    
    @Test("Unexpected disconnection error description")
    func unexpectedDisconnectionErrorDescription() {
        let error: SSEError = .unexpectedDisconnection
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("unexpectedly closed") == true)
    }
    
    // MARK: - Error Protocol Conformance
    
    @Test("Error protocol conformance")
    func errorProtocolConformance() {
        let error: SSEError = .notConnected
        let anyError: Error = error
        
        #expect(anyError is SSEError)
    }
    
    @Test("LocalizedError protocol conformance")
    func localizedErrorProtocolConformance() {
        let error: SSEError = .invalidStatusCode(404)
        let localizedError: LocalizedError = error
        
        #expect(localizedError.errorDescription != nil)
    }
    
    // MARK: - Pattern Matching Tests
    
    @Test("Pattern matching all error cases")
    func patternMatchingAllErrorCases() {
        let errors: [SSEError] = [
            .notConnected,
            .alreadyConnected,
            .stillConnecting,
            .connectionFailed(underlying: NSError(domain: "test", code: 1)),
            .invalidResponse,
            .invalidStatusCode(404),
            .invalidContentType("text/html"),
            .unexpectedDisconnection
        ]
        
        for error in errors {
            switch error {
            case .notConnected, .alreadyConnected, .stillConnecting,
                 .connectionFailed, .invalidResponse, .invalidStatusCode,
                 .invalidContentType, .unexpectedDisconnection:
                #expect(Bool(true))
            }
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Multiple status codes")
    func multipleStatusCodes() {
        let statusCodes = [400, 401, 403, 404, 500, 502, 503]
        
        for code in statusCodes {
            let error: SSEError = .invalidStatusCode(code)
            
            if case .invalidStatusCode(let receivedCode) = error {
                #expect(receivedCode == code)
            } else {
                Issue.record("Expected invalidStatusCode error for code \(code)")
            }
        }
    }
    
    @Test("Various content types")
    func variousContentTypes() {
        let contentTypes = [
            "application/json",
            "text/html",
            "text/plain",
            "application/xml"
        ]
        
        for contentType in contentTypes {
            let error: SSEError = .invalidContentType(contentType)
            
            if case .invalidContentType(let receivedType) = error {
                #expect(receivedType == contentType)
            } else {
                Issue.record("Expected invalidContentType error")
            }
        }
    }
    
    @Test("Error description is not empty")
    func errorDescriptionIsNotEmpty() {
        let errors: [SSEError] = [
            .notConnected,
            .alreadyConnected,
            .stillConnecting,
            .connectionFailed(underlying: NSError(domain: "test", code: 1)),
            .invalidResponse,
            .invalidStatusCode(404),
            .invalidContentType("text/html"),
            .invalidContentType(nil),
            .unexpectedDisconnection
        ]
        
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }
}