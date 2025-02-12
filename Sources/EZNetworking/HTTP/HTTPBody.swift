import Foundation

public enum HTTPBody {
    case string(_ str: String)
    case dictionary(_ dic: Dictionary<String, Any>)
    case encodable(_ encodable: Encodable)
    case data(_ data: Data)
    case fileURL(_ url: URL)
    case jsonString(_ json: String)
    case base64(_ base64String: String)
    case urlComponents(_ components: URLComponents)
    
    var data: Data? {
        switch self {
        case .string(let string):
            return string.data(using: .utf8)
            
        case .dictionary(let dictionary):
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                return data
            } catch {
                return nil
            }
            
        case .encodable(let encodable):
            do {
                let data = try JSONEncoder().encode(encodable)
                return data
            } catch {
                return nil
            }
            
        case .data(let data):
            return data
            
        case .fileURL(let url):
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                return nil
            }
            
        case .jsonString(let json):
            return Data(json.utf8)
            
        case .base64(let base64String):
            if let data = Data(base64Encoded: base64String) {
                return data
            } else {
                return nil
            }
            
        case .urlComponents(let components):
            guard let query = components.percentEncodedQuery else {
                return nil
            }
            return query.data(using: .utf8)
        }
    }
}
