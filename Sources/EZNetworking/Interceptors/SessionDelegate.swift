import Foundation

public class SessionDelegate: NSObject {
    public weak var cacheInterceptor: CacheInterceptor? = nil
    public weak var authenticationInterceptor: AuthenticationInterceptor? = nil
    public weak var redirectInterceptor: RedirectInterceptor? = nil
    public weak var metricsInterceptor: MetricsInterceptor? = nil
    public weak var taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil
    public weak var dataTaskInterceptor: DataTaskInterceptor? = nil
    public weak var downloadTaskInterceptor: DownloadTaskInterceptor? = nil
    public weak var uploadTaskInterceptor: UploadTaskInterceptor? = nil
    public weak var streamTaskInterceptor: StreamTaskInterceptor? = nil
    public weak var webSocketTaskInterceptor: WebSocketTaskInterceptor? = nil
    
    public init(cacheInterceptor: CacheInterceptor? = nil,
                authenticationInterceptor: AuthenticationInterceptor? = nil,
                redirectInterceptor: RedirectInterceptor? = nil,
                metricsInterceptor: MetricsInterceptor? = nil,
                taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil,
                dataTaskInterceptor: DataTaskInterceptor? = nil,
                downloadTaskInterceptor: DownloadTaskInterceptor? = nil,
                uploadTaskInterceptor: UploadTaskInterceptor? = nil,
                streamTaskInterceptor: StreamTaskInterceptor? = nil,
                webSocketTaskInterceptor: WebSocketTaskInterceptor? = nil) {
        self.cacheInterceptor = cacheInterceptor
        self.authenticationInterceptor = authenticationInterceptor
        self.redirectInterceptor = redirectInterceptor
        self.metricsInterceptor = metricsInterceptor
        self.taskLifecycleInterceptor = taskLifecycleInterceptor
        self.dataTaskInterceptor = dataTaskInterceptor
        self.downloadTaskInterceptor = downloadTaskInterceptor
        self.uploadTaskInterceptor = uploadTaskInterceptor
        self.streamTaskInterceptor = streamTaskInterceptor
        self.webSocketTaskInterceptor = webSocketTaskInterceptor
    }
}
