import Foundation

public enum HTTPBody {
    case string(_ str: String)
    case dictionary(_ dic: [String: Any])
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

extension HTTPBody: Equatable {
    public static func ==(lhs: HTTPBody, rhs: HTTPBody) -> Bool {
        switch (lhs, rhs) {
        case (.string(let str1), .string(let str2)):
            return str1 == str2
            
        case (.dictionary(let dic1), .dictionary(let dic2)):
            return dictionariesAreEqual(dic1, dic2)
            
        case (.encodable(let encodable1), .encodable(let encodable2)):
            return String(describing: encodable1) == String(describing: encodable2)
            
        case (.data(let data1), .data(let data2)):
            return data1 == data2
            
        case (.fileURL(let url1), .fileURL(let url2)):
            return url1 == url2
            
        case (.jsonString(let json1), .jsonString(let json2)):
            return json1 == json2
            
        case (.base64(let base64Str1), .base64(let base64Str2)):
            return base64Str1 == base64Str2
            
        case (.urlComponents(let components1), .urlComponents(let components2)):
            return components1 == components2
            
        default:
            return false
        }
    }
    
    private static func dictionariesAreEqual(_ dic1: [String: Any], _ dic2: [String: Any]) -> Bool {
        do {
            let data1 = try JSONSerialization.data(withJSONObject: dic1, options: [])
            let data2 = try JSONSerialization.data(withJSONObject: dic2, options: [])
            return data1 == data2
        } catch {
            return false
        }
    }
}
