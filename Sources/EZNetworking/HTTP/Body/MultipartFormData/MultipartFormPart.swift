import Foundation

public struct MultipartFormPart {
    /// The form field name.
    /// The field’s name in the form, like “profile_picture” or “description.”
    public var name: String
    /// Part payload bytes.
    /// The actual data to be sent, whether it’s text or binary.
    public var data: Data
    /// Optional filename (present for file parts).
    /// If the data is a file, this is the name the server will recognize.
    /// Example: protifle_picture.png
    public var filename: String?
    /// Optional content type (e.g. "image/png" or "text/plain; charset=utf-8").
    /// Describes what kind of data it is, such as “image/jpeg” or “text/plain.”
    public var mimeType: MimeType
    
    /// content length of the data part which is crucial one/
    public var contentLength: Int {
        data.count
    }
    
    public var value: String? {
        get {
            return autoreleasepool { String(bytes: self.data, encoding: .utf8) }
        }
        set {
            autoreleasepool {
                guard let value = newValue else {
                    self.data = Data()
                    return
                }
                
                self.data = value.data(using: .utf8, allowLossyConversion: true)!
            }
        }
    }
    
    public init(name: String, data: Data, filename: String? = nil, mimeType: MimeType) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }
    
    public init(name: String, value: String, mimeType: MimeType = .plain) {
        let data = value.data(using: .utf8, allowLossyConversion: true)!
        self.init(name: name, data: data, filename: nil, mimeType: mimeType)
    }
}
