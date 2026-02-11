@testable import EZNetworking
import Foundation
import Testing

@Suite("Test AsyncSequence.sseLines() extension method")
struct AsyncSequenceExtTests {
    // MARK: - Helper Methods

    /// Creates an AsyncStream from a byte array
    private func makeByteStream(_ bytes: [UInt8]) -> AsyncStream<UInt8> {
        AsyncStream { continuation in
            for byte in bytes {
                continuation.yield(byte)
            }
            continuation.finish()
        }
    }

    /// Creates an AsyncStream from a string
    private func makeByteStream(_ string: String) -> AsyncStream<UInt8> {
        let bytes = [UInt8](string.utf8)
        return makeByteStream(bytes)
    }

    /// Collects all lines from a byte stream
    private func collectLines(from bytes: [UInt8]) async throws -> [String] {
        let stream = makeByteStream(bytes)
        var lines: [String] = []
        for try await line in stream.sseLines {
            lines.append(line)
        }
        return lines
    }

    /// Collects all lines from a string
    private func collectLines(from string: String) async throws -> [String] {
        let stream = makeByteStream(string)
        var lines: [String] = []
        for try await line in stream.sseLines {
            lines.append(line)
        }
        return lines
    }

    // MARK: - Basic Line Splitting

    @Test("Single line with LF terminator")
    func singleLineWithLF() async throws {
        let lines = try await collectLines(from: "Hello\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    @Test("Multiple lines with LF terminators")
    func multipleLinesWithLF() async throws {
        let lines = try await collectLines(from: "Line1\nLine2\nLine3\n")

        #expect(lines.count == 3)
        #expect(lines[0] == "Line1")
        #expect(lines[1] == "Line2")
        #expect(lines[2] == "Line3")
    }

    @Test("Single line without terminator")
    func singleLineWithoutTerminator() async throws {
        let lines = try await collectLines(from: "Hello")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    @Test("Empty line with just LF")
    func emptyLineWithJustLF() async throws {
        let lines = try await collectLines(from: "\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "")
    }

    @Test("Multiple empty lines")
    func multipleEmptyLines() async throws {
        let lines = try await collectLines(from: "\n\n\n")

        #expect(lines.count == 3)
        #expect(lines[0] == "")
        #expect(lines[1] == "")
        #expect(lines[2] == "")
    }

    @Test("Empty stream")
    func emptyStream() async throws {
        let lines = try await collectLines(from: "")

        #expect(lines.isEmpty)
    }

    // MARK: - CRLF Handling

    @Test("Single line with CRLF terminator")
    func singleLineWithCRLF() async throws {
        let lines = try await collectLines(from: "Hello\r\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    @Test("Multiple lines with CRLF terminators")
    func multipleLinesWithCRLF() async throws {
        let lines = try await collectLines(from: "Line1\r\nLine2\r\nLine3\r\n")

        #expect(lines.count == 3)
        #expect(lines[0] == "Line1")
        #expect(lines[1] == "Line2")
        #expect(lines[2] == "Line3")
    }

    @Test("Mixed LF and CRLF terminators")
    func mixedLFAndCRLF() async throws {
        let lines = try await collectLines(from: "Line1\nLine2\r\nLine3\n")

        #expect(lines.count == 3)
        #expect(lines[0] == "Line1")
        #expect(lines[1] == "Line2")
        #expect(lines[2] == "Line3")
    }

    @Test("Just CRLF")
    func justCRLF() async throws {
        let lines = try await collectLines(from: "\r\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "")
    }

    @Test("Multiple CRLFs")
    func multipleCRLFs() async throws {
        let lines = try await collectLines(from: "\r\n\r\n\r\n")

        #expect(lines.count == 3)
        #expect(lines[0] == "")
        #expect(lines[1] == "")
        #expect(lines[2] == "")
    }

    // MARK: - Lone CR Handling

    @Test("Lone CR is ignored")
    func loneCRIsIgnored() async throws {
        let lines = try await collectLines(from: "Hello\rWorld\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "HelloWorld")
    }

    @Test("Multiple lone CRs")
    func multipleLoneCRs() async throws {
        let lines = try await collectLines(from: "A\rB\rC\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "ABC")
    }

    @Test("Lone CR at end without LF")
    func loneCRAtEndWithoutLF() async throws {
        let lines = try await collectLines(from: "Hello\r")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    // MARK: - SSE-Specific Scenarios

    @Test("SSE event with data field")
    func sseEventWithDataField() async throws {
        let input = "data: Hello, World!\n\n"
        let lines = try await collectLines(from: input)

        #expect(lines.count == 2)
        #expect(lines[0] == "data: Hello, World!")
        #expect(lines[1] == "")
    }

    @Test("SSE event with multiple fields", .disabled())
    func sseEventWithMultipleFields() async throws {
        let input = """
        id: 123
        event: update
        data: Test data
        
        """
        let lines = try await collectLines(from: input)

        #expect(lines.count == 4)
        #expect(lines[0] == "id: 123")
        #expect(lines[1] == "event: update")
        #expect(lines[2] == "data: Test data")
        #expect(lines[3] == "")
    }

    @Test("SSE comment line", .disabled())
    func sseCommentLine() async throws {
        let input = ": this is a comment\n"
        let lines = try await collectLines(from: input)

        #expect(lines.count == 1)
        #expect(lines[0] == ": this is a comment")
    }

    @Test("SSE multi-line data", .disabled())
    func sseMultiLineData() async throws {
        let input = """
        data: Line 1
        data: Line 2
        data: Line 3
        
        """
        let lines = try await collectLines(from: input)

        #expect(lines.count == 4)
        #expect(lines[0] == "data: Line 1")
        #expect(lines[1] == "data: Line 2")
        #expect(lines[2] == "data: Line 3")
        #expect(lines[3] == "")
    }

    @Test("SSE heartbeat (empty comment)")
    func sseHeartbeat() async throws {
        let input = ":\n"
        let lines = try await collectLines(from: input)

        #expect(lines.count == 1)
        #expect(lines[0] == ":")
    }

    @Test("Multiple SSE events", .disabled())
    func multipleSSEEvents() async throws {
        let input = """
        data: Event 1
        
        data: Event 2
        
        data: Event 3
        
        """
        let lines = try await collectLines(from: input)

        #expect(lines.count == 6)
        #expect(lines[0] == "data: Event 1")
        #expect(lines[1] == "")
        #expect(lines[2] == "data: Event 2")
        #expect(lines[3] == "")
        #expect(lines[4] == "data: Event 3")
        #expect(lines[5] == "")
    }

    // MARK: - UTF-8 Handling

    @Test("UTF-8 emoji")
    func utf8Emoji() async throws {
        let lines = try await collectLines(from: "Hello 👋 World\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello 👋 World")
    }

    @Test("UTF-8 multi-byte characters")
    func utf8MultiByteCharacters() async throws {
        let lines = try await collectLines(from: "こんにちは世界\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "こんにちは世界")
    }

    @Test("UTF-8 mixed languages")
    func utf8MixedLanguages() async throws {
        let lines = try await collectLines(from: "Hello 世界 🌍\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello 世界 🌍")
    }

    @Test("UTF-8 BOM preserved")
    func utf8BOMPreserved() async throws {
        let bom = "\u{FEFF}"
        let lines = try await collectLines(from: "\(bom)Hello\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "\(bom)Hello")
    }

    @Test("UTF-8 right-to-left text")
    func utf8RightToLeftText() async throws {
        let lines = try await collectLines(from: "مرحبا\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "مرحبا")
    }

    // MARK: - Special Characters

    @Test("Line with null character")
    func lineWithNullCharacter() async throws {
        let bytes: [UInt8] = [72, 101, 108, 108, 111, 0, 87, 111, 114, 108, 100, 10] // "Hello\0World\n"
        let lines = try await collectLines(from: bytes)

        #expect(lines.count == 1)
        #expect(lines[0].contains("\0"))
    }

    @Test("Line with tab characters")
    func lineWithTabCharacters() async throws {
        let lines = try await collectLines(from: "Hello\tWorld\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello\tWorld")
    }

    @Test("Line with special ASCII characters")
    func lineWithSpecialASCIICharacters() async throws {
        let lines = try await collectLines(from: "!@#$%^&*()_+-=[]{}|;':\",./<>?\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "!@#$%^&*()_+-=[]{}|;':\",./<>?")
    }

    // MARK: - Fragmented Packets (Key SSE Test)

    @Test("Fragmented packet - split in middle of line")
    func fragmentedPacketSplitInMiddle() async throws {
        let stream = AsyncStream<UInt8> { continuation in
            Task {
                // Send "Hel"
                for byte in "Hel".utf8 {
                    continuation.yield(byte)
                }
                try? await Task.sleep(for: .milliseconds(10))

                // Send "lo\n"
                for byte in "lo\n".utf8 {
                    continuation.yield(byte)
                }

                continuation.finish()
            }
        }

        var lines: [String] = []
        for try await line in stream.sseLines {
            lines.append(line)
        }

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    @Test("Fragmented packet - byte by byte")
    func fragmentedPacketByteByByte() async throws {
        let stream = AsyncStream<UInt8> { continuation in
            Task {
                for byte in "Hello\n".utf8 {
                    continuation.yield(byte)
                    try? await Task.sleep(for: .milliseconds(1))
                }
                continuation.finish()
            }
        }

        var lines: [String] = []
        for try await line in stream.sseLines {
            lines.append(line)
        }

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    @Test("Fragmented packet - split between CRLF")
    func fragmentedPacketSplitBetweenCRLF() async throws {
        let stream = AsyncStream<UInt8> { continuation in
            Task {
                // Send "Hello\r"
                for byte in "Hello\r".utf8 {
                    continuation.yield(byte)
                }
                try? await Task.sleep(for: .milliseconds(10))

                // Send "\n"
                continuation.yield(10)

                continuation.finish()
            }
        }

        var lines: [String] = []
        for try await line in stream.sseLines {
            lines.append(line)
        }

        #expect(lines.count == 1)
        #expect(lines[0] == "Hello")
    }

    @Test("Fragmented packet - multiple fragments")
    func fragmentedPacketMultipleFragments() async throws {
        let stream = AsyncStream<UInt8> { continuation in
            Task {
                let fragments = ["da", "ta: ", "Hel", "lo\n"]
                for fragment in fragments {
                    for byte in fragment.utf8 {
                        continuation.yield(byte)
                    }
                    try? await Task.sleep(for: .milliseconds(5))
                }
                continuation.finish()
            }
        }

        var lines: [String] = []
        for try await line in stream.sseLines {
            lines.append(line)
        }

        #expect(lines.count == 1)
        #expect(lines[0] == "data: Hello")
    }

    // MARK: - Large Data

    @Test("Very long line (10KB)")
    func veryLongLine() async throws {
        let longLine = String(repeating: "A", count: 10_000)
        let lines = try await collectLines(from: "\(longLine)\n")

        #expect(lines.count == 1)
        #expect(lines[0].count == 10_000)
        #expect(lines[0] == longLine)
    }

    @Test("Many lines (1000 lines)")
    func manyLines() async throws {
        var input = ""
        for i in 0..<1000 {
            input += "Line \(i)\n"
        }

        let lines = try await collectLines(from: input)

        #expect(lines.count == 1000)
        #expect(lines[0] == "Line 0")
        #expect(lines[999] == "Line 999")
    }

    @Test("Large data with no newlines")
    func largeDataWithNoNewlines() async throws {
        let largeData = String(repeating: "X", count: 100_000)
        let lines = try await collectLines(from: largeData)

        #expect(lines.count == 1)
        #expect(lines[0].count == 100_000)
    }

    // MARK: - Trailing Data

    @Test("Trailing data without newline")
    func trailingDataWithoutNewline() async throws {
        let lines = try await collectLines(from: "Line1\nLine2")

        #expect(lines.count == 2)
        #expect(lines[0] == "Line1")
        #expect(lines[1] == "Line2")
    }

    @Test("Multiple lines with trailing data")
    func multipleLinesWithTrailingData() async throws {
        let lines = try await collectLines(from: "Line1\nLine2\nLine3")

        #expect(lines.count == 3)
        #expect(lines[0] == "Line1")
        #expect(lines[1] == "Line2")
        #expect(lines[2] == "Line3")
    }

    @Test("Empty trailing data after newline")
    func emptyTrailingDataAfterNewline() async throws {
        let lines = try await collectLines(from: "Line1\n")

        #expect(lines.count == 1)
        #expect(lines[0] == "Line1")
    }

    // MARK: - Error Handling

    @Test("Stream throws error during iteration")
    func streamThrowsErrorDuringIteration() async {
        struct TestError: Error {}

        let stream = AsyncThrowingStream<UInt8, Error> { continuation in
            Task {
                for byte in "Hello".utf8 {
                    continuation.yield(byte)
                }
                continuation.finish(throwing: TestError())
            }
        }

        do {
            var lines: [String] = []
            for try await line in stream.sseLines {
                lines.append(line)
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test("Stream throws error before any data")
    func streamThrowsErrorBeforeAnyData() async {
        struct TestError: Error {}

        let stream = AsyncThrowingStream<UInt8, Error> { continuation in
            continuation.finish(throwing: TestError())
        }

        do {
            var lines: [String] = []
            for try await line in stream.sseLines {
                lines.append(line)
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    // MARK: - Cancellation

    @Test("Stream cancellation stops iteration")
    func streamCancellationStopsIteration() async throws {
        let stream = AsyncStream<UInt8> { continuation in
            Task {
                // Send infinite data
                for i in 0..<10000 {
                    continuation.yield(UInt8(i % 256))
                    try? await Task.sleep(for: .milliseconds(1))
                }
                continuation.finish()
            }
        }

        let task = Task {
            var count = 0
            for try await _ in stream.sseLines {
                count += 1
                if count == 5 {
                    break
                }
            }
            return count
        }

        let count = try await task.value
        #expect(count == 5)
    }

    // MARK: - Edge Cases

    @Test("Only CR characters")
    func onlyCRCharacters() async throws {
        let lines = try await collectLines(from: "\r\r\r")

        #expect(lines.isEmpty)
    }

    @Test("Mixed whitespace")
    func mixedWhitespace() async throws {
        let lines = try await collectLines(from: "  \t  \n")

        #expect(lines.count == 1)
        #expect(lines[0] == "  \t  ")
    }

    @Test("Line with only spaces")
    func lineWithOnlySpaces() async throws {
        let lines = try await collectLines(from: "     \n")

        #expect(lines.count == 1)
        #expect(lines[0] == "     ")
    }

    @Test("Consecutive newlines")
    func consecutiveNewlines() async throws {
        let lines = try await collectLines(from: "Line1\n\n\nLine2\n")

        #expect(lines.count == 4)
        #expect(lines[0] == "Line1")
        #expect(lines[1] == "")
        #expect(lines[2] == "")
        #expect(lines[3] == "Line2")
    }

    @Test("Single byte stream")
    func singleByteStream() async throws {
        let lines = try await collectLines(from: [65]) // 'A'

        #expect(lines.count == 1)
        #expect(lines[0] == "A")
    }

    @Test("Binary data that's not valid UTF-8")
    func binaryDataNotValidUTF8() async throws {
        // Invalid UTF-8 sequence
        let bytes: [UInt8] = [0xFF, 0xFE, 10]
        let lines = try await collectLines(from: bytes)

        #expect(lines.count == 1)
        // String(decoding:as:) uses replacement character for invalid sequences
        #expect(lines[0].contains("�"))
    }
}
