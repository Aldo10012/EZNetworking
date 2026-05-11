# Performing a Request

## Async/Await Usage

Modern Swift concurrency support:

```swift
// With response decoding
do {
    let userData = try await RequestPerformer().perform(request: request, decodeTo: UserData.self)
    // Handle decoded response
} catch {
    // Handle error
}

// Without decoding
do {
    try await RequestPerformer().perform(request: request, decodeTo: EmptyResponse.self)
    // Handle success
} catch {
    // Handle error
}
```

## Error Handling

EZNetworking provides comprehensive error handling:

```swift
public enum NetworkingError: Error {
    case couldNotBuildURLRequest(reason: URLBuildFailureReason)
    case decodingFailed(reason: DecodingFailureReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case requestFailed(reason: RequestFailureReason)
}

// Error handling example
do {
    let response = try await RequestPerformer().perform(request: request, decodeTo: UserData.self)
    // do something with the response
} catch let error as NetworkingError {
    switch error {
    case .couldNotBuildURLRequest(reason: let reason):
        // url inside of your Request is invalid
    case .decodingFailed(reason: let reason):
        // could not decode data into your Decodable type
    case .responseValidationFailed(reason: let reason):
        // bad URLResponse
    case .requestFailed(reason: let reason):
        // api request failed
    }
}
```
