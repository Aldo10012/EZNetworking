import Foundation

/// Represents a single Server-Sent Event (SSE) message received from an event stream.
public struct ServerSentEvent: Sendable, Equatable {

    /// The optional event identifier used for resuming streams via `Last-Event-ID`.
    public let id: String?

    /// The optional event name (type) provided by the server (defaults to `"message"` if omitted).
    public let event: String?

    /// The raw data payload of the event, potentially composed of multiple `data:` lines.
    public let data: String

    /// The optional retry interval (in milliseconds) suggested by the server for reconnection.
    public let retry: Int?

    /// Creates a new `ServerSentEvent` with the provided SSE fields.
    public init(
        id: String? = nil,
        event: String? = nil,
        data: String,
        retry: Int? = nil
    ) {
        self.id = id
        self.event = event
        self.data = data
        self.retry = retry
    }
}
