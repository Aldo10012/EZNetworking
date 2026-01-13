import Foundation

public struct URLBuilder {
    public enum URLSchemePolicy {
        /// Support http and https schemes
        case http
        /// Support ws and wss schemes
        case ws

        public var values: Set<String> {
            switch self {
            case .http: ["http", "https"]
            case .ws: ["ws", "wss"]
            }
        }
    }

    private let allowedSchemes: URLSchemePolicy

    public init(allowedSchemes: URLSchemePolicy = .http) {
        self.allowedSchemes = allowedSchemes
    }

    public func buildAndValidate(_ urlString: String) throws -> URL {
        guard !urlString.isEmpty else {
            throw NetworkingError.internalError(.noURL)
        }
        guard let url = URL(string: urlString) else {
            throw NetworkingError.internalError(.invalidURL)
        }
        guard let scheme = url.scheme?.lowercased(), allowedSchemes.values.contains(scheme) else {
            throw NetworkingError.internalError(.invalidScheme(url.scheme))
        }
        guard url.host != nil else {
            throw NetworkingError.internalError(.missingHost)
        }
        return url
    }
}
