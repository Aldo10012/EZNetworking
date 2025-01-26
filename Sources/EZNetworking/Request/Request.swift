import Foundation

public protocol Request {
    var httpMethod: HTTPMethod { get }
    var baseUrlString: String { get }
    var parameters: [HTTPParameter]? { get }
    var headers: [HTTPHeader]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

public extension Request {
    var timeoutInterval: TimeInterval { 60 }
}

internal extension Request {
    func build() -> URLRequest {
        return RequestFactoryImpl()
            .build(httpMethod: httpMethod,
                   baseUrlString: baseUrlString,
                   parameters: parameters,
                   headers: headers,
                   body: body,
                   timeoutInterval: timeoutInterval
            )!
    }
}
