import Foundation
import Testing
@testable import EZNetworking

@Suite("Test URLBuilder")
final class URLBuilderTests {
    let httpURLBuilder = URLBuilder(allowedSchemes: .http)
    let wsURLBuilder = URLBuilder(allowedSchemes: .ws)

    @Test("test URLBuilder with empty url")
    func uRLBuilderWithEmptyURL() throws {
        #expect(throws: NetworkingError.internalError(.noURL)) {
            _ = try httpURLBuilder.buildAndValidate("")
        }
        #expect(throws: NetworkingError.internalError(.noURL)) {
            _ = try wsURLBuilder.buildAndValidate("")
        }
    }

    @Test("test URLBuilder with invalid url")
    func uRLBuilderWithInvalidURL() throws {
        #expect(throws: NetworkingError.internalError(.invalidScheme(nil))) {
            _ = try httpURLBuilder.buildAndValidate("not a url")
        }
        #expect(throws: NetworkingError.internalError(.invalidScheme(nil))) {
            _ = try wsURLBuilder.buildAndValidate("not a url")
        }
    }

    @Test("test URLBuilder with invalid scheme")
    func uRLBuilderWithInvalidScheme() throws {
        // test http url when expecting ws or wss scheme
        #expect(throws: NetworkingError.internalError(.invalidScheme("http"))) {
            _ = try wsURLBuilder.buildAndValidate("http://www.example.com")
        }
        // test https url when expecting ws or wss scheme
        #expect(throws: NetworkingError.internalError(.invalidScheme("https"))) {
            _ = try wsURLBuilder.buildAndValidate("https://www.example.com")
        }
        // test ws url when expecting http or https scheme
        #expect(throws: NetworkingError.internalError(.invalidScheme("ws"))) {
            _ = try httpURLBuilder.buildAndValidate("ws://www.example.coml")
        }
        // test wss url when expecting http or https scheme
        #expect(throws: NetworkingError.internalError(.invalidScheme("wss"))) {
            _ = try httpURLBuilder.buildAndValidate("wss://www.example.com")
        }
    }

    @Test("test URLBuilder when url is missing host")
    func uRLBuilderWhenUrlIsMissingHost() throws {
        // test http url when expecting http or https scheme but host is missing
        #expect(throws: NetworkingError.internalError(.missingHost)) {
            _ = try httpURLBuilder.buildAndValidate("http://")
        }
        // test https url when expecting http or https scheme but host is missing
        #expect(throws: NetworkingError.internalError(.missingHost)) {
            _ = try httpURLBuilder.buildAndValidate("https://")
        }
        // test ws url when expecting ws or wss scheme but host is missing
        #expect(throws: NetworkingError.internalError(.missingHost)) {
            _ = try wsURLBuilder.buildAndValidate("ws://")
        }
        // test wss url when expecting ws or wss scheme but host is missing
        #expect(throws: NetworkingError.internalError(.missingHost)) {
            _ = try wsURLBuilder.buildAndValidate("wss://")
        }
    }

    @Test("test URLBuilder when url is valid")
    func uRLBuilderWhenUrlIsValid() throws {
        // test http url when expecting http or https scheme
        #expect(throws: Never.self) {
            _ = try httpURLBuilder.buildAndValidate("http://www.example.com")
        }
        // test https url when expecting http or https scheme
        #expect(throws: Never.self) {
            _ = try httpURLBuilder.buildAndValidate("https://www.example.com")
        }
        // test ws url when expecting ws or wss scheme but
        #expect(throws: Never.self) {
            _ = try wsURLBuilder.buildAndValidate("ws://www.example.com")
        }
        // test wss url when expecting ws or wss scheme but
        #expect(throws: Never.self) {
            _ = try wsURLBuilder.buildAndValidate("wss://www.example.com")
        }
    }

    @Test("test URLBuilder")
    func uRLBuilder() throws {
        let httpURL = try httpURLBuilder.buildAndValidate("http://www.example.com")
        #expect(httpURL.absoluteString == "http://www.example.com")

        let httpsURL = try httpURLBuilder.buildAndValidate("https://www.example.com")
        #expect(httpsURL.absoluteString == "https://www.example.com")

        let wsURL = try wsURLBuilder.buildAndValidate("ws://www.example.com")
        #expect(wsURL.absoluteString == "ws://www.example.com")

        let wssURL = try wsURLBuilder.buildAndValidate("wss://www.example.com")
        #expect(wssURL.absoluteString == "wss://www.example.com")
    }
}

@Suite("Test URLSchemePolicy")
final class URLSchemePolicyTests {
    @Test("HTTP policy allows http and https")
    func httpPolicyValues() {
        let allowedSchemes = URLBuilder.URLSchemePolicy.http.values

        #expect(allowedSchemes.count == 2)
        #expect(allowedSchemes.contains("http"))
        #expect(allowedSchemes.contains("https"))
    }

    @Test("WebSocket policy allows ws and wss")
    func webSocketPolicyValues() {
        let allowedSchemes = URLBuilder.URLSchemePolicy.ws.values

        #expect(allowedSchemes.count == 2)
        #expect(allowedSchemes.contains("ws"))
        #expect(allowedSchemes.contains("wss"))
    }
}
