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

## Completion Handlers

Traditional callback-based approach:

```swift
// With response decoding
RequestPerformer().performTask(request: request, decodeTo: UserData.self) { result in
    switch result {
    case .success(let userData):
        // Handle decoded response
    case .failure(let error):
        // Handle error
    }
}

// Without decoding
RequestPerformer().performTask(request: request, decodeTo: EmptyResponse.self) { result in
    switch result {
    case .success:
        // Handle success
    case .failure(let error):
        // Handle error
    }
}
```

## Task Control

Control over URLSessionTask:

```swift
// Store task reference
let task = RequestPerformer().performTask(request: request) { _ in
    // Handle completion
}

// Cancel task if needed
task.cancel()

// Resume suspended task
task.resume()

// Suspend task
task.suspend()

// Get task state
print(task.state) // running, suspended, canceling, completed
```

## Publishers

If you prefer using the Combine framework

```swift
let cancellables = Set<AnyCancellable>()

RequestPerformer()
    .performPublisher(request: CustomRequest(), decodeTo: CustomeType.swift)
    .sink(receiveCompletion: { completion in
        // handle completion
    }, receiveValue: { customType in
        // handle response
    })
    .store(in: &cancellables)
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
    let response = try await AsyncRequestPerformer().perform(request: request, decodeTo: UserData.self)
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
