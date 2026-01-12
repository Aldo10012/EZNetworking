@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPParameterApplier")
final class HTTPParameterApplierTests {

    @Test("test URL Query Parameters Are Added")
    func testURLQueryParametersAreAdded() throws {
        let url = try #require(URL(string: "https://www.example.com"))
        var urlRequest = URLRequest(url: url)

        HTTPParameterApplier.apply([
            HTTPParameter(key: "key_1", value: "value_1"),
            HTTPParameter(key: "key_2", value: "value_2"),
            HTTPParameter(key: "key_3", value: "value_3")
        ], to: &urlRequest)

        let expectedURL = "https://www.example.com?key_1=value_1&key_2=value_2&key_3=value_3"
        #expect(urlRequest.url?.absoluteString == expectedURL)
    }

}
