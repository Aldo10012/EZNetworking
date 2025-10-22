import Foundation

/// A single part in a multipart/form-data HTTP body.
public struct MultipartFormPart {
    /// The form field name.
    public var name: String

    /// The raw bytes for this part.
    public var data: Data

    /// Optional filename for file parts; nil for simple fields.
    public var filename: String?

    /// The MIME type for this part's payload.
    public var mimeType: MimeType

    /// Number of bytes in the payload.
    public var contentLength: Int { data.count }

    /// Payload decoded as UTF-8 string, or nil if decoding fails.
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

    /// Designated initializer with full metadata.
    public init(name: String, data: Data, filename: String? = nil, mimeType: MimeType) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }

    /// Convenience initializer for text fields (UTF-8).
    public init(name: String, value: String, mimeType: MimeType = .plain) {
        let data = value.data(using: .utf8, allowLossyConversion: true)!
        self.init(name: name, data: data, filename: nil, mimeType: mimeType)
    }
}
