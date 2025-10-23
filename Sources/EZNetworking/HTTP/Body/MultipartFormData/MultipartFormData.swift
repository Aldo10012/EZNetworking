import Foundation

public class MultipartFormData: DataConvertible {
    
    // MARK: Variables

    public let boundary: String
    
    // MARK: Init
    
    public init(boundary: String) {
        self.boundary = boundary
    }
    
    // MARK: Data
    
    public func toData() -> Data? {
        // TODO: implement
        return nil
    }
}
