import Foundation

public enum MimeType: Equatable {
    // MARK: - Application Types
    case json
    case xml
    case formUrlEncoded
    case multipartFormData
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
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .formUrlEncoded: return "application/x-www-form-urlencoded"
        case .multipartFormData: return "multipart/form-data"
        case .pdf: return "application/pdf"
        case .zip: return "application/zip"
        case .octetStream: return "application/octet-stream"
        case .javascript: return "application/javascript"
        case .wasm: return "application/wasm"
        
        // Text Types
        case .plain: return "text/plain"
        case .html: return "text/html"
        case .css: return "text/css"
        case .csv: return "text/csv"
        case .rtf: return "text/rtf"
        case .xmlText: return "text/xml"
        
        // Image Types
        case .jpeg: return "image/jpeg"
        case .png: return "image/png"
        case .gif: return "image/gif"
        case .webp: return "image/webp"
        case .svg: return "image/svg+xml"
        case .bmp: return "image/bmp"
        case .ico: return "image/x-icon"
        case .tiff: return "image/tiff"
        
        // Video Types
        case .mp4: return "video/mp4"
        case .avi: return "video/x-msvideo"
        case .mov: return "video/quicktime"
        case .wmv: return "video/x-ms-wmv"
        case .flv: return "video/x-flv"
        case .webm: return "video/webm"
        case .mkv: return "video/x-matroska"
        case .quicktime: return "video/quicktime"
        
        // Audio Types
        case .mp3: return "audio/mpeg"
        case .wav: return "audio/wav"
        case .ogg: return "audio/ogg"
        case .aac: return "audio/aac"
        case .flac: return "audio/flac"
        case .m4a: return "audio/mp4"
        case .wma: return "audio/x-ms-wma"
        
        // Font Types
        case .ttf: return "font/ttf"
        case .otf: return "font/otf"
        case .woff: return "font/woff"
        case .woff2: return "font/woff2"
        case .eot: return "application/vnd.ms-fontobject"
        
        // Custom
        case .custom(let value): return value
        }
    }
}
