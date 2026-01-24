import Foundation

public class SessionDelegate: NSObject {
    public weak var cacheInterceptor: CacheInterceptor?
    public weak var authenticationInterceptor: AuthenticationInterceptor?
    public weak var redirectInterceptor: RedirectInterceptor?
    public weak var metricsInterceptor: MetricsInterceptor?
    public weak var taskLifecycleInterceptor: TaskLifecycleInterceptor?
    public weak var dataTaskInterceptor: DataTaskInterceptor?
    public weak var downloadTaskInterceptor: DownloadTaskInterceptor?
    public weak var uploadTaskInterceptor: UploadTaskInterceptor?
    public weak var streamTaskInterceptor: StreamTaskInterceptor?
    public weak var webSocketTaskInterceptor: WebSocketTaskInterceptor?

    public init(
        cacheInterceptor: CacheInterceptor? = nil,
        authenticationInterceptor: AuthenticationInterceptor? = nil,
        redirectInterceptor: RedirectInterceptor? = nil,
        metricsInterceptor: MetricsInterceptor? = nil,
        taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil,
        dataTaskInterceptor: DataTaskInterceptor? = nil,
        downloadTaskInterceptor: DownloadTaskInterceptor? = nil,
        uploadTaskInterceptor: UploadTaskInterceptor? = nil,
        streamTaskInterceptor: StreamTaskInterceptor? = nil,
        webSocketTaskInterceptor: WebSocketTaskInterceptor? = nil
    ) {
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
