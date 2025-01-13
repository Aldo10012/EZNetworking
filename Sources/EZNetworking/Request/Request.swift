import Foundation

public protocol Request {
    var httpMethod: HTTPMethod { get }
    var baseUrlString: String { get }
    var parameters: [HTTPParameter]? { get }
    var header: [HTTPHeader]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

public extension Request {
    var timeoutInterval: TimeInterval { 60 }
}

internal extension Request {
    func build() -> URLRequest? {
        RequestBuilder().build(httpMethod: httpMethod,
                               baseUrlString: baseUrlString,
                               parameters: parameters,
                               headers: header,
                               body: body,
                               timeoutInterval: timeoutInterval)
    }
}
