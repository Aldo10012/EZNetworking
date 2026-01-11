import Foundation

public protocol Request {
    var httpMethod: HTTPMethod { get }
    var baseUrl: String { get }
    var parameters: [HTTPParameter]? { get }
    var headers: [HTTPHeader]? { get }
    var body: HTTPBody? { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

// default values
public extension Request {
    var timeoutInterval: TimeInterval { 60 }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}

// additions
public extension Request {
    func getURLRequest() -> URLRequest? {
        guard let url = URL(string: baseUrl) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body?.toData()
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy

        if let parameters = parameters {
            try? HTTPParameterEncoder().encodeParameters(for: &request, with: parameters)
        }

        if let headers = headers {
            HTTPHeaderEncoder().encodeHeaders(for: &request, with: headers)
        }

        return request
    }
}

internal struct EZRequest: Request {
    var httpMethod: HTTPMethod
    var baseUrl: String
    var parameters: [HTTPParameter]?
    var headers: [HTTPHeader]?
    var body: HTTPBody?
    var timeoutInterval: TimeInterval
    var cachePolicy: URLRequest.CachePolicy
}
