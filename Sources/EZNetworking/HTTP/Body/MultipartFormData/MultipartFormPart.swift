import Foundation

/// Represents a single body part in a `multipart/form-data` HTTP request.
public struct MultipartFormPart {
    /// The form field name associated with this part.
    public var name: String

    /// The raw binary data representing the body of this part.
    public var data: Data

    /// An optional filename to include in the `Content-Disposition` header.
    public var filename: String?

    /// The MIME type describing the content of the data payload.
    public var mimeType: MimeType

    /// The total size of the data payload, in bytes.
    public var contentLength: Int { data.count }

    /// The payload interpreted as a UTF-8 string.
    public var value: String? {
        get { String(data: data, encoding: .utf8) }
        set { data = newValue.map { Data($0.utf8) } ?? Data() }
    }

    // MARK: - Internal Initializers

    /// Creates a new multipart form part with binary data.
    internal init(name: String, data: Data, filename: String? = nil, mimeType: MimeType) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }

    /// Creates a new multipart form part from a plain text value.
    internal init(name: String, value: String) {
        self.init(name: name, data: Data(value.utf8), filename: nil, mimeType: .plain)
    }
}

// MARK: - Creation static methods

public extension MultipartFormPart {
    /// Creates a text field part with a UTF-8 encoded value.
    static func field(name: String, value: String) -> MultipartFormPart {
        MultipartFormPart(name: name, value: value)
    }
    
    /// Creates a file upload part with binary data and metadata.
    static func file(name: String, data: Data, filename: String, mimeType: MimeType) -> MultipartFormPart {
        MultipartFormPart(name: name, data: data, filename: filename, mimeType: mimeType)
    }
}
