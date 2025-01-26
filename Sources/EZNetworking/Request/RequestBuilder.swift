import Foundation

public protocol RequestBuilder {
    func setHttpMethod(_ method: HTTPMethod) -> RequestBuilder
    func setBaseUrl(_ baseUrl: String) -> RequestBuilder
    func setParameters(_ parameters: [HTTPParameter]) -> RequestBuilder
    func setHeaders(_ headers: [HTTPHeader]) -> RequestBuilder
    func setBody(_ body: Data) -> RequestBuilder
    func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> RequestBuilder
    func build() -> Request?
}

public class RequestBuilderImpl: RequestBuilder {
    private var httpMethod: HTTPMethod?
    private var baseUrlString: String?
    private var parameters: [HTTPParameter]?
    private var headers: [HTTPHeader]?
    private var body: Data?
    private var timeoutInterval: TimeInterval?

    private let headerEncoder: HTTPHeaderEncoder
    private let paramEncoder: HTTPParameterEncoder

    public init(headerEncoder: HTTPHeaderEncoder = HTTPHeaderEncoderImpl(),
                paramEncoder: HTTPParameterEncoder = HTTPParameterEncoderImpl()) {
        self.headerEncoder = headerEncoder
        self.paramEncoder = paramEncoder
    }

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

    public func setBody(_ body: Data) -> RequestBuilder {
        self.body = body
        return self
    }

    public func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> RequestBuilder {
        self.timeoutInterval = timeoutInterval
        return self
    }

    public func build() -> Request? {
        guard let httpMethod, let baseUrlString else { return nil }
        return EZRequest(httpMethod: httpMethod, baseUrlString: baseUrlString, parameters: parameters, headers: headers, body: body, timeoutInterval: timeoutInterval ?? 60)
    }
}
