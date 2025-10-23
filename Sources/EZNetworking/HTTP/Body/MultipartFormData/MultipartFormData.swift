import Foundation

public class MultipartFormData {
    
    // MARK: - Helper Types
    
    enum EncodingCharacters {
        static let crlf = "\r\n"
    }
    
    enum BoundaryGenerator {
        enum BoundaryType {
            case initial, encapsulated, final
        }
        
        static func randomBoundary() -> String {
            return String.getRandomMultiPartFormBoundary()
        }
        
        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
            let boundaryText = switch boundaryType {
            case .initial:
                "--\(boundary)\(EncodingCharacters.crlf)"
            case .encapsulated:
                "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
            case .final:
                "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
            }
            
            return Data(boundaryText.utf8)
        }
    }
    
    // MARK: Init
    
    public init() {
        // TODO: add details
    }
    
    // MARK: Data
    
    public var data: Data? {
        // TODO: add details
        return nil
    }

}
