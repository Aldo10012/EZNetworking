import Foundation

extension AsyncSequence where Element == UInt8 {
    /// A custom implementation of line-buffering that mimics `URLSession.AsyncBytes.lines`.
    ///
    /// This extension bridges raw byte streams to the line-based requirements of the SSE spec.
    ///
    /// ### Delimiter Handling:
    /// * **LF (\n)**: The primary line terminator.
    /// * **CR (\r)**: Ignored to handle `\r\n` sequences gracefully.
    ///
    /// - Returns: An `AsyncThrowingStream<String, Error>` of UTF-8 strings.
    public var sseLines: AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var buffer = Data()
                do {
                    for try await byte in self {
                        if byte == ASCII.lineFeed.rawValue {
                            // swiftlint:disable:next optional_data_string_conversion
                            let line = String(decoding: buffer, as: UTF8.self)
                            continuation.yield(line)
                            buffer.removeAll()
                        } else if byte == ASCII.carriageReturn.rawValue {
                            // Peek is complex in AsyncSequence;
                            // for SSE, we usually just ignore \r and wait for \n
                            continue
                        } else {
                            buffer.append(byte)
                        }
                    }
                    // Yield any trailing data if the stream ends without a final newline
                    if !buffer.isEmpty {
                        // swiftlint:disable:next optional_data_string_conversion
                        continuation.yield(String(decoding: buffer, as: UTF8.self))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

enum ASCII: UInt8 {
    case lineFeed = 10 // '\n'
    case carriageReturn = 13 // '\r'
}
