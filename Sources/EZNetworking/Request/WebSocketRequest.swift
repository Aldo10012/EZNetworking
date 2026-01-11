import Foundation

public protocol WebSocketRequest: Request {
    var protocols: [String]? { get }
    var additionalheaders: [HTTPHeader]? { get }
}

public extension WebSocketRequest {
    var httpMethod: HTTPMethod { .GET }
    var parameters: [HTTPParameter]? { nil }
    var body: (any HTTPBody)? { nil }
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalCacheData }
    
    var headers: [HTTPHeader]? {
        var headers = [HTTPHeader]()
        if let protocols = protocols {
            headers.append(.secWebSocketProtocol(protocols))
        }
        if let additionalheaders = additionalheaders {
            headers += additionalheaders
        }
        return !headers.isEmpty ? headers :  nil
    }
}

public struct WSRequest: WebSocketRequest {
    public var baseUrlString: String
    public var protocols: [String]?
    public var additionalheaders: [HTTPHeader]?
    
    public init(url: String, protocols: [String]? = nil, additionalheaders: [HTTPHeader]? = nil) {
        self.baseUrlString = url
        self.protocols = protocols
        self.additionalheaders = additionalheaders
    }
}
