import Foundation

public protocol NetworkSession {
    var configuration: URLSessionConfiguration { get }
    var delegate: SessionDelegate { get }
    var delegateQueue: OperationQueue? { get }

    var urlSession: URLSessionProtocol { get }
}

public class Session: NetworkSession {
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
