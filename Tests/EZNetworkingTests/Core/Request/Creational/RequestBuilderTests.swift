@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestBuilder")
final class RequestBuilderTests {
    @Test("test BuildURLRequest with valid parameters")
    func buildURLRequestWithValidParameters() {
        let builder = RequestBuilderImpl()
        let urlString = "https://example.com/api"
        let httpMethod = HTTPMethod.POST
        let parameters: [HTTPParameter] = [
            HTTPParameter(key: "key1", value: "value1"),
            HTTPParameter(key: "key2", value: "value2")
        ]
        let headers: [HTTPHeader] = [
            HTTPHeader.contentType(.json),
            HTTPHeader.authorization(.bearer("token"))
        ]
        let body = Data(jsonString: "{\"name\": \"John\"}")!
        let timeoutInterval: TimeInterval = 30

        let request = builder
            .setHttpMethod(httpMethod)
            .setBaseUrl(urlString)
            .setParameters(parameters)
            .setHeaders(headers)
            .setBody(body)
            .setTimeoutInterval(timeoutInterval)
            .build()

        #expect(request != nil)
        #expect(request?.baseUrl == "https://example.com/api")
        #expect(request?.httpMethod == httpMethod)
        #expect(request?.parameters == parameters)
        #expect(request?.body?.toData() == body)
        #expect(request?.timeoutInterval == timeoutInterval)
        #expect(request?.headers == headers)
        #expect(request?.cachePolicy == .useProtocolCachePolicy)
    }

    @Test("test BuildURLRequest with no parameters and headers")
    func buildURLRequestWithNoParametersAndHeaders() {
        let builder = RequestBuilderImpl()
        let urlString = "https://example.com/api"
        let httpMethod = HTTPMethod.PUT

        let request = builder
            .setHttpMethod(httpMethod)
            .setBaseUrl(urlString)
            .setTimeoutInterval(60)
            .build()

        #expect(request != nil)
        #expect(request?.baseUrl == "https://example.com/api")
        #expect(request?.httpMethod == httpMethod)
        #expect(request?.parameters == nil)
        #expect(request?.body == nil)
        #expect(request?.timeoutInterval == 60)
        #expect(request?.headers == nil)
        #expect(request?.cachePolicy == .useProtocolCachePolicy)
    }
}
