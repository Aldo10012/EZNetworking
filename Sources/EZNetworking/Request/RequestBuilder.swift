import Foundation

public protocol RequestBuilder {
    func setHttpMethod(_ method: HTTPMethod) -> RequestBuilder
    func setBaseUrl(_ baseUrl: String) -> RequestBuilder
    func setParameters(_ parameters: [HTTPParameter]) -> RequestBuilder
    func setHeaders(_ headers: [HTTPHeader]) -> RequestBuilder
    func setBody(_ body: Data) -> RequestBuilder
    func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> RequestBuilder
    func build() -> URLRequest?
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

    public func build() -> URLRequest? {
        guard let baseUrlString = baseUrlString,
              let httpMethod = httpMethod,
              let url = URL(string: baseUrlString) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }

        if let parameters = parameters {
            try? paramEncoder.encodeParameters(for: &request, with: parameters)
        }

        if let headers = headers {
            headerEncoder.encodeHeaders(for: &request, with: headers)
        }

        return request
    }
}
