import Foundation

public protocol ResponseValidator {
    func validateStatus(from urlResponse: URLResponse) throws
}

public struct DefaultResponseValidator: ResponseValidator {
    private let expectedHttpHeaders: [HTTPHeader]?

    public init(expectedHttpHeaders: [HTTPHeader]? = nil) {
        self.expectedHttpHeaders = expectedHttpHeaders
    }

    public func validateStatus(from urlResponse: URLResponse) throws {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse)
        }
        let httpResponse = convert(httpURLResponse)

        guard httpResponse.category == .success || httpResponse.statusCode == 304 else {
            throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: httpResponse))
        }

        guard responseContainsAllExpectedHttpHeaders(httpResponse: httpResponse) else {
            throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: httpResponse))
        }
    }

    private func convert(_ httpURLResponse: HTTPURLResponse) -> HTTPResponse {
        // Convert headers from [AnyHashable: Any] to [String: String]
        let headers = httpURLResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
            if let key = pair.key as? String, let value = pair.value as? String {
                result[key] = value
            }
        }
        return HTTPResponse(statusCode: httpURLResponse.statusCode, headers: headers)
    }

    private func responseContainsAllExpectedHttpHeaders(httpResponse: HTTPResponse) -> Bool {
        guard let expectedHttpHeaders else {
            return true
        }
        if !expectedHttpHeaders.allSatisfy({ httpResponse.headers[$0.key] == $0.value }) {
            return false
        }
        return true
    }
}
