@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketPublisherAdapter")
final class WebSocketPublisherAdapterTests {
    // TODO: add tests
}

private actor MockWebSocket: WebSocketClient {
    var messageContinuation: AsyncStream<InboundMessage>.Continuation
    let _messageStream: AsyncStream<InboundMessage>

    var stateContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    let _stateStream: AsyncStream<WebSocketConnectionState>


    init() {
        let foo = AsyncStream<InboundMessage>.makeStream()
        messageContinuation = foo.continuation
        _messageStream = foo.stream

        let bar = AsyncStream<WebSocketConnectionState>.makeStream()
        stateContinuation = bar.continuation
        _stateStream = bar.stream

    }

    func connect() async throws {

    }
    
    func disconnect() async throws {

    }
    
    func terminate() async {

    }
    
    func send(_ message: OutboundMessage) async throws {

    }
    
    var messages: AsyncStream<InboundMessage> {
        _messageStream
    }

    var stateEvents: AsyncStream<WebSocketConnectionState> {
        _stateStream
    }
}
