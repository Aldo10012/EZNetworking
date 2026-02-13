import Foundation

public struct SSERequest: Request {
    public var baseUrl: String
    public var additionalheaders: [HTTPHeader]?

    /// Last event ID received; sent as `Last-Event-ID` header on reconnect per SSE spec.
    private var lastEventId: String?

    public init(url: String, additionalheaders: [HTTPHeader]? = nil) {
        baseUrl = url
        self.additionalheaders = additionalheaders
    }

    public var headers: [HTTPHeader]? {
        var sseHeaders: [HTTPHeader] = [
            HTTPHeader.accept(.eventStream),
            HTTPHeader.cacheControl("no_cache"),
            HTTPHeader.connection("keep_alive")
        ]
        if let lastEventId {
            sseHeaders.append(HTTPHeader.lastEventID(lastEventId))
        }
        if let additionalheaders {
            sseHeaders += additionalheaders
        }
        return sseHeaders
    }

    public var httpMethod: HTTPMethod { .GET }
    public var parameters: [HTTPParameter]? { nil }
    public var body: (any HTTPBody)? { nil }
    public var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalCacheData }
    public var timeoutInterval: TimeInterval { 60 } // 1 minute

    mutating func setLastEventId(_ id: String?) {
        lastEventId = id
    }
}
