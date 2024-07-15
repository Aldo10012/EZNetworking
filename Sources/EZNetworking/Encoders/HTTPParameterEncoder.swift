import Foundation

protocol HTTPParameterEncoder {
    func encodeParameters(for urlRequest: inout URLRequest, with parameters: [HTTPParameter]) throws
}

struct HTTPParameterEncoderImpl: HTTPParameterEncoder {
    init() {}
    func encodeParameters(for urlRequest: inout URLRequest, with parameters: [HTTPParameter]) throws {
        guard let url = urlRequest.url else {
            throw NetworkingError.noURL
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            for param in parameters {
                let queryItem = URLQueryItem(name: param.key, value: "\(param.value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
    }
}
