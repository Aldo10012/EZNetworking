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
    var lines: AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var buffer = Data()
                do {
                    for try await byte in self {
                        if byte == 10 { // '\n'
                            let line = String(decoding: buffer, as: UTF8.self)
                            continuation.yield(line)
                            buffer.removeAll()
                        } else if byte == 13 { // '\r'
                            // Peek is complex in AsyncSequence;
                            // for SSE, we usually just ignore \r and wait for \n
                            continue
                        } else {
                            buffer.append(byte)
                        }
                    }
                    // Yield any trailing data if the stream ends without a final newline
                    if !buffer.isEmpty {
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
