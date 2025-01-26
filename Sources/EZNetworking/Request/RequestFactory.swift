import Foundation

public protocol RequestFactory {
    func build(httpMethod: HTTPMethod,
               baseUrlString: String,
               parameters: [HTTPParameter]?,
               headers: [HTTPHeader]?,
               body: Data?,
               timeoutInterval: TimeInterval) -> Request
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
               body: Data? = nil,
               timeoutInterval: TimeInterval = 60
    ) -> Request {
        return EZRequest(httpMethod: httpMethod, baseUrlString: baseUrlString, parameters: parameters, headers: headers, body: body, timeoutInterval: timeoutInterval)
    }
}
