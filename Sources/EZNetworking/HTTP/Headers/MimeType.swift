import Foundation

public enum MimeType: Equatable {
    // MARK: - Application Types

    case json
    case xml
    case formUrlEncoded
    case multipartFormData(boundary: String)
    case pdf
    case zip
    case octetStream
    case javascript
    case wasm

    // MARK: - Text Types

    case plain
    case html
    case css
    case csv
    case rtf
    case xmlText

    // MARK: - Image Types

    case jpeg
    case png
    case gif
    case webp
    case svg
    case bmp
    case ico
    case tiff

    // MARK: - Video Types

    case mp4
    case avi
    case mov
    case wmv
    case flv
    case webm
    case mkv
    case quicktime

    // MARK: - Audio Types

    case mp3
    case wav
    case ogg
    case aac
    case flac
    case m4a
    case wma

    // MARK: - Font Types

    case ttf
    case otf
    case woff
    case woff2
    case eot

    // MARK: - Custom

    case custom(String)

    var value: String {
        switch self {
        // Application Types
        case .json: "application/json"
        case .xml: "application/xml"
        case .formUrlEncoded: "application/x-www-form-urlencoded"
        case let .multipartFormData(boundary): "multipart/form-data; boundary=\(boundary)"
        case .pdf: "application/pdf"
        case .zip: "application/zip"
        case .octetStream: "application/octet-stream"
        case .javascript: "application/javascript"
        case .wasm: "application/wasm"
        // Text Types
        case .plain: "text/plain"
        case .html: "text/html"
        case .css: "text/css"
        case .csv: "text/csv"
        case .rtf: "text/rtf"
        case .xmlText: "text/xml"
        // Image Types
        case .jpeg: "image/jpeg"
        case .png: "image/png"
        case .gif: "image/gif"
        case .webp: "image/webp"
        case .svg: "image/svg+xml"
        case .bmp: "image/bmp"
        case .ico: "image/x-icon"
        case .tiff: "image/tiff"
        // Video Types
        case .mp4: "video/mp4"
        case .avi: "video/x-msvideo"
        case .mov: "video/quicktime"
        case .wmv: "video/x-ms-wmv"
        case .flv: "video/x-flv"
        case .webm: "video/webm"
        case .mkv: "video/x-matroska"
        case .quicktime: "video/quicktime"
        // Audio Types
        case .mp3: "audio/mpeg"
        case .wav: "audio/wav"
        case .ogg: "audio/ogg"
        case .aac: "audio/aac"
        case .flac: "audio/flac"
        case .m4a: "audio/mp4"
        case .wma: "audio/x-ms-wma"
        // Font Types
        case .ttf: "font/ttf"
        case .otf: "font/otf"
        case .woff: "font/woff"
        case .woff2: "font/woff2"
        case .eot: "application/vnd.ms-fontobject"
        // Custom
        case let .custom(value): value
        }
    }
}
