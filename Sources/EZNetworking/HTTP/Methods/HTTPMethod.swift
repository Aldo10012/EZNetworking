import Foundation

/// Standard HTTP Methods
public enum HTTPMethod: String, CaseIterable {
    /// Retrieve data from server
    case GET
    /// Submit data to server
    case POST
    /// Update existing resource
    case PUT
    /// Delete a resource
    case DELETE
    /// Update partial resource
    case PATCH
    /// Get headers only (without body)
    case HEAD
    /// Get available methods for a resource
    case OPTIONS
    /// Trace request path
    case TRACE
    /// Connect to server (for proxies)
    case CONNECT
}
