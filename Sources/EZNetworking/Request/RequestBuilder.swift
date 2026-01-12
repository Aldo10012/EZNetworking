import Foundation

public protocol RequestBuilder {
    func setHttpMethod(_ method: HTTPMethod) -> RequestBuilder
    func setBaseUrl(_ baseUrl: String) -> RequestBuilder
    func setParameters(_ parameters: [HTTPParameter]) -> RequestBuilder
    func setHeaders(_ headers: [HTTPHeader]) -> RequestBuilder
    func setBody(_ body: HTTPBody) -> RequestBuilder
    func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> RequestBuilder
    func setCachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> RequestBuilder
    func build() -> Request?
}

public class RequestBuilderImpl: RequestBuilder {
    private var httpMethod: HTTPMethod?
    private var baseUrlString: String?
    private var parameters: [HTTPParameter]?
    private var headers: [HTTPHeader]?
    private var body: HTTPBody? = nil
    private var timeoutInterval: TimeInterval?
    private var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

    public init() { }

    public func setHttpMethod(_ method: HTTPMethod) -> RequestBuilder {
        self.httpMethod = method
        return self
    }

    public func setBaseUrl(_ baseUrl: String) -> RequestBuilder {
        self.baseUrlString = baseUrl
        return self
    }

    public func setParameters(_ parameters: [HTTPParameter]) -> RequestBuilder {
        self.parameters = parameters
        return self
    }

    public func setHeaders(_ headers: [HTTPHeader]) -> RequestBuilder {
        self.headers = headers
        return self
    }

    public func setBody(_ body: HTTPBody) -> RequestBuilder {
        self.body = body
        return self
    }

    public func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> RequestBuilder {
        self.timeoutInterval = timeoutInterval
        return self
    }

    public func setCachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> RequestBuilder {
        self.cachePolicy = cachePolicy
        return self
    }

    public func build() -> Request? {
        guard let httpMethod, let baseUrlString else { return nil }
        return EZRequest(httpMethod: httpMethod, baseUrl: baseUrlString, parameters: parameters, headers: headers, body: body, timeoutInterval: timeoutInterval ?? 60, cachePolicy: cachePolicy)
    }
}
