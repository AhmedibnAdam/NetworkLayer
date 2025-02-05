//
//  NetworkRequestBuilder.swift
//  NetworkLayer
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation

// MARK: - protocol
public protocol URLRequestBuilder {
    func buildURLRequest(from request: RequestProtocol) throws -> URLRequest
}

// MARK: - Concrete Implementations
public final class NetworkRequestBuilder: URLRequestBuilder {

    public func buildURLRequest(from request: RequestProtocol) throws -> URLRequest {
        let url = request.baseURL.appendingPathComponent(request.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // Add API Key as Header instead of Query Parameter (Optional, consider your API design)
        if let apiToken = request.apiToken {
            urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: apiToken)]
        }
        
        // Add additional parameters for GET requests
        if request.method == .get, let parameters = request.parameters {
            urlComponents?.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cachePolicy
        
        // Content-Type Header
        urlRequest.setValue(request.contentType.rawValue, forHTTPHeaderField: "Content-Type")
        
        // Custom Headers
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Authorization Header if needed
        if request.requiresAuthentication, let authToken = request.authToken {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Handle Request Body
        try handleRequestBody(for: request, on: &urlRequest)

        return urlRequest
    }

    private func handleRequestBody(for request: RequestProtocol, on urlRequest: inout URLRequest) throws {
        if request.method != .get, let body = request.body {
            switch request.contentType {
            case .json:
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            case .formData:
                let boundary = UUID().uuidString
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = createMultipartFormData(body: body, boundary: boundary)
            case .urlEncoded:
                urlRequest.httpBody = body.map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&")
                    .data(using: .utf8)
            }
        }
    }

    private func createMultipartFormData(body: [String: Any], boundary: String) -> Data {
        var bodyData = Data()

        for (key, value) in body {
            guard let valueData = "\(value)".data(using: .utf8) else { continue }
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            bodyData.append(valueData)
            bodyData.append("\r\n".data(using: .utf8)!)
        }

        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return bodyData
    }
}
