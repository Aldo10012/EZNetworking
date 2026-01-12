import Foundation

public struct WebSocketRequest: Request {
    public var baseUrl: String
    public var protocols: [String]?
    public var additionalheaders: [HTTPHeader]?

    public init(url: String, protocols: [String]? = nil, additionalheaders: [HTTPHeader]? = nil) {
        self.baseUrl = url
        self.protocols = protocols
        self.additionalheaders = additionalheaders
    }

    public var headers: [HTTPHeader]? {
        var headers = [HTTPHeader]()
        if let protocols = protocols {
            headers.append(.secWebSocketProtocol(protocols))
        }
        if let additionalheaders = additionalheaders {
            headers += additionalheaders
        }
        return !headers.isEmpty ? headers :  nil
    }

    public var httpMethod: HTTPMethod { .GET }
    public var parameters: [HTTPParameter]? { nil }
    public var body: (any HTTPBody)? { nil }
    public var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalCacheData }
}
