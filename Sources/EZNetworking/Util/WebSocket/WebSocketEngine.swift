import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private let sessionDelegate: SessionDelegate?
    
    // MARK: - init
    
    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        if let urlSession = urlSession as? URLSession {
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
                let newDelegate = sessionDelegate ?? SessionDelegate()
                let newSession = URLSession(
                    configuration: urlSession.configuration,
                    delegate: newDelegate,
                    delegateQueue: urlSession.delegateQueue
                )
                self.sessionDelegate = newDelegate
                self.urlSession = newSession
            }
        } else {
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
    }
    
    // MARK: - Connect
    
    // TODO: Implement
    
    // MARK: - Disconnect
    
    // TODO: Implement

    // MARK: - Send message
    
    // TODO: Implement

    // MARK: - Receive message
    
    // TODO: Implement

}
