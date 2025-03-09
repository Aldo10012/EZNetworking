import Foundation

public class SessionDelegate: NSObject {
    public weak var cacheInterceptor: CacheInterceptor? = nil
    public weak var authenticationInterceptor: AuthenticationInterceptor? = nil
    public weak var redirectInterceptor: RedirectInterceptor? = nil
    public weak var metricsInterceptor: MetricsInterceptor? = nil
    public weak var taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil
    public weak var dataTaskInterceptor: DataTaskInterceptor? = nil
    public weak var downloadTaskInterceptor: DownloadTaskInterceptor? = nil
    public weak var streamTaskInterceptor: StreamTaskInterceptor? = nil
    public weak var webSocketTaskInterceptor: WebSocketTaskInterceptor? = nil
    
    override public init() {}
}
