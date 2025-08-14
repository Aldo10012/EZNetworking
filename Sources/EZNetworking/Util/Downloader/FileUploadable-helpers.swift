import Foundation

struct MultipartBodyBuilder {
    static func createMultipartBody(boundary: String, fileData: Data, fileName: String, mimeType: String) -> Data {
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

enum MimeType {
    static func mimeType(for pathExtension: String) -> String {
        return switch pathExtension.lowercased() {
        case "jpg", "jpeg": "image/jpeg"
        case "png": "image/png"
        case "pdf": "application/pdf"
        case "txt": "text/plain"
        case "mp4": "video/mp4"
        case "mov": "video/quicktime"
        case "json": "application/json"
        default: "application/octet-stream"
        }
    }
}
