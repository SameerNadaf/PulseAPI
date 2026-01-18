//
//  Endpoint.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - HTTP Method
enum HTTPMethod: String, Codable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

// MARK: - Endpoint Status
enum EndpointStatus: String, Codable {
    case healthy     // Response time within baseline, no errors
    case degraded    // Response time above baseline or intermittent errors
    case down        // Consistent failures or timeouts
    case unknown     // No probe data yet
    
    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .degraded: return "Degraded"
        case .down: return "Down"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Endpoint Model
struct Endpoint: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var url: String
    var method: HTTPMethod
    var headers: [String: String]?
    var body: String?
    var probeIntervalMinutes: Int
    var timeoutSeconds: Int
    var expectedStatusCodes: [Int]
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed Properties
    var host: String? {
        URL(string: url)?.host
    }
    
    var path: String {
        URL(string: url)?.path ?? "/"
    }
}

// MARK: - Endpoint + Defaults
extension Endpoint {
    static func new(name: String, url: String, method: HTTPMethod = .get) -> Endpoint {
        Endpoint(
            id: UUID().uuidString,
            name: name,
            url: url,
            method: method,
            headers: nil,
            body: nil,
            probeIntervalMinutes: AppConstants.defaultProbeIntervalMinutes,
            timeoutSeconds: Int(APIConfig.probeTimeout),
            expectedStatusCodes: [200, 201, 204],
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Endpoint Health Summary
struct EndpointHealthSummary: Codable {
    let endpointId: String
    let status: EndpointStatus
    let reliabilityScore: Double // 0.0 to 100.0
    let currentLatencyMs: Double?
    let baselineLatencyMs: Double?
    let errorRate: Double // 0.0 to 1.0
    let lastProbeAt: Date?
    let lastIncidentAt: Date?
    let uptimePercentage: Double // 0.0 to 100.0 (last 30 days)
}
