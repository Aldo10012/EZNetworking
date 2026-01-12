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
        case .bearer(let token):
            return "Bearer \(token)"

        case .basic(let credentials):
            return "Basic \(credentials)"

        case .digest(let credentials):
            return "Digest \(credentials)"

        case .apiKey(let key):
            return "ApiKey \(key)"

        case .oauth1(let credentials):
            return "OAuth \(credentials)"

        case .oauth2(let token, let tokenType):
            return "\(tokenType) \(token)"

        case .aws4(let signature):
            return "AWS4-HMAC-SHA256 \(signature)"

        case .hawk(let credentials):
            return "Hawk \(credentials)"

        case .custom(let value):
            return value
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
        return .custom("\(headerName) \(key)")
    }

    /// Creates a custom authorization with a specific scheme
    public static func custom(scheme: String, credentials: String) -> AuthorizationType {
        return .custom("\(scheme) \(credentials)")
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
        case .oauth2(_, let tokenType):
            return tokenType
        case .aws4:
            return "AWS4-HMAC-SHA256"
        case .hawk:
            return "Hawk"
        case .custom(let value):
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
        case .bearer(let token):
            return token
        case .basic(let credentials):
            return credentials
        case .digest(let credentials):
            return credentials
        case .apiKey(let key):
            return key
        case .oauth1(let credentials):
            return credentials
        case .oauth2(let token, _):
            return token
        case .aws4(let signature):
            return signature
        case .hawk(let credentials):
            return credentials
        case .custom(let value):
            // Extract credentials from custom value (everything after first space)
            if let spaceIndex = value.firstIndex(of: " ") {
                return String(value[value.index(after: spaceIndex)...])
            }
            return ""
        }
    }
}
