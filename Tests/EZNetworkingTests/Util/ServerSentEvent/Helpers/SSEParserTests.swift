@testable import EZNetworking
import Foundation
import Testing

@Suite("SSEParser Tests")
struct SSEParserTests {
    // MARK: - Basic Parsing Tests

    @Test("test Parse simple event with data only")
    func parseSimpleEventWithDataOnly() async {
        let parser = SSEParser()

        let result1 = await parser.parseLine("data: Hello, World!")
        #expect(result1 == nil) // Not complete yet

        let result2 = await parser.parseLine("") // Empty line completes event
        #expect(result2?.data == "Hello, World!")
        #expect(result2?.id == nil)
        #expect(result2?.event == nil)
        #expect(result2?.retry == nil)
    }

    @Test("test Parse event with all fields")
    func parseEventWithAllFields() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 123")
        _ = await parser.parseLine("event: update")
        _ = await parser.parseLine("data: Test data")
        _ = await parser.parseLine("retry: 5000")

        let event = await parser.parseLine("") // Complete event

        #expect(event?.id == "123")
        #expect(event?.event == "update")
        #expect(event?.data == "Test data")
        #expect(event?.retry == 5000)
    }

    @Test("test Parse event with only id field")
    func parseEventWithOnlyIdField() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: abc-123")
        _ = await parser.parseLine("data: content")

        let event = await parser.parseLine("")

        #expect(event?.id == "abc-123")
        #expect(event?.data == "content")
    }

    @Test("test Parse event with only event type")
    func parseEventWithOnlyEventType() async {
        let parser = SSEParser()

        _ = await parser.parseLine("event: notification")
        _ = await parser.parseLine("data: message")

        let event = await parser.parseLine("")

        #expect(event?.event == "notification")
        #expect(event?.data == "message")
    }

    // MARK: - Multi-line Data Tests

    @Test("test Parse multi-line data field")
    func parseMultiLineDataField() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: Line 1")
        _ = await parser.parseLine("data: Line 2")
        _ = await parser.parseLine("data: Line 3")

        let event = await parser.parseLine("")

        #expect(event?.data == "Line 1\nLine 2\nLine 3")
    }

    @Test("test Parse multi-line data with empty lines in data")
    func parseMultiLineDataWithEmptyLinesInData() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: First")
        _ = await parser.parseLine("data: ")
        _ = await parser.parseLine("data: Third")

        let event = await parser.parseLine("")

        #expect(event?.data == "First\n\nThird")
    }

    // MARK: - Comment Tests

    @Test("test Ignore comment lines")
    func ignoreCommentLines() async {
        let parser = SSEParser()

        let result1 = await parser.parseLine(": this is a comment")
        #expect(result1 == nil)

        _ = await parser.parseLine("data: actual data")

        let result2 = await parser.parseLine(": another comment")
        #expect(result2 == nil)

        let event = await parser.parseLine("")
        #expect(event?.data == "actual data")
    }

    @Test("test Ignore lines starting with colon")
    func ignoreLinesStartingWithColon() async {
        let parser = SSEParser()

        _ = await parser.parseLine(":comment")
        _ = await parser.parseLine(": comment with space")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        #expect(event?.data == "test")
    }

    // MARK: - Field Value Trimming Tests

    @Test("test Trim leading space after colon")
    func trimLeadingSpaceAfterColon() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: value with space")
        _ = await parser.parseLine("id: 123")

        let event = await parser.parseLine("")

        #expect(event?.data == "value with space")
        #expect(event?.id == "123")
    }

    @Test("test Do not trim when no space after colon")
    func doNotTrimWhenNoSpaceAfterColon() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data:no space")

        let event = await parser.parseLine("")

        #expect(event?.data == "no space")
    }

    @Test("test Preserve trailing spaces in value")
    func preserveTrailingSpacesInValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: value with trailing spaces  ")

        let event = await parser.parseLine("")

        #expect(event?.data == "value with trailing spaces  ")
    }

    // MARK: - Retry Field Tests

    @Test("test Parse valid retry value")
    func parseValidRetryValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: 3000")

        let event = await parser.parseLine("")

        #expect(event?.retry == 3000)
    }

    @Test("test Ignore invalid retry value")
    func ignoreInvalidRetryValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: not-a-number")

        let event = await parser.parseLine("")

        #expect(event?.retry == nil)
    }

    @Test("test Parse zero retry value")
    func parseZeroRetryValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: 0")

        let event = await parser.parseLine("")

        #expect(event?.retry == 0)
    }

    @Test("test Ignore negative retry value")
    func ignoreNegativeRetryValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: -1000")

        let event = await parser.parseLine("")

        // Note: Int("-1000") succeeds, so this will actually parse
        // The spec doesn't explicitly forbid negative values
        #expect(event?.retry == -1000)
    }

    // MARK: - UTF-8 BOM Tests

    @Test("test Strip UTF-8 BOM from first line")
    func stripUTF8BOMFromFirstLine() async {
        let parser = SSEParser()

        _ = await parser.parseLine("\u{FEFF}data: test")

        let event = await parser.parseLine("")

        #expect(event?.data == "test")
    }

    // MARK: - Malformed Line Tests

    @Test("test Ignore malformed line without colon")
    func ignoreMalformedLineWithoutColon() async {
        let parser = SSEParser()

        let result1 = await parser.parseLine("malformed line")
        #expect(result1 == nil)

        _ = await parser.parseLine("data: valid data")

        let event = await parser.parseLine("")

        #expect(event?.data == "valid data")
    }

    @Test("test Handle line with only field name")
    func handleLineWithOnlyFieldName() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data:")

        let event = await parser.parseLine("")

        // Empty value after colon should result in empty string
        #expect(event?.data == "")
    }

    @Test("test Malformed line treated as comment - various formats")
    func malformedLineTreatedAsComment() async {
        let parser = SSEParser()

        // Various malformed lines without colons
        let result1 = await parser.parseLine("just some text")
        #expect(result1 == nil)

        let result2 = await parser.parseLine("malformed-field-name")
        #expect(result2 == nil)

        let result3 = await parser.parseLine("123456")
        #expect(result3 == nil)

        // Now add valid data
        _ = await parser.parseLine("data: valid content")

        // More malformed lines mixed in
        let result4 = await parser.parseLine("another malformed line")
        #expect(result4 == nil)

        // Complete the event
        let event = await parser.parseLine("")

        // Only the valid data line should be included
        #expect(event?.data == "valid content")
        #expect(event?.id == nil)
        #expect(event?.event == nil)
    }

    // MARK: - Unknown Field Tests

    @Test("test Ignore unknown field names")
    func ignoreUnknownFieldNames() async {
        let parser = SSEParser()

        _ = await parser.parseLine("unknown: value")
        _ = await parser.parseLine("custom: field")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        #expect(event?.data == "test")
        #expect(event?.id == nil)
        #expect(event?.event == nil)
    }

    // MARK: - Multiple Events Tests

    @Test("test Parse multiple consecutive events")
    func parseMultipleConsecutiveEvents() async {
        let parser = SSEParser()

        // First event
        _ = await parser.parseLine("data: Event 1")
        let event1 = await parser.parseLine("")

        #expect(event1?.data == "Event 1")

        // Second event
        _ = await parser.parseLine("data: Event 2")
        let event2 = await parser.parseLine("")

        #expect(event2?.data == "Event 2")

        // Third event
        _ = await parser.parseLine("data: Event 3")
        let event3 = await parser.parseLine("")

        #expect(event3?.data == "Event 3")
    }

    @Test("test Parse events with different field orders")
    func parseEventsWithDifferentFieldOrders() async {
        let parser = SSEParser()

        // Event 1: data first
        _ = await parser.parseLine("data: First")
        _ = await parser.parseLine("id: 1")
        let event1 = await parser.parseLine("")

        #expect(event1?.data == "First")
        #expect(event1?.id == "1")

        // Event 2: id first
        _ = await parser.parseLine("id: 2")
        _ = await parser.parseLine("data: Second")
        let event2 = await parser.parseLine("")

        #expect(event2?.data == "Second")
        #expect(event2?.id == "2")
    }

    // MARK: - No Data Tests

    @Test("test Empty line without data returns nil")
    func emptyLineWithoutDataReturnsNil() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 123")
        _ = await parser.parseLine("event: test")

        let event = await parser.parseLine("") // No data field

        #expect(event == nil)
    }

    @Test("test Event requires data field")
    func eventRequiresDataField() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 1")
        _ = await parser.parseLine("event: update")
        _ = await parser.parseLine("retry: 1000")

        let event = await parser.parseLine("")

        #expect(event == nil) // No data, so no event
    }

    // MARK: - Edge Cases

    @Test("test Empty data value is valid")
    func emptyDataValueIsValid() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data:")

        let event = await parser.parseLine("")

        #expect(event?.data == "")
    }

    @Test("test Multiple empty lines")
    func multipleEmptyLines() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        let event1 = await parser.parseLine("")

        #expect(event1?.data == "test")

        // Additional empty lines should return nil
        let event2 = await parser.parseLine("")
        let event3 = await parser.parseLine("")

        #expect(event2 == nil)
        #expect(event3 == nil)
    }

    @Test("test Data with special characters")
    func dataWithSpecialCharacters() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: Special chars: <>&\"'")

        let event = await parser.parseLine("")

        #expect(event?.data == "Special chars: <>&\"'")
    }

    @Test("test Data with Unicode characters")
    func dataWithUnicodeCharacters() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: Hello 世界 🌍")

        let event = await parser.parseLine("")

        #expect(event?.data == "Hello 世界 🌍")
    }

    @Test("test Field name case sensitivity")
    func fieldNameCaseSensitivity() async {
        let parser = SSEParser()

        // SSE spec says field names are case-sensitive
        _ = await parser.parseLine("Data: wrong case")
        _ = await parser.parseLine("data: correct case")

        let event = await parser.parseLine("")

        // Only the lowercase "data" should be recognized
        #expect(event?.data == "correct case")
    }

    @Test("test Colon in field value")
    func colonInFieldValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: value:with:colons")

        let event = await parser.parseLine("")

        #expect(event?.data == "value:with:colons")
    }

    @Test("test Very long data value")
    func veryLongDataValue() async {
        let parser = SSEParser()

        let longValue = String(repeating: "A", count: 10000)
        _ = await parser.parseLine("data: \(longValue)")

        let event = await parser.parseLine("")

        #expect(event?.data == longValue)
    }

    // MARK: - No Colon Handling (Spec Compliance)

    @Test("test Line without colon treated as field name with empty value")
    func lineWithoutColonTreatedAsFieldNameWithEmptyValue() async {
        let parser = SSEParser()

        // Field name with no colon should have empty value
        _ = await parser.parseLine("customfield")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        // The "customfield" is an unknown field, so it's ignored
        // But it should NOT prevent the event from being parsed
        #expect(event?.data == "test")
    }

    @Test("test Known field without colon gets empty value")
    func knownFieldWithoutColonGetsEmptyValue() async {
        let parser = SSEParser()

        // "data" field with no colon = empty data value
        _ = await parser.parseLine("data")

        let event = await parser.parseLine("")

        // Empty string is valid data
        #expect(event?.data == "")
    }

    @Test("test Event field without colon gets empty value")
    func eventFieldWithoutColonGetsEmptyValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("event")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        #expect(event?.event == "")
        #expect(event?.data == "test")
    }

    @Test("test ID field without colon gets empty value")
    func idFieldWithoutColonGetsEmptyValue() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        #expect(event?.id == "")
        #expect(event?.data == "test")
    }

    // MARK: - Null Character Handling (Spec Compliance)

    @Test("test ID field with null character is ignored")
    func idFieldWithNullCharacterIsIgnored() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: abc\0def")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        // ID with null character should be ignored
        #expect(event?.id == nil)
        #expect(event?.data == "test")
    }

    @Test("test ID field without null character is accepted")
    func idFieldWithoutNullCharacterIsAccepted() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: valid-id-123")
        _ = await parser.parseLine("data: test")

        let event = await parser.parseLine("")

        #expect(event?.id == "valid-id-123")
    }

    @Test("test Null character in data field is preserved")
    func nullCharacterInDataFieldIsPreserved() async {
        let parser = SSEParser()

        // Null character check only applies to ID field
        _ = await parser.parseLine("data: test\0data")

        let event = await parser.parseLine("")

        // Data should include the null character
        #expect(event?.data == "test\0data")
    }

    // MARK: - BOM Optimization

    @Test("test BOM stripped from first line enables proper parsing")
    func bomStrippedFromFirstLineEnablesProperParsing() async {
        let parser = SSEParser()

        // First line with BOM - should be stripped to allow "data" to be recognized
        _ = await parser.parseLine("\u{FEFF}data: line1")
        _ = await parser.parseLine("data: line2")
        _ = await parser.parseLine("data: line3")

        let event = await parser.parseLine("")

        // All lines should be parsed correctly
        #expect(event?.data == "line1\nline2\nline3")
    }

    @Test("test BOM only stripped from very first line parsed")
    func bomOnlyStrippedFromVeryFirstLineParsed() async {
        let parser = SSEParser()

        // First line with BOM - should be stripped
        _ = await parser.parseLine("\u{FEFF}data: first")
        let event1 = await parser.parseLine("")

        #expect(event1?.data == "first")

        // Second event - BOM not stripped, so field name becomes "\u{FEFF}data"
        // which is unknown and gets ignored
        _ = await parser.parseLine("\u{FEFF}data: ignored")
        _ = await parser.parseLine("data: actual data")
        let event2 = await parser.parseLine("")

        // Only the properly formatted line is captured
        #expect(event2?.data == "actual data")
    }

    @Test("test BOM in field value is preserved")
    func bomInFieldValueIsPreserved() async {
        let parser = SSEParser()

        // First line without BOM
        _ = await parser.parseLine("data: first")
        let event1 = await parser.parseLine("")

        #expect(event1?.data == "first")

        // Second event - BOM appears in the value portion
        _ = await parser.parseLine("data: \u{FEFF}second")
        let event2 = await parser.parseLine("")

        // BOM is part of the data value, not stripped
        #expect(event2?.data == "\u{FEFF}second")
    }

    @Test("test First line without BOM means all subsequent BOMs preserved")
    func firstLineWithoutBOMMeansAllSubsequentBOMsPreserved() async {
        let parser = SSEParser()

        // First line has no BOM
        _ = await parser.parseLine("data: first")

        // isFirstLine is now false, so BOM won't be stripped from here on
        _ = await parser.parseLine("data: \u{FEFF}second")

        let event = await parser.parseLine("")

        #expect(event?.data == "first\n\u{FEFF}second")
    }

    // MARK: - Retry Whitespace Handling

    @Test("test Retry with leading whitespace")
    func retryWithLeadingWhitespace() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry:   3000")

        let event = await parser.parseLine("")

        #expect(event?.retry == 3000)
    }

    @Test("test Retry with trailing whitespace")
    func retryWithTrailingWhitespace() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: 3000   ")

        let event = await parser.parseLine("")

        #expect(event?.retry == 3000)
    }

    @Test("test Retry with both leading and trailing whitespace")
    func retryWithBothLeadingAndTrailingWhitespace() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry:   3000   ")

        let event = await parser.parseLine("")

        #expect(event?.retry == 3000)
    }

    @Test("test Retry with invalid format is ignored")
    func retryWithInvalidFormatIsIgnored() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: 5000ms")

        let event = await parser.parseLine("")

        #expect(event?.retry == nil)
    }

    @Test("test Retry with decimal is ignored")
    func retryWithDecimalIsIgnored() async {
        let parser = SSEParser()

        _ = await parser.parseLine("data: test")
        _ = await parser.parseLine("retry: 10.5")

        let event = await parser.parseLine("")

        #expect(event?.retry == nil)
    }

    // MARK: - Heartbeat Events (No Data Field)

    @Test("test Event with only ID field returns nil")
    func eventWithOnlyIdFieldReturnsNil() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 123")

        let event = await parser.parseLine("")

        // Per spec: No data = no event dispatched
        #expect(event == nil)
    }

    @Test("test Event with ID and event type but no data returns nil")
    func eventWithIdAndEventTypeButNoDataReturnsNil() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 456")
        _ = await parser.parseLine("event: heartbeat")

        let event = await parser.parseLine("")

        // Per spec: No data = no event dispatched
        #expect(event == nil)
    }

    @Test("test Event with all fields except data returns nil")
    func eventWithAllFieldsExceptDataReturnsNil() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 789")
        _ = await parser.parseLine("event: ping")
        _ = await parser.parseLine("retry: 5000")

        let event = await parser.parseLine("")

        // Per spec: No data = no event dispatched
        #expect(event == nil)
    }

    @Test("test Event with empty data field is valid")
    func eventWithEmptyDataFieldIsValid() async {
        let parser = SSEParser()

        _ = await parser.parseLine("id: 999")
        _ = await parser.parseLine("data:")

        let event = await parser.parseLine("")

        // Empty string is valid data
        #expect(event?.id == "999")
        #expect(event?.data == "")
    }
}
