import Foundation

public enum DownloadDestination: Sendable {
    /// Copies the file to a stable temporary directory so it survives the URLSession callback.
    case temporary

    /// Moves the file to the user's Documents directory with the given filename.
    case documents(filename: String)

    /// Lets the caller decide where to move the file.
    case custom(@Sendable (URL /*tempURL*/) throws -> URL)

    func moveFile(from tempURL: URL, fileManager: FileManager = .default) throws -> URL {
        switch self {
        case .temporary:
            let destination = fileManager.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(tempURL.pathExtension)
            try fileManager.copyItem(at: tempURL, to: destination)
            return destination

        case .documents(let filename):
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let destination = documentsURL.appendingPathComponent(filename)
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.moveItem(at: tempURL, to: destination)
            return destination

        case .custom(let handler):
            return try handler(tempURL)
        }
    }
}
