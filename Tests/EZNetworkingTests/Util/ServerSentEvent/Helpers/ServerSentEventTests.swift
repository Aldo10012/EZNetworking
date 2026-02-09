@testable import EZNetworking
import Foundation
import Testing

@Suite("ServerSentEvent Tests")
struct ServerSentEventTests {
    // MARK: - Initialization Tests

    @Test("test initialize with all parameters")
    func initWithAllParameters() {
        let event = ServerSentEvent(
            id: "123",
            event: "update",
            data: "Hello, World!",
            retry: 5000
        )

        #expect(event.id == "123")
        #expect(event.event == "update")
        #expect(event.data == "Hello, World!")
        #expect(event.retry == 5000)
    }

    @Test("test initialize with only data")
    func initWithOnlyData() {
        let event = ServerSentEvent(data: "Test data")

        #expect(event.id == nil)
        #expect(event.event == nil)
        #expect(event.data == "Test data")
        #expect(event.retry == nil)
    }

    @Test("test initialize with default values")
    func initWithDefaultValues() {
        let event = ServerSentEvent(
            id: nil,
            event: nil,
            data: "Data only",
            retry: nil
        )

        #expect(event.id == nil)
        #expect(event.event == nil)
        #expect(event.data == "Data only")
        #expect(event.retry == nil)
    }

    @Test("test initialize with partial parameters")
    func initWithPartialParameters() {
        let event = ServerSentEvent(
            id: "456",
            data: "Partial event"
        )

        #expect(event.id == "456")
        #expect(event.event == nil)
        #expect(event.data == "Partial event")
        #expect(event.retry == nil)
    }

    // MARK: - Equatable Tests

    @Test("test equatable with identical events")
    func equatableWithIdenticalEvents() {
        let event1 = ServerSentEvent(
            id: "1",
            event: "test",
            data: "data",
            retry: 1000
        )
        let event2 = ServerSentEvent(
            id: "1",
            event: "test",
            data: "data",
            retry: 1000
        )

        #expect(event1 == event2)
    }

    @Test("test equatable with different IDs")
    func equatableWithDifferentIDs() {
        let event1 = ServerSentEvent(id: "1", data: "data")
        let event2 = ServerSentEvent(id: "2", data: "data")

        #expect(event1 != event2)
    }

    @Test("test equatable with different event types")
    func equatableWithDifferentEventTypes() {
        let event1 = ServerSentEvent(event: "type1", data: "data")
        let event2 = ServerSentEvent(event: "type2", data: "data")

        #expect(event1 != event2)
    }

    @Test("test equatable with different data")
    func equatableWithDifferentData() {
        let event1 = ServerSentEvent(data: "data1")
        let event2 = ServerSentEvent(data: "data2")

        #expect(event1 != event2)
    }

    @Test("test equatable with different retry")
    func equatableWithDifferentRetry() {
        let event1 = ServerSentEvent(data: "data", retry: 1000)
        let event2 = ServerSentEvent(data: "data", retry: 2000)

        #expect(event1 != event2)
    }

    @Test("test equatable with nil values")
    func equatableWithNilValues() {
        let event1 = ServerSentEvent(data: "data")
        let event2 = ServerSentEvent(data: "data")

        #expect(event1 == event2)
    }

    // MARK: - Sendable Tests

    @Test("test sendable conformance")
    func sendableConformance() async {
        let event = ServerSentEvent(data: "test")

        await withCheckedContinuation { continuation in
            Task {
                _ = event // Capture in async context
                continuation.resume()
            }
        }

        // If we reach here without compiler errors, Sendable works
        #expect(Bool(true))
    }

    // MARK: - Edge Cases

    @Test("test empty data")
    func emptyData() {
        let event = ServerSentEvent(data: "")

        #expect(event.data == "")
    }

    @Test("test multiline data")
    func multilineData() {
        let multilineData = """
        Line 1
        Line 2
        Line 3
        """
        let event = ServerSentEvent(data: multilineData)

        #expect(event.data == multilineData)
    }

    @Test("test zero retry")
    func zeroRetry() {
        let event = ServerSentEvent(data: "test", retry: 0)

        #expect(event.retry == 0)
    }

    @Test("test negative retry")
    func negativeRetry() {
        let event = ServerSentEvent(data: "test", retry: -1)

        #expect(event.retry == -1)
    }

    @Test("test empty strings for optional fields")
    func emptyStringsForOptionalFields() {
        let event = ServerSentEvent(
            id: "",
            event: "",
            data: "data"
        )

        #expect(event.id == "")
        #expect(event.event == "")
    }

    @Test("test Unicode and special characters in data")
    func unicodeAndSpecialCharacters() {
        let event = ServerSentEvent(
            data: "Hello 世界 🌍 \n\t Special: <>&\""
        )

        #expect(event.data.contains("世界"))
        #expect(event.data.contains("🌍"))
    }

    @Test("test large retry value")
    func largeRetryValue() {
        let event = ServerSentEvent(data: "test", retry: Int.max)

        #expect(event.retry == Int.max)
    }
}
