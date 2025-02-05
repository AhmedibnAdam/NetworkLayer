//
//  RetryHandler.swift
//  MoviesDB
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation

public protocol RetryHandler: Sendable {
    func executeWithRetry<T: Decodable>(
        retryCount: Int,
        task: () async throws -> T
    ) async throws -> T
}

public final class RequestRetryCoordinator: RetryHandler {
    public func executeWithRetry<T: Decodable>(
        retryCount: Int,
        task: () async throws -> T
    ) async throws -> T {
        var retryCount = retryCount
        var lastError: Error?
        
        repeat {
            do {
                return try await task()
            } catch {
                lastError = error
                retryCount -= 1
            }
        } while retryCount > 0
        
        throw lastError ?? NetworkError.invalidResponse
    }
}
