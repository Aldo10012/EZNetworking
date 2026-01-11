@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPHeaderEncoderImpl")
final class HTTPHeaderEncoderTests {
    
    @Test("test allHTTPHeaderFields is set to injected headers")
    func testAllHTTPHeaderFieldsIsSetToInjectedHeaders() throws {
        let url = try #require(URL(string: "https://www.example.com"))
        var urlRequest = URLRequest(url: url)
        
        HTTPHeaderEncoder.encodeHeaders(for: &urlRequest, with: [
            .accept(.json),
            .contentType(.json),
            .authorization(.bearer("My_API_KEY"))
        ])
        
        let expextedHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer My_API_KEY"
        ]
        #expect(urlRequest.allHTTPHeaderFields == expextedHeaders)
    }
}
