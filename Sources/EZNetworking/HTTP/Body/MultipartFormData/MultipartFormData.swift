import Foundation

public class MultipartFormData: DataConvertible {
    
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
