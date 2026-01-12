import Foundation
import Testing
@testable import EZNetworking

@Suite("Test HTTPBody")
class HTTPBodyTests {
    @Test("test Data is HTTPBody")
    func dataIsHTTPBody() {
        #expect(Data() is HTTPBody)
    }

    @Test("test Data is DataConvertible")
    func dataIsDataConvertible() {
        #expect(Data() is DataConvertible)
    }

    @Test("test Data is equal to data.toData()")
    func dataIsEqualToDataToData() {
        let data = Data()
        #expect(data == data.toData())
    }
}
