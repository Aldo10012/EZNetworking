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
    
    // MARK: Variables
    
    public let boundary: String
    public let parts: [MultipartFormPart]
    
    // MARK: Init
    
    public init(parts: [MultipartFormPart], boundary: String? = nil) {
        self.parts = parts
        self.boundary = boundary ?? BoundaryGenerator.randomBoundary()
    }
    
    // MARK: Data
    
    public var data: Data? {
        var data = Data()
        
        // 1️⃣ Append initial boundary
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .initial, boundary: boundary))

        // 2️⃣ Append each form part
        for (index, part) in parts.enumerated() {
            var headers = "Content-Disposition: form-data; name=\"\(part.name)\""
            
            // Include filename if this part is a file
            if let filename = part.filename {
                headers += "; filename=\"\(filename)\""
            }
            
            headers += EncodingCharacters.crlf
            
            // Include Content-Type header if present
            headers += "Content-Type: \(part.mimeType.value)\(EncodingCharacters.crlf)\(EncodingCharacters.crlf)"
            
            // Add headers as Data
            data.append(Data(headers.utf8))
            
            // Add the actual data payload
            data.append(part.data)
            
            // If not the last part, add an encapsulated boundary
            if index < parts.count - 1 {
                data.append(BoundaryGenerator.boundaryData(forBoundaryType: .encapsulated, boundary: boundary))
            }
        }
        
        // 3️⃣ Append final boundary
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .final, boundary: boundary))
        
        return data
    }

}
