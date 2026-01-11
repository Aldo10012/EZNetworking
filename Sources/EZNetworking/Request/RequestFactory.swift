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

    public init() { }

    public func build(httpMethod: HTTPMethod,
               baseUrlString: String,
               parameters: [HTTPParameter]?,
               headers: [HTTPHeader]? = nil,
               body: HTTPBody? = nil,
               timeoutInterval: TimeInterval = 60,
               cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) -> Request {
        return EZRequest(httpMethod: httpMethod, baseUrl: baseUrlString, parameters: parameters, headers: headers, body: body, timeoutInterval: timeoutInterval, cachePolicy: cachePolicy)
    }
}
