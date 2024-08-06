import Foundation

public protocol RequestBuildable {
    func build(httpMethod: HTTPMethod,
               urlString: String,
               parameters: [HTTPParameter]?,
               headers: [HTTPHeader]?,
               body: Data?,
               timeoutInterval: TimeInterval) -> URLRequest?
}

public class RequestBuilder: RequestBuildable {
    private let headerEncoder: HTTPHeaderEncoder
    private let paramEncoder: HTTPParameterEncoder

    public init(headerEncoder: HTTPHeaderEncoder = HTTPHeaderEncoderImpl(),
         paramEncoder: HTTPParameterEncoder = HTTPParameterEncoderImpl()) {
        self.headerEncoder = headerEncoder
        self.paramEncoder = paramEncoder
    }

    public func build(httpMethod: HTTPMethod,
               urlString: String,
               parameters: [HTTPParameter]?,
               headers: [HTTPHeader]? = nil,
               body: Data? = nil,
               timeoutInterval: TimeInterval = 60
    ) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.timeoutInterval = timeoutInterval

        if let parameters = parameters {
            try? paramEncoder.encodeParameters(for: &request, with: parameters)
        }

        if let headers = headers {
            headerEncoder.encodeHeaders(for: &request, with: headers)
        }

        return request
    }
}
