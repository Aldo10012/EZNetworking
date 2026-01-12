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
    func getURLRequest(allowedSchemes: URLBuilder.URLSchemePolicy = .http) throws -> URLRequest {
        let url = try URLBuilder(allowedSchemes: allowedSchemes).buildAndValidate(baseUrl)

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body?.toData()
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy

        if let parameters = parameters {
            HTTPParameterApplier.apply(parameters, to: &request)
        }

        if let headers = headers {
            HTTPHeaderApplier.apply(headers, to: &request)
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

// TODO: move to another file

public struct URLBuilder {
    public enum URLSchemePolicy {
        /// Support http and https schemes
        case http
        /// Support ws and wss schemes
        case ws
        
        public var values: Set<String> {
            switch self {
            case .http: ["http", "https"]
            case .ws: ["ws", "wss"]
            }
        }
    }
    
    private let allowedSchemes: URLSchemePolicy
    
    public init(allowedSchemes: URLSchemePolicy = .http) {
        self.allowedSchemes = allowedSchemes
    }
    
    public func buildAndValidate(_ urlString: String) throws -> URL {
        guard !urlString.isEmpty else {
            throw NetworkingError.internalError(.noURL)
        }
        guard let url = URL(string: urlString) else {
            throw NetworkingError.internalError(.invalidURL)
        }
        guard let scheme = url.scheme?.lowercased(), allowedSchemes.values.contains(scheme) else {
            throw NetworkingError.internalError(.invalidScheme(url.scheme))
        }
        
        guard url.host != nil else {
            throw NetworkingError.internalError(.missingHost)
        }
        return url
    }
}
