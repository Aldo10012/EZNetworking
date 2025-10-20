import Foundation

public typealias HTTPBody = Data

public extension HTTPBody {
    static func string(_ str: String) -> Data? {
        str.data(using: .utf8)
    }

    static func dictionary(_ dic: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: dic, options: [])
    }

    static func encodable<T: Encodable>(_ encodable: T) -> Data? {
        do {
            return try JSONEncoder().encode(encodable)
        } catch {
            return nil
        }
    }

    static func fileURL(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    static func jsonString(_ json: String) -> Data? {
        Data(json.utf8)
    }

    static func base64(_ base64String: String) -> Data? {
        Data(base64Encoded: base64String)
    }

    static func urlComponents(_ components: URLComponents) -> Data? {
        guard let query = components.percentEncodedQuery else { return nil }
        return query.data(using: .utf8)
    }
}
