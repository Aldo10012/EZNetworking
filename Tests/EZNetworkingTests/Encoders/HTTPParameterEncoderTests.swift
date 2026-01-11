@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPParameterEncoderImpl")
final class HTTPParameterEncoderTests {
    private let sut = HTTPParameterEncoder()

    @Test("test URL Query Parameters Are Added")
    func testURLQueryParametersAreAdded() throws {
        let url = try #require(URL(string: "https://www.example.com"))
        var urlRequest = URLRequest(url: url)
        
        try sut.encodeParameters(for: &urlRequest, with: [
            HTTPParameter(key: "key_1", value: "value_1"),
            HTTPParameter(key: "key_2", value: "value_2"),
            HTTPParameter(key: "key_3", value: "value_3")
        ])
        
        let expectedURL = "https://www.example.com?key_1=value_1&key_2=value_2&key_3=value_3"
        #expect(urlRequest.url?.absoluteString == expectedURL)
    }

}
