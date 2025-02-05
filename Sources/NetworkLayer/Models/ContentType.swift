//
//  ContentType.swift
//  NetworkLayer
//
//  Created by Ahmad on 05/02/2025.
//


// MARK: - Content Type
public enum ContentType: String {
    case json = "application/json"
    case formData = "multipart/form-data"
    case urlEncoded = "application/x-www-form-urlencoded"
}
