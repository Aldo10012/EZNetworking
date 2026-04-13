@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEventCallbackAdapter")
final class ServerSentEventCallbackAdapterTests {
    // MARK: .connect()

    @Test("test ServerSentEventCallbackAdapter.connect() returns success if actor does not throw")
    func serverSentEventCallbackAdapterConnectReturnsSuccessIfActorDoesNotThrow() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.connect { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test ServerSentEventCallbackAdapter.connect() returns failure if actor does throw")
    func serverSentEventCallbackAdapterConnectReturnsFailureIfActorDoesThrow() async throws {
        let mockSSEActor = MockServerSentEventClient(connectThrows: DummyError.error)
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)
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

    @Test("test ServerSentEventCallbackAdapter.disconnect() returns success if actor does not throw")
    func serverSentEventCallbackAdapterDisconnectReturnsSuccessIfActorDoesNotThrow() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)
        let expectation = Expectation()

        var didSucceed = false
        sut.disconnect { result in
            if case .success = result { didSucceed = true }
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
        #expect(didSucceed)
    }

    @Test("test ServerSentEventCallbackAdapter.disconnect() returns failure if actor does throw")
    func serverSentEventCallbackAdapterDisconnectReturnsFailureIfActorDoesThrow() async throws {
        let mockSSEActor = MockServerSentEventClient(disconnectThrows: DummyError.error)
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)
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

    @Test("test ServerSentEventCallbackAdapter.terminate()")
    func serverSentEventCallbackAdapterTerminate() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)

        sut.terminate()
        try? await Task.sleep(for: .milliseconds(100))

        let didTerminate = await mockSSEActor.didTerminate
        #expect(didTerminate)
    }

    // MARK: .onEvent()

    @Test("test ServerSentEventCallbackAdapter.onEvent()")
    func serverSentEventCallbackAdapterOnEvent() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)

        var eventsReceived = [ServerSentEvent]()
        sut.onEvent { event in
            eventsReceived.append(event)
        }

        try? await Task.sleep(for: .milliseconds(100))
        await mockSSEActor.eventContinuation.yield(ServerSentEvent(data: "test data"))
        try? await Task.sleep(for: .milliseconds(100))

        #expect(eventsReceived.count == 1)
    }

    // MARK: .onStateChange()

    @Test("test ServerSentEventCallbackAdapter.onStateChange()")
    func serverSentEventCallbackAdapterOnStateChange() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventCallbackAdapter(serverSentEventClient: mockSSEActor)

        var statesReceived = [SSEConnectionState]()
        sut.onStateChange { state in
            statesReceived.append(state)
        }

        try? await Task.sleep(for: .milliseconds(100))
        await mockSSEActor.stateContinuation.yield(.connected)
        try? await Task.sleep(for: .milliseconds(100))

        #expect(statesReceived.count == 1)
    }
}

// MARK: Mocks

private actor MockServerSentEventClient: ServerSentEventClient {
    // Stream
    var eventContinuation: AsyncStream<ServerSentEvent>.Continuation
    let _eventStream: AsyncStream<ServerSentEvent>
    var stateContinuation: AsyncStream<SSEConnectionState>.Continuation
    let _stateStream: AsyncStream<SSEConnectionState>

    init(
        connectThrows: Error? = nil,
        disconnectThrows: Error? = nil
    ) {
        self.connectThrows = connectThrows
        self.disconnectThrows = disconnectThrows

        // set up streams
        let eventStreamTuple = AsyncStream<ServerSentEvent>.makeStream()
        eventContinuation = eventStreamTuple.continuation
        _eventStream = eventStreamTuple.stream

        let stateStreamTuple = AsyncStream<SSEConnectionState>.makeStream()
        stateContinuation = stateStreamTuple.continuation
        _stateStream = stateStreamTuple.stream
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

    var events: AsyncStream<ServerSentEvent> {
        _eventStream
    }

    var stateEvents: AsyncStream<SSEConnectionState> {
        _stateStream
    }
}

private enum DummyError: Error { case error }
