import Foundation

public enum AuthorizationType: Equatable {
    // MARK: - Standard Authorization Types

    /// Bearer token authentication (OAuth 2.0, JWT)
    case bearer(String)

    /// Basic authentication (username:password base64 encoded)
    case basic(String)

    /// Digest authentication
    case digest(String)

    /// API Key authentication
    case apiKey(String)

    /// OAuth 1.0 authentication
    case oauth1(String)

    /// OAuth 2.0 with different token types
    case oauth2(String, tokenType: String = "Bearer")

    /// AWS Signature Version 4
    case aws4(String)

    /// Hawk authentication
    case hawk(String)

    /// Custom authorization header value
    case custom(String)

    // MARK: - Computed Properties

    var value: String {
        switch self {
        // Standard Authorization Types
        case let .bearer(token):
            "Bearer \(token)"

        case let .basic(credentials):
            "Basic \(credentials)"

        case let .digest(credentials):
            "Digest \(credentials)"

        case let .apiKey(key):
            "ApiKey \(key)"

        case let .oauth1(credentials):
            "OAuth \(credentials)"

        case let .oauth2(token, tokenType):
            "\(tokenType) \(token)"

        case let .aws4(signature):
            "AWS4-HMAC-SHA256 \(signature)"

        case let .hawk(credentials):
            "Hawk \(credentials)"

        case let .custom(value):
            value
        }
    }

    // MARK: - Convenience Initializers

    /// Creates a Basic authorization with username and password
    public static func basic(username: String, password: String) -> AuthorizationType {
        let credentials = "\(username):\(password)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        return .basic(base64Credentials)
    }

    /// Creates an API Key authorization with a specific header name
    public static func apiKeyWithHeader(_ key: String, headerName: String = "X-API-Key") -> AuthorizationType {
        .custom("\(headerName) \(key)")
    }

    /// Creates a custom authorization with a specific scheme
    public static func custom(scheme: String, credentials: String) -> AuthorizationType {
        .custom("\(scheme) \(credentials)")
    }
}

// MARK: - AuthorizationType Extensions

extension AuthorizationType {
    /// Returns the authorization scheme (e.g., "Bearer", "Basic", "Digest")
    public var scheme: String {
        switch self {
        case .bearer:
            return "Bearer"
        case .basic:
            return "Basic"
        case .digest:
            return "Digest"
        case .apiKey:
            return "ApiKey"
        case .oauth1:
            return "OAuth"
        case let .oauth2(_, tokenType):
            return tokenType
        case .aws4:
            return "AWS4-HMAC-SHA256"
        case .hawk:
            return "Hawk"
        case let .custom(value):
            // Extract scheme from custom value (everything before first space)
            if let spaceIndex = value.firstIndex(of: " ") {
                return String(value[..<spaceIndex])
            }
            return value
        }
    }

    /// Returns the credentials part (everything after the scheme)
    public var credentials: String {
        switch self {
        case let .bearer(token):
            return token
        case let .basic(credentials):
            return credentials
        case let .digest(credentials):
            return credentials
        case let .apiKey(key):
            return key
        case let .oauth1(credentials):
            return credentials
        case let .oauth2(token, _):
            return token
        case let .aws4(signature):
            return signature
        case let .hawk(credentials):
            return credentials
        case let .custom(value):
            // Extract credentials from custom value (everything after first space)
            if let spaceIndex = value.firstIndex(of: " ") {
                return String(value[value.index(after: spaceIndex)...])
            }
            return ""
        }
    }
}
