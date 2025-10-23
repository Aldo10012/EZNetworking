import Foundation

public class MultipartFormData: DataConvertible {
    
    // MARK: - Helper Types
    
    enum Constants {
        static let crlf = "\r\n"
    }
    
    enum BoundaryGenerator {
        enum BoundaryType {
            case initial, encapsulated, final
        }
        
        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
            let boundaryText = switch boundaryType {
            case .initial:
                "--\(boundary)\(Constants.crlf)"
            case .encapsulated:
                "\(Constants.crlf)--\(boundary)\(Constants.crlf)"
            case .final:
                "\(Constants.crlf)--\(boundary)--\(Constants.crlf)"
            }
            return Data(boundaryText.utf8)
        }
    }
    
    // MARK: Variables

    public let parts: [MultipartFormPart]
    public let boundary: String
    
    // MARK: Init
    
    public init(parts: [MultipartFormPart], boundary: String) {
        self.parts = parts
        self.boundary = boundary
    }
    
    // MARK: Data
    
    public func toData() -> Data? {
        // TODO: implement
        return nil
    }
}
