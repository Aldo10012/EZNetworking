import Foundation

public protocol ResponseValidator {
    func validateStatus(from urlResponse: URLResponse) throws
}

public struct ResponseValidatorImpl: ResponseValidator {
    private var expectedHttpHeaders: [HTTPHeader]?

    public init(expectedHttpHeaders: [HTTPHeader]? = nil) {
        self.expectedHttpHeaders = expectedHttpHeaders
    }

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
        let httpResponse = HTTPResponse(statusCode: httpURLResponse.statusCode, headers: headers)

        // Validate status code is 2xx or 304
        guard httpResponse.category == .success || httpResponse.statusCode == 304 else {
            throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: httpResponse))
        }

        if let expectedHttpHeaders {
            if !expectedHttpHeaders.allSatisfy({ httpResponse.headers[$0.key] == $0.value }) {
                throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: httpResponse))
            }
        }
    }
}
