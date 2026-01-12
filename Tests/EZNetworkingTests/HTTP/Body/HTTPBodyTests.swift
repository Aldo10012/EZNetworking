@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPBody")
class HTTPBodyTests {

    @Test("test Data is HTTPBody")
    func testDataIsHTTPBody() {
        #expect(Data() is HTTPBody)
    }

    @Test("test Data is DataConvertible")
    func testDataIsDataConvertible() {
        #expect(Data() is DataConvertible)
    }

    @Test("test Data is equal to data.toData()")
    func testDataIsEqualToDataToData() {
        let data = Data()
        #expect(data == data.toData())
    }
}
