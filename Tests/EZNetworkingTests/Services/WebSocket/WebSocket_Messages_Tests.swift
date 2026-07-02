@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.messages()")
final class WebSocketMessagesTests {
    var pingConfig: PingConfig!
    var wsTask: MockURLSessionWebSocketTask!
    var urlSession: MockWebSockerURLSession!
    var wsInterceptor: MockWebSocketTaskInterceptor!
    var delegate: SessionDelegate!
    var session: MockSession!

    // MARK: - setup

    init() {
        self.setup(pingConfig: PingConfig(pingInterval: .seconds(1), maxPingFailures: 1))
        self.setupSession(withTask: MockURLSessionWebSocketTask())
    }

    func setup(pingConfig: PingConfig) {
        self.pingConfig = pingConfig
    }

    func setupSession(withTask wsTask: MockURLSessionWebSocketTask) {
        self.wsTask = wsTask
        self.urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        self.wsInterceptor = MockWebSocketTaskInterceptor()
        self.delegate = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        self.session = MockSession(urlSession: urlSession, delegate: delegate)
    }

    func getSut() -> WebSocket {
        return WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: session)
    }

    // MARK: - teardown

    deinit {
        self.wsTask = nil
        self.urlSession = nil
        self.wsInterceptor = nil
        self.delegate = nil
        self.session = nil
    }

    // MARK: .messages()

    @Test("test receiveing messagess")
    func receivingMessages() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))

        var receivedMessages = [String]()
        let receiveMessagesTask = Task {
            for await message in await sut.messages.prefix(1) {
                switch message {
                case let .string(msg):
                    receivedMessages.append(msg)
                default:
                    Issue.record("Expected string message")
                }
            }
        }

        try await Task.sleep(nanoseconds: 100_000)

        wsTask.simulateReceiveMessage(.string("mock message"))

        await receiveMessagesTask.value

        #expect(receivedMessages == ["mock message"])
        try await sut.disconnect()
    }

    @Test("test receiveing multiple messagess")
    func receivingMultipleMessages() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))

        var receivedMessages = [String]()
        let receiveMessagesTask = Task {
            for await message in await sut.messages.prefix(2) {
                switch message {
                case let .string(msg):
                    receivedMessages.append(msg)
                default:
                    Issue.record("Expected string message")
                }
            }
        }

        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("mock message 1"))

        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("mock message 2"))

        await receiveMessagesTask.value

        #expect(receivedMessages == ["mock message 1", "mock message 2"])
    }

    @Test("test receive message failure")
    func receiveMessageFailure() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))

        var messageReceived = false
        Task {
            for await _ in await sut.messages {
                messageReceived = true
            }
        }

        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessageError()

        #expect(!messageReceived)
    }

    @Test("test messages stream persists after disconnect then reconnect")
    func messagesStreamPersistsAfterDisconnectThenReconnect() async throws {
        let sut = getSut()

        // connect
        try await performConnect(sut, simulating: .didOpenWithProtocol(nil), sleepNanoseconds: 10000)

        // listen to messages
        var messagesReceived = [String]()
        let receiveMessagesTask = Task {
            for await message in await sut.messages.prefix(2) {
                switch message {
                case let .string(msg):
                    messagesReceived.append(msg)
                default:
                    Issue.record("Expected string message")
                }
            }
        }

        // send first message
        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("message 1"))

        // disconnect
        try await sut.disconnect()

        // reconnect
        try await performConnect(sut, simulating: .didOpenWithProtocol(nil), sleepNanoseconds: 10000)

        // send second message
        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("message 2"))

        await receiveMessagesTask.value
        #expect(messagesReceived == ["message 1", "message 2"])
    }

    @Test("test messages stream ends on WebSocket.terminate()")
    func messagessStreamEndsOnWebSocketTerminate() async throws {
        let sut = getSut()

        // connect
        try await performConnect(sut, simulating: .didOpenWithProtocol(nil), sleepNanoseconds: 1000)

        // listen to messages
        var messagesStreamEnded = false

        let messageTask = Task {
            for await _ in await sut.messages {
                // no need to handle messages received for this test
            }
            messagesStreamEnded = true
        }

        try await Task.sleep(nanoseconds: 100_000)
        await sut.terminate()

        _ = await messageTask.value
        #expect(messagesStreamEnded)
    }
}

// MARK: Helpers

/// The interceptor event to fire in order to unblock `WebSocket.connect()`, which
/// suspends inside `waitForConnection()` until the interceptor reports an outcome.
fileprivate enum ConnectSimulation {
    case didOpenWithProtocol(String?)
    case didCompleteWithError(any Error)
    case didCloseWithCloseCode(URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketMessagesTests {
    /// Starts `sut.connect()`, waits for it to reach the suspension point inside
    /// `waitForConnection()`, fires the given interceptor event to unblock it, then
    /// awaits the result. Throws whatever `connect()` throws.
    fileprivate func performConnect(
        _ sut: WebSocket,
        simulating simulation: ConnectSimulation,
        sleepNanoseconds: UInt64 = 100
    ) async throws {
        let task = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: sleepNanoseconds)
        switch simulation {
        case .didOpenWithProtocol(let proto):
            wsInterceptor.simulateOpenWithProtocol(proto)
        case .didCompleteWithError(let error):
            wsInterceptor.simulateDidCompleteWithError(error: error)
        case .didCloseWithCloseCode(let code, let reason):
            wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: code, reason: reason)
        }

        try await task.value
    }

    func createConnectTaskExpectingThrow(_ sut: WebSocket) throws -> Task<Void, Error> {
        Task {
            do {
                try await sut.connect()
            } catch {
                throw error
            }
        }
    }
}

private enum DummyError: Error {
    case error
}
