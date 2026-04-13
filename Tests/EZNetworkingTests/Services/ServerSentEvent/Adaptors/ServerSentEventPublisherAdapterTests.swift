import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ServerSentEventPublisherAdapter")
final class ServerSentEventPublisherAdapterTests {
    // MARK: .connect()

    @Test("test ServerSentEventPublisherAdapter.connect() completes if actor does not throw")
    func serverSentEventPublisherAdapterConnectCompletesIfActorDoesNotThrow() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
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

    @Test("test ServerSentEventPublisherAdapter.connect() fails if actor throws")
    func serverSentEventPublisherAdapterConnectFailsIfActorThrows() async throws {
        let mockSSEActor = MockServerSentEventClient(connectThrows: DummyError.error)
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
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

    @Test("test ServerSentEventPublisherAdapter.disconnect() completes if actor does not throw")
    func serverSentEventPublisherAdapterDisconnectCompletesIfActorDoesNotThrow() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
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

    @Test("test ServerSentEventPublisherAdapter.disconnect() fails if actor throws")
    func serverSentEventPublisherAdapterDisconnectFailsIfActorThrows() async throws {
        let mockSSEActor = MockServerSentEventClient(disconnectThrows: DummyError.error)
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
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

    @Test("test ServerSentEventPublisherAdapter.terminate() calls actor.terminate()")
    func serverSentEventPublisherAdapterTerminateCallsActorTerminate() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
        sut.terminate()
        try? await Task.sleep(for: .milliseconds(100))
        let didTerminate = await mockSSEActor.didTerminate
        #expect(didTerminate)
    }

    // MARK: .events

    @Test("test ServerSentEventPublisherAdapter.events emits server sent events")
    func serverSentEventPublisherAdapterEventsEmitsServerSentEvents() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
        var cancellables = Set<AnyCancellable>()
        let expectation = Expectation()
        var received: [ServerSentEvent] = []

        sut.events
            .sink { event in
                received.append(event)
                if received.count == 1 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        await mockSSEActor.eventContinuation.yield(ServerSentEvent(data: "test data"))
        await expectation.fulfillment(within: .milliseconds(100))
        #expect(received.count == 1)
    }

    // MARK: .stateEvents

    @Test("test ServerSentEventPublisherAdapter.stateEvents emits state changes")
    func serverSentEventPublisherAdapterStateEventsEmitsStateChanges() async throws {
        let mockSSEActor = MockServerSentEventClient()
        let sut = ServerSentEventPublisherAdapter(serverSentEventClient: mockSSEActor)
        var cancellables = Set<AnyCancellable>()
        let expectation = Expectation()
        var received: [SSEConnectionState] = []

        sut.stateEvents
            .sink { state in
                received.append(state)
                if received.count == 1 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        await mockSSEActor.stateContinuation.yield(.connected)
        await expectation.fulfillment(within: .milliseconds(100))
        #expect(received.count == 1)
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
