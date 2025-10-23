@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPBody")
class HTTPBodyTests {

    @Test("test Data is HTTPBody")
    func testDataIsHTTPBody() {
        #expect(Data() is HTTPBody)
    }
}
