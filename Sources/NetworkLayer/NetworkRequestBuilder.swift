//
//  NetworkRequestBuilder.swift
//  MoviesDB
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation

// MARK: - 
public protocol URLRequestBuilder {
    func buildURLRequest(from request: RequestProtocol) throws -> URLRequest
}

// MARK: - Concrete Implementations

public final class NetworkRequestBuilder: URLRequestBuilder {
    private let baseURL: URL
    private let authToken: String?
    private let apiToken: String?
    
    public init(baseURL: URL, authToken: String?, apiToken: String?) {
        self.baseURL = baseURL
        self.authToken = authToken
        self.apiToken = apiToken
    }
    
    public func buildURLRequest(from request: RequestProtocol) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(request.path)
       
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // Add the API key as a query parameter
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: apiToken)
        urlComponents?.queryItems = [apiKeyQueryItem]
        
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
        
        urlRequest.setValue(request.contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if request.requiresAuthentication, let authToken = authToken {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
       
        
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
        
        return urlRequest
    }
    
    private func createMultipartFormData(body: [String: Any], boundary: String) -> Data {
        var bodyData = Data()
        
        for (key, value) in body {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            bodyData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return bodyData
    }
}
