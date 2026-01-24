@testable import EZNetworking
import Foundation

class MockSession: NetworkSession {
    var configuration: URLSessionConfiguration = .default
    var delegateQueue: OperationQueue?

    var delegate: EZNetworking.SessionDelegate
    var urlSession: any EZNetworking.URLSessionProtocol

    init(urlSession: URLSessionProtocol, delegate: SessionDelegate = SessionDelegate()) {
        self.delegate = delegate
        self.urlSession = urlSession
    }
}
