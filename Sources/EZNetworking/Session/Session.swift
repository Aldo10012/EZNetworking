import Foundation

public class Session {
    public internal(set) var configuration: URLSessionConfiguration
    public internal(set) var delegate: SessionDelegate
    public internal(set) var delegateQueue: OperationQueue?

    public private(set) lazy var urlSession: URLSessionProtocol = {
        URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }()

    public init(
        configuration: URLSessionConfiguration = .default,
        delegate: SessionDelegate = SessionDelegate(),
        delegateQueue: OperationQueue? = nil
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }
}
