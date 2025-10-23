@testable import EZNetworking
import Foundation
import Testing

@Suite("Test String Extensions")
final class StringExtensinoTests {
    
    // MARK: - .getRandomMultiPartFormBoundary()
    
    private let prefix = "EZNetworking.Boundary."
    
    @Test("generated boundary has expected prefix and UUID suffix")
    func test_generatedBoundary_hasPrefixAndUuidSuffix() {
        let boundary = String.getRandomMultiPartFormBoundary()
        #expect(boundary.hasPrefix(prefix))
        
        let uuidPart = String(boundary.dropFirst(prefix.count))
        #expect(UUID(uuidString: uuidPart) != nil)
    }
    
    @Test("consecutive calls produce different values")
    func test_consecutiveCalls_areDifferent() {
        let first = String.getRandomMultiPartFormBoundary()
        let second = String.getRandomMultiPartFormBoundary()
        #expect(first != second)
    }
    
    @Test("multiple calls produce unique values")
    func test_multipleCalls_areUnique() {
        let iterations = 200
        var seen = Set<String>()
        for _ in 0..<iterations {
            seen.insert(String.getRandomMultiPartFormBoundary())
        }
        #expect(seen.count == iterations)
    }
    
    @Test("generated boundary is non-empty and longer than prefix")
    func test_generatedBoundary_lengthIsReasonable() {
        let boundary = String.getRandomMultiPartFormBoundary()
        #expect(!boundary.isEmpty)
        #expect(boundary.count > prefix.count)
    }
}
