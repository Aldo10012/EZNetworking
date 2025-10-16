import Foundation

internal struct MultipartFormDataBuilder {
    static func buildBody(parts: [MultipartFormPart], boundary: String) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        for part in parts {
            switch part {
            case .data(let name, let filename, let mimeType, let data):
                body.append(boundaryPrefix.data(using: .utf8)!)
                var disposition = "Content-Disposition: form-data; name=\"\(name)\""
                if let filename { disposition += "; filename=\"\(filename)\"" }
                disposition += "\r\n"
                body.append(disposition.data(using: .utf8)!)
                if let mimeType {
                    body.append("Content-Type: \(mimeType)\r\n".data(using: .utf8)!)
                }
                body.append("\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}


