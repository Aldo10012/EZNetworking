import Foundation

public class MultipartFormData: DataConvertible {
    // MARK: - Helper Types

    enum Constants {
        static let crlf = "\r\n"
    }

    enum BoundaryGenerator {
        enum BoundaryType {
            case initial, encapsulated, final
        }

        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
            let boundaryText = switch boundaryType {
            case .initial:
                "--\(boundary)\(Constants.crlf)"
            case .encapsulated:
                "\(Constants.crlf)--\(boundary)\(Constants.crlf)"
            case .final:
                "\(Constants.crlf)--\(boundary)--\(Constants.crlf)"
            }
            return Data(boundaryText.utf8)
        }
    }

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
        var data = Data()

        // 1️⃣ Append initial boundary
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .initial, boundary: boundary))

        // 2️⃣ Append each form part
        for (index, part) in parts.enumerated() {
            var headers = "Content-Disposition: form-data; name=\"\(part.name)\""

            // Include filename if this part is a file
            if let filename = part.filename {
                headers += "; filename=\"\(filename)\""
            }

            headers += Constants.crlf

            // Include Content-Type header if present
            headers += "Content-Type: \(part.mimeType.value)\(Constants.crlf)\(Constants.crlf)"

            // Add headers as Data
            data.append(Data(headers.utf8))

            // Add the actual data payload
            data.append(part.data)

            // If not the last part, add an encapsulated boundary
            if index < parts.count - 1 {
                data.append(BoundaryGenerator.boundaryData(forBoundaryType: .encapsulated, boundary: boundary))
            }
        }

        // 3️⃣ Append final boundary
        data.append(BoundaryGenerator.boundaryData(forBoundaryType: .final, boundary: boundary))

        return data
    }
}
