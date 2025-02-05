//
//  RequestProtocol.swift
//  NetworkLayer
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation


// MARK: - Request Protocol
public protocol RequestProtocol {
    var baseURL: URL { get }
    var authToken: String? { get }
    var apiToken: String? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var body: [String: Any]? { get }
    var contentType: ContentType { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var retryCount: Int { get }
    var requiresAuthentication: Bool { get }
}
