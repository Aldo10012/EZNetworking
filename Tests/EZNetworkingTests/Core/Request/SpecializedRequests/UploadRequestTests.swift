@testable import EZNetworking
import Foundation
import Testing

@Suite("Test UploadRequest")
final class UploadRequestTests {
    private let uploadURL = "https://example.com/upload"

    // MARK: - Default Values

    @Test("test UploadRequest default values")
    func uploadRequestDefaultValues() {
        let sut = UploadRequest(url: uploadURL)

        #expect(sut.httpMethod == .POST)
        #expect(sut.baseUrl == uploadURL)
        #expect(sut.parameters == nil)
        #expect(sut.body == nil)
        #expect(sut.headers == nil)
        #expect(sut.additionalheaders == nil)
        #expect(sut.cachePolicy == .useProtocolCachePolicy)
        #expect(sut.timeoutInterval == 60)
    }

    // MARK: - Additional Headers

    @Test("test UploadRequest surfaces additional headers")
    func uploadRequestAdditionalHeaders() {
        let sut = UploadRequest(
            url: uploadURL,
            additionalheaders: [
                .authorization(.bearer("TOKEN"))
            ]
        )

        #expect(sut.additionalheaders == [.authorization(.bearer("TOKEN"))])
        #expect(sut.headers == [.authorization(.bearer("TOKEN"))])
    }

    @Test("test UploadRequest supports multiple additional headers")
    func uploadRequestMultipleAdditionalHeaders() {
        let sut = UploadRequest(
            url: uploadURL,
            additionalheaders: [
                .authorization(.bearer("TOKEN")),
                .contentType(.json)
            ]
        )

        #expect(sut.headers == [
            .authorization(.bearer("TOKEN")),
            .contentType(.json)
        ])
    }

    @Test("test UploadRequest handles empty additional headers array")
    func uploadRequestEmptyAdditionalHeadersArray() {
        let sut = UploadRequest(
            url: uploadURL,
            additionalheaders: []
        )

        #expect(sut.headers == [])
    }

    // MARK: - Always POST

    @Test("test UploadRequest always uses POST method")
    func uploadRequestAlwaysPOST() {
        let sut = UploadRequest(url: uploadURL)

        #expect(sut.httpMethod == .POST)
    }

    // MARK: - No Body or Parameters

    @Test("test UploadRequest has no body or parameters")
    func uploadRequestHasNoBodyOrParameters() {
        let sut = UploadRequest(url: uploadURL)

        #expect(sut.parameters == nil)
        #expect(sut.body == nil)
    }

    // MARK: - URLRequest conversion

    @Test("test UploadRequest getURLRequest returns well-formed URLRequest")
    func uploadRequestGetURLRequest() throws {
        let sut = UploadRequest(
            url: uploadURL,
            additionalheaders: [.authorization(.bearer("TOKEN"))]
        )

        let urlRequest = try sut.getURLRequest()

        #expect(urlRequest.url?.absoluteString == uploadURL)
        #expect(urlRequest.httpMethod == "POST")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer TOKEN")
    }

    @Test("test UploadRequest getURLRequest throws for invalid URL")
    func uploadRequestGetURLRequestInvalidURL() {
        let sut = UploadRequest(url: "")

        #expect(throws: (any Error).self) {
            try sut.getURLRequest()
        }
    }
}
