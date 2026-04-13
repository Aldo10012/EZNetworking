import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocketPublisherAdapter")
final class WebSocketPublisherAdapterTests {
    // MARK: .connect()

    @Test("test WebSocketPublisherAdapter.connect() completes if actor does not throw")
    func webSocketPublisherAdapterConnectCompletesIfActorDoesNotThrow() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()
        var didSucceed = false
        var cancellables = Set<AnyCancellable>()

        sut.connect()
            .sink(receiveCompletion: { completion in
                if case .finished = completion { didSucceed = true }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test WebSocketPublisherAdapter.connect() fails if actor throws")
    func webSocketPublisherAdapterConnectFailsIfActorThrows() async throws {
        let mockWSActor = MockWebSocket(connectThrows: DummyError.error)
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()
        var didFail = false
        var cancellables = Set<AnyCancellable>()

        sut.connect()
            .sink(receiveCompletion: { completion in
                if case .failure = completion { didFail = true }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didFail)
    }

    // MARK: .disconnect()

    @Test("test WebSocketPublisherAdapter.disconnect() completes if actor does not throw")
    func webSocketPublisherAdapterDisconnectCompletesIfActorDoesNotThrow() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()
        var didSucceed = false
        var cancellables = Set<AnyCancellable>()

        sut.disconnect()
            .sink(receiveCompletion: { completion in
                if case .finished = completion { didSucceed = true }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test WebSocketPublisherAdapter.disconnect() fails if actor throws")
    func webSocketPublisherAdapterDisconnectFailsIfActorThrows() async throws {
        let mockWSActor = MockWebSocket(disconnectThrows: DummyError.error)
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()
        var didFail = false
        var cancellables = Set<AnyCancellable>()

        sut.disconnect()
            .sink(receiveCompletion: { completion in
                if case .failure = completion { didFail = true }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didFail)
    }

    // MARK: .terminate()

    @Test("test WebSocketPublisherAdapter.terminate() calls actor.terminate()")
    func webSocketPublisherAdapterTerminateCallsActorTerminate() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        sut.terminate()
        try? await Task.sleep(for: .milliseconds(100))
        let didTerminate = await mockWSActor.didTerminate
        #expect(didTerminate)
    }

    // MARK: .send()

    @Test("test WebSocketPublisherAdapter.send() completes if actor does not throw")
    func webSocketPublisherAdapterSendCompletesIfActorDoesNotThrow() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()
        var didSucceed = false
        var cancellables = Set<AnyCancellable>()

        sut.send(.string("Test"))
            .sink(receiveCompletion: { completion in
                if case .finished = completion { didSucceed = true }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test WebSocketPublisherAdapter.send() fails if actor throws")
    func webSocketPublisherAdapterSendFailsIfActorThrows() async throws {
        let mockWSActor = MockWebSocket(sendThrows: DummyError.error)
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        let expectation = Expectation()
        var didFail = false
        var cancellables = Set<AnyCancellable>()

        sut.send(.string("Test")).sink(receiveCompletion: { completion in
            if case .failure = completion { didFail = true }
            expectation.fulfill()
        }, receiveValue: { _ in }).store(in: &cancellables)

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didFail)
    }

    // MARK: .messages

    @Test("test WebSocketPublisherAdapter.messages emits inbound messages")
    func webSocketPublisherAdapterMessagesEmitsInboundMessages() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        var cancellables = Set<AnyCancellable>()
        let expectation = Expectation()
        var received: [InboundMessage] = []

        sut.messages
            .sink { msg in
                received.append(msg)
                if received.count == 1 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        await mockWSActor.messageContinuation.yield(.string("Hello world"))
        await expectation.fulfillment(within: .milliseconds(100))
        #expect(received.count == 1)
    }

    // MARK: .stateEvents

    @Test("test WebSocketPublisherAdapter.stateEvents emits state changes")
    func webSocketPublisherAdapterStateEventsEmitsStateChanges() async throws {
        let mockWSActor = MockWebSocket()
        let sut = WebSocketPublisherAdapter(webSocketClient: mockWSActor)
        var cancellables = Set<AnyCancellable>()
        let expectation = Expectation()
        var received: [WebSocketConnectionState] = []

        sut.stateEvents
            .sink { state in
                received.append(state)
                if received.count == 1 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        await mockWSActor.stateContinuation.yield(.connected(protocol: nil))
        await expectation.fulfillment(within: .milliseconds(100))
        #expect(received.count == 1)
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
