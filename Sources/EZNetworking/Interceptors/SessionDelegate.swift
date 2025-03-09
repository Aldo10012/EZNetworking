import Foundation

open class SessionDelegate: NSObject {
    weak var cacheInterceptor: CacheInterceptor? = nil
    weak var authenticationInterceptor: AuthenticationInterceptor? = nil
    weak var redirectInterceptor: RedirectInterceptor? = nil
    weak var metricsInterceptor: MetricsInterceptor? = nil
    weak var taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil
    weak var dataTaskInterceptor: DataTaskInterceptor? = nil
    weak var downloadTaskInterceptor: DownloadTaskInterceptor? = nil
    weak var streamTaskInterceptor: StreamTaskInterceptor? = nil
    weak var webSocketTaskInterceptor: WebSocketTaskInterceptor? = nil
    
    public init(cacheInterceptor: CacheInterceptor? = nil,
                authenticationInterceptor: AuthenticationInterceptor? = nil,
                redirectInterceptor: RedirectInterceptor? = nil,
                metricsInterceptor: MetricsInterceptor? = nil,
                taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil,
                dataTaskInterceptor: DataTaskInterceptor? = nil,
                downloadTaskInterceptor: DownloadTaskInterceptor? = nil,
                streamTaskInterceptor: StreamTaskInterceptor? = nil,
                webSocketTaskInterceptor: WebSocketTaskInterceptor? = nil) {
        self.cacheInterceptor = cacheInterceptor
        self.authenticationInterceptor = authenticationInterceptor
        self.redirectInterceptor = redirectInterceptor
        self.metricsInterceptor = metricsInterceptor
        self.taskLifecycleInterceptor = taskLifecycleInterceptor
        self.dataTaskInterceptor = dataTaskInterceptor
        self.downloadTaskInterceptor = downloadTaskInterceptor
        self.streamTaskInterceptor = streamTaskInterceptor
        self.webSocketTaskInterceptor = webSocketTaskInterceptor
    }
}
