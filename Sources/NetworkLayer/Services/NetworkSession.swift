//
//  NetworkSession.swift
//  NetworkLayer
//
//  Created by Ahmad on 05/02/2025.
//

import Foundation

public protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

@available(macOS 12.0, *)
public final class URLSessionDispatcher: NetworkSession {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}
