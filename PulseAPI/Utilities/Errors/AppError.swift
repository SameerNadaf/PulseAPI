//
//  AppError.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - Base App Error
enum AppError: LocalizedError {
    case network(NetworkError)
    case storage(StorageError)
    case subscription(SubscriptionError)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .storage(let error):
            return error.errorDescription
        case .subscription(let error):
            return error.errorDescription
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noConnection
    case timeout
    case serverError(statusCode: Int, message: String?)
    case decodingFailed(String)
    case encodingFailed
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code, let message):
            return message ?? "Server error (\(code))"
        case .decodingFailed(let details):
            return "Failed to parse response: \(details)"
        case .encodingFailed:
            return "Failed to encode request"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .timeout, .noConnection:
            return true
        case .serverError(let code, _):
            return code >= 500
        default:
            return false
        }
    }
}

// MARK: - Storage Errors
enum StorageError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case notFound
    case corrupted
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let item):
            return "Failed to save \(item)"
        case .loadFailed(let item):
            return "Failed to load \(item)"
        case .deleteFailed(let item):
            return "Failed to delete \(item)"
        case .notFound:
            return "Data not found"
        case .corrupted:
            return "Data is corrupted"
        }
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case purchaseFailed(String)
    case verificationFailed
    case notSubscribed
    case expired
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .verificationFailed:
            return "Subscription verification failed"
        case .notSubscribed:
            return "No active subscription"
        case .expired:
            return "Subscription has expired"
        case .cancelled:
            return "Purchase was cancelled"
        }
    }
}
