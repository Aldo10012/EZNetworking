import Foundation

public enum HTTPHeader: Equatable {
    case accept(MimeType)
    case acceptCharset(String)
    case acceptEncoding(String)
    case acceptLanguage(String)
    case authorization(AuthorizationType)
    case cacheControl(String)
    case connection(String)
    case contentLength(String)
    case contentType(MimeType)
    case cookie(String)
    case host(String)
    case ifModifiedSince(String)
    case ifNoneMatch(String)
    case origin(String)
    case referer(String)
    case userAgent(String)
    case secWebSocketProtocol([String])
    case custom(key: String, value: String)

    var key: String {
        switch self {
        case .accept: "Accept"
        case .acceptCharset: "Accept-Charset"
        case .acceptEncoding: "Accept-Encoding"
        case .acceptLanguage: "Accept-Language"
        case .authorization: "Authorization"
        case .cacheControl: "Cache-Control"
        case .connection: "Connection"
        case .contentLength: "Content-Length"
        case .contentType: "Content-Type"
        case .cookie: "Cookie"
        case .host: "Host"
        case .ifModifiedSince: "If-Modified-Since"
        case .ifNoneMatch: "If-None-Match"
        case .origin: "Origin"
        case .referer: "Referer"
        case .userAgent: "User-Agent"
        case .secWebSocketProtocol: "Sec-WebSocket-Protocol"
        case let .custom(key, _): key
        }
    }

    var value: String {
        switch self {
        case let .accept(accept): accept.value
        case let .acceptCharset(value): value
        case let .acceptEncoding(value): value
        case let .acceptLanguage(value): value
        case let .authorization(authentication): authentication.value
        case let .cacheControl(value): value
        case let .connection(value): value
        case let .contentLength(value): value
        case let .contentType(contentType): contentType.value
        case let .cookie(value): value
        case let .host(value): value
        case let .ifModifiedSince(value): value
        case let .ifNoneMatch(value): value
        case let .origin(value): value
        case let .referer(value): value
        case let .userAgent(value): value
        case let .secWebSocketProtocol(protocols): protocols.joined(separator: ", ")
        case let .custom(_, value): value
        }
    }
}
