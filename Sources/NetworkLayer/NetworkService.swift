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
    
    public init(
        urlRequestBuilder: URLRequestBuilder,
        networkSession: NetworkSession,
        responseHandler: ResponseHandler,
        retryHandler: RetryHandler
    ) {
        self.urlRequestBuilder = urlRequestBuilder
        self.networkSession = networkSession
        self.responseHandler = responseHandler
        self.retryHandler = retryHandler
    }
    
    public convenience init(urlRequestBuilder: URLRequestBuilder) {
        self.init(
            urlRequestBuilder: urlRequestBuilder,
            networkSession: URLSessionDispatcher(),
            responseHandler: APIResponseDecoder(),
            retryHandler: RequestRetryCoordinator()
        )
    }
    
    public func request<T: Decodable>(_ request: RequestProtocol) async throws -> T {
        let urlRequest = try urlRequestBuilder.buildURLRequest(from: request)
        logRequest(urlRequest)
        return try await retryHandler.executeWithRetry(retryCount: request.retryCount) {
            do {
                let (data, response) = try await networkSession.data(for: urlRequest)
                logResponse(response)
                return try responseHandler.handleResponse(data: data, response: response)
            } catch {
                logError(error)
                throw NetworkError.networkFailure(error: error)
            }
        }
    }
    
    private func logRequest(_ request: URLRequest) {
        print("********************** Request **************************")
        print(request)
        print("*********************************************")
    }
    
    private func logResponse(_ response: URLResponse) {
        print("########################## Response #########################")
        print(response)
        print("###################################################")
    }
    
    private func logError(_ error: Error) {
        print("&&&&&&&&&&&&&&&&&&&&&&&& Error &&&&&&&&&&&&&&&&&&&&&&")
        print(error)
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    }
}
