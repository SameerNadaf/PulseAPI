//
//  Environment.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

enum AppEnvironment {
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

enum APIConfig {
    // MARK: - Base URLs
    static var baseURL: String {
        switch AppEnvironment.current {
        case .development:
            return "http://localhost:8787"
        case .staging:
            return "https://api-staging.pulseapi.dev"
        case .production:
            return "https://api.pulseapi.dev"
        }
    }
    
    // MARK: - API Version
    static let apiVersion = "v1"
    
    // MARK: - Computed
    static var fullBaseURL: String {
        "\(baseURL)/\(apiVersion)"
    }
    
    // MARK: - Timeouts (in seconds)
    static let requestTimeout: TimeInterval = 30
    static let probeTimeout: TimeInterval = 10
    
    // MARK: - Retry Configuration
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
}

enum AppConstants {
    // MARK: - App Identity
    static let appName = "PulseAPI"
    static let bundleID = "com.pulseapi.app"
    
    // MARK: - Subscription
    static let freeEndpointLimit = 3
    static let proEndpointLimit = 50
    
    // MARK: - Probe Settings
    static let defaultProbeIntervalMinutes = 5
    static let minimumProbeIntervalMinutes = 1
    static let maximumProbeIntervalMinutes = 60
    
    // MARK: - Data Retention
    static let probeDataRetentionDays = 30
    static let incidentRetentionDays = 90
    
    // MARK: - UI
    static let animationDuration: Double = 0.25
    static let chartDataPoints = 24 // Last 24 data points for sparklines
}
