@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.messages()")
final class WebSocketMessagesTests {
    @Test("test receiveing messagess")
    func receivingMessages() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await connectTask.value

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
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await connectTask.value

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
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await connectTask.value

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
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        // connect
        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        try await Task.sleep(nanoseconds: 10000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await connectTask.value

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
        let reconnectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        try await Task.sleep(nanoseconds: 10000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await reconnectTask.value

        // send second message
        try await Task.sleep(nanoseconds: 100_000)
        wsTask.simulateReceiveMessage(.string("message 2"))

        await receiveMessagesTask.value
        #expect(messagesReceived == ["message 1", "message 2"])
    }

    @Test("test messages stream ends on WebSocket.terminate()")
    func messagessStreamEndsOnWebSocketTerminate() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        // connect
        let connectTask = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }
        try await Task.sleep(nanoseconds: 1000)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await connectTask.value

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

private enum DummyError: Error {
    case error
}
