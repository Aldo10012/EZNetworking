@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketCallbackAdapter")
final class WebSocketCallbackAdapterTests {
    // MARK: .connect()

    @Test("test WebSocketCallbackAdapter.connect() returns success if actor does not throw")
    func webSocketCallbackAdapterConnectReturnsSuccessIfActorDoesNotThrow() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.connect { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test WebSocketCallbackAdapter.connect() returns failure if actor does throw")
    func webSocketCallbackAdapterConnectReturnsFailureIfActorDoesThrow() async throws {
        let mockWSActor = MockWebSocket(connectThrows: DummyError.error)
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.connect { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(!didSucceed)
    }

    // MARK: .disconnect()

    @Test("test WebSocketCallbackAdapter.disconnect() returns success if actor does not throw")
    func webSocketCallbackAdapterDisconnectReturnsSuccessIfActorDoesNotThrow() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.disconnect { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test WebSocketCallbackAdapter.disconnect() returns failure if actor does throw")
    func webSocketCallbackAdapterDisconnectReturnsFailureIfActorDoesThrow() async throws {
        let mockWSActor = MockWebSocket(disconnectThrows: DummyError.error)
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.disconnect { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(!didSucceed)
    }

    // MARK: .terminate()

    @Test("test WebSocketCallbackAdapter.terminate()")
    func webSocketCallbackAdapterTerminate() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)

        sut.terminate()
        try? await Task.sleep(for: .milliseconds(100))

        let didTerminate = await mockWSActor.didTerminate
        #expect(didTerminate)
    }

    // MARK: .send()

    @Test("test WebSocketCallbackAdapter.send() returns success if actor does not throw")
    func webSocketCallbackAdapterSendtReturnsSuccessIfActorDoesNotThrow() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.send(.string("Test")) { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test WebSocketCallbackAdapter.send() returns failure if actor does not throw")
    func webSocketCallbackAdapterSendtReturnsFailureIfActorDoesThrow() async throws {
        let mockWSActor = MockWebSocket(sendThrows: DummyError.error)
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.send(.string("Test")) { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(!didSucceed)
    }

    // MARK: .messages

    @Test("test WebSocketCallbackAdapter.onMessages()")
    func webSocketCallbackAdapterOnMessages() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)

        var messagesReceived = [InboundMessage]()
        sut.onMessage { msg in
            messagesReceived.append(msg)
        }

        try? await Task.sleep(for: .milliseconds(100))
        await mockWSActor.messageContinuation.yield(.string("Hello world"))
        try? await Task.sleep(for: .milliseconds(100))

        #expect(messagesReceived.count == 1)
    }

    // MARK: .onStateChange

    @Test("test WebSocketCallbackAdapter.onStateChange()")
    func webSocketCallbackAdapterOnStateChange() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketCallbackAdapter(webSocketClient: mockWSActor)

        var messagesState = [WebSocketConnectionState]()
        sut.onStateChange { msg in
            messagesState.append(msg)
        }

        try? await Task.sleep(for: .milliseconds(100))
        await mockWSActor.stateContinuation.yield(.connected(protocol: nil))
        try? await Task.sleep(for: .milliseconds(100))

        #expect(messagesState.count == 1)
    }
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
