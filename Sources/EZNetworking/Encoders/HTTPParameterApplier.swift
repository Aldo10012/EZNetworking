import Foundation

struct HTTPParameterApplier {
    private init() {}
    
    static func apply(_ parameters: [HTTPParameter], to urlRequest: inout URLRequest) {
        guard !parameters.isEmpty,
              let url = urlRequest.url,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlRequest.url = urlComponents.url
    }
}
