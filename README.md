# Network Layer

## Overview

This repository contains the **Network Layer** for handling HTTP requests in an iOS application. The layer includes features like network reachability checks, retry mechanisms, and centralized error handling using Swift's `async/await`.

### Key Features:
- **Network Reachability**
- **Retry Logic**
- **Async/Await**
- **Error Handling**

---

## Components

### `NetworkService`

```swift
public class NetworkService {
    static let shared = NetworkService()

    public func request<T: Decodable>(_ request: RequestProtocol) async throws -> T
}
```
- request(_: RequestProtocol): Makes an HTTP request and returns a decoded response of type T.
- Parameters: A RequestProtocol object that contains the URL, HTTP method, parameters, and retry count.
- Returns: A decoded object of type T (must conform to Decodable).
- Throws: Throws an error if the request fails or if there are decoding issues.

### `RequestProtocol`

```swift

public protocol RequestProtocol {
    var url: URL { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var retryCount: Int { get }
}
```

- url: The URL for the request.
- method: The HTTP method (e.g., GET, POST).
- parameters: Optional parameters for the request.
- retryCount: Number of retry attempts in case of failure.

### `ReachabilityManager`

```swift

public class ReachabilityManager {
    public static let shared = ReachabilityManager()

    public func isNetworkReachable() async -> Bool
}
```
- isNetworkReachable(): Checks if the device has an active internet connection.

### `RetryHandler`

```swift

public class RetryHandler {
    public func executeWithRetry<T>(retryCount: Int, block: @escaping () async throws -> T) async throws -> T
}
```

- executeWithRetry(retryCount:block:): Executes a block and retries the block up to retryCount times if it fails.

### `ResponseHandler`

```swift

public class ResponseHandler {
    public func handleResponse<T>(data: Data, response: URLResponse) throws -> T
}
```
- handleResponse(data:response:): Decodes the Data into an object of type T (conforming to Decodable).

### `Usage`

1. Define a Request Type
```swift

struct MyRequest: RequestProtocol {
    var url: URL
    var method: HTTPMethod
    var parameters: [String: Any]?
    var retryCount: Int
}
```
2. Make a Network Request
   
```swift
async {
    do {
        let request = MyRequest(url: URL(string: "https://api.example.com/data")!, method: .get, retryCount: 3, parameters: nil)
        let response: MyResponseType = try await NetworkService.shared.request(request)
        print("Response: \(response)")
    } catch {
        print("Request failed with error: \(error)")
    }
}
```

3. Define the Response Type
   
```swift
struct MyResponseType: Decodable {
    let name: String
    let age: Int
}
```
4. Customize Retry Count
```swift

let request = MyRequest(url: URL(string: "https://api.example.com/data")!, method: .get, retryCount: 5, parameters: nil)
```

5. Handle Errors
```swift

do {
    let response: MyResponseType = try await NetworkService.shared.request(request)
} catch let error {
    print("Error: \(error)")
}
```
### `Requirements`

iOS 13.0 or later
Swift 5.5 or later (for async/await support)

### `License`
This project is licensed under the MIT License. See the LICENSE file for more information.

### `Contributing`
Feel free to fork this repository, submit issues, or open pull requests to improve the network layer.
