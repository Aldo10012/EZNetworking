import Foundation

open class SessionDelegate: NSObject {
    // Interceptors
    weak var cacheInterceptor: CacheInterceptor? = nil
    weak var authenticationInterceptor: AuthenticationInterceptor? = nil
    weak var redirectInterceptor: RedirectInterceptor? = nil
    weak var metricsInterceptor: MetricsInterceptor? = nil
    weak var taskLifecycleInterceptor: TaskLifecycleInterceptor? = nil
    weak var dataTaskInterceptor: DataTaskInterceptor? = nil
    weak var downloadTaskInterceptor: DownloadTaskInterceptor? = nil

}
