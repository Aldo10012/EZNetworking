@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DownloadRequest")
final class DownloadRequestTests {
    private let downloadURL = "https://example.com/file.pdf"

    // MARK: - Default Values

    @Test("test DownloadRequest default values")
    func downloadRequestDefaultValues() {
        let sut = DownloadRequest(url: downloadURL)

        #expect(sut.httpMethod == .GET)
        #expect(sut.baseUrl == downloadURL)
        #expect(sut.parameters == nil)
        #expect(sut.body == nil)
        #expect(sut.headers == nil)
        #expect(sut.additionalheaders == nil)
        #expect(sut.cachePolicy == .useProtocolCachePolicy)
        #expect(sut.timeoutInterval == 60)
    }

    // MARK: - Additional Headers

    @Test("test DownloadRequest surfaces additional headers")
    func downloadRequestAdditionalHeaders() {
        let sut = DownloadRequest(
            url: downloadURL,
            additionalheaders: [
                .authorization(.bearer("TOKEN"))
            ]
        )

        #expect(sut.additionalheaders == [.authorization(.bearer("TOKEN"))])
        #expect(sut.headers == [.authorization(.bearer("TOKEN"))])
    }

    @Test("test DownloadRequest supports multiple additional headers")
    func downloadRequestMultipleAdditionalHeaders() {
        let sut = DownloadRequest(
            url: downloadURL,
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

    @Test("test DownloadRequest handles empty additional headers array")
    func downloadRequestEmptyAdditionalHeadersArray() {
        let sut = DownloadRequest(
            url: downloadURL,
            additionalheaders: []
        )

        #expect(sut.headers == [])
    }

    // MARK: - Always GET

    @Test("test DownloadRequest always uses GET method")
    func downloadRequestAlwaysGET() {
        let sut = DownloadRequest(url: downloadURL)

        #expect(sut.httpMethod == .GET)
    }

    // MARK: - No Body or Parameters

    @Test("test DownloadRequest has no body or parameters")
    func downloadRequestHasNoBodyOrParameters() {
        let sut = DownloadRequest(url: downloadURL)

        #expect(sut.parameters == nil)
        #expect(sut.body == nil)
    }

    // MARK: - URLRequest conversion

    @Test("test DownloadRequest getURLRequest returns well-formed URLRequest")
    func downloadRequestGetURLRequest() throws {
        let sut = DownloadRequest(
            url: downloadURL,
            additionalheaders: [.authorization(.bearer("TOKEN"))]
        )

        let urlRequest = try sut.getURLRequest()

        #expect(urlRequest.url?.absoluteString == downloadURL)
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer TOKEN")
    }

    @Test("test DownloadRequest getURLRequest throws for invalid URL")
    func downloadRequestGetURLRequestInvalidURL() {
        let sut = DownloadRequest(url: "")

        #expect(throws: (any Error).self) {
            try sut.getURLRequest()
        }
    }
}
