import Foundation

class EZNetworkUtil {
    private let builder: RequestBuildable
    private let performer: RequestPerformable
    private var request: URLRequest?
    
    public convenience init() {
        self.init(builder: RequestBuilder(), performer: RequestPerformer())
    }
    
    init(builder: RequestBuildable, performer: RequestPerformable) {
        self.builder = builder
        self.performer = performer
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
        return try await performer.perform(request: request, decodeTo: decodableObject)
    }
    
    func perform() async throws {
        guard let request = request else {
            throw NetworkingError.noRequest
        }
        try await performer.perform(request: request)
    }
    
    func perform<T: Decodable>(decodeTo type: T.Type, completion: @escaping (Result<T, NetworkingError>) -> Void) {
        guard let request = request else {
            completion(.failure(NetworkingError.noRequest))
            return
        }
        
        performer.perform(request: request, decodeTo: type, completion: completion)
    }
    
    
    func perform(completion: @escaping ((VoidResult<NetworkingError>) -> Void)) {
        guard let request = request else {
            completion(.failure(NetworkingError.noRequest))
            return
        }
        performer.perform(request: request, completion: completion)
    }
}
