@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SSERequest")
final class SSERequestTests {
    private let sseURL = "https://api.example.com/events"

    // MARK: - Default Values

    @Test("test SSERequest default values")
    func sseRequestDefaultValues() {
        let sut = SSERequest(url: sseURL)

        #expect(sut.httpMethod == .GET)
        #expect(sut.baseUrl == sseURL)

        #expect(sut.parameters == nil)
        #expect(sut.body == nil)

        // SSERequest always injects base SSE headers
        #expect(sut.headers == [
            .accept(.eventStream),
            .cacheControl("no_cache"),
            .connection("keep_alive")
        ])

        #expect(sut.additionalheaders == nil)
        #expect(sut.cachePolicy == .reloadIgnoringLocalCacheData)

        #expect(sut.timeoutInterval == 60)
    }

    // MARK: - Base SSE Headers Always Present

    @Test("test SSERequest always includes required SSE headers")
    func sseRequestAlwaysIncludesRequiredHeaders() {
        let sut = SSERequest(url: sseURL)

        let headers = sut.headers ?? []

        #expect(headers.contains(.accept(.eventStream)))
        #expect(headers.contains(.cacheControl("no_cache")))
        #expect(headers.contains(.connection("keep_alive")))
    }

    // MARK: - Additional Headers

    @Test("test SSERequest additional headers are appended")
    func sseRequestAdditionalHeadersAppended() {
        let sut = SSERequest(
            url: sseURL,
            additionalheaders: [
                .authorization(.bearer("TOKEN"))
            ]
        )

        #expect(sut.additionalheaders == [
            .authorization(.bearer("TOKEN"))
        ])

        #expect(sut.headers == [
            .accept(.eventStream),
            .cacheControl("no_cache"),
            .connection("keep_alive"),
            .authorization(.bearer("TOKEN"))
        ])
    }

    // MARK: - Multiple Additional Headers

    @Test("test SSERequest supports multiple additional headers")
    func sseRequestMultipleAdditionalHeaders() {
        let sut = SSERequest(
            url: sseURL,
            additionalheaders: [
                .authorization(.bearer("TOKEN")),
                .lastEventID("42")
            ]
        )

        #expect(sut.headers == [
            .accept(.eventStream),
            .cacheControl("no_cache"),
            .connection("keep_alive"),
            .authorization(.bearer("TOKEN")),
            .lastEventID("42")
        ])
    }

    // MARK: - Header Ordering

    @Test("test SSERequest preserves required header ordering")
    func sseRequestPreservesHeaderOrdering() {
        let sut = SSERequest(
            url: sseURL,
            additionalheaders: [.contentType(.json)]
        )

        // Required SSE headers must always come first
        #expect(sut.headers?.prefix(3) == [
            .accept(.eventStream),
            .cacheControl("no_cache"),
            .connection("keep_alive")
        ])
    }

    // MARK: - Empty Additional Headers Array

    @Test("test SSERequest handles empty additional headers array")
    func sseRequestEmptyAdditionalHeadersArray() {
        let sut = SSERequest(
            url: sseURL,
            additionalheaders: []
        )

        // Still only contains the required SSE headers
        #expect(sut.headers == [
            .accept(.eventStream),
            .cacheControl("no_cache"),
            .connection("keep_alive")
        ])
    }

    // MARK: - Last-Event-ID

    @Test("test SSERequest lastEventId header is set when lastEventId is set")
    func sseRequestLastEventIdHeaderIsSetWhenLastEventIdIsSet() {
        var sut = SSERequest(url: sseURL)
        sut.setLastEventId("123")

        #expect(sut.headers == [
            .accept(.eventStream),
            .cacheControl("no_cache"),
            .connection("keep_alive"),
            .lastEventID("123")
        ])
    }

    // MARK: - Cache Policy

    @Test("test SSERequest uses reloadIgnoringLocalCacheData")
    func sseRequestCachePolicy() {
        let sut = SSERequest(url: sseURL)

        #expect(sut.cachePolicy == .reloadIgnoringLocalCacheData)
    }

    // MARK: - Always GET

    @Test("test SSERequest always uses GET method")
    func sseRequestAlwaysGET() {
        let sut = SSERequest(url: sseURL)

        #expect(sut.httpMethod == .GET)
    }

    // MARK: - No Body or Parameters

    @Test("test SSERequest has no body or parameters")
    func sseRequestHasNoBodyOrParameters() {
        let sut = SSERequest(url: sseURL)

        #expect(sut.parameters == nil)
        #expect(sut.body == nil)
    }
}
