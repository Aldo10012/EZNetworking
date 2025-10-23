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
        get { String(data: data, encoding: .utf8) }
        set {
            if let newValue = newValue {
                data = Data(newValue.utf8)
            } else {
                data = Data()
            }
        }
    }

    // MARK: - Internal Initializers
    internal init(name: String, data: Data, filename: String? = nil, mimeType: MimeType) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }

    internal init(name: String, value: String) {
        self.init(name: name, data: Data(value.utf8), filename: nil, mimeType: .plain)
    }
}

public extension MultipartFormPart {
    static func string(name: String, value: String) -> MultipartFormPart {
        MultipartFormPart(name: name, value: value)
    }
    
    static func file(name: String, data: Data, filename: String, mimeType: MimeType) -> MultipartFormPart {
        MultipartFormPart(name: name, data: data, filename: filename, mimeType: mimeType)
    }
}
