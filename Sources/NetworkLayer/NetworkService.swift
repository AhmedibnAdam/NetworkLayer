//
//  NetworkService.swift
//  MoviesDB
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation


// MARK: - Network Service
@available(macOS 12.0, *)
public final class NetworkService {
    
    private let urlRequestBuilder: URLRequestBuilder
    private let networkSession: NetworkSession
    private let responseHandler: ResponseHandler
    private let retryHandler: RetryHandler
    
    init(
        urlRequestBuilder: URLRequestBuilder ,
        networkSession: NetworkSession = URLSessionDispatcher(),
        responseHandler: ResponseHandler = APIResponseDecoder(),
        retryHandler: RetryHandler = RequestRetryCoordinator()
    ) {
        self.urlRequestBuilder = urlRequestBuilder
        self.networkSession = networkSession
        self.responseHandler = responseHandler
        self.retryHandler = retryHandler
    }
    
    func request<T: Decodable>(_ request: RequestProtocol) async throws -> T {
        let urlRequest = try urlRequestBuilder.buildURLRequest(from: request)
        
        return try await retryHandler.executeWithRetry(retryCount: request.retryCount) {
            let (data, response) = try await networkSession.data(for: urlRequest)
            return try responseHandler.handleResponse(data: data, response: response)
        }
    }

}
