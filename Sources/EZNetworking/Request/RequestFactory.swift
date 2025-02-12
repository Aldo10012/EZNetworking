import Foundation

public protocol RequestFactory {
    func build(httpMethod: HTTPMethod,
               baseUrlString: String,
               parameters: [HTTPParameter]?,
               headers: [HTTPHeader]?,
               body: HTTPBody?,
               timeoutInterval: TimeInterval,
               cachePolicy: URLRequest.CachePolicy) -> Request
}

public class RequestFactoryImpl: RequestFactory {
    private let headerEncoder: HTTPHeaderEncoder
    private let paramEncoder: HTTPParameterEncoder

    public init(headerEncoder: HTTPHeaderEncoder = HTTPHeaderEncoderImpl(),
         paramEncoder: HTTPParameterEncoder = HTTPParameterEncoderImpl()) {
        self.headerEncoder = headerEncoder
        self.paramEncoder = paramEncoder
    }

    public func build(httpMethod: HTTPMethod,
               baseUrlString: String,
               parameters: [HTTPParameter]?,
               headers: [HTTPHeader]? = nil,
               body: HTTPBody? = nil,
               timeoutInterval: TimeInterval = 60,
               cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) -> Request {
        return EZRequest(httpMethod: httpMethod, baseUrlString: baseUrlString, parameters: parameters, headers: headers, body: body, timeoutInterval: timeoutInterval, cachePolicy: cachePolicy)
    }
}
