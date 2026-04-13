import Foundation

extension String {
    /// generate random boundary for multi-part-form data
    public static func getRandomMultiPartFormBoundary() -> String {
        "EZNetworking.Boundary.\(UUID().uuidString)"
    }
}
