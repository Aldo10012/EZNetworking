import Foundation

public enum UploadEvent: Sendable, Equatable {
    case progress(Double)
    case completed(Data)
    case failed(NetworkingError)

    public static func == (lhs: UploadEvent, rhs: UploadEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.progress(lhsP), .progress(rhsP)):
            lhsP == rhsP
        case let (.completed(lhsData), .completed(rhsData)):
            lhsData == rhsData
        case let (.failed(lhsE), .failed(rhsE)):
            lhsE == rhsE
        default:
            false
        }
    }
}
