import Foundation
import Testing
@testable import EZNetworking

@Suite("Test WebSocketRequest")
final class WebSocketRequestTests {
    private let wsURL = "ws://127.0.0.1:8080"

    @Test("test WebSocketRequest default values")
    func webSocketRequestDefaultValues() {
        let sut = WebSocketRequest(url: wsURL)
        #expect(sut.httpMethod == .GET)
        #expect(sut.baseUrl == wsURL)
        #expect(sut.parameters == nil)
        #expect(sut.body == nil)
        #expect(sut.headers == nil)
        #expect(sut.additionalheaders == nil)
        #expect(sut.cachePolicy == .reloadIgnoringLocalCacheData)
        #expect(sut.timeoutInterval == 60)
    }

    @Test("test WebSocketRequest protocols")
    func webSocketRequestProtocols() {
        let sut = WebSocketRequest(
            url: wsURL,
            protocols: ["chat", "superchat"]
        )
        #expect(sut.protocols == ["chat", "superchat"])
        #expect(sut.headers == [.secWebSocketProtocol(["chat", "superchat"])])
    }

    @Test("test WebSocketRequest additional headers")
    func webSocketRequestAdditionalHeaders() {
        let sut = WebSocketRequest(
            url: wsURL,
            additionalheaders: [.contentType(.json)]
        )
        #expect(sut.additionalheaders == [.contentType(.json)])
        #expect(sut.headers == [.contentType(.json)])
    }

    @Test("test WebSocketRequest protocols and additional headers")
    func webSocketRequestProtoclsAndAdditionalHeaders() {
        let sut = WebSocketRequest(
            url: wsURL,
            protocols: ["chat", "superchat"],
            additionalheaders: [.contentType(.json)]
        )
        #expect(sut.protocols == ["chat", "superchat"])
        #expect(sut.additionalheaders == [.contentType(.json)])
        #expect(sut.headers == [
            .secWebSocketProtocol(["chat", "superchat"]),
            .contentType(.json)
        ])
    }
}
