@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketPublisherAdapter")
final class WebSocketPublisherAdapterTests {
    // TODO: add tests
}

// MARK: Mocks

private actor MockWebSocket: WebSocketClient {
    // Stream
    var messageContinuation: AsyncStream<InboundMessage>.Continuation
    let _messageStream: AsyncStream<InboundMessage>
    var stateContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    let _stateStream: AsyncStream<WebSocketConnectionState>

    init(
        connectThrows: Error? = nil,
        disconnectThrows: Error? = nil,
        sendThrows: Error? = nil
    ) {
        self.connectThrows = connectThrows
        self.disconnectThrows = disconnectThrows
        self.sendThrows = sendThrows

        // set up streams
        let foo = AsyncStream<InboundMessage>.makeStream()
        messageContinuation = foo.continuation
        _messageStream = foo.stream

        let bar = AsyncStream<WebSocketConnectionState>.makeStream()
        stateContinuation = bar.continuation
        _stateStream = bar.stream
    }

    let connectThrows: Error?
    func connect() async throws {
        if let connectThrows {
            throw connectThrows
        }
    }

    let disconnectThrows: Error?
    func disconnect() async throws {
        if let disconnectThrows {
            throw disconnectThrows
        }
    }

    var didTerminate = false
    func terminate() async {
        didTerminate = true
    }

    var sendThrows: Error?
    func send(_ message: OutboundMessage) async throws {
        if let sendThrows {
            throw sendThrows
        }
    }

    var messages: AsyncStream<InboundMessage> {
        _messageStream
    }

    var stateEvents: AsyncStream<WebSocketConnectionState> {
        _stateStream
    }
}

private enum DummyError: Error { case error }
