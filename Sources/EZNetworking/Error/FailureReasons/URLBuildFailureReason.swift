import Foundation

public enum URLBuildFailureReason: Equatable, Sendable {
    case noURL
    case invalidURL
    case invalidScheme(String?)
    case missingHost
}
