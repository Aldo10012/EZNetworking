import Foundation

class EZNetworkUtil {
    private let builder: RequestBuildable
    private let performer: RequestPerformable
    private let asyncPerformer: AsyncRequestPerformable
    private var request: URLRequest?
    
    public convenience init() {
        self.init(builder: RequestBuilder(),
                  performer: RequestPerformer(),
                  asyncPerformer: AsyncRequestPerformer())
    }
    
    init(builder: RequestBuildable, 
         performer: RequestPerformable,
         asyncPerformer: AsyncRequestPerformable) {
        self.builder = builder
        self.performer = performer
        self.asyncPerformer = asyncPerformer
    }
    
    func request(httpMethod: HTTPMethod,
                 urlString: String,
                 parameters: [HTTPParameter]?,
                 headers: [HTTPHeader]? = nil,
                 body: Data? = nil,
                 timeoutInterval: TimeInterval = 60) -> EZNetworkUtil {
        self.request = builder.build(httpMethod: httpMethod, urlString: urlString, parameters: parameters, headers: headers, body: body, timeoutInterval: timeoutInterval)
        return self
    }
    
    func perform<T: Codable>(decodeTo decodableObject: T.Type) async throws -> T {
        guard let request = request else {
            throw NetworkingError.noRequest
        }
        return try await asyncPerformer.perform(request: request, decodeTo: decodableObject)
    }
    
    func perform() async throws {
        guard let request = request else {
            throw NetworkingError.noRequest
        }
        try await asyncPerformer.perform(request: request)
    }
    
    func perform<T: Decodable>(decodeTo type: T.Type, completion: @escaping (Result<T, NetworkingError>) -> Void) {
        guard let request = request else {
            completion(.failure(NetworkingError.noRequest))
            return
        }
        
        performer.performTask(request: request, decodeTo: type, completion: completion).resume()
    }
    
    
    func perform(completion: @escaping ((VoidResult<NetworkingError>) -> Void)) {
        guard let request = request else {
            completion(.failure(NetworkingError.noRequest))
            return
        }
        performer.performTask(request: request, completion: completion).resume()
    }
}
