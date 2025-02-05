//
//  NetworkService.swift
//  NetworkLayer
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation

// MARK: - Network Service
protocol NetworkServicing {
    func request<T: Decodable>(_ request: RequestProtocol) async throws -> T
}

@available(macOS 12.0, *)
public final class NetworkService: NetworkServicing {
    
    private let urlRequestBuilder: URLRequestBuilder
    private let networkSession: NetworkSession
    private let responseHandler: ResponseHandler
    private let retryHandler: RetryHandler
    
    // Singleton instance
    nonisolated(unsafe) public static let shared = NetworkService()
    
    private init(
        urlRequestBuilder: URLRequestBuilder = NetworkRequestBuilder(),
        networkSession: NetworkSession = URLSessionDispatcher(),
        responseHandler: ResponseHandler = APIResponseDecoder(),
        retryHandler: RetryHandler = RequestRetryCoordinator()
    ) {
        self.urlRequestBuilder = urlRequestBuilder
        self.networkSession = networkSession
        self.responseHandler = responseHandler
        self.retryHandler = retryHandler
    }
    
    public func request<T: Decodable>(_ request: RequestProtocol) async throws -> T {
        if await !ReachabilityManager.shared.isNetworkReachable() {
            throw NetworkError.networkFailure
        }
        let urlRequest = try urlRequestBuilder.buildURLRequest(from: request)
        logRequest(urlRequest)
        
        return try await retryHandler.executeWithRetry(retryCount: request.retryCount) {
            do {
                let (data, response) = try await networkSession.data(for: urlRequest)
                logResponse(response)
                return try responseHandler.handleResponse(data: data, response: response)
            } catch {
                logError(error)
                throw NetworkError.networkFailure
            }
        }
    }
    
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("********************** Request **************************")
        print(request)
        print("*********************************************")
        #endif
    }
    
    private func logResponse(_ response: URLResponse) {
        #if DEBUG
        print("########################## Response #########################")
        print(response)
        print("###################################################")
        #endif
    }
    
    private func logError(_ error: Error) {
        #if DEBUG
        print("&&&&&&&&&&&&&&&&&&&&&&&& Error &&&&&&&&&&&&&&&&&&&&&&")
        print(error)
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        #endif
    }
}
