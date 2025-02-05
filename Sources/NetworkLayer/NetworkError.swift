//
//  NetworkError.swift
//  MoviesDB
//
//  Created by Ahmad on 27/01/2025.
//
import Foundation

// MARK: - Network Error
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case clientError(statusCode: Int)
    case unknownStatusCode(statusCode: Int)
    case networkFailure(error: Error)
    case parameterEncodingFailed
    case decodingError(Error)
    case noData
    case customError(String)
    case authenticationFailed
    case requestCancelled


    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid."
        case .invalidResponse:
            return "The server response was not valid."
        case .serverError(let statusCode):
            return "Server error occurred. Status code: \(statusCode)."
        case .clientError(let statusCode):
            return "Client error occurred. Status code: \(statusCode)."
        case .unknownStatusCode(let statusCode):
            return "Unexpected status code: \(statusCode)."
        case .networkFailure(let error):
            return "Network failure: \(error.localizedDescription)"
        case .parameterEncodingFailed:
            return "parameterEncodingFailed"
        case .decodingError(let error):
            return "decoding failure: \(error.localizedDescription)"
        case .noData:
            return "No Data"
        case .customError(let error):
            return "failure: \(error)"
        case .authenticationFailed:
            return "Authentication Failed"
        case .requestCancelled:
            return "Request Cancelled"
        }
    }
}
