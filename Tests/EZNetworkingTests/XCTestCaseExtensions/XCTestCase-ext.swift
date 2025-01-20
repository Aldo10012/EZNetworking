import XCTest

extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @escaping @autoclosure () async throws -> T,
        errorHandler: (Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected to throw an error, but no error was thrown", file: #filePath, line:  #line)
        } catch {
            errorHandler(error)
        }
    }
    
    func XCTAssertNoThrowAsync<T>(
        _ expression: @escaping @autoclosure () async throws -> T,
        message: String = "Expected no error, but an error was thrown."
    ) async {
        do {
            _ = try await expression()
        } catch {
            XCTFail("\(message) Error: \(error)", file: #filePath, line: #line)
        }
    }
}
