import Foundation

public struct SSEResponseValidator: ResponseValidator {
    public init() {}

    public func validateStatus(from urlResponse: URLResponse) throws {
        // Must be an HTTP response
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw SSEError.invalidResponse
        }

        // Convert headers from [AnyHashable: Any] to [String: String]
        let headers = httpURLResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
            if let key = pair.key as? String, let value = pair.value as? String {
                result[key] = value
            }
        }

        let httpResponse = HTTPResponse(
            statusCode: httpURLResponse.statusCode,
            headers: headers
        )

        // Validate status code is 2xx
        guard httpResponse.category == .success else {
            throw SSEError.invalidHTTPResponse(httpResponse)
        }

        // Validate Content-Type header contains "text/event-stream"
        let contentType = headers["Content-Type"] ?? headers["content-type"]
        guard let contentType, contentType.lowercased().contains("text/event-stream") else {
            throw SSEError.invalidHTTPResponse(httpResponse)
        }
    }
}
