# Large Data

## File Download

`FileDownloader` is an actor-based downloader that supports pause, resume, and cancel. It exposes a single `AsyncStream<DownloadEvent>` API.

### Basic Usage
```swift
let downloader = FileDownloader(url: URL(string: "https://example.com/file.pdf")!)

for await event in await downloader.downloadFileStream() {
    switch event {
    case .started:
        // download started
    case .progress(let progress):
        // handle progress (0.0 to 1.0)
    case .completed(let localURL):
        // handle downloaded file at localURL
    case .failed(let error):
        // handle error
    case .failedButCanResume(let error):
        // download failed but can be resumed by calling resume()
    case .paused:
        // download paused
    case .resumed:
        // download resumed
    case .cancelled:
        // download cancelled
    }
}
```

### Pause, Resume, and Cancel
```swift
let downloader = FileDownloader(url: URL(string: "https://example.com/file.pdf")!)

// Start consuming events in a background task
let eventsTask = Task {
    for await event in await downloader.downloadFileStream() {
        // handle events
    }
}

// Pause the download
try await downloader.pause()

// Resume the download
try await downloader.resume()

// Cancel the download
try downloader.cancel()
```

### Background Downloads

To continue downloads when the app is suspended, create a `Session` with a background `URLSessionConfiguration` and inject it into `FileDownloader`:

```swift
let configuration = URLSessionConfiguration.background(withIdentifier: "com.myapp.backgroundDownload")
let session = Session(configuration: configuration)

let downloader = FileDownloader(
    url: URL(string: "https://example.com/largefile.zip")!,
    session: session
)

for await event in await downloader.downloadFileStream() {
    // handle events
}
```

## Data Upload

### Async Await
```swift
do {
  let resultData = try await DataUploader().uploadData(data, with: request, progress: { progress in
    // track progress
  })
  // handle success
} catch {
  // handle error
}
```

### AsyncStream
```swift
for await event in DataUploader().uploadDataStream(data, with: request) {
  switch event {
  case .progress(let value): // handle progress
  case .success(let data): // handle success
  case .failure(let error): // handle error
  }
}
```

### Completion Handler
```swift
DataUploader().uploadData(data, with: request, progress: { progress in
  // track progress
}, completion: { result in
  switch result {
  case: .success(let data):
    // handle success
  case: .failure(let error):
    // handle error
  }
})
```

### Combine Publisher
```swift
DataUploader().uploadDataPublisher(data, with: request: progress: { progress in
  // track progress
})
.sink { completion in
  switch completion {
  case .failure: // handle error
  case .finished: // handle completion
  }
} receiveValue: { data in
  // handle data
}
.store(in: &cancellables)
```

## File Upload

To get a file that exists in your bundle, do this

```swift
fileURL = Bundle.main.url(forResource: "myDocument", withExtension: "txt")
```

To get a file that exists in your files directory, do this

```swift
let customFileURL = URL(fileURLWithPath: "/Users/username/Documents/myFile.pdf")
```

### Async Await
```swift
do {
  let resultData = try await FileUploader().uploadFile(fileURL, with: request, progress: { progress in
    // track progress
  })
  // handle success
} catch {
  // handle error
}
```

### AsyncStream
```swift
for await event in FileUploader().uploadFileStream(fileURL, with: request) {
  switch event {
  case .progress(let value): // handle progress
  case .success(let data): // handle success
  case .failure(let error): // handle error
  }
}
```

### Completion Handler
```swift
FileUploader().uploadFileTask(fileURL, with: request, progress: { progress in
  // track progress
}, completion: { result in
  switch result {
  case: .success(let data):
    // handle success
  case: .failure(let error):
    // handle error
  }
})
```

### Combine Publisher
```swift
FileUploader().uploadFilePublisher(fileURL, with: request: progress: { progress in
  // track progress
})
.sink { completion in
  switch completion {
  case .failure: // handle error
  case .finished: // handle completion
  }
} receiveValue: { data in
  // handle data
}
.store(in: &cancellables)
```

## Multipart-form Upload

```swift
let parts: [MultipartFormPart] = [
    MultipartFormPart.fieldPart(
        name: "username",
        value: "Daniel"
    ),
    MultipartFormPart.filePart(
        name: "profile_picture",
        data: fileData,
        filename: "profile.jpg",
        mimeType: .jpeg
    ),
    MultipartFormPart.dataPart(
        name: "metadata",
        data: Data(encodable: user)!,
        mimeType: .json
    )
]
let multippartFormData = MultipartFormData(parts: parts, boundary: "SOME_BOUNDARY")

// example usage on Request

let request = RequestFactoryImpl().build(
    httpMethod: .POST,
    baseUrlString: "https://www.example.com/upload",
    parameters: nil,
    headers: [
        .contentType(.multipartFormData(boundary: "SOME_BOUNDARY"))
    ],
    body: nil
    // dont inject multippartFormData into the request body. Inject it into DataUploader instead.
    // Reason for this is DataUploader internally uses `URLSession.shared.uploadTask()` which is optimized for uploading data to a server. It takes `data` as an argument and ignores the data provided in `URLRequest.httpBody`
)

// use DataUploader for uploading the data to a server

for await event in DataUploader().uploadDataStream(multippartFormData.toData()!, with: request) {
  switch event {
  case .progress(let value): // handle progress
  case .success(let data): // handle success
  case .failure(let error): // handle error
  }
}

```
