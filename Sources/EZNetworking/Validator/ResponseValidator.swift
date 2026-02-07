import Foundation

public protocol ResponseValidator {
    func validateStatus(from urlResponse: URLResponse) throws
}

public struct ResponseValidatorImpl: ResponseValidator {
    public init() {}

    public func validateStatus(from urlResponse: URLResponse) throws {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse)
        }

        // Convert headers from [AnyHashable: Any] to [String: String]
        let headers = httpURLResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
            if let key = pair.key as? String, let value = pair.value as? String {
                result[key] = value
            }
        }

        let statusCode = HTTPResponse(
            statusCode: httpURLResponse.statusCode,
            headers: headers
        )

        if statusCode.category == .success {
            return // successful http response (2xx) do not throw error
        }
        throw NetworkingError.httpError(statusCode)
    }
}

public typealias URLResponseHeaders = [AnyHashable: Any]
