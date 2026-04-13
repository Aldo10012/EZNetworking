@testable import EZNetworking
import Testing

@Suite("Test HTTPHeader")
final class HTTPHeaderTests {
    @Test("test HTTPHeader .key and .value", arguments: arguments)
    func hTTPHeaderKeyAndValue(header: HTTPHeader, key: String, value: String) {
        #expect(header.key == key)
        #expect(header.value == value)
    }

    // swiftlint:disable large_tuple
    private static let arguments: [(header: HTTPHeader, key: String, value: String)] = [
        (header: HTTPHeader.accept(.json), key: "Accept", value: "application/json"),
        (header: HTTPHeader.accept(.xml), key: "Accept", value: "application/xml"),
        (header: HTTPHeader.accept(.formUrlEncoded), key: "Accept", value: "application/x-www-form-urlencoded"),
        (header: HTTPHeader.accept(.custom("custom_value")), key: "Accept", value: "custom_value"),
        (header: HTTPHeader.acceptCharset("utf-8"), key: "Accept-Charset", value: "utf-8"),
        (header: HTTPHeader.acceptEncoding("gzip, deflate"), key: "Accept-Encoding", value: "gzip, deflate"),
        (header: HTTPHeader.acceptLanguage("en-US"), key: "Accept-Language", value: "en-US"),
        (header: HTTPHeader.authorization(.bearer("abcde")), key: "Authorization", value: "Bearer abcde"),
        (header: HTTPHeader.cacheControl("no-cache"), key: "Cache-Control", value: "no-cache"),
        (header: HTTPHeader.connection("keep-alive"), key: "Connection", value: "keep-alive"),
        (header: HTTPHeader.contentLength("1024"), key: "Content-Length", value: "1024"),
        (header: HTTPHeader.contentType(.json), key: "Content-Type", value: "application/json"),
        (header: HTTPHeader.contentType(.xml), key: "Content-Type", value: "application/xml"),
        (header: HTTPHeader.contentType(.formUrlEncoded), key: "Content-Type", value: "application/x-www-form-urlencoded"),
        (header: HTTPHeader.contentType(.custom("custom_value")), key: "Content-Type", value: "custom_value"),
        (header: HTTPHeader.cookie("session_id=abcdef123456"), key: "Cookie", value: "session_id=abcdef123456"),
        (header: HTTPHeader.host("example.com"), key: "Host", value: "example.com"),
        (header: HTTPHeader.ifModifiedSince(sampleDate), key: "If-Modified-Since", value: sampleDate),
        (header: HTTPHeader.ifNoneMatch("W/\"123456789\""), key: "If-None-Match", value: "W/\"123456789\""),
        (header: HTTPHeader.lastEventID("event-123"), key: "Last-Event-ID", value: "event-123"),
        (header: HTTPHeader.origin("https://example.com"), key: "Origin", value: "https://example.com"),
        (header: HTTPHeader.referer("https://example.com/previous-page"), key: "Referer", value: "https://example.com/previous-page"),
        (header: HTTPHeader.userAgent(sampleUserAgent), key: "User-Agent", value: sampleUserAgent),
        (header: HTTPHeader.secWebSocketProtocol([]), key: "Sec-WebSocket-Protocol", value: ""),
        (header: HTTPHeader.secWebSocketProtocol(["graphql-ws"]), key: "Sec-WebSocket-Protocol", value: "graphql-ws"),
        (header: HTTPHeader.secWebSocketProtocol(["graphql-ws", "json"]), key: "Sec-WebSocket-Protocol", value: "graphql-ws, json"),
        (header: HTTPHeader.custom(key: "X-Custom-Header", value: "custom-value"), key: "X-Custom-Header", value: "custom-value")
    ]
    // swiftlint:enable large_tuple

    private static let sampleDate = "Tue, 21 Jul 2024 00:00:00 GMT"
    private static let sampleUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}
