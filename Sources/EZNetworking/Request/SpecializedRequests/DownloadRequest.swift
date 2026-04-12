import Foundation

public struct DownloadRequest: Request {
    public var baseUrl: String
    public var additionalheaders: [HTTPHeader]?

    public init(url: String, additionalheaders: [HTTPHeader]? = nil) {
        baseUrl = url
        self.additionalheaders = additionalheaders
    }

    public var headers: [HTTPHeader]? { additionalheaders }

    public var httpMethod: HTTPMethod { .GET }
    public var parameters: [HTTPParameter]? { nil }
    public var body: (any HTTPBody)? { nil }
}
