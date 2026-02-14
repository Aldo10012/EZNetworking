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
extension Request {
    public var timeoutInterval: TimeInterval { 60 }
    public var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}

// additions
extension Request {
    public func getURLRequest(allowedSchemes: URLBuilder.URLSchemePolicy = .http) throws -> URLRequest {
        let url = try URLBuilder(allowedSchemes: allowedSchemes).buildAndValidate(baseUrl)

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body?.toData()
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy

        if let parameters {
            HTTPParameterApplier.apply(parameters, to: &request)
        }

        if let headers {
            HTTPHeaderApplier.apply(headers, to: &request)
        }

        return request
    }
}
