import XCTest
@testable import EZNetworking

final class HTTPHeaderTests: XCTestCase {
    
    func testAcceptHeaderJson() {
        let header = HTTPHeader.accept(.json)
        XCTAssertEqual(header.key, "Accept")
        XCTAssertEqual(header.value, "application/json")
    }
    
    func testAcceptHeaderXml() {
        let header = HTTPHeader.accept(.xml)
        XCTAssertEqual(header.key, "Accept")
        XCTAssertEqual(header.value, "application/xml")
    }
    
    func testAcceptHeaderFromURLEncoded() {
        let header = HTTPHeader.accept(.formUrlEncoded)
        XCTAssertEqual(header.key, "Accept")
        XCTAssertEqual(header.value, "application/x-www-form-urlencoded")
    }
    
    func testAcceptHeaderCustom() {
        let header = HTTPHeader.accept(.custon("custom_value"))
        XCTAssertEqual(header.key, "Accept")
        XCTAssertEqual(header.value, "custom_value")
    }
    
    func testAcceptCharsetHeader() {
        let header = HTTPHeader.acceptCharset("utf-8")
        XCTAssertEqual(header.key, "Accept-Charset")
        XCTAssertEqual(header.value, "utf-8")
    }
    
    func testAcceptEncodingHeader() {
        let header = HTTPHeader.acceptEncoding("gzip, deflate")
        XCTAssertEqual(header.key, "Accept-Encoding")
        XCTAssertEqual(header.value, "gzip, deflate")
    }
    
    func testAcceptLanguageHeader() {
        let header = HTTPHeader.acceptLanguage("en-US")
        XCTAssertEqual(header.key, "Accept-Language")
        XCTAssertEqual(header.value, "en-US")
    }
    
    func testAuthorizationHeaderBearer() {
        let token = "abcdef123456"
        let header = HTTPHeader.authorization(.bearer(token))
        XCTAssertEqual(header.key, "Authorization")
        XCTAssertEqual(header.value, "Bearer \(token)")
    }
    
    func testCacheControlHeader() {
        let header = HTTPHeader.cacheControl("no-cache")
        XCTAssertEqual(header.key, "Cache-Control")
        XCTAssertEqual(header.value, "no-cache")
    }
    
    func testContentLengthHeader() {
        let header = HTTPHeader.contentLength("1024")
        XCTAssertEqual(header.key, "Content-Length")
        XCTAssertEqual(header.value, "1024")
    }
    
    func testContentTypeHeaderJson() {
        let header = HTTPHeader.contentType(.json)
        XCTAssertEqual(header.key, "Content-Type")
        XCTAssertEqual(header.value, "application/json")
    }
    
    func testContentTypeHeaderXml() {
        let header = HTTPHeader.contentType(.xml)
        XCTAssertEqual(header.key, "Content-Type")
        XCTAssertEqual(header.value, "application/xml")
    }
    
    func testContentTypeHeaderFromURLEncoded() {
        let header = HTTPHeader.contentType(.formUrlEncoded)
        XCTAssertEqual(header.key, "Content-Type")
        XCTAssertEqual(header.value, "application/x-www-form-urlencoded")
    }
    
    func testContentTypeHeaderCustom() {
        let header = HTTPHeader.contentType(.custon("custom_value"))
        XCTAssertEqual(header.key, "Content-Type")
        XCTAssertEqual(header.value, "custom_value")
    }
    
    func testCookieHeader() {
        let cookie = "session_id=abcdef123456"
        let header = HTTPHeader.cookie(cookie)
        XCTAssertEqual(header.key, "Cookie")
        XCTAssertEqual(header.value, cookie)
    }
    
    func testHostHeader() {
        let header = HTTPHeader.host("example.com")
        XCTAssertEqual(header.key, "Host")
        XCTAssertEqual(header.value, "example.com")
    }
    
    func testIfModifiedSinceHeader() {
        let date = "Tue, 21 Jul 2024 00:00:00 GMT"
        let header = HTTPHeader.ifModifiedSince(date)
        XCTAssertEqual(header.key, "If-Modified-Since")
        XCTAssertEqual(header.value, date)
    }
    
    func testIfNoneMatchHeader() {
        let tag = "W/\"123456789\""
        let header = HTTPHeader.ifNoneMatch(tag)
        XCTAssertEqual(header.key, "If-None-Match")
        XCTAssertEqual(header.value, tag)
    }
    
    func testOriginHeader() {
        let origin = "https://example.com"
        let header = HTTPHeader.origin(origin)
        XCTAssertEqual(header.key, "Origin")
        XCTAssertEqual(header.value, "https://example.com")
    }
    
    func testRefererHeader() {
        let referer = "https://example.com/previous-page"
        let header = HTTPHeader.referer(referer)
        XCTAssertEqual(header.key, "Referer")
        XCTAssertEqual(header.value, "https://example.com/previous-page")
    }
    
    func testUserAgentHeader() {
        let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        let header = HTTPHeader.userAgent(userAgent)
        XCTAssertEqual(header.key, "User-Agent")
        XCTAssertEqual(header.value, userAgent)
    }
    
    func testCustomHeader() {
        let key = "X-Custom-Header"
        let value = "custom-value"
        let header = HTTPHeader.custom(key: key, value: value)
        XCTAssertEqual(header.key, key)
        XCTAssertEqual(header.value, value)
    }
    
}
