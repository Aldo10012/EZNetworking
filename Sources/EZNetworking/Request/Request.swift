import Foundation

public protocol Request {
    var httpMethod: HTTPMethod { get }
    var baseUrlString: String { get }
    var parameters: [HTTPParameter]? { get }
    var headers: [HTTPHeader]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
    var cacheStrategy: CacheStrategy { get }
    var additionalHeaders: [HTTPHeader]? { get set }
}

public extension Request {
    var timeoutInterval: TimeInterval { 60 }
    var cacheStrategy: CacheStrategy { .networkOnly }
    var additionalHeaders: [HTTPHeader]? { nil }

    var urlRequest: URLRequest? {
        guard let url = URL(string: baseUrlString) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cacheStrategy.urlRequestCachePolicy

        if let parameters = parameters {
            try? HTTPParameterEncoderImpl().encodeParameters(for: &request, with: parameters)
        }

        if let headers = headers {
            if let additionalHeaders = additionalHeaders {
                HTTPHeaderEncoderImpl().encodeHeaders(for: &request, with: headers + additionalHeaders)
            } else {
                HTTPHeaderEncoderImpl().encodeHeaders(for: &request, with: headers)
            }
        }

        return request
    }
    
    var etagKey: String {
        let url: String = urlRequest?.url?.absoluteString ?? ""
        return "HTTPMethod=\(httpMethod.rawValue)_URL=\(url)"
    }
}

internal struct EZRequest: Request {
    var httpMethod: HTTPMethod
    var baseUrlString: String
    var parameters: [HTTPParameter]?
    var headers: [HTTPHeader]?
    var body: Data?
    var timeoutInterval: TimeInterval
    var cacheStrategy: CacheStrategy
    var additionalHeaders: [HTTPHeader]?
}
