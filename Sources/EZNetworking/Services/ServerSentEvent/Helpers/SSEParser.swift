import Foundation

/// Parses Server-Sent Event data according to the SSE specification.
///
/// The parser handles the SSE protocol format, which consists of lines of text
/// separated by newlines. Events are delimited by blank lines (two consecutive newlines).
///
/// SSE format:
/// ```
/// id: 123
/// event: update
/// data: Hello, World!
/// data: This is line 2
/// retry: 5000
///
/// ```
actor SSEParser {
    /// Represents a partially constructed event that's being accumulated across multiple lines.
    private struct PartialEvent {
        var id: String?
        var event: String?
        var data: String?
        var retry: Int?

        /// Creates a ServerSentEvent from the accumulated fields, if data exists.
        func toEvent() -> ServerSentEvent? {
            guard let data else {
                return nil
            }

            return ServerSentEvent(
                id: id,
                event: event,
                data: data,
                retry: retry
            )
        }
    }

    /// The current event being built from incoming lines.
    private var currentEvent: PartialEvent

    /// Tracks whether this is the first line ever parsed (for BOM handling).
    private var isFirstLine: Bool

    /// Initializes a new SSE parser.
    init() {
        currentEvent = PartialEvent()
        isFirstLine = true
    }

    /// Parses a single line of SSE data.
    ///
    /// This method should be called for each line received from the event stream.
    /// When a complete event is ready (indicated by a blank line), it returns the event.
    ///
    /// - Parameter line: A single line from the SSE stream
    /// - Returns: A `ServerSentEvent` if a complete event was parsed, otherwise `nil`
    func parseLine(_ line: String) -> ServerSentEvent? {
        var processedLine = line

        // Strip UTF-8 BOM only on the very first line
        if isFirstLine {
            if processedLine.hasPrefix("\u{FEFF}") {
                processedLine.removeFirst()
            }
            isFirstLine = false
        }

        // Empty line indicates end of event
        if processedLine.isEmpty {
            return completeCurrentEvent()
        }

        // Comment line (starts with ':') - ignore
        if processedLine.hasPrefix(":") {
            return nil
        }

        // Parse field line
        let name: String
        let value: String

        if let colonIndex = processedLine.firstIndex(of: ":") {
            name = String(processedLine[..<colonIndex])
            var fieldValue = String(processedLine[processedLine.index(after: colonIndex)...])

            // Remove leading space after colon if present (per spec)
            if fieldValue.hasPrefix(" ") {
                fieldValue.removeFirst()
            }

            value = fieldValue
        } else {
            // Per spec: If no colon, treat entire line as field name with empty value
            name = processedLine
            value = ""
        }

        processField(name: name, value: value)
        return nil
    }

    /// Processes a parsed field and updates the current event.
    private func processField(name: String, value: String) {
        switch name {
        case "id":
            // Per spec: If value contains U+0000 NULL character, ignore the field
            if !value.contains("\0") {
                currentEvent.id = value
            }

        case "event":
            currentEvent.event = value

        case "data":
            // Data fields can appear multiple times and should be concatenated with newlines
            if let existingData = currentEvent.data {
                currentEvent.data = existingData + "\n" + value
            } else {
                currentEvent.data = value
            }

        case "retry":
            // Parse retry as integer (milliseconds)
            // Trim whitespace to be more forgiving
            if let retryValue = Int(value.trimmingCharacters(in: .whitespaces)) {
                currentEvent.retry = retryValue
            }
            // If not a valid integer, ignore per spec

        default:
            // Unknown field - ignore per spec
            break
        }
    }

    /// Completes the current event and resets the parser for the next event.
    private func completeCurrentEvent() -> ServerSentEvent? {
        let event = currentEvent.toEvent()
        reset()
        return event
    }

    /// Resets the parser state to begin accumulating a new event.
    private func reset() {
        currentEvent = PartialEvent()
    }
}
